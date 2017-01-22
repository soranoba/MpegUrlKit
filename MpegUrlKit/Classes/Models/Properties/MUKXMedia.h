//
//  MUKXMedia.h
//  MpegUrlKit
//
//  Created by Hinagiku Soranoba on 2017/01/14.
//  Copyright © 2017年 Hinagiku Soranoba. All rights reserved.
//

#import "MUKAttributeModel.h"
#import "MUKErrorCode.h"
#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, MUKXMediaType) {
    MUKXMediaTypeUnknown = 0,
    MUKXMediaTypeAudio = 1,
    MUKXMediaTypeVideo,
    MUKXMediaTypeSubtitles,
    MUKXMediaTypeClosedCaptions
};

/**
 * 4.3.4.1. EXT-X-MEDIA
 * It is an information of rendition.
 */
@interface MUKXMedia : MUKAttributeModel <MUKAttributeSerializing>

/// Type of the Rendition.
///
/// MUKXMediaTypeUnknown MUST NOT be specified.
@property (nonatomic, assign, readonly) MUKXMediaType mediaType;

/// the URI that specified a Media Playlist file of the Rendition.
///
/// If mediaType is MUKXMediaTypeClosedCaptions, uri MUST be nil.
@property (nonatomic, nullable, copy, readonly) NSURL* uri;

/// Specified a group of Renditions.
///
/// A Group of Renditions has the same groupId and the same mediaType.
@property (nonatomic, nonnull, copy, readonly) NSString* groupId;

/// The primary language used in the Rendition.
///
/// The format is language tag (RFC5646).
@property (nonatomic, nullable, copy, readonly) NSString* language;

/// Associated language used in the Rendition.
///
/// The format is language tag (RFC5646).
@property (nonatomic, nullable, copy, readonly) NSString* associatedLanguage;

/// A Human-readable description of the Rendition.
@property (nonatomic, nonnull, copy, readonly) NSString* name;

/// The Rendition with the value YES is selected if client is not specified by the user.
@property (nonatomic, assign, readonly, getter=isDefaultRendition) BOOL defaultRendition;

/// If the value is YES, the client may automatically select when user does not specify.
///
/// The value MUST be YES, if isDefaultRendition is YES.
@property (nonatomic, assign, readonly, getter=canAutoSelect) BOOL autoSelect;

/// If this value is YES, the Rendition contains content that is considered essential to play.
///
/// If mediaType is MUKXMediaTypeSubtitles, this value MUST be NO.
@property (nonatomic, assign, readonly) BOOL forced;

/// The value specifies a Rendition within the segments in the Media Playlist.
/// If mediaType is MUKXMediaTypeClosedCaptions, this value is REQUIRED. Otherwise, it MUST be nil.
///
/// This value only support CC1, CC2 ... CC4 and SERVICE1, SERVICE2 ... SERVICE63.
@property (nonatomic, nullable, copy, readonly) NSString* instreamId;

/// Array of Uniform Type Identifiers (UTI)
@property (nonatomic, nullable, copy, readonly) NSArray<NSString*>* characteristics;

/// Audio channels.
/// This value is array of unsigned integer.
///
/// All audio rendition SHOULD have this value.
/// If a Master Playlist contains multiple renditions with the same codec but a different number of channels, this value is REQUIRED.
@property (nonatomic, nullable, copy, readonly) NSArray<NSNumber*>* channels;

#pragma mark - Lifecycle

/**
 * Create an instance
 * Please refer to MUKXMedia property documents.
 *
 * @param mediaType          TYPE field. MUKXMediaTypeUnknown MUST NOT be specified.
 * @param uri                URI field.
 * @param groupId            GROUP-ID field.
 * @param language           LANGUAGE field.
 * @param associatedLanguage ASSOC-LANGUAGE field.
 * @param name               NAME field.
 * @param isDefaultRendition DEFAULT field.
 * @param canAutoSelect      AUTOSELECT field.
 * @param forced             FORCED field.
 * @param instreamId         INSTREAM-ID filed.
 * @param characteristics    CHARACTERISTICS filed.
 * @param channels           CHANNELS filed.
 * @return instance
 */
- (instancetype _Nullable)initWithType:(MUKXMediaType)mediaType
                                   uri:(NSString* _Nullable)uri
                               groupId:(NSString* _Nonnull)groupId
                              language:(NSString* _Nullable)language
                    associatedLanguage:(NSString* _Nullable)associatedLanguage
                                  name:(NSString* _Nonnull)name
                    isDefaultRendition:(BOOL)isDefaultRendition
                         canAutoSelect:(BOOL)canAutoSelect
                                forced:(BOOL)forced
                            instreamId:(NSString* _Nullable)instreamId
                       characteristics:(NSArray<NSString*>* _Nullable)characteristics
                              channels:(NSArray<NSNumber*>* _Nullable)channels;

#pragma mark - Public Methods

/**
 * Convert to MUKXMediaType from NSString.
 *
 * @param string An enumerated-string
 * @return Return MUKXMediaTypeUnknown, if the string is not supported string.
 *         Otherwise, return converted enumerated-value.
 */
+ (MUKXMediaType)mediaTypeFromString:(NSString* _Nonnull)string;

/**
 * Convert to NSString from MUKXMediaType.
 *
 * @param mediaType An enumerated-value
 * @return Return nil, if the method is MUKXMediaTypeUnknown (or not enumerated-value).
 *         Otherwise, return an enumerated-string.
 */
+ (NSString* _Nullable)mediaTypeToString:(MUKXMediaType)mediaType;

@end
