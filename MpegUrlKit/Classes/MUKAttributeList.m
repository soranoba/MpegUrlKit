//
//  MUKAttributeList.m
//  MpegUrlKit
//
//  Created by Hinagiku Soranoba on 2017/01/07.
//  Copyright © 2017年 Hinagiku Soranoba. All rights reserved.
//

#import "MUKAttributeList.h"
#import "MUKConsts.h"
#import "NSError+MUKErrorDomain.h"

@interface MUKAttributeValue ()

@property (nonatomic, assign, readwrite) BOOL isQuotedString;
@property (nonatomic, nonnull, copy, readwrite) NSString* value;

@end

@implementation MUKAttributeValue

#pragma mark - Lifecycle

- (instancetype _Nonnull)initWithValue:(NSString* _Nonnull)value
                        isQuotedString:(BOOL)isQuotedString
{
    NSParameterAssert(value != nil);

    if (self = [super init]) {
        self.isQuotedString = isQuotedString;
        self.value = value;
    }
    return self;
}

#pragma mark - Public Methods

- (BOOL)scanDecimalInteger:(NSUInteger* _Nonnull)pInteger
                     error:(NSError* _Nullable* _Nullable)error
{
    NSParameterAssert(pInteger != nil);

    NSScanner* scanner = [NSScanner scannerWithString:self.value];
    unsigned long long ull;
    if (![scanner scanUnsignedLongLong:&ull]) {
        SET_ERROR(error, MUKErrorInvalidType, @"Invalid decimal integer");
        return NO;
    }
    *pInteger = ull;
    return YES;
}

