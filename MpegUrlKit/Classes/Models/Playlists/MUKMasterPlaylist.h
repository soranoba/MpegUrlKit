//
//  MUKMasterPlaylist.h
//  MpegUrlKit
//
//  Created by Hinagiku Soranoba on 2017/01/06.
//  Copyright © 2017年 Hinagiku Soranoba. All rights reserved.
//

#import "MUKErrorCode.h"
#import "MUKSerializing.h"
#import "MUKXIframeStreamInf.h"
#import "MUKXKey.h"
#import "MUKXMedia.h"
#import "MUKXSessionData.h"
#import "MUKXStart.h"
#import "MUKXStreamInf.h"
#import <Foundation/Foundation.h>

@interface MUKMasterPlaylist : MUKSerializing

@property (nonatomic, nonnull, copy) NSArray<MUKXMedia*>* medias;
@property (nonatomic, nonnull, copy) NSArray<MUKXStreamInf*>* streamInfs;
@property (nonatomic, nonnull, copy) NSArray<MUKXSessionData*>* sessionDatas;
@property (nonatomic, nonnull, copy) NSArray<MUKXKey*>* sessionKeys;
@property (nonatomic, assign, getter=isIndependentSegment) BOOL independentSegment;
@property (nonatomic, nullable, strong) MUKXStart* startOffset;

@end
