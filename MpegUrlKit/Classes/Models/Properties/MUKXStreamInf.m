//
//  MUKXStreamInf.m
//  MpegUrlKit
//
//  Created by Hinagiku Soranoba on 2017/01/15.
//  Copyright © 2017年 Hinagiku Soranoba. All rights reserved.
//

#import "MUKXStreamInf.h"
#import "NSError+MUKErrorDomain.h"

static NSString* const MUK_X_STREAM_INF_HDCP_NONE = @"NONE";
static NSString* const MUK_X_STREAM_INF_HDCP_TYPE0 = @"TYPE-0";

@interface MUKXStreamInf ()
@property (nonatomic, assign, readwrite) NSUInteger maxBitrate;
@property (nonatomic, assign, readwrite) NSUInteger averageBitrate;
@property (nonatomic, nullable, copy, readwrite) NSArray<NSString*>* codecs;
@property (nonatomic, assign, readwrite) CGSize resolution;
@property (nonatomic, assign, readwrite) double maxFrameRate;
@property (nonatomic, assign, readwrite) MUKXStreamInfHdcpLevel hdcpLevel;
@property (nonatomic, nullable, copy, readwrite) NSString* audioGroupId;
@property (nonatomic, nullable, copy, readwrite) NSString* videoGroupId;
@property (nonatomic, nullable, copy, readwrite) NSString* subtitlesGroupId;
@property (nonatomic, nullable, copy, readwrite) NSString* closedCaptionsGroupId;
@property (nonatomic, nonnull, copy, readwrite) NSString* uri;
@end

@implementation MUKXStreamInf

#pragma mark - Lifecycle

- (instancetype _Nonnull)initWithMaxBitrate:(NSUInteger)maxBitrate
                             averageBitrate:(NSUInteger)averageBitrate
                                     codecs:(NSArray<NSString*>* _Nullable)codecs
                                 resolution:(CGSize)resolution
                               maxFrameRate:(double)maxFrameRate
                                  hdcpLevel:(MUKXStreamInfHdcpLevel)hdcpLevel
                               audioGroupId:(NSString* _Nullable)audioGroupId
                               videoGroupId:(NSString* _Nullable)videoGroupId
                           subtitlesGroupId:(NSString* _Nullable)subtitlesGroupId
                      closedCaptionsGroupId:(NSString* _Nullable)closedCaptionsGroupId
                                        uri:(NSString* _Nonnull)uri
{
    NSParameterAssert(maxBitrate > 0 && uri != nil);

    if (self = [super init]) {
        self.maxBitrate = maxBitrate;
        self.averageBitrate = averageBitrate;
        self.codecs = codecs;
        self.resolution = resolution;
        self.maxFrameRate = maxFrameRate;
        self.hdcpLevel = hdcpLevel;
        self.audioGroupId = audioGroupId;
        self.videoGroupId = videoGroupId;
        self.subtitlesGroupId = subtitlesGroupId;
        self.closedCaptionsGroupId = closedCaptionsGroupId;
        self.uri = uri;
    }
    return self;
}

#pragma mark - Public Methods

+ (MUKXStreamInfHdcpLevel)hdcpLevelFromString:(NSString* _Nonnull)string
{
    NSParameterAssert(string != nil);

    if ([string isEqualToString:MUK_X_STREAM_INF_HDCP_NONE]) {
        return MUKXStreamInfHdcpLevelNone;
    } else if ([string isEqualToString:MUK_X_STREAM_INF_HDCP_TYPE0]) {
        return MUKXStreamInfHdcpLevelType0;
    } else {
        return MUKXStreamInfHdcpLevelUnknown;
    }
}

+ (NSString* _Nullable)hdcpLevelToString:(MUKXStreamInfHdcpLevel)hdcpLevel
{
    switch (hdcpLevel) {
        case MUKXStreamInfHdcpLevelNone:
            return MUK_X_STREAM_INF_HDCP_NONE;
        case MUKXStreamInfHdcpLevelType0:
            return MUK_X_STREAM_INF_HDCP_TYPE0;
        default:
            return nil;
    }
}

#pragma mark - MUKAttributeSerializing

