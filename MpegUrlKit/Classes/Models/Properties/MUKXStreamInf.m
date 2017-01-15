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
static NSString* const MUK_X_STREAM_INF_HDCP_TYPE0 = @"TYPE0";

@interface MUKXStreamInf ()
@property (nonatomic, assign, readwrite) NSUInteger maxBitrate;
@property (nonatomic, assign, readwrite) NSUInteger averageBitrate;
@property(nonatomic, nullable, copy, readwrite) NSArray<NSString*>* codecs;
@property(nonatomic, assign, readwrite) CGSize resolution;
@property(nonatomic, assign, readwrite) double maxFrameRate;
@property(nonatomic, assign, readwrite) MUKXStreamInfHdcpLevel hdcpLevel;
@property(nonatomic, nullable, copy, readwrite) NSString* audioGroupId;
@property(nonatomic, nullable, copy, readwrite) NSString* videoGroupId;
@property(nonatomic, nullable, copy, readwrite) NSString* subtitlesGroupId;
@property(nonatomic, nullable, copy, readwrite) NSString* closedCaptionsGroupId;
@property(nonatomic, nonnull, copy, readwrite) NSString* uri;
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
        self.maxBitrate = maxFrameRate;
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

- (BOOL)validate:(NSError* _Nullable * _Nullable)error
{
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

@end
