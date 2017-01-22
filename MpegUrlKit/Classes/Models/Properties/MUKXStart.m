//
//  MUKXStart.m
//  MpegUrlKit
//
//  Created by Hinagiku Soranoba on 2017/01/21.
//  Copyright © 2017年 Hinagiku Soranoba. All rights reserved.
//

#import "MUKXStart.h"
#import "NSError+MUKErrorDomain.h"
#import "NSString+MUKExtension.h"

@implementation MUKXStart

#pragma mark - MUKAttributeSerializing

+ (NSDictionary<NSString*, NSString*>* _Nonnull)propertyByAttributeKey
{
    return @{ @"TIME-OFFSET" : @"timeOffset",
              @"PRECISE" : @"precise" };
}

+ (NSArray<NSString*>* _Nonnull)attributeOrder
{
    return @[ @"TIME-OFFSET", @"PRECISE" ];
}

+ (MUKTransformer* _Nonnull)timeOffsetTransformer
{
    return [MUKTransformer transformerWithReverseBlock:^MUKAttributeValue* _Nullable(id _Nonnull value) {
        NSParameterAssert([value isKindOfClass:NSNumber.class]);

        NSString* str = [NSString muk_stringWithDouble:[value doubleValue]];
        return [[MUKAttributeValue alloc] initWithValue:str isQuotedString:NO];
    }];
}

#pragma mark - MUKAttributeModel (Override)

- (BOOL)validate:(NSError* _Nullable* _Nullable)error
{
    return YES;
}

@end
