//
//  MUKMediaPlaylist.m
//  MpegUrlKit
//
//  Created by Hinagiku Soranoba on 2017/01/06.
//  Copyright © 2017年 Hinagiku Soranoba. All rights reserved.
//

#import "MUKMediaPlaylist.h"
#import "MUKAttributeList.h"
#import "MUKConsts.h"
#import "NSError+MUKErrorDomain.h"
#import "NSString+MUKExtension.h"

@interface MUKMediaPlaylist ()
@property (nonatomic, assign) BOOL hasExtm3u;
@property (nonatomic, assign) BOOL isWaitingMediaSegmentUri;

@property (nonatomic, nonnull, strong) NSMutableArray<MUKMediaSegment*>* processingMediaSegments;
@property (nonatomic, nonnull, strong) NSMutableArray<MUKDateRange*>* processingDateRanges;
@property (nonatomic, nullable, copy) MUKSegmentValidator segmentValidator;
@property (nonatomic, nullable, strong) MUKMediaEncrypt* encrypt;
@property (nonatomic, nullable, strong) NSDate* programDate;
@end

@implementation MUKMediaPlaylist

#pragma mark - Lifecycle

- (instancetype _Nullable)init
{
    if (self = [super init]) {
        self.processingMediaSegments = [NSMutableArray array];
        self.mediaSegments = [NSArray array];
        self.processingDateRanges = [NSMutableArray array];
        self.dateRanges = [NSArray array];
    }
    return self;
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

    MUKMediaSegment* mediaSegment = [self currentMediaSegment];

    mediaSegment.duration = [strs[0] floatValue];
    mediaSegment.title = strs[1];

    return MUKLineActionResultProcessed;
}

- (MUKLineActionResult)onMediaSegmentUrl:(NSString* _Nonnull)line error:(NSError* _Nullable* _Nullable)error
{
    if (line.length > 0 && ![line hasPrefix:@"#"]) {
        MUKMediaSegment* mediaSegment = [self currentMediaSegment];
        mediaSegment.uri = line;
        return [self commitMediaSegment:mediaSegment error:error] ? MUKLineActionResultProcessed : MUKLineActionResultErrored;
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

    MUKMediaSegment* mediaSegment = [self currentMediaSegment];
    MUKMediaSegment* previousMediaSegment = [self previousMediaSegment:mediaSegment];

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
                      ([NSString stringWithFormat:@"offset MUST be positive integer, but got %@", strs[1]]));
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
                return NO;
            }
            return YES;
        } copy];
    } else {
        SET_ERROR(error, MUKErrorInvalidByteRange,
                  @"offcet is not found, but previous media segment also be not found");
        return MUKLineActionResultErrored;
    }

    return MUKLineActionResultProcessed;
}

/**
 * 4.3.2.3 EXT-X-DISCONTINUITY
 */
- (MUKLineActionResult)onDiscontinuity:(NSString* _Nonnull)line error:(NSError* _Nullable* _Nullable)error
{
    MUKMediaSegment* mediaSegment = [self currentMediaSegment];
    mediaSegment.discontinuity = YES;
    return MUKLineActionResultProcessed;
}

/**
 * 4.3.2.4 EXT-X-KEY
 */