- (BOOL)scanHexadecimal:(NSData* _Nullable* _Nonnull)pData
                  error:(NSError* _Nullable* _Nullable)error
{
    NSParameterAssert(pData != nil);

    unsigned char* buffer = nil;

    if (!([self.value hasPrefix:@"0x"] || [self.value hasPrefix:@"0X"])) {
        SET_ERROR(error, MUKErrorInvalidType, @"Hexadecimal-sequence MUST be prefixed 0x or 0X");
        goto failed;
    }

    NSUInteger length = self.value.length - 2;
    size_t byteSize = (size_t)((length + 1) / 2);
    buffer = malloc(sizeof(char) * byteSize);
    memset(buffer, 0, byteSize);

    unsigned char* p = buffer;
    for (NSUInteger i = 2; i < self.value.length; i++) {
        unichar c = [self.value characterAtIndex:i];
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

- (BOOL)scanDouble:(double* _Nonnull)pDouble
             error:(NSError* _Nullable* _Nullable)error
{
    NSParameterAssert(pDouble != nil);

    for (NSUInteger i = 0; i < self.value.length; i++) {
        unichar c = [self.value characterAtIndex:i];
        if (!((c >= '0' && c <= '9') || c == '.' || c == '-')) {
            SET_ERROR(error, MUKErrorInvalidType, @"invalid decimal-floating-point");
            return NO;
        }
    }

    NSScanner* scanner = [NSScanner scannerWithString:self.value];
    if (![scanner scanDouble:pDouble]) {
        SET_ERROR(error, MUKErrorInvalidType, @"invalid decimal-floating-point");
        return NO;
    }
    return YES;
}

- (BOOL)scanDecimalResolution:(CGSize* _Nonnull)pSize
                        error:(NSError* _Nullable* _Nullable)error
{
    NSArray<NSString*>* strs = [self.value componentsSeparatedByString:@"x"];
    if (strs.count != 2) {
        SET_ERROR(error, MUKErrorInvalidType, @"decimal-resolution MUST be two decimal-integers separated by the 'x'");
        return NO;
    }
    *pSize = CGSizeMake([strs[0] integerValue], [strs[1] integerValue]);
    return YES;
}

- (BOOL)validate:(NSError* _Nullable* _Nullable)error
{
    for (NSUInteger i = 0; i < self.value.length; i++) {
        switch ([self.value characterAtIndex:i]) {
            case '"':
            case '\r':
            case '\n':
                SET_ERROR(error, MUKErrorInvalidAttributeList,
                          @"It MUST NOT include double quotes, CR and LF");
                return NO;
            case ',':
                if (!self.isQuotedString) {
                    SET_ERROR(error, MUKErrorInvalidAttributeList,
                              @"It MUST NOT include commas, when it is not quoted-string.");
                    return NO;
                }
            default:
                break; // NOP
        }
    }
    return YES;
}

#pragma mark - NSObject (Overwrite)

- (BOOL)isEqual:(id _Nullable)object
{
    if ([object isKindOfClass:self.class]) {
        typeof(self) anotherValue = object;
        return self.isQuotedString == anotherValue.isQuotedString && [self.value isEqualToString:anotherValue.value];
    }
    return NO;
}

@end

@implementation MUKAttributeList

#pragma mark - Public Methods

+ (NSDictionary<NSString*, MUKAttributeValue*>* _Nullable)parseFromString:(NSString* _Nonnull)string
                                                                    error:(NSError* _Nullable* _Nullable)error
{
    NSParameterAssert(string != nil);

    NSMutableDictionary<NSString*, MUKAttributeValue*>* attributes = [NSMutableDictionary dictionary];
    NSString *key = nil, *value = nil;
    NSUInteger i, p;

    for (i = 0, p = 0; i < string.length; i++) {
        if ([string characterAtIndex:i] != '=') {
            continue;
        }

        key = [string substringWithRange:NSMakeRange(p, i - p)];
        if (attributes[key]) {
            SET_ERROR(error, MUKErrorInvalidAttributeList,
                      ([NSString stringWithFormat:@"The same attribute key MUST NOT be present. Duplicate key is %@", key]));
            return nil;
        }
        p = ++i;

        if ([string characterAtIndex:i] == '"') { // quoted-string
            for (p = ++i; i < string.length; i++) {
                if ([string characterAtIndex:i] != '"') {
                    continue;
                }

                value = [string substringWithRange:NSMakeRange(p, i - p)];
                if (++i >= string.length || [string characterAtIndex:i] == ',') {
                    attributes[key] = [[MUKAttributeValue alloc] initWithValue:value isQuotedString:YES];
                    break;
                } else {
                    SET_ERROR(error, MUKErrorInvalidAttributeList, @"Characters are present outside double quotes");
                    return nil;
                }
            }
            if (!value) {
                SET_ERROR(error, MUKErrorInvalidAttributeList, @"Quoted-string has not ended");
                return nil;
            }
        } else { // other
            for (; i < string.length; i++) {
                if ([string characterAtIndex:i] == ',') {
                    break;
                }
            }
            value = [string substringWithRange:NSMakeRange(p, i - p)];
            attributes[key] = [[MUKAttributeValue alloc] initWithValue:value isQuotedString:NO];
        }

        if (![attributes[key] validate:error]) {
            return nil;
        }

        p = ++i;
        value = nil;
    }

    if (p + 1 != i) {
        SET_ERROR(error, MUKErrorInvalidAttributeList, @"key-value pairs are broken");
        return nil;
    }
    return attributes;
}

+ (NSString* _Nullable)makeFromDict:(NSDictionary<NSString*, MUKAttributeValue*>* _Nonnull)attributes
                              error:(NSError* _Nullable* _Nullable)error
{
    NSParameterAssert(attributes != nil);

    NSMutableString* result = [NSMutableString string];
    for (NSString* key in attributes) {
        if (result.length != 0) {
            [result appendString:@","];
        }

        MUKAttributeValue* value = attributes[key];
        if (![value validate:error]) {
            return nil;
        }

        if (value.isQuotedString) {
            [result appendFormat:@"%@=\"%@\"", key, value.value];
        } else {
            [result appendFormat:@"%@=%@", key, value.value];
        }
    }
    return result;
}

@end
