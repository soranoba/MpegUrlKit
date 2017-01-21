//
//  MUKTAttributeModel.m
//  MpegUrlKit
//
//  Created by Hinagiku Soranoba on 2017/01/15.
//  Copyright © 2017年 Hinagiku Soranoba. All rights reserved.
//

#import "MUKTAttributeModel.h"
#import "MUKTransformer.h"

@implementation MUKTAttributeModel

#pragma mark - MUKAttributeSerializing

+ (NSDictionary<NSString*, NSString*>* _Nonnull)propertyByAttributeKey
{
    return @{ @"BOOL" : @"b",
              @"INTEGER" : @"i",
              @"DOUBLE" : @"d",
              @"SIZE" : @"size",
              @"STRING" : @"s",
              @"ENUM" : @"e" };
}

+ (NSArray<NSString*>* _Nonnull)attributeOrder
{
    return @[ @"BOOL", @"INTEGER", @"DOUBLE", @"SIZE", @"STRING", @"ENUM" ];
}

+ (MUKTransformer* _Nonnull)sTransformer
{
    return [MUKTransformer transformerWithReverseBlock:^MUKAttributeValue* _Nullable(id _Nonnull value) {
        if ([value length] > 0) {
            return [[MUKAttributeValue alloc] initWithValue:value isQuotedString:YES];
        } else {
            return nil;
        }
    }];
}

+ (MUKTransformer* _Nonnull)eTransformer
{
    return [MUKTransformer transformerWithBlock:^id _Nullable(MUKAttributeValue* _Nonnull value) {
        if (value.isQuotedString) {
            return nil;
        } else {
            if ([value.value isEqualToString:@"A"]) {
                return @(MUKTEnumA);
            } else if ([value.value isEqualToString:@"B"]) {
                return @(MUKTEnumB);
            } else {
                return nil;
            }
        }
    }
        reverseBlock:^MUKAttributeValue* _Nullable(id _Nonnull value) {
            if ([value isEqual:@(MUKTEnumA)]) {
                return [[MUKAttributeValue alloc] initWithValue:@"A" isQuotedString:NO];
            } else if ([value isEqual:@(MUKTEnumB)]) {
                return [[MUKAttributeValue alloc] initWithValue:@"B" isQuotedString:NO];
            } else {
                return nil;
            }
        }];
}

#pragma mark - MUKAttributeModel (Override)

- (BOOL)validate:(NSError* _Nullable* _Nullable)error
{
    return YES;
}

@end
