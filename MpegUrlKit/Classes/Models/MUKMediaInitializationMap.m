//
//  MUKMediaInitializationMap.m
//  MpegUrlKit
//
//  Created by Hinagiku Soranoba on 2017/01/08.
//  Copyright © 2017年 Hinagiku Soranoba. All rights reserved.
//

#import "MUKMediaInitializationMap.h"

@interface MUKMediaInitializationMap ()
@property (nonatomic, nonnull, copy, readwrite) NSString* uri;
@property (nonatomic, assign, readwrite) NSRange byteRange;
@end

@implementation MUKMediaInitializationMap

#pragma mark - Lifecycle

- (instancetype _Nonnull)initWithUri:(NSString* _Nonnull)uri
{
    return [self initWithUri:uri range:NSMakeRange(NSNotFound, 0)];
}

- (instancetype _Nonnull)initWithUri:(NSString* _Nonnull)uri
                               range:(NSRange)range
{
    if (self = [super init]) {
        self.uri = uri;
        self.byteRange = range;
    }
    return self;
}

@end
