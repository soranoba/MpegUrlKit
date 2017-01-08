//
//  NSString+MUKExtension.m
//  MpegUrlKit
//
//  Created by Hinagiku Soranoba on 2017/01/07.
//  Copyright © 2017年 Hinagiku Soranoba. All rights reserved.
//

#import "MUKConsts.h"
#import "NSError+MUKErrorDomain.h"
#import "NSString+MUKExtension.h"

static NSString* const MUKIso8601DateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ";

@implementation NSString (MUKExtension)

#pragma mark - Lifecycle

+ (instancetype _Nullable)muk_stringWithDecimal:(NSUInteger)integer
{
    return [[NSNumber numberWithUnsignedInteger:integer] stringValue];
}

+ (instancetype _Nullable)muk_stringHexWithData:(NSData* _Nonnull)data
{
    NSParameterAssert(data != nil);

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
    return [NSString stringWithFormat:@"%tux%tu", (NSUInteger)size.width, (NSUInteger)size.height];
}

+ (instancetype _Nullable)muk_stringWithDate:(NSDate* _Nonnull)date
{
    NSParameterAssert(date != nil);

    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = MUKIso8601DateFormat;
    return [dateFormatter stringFromDate:date];
}

#pragma mark - Public Methods

- (BOOL)muk_scanDecimalInteger:(NSUInteger* _Nonnull)pInteger
                         error:(NSError* _Nullable* _Nullable)error
{
    NSParameterAssert(pInteger != nil);

    NSScanner* scanner = [NSScanner scannerWithString:self];
    unsigned long long ull;
    if (![scanner scanUnsignedLongLong:&ull] || ![[self.class muk_stringWithDecimal:(NSUInteger)ull] isEqual:self]) {
        SET_ERROR(error, MUKErrorInvalidType, @"Invalid decimal integer");
        return NO;
    }
    *pInteger = (NSUInteger)ull;
    return YES;
}

- (BOOL)muk_scanHexadecimal:(NSData* _Nullable* _Nonnull)pData
                      error:(NSError* _Nullable* _Nullable)error
{
    NSParameterAssert(pData != nil);

    unsigned char* buffer = nil;

    if (!([self hasPrefix:@"0x"] || [self hasPrefix:@"0X"])) {
        SET_ERROR(error, MUKErrorInvalidType, @"Hexadecimal-sequence MUST be prefixed 0x or 0X");
        goto failed;
    }

    NSUInteger length = self.length - 2;
    size_t byteSize = (size_t)((length + 1) / 2);
    buffer = malloc(sizeof(char) * byteSize);
    memset(buffer, 0, byteSize);

    unsigned char* p = buffer;
    for (NSUInteger i = 2; i < self.length; i++) {
        unichar c = [self characterAtIndex:i];
        if (c >= '0' && c <= '9') {
            *p |= c - '0';
        } else if (c >= 'a' && c <= 'f') {
            *p |= c - 'a' + 10;
        } else if (c >= 'A' && c <= 'F') {
            *p |= c - 'A' + 10;
        } else {
            SET_ERROR(error, MUKErrorInvalidType, @"Invalid hexadecimal-sequence");
            goto failed;
        }

        if (i % 2 == 1) {
            p++;
        } else {
            *p <<= 4;
        }
    }

    *pData = [NSData dataWithBytesNoCopy:buffer length:byteSize freeWhenDone:YES];
    return YES;

failed:
    if (buffer) {
        free(buffer);
    }
    return NO;
}

- (BOOL)muk_scanDouble:(double* _Nonnull)pDouble
                 error:(NSError* _Nullable* _Nullable)error
{
    NSParameterAssert(pDouble != nil);

    for (NSUInteger i = 0; i < self.length; i++) {
        unichar c = [self characterAtIndex:i];
        if (!((c >= '0' && c <= '9') || c == '.' || (c == '-' && i == 0))) {
            SET_ERROR(error, MUKErrorInvalidType, @"invalid decimal-floating-point");
            return NO;
        }
    }

    NSScanner* scanner = [NSScanner scannerWithString:self];
    if (![scanner scanDouble:pDouble]) {
        SET_ERROR(error, MUKErrorInvalidType, @"invalid decimal-floating-point");
        return NO;
    }
    return YES;
}

- (BOOL)muk_scanDecimalResolution:(CGSize* _Nonnull)pSize
                            error:(NSError* _Nullable* _Nullable)error
{
    NSParameterAssert(pSize != nil);

    NSArray<NSString*>* strs = [self componentsSeparatedByString:@"x"];
    if (strs.count != 2) {
        SET_ERROR(error, MUKErrorInvalidType, @"decimal-resolution MUST be two decimal-integers separated by the 'x'");
        return NO;
    }

    NSUInteger w, h;
    if (!([strs[0] muk_scanDecimalInteger:&w error:error] && [strs[1] muk_scanDecimalInteger:&h error:error])) {
        SET_ERROR(error, MUKErrorInvalidType, @"decimal-resolution MUST be two decimal-integers separated by the 'x'");
        return NO;
    }
    *pSize = CGSizeMake(w, h);
    return YES;
}

- (BOOL)muk_scanDate:(NSDate* _Nullable* _Nonnull)pDate
               error:(NSError* _Nullable* _Nullable)error
{
    NSParameterAssert(pDate != nil);

    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = MUKIso8601DateFormat;

    NSDate* date = [dateFormatter dateFromString:self];
    if (date) {
        *pDate = date;
        return YES;
    } else {
        SET_ERROR(error, MUKErrorInvalidType, @"invalid iso-8601 date format");
        return NO;
    }
}

@end
