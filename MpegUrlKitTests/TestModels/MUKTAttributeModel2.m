//
//  MUKTAttributeModel2.m
//  MpegUrlKit
//
//  Created by Hinagiku Soranoba on 2017/01/21.
//  Copyright © 2017年 Hinagiku Soranoba. All rights reserved.
//

#import "MUKTAttributeModel2.h"

@implementation MUKTAttributeModel2

#pragma mark - MUKAttributeSerializing

+ (NSDictionary<NSString*, NSString*>* _Nonnull)propertyByAttributeKey
{
    return @{ @"V1" : @"v1",
              @"V2" : @"v2",
              @"V3" : @"v3",
              @"V4" : @"v4" };
}

+ (NSArray<NSString*>* _Nonnull)attributeOrder
{
    return @[ @"V1", @"V2", @"V3", @"V4" ];
}

+ (NSUInteger)minimumModelSupportedVersion
{
    return 2;
}

+ (NSDictionary<NSString*, NSNumber*>* _Nonnull)minimumAttributeSupportedVersions
{
    return @{ @"V2" : @(2),
              @"V3" : @(3),
              @"V4" : @(4) };
}

@end
