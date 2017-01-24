//
//  MUKMediaPlaylist.m
//  MpegUrlKit
//
//  Created by Hinagiku Soranoba on 2017/01/06.
//  Copyright © 2017年 Hinagiku Soranoba. All rights reserved.
//

#import "MUKMediaPlaylist.h"
#import "MUKAttributeSerializer.h"
#import "MUKConsts.h"
#import "MUKXMap+Private.h"
#import "NSError+MUKErrorDomain.h"
#import "NSString+MUKExtension.h"

@interface MUKMediaPlaylist ()
@property (nonatomic, assign) BOOL hasExtm3u;
@property (nonatomic, assign) BOOL isWaitingMediaSegmentUri;

@property (nonatomic, nonnull, strong) NSMutableArray<MUKMediaSegment*>* processingMediaSegments;
@property (nonatomic, nonnull, strong) NSMutableArray<MUKXDateRange*>* processingDateRanges;
@property (nonatomic, nullable, copy) MUKSegmentValidator segmentValidator;
@property (nonatomic, nullable, strong) MUKXKey* encrypt;
@property (nonatomic, nullable, strong) NSDate* programDate;
@end

@implementation MUKMediaPlaylist

#pragma mark - Lifecycle

- (instancetype _Nullable)initWithPlaylistUrl:(NSURL* _Nullable)url
{
    if (self = [super initWithPlaylistUrl:url]) {
        self.processingMediaSegments = [NSMutableArray array];
        self.mediaSegments = [NSArray array];
        self.processingDateRanges = [NSMutableArray array];
        self.dateRanges = [NSArray array];
    }
    return self;
}

#pragma mark - Custom Accessor

- (void)setPlaylistUrl:(NSURL* _Nullable)playlistUrl
{
    [super setPlaylistUrl:playlistUrl];
    self.serializer = [[MUKAttributeSerializer alloc] initWithVersion:(self.version ? @(self.version) : nil)
                                                              baseUri:self.playlistUrl];
}

- (void)setVersion:(NSUInteger)version
{
    _version = version;
    self.serializer = [[MUKAttributeSerializer alloc] initWithVersion:@(version) baseUri:self.playlistUrl];
}

#pragma mark - Public Methods

+ (NSString* _Nullable)playlistTypeToString:(MUKPlaylistType)type
{
    switch (type) {
        case MUKPlaylistTypeVod:
            return @"VOD";
        case MUKPlaylistTypeEvent:
            return @"EVENT";
        default:
            return nil;
    }
}

+ (MUKPlaylistType)playlistTypeFromString:(NSString* _Nonnull)string
{
    if ([string isEqualToString:@"VOD"]) {
        return MUKPlaylistTypeVod;
    } else if ([string isEqualToString:@"EVENT"]) {
        return MUKPlaylistTypeEvent;
    } else {
        return MUKPlaylistTypeUnknown;
    }
}

#pragma mark - Private Methods

/**
 * Return the currently processed media segment.
 *
 * @return When processing now, return the currently processed media segment.
 *         Otherwise, change state to processing and return newly created media segment.
 */
- (MUKMediaSegment* _Nonnull)currentMediaSegment
{
    if (!self.isWaitingMediaSegmentUri) {
        [self.processingMediaSegments addObject:[MUKMediaSegment new]];
    }

    MUKMediaSegment* mediaSegment = [self.processingMediaSegments lastObject];
    NSAssert(mediaSegment, @"isWaitingMediaSegmentUri is YES, but processingMediaSegments is empty");

    self.isWaitingMediaSegmentUri = YES;
    return mediaSegment;
}

/**
 * Find and return the previous media segment.
 *
 * @param current A current media segment.
 * @return Return nil, if it is not found. Otherwise, return a previous media segment.
 */
- (MUKMediaSegment* _Nullable)previousMediaSegment:(MUKMediaSegment* _Nonnull)current
{
    // NOTE: It assume that current always be lastObject, so Optimized by reversing order.
    for (NSUInteger i = self.processingMediaSegments.count - 1; i != NSUIntegerMax; i--) {
        if (i != 0 && self.processingMediaSegments[i] == current) {
            return self.processingMediaSegments[i - 1];
        }
    }
    return nil;
}