- (MUKLineActionResult)onKey:(NSString* _Nonnull)line error:(NSError* _Nullable* _Nullable)error
{
    NSDictionary<NSString*, MUKAttributeValue*>* attributes = [MUKAttributeList parseFromString:TAG_VALUE(MUK_EXT_X_KEY, line)
                                                                                          error:error];
    if (!attributes) {
        return MUKLineActionResultErrored;
    }

    NSMutableArray<NSNumber*>* keyFormatVersions = nil;
    if (attributes[@"KEYFORMATVERSIONS"]) {
        if (!(attributes[@"KEYFORMATVERSIONS"].isQuotedString)) {
            SET_ERROR(error, MUKErrorInvalidEncrypt, @"KEYFORMATVERSIONS MUST be quoted-string");
            return MUKLineActionResultErrored;
        }
        NSArray<NSString*>* formats = [attributes[@"KEYFORMATVERSIONS"].value componentsSeparatedByString:@"/"];
        keyFormatVersions = [NSMutableArray arrayWithCapacity:formats.count];
        NSInteger num;

        for (NSString* format in formats) {
            if ((num = [format integerValue])) {
                [keyFormatVersions addObject:[NSNumber numberWithInteger:num]];
            } else {
                SET_ERROR(error, MUKErrorInvalidEncrypt,
                          ([NSString stringWithFormat:@"KEYFORMATVERSIONS MUST be positive integers. Got %@",
                                                      attributes[@"KEYFORMATVERSIONS"]]));
                return MUKLineActionResultErrored;
            }
        }
    }

    if (attributes[@"URI"] && !(attributes[@"URI"].isQuotedString)) {
        SET_ERROR(error, MUKErrorInvalidEncrypt, @"URI MUST be quoted-string");
        return MUKLineActionResultErrored;
    }

    if (attributes[@"KEYFORMAT"] && !(attributes[@"KEYFORMAT"].isQuotedString)) {
        SET_ERROR(error, MUKErrorInvalidEncrypt, @"KEYFORMAT MUST be quoted-string");
        return MUKLineActionResultErrored;
    }

    NSData* iv = nil;
    if (attributes[@"IV"] && !([attributes[@"IV"].value muk_scanHexadecimal:&iv error:error])) {
        return MUKLineActionResultErrored;
    }

    self.encrypt = [[MUKMediaEncrypt alloc] initWithMethod:[MUKMediaEncrypt encryptMethodFromString:attributes[@"METHOD"].value]
                                                       uri:attributes[@"URI"].value
                                                        iv:(self.version >= 2 ? iv : nil)
                                                 keyFormat:(self.version >= 5 ? attributes[@"KEYFORMAT"].value : nil)
                                         keyFormatVersions:(self.version >= 5 ? keyFormatVersions : nil)];
    if ([self.encrypt validate:error]) {
        return MUKLineActionResultProcessed;
    } else {
        return MUKLineActionResultErrored;
    }
}

/**
 * 4.3.2.5. EXT-X-MAP
 */
- (MUKLineActionResult)onMap:(NSString* _Nonnull)line error:(NSError* _Nullable* _Nullable)error
{
    if (self.version < 5) {
        return MUKLineActionResultIgnored;
    }

    if (self.version == 5 && !self.isIframesOnly) {
        SET_ERROR(error, MUKErrorInvalidMap, @"EXT-X-MAP on version 5 only support I-frame only playlist");
        return MUKLineActionResultErrored;
    }

    NSDictionary<NSString*, MUKAttributeValue*>* attributes = [MUKAttributeList parseFromString:TAG_VALUE(MUK_EXT_X_MAP, line)
                                                                                          error:error];
    if (!attributes) {
        return MUKLineActionResultErrored;
    }

    if (!(attributes[@"URI"].isQuotedString)) {
        SET_ERROR(error, MUKErrorInvalidMap, @"a URI attribute is REQUIRED and MUST be quoted-string");
        return MUKLineActionResultErrored;
    }

    MUKMediaSegment* mediaSegment = [self currentMediaSegment];
    if (attributes[@"BYTERANGE"]) {
        if (!attributes[@"BYTERANGE"].isQuotedString) {
            SET_ERROR(error, MUKErrorInvalidMap, @"BYTERANGE MUST be quoted-string");
            return MUKLineActionResultErrored;
        }
        NSArray<NSString*>* strs = [attributes[@"BYTERANGE"].value componentsSeparatedByString:@"@"];
        if (!(strs.count == 1 || strs.count == 2)) {
            SET_ERROR(error, MUKErrorInvalidMap,
                      ([NSString stringWithFormat:@"%@ is invalid byte range format", attributes[@"BYTERANGE"].value]));
            return MUKLineActionResultErrored;
        }

        NSRange range = NSMakeRange((strs.count == 2 ? [strs[1] integerValue] : 0), [strs[0] integerValue]);
        mediaSegment.initializationMap = [[MUKMediaInitializationMap alloc] initWithUri:attributes[@"URI"].value
                                                                                  range:range];
    } else {
        mediaSegment.initializationMap = [[MUKMediaInitializationMap alloc] initWithUri:attributes[@"URI"].value];
    }
    return MUKLineActionResultProcessed;
}

