//
//  MUKMasterPlaylist.m
//  MpegUrlKit
//
//  Created by Hinagiku Soranoba on 2017/01/06.
//  Copyright © 2017年 Hinagiku Soranoba. All rights reserved.
//

#import "MUKMasterPlaylist.h"
#import "MUKConsts.h"

@implementation MUKMasterPlaylist

#pragma mark - MUKSerializing (Override)

- (NSDictionary<NSString*, MUKLineAction>* _Nonnull)lineActions
{
    return @{};
}

@end