/**
 * Commit the processing media segment and change state to not processing.
 *
 * @param mediaSegment A processing media segment
 * @param error        If it return NO, detailed error information is saved here.
 * @return Return whether commit succeeded.
 */
- (BOOL)commitMediaSegment:(MUKMediaSegment* _Nonnull)mediaSegment
                     error:(NSError* _Nullable* _Nullable)error
{
    NSParameterAssert(mediaSegment != nil);

    NSAssert([self.processingMediaSegments lastObject] == mediaSegment,
             @"The committing mediaSegment MUST be currentMediaSegment");
    NSAssert(self.isWaitingMediaSegmentUri == YES,
             @"It MUST NOT multiple commit with same object.");

    mediaSegment.encrypt = self.encrypt;
    mediaSegment.programDate = self.programDate;
    self.programDate = nil;

    MUKSegmentValidator segmentValidator = self.segmentValidator;
    self.segmentValidator = nil;
    self.isWaitingMediaSegmentUri = NO;

    if (segmentValidator) {
        BOOL result = segmentValidator(mediaSegment, error);
        if (!result) {
            [self.processingMediaSegments removeLastObject];
        }
        return result;
    } else {
        return YES;
    }
}

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
 * 4.3.1.2 EXT-X-VERSION
 */
- (MUKTagActionResult)onVersion:(NSString* _Nonnull)tagValue error:(NSError* _Nullable* _Nullable)error
{
    if (self.version > 0) {
        SET_ERROR(error, MUKErrorInvalidVersion, @"It has multiple EXT-X-VERSION");
        return MUKTagActionResultErrored;
    }

    NSInteger version = [tagValue integerValue];
    if (version < 1) {
        SET_ERROR(error, MUKErrorInvalidVersion,
                  ([NSString stringWithFormat:@"%@ is an invalid version", tagValue]));
        return MUKTagActionResultErrored;
    }

    self.version = version;
    return MUKTagActionResultProcessed;
}

/**
 * 4.3.2.1 EXTINF
 */
- (MUKTagActionResult)onExtinf:(NSString* _Nonnull)tagValue error:(NSError* _Nullable* _Nullable)error
{
    NSArray<NSString*>* strs = [tagValue componentsSeparatedByString:@","];
    if (strs.count != 2) {
        SET_ERROR(error, MUKErrorInvalidMediaSegment,
                  @"EXTINF MUST contain a character (#EXTINF:duration,[title])");
        return MUKTagActionResultErrored;
    }

    if (self.version < 3 && [strs[0] rangeOfString:@"."].location != NSNotFound) {
        SET_ERROR(error, MUKErrorInvalidMediaSegment,
                  ([NSString stringWithFormat:@"Version %tu does NOT supoort float duration", self.version]));
        return MUKTagActionResultErrored;
    }

    MUKMediaSegment* mediaSegment = [self currentMediaSegment];

    mediaSegment.duration = [strs[0] floatValue];
    mediaSegment.title = strs[1];

    return MUKTagActionResultProcessed;
}

- (MUKTagActionResult)onMediaSegmentUrl:(NSString* _Nonnull)tagValue error:(NSError* _Nullable* _Nullable)error
{
    if (tagValue.length > 0 && ![tagValue hasPrefix:@"#"]) {
        MUKMediaSegment* mediaSegment = [self currentMediaSegment];
        mediaSegment.uri = [NSURL URLWithString:tagValue relativeToURL:self.playlistUrl];
        return [self commitMediaSegment:mediaSegment error:error] ? MUKTagActionResultProcessed : MUKTagActionResultErrored;
    }
    return MUKTagActionResultIgnored;
}

/**
 * 4.3.2.2 EXT-X-BYTERANGE
 */