/**
 * 4.3.2.6 EXT-X-PROGRAM-DATE-TIME
 */
- (MUKLineActionResult)onProgramDateTime:(NSString* _Nonnull)line error:(NSError* _Nullable* _Nullable)error
{
    NSDate* date;
    if (![TAG_VALUE(MUK_EXT_X_PROGRAM_DATE_TIME, line) muk_scanDate:&date error:error]) {
        return MUKLineActionResultErrored;
    }
    self.programDate = date;
    return MUKLineActionResultProcessed;
}

/**
 * 4.3.2.7. EXT-X-DATERANGE
 *
 * NOTE: Clients SHOULD ignore EXT-X-DATERANGE tags with illegal syntax.
 */
- (MUKLineActionResult)onDateRange:(NSString* _Nonnull)line error:(NSError* _Nullable* _Nullable)error
{
    NSDictionary<NSString*, MUKAttributeValue*>* attributes = [MUKAttributeList parseFromString:TAG_VALUE(MUK_EXT_X_DATERANGE, line)
                                                                                          error:nil];
    if (!attributes) {
        return MUKLineActionResultIgnored;
    }

    MUKAttributeValue* v = nil;
    NSString* identify = attributes[@"ID"].value;
    if (!attributes[@"ID"].isQuotedString) {
        return MUKLineActionResultIgnored;
    }

    NSString* class = nil;
    if ((v = attributes[@"CLASS"]) && !v.isQuotedString) {
        return MUKLineActionResultIgnored;
    }
    class = v.value;

    NSDate* startDate;
    if (![attributes[@"START-DATE"].value muk_scanDate:&startDate error:nil]) {
        return MUKLineActionResultIgnored;
    }

    NSDate* endDate = nil;
    if ((v = attributes[@"END-DATE"])) {
        if (![v.value muk_scanDate:&endDate error:nil]) {
            return MUKLineActionResultIgnored;
        }
        if ([startDate compare:endDate] == NSOrderedDescending) {
            SET_ERROR(error, MUKErrorInvalidDateRange, @"");
            return MUKLineActionResultErrored;
        }
    }

    double duration = -1;
    if ((v = attributes[@"DURATION"])) {
        if (![v.value muk_scanDouble:&duration error:nil]) {
            return MUKLineActionResultIgnored;
        }
        if (duration < 0) {
            return MUKLineActionResultIgnored;
        }
    }

    double plannedDuration = -1;
    if ((v = attributes[@"PLANNED-DURATION"])) {
        if (![v.value muk_scanDouble:&plannedDuration error:nil]) {
            return MUKLineActionResultIgnored;
        }
        if (plannedDuration < 0) {
            return MUKLineActionResultIgnored;
        }
    }

    BOOL endOnNext = NO;
    if ((v = attributes[@"END-ON-NEXT"])) {
        if (!v.isQuotedString && [v.value isEqualToString:@"YES"]) {
            endOnNext = YES;
        } else {
            return MUKLineActionResultIgnored;
        }
    }

    NSData* scte35Cmd = nil;
    if ((v = attributes[@"SCTE35-CMD"]) && ![v.value muk_scanHexadecimal:&scte35Cmd error:nil]) {
        return MUKLineActionResultIgnored;
    }

    NSData* scte35Out = nil;
    if ((v = attributes[@"SCTE35-OUT"]) && ![v.value muk_scanHexadecimal:&scte35Out error:nil]) {
        return MUKLineActionResultIgnored;
    }

    NSData* scte35In = nil;
    if ((v = attributes[@"SCTE35-IN"]) && ![v.value muk_scanHexadecimal:&scte35In error:nil]) {
        return MUKLineActionResultIgnored;
    }

    NSMutableDictionary<NSString*, MUKAttributeValue*>* clientDefineds = [NSMutableDictionary dictionary];
    for (NSString* key in attributes) {
        if ([key hasPrefix:@"X-"]) {
            clientDefineds[key] = attributes[key];
        }
    }
    MUKDateRange* dateRange = [[MUKDateRange alloc] initWithId:identify
                                                         klass:class
                                                         start:startDate
                                                           end:endDate
                                                      duration:duration
                                               plannedDuration:plannedDuration
                                                   isEndOnNext:endOnNext
                                                     scte35Cmd:scte35Cmd
                                                     scte35Out:scte35Out
                                                      scte35In:scte35In
                                         userDefinedAttributes:clientDefineds];
    if (![dateRange validate:nil]) {
        return MUKLineActionResultIgnored;
    }
    [self.processingDateRanges addObject:dateRange];
    return MUKLineActionResultProcessed;
}

