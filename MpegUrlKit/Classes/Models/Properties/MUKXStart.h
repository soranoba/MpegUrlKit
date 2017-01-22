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

@property (nonatomic, assign, readonly) double timeOffset;
@property (nonatomic, assign, readonly, getter=isPrecise) BOOL precise;

@end
