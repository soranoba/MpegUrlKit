//
//  MUKXMedia.m
//  MpegUrlKit
//
//  Created by Hinagiku Soranoba on 2017/01/14.
//  Copyright © 2017年 Hinagiku Soranoba. All rights reserved.
//

#import "MUKXMedia.h"
#import "NSError+MUKErrorDomain.h"
#import "NSString+MUKExtension.h"

static NSString* const MUK_EXT_X_MEDIA_TYPE_AUDIO = @"AUDIO";
static NSString* const MUK_EXT_X_MEDIA_TYPE_VIDEO = @"VIDEO";
static NSString* const MUK_EXT_X_MEDIA_TYPE_SUBTITLES = @"SUBTITLES";
static NSString* const MUK_EXT_X_MEDIA_TYPE_CLOSED_CAPTIONS = @"CLOSED-CAPTIONS";

@interface MUKXMedia ()
@property (nonatomic, assign, readwrite) MUKXMediaType mediaType;
@property (nonatomic, nullable, copy, readwrite) NSString* uri;
@property (nonatomic, nonnull, copy, readwrite) NSString* groupId;
@property (nonatomic, nullable, copy, readwrite) NSString* language;
@property (nonatomic, nullable, copy, readwrite) NSString* associatedLanguage;
@property (nonatomic, nonnull, copy, readwrite) NSString* name;
@property (nonatomic, assign, readwrite) BOOL isDefaultRendition;
@property (nonatomic, assign, readwrite) BOOL canAutoSelect;
@property (nonatomic, assign, readwrite) BOOL forced;
@property (nonatomic, nullable, copy, readwrite) NSString* instreamId;
@property (nonatomic, nullable, copy, readwrite) NSArray<NSString*>* characteristics;
@property (nonatomic, nullable, copy, readwrite) NSArray<NSNumber*>* channels;
@end

@implementation MUKXMedia

#pragma mark - Lifecycle

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
                              channels:(NSArray<NSNumber*>* _Nullable)channels
{
    NSParameterAssert(mediaType != MUKXMediaTypeUnknown && groupId != nil && name != nil);

    if (self = [super init]) {
        self.mediaType = mediaType;
        self.uri = uri;
        self.groupId = groupId;
        self.language = language;
        self.associatedLanguage = associatedLanguage;
        self.name = name;
        self.isDefaultRendition = isDefaultRendition;
        self.canAutoSelect = canAutoSelect;
        self.forced = forced;
        self.instreamId = instreamId;
        self.characteristics = characteristics;
        self.channels = channels;
    }
    return self;
}

#pragma mark - Public Methods

- (BOOL)validate:(NSError* _Nullable* _Nullable)error
{
    if (self.mediaType == MUKXMediaTypeClosedCaptions && self.uri != nil) {
        SET_ERROR(error, MUKErrorInvalidMedia,
                  ([NSString stringWithFormat:@"if the TYPE is %@, URI MUST NOT be present", MUK_EXT_X_MEDIA_TYPE_CLOSED_CAPTIONS]));
        return NO;
    }

    if (self.canAutoSelect && !self.isDefaultRendition) {
        SET_ERROR(error, MUKErrorInvalidMedia, @"if the AUTOSELECT is YES, the DEFAULT MUST be YES");
        return NO;
    }

    if (self.mediaType == MUKXMediaTypeSubtitles && self.forced) {
        SET_ERROR(error, MUKErrorInvalidMedia,
                  ([NSString stringWithFormat:@"if the TYPE is %@, FORCED MUST NOT be present", MUK_EXT_X_MEDIA_TYPE_SUBTITLES]));
        return NO;
    }

    if (![self validateInStreamId:error]) {
        return NO;
    }

    for (NSString* uti in self.characteristics) {
        if ([uti rangeOfString:@","].location != NSNotFound) {
            SET_ERROR(error, MUKErrorInvalidMedia, @"Each element of CHARACTERISTICS MUST NOT contain a comma");
            return NO;
        }
    }

    return YES;
}

+ (MUKXMediaType)mediaTypeFromString:(NSString* _Nonnull)string
{
    NSParameterAssert(string != nil);

    if ([string isEqualToString:MUK_EXT_X_MEDIA_TYPE_AUDIO]) {
        return MUKXMediaTypeAudio;
    } else if ([string isEqualToString:MUK_EXT_X_MEDIA_TYPE_VIDEO]) {
        return MUKXMediaTypeVideo;
    } else if ([string isEqualToString:MUK_EXT_X_MEDIA_TYPE_SUBTITLES]) {
        return MUKXMediaTypeSubtitles;
    } else if ([string isEqualToString:MUK_EXT_X_MEDIA_TYPE_CLOSED_CAPTIONS]) {
        return MUKXMediaTypeClosedCaptions;
    } else {
        return MUKXMediaTypeUnknown;
    }
}

+ (NSString* _Nullable)mediaTypeToString:(MUKXMediaType)mediaType
{
    switch (mediaType) {
        case MUKXMediaTypeAudio:
            return MUK_EXT_X_MEDIA_TYPE_AUDIO;
        case MUKXMediaTypeVideo:
            return MUK_EXT_X_MEDIA_TYPE_VIDEO;
        case MUKXMediaTypeSubtitles:
            return MUK_EXT_X_MEDIA_TYPE_SUBTITLES;
        case MUKXMediaTypeClosedCaptions:
            return MUK_EXT_X_MEDIA_TYPE_CLOSED_CAPTIONS;
        default:
            return nil;
    }
}

#pragma mark - Private Methods

/**
 * Validate instreamId and return YES if it is correct.
 *
 * @param error  If it return NO, detailed error information is saved here.
 * @return If it is correct, it return YES. Otherwise, return NO.
 */
- (BOOL)validateInStreamId:(NSError* _Nullable* _Nullable)error
{
    if (self.mediaType == MUKXMediaTypeClosedCaptions) {
        if (!self.instreamId) {
            SET_ERROR(error, MUKErrorInvalidMedia,
                      ([NSString stringWithFormat:@"if the TYPE is %@, INSTREAM-ID is REQUIRED", MUK_EXT_X_MEDIA_TYPE_CLOSED_CAPTIONS]));
            return NO;
        }
    } else {
        if (self.instreamId) {
            SET_ERROR(error, MUKErrorInvalidMedia,
                      ([NSString stringWithFormat:@"if the TYPE is %@, INSTREAM-ID MUST NOT be present", MUK_EXT_X_MEDIA_TYPE_CLOSED_CAPTIONS]));
            return NO;
        }
        return YES;
    }

    NSUInteger suffixNum;
    NSDictionary<NSString*, NSNumber*>* supportMaxNums = @{ @"CC" : @(4),
                                                            @"SERVICE" : @(63) };
    for (NSString* prefix in supportMaxNums) {
        if ([self.instreamId hasPrefix:prefix]) {
            NSString* suffix = [self.instreamId substringWithRange:NSMakeRange(prefix.length, self.instreamId.length - prefix.length)];
            if ([suffix muk_scanDecimalInteger:&suffixNum error:nil]
                && suffixNum >= 1 && suffixNum <= supportMaxNums[prefix].unsignedIntegerValue) {
                return YES;
            }
        }
    }

    SET_ERROR(error, MUKErrorInvalidMedia, @"INSTREAM-ID is only support CC1 ~ CC4 and SERVICE1 ~ SERVICE63");
    return NO;
}

@end
