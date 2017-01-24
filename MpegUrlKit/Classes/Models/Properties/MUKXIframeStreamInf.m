//
//  MUKXIframeStreamInf.m
//  MpegUrlKit
//
//  Created by Hinagiku Soranoba on 2017/01/15.
//  Copyright © 2017年 Hinagiku Soranoba. All rights reserved.
//

#import "MUKXIframeStreamInf.h"
#import "NSError+MUKErrorDomain.h"

@implementation MUKXIframeStreamInf

#pragma mark - Lifecycle

- (instancetype _Nonnull)initWithMaxBitrate:(NSUInteger)maxBitrate
                             averageBitrate:(NSUInteger)averageBitrate
                                     codecs:(NSArray<NSString*>* _Nullable)codecs
                                 resolution:(CGSize)resolution
                                  hdcpLevel:(MUKXStreamInfHdcpLevel)hdcpLevel
                               videoGroupId:(NSString* _Nullable)videoGroupId
                                        uri:(NSURL* _Nonnull)uri
{
    return [super initWithMaxBitrate:maxBitrate
                      averageBitrate:averageBitrate
                              codecs:codecs
                          resolution:resolution
                        maxFrameRate:0
                           hdcpLevel:hdcpLevel
                        audioGroupId:nil
                        videoGroupId:videoGroupId
                    subtitlesGroupId:nil
               closedCaptionsGroupId:nil
                                 uri:uri];
}

#pragma mark - MUKXStreamInf (Override)

+ (NSDictionary<NSString*, NSString*>* _Nonnull)propertyByAttributeKey
{
    NSMutableDictionary<NSString*, NSString*>* dict = [[super propertyByAttributeKey] mutableCopy];
    [dict addEntriesFromDictionary:@{ @"URI" : @"uri" }];
    [dict removeObjectsForKeys:@[ @"FRAME-RATE", @"AUDIO", @"SUBTITLES", @"CLOSED-CAPTIONS" ]];
    return dict;
}

+ (NSArray<NSString*>* _Nonnull)attributeOrder
{
    NSMutableArray<NSString*>* arr = [[super attributeOrder] mutableCopy];
    [arr removeObjectsInArray:@[ @"FRAME-RATE", @"AUDIO", @"SUBTITLES", @"CLOSED-CAPTIONS" ]];
    [arr addObject:@"URI"];
    return arr;
}

- (NSString* _Nullable)finalizeOfToString:(NSString* _Nonnull)attributeString
                                    error:(NSError* _Nullable* _Nullable)error
{
    return attributeString;
}

- (BOOL)validate:(NSError* _Nullable* _Nullable)error
{
    if (![super validate:error]) {
        return NO;
    }

    if (!self.uri) {
        SET_ERROR(error, MUKErrorInvalidStreamInf, @"URI is REQUIRED");
        return NO;
    }
    return YES;
}

@end