- (MUKTagActionResult)onByteRange:(NSString* _Nonnull)tagValue error:(NSError* _Nullable* _Nullable)error
{
    if (self.version < 4) { // not supported.
        return MUKTagActionResultIgnored;
    }

    MUKMediaSegment* mediaSegment = [self currentMediaSegment];
    MUKMediaSegment* previousMediaSegment = [self previousMediaSegment:mediaSegment];

    // #EXT-X-BYTERANGE:<length>[@<offset>]
    NSArray<NSString*>* strs = [tagValue componentsSeparatedByString:@"@"];
    if (!(strs.count >= 1 && strs.count <= 2)) {
        SET_ERROR(error, MUKErrorInvalidByteRange,
                  ([NSString stringWithFormat:@"%@ is invalid byte range format", tagValue]));
        return MUKTagActionResultErrored;
    }

    NSInteger length = [strs[0] integerValue];
    if (length < 0) {
        SET_ERROR(error, MUKErrorInvalidByteRange,
                  ([NSString stringWithFormat:@"length MUST be positive integer, but got %@", strs[0]]));
        return MUKTagActionResultErrored;
    }

    if (strs.count == 2) {
        NSInteger offset = [strs[1] integerValue];
        if (offset < 0) {
            SET_ERROR(error, MUKErrorInvalidByteRange,
                      ([NSString stringWithFormat:@"offset MUST be positive integer, but got %@", strs[1]]));
            return MUKTagActionResultErrored;
        }
        mediaSegment.byteRange = NSMakeRange(offset, length);
    } else if (previousMediaSegment) {
        mediaSegment.byteRange = NSMakeRange(NSMaxRange(previousMediaSegment.byteRange), length);
        mediaSegment.uri = previousMediaSegment.uri;
        self.segmentValidator = [^(MUKMediaSegment* _Nonnull mediaSegment, NSError* _Nullable* _Nullable error) {
            if (![mediaSegment.uri isEqual:previousMediaSegment.uri]) {
                SET_ERROR(error, MUKErrorInvalidByteRange,
                          @"offcet is not present, but previous media segment is not same media resource");
                return NO;
            }
            return YES;
        } copy];
    } else {
        SET_ERROR(error, MUKErrorInvalidByteRange,
                  @"offcet is not found, but previous media segment also be not found");
        return MUKTagActionResultErrored;
    }

    return MUKTagActionResultProcessed;
}

/**
 * 4.3.2.3 EXT-X-DISCONTINUITY
 */
- (MUKTagActionResult)onDiscontinuity:(NSString* _Nonnull)tagValue error:(NSError* _Nullable* _Nullable)error
{
    MUKMediaSegment* mediaSegment = [self currentMediaSegment];
    mediaSegment.discontinuity = YES;
    return MUKTagActionResultProcessed;
}

/**
 * 4.3.2.4 EXT-X-KEY
 */
- (MUKTagActionResult)onKey:(NSString* _Nonnull)tagValue error:(NSError* _Nullable* _Nullable)error
{
    MUKXKey* encrypt = [self.serializer modelOfClass:MUKXKey.class fromString:tagValue error:error];
    if (!encrypt) {
        return MUKTagActionResultErrored;
    }

    self.encrypt = encrypt;
    return MUKTagActionResultProcessed;
}

/**
 * 4.3.2.5. EXT-X-MAP
 */
- (MUKTagActionResult)onMap:(NSString* _Nonnull)tagValue error:(NSError* _Nullable* _Nullable)error
{
    if (self.version < [MUKXMap minimumModelSupportedVersion]) {
        return MUKTagActionResultIgnored;
    }

    if (self.version == 5 && !self.isIframesOnly) {
        SET_ERROR(error, MUKErrorInvalidMap, @"EXT-X-MAP on version 5 only support I-frame only playlist");
        return MUKTagActionResultErrored;
    }

    MUKXMap* map = [self.serializer modelOfClass:MUKXMap.class fromString:tagValue error:error];
    if (!map) {
        return MUKTagActionResultErrored;
    }

    MUKMediaSegment* mediaSegment = [self currentMediaSegment];
    if (!map.byteRange.location) {
        MUKMediaSegment* previousSegment = [self previousMediaSegment:mediaSegment];
        if (previousSegment) {
            map.byteRange = NSMakeRange(NSMaxRange(previousSegment.byteRange), map.byteRange.length);
        }
    }
    mediaSegment.initializationMap = map;
    return MUKTagActionResultProcessed;
}