/**
 * 4.3.3.1. EXT-X-TARGETDURATION
 */
- (MUKLineActionResult)onTargetDuration:(NSString* _Nonnull)line error:(NSError* _Nullable* _Nullable)error
{
    NSString* durationStr = TAG_VALUE(MUK_EXT_X_TARGETDURATION, line);
    NSUInteger duration;
    if (![durationStr muk_scanDecimalInteger:&duration error:error]) {
        return MUKLineActionResultErrored;
    }
    if (self.targetDuration) {
        SET_ERROR(error, MUKErrorDuplicateTag, @"EXT-X-TARGETDURATION tag duplicated");
        return MUKLineActionResultErrored;
    }
    self.targetDuration = duration;
    return MUKLineActionResultProcessed;
}

/**
 * 4.3.3.2. EXT-X-MEDIA-SEQUENCE
 */
- (MUKLineActionResult)onMediaSequence:(NSString* _Nonnull)line error:(NSError* _Nullable* _Nullable)error
{
    NSString* sequenceStr = TAG_VALUE(MUK_EXT_X_MEDIA_SEQUENCE, line);
    NSUInteger sequence;
    if (![sequenceStr muk_scanDecimalInteger:&sequence error:error]) {
        return MUKLineActionResultErrored;
    }
    if (self.firstSequenceNumber) {
        SET_ERROR(error, MUKErrorDuplicateTag, @"EXT-X-MEDIA-SEQUENCE tag duplicated");
        return MUKLineActionResultErrored;
    }
    if (self.processingMediaSegments.count) {
        SET_ERROR(error, MUKErrorLocationIncorrect, @"EXT-X-MEDIA-SEQUENCE MUST appear before first Media Segment");
        return MUKLineActionResultErrored;
    }
    self.firstSequenceNumber = sequence;
    return MUKLineActionResultProcessed;
}

/**
 * 4.3.3.3. EXT-X-DISCONTINUITY-SEQUENCE
 */
- (MUKLineActionResult)onDiscontinuitySequence:(NSString* _Nonnull)line error:(NSError* _Nullable* _Nullable)error
{
    NSString* sequenceStr = TAG_VALUE(MUK_EXT_X_DISCONTINUITY_SEQUENCE, line);
    NSUInteger sequence;
    if (![sequenceStr muk_scanDecimalInteger:&sequence error:error]) {
        return MUKLineActionResultErrored;
    }
    if (self.firstDiscontinuitySequenceNumber) {
        SET_ERROR(error, MUKErrorDuplicateTag, @"EXT-X-DISCONTINUITY-SEQUENCE tag duplicated");
        return MUKLineActionResultErrored;
    }
    if (self.processingMediaSegments.count) {
        SET_ERROR(error, MUKErrorLocationIncorrect, @"EXT-X-DISCONTINUITY-SEQUENCE MUST appear before first Media Segment");
        return MUKLineActionResultErrored;
    }
    self.firstDiscontinuitySequenceNumber = sequence;
    return MUKLineActionResultProcessed;
}

