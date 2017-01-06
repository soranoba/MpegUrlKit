//
//  MUKSerializing.m
//  MpegUrlKit
//
//  Created by Hinagiku Soranoba on 2017/01/06.
//  Copyright © 2017年 Hinagiku Soranoba. All rights reserved.
//

#import "MUKSerializing.h"

@implementation MUKSerializing

#pragma mark - Public Methods

- (NSDictionary<NSString*, MUKLineAction>* _Nonnull)lineActions
{
    return @{};
}

#pragma mark - MUKSerializable

- (void)beginSerialization
{
    // NOP
}

- (MUKLineActionResult)appendLine:(NSString* _Nonnull)string error:(NSError* _Nullable* _Nullable)error
{
    NSDictionary<NSString*, MUKLineAction>* lineActions = self.lineActions;
    for (NSString* prefix in lineActions) {
        if ([string hasPrefix:prefix]) {
            return (lineActions[prefix])(string, error);
        }
    }
    if (lineActions[@""]) {
        return (lineActions[@""])(string, error);
    }
    return MUKLineActionResultIgnored;
}

- (void)endSerialization
{
    // NOP
}

- (BOOL)validate:(NSError* _Nullable* _Nullable)error
{
    return YES;
}

@end
