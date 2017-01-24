//
//  MUKXStreamInf.h
//  MpegUrlKit
//
//  Created by Hinagiku Soranoba on 2017/01/21.
//  Copyright © 2017年 Hinagiku Soranoba. All rights reserved.
//

#import "MUKAttributeModel.h"
#import "MUKErrorCode.h"
#import <Foundation/Foundation.h>

/**
 * 4.3.5.2. EXT-X-START
 *
 * A class that indicates a preferred point at which to start playing a Playlist.
 */
@interface MUKXStart : MUKAttributeModel <MUKAttributeSerializing>

/// If the value is positive, it means a time offset from the beginning of the Playlist.
/// If the value is negative, it means a time offset from the ending of the last Media Segment in the Playlist.
@property (nonatomic, assign, readonly) double timeOffset;

/// If the value is YES, it means client SHOULD start playback at the Media Segment containing the timeOffset.
/// Otherwise, client SHOULD attempt to render every media sample.
@property (nonatomic, assign, readonly, getter=isPrecise) BOOL precise;

#pragma mark - Lifecycle

/**
 * Create an instance
 *
 * @param timeOffset    TIME-OFFSET
 * @param isPrecise     PRECISE
 * @return an instance
 */
- (instancetype _Nonnull)initWithTimeOffset:(double)timeOffset
                                    precise:(BOOL)isPrecise;

@end
