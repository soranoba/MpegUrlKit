//
//  MUKMediaPlaylist.h
//  MpegUrlKit
//
//  Created by Hinagiku Soranoba on 2017/01/06.
//  Copyright © 2017年 Hinagiku Soranoba. All rights reserved.
//

#import "MUKErrorCode.h"
#import "MUKMediaSegment.h"
#import "MUKSerializing.h"
#import <Foundation/Foundation.h>

@interface MUKMediaPlaylist : MUKSerializing
@property (nonatomic, assign) NSUInteger version;
@property (nonatomic, nonnull, copy) NSArray<MUKMediaSegment*>* mediaSegments;
@end
