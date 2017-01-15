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
@property (nonatomic, nonnull, strong) NSMutableArray<MUKXMedia*>* processingMedias;
@property (nonatomic, assign) BOOL isWaitingStreamUri;
@property (nonatomic, nonnull, strong) NSMutableArray<MUKXStreamInf*>* processingStreamInfs;
@property (nonatomic, nonnull, strong) NSMutableArray<MUKXSessionData*>* processingSessionData;
@end

@implementation MUKMasterPlaylist

#pragma mark - Lifecycle

- (instancetype _Nullable)init
{
    if (self = [super init]) {
        self.processingMedias = [NSMutableArray array];
        self.processingStreamInfs = [NSMutableArray array];
        self.processingSessionData = [NSMutableArray array];
        self.isWaitingStreamUri = NO;
    }
    return self;
}

#pragma mark - Private Methods

#pragma mark M3U8 Tag

/**
 * 4.3.4.1. EXT-X-MEDIA
 */
- (MUKTagActionResult)onMedia:(NSString* _Nonnull)tagValue error:(NSError* _Nullable* _Nullable)error
{
    MUKXMedia* media = [[MUKAttributeSerializer sharedSerializer] modelOfClass:MUKXMedia.class
                                                                    fromString:tagValue
                                                                         error:error];
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
    MUKXStreamInf* streamInf = [[MUKAttributeSerializer sharedSerializer] modelOfClass:MUKXStreamInf.class
                                                                            fromString:tagValue
                                                                                 error:error];
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
        streamInf.uri = tagValue;
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
    MUKXIframeStreamInf* streamInf = [[MUKAttributeSerializer sharedSerializer] modelOfClass:MUKXIframeStreamInf.class
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
    MUKXSessionData* sessionData = [[MUKAttributeSerializer sharedSerializer] modelOfClass:MUKXSessionData.class
                                                                                fromString:tagValue
                                                                                     error:error];
    if (!sessionData) {
        return MUKTagActionResultErrored;
    }
    [self.processingSessionData addObject:sessionData];
    return MUKTagActionResultProcessed;
}

#pragma mark - MUKSerializing (Override)

- (NSDictionary<NSString*, MUKTagAction>* _Nonnull)tagActions
{
    if (self.isWaitingStreamUri) {
        return @{ @"" : ACTION([self onStreamInfUri:tagValue error:error]) };
    } else {
        return @{ MUK_EXT_X_MEDIA : ACTION([self onMedia:tagValue error:error]),
                  MUK_EXT_X_STREAM_INF : ACTION([self onStreamInf:tagValue error:error]),
                  MUK_EXT_X_I_FRAME_STREAM_INF : ACTION([self onIframeStreamInf:tagValue error:error]),
                  MUK_EXT_X_SESSION_DATA : ACTION([self onSessionData:tagValue error:error]) };
    }
}

@end
