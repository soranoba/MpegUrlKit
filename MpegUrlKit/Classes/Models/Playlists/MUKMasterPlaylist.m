//
//  MUKMasterPlaylist.m
//  MpegUrlKit
//
//  Created by Hinagiku Soranoba on 2017/01/06.
//  Copyright © 2017年 Hinagiku Soranoba. All rights reserved.
//

#import "MUKMasterPlaylist.h"
#import "MUKAttributeSerializer.h"
#import "MUKConsts.h"
#import "MUKXStreamInf+Private.h"
#import "NSError+MUKErrorDomain.h"
#import "NSString+MUKExtension.h"

@interface MUKMasterPlaylist ()
@property (nonatomic, assign) BOOL hasExtm3u;
@property (nonatomic, nonnull, strong) NSMutableArray<MUKXMedia*>* processingMedias;
@property (nonatomic, assign) BOOL isWaitingStreamUri;
@property (nonatomic, nonnull, strong) NSMutableArray<MUKXStreamInf*>* processingStreamInfs;
@property (nonatomic, nonnull, strong) NSMutableArray<MUKXSessionData*>* processingSessionDatas;
@property (nonatomic, nonnull, strong) NSMutableArray<MUKXKey*>* processingSessionKeys;
@end

@implementation MUKMasterPlaylist

#pragma mark - Lifecycle

- (instancetype _Nullable)initWithPlaylistUrl:(NSURL* _Nullable)url
{
    if (self = [super initWithPlaylistUrl:url]) {
        self.processingMedias = [NSMutableArray array];
        self.processingStreamInfs = [NSMutableArray array];
        self.processingSessionDatas = [NSMutableArray array];
        self.isWaitingStreamUri = NO;
        self.medias = [NSArray array];
        self.streamInfs = [NSArray array];
        self.sessionDatas = [NSArray array];
        self.sessionKeys = [NSArray array];
        self.processingSessionKeys = [NSMutableArray array];
    }
    return self;
}

#pragma mark - Private Methods

#pragma mark M3U8 Tag

/**
 * 4.3.1.1 EXTM3U
 */
- (MUKTagActionResult)onExtm3u:(NSString* _Nonnull)tagValue error:(NSError* _Nullable* _Nullable)error
{
    self.hasExtm3u = YES;
    return MUKTagActionResultProcessed;
}

- (MUKTagActionResult)notFoundExtm3u:(NSError* _Nullable* _Nullable)error
{
    SET_ERROR(error, MUKErrorInvalidM3UFormat, @"EXTM3U is not on the first line");
    return MUKTagActionResultErrored;
}

/**
 * 4.3.4.1. EXT-X-MEDIA
 */
- (MUKTagActionResult)onMedia:(NSString* _Nonnull)tagValue error:(NSError* _Nullable* _Nullable)error
{
    MUKXMedia* media = [self.serializer modelOfClass:MUKXMedia.class fromString:tagValue error:error];
    if (!media) {
        return MUKTagActionResultErrored;
    }
    [self.processingMedias addObject:media];
    return MUKTagActionResultProcessed;
}

/**
 * 4.3.4.2. EXT-X-STREAM-INF
 */
- (MUKTagActionResult)onStreamInf:(NSString* _Nonnull)tagValue error:(NSError* _Nullable* _Nullable)error
{
    MUKXStreamInf* streamInf = [self.serializer modelOfClass:MUKXStreamInf.class fromString:tagValue error:error];
    if (!streamInf) {
        return MUKTagActionResultErrored;
    }
    self.isWaitingStreamUri = YES;
    [self.processingStreamInfs addObject:streamInf];
    return MUKTagActionResultProcessed;
}

- (MUKTagActionResult)onStreamInfUri:(NSString* _Nonnull)tagValue error:(NSError* _Nullable* _Nullable)error
{
    NSAssert(self.processingStreamInfs.count > 0, @"processingStreamInfs.count MUST be greater than 0");

    if (tagValue.length > 0 && ![tagValue hasPrefix:@"#"]) {
        MUKXStreamInf* streamInf = (MUKXStreamInf*)(self.processingStreamInfs.lastObject);
        streamInf.uri = [NSURL URLWithString:tagValue relativeToURL:self.playlistUrl];
        self.isWaitingStreamUri = NO;

        return MUKTagActionResultProcessed;
    }
    return MUKTagActionResultIgnored;
}

/**
 * 4.3.4.3. EXT-X-I-FRAME-STREAM-INF
 */
- (MUKTagActionResult)onIframeStreamInf:(NSString* _Nonnull)tagValue error:(NSError* _Nullable* _Nullable)error
{
    MUKXIframeStreamInf* streamInf = [self.serializer modelOfClass:MUKXIframeStreamInf.class
                                                        fromString:tagValue
                                                             error:error];
    if (!streamInf) {
        return MUKTagActionResultErrored;
    }
    [self.processingStreamInfs addObject:streamInf];
    return MUKTagActionResultProcessed;
}

