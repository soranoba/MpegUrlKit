//
//  MUKAttributeModel.m
//  MpegUrlKit
//
//  Created by Hinagiku Soranoba on 2017/01/15.
//  Copyright © 2017年 Hinagiku Soranoba. All rights reserved.
//

#import "MUKAttributeModel.h"
#import "MUKAttributeSerializer.h"

@implementation MUKAttributeModel

#pragma mark - Public Method

- (BOOL)validate:(NSError* _Nullable* _Nullable)error
{
    return YES;
}

#pragma mark - NSObject (Override)

- (NSString* _Nonnull)description
{
    NSString* desc = nil;
    if ([self conformsToProtocol:@protocol(MUKAttributeSerializing)]) {
        desc = [[MUKAttributeSerializer sharedSerializer] stringFromModel:(id<MUKAttributeSerializing>)self error:nil];
    }
    return desc ?: [super description];
}

@end
