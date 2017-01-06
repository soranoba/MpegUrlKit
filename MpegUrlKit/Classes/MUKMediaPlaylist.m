//
//  MUKMediaPlaylist.m
//  MpegUrlKit
//
//  Created by Hinagiku Soranoba on 2017/01/06.
//  Copyright © 2017年 Hinagiku Soranoba. All rights reserved.
//

#import "MUKMediaPlaylist.h"
#import "MUKConsts.h"
#import "NSError+MUKErrorDomain.h"

@interface MUKMediaPlaylist ()
@property (nonatomic, assign) BOOL hasExtm3u;
@property (nonatomic, assign) BOOL isWaitingMediaSegmentUri;

@property (nonatomic, nonnull, strong) NSMutableArray<MUKMediaSegment*>* processingMediaSegments;
@property (nonatomic, nullable, copy) MUKSegmentValidator segmentValidator;
@end

@implementation MUKMediaPlaylist

#pragma mark - Lifecycle

- (instancetype _Nullable)init
{
    if (self = [super init]) {
        self.processingMediaSegments = [NSMutableArray array];
        self.mediaSegments = [NSArray array];
    }
    return self;
}

#pragma mark - Private Methods

/**
 * 4.3.1.1 EXTM3U
 */
- (MUKLineActionResult)onExtm3u:(NSString* _Nonnull)line error:(NSError* _Nullable* _Nullable)error
{
    self.hasExtm3u = YES;
    return MUKLineActionResultProcessed;
}

- (MUKLineActionResult)notFoundExtm3u:(NSError* _Nullable* _Nullable)error
{
    SET_ERROR(error, MUKErrorInvalidM3UFormat, @"EXTM3U is not on the first line");
    return MUKLineActionResultErrored;
}

/**
 * 4.3.1.2 EXT-X-VERSION
 */
- (MUKLineActionResult)onVersion:(NSString* _Nonnull)line error:(NSError* _Nullable* _Nullable)error
{
    if (self.version > 0) {
        SET_ERROR(error, MUKErrorInvalidVersion, @"It has multiple EXT-X-VERSION");
        return MUKLineActionResultErrored;
    }

    NSString* versionStr = TAG_VALUE(MUK_EXT_X_VERSION, line);
    NSInteger version = [versionStr integerValue];
    if (version < 1) {
        SET_ERROR(error, MUKErrorInvalidVersion,
                  ([NSString stringWithFormat:@"%@ is an invalid version", versionStr]));
        return MUKLineActionResultErrored;
    }

    self.version = version;
    return MUKLineActionResultProcessed;
}

/**
 * 4.3.2.1 EXTINF
 */
- (MUKLineActionResult)onExtinf:(NSString* _Nonnull)line error:(NSError* _Nullable* _Nullable)error
{
    NSArray<NSString*>* strs = [TAG_VALUE(MUK_EXTINF, line) componentsSeparatedByString:@","];
    if (strs.count != 2) {
        SET_ERROR(error, MUKErrorInvalidMediaSegment,
                  @"EXTINF MUST contain a character (#EXTINF:duration,[title])");
        return MUKLineActionResultErrored;
    }

    if (self.version < 3 && [strs[0] rangeOfString:@"."].location != NSNotFound) {
        SET_ERROR(error, MUKErrorInvalidMediaSegment,
                  ([NSString stringWithFormat:@"Version %lu does NOT supoort float duration", self.version]));
        return MUKLineActionResultErrored;
    }

    if (!self.isWaitingMediaSegmentUri) {
        [self.processingMediaSegments addObject:[MUKMediaSegment new]];
    }

    MUKMediaSegment* mediaSegment = [self.processingMediaSegments lastObject];
    NSAssert(mediaSegment, @"isWaitingMediaSegmentUri is YES, but processingMediaSegments is empty");

    mediaSegment.duration = [strs[0] floatValue];
    mediaSegment.title = strs[1];

    self.isWaitingMediaSegmentUri = YES;
    return MUKLineActionResultProcessed;
}

- (MUKLineActionResult)onMediaSegmentUrl:(NSString* _Nonnull)line error:(NSError* _Nullable* _Nullable)error
{
    if (self.isWaitingMediaSegmentUri && line.length > 0 && ![line hasPrefix:@"#"]) {
        MUKMediaSegment* mediaSegment = [self.processingMediaSegments lastObject];
        NSAssert(mediaSegment, @"isWaitingMediaSegmentUri is YES, but processingMediaSegments is empty");

        mediaSegment.uri = line;
        self.isWaitingMediaSegmentUri = NO;

        MUKSegmentValidator segmentValidator = self.segmentValidator;
        self.segmentValidator = nil;

        if (segmentValidator) {
            return segmentValidator(mediaSegment, error);
        } else {
            return MUKLineActionResultProcessed;
        }
    }
    return MUKLineActionResultIgnored;
}

