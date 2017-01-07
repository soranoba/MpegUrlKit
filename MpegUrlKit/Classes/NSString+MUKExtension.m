//
//  NSString+MUKExtension.m
//  MpegUrlKit
//
//  Created by Hinagiku Soranoba on 2017/01/07.
//  Copyright © 2017年 Hinagiku Soranoba. All rights reserved.
//

#import "NSString+MUKExtension.h"

@implementation NSString (MUKExtension)

+ (instancetype _Nullable)muk_stringWithDecimal:(NSUInteger)integer
{
    return [[NSNumber numberWithUnsignedInteger:integer] stringValue];
}

+ (instancetype _Nullable)muk_stringHexWithData:(NSData* _Nonnull)data
{
    if (data.length == 0) {
        return nil;
    }

    NSMutableString* str = [NSMutableString stringWithCapacity:data.length * 2 + 2];
    [str appendString:@"0x"];

    [data enumerateByteRangesUsingBlock:^(const void* _Nonnull bytes, NSRange byteRange, BOOL* _Nonnull stop) {
        for (NSUInteger i = 0; i < byteRange.length; ++i) {
            uint8_t a = (((uint8_t*)bytes)[i] & 0xf0) >> 4;
            uint8_t b = ((uint8_t*)bytes)[i] & 0x0f;
            [str appendFormat:@"%c%c",
                              (a >= 10 ? (a - 10) + 'a' : a + '0'),
                              (b >= 10 ? (b - 10) + 'a' : b + '0')];
        }
    }];
    return str;
}

+ (instancetype _Nullable)muk_stringWithDouble:(double)d
{
    return [[NSNumber numberWithDouble:d] stringValue];
}

+ (instancetype _Nullable)muk_stringWithSize:(CGSize)size
{
    return [NSString stringWithFormat:@"%lux%lu", (NSUInteger)size.width, (NSUInteger)size.height];
}

@end