/**
 * 4.3.2.6 EXT-X-PROGRAM-DATE-TIME
 */
- (MUKTagActionResult)onProgramDateTime:(NSString* _Nonnull)tagValue error:(NSError* _Nullable* _Nullable)error
{
    NSDate* date;
    if (![tagValue muk_scanDate:&date error:error]) {
        return MUKTagActionResultErrored;
    }
    self.programDate = date;
    return MUKTagActionResultProcessed;
}

/**
 * 4.3.2.7. EXT-X-DATERANGE
 *
 * NOTE: Clients SHOULD ignore EXT-X-DATERANGE tags with illegal syntax.
 */
- (MUKTagActionResult)onDateRange:(NSString* _Nonnull)tagValue error:(NSError* _Nullable* _Nullable)error
{
    MUKXDateRange* dateRange = [self.serializer modelOfClass:MUKXDateRange.class fromString:tagValue error:nil];
    if (!dateRange) {
        return MUKTagActionResultIgnored;
    }
    [self.processingDateRanges addObject:dateRange];
    return MUKTagActionResultProcessed;
}

/**
 * 4.3.3.1. EXT-X-TARGETDURATION
 */
- (MUKTagActionResult)onTargetDuration:(NSString* _Nonnull)tagValue error:(NSError* _Nullable* _Nullable)error
{
    NSUInteger duration;
    if (![tagValue muk_scanDecimalInteger:&duration error:error]) {
        return MUKTagActionResultErrored;
    }
    if (self.targetDuration) {
        SET_ERROR(error, MUKErrorDuplicateTag, @"EXT-X-TARGETDURATION tag duplicated");
        return MUKTagActionResultErrored;
    }
    self.targetDuration = duration;
    return MUKTagActionResultProcessed;
}

/**
 * 4.3.3.2. EXT-X-MEDIA-SEQUENCE
 */
- (MUKTagActionResult)onMediaSequence:(NSString* _Nonnull)tagValue error:(NSError* _Nullable* _Nullable)error
{
    NSUInteger sequence;
    if (![tagValue muk_scanDecimalInteger:&sequence error:error]) {
        return MUKTagActionResultErrored;
    }
    if (self.firstSequenceNumber) {
        SET_ERROR(error, MUKErrorDuplicateTag, @"EXT-X-MEDIA-SEQUENCE tag duplicated");
        return MUKTagActionResultErrored;
    }
    if (self.processingMediaSegments.count) {
        SET_ERROR(error, MUKErrorLocationIncorrect, @"EXT-X-MEDIA-SEQUENCE MUST appear before first Media Segment");
        return MUKTagActionResultErrored;
    }
    self.firstSequenceNumber = sequence;
    return MUKTagActionResultProcessed;
}

/**
 * 4.3.3.3. EXT-X-DISCONTINUITY-SEQUENCE
 */
- (MUKTagActionResult)onDiscontinuitySequence:(NSString* _Nonnull)tagValue error:(NSError* _Nullable* _Nullable)error
{
    NSUInteger sequence;
    if (![tagValue muk_scanDecimalInteger:&sequence error:error]) {
        return MUKTagActionResultErrored;
    }
    if (self.firstDiscontinuitySequenceNumber) {
        SET_ERROR(error, MUKErrorDuplicateTag, @"EXT-X-DISCONTINUITY-SEQUENCE tag duplicated");
        return MUKTagActionResultErrored;
    }
    if (self.processingMediaSegments.count) {
        SET_ERROR(error, MUKErrorLocationIncorrect, @"EXT-X-DISCONTINUITY-SEQUENCE MUST appear before first Media Segment");
        return MUKTagActionResultErrored;
    }
    self.firstDiscontinuitySequenceNumber = sequence;
    return MUKTagActionResultProcessed;
}

/**
 * 4.3.3.4. EXT-X-ENDLIST
 */