/**
 * 4.3.2.2 EXT-X-BYTERANGE
 */
- (MUKLineActionResult)onByteRange:(NSString* _Nonnull)line error:(NSError* _Nullable* _Nullable)error
{
    if (self.version < 4) { // not supported.
        return MUKLineActionResultIgnored;
    }

    if (!self.isWaitingMediaSegmentUri) {
        [self.processingMediaSegments addObject:[MUKMediaSegment new]];
    }

    MUKMediaSegment* mediaSegment = [self.processingMediaSegments lastObject];
    MUKMediaSegment* previousMediaSegment = nil;
    if (self.processingMediaSegments.count >= 2) {
        previousMediaSegment = self.processingMediaSegments[self.processingMediaSegments.count - 2];
    }

    // #EXT-X-BYTERANGE:<length>[@<offset>]
    NSArray<NSString*>* strs = [TAG_VALUE(MUK_EXT_X_BYTERANGE, line) componentsSeparatedByString:@"@"];
    if (!(strs.count >= 1 && strs.count <= 2)) {
        SET_ERROR(error, MUKErrorInvalidByteRange,
                  ([NSString stringWithFormat:@"%@ is invalid byte range format", line]));
        return MUKLineActionResultErrored;
    }

    NSInteger length = [strs[0] integerValue];
    if (length < 0) {
        SET_ERROR(error, MUKErrorInvalidByteRange,
                  ([NSString stringWithFormat:@"length MUST be positive integer, but got %@", strs[0]]));
        return MUKLineActionResultErrored;
    }

    if (strs.count == 2) {
        NSInteger offset = [strs[1] integerValue];
        if (offset < 0) {
            SET_ERROR(error, MUKErrorInvalidByteRange,
                      ([NSString stringWithFormat:@"offcet MUST be positive integer, but got %@", strs[1]]));
            return MUKLineActionResultErrored;
        }
        mediaSegment.byteRange = NSMakeRange(offset, length);
    } else if (previousMediaSegment) {
        mediaSegment.byteRange = NSMakeRange(NSMaxRange(previousMediaSegment.byteRange), length);
        mediaSegment.uri = previousMediaSegment.uri;
        self.segmentValidator = [^(MUKMediaSegment* _Nonnull mediaSegment, NSError* _Nullable* _Nullable error) {
            if (![mediaSegment.uri isEqualToString:previousMediaSegment.uri]) {
                SET_ERROR(error, MUKErrorInvalidByteRange,
                          @"offcet is not present, but previous media segment is not same media resource");
                return MUKLineActionResultErrored;
            }
            return MUKLineActionResultProcessed;
        } copy];
    } else {
        SET_ERROR(error, MUKErrorInvalidByteRange,
                  @"offcet is not found, but previous media segment also be not found");
        return MUKLineActionResultErrored;
    }

    self.isWaitingMediaSegmentUri = YES;
    return MUKLineActionResultProcessed;
}

#pragma mark - MUKSerializing (Override)

- (NSDictionary<NSString*, MUKLineAction>* _Nonnull)lineActions
{
    __weak typeof(self) weakSelf = self;

    if (!self.hasExtm3u) {
        return @{ MUK_EXTM3U : ACTION([weakSelf onExtm3u:line error:error]),
                  @"" : ACTION([weakSelf notFoundExtm3u:error]) };
    } else if (self.isWaitingMediaSegmentUri) {
        return @{ MUK_EXT_X_BYTERANGE : ACTION([weakSelf onByteRange:line error:error]),
                  @"" : ACTION([weakSelf onMediaSegmentUrl:line error:error]) };
    } else {
        return @{ MUK_EXT_X_VERSION : ACTION([weakSelf onVersion:line error:error]),
                  MUK_EXTINF : ACTION([weakSelf onExtinf:line error:error]),
                  MUK_EXT_X_BYTERANGE : ACTION([weakSelf onByteRange:line error:error]) };
    }
}

#pragma mark - MUKSerializing

- (void)beginSerialization
{
    self.version = 0;
    self.hasExtm3u = NO;
    self.isWaitingMediaSegmentUri = NO;
    [self.processingMediaSegments removeAllObjects];
}

- (void)endSerialization
{
    if (self.version == 0) {
        self.version = 1;
    }
    self.mediaSegments = self.processingMediaSegments;
}

- (BOOL)validate:(NSError* _Nullable* _Nullable)error
{
    if (!self.hasExtm3u) {
        SET_ERROR(error, MUKErrorInvalidM3UFormat, @"EXTM3U is NOT found");
    } else if (self.isWaitingMediaSegmentUri) {
        SET_ERROR(error, MUKErrorInvalidMediaSegment, @"A media segment has EXTINF, but it does NOT have URI");
    } else {
        return YES;
    }
    return NO;
}

@end