+ (NSDictionary<NSString*, NSString*>* _Nonnull)keyByPropertyKey
{
    return @{ @"BANDWIDTH" : @"maxBitrate",
              @"AVERAGE-BANDWIDTH" : @"averageBitrate",
              @"CODECS" : @"codecs",
              @"RESOLUTION" : @"resolution",
              @"FRAME-RATE" : @"maxFrameRate",
              @"HDCP-LEVEL" : @"hdcpLevel",
              @"AUDIO" : @"audioGroupId",
              @"VIDEO" : @"videoGroupId",
              @"SUBTITLES" : @"subtitlesGroupId",
              @"CLOSED-CAPTIONS" : @"closedCaptionsGroupId" };
}

+ (NSArray<NSString*>* _Nonnull)attributeOrder
{
    return @[ @"BANDWIDTH", @"AVERAGE-BANDWIDTH", @"CODECS", @"RESOLUTION", @"FRAME-RATE", @"HDCP-LEVEL",
              @"AUDIO", @"VIDEO", @"SUBTITLES", @"CLOSED-CAPTIONS" ];
}

- (NSString* _Nullable)finalizeOfToString:(NSString* _Nonnull)attributeString
                                    error:(NSError* _Nullable* _Nullable)error
{
    return [NSString stringWithFormat:@"%@\n%@", attributeString, self.uri];
}

+ (MUKTransformer* _Nonnull)codecsTransformer
{
    return [MUKTransformer transformerWithBlock:^id _Nullable(MUKAttributeValue* _Nonnull value) {
        if (value.isQuotedString) {
            return [value.value componentsSeparatedByString:@","];
        } else {
            return nil;
        }
    }
        reverseBlock:^MUKAttributeValue* _Nullable(id _Nonnull value) {
            NSParameterAssert([value isKindOfClass:NSArray.class]);
            return [[MUKAttributeValue alloc] initWithValue:[value componentsJoinedByString:@","] isQuotedString:YES];
        }];
}

+ (MUKTransformer* _Nonnull)hdcpLevelTransformer
{
    return [MUKTransformer transformerWithBlock:^id _Nullable(MUKAttributeValue* _Nonnull value) {
        if (value.isQuotedString) {
            return nil;
        } else {
            MUKXStreamInfHdcpLevel level = [self.class hdcpLevelFromString:value.value];
            if (level == MUKXStreamInfHdcpLevelUnknown) {
                return nil;
            } else {
                return @(level);
            }
        }
    }
        reverseBlock:^MUKAttributeValue* _Nullable(id _Nonnull value) {
            NSString* str = [self.class hdcpLevelToString:(MUKXStreamInfHdcpLevel)[value unsignedIntegerValue]];
            if (str) {
                return [[MUKAttributeValue alloc] initWithValue:str isQuotedString:NO];
            } else {
                return nil;
            }
        }];
}

+ (MUKTransformer* _Nonnull)closedCaptionGroupIdTransformer
{
    return [MUKTransformer transformerWithBlock:^id _Nullable(MUKAttributeValue* _Nonnull value) {
        if (value.isQuotedString) {
            return value.value;
        } else {
            if ([value.value isEqualToString:@"NONE"]) {
                return [NSNull new];
            } else {
                return nil;
            }
        }
    }];
}

#pragma mark - MUKAttributeModel (Override)

- (BOOL)validate:(NSError* _Nullable* _Nullable)error
{
    if (self.maxBitrate == 0) {
        SET_ERROR(error, MUKErrorInvalidStreamInf, @"BITRATE is REQUIRED");
        return NO;
    }

    if (self.maxBitrate < self.averageBitrate) {
        SET_ERROR(error, MUKErrorInvalidStreamInf, @"AVERAGE-BIRATE MUST be less than or equal to BITRATE");
        return NO;
    }

    for (NSString* codec in self.codecs) {
        if ([codec rangeOfString:@","].location != NSNotFound) {
            SET_ERROR(error, MUKErrorInvalidMedia, @"Each element of CODECS MUST NOT contain a comma");
            return NO;
        }
    }
    return YES;
}

@end