- (MUKTagActionResult)onEndList:(NSString* _Nonnull)tagValue error:(NSError* _Nullable* _Nullable)error
{
    self.hasEndList = YES;
    return MUKTagActionResultProcessed;
}

/**
 * 4.3.3.5. EXT-X-PLAYLIST-TYPE
 */
- (MUKTagActionResult)onPlaylistType:(NSString* _Nonnull)tagValue error:(NSError* _Nullable* _Nullable)error
{
    MUKPlaylistType type = [self.class playlistTypeFromString:tagValue];

    if (type == MUKPlaylistTypeUnknown) {
        SET_ERROR(error, MUKErrorInvalidType, @"EXT-X-PLAYLIST-TYPE only allow EVENT or VOD");
        return MUKTagActionResultErrored;
    }
    self.playlistType = type;
    return MUKTagActionResultProcessed;
}

/**
 * 4.3.3.6. EXT-X-I-FRAMES-ONLY
 */
- (MUKTagActionResult)onIframesOnly:(NSString* _Nonnull)tagValue error:(NSError* _Nullable* _Nullable)error
{
    if (self.version < 4) {
        return MUKTagActionResultIgnored;
    }

    self.iframesOnly = YES;
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

    MUKXStart* start = [[MUKAttributeSerializer sharedSerializer] modelOfClass:MUKXStart.class
                                                                    fromString:tagValue
                                                                         error:error];
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
    } else if (self.hasEndList) {
        return @{};
    } else {
        return @{ MUK_EXT_X_VERSION : ACTION([self onVersion:tagValue error:error]),
                  MUK_EXTINF : ACTION([self onExtinf:tagValue error:error]),
                  MUK_EXT_X_BYTERANGE : ACTION([self onByteRange:tagValue error:error]),
                  MUK_EXT_X_DISCONTINUITY : ACTION([self onDiscontinuity:tagValue error:error]),
                  MUK_EXT_X_KEY : ACTION([self onKey:tagValue error:error]),
                  MUK_EXT_X_MAP : ACTION([self onMap:tagValue error:error]),
                  MUK_EXT_X_PROGRAM_DATE_TIME : ACTION([self onProgramDateTime:tagValue error:error]),
                  MUK_EXT_X_DATERANGE : ACTION([self onDateRange:tagValue error:error]),
                  MUK_EXT_X_TARGETDURATION : ACTION([self onTargetDuration:tagValue error:error]),
                  MUK_EXT_X_MEDIA_SEQUENCE : ACTION([self onMediaSequence:tagValue error:error]),
                  MUK_EXT_X_DISCONTINUITY_SEQUENCE : ACTION([self onDiscontinuitySequence:tagValue error:error]),
                  MUK_EXT_X_ENDLIST : ACTION([self onEndList:tagValue error:error]),
                  MUK_EXT_X_PLAYLIST_TYPE : ACTION([self onPlaylistType:tagValue error:error]),
                  MUK_EXT_X_I_FRAMES_ONLY : ACTION([self onIframesOnly:tagValue error:error]),
                  MUK_EXT_X_INDEPENDENT_SEGMENT : ACTION([self onIndependentSegment:tagValue error:error]),
                  MUK_EXT_X_START : ACTION([self onStart:tagValue error:error]),
                  @"" : ACTION([self onMediaSegmentUrl:tagValue error:error]) };
    }
}

#pragma mark - MUKSerializing

- (void)finalizeForToModel
{
    if (self.version == 0) {
        self.version = 1;
    }
    self.mediaSegments = self.processingMediaSegments;
    self.dateRanges = self.processingDateRanges;
}

