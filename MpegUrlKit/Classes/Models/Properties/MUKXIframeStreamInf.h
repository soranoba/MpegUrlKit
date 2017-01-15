//
//  MUKXIframeStreamInf.h
//  MpegUrlKit
//
//  Created by Hinagiku Soranoba on 2017/01/15.
//  Copyright © 2017年 Hinagiku Soranoba. All rights reserved.
//

#import "MUKXStreamInf.h"

/**
 * 4.3.4.3. EXT-X-I-FRAME-STREAM-INF
 * It specifies stands alone a Variant Stream containing I-frames.
 */
@interface MUKXIframeStreamInf : MUKXStreamInf

#pragma mark - Lifecycle

/**
 * Create an instance.
 * Please refer to MUKXStreamInf's designated initializer.
 */
- (instancetype _Nonnull)initWithMaxBitrate:(NSUInteger)maxBitrate
                             averageBitrate:(NSUInteger)averageBitrate
                                     codecs:(NSArray<NSString*>* _Nullable)codecs
                                 resolution:(CGSize)resolution
                                  hdcpLevel:(MUKXStreamInfHdcpLevel)hdcpLevel
                               videoGroupId:(NSString* _Nullable)videoGroupId
                                        uri:(NSString* _Nonnull)uri;
@end
