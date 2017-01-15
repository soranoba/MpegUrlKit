//
//  MUKXIframeStreamInf.m
//  MpegUrlKit
//
//  Created by Hinagiku Soranoba on 2017/01/15.
//  Copyright © 2017年 Hinagiku Soranoba. All rights reserved.
//

#import "MUKXIframeStreamInf.h"

@implementation MUKXIframeStreamInf

- (instancetype _Nonnull)initWithMaxBitrate:(NSUInteger)maxBitrate
                             averageBitrate:(NSUInteger)averageBitrate
                                     codecs:(NSArray<NSString*>* _Nullable)codecs
                                 resolution:(CGSize)resolution
                                  hdcpLevel:(MUKXStreamInfHdcpLevel)hdcpLevel
                               videoGroupId:(NSString* _Nullable)videoGroupId
                                        uri:(NSString* _Nonnull)uri
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

@end