/**
 * 4.3.3.4. EXT-X-ENDLIST
 */
- (MUKLineActionResult)onEndList:(NSString* _Nonnull)line error:(NSError* _Nullable* _Nullable)error
{
    self.hasEndList = YES;
    return MUKLineActionResultProcessed;
}

/**
 * 4.3.3.5. EXT-X-PLAYLIST-TYPE
 */
- (MUKLineActionResult)onPlaylistType:(NSString* _Nonnull)line error:(NSError* _Nullable* _Nullable)error
{
    NSString* typeStr = TAG_VALUE(MUK_EXT_X_PLAYLIST_TYPE, line);
    MUKPlaylistType type = [self.class playlistTypeFromString:typeStr];

    if (type == MUKPlaylistTypeUnknown) {
        SET_ERROR(error, MUKErrorInvalidType, @"EXT-X-PLAYLIST-TYPE only allow EVENT or VOD");
        return MUKLineActionResultErrored;
    }
    self.playlistType = type;
    return MUKLineActionResultProcessed;
}

/**
 * 4.3.3.6. EXT-X-I-FRAMES-ONLY
 */
- (MUKLineActionResult)onIframesOnly:(NSString* _Nonnull)line error:(NSError* _Nullable* _Nullable)error
{
    if (self.version < 4) {
        return MUKLineActionResultIgnored;
    }

    self.isIframesOnly = YES;
    return MUKLineActionResultProcessed;
}

#pragma mark - MUKSerializing (Override)

- (NSDictionary<NSString*, MUKLineAction>* _Nonnull)lineActions
{
    __weak typeof(self) weakSelf = self;

    if (!self.hasExtm3u) {
        return @{ MUK_EXTM3U : ACTION([weakSelf onExtm3u:line error:error]),
                  @"" : ACTION([weakSelf notFoundExtm3u:error]) };
    } else if (self.hasEndList) {
        return @{};
    } else {
        return @{ MUK_EXT_X_VERSION : ACTION([weakSelf onVersion:line error:error]),
                  MUK_EXTINF : ACTION([weakSelf onExtinf:line error:error]),
                  MUK_EXT_X_BYTERANGE : ACTION([weakSelf onByteRange:line error:error]),
                  MUK_EXT_X_DISCONTINUITY : ACTION([weakSelf onDiscontinuity:line error:error]),
                  MUK_EXT_X_KEY : ACTION([weakSelf onKey:line error:error]),
                  MUK_EXT_X_MAP : ACTION([weakSelf onMap:line error:error]),
                  MUK_EXT_X_PROGRAM_DATE_TIME : ACTION([weakSelf onProgramDateTime:line error:error]),
                  MUK_EXT_X_DATERANGE : ACTION([weakSelf onDateRange:line error:error]),
                  MUK_EXT_X_TARGETDURATION : ACTION([weakSelf onTargetDuration:line error:error]),
                  MUK_EXT_X_MEDIA_SEQUENCE : ACTION([weakSelf onMediaSequence:line error:error]),
                  MUK_EXT_X_DISCONTINUITY_SEQUENCE : ACTION([weakSelf onDiscontinuitySequence:line error:error]),
                  MUK_EXT_X_ENDLIST : ACTION([weakSelf onEndList:line error:error]),
                  MUK_EXT_X_PLAYLIST_TYPE : ACTION([weakSelf onPlaylistType:line error:error]),
                  MUK_EXT_X_I_FRAMES_ONLY : ACTION([weakSelf onIframesOnly:line error:error]),
                  @"" : ACTION([weakSelf onMediaSegmentUrl:line error:error]) };
    }
}

#pragma mark - MUKSerializing

- (void)beginSerialization
{
    // NOP
}

- (void)endSerialization
{
    if (self.version == 0) {
        self.version = 1;
    }
    self.mediaSegments = self.processingMediaSegments;
    self.dateRanges = self.processingDateRanges;
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