/**
 * 4.3.4.4. EXT-X-SESSION-DATA
 */
- (MUKTagActionResult)onSessionData:(NSString* _Nonnull)tagValue error:(NSError* _Nullable* _Nullable)error
{
    MUKXSessionData* sessionData = [self.serializer modelOfClass:MUKXSessionData.class fromString:tagValue error:error];
    if (!sessionData) {
        return MUKTagActionResultErrored;
    }
    [self.processingSessionDatas addObject:sessionData];
    return MUKTagActionResultProcessed;
}

/**
 * 4.3.4.5. EXT-X-SESSION-KEY
 */
- (MUKTagActionResult)onSessionKey:(NSString* _Nonnull)tagValue error:(NSError* _Nullable* _Nullable)error
{
    MUKXKey* encrypt = [self.serializer modelOfClass:MUKXKey.class fromString:tagValue error:error];
    if (!encrypt) {
        return MUKTagActionResultErrored;
    }
    [self.processingSessionKeys addObject:encrypt];
    return MUKTagActionResultProcessed;
}

/**
 * 4.3.5.1. EXT-X-INDEPENDENT-SEGMENTS
 */
- (MUKTagActionResult)onIndependentSegment:(NSString* _Nonnull)tagValue error:(NSError* _Nullable* _Nullable)error
{
    if (self.isIndependentSegment) {
        SET_ERROR(error, MUKErrorDuplicateTag,
                  @"EXT-X-INDEPENDENT-SEGMENTS MUST NOT appear more than once in a playlist");
        return MUKTagActionResultErrored;
    }

    self.independentSegment = YES;
    return MUKTagActionResultProcessed;
}

/**
 * 4.3.5.2. EXT-X-START
 */
- (MUKTagActionResult)onStart:(NSString* _Nonnull)tagValue error:(NSError* _Nullable* _Nullable)error
{
    if (self.startOffset) {
        SET_ERROR(error, MUKErrorDuplicateTag,
                  @"EXT-X-START MUST NOT appear more than once in a playlist");
        return MUKTagActionResultErrored;
    }

    MUKXStart* start = [self.serializer modelOfClass:MUKXStart.class fromString:tagValue error:error];
    if (!start) {
        return MUKTagActionResultErrored;
    }

    self.startOffset = start;
    return MUKTagActionResultProcessed;
}

#pragma mark - MUKSerializing (Override)

- (NSDictionary<NSString*, MUKTagAction>* _Nonnull)tagActions
{
    if (!self.hasExtm3u) {
        return @{ MUK_EXTM3U : ACTION([self onExtm3u:tagValue error:error]),
                  @"" : ACTION([self notFoundExtm3u:error]) };
    } else if (self.isWaitingStreamUri) {
        return @{ @"" : ACTION([self onStreamInfUri:tagValue error:error]) };
    } else {
        return @{ MUK_EXT_X_MEDIA : ACTION([self onMedia:tagValue error:error]),
                  MUK_EXT_X_STREAM_INF : ACTION([self onStreamInf:tagValue error:error]),
                  MUK_EXT_X_I_FRAME_STREAM_INF : ACTION([self onIframeStreamInf:tagValue error:error]),
                  MUK_EXT_X_SESSION_DATA : ACTION([self onSessionData:tagValue error:error]),
                  MUK_EXT_X_SESSION_KEY : ACTION([self onSessionKey:tagValue error:error]),
                  MUK_EXT_X_INDEPENDENZT_SEGMENT : ACTION([self onIndependentSegment:tagValue error:error]),
                  MUK_EXT_X_START : ACTION([self onStart:tagValue error:error]) };
    }
}

#pragma mark - MUKSerializing

- (void)finalizeForToModel
{
    self.medias = self.processingMedias;
    self.streamInfs = self.processingStreamInfs;
    self.sessionDatas = self.processingSessionDatas;
    self.sessionKeys = self.processingSessionKeys;
}

- (NSDictionary<NSString*, id>* _Nonnull)renderObject
{
    return @{};
}

- (NSString* _Nonnull)renderTemplate
{
    NSString* path = [[NSBundle bundleForClass:MUKMasterPlaylist.class] pathForResource:@"master" ofType:@"mustache"];
    return [NSString stringWithContentsOfFile:path
                                     encoding:NSUTF8StringEncoding
                                        error:nil];
}

- (BOOL)validate:(NSError* _Nullable* _Nullable)error
{
    if (!self.hasExtm3u) {
        SET_ERROR(error, MUKErrorInvalidM3UFormat, @"EXTM3U is NOT found");
        return NO;
    }

    if (self.isWaitingStreamUri) {
        SET_ERROR(error, MUKErrorInvalidStreamInf, @"EXT-X-I-FRAME-STREAM-INF MUST have a url line");
        return NO;
    }
    return YES;
}

@end