- (NSDictionary<NSString*, id>* _Nonnull)renderObject
{
    NSString* xStart = nil;
    if (self.startOffset) {
        xStart = [self.serializer stringFromModel:self.startOffset error:nil];
        if (!xStart) {
            return nil;
        }
    }

    NSMutableArray<NSString*>* xDateRanges = [NSMutableArray array];
    for (MUKXDateRange* dateRange in self.dateRanges) {
        NSString* str = [self.serializer stringFromModel:dateRange error:nil];
        if (!str) {
            return nil;
        }
        [xDateRanges addObject:str];
    }

    NSMutableArray* xExtInfs = [NSMutableArray arrayWithCapacity:self.mediaSegments.count];
    for (MUKMediaSegment* seg in self.mediaSegments) {
        NSString* xKey = nil;
        if (seg.encrypt) {
            xKey = [self.serializer stringFromModel:seg.encrypt error:nil];
            if (!xKey) {
                return nil;
            }
        }
        NSString* xMap = nil;
        if (seg.initializationMap) {
            xMap = [self.serializer stringFromModel:seg.initializationMap error:nil];
            if (!xMap) {
                return nil;
            }
        }

        [xExtInfs addObject:[@{ MUK_EXT_X_DISCONTINUITY : @(seg.discontinuity),
                                MUK_EXT_X_BYTERANGE : (seg.byteRange.location != NSNotFound
                                                           ? [NSString stringWithFormat:@"%tu@%tu",
                                                                                        seg.byteRange.length, seg.byteRange.location]
                                                           : @NO),
                                MUK_EXT_X_KEY : xKey ?: @NO,
                                MUK_EXT_X_MAP : xMap ?: @NO,
                                MUK_EXT_X_PROGRAM_DATE_TIME : (seg.programDate ? [NSString muk_stringWithDate:seg.programDate] : @NO),
                                @"DURATION" : @(seg.duration),
                                @"TITLE" : seg.title ?: @"",
                                @"URL" : seg.uri.absoluteString } mutableCopy]];
    }

    if (xExtInfs.count > 0) {
        xExtInfs[0][MUK_EXT_X_DISCONTINUITY] = @NO;
    }

    NSUInteger index = 0;
    for (NSUInteger i = 1; i < xExtInfs.count; i++) {
        if ([xExtInfs[i][MUK_EXT_X_KEY] isEqual:xExtInfs[index][MUK_EXT_X_KEY]]) {
            xExtInfs[i][MUK_EXT_X_KEY] = @NO;
        } else {
            index = i;
        }
    }

    return @{ MUK_EXT_X_VERSION : @(self.version ?: 1),
              MUK_EXT_X_TARGETDURATION : @(self.targetDuration ?: NO),
              MUK_EXT_X_MEDIA_SEQUENCE : @(self.firstSequenceNumber ?: NO),
              MUK_EXT_X_DISCONTINUITY_SEQUENCE : @(self.firstDiscontinuitySequenceNumber ?: NO),
              MUK_EXT_X_PLAYLIST_TYPE : ([self.class playlistTypeToString:self.playlistType] ?: @NO),
              MUK_EXT_X_I_FRAMES_ONLY : @(self.isIframesOnly),
              MUK_EXT_X_INDEPENDENT_SEGMENT : @(self.isIndependentSegment),
              MUK_EXT_X_START : (xStart ?: @(NO)),
              MUK_EXT_X_DATERANGE : xDateRanges,

              MUK_EXTINF : xExtInfs,

              MUK_EXT_X_ENDLIST : @(self.hasEndList) };
}

- (NSString* _Nonnull)renderTemplate
{
    NSString* path = [[NSBundle bundleForClass:MUKMediaPlaylist.class] pathForResource:@"media" ofType:@"mustache"];
    return [NSString stringWithContentsOfFile:path
                                     encoding:NSUTF8StringEncoding
                                        error:nil];
}

- (BOOL)validate:(NSError* _Nullable* _Nullable)error
{
    if (!self.hasExtm3u) {
        SET_ERROR(error, MUKErrorInvalidM3UFormat, @"EXTM3U is NOT found");
    } else if (self.isWaitingMediaSegmentUri) {
        SET_ERROR(error, MUKErrorInvalidMediaSegment, @"A media segment has EXTINF, but it does NOT have URI");
    } else if (!self.targetDuration) {
        SET_ERROR(error, MUKErrorMissingRequiredTag, @"EXT-X-TARGETDURATION is REQUIRED");
    } else {
        return YES;
    }
    return NO;
}

@end
