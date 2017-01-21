//
//  MUKXStreamInf.h
//  MpegUrlKit
//
//  Created by Hinagiku Soranoba on 2017/01/15.
//  Copyright © 2017年 Hinagiku Soranoba. All rights reserved.
//

#import "MUKAttributeModel.h"
#import "MUKErrorCode.h"
#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, MUKXStreamInfHdcpLevel) {
    MUKXStreamInfHdcpLevelUnknown = 0,
    MUKXStreamInfHdcpLevelNone = 1,
    MUKXStreamInfHdcpLevelType0,
};

/**
 * 4.3.4.2. EXT-X-STREAM-INF
 * It specifies a Variant Stream, which have multiple Renditions that can be combined to play.
 */
@interface MUKXStreamInf : MUKAttributeModel <MUKAttributeSerializing>

/// It represents the peak segment bitrate of the Variant Stream.
/// It MUST be greater than 0.
@property (nonatomic, assign, readonly) NSUInteger maxBitrate;

/// If it is 0, it means no designation.
/// Otherwise, it represents the average segment bitrate of the Variant Stream.
@property (nonatomic, assign, readonly) NSUInteger averageBitrate;

/// An array of codec.
/// Please refert to RFC6381.
@property (nonatomic, nullable, copy, readonly) NSArray<NSString*>* codecs;

/// If it is CGSizeZero, it means no designation.
/// Otherwise, it represents the optimal pixel resolution at which to display all the video in the Variant Stream.
/// Width and height MUST be specified as integers.
@property (nonatomic, assign, readonly) CGSize resolution;

/// If it is 0, it means no designation. Otherwise, it represents the max frame rate for all the video in the Variant Stream.
@property (nonatomic, assign, readonly) double maxFrameRate;

/// High-bandwidth Digital Content Protection system (HDCP)
/// It puts a reference value as to whether it is protected by HDCP.
///
/// If it is MUKXStreamInfHdcpLevelUnknwon, it means no designation.
@property (nonatomic, assign, readonly) MUKXStreamInfHdcpLevel hdcpLevel;

/// Please refer to MUKXMedia class.
/// It value MUST match a MUKXMedia object that have mediaType is MUKXMediaTypeAudio and groupId is the value.
@property (nonatomic, nullable, copy, readonly) NSString* audioGroupId;

/// Please refer to MUKXMedia class.
/// It value MUST match a MUKXMedia object that have mediaType is MUKXMediaTypeVideo and groupId is the value.
@property (nonatomic, nullable, copy, readonly) NSString* videoGroupId;

/// Please refer to MUKXMedia class.
/// It value MUST match a MUKXMedia object that have mediaType is MUKXMediaTypeSubtitles and groupId is the value.
@property (nonatomic, nullable, copy, readonly) NSString* subtitlesGroupId;

/// Please refer to MUKXMedia class.
/// It value MUST match a MUKXMedia object that have mediaType is MUKXMediaTypeClosedCaptions and groupId is the value.
@property (nonatomic, nullable, copy, readonly) NSString* closedCaptionsGroupId;

/// It specifies a Media Playlist that carries a Rendition of the Variant Stream.
@property (nonatomic, nonnull, copy, readonly) NSURL* uri;

#pragma mark - Lifecycle

/**
 * Create an instance.
 * Please refer to MUKXStreamInf property documents.
 *
 * @param maxBitrate             BITRATE field.
 * @param averageBitrate         AVERAGE-BANDWIDTH field.
 * @param codecs                 CODECS field.
 * @param resolution             RESOLUTION field.
 * @param maxFrameRate           FRAME-RATE field.
 * @param hdcpLevel              HDCP-LEVEL field.
 * @param audioGroupId           AUDIO field.
 * @param videoGroupId           VIDEO field.
 * @param subtitlesGroupId       SUBTITLES field.
 * @param closedCaptionsGroupId  CLOSED-CAPTIONS field.
 * @param uri                    URI line.
 * @return instance
 */
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
                                        uri:(NSURL* _Nonnull)uri;

#pragma mark - Public Methods

/**
 * Convert to MUKXStreamInfHdcpLevel from NSString.
 *
 * @param string An enumerated-string
 * @return Return MUKXStreamInfoHdcpLevelUnknown, if the string is not supported string.
 *         Otherwise, return converted enumerated-value.
 */
+ (MUKXStreamInfHdcpLevel)hdcpLevelFromString:(NSString* _Nonnull)string;

/**
 * Convert to NSString from MUKXStreamInfHdcpLevel.
 *
 * @param hdcpLevel An enumerated-value
 * @return Return nil, if the method is MUKXStreamInfoHdcpLevelUnknown (or not enumerated-value).
 *         Otherwise, return an enumerated-string.
 */
+ (NSString* _Nullable)hdcpLevelToString:(MUKXStreamInfHdcpLevel)hdcpLevel;

@end
