//
//  MUKXKey.m
//  MpegUrlKit
//
//  Created by Hinagiku Soranoba on 2017/01/07.
//  Copyright © 2017年 Hinagiku Soranoba. All rights reserved.
//

#import "MUKXKey.h"
#import "MUKConsts.h"
#import "NSError+MUKErrorDomain.h"

static NSString* const MUK_EXT_X_KEY_METHOD_NONE = @"NONE";
static NSString* const MUK_EXT_X_KEY_METHOD_AES_128 = @"AES-128";
static NSString* const MUK_EXT_X_KEY_METHOD_SAMPLE_AES = @"SAMPLE-AES";

@interface MUKXKey ()
@property (nonatomic, assign, readwrite) MUKXKeyMethod method;
@property (nonatomic, nullable, copy, readwrite) NSString* uri;
@property (nonatomic, nullable, copy, readwrite) NSData* aesInitializeVector;
@property (nonatomic, nonnull, copy, readwrite) NSString* keyFormat;
@property (nonatomic, nonnull, copy, readwrite) NSArray<NSNumber*>* keyFormatVersions;
@end

@implementation MUKXKey

#pragma mark - Lifecycle

- (instancetype _Nonnull)init
{
    if (self = [super init]) {
        self.keyFormat = @"identity";
        self.keyFormatVersions = @[ @1 ];
    }
    return self;
}

- (instancetype _Nonnull)initWithMethod:(MUKXKeyMethod)method
                                    uri:(NSString* _Nullable)uri
                                     iv:(NSData* _Nullable)iv
                              keyFormat:(NSString* _Nullable)keyFormat
                      keyFormatVersions:(NSArray<NSNumber*>* _Nullable)keyFormatVersions
{
    if (self = [self init]) {
        self.method = method;
        self.uri = uri;
        self.aesInitializeVector = iv;
        if (keyFormat) {
            self.keyFormat = keyFormat;
        }
        if (keyFormatVersions) {
            self.keyFormatVersions = keyFormatVersions;
        }
    }
    return self;
}

#pragma mark - Public Methods

+ (MUKXKeyMethod)keyMethodFromString:(NSString* _Nonnull)string
{
    if ([string isEqualToString:MUK_EXT_X_KEY_METHOD_NONE]) {
        return MUKXKeyMethodNone;
    } else if ([string isEqualToString:MUK_EXT_X_KEY_METHOD_AES_128]) {
        return MUKXKeyMethodAes128;
    } else if ([string isEqualToString:MUK_EXT_X_KEY_METHOD_SAMPLE_AES]) {
        return MUKXKeyMethodSampleAes;
    }
    return MUKXKeyMethodUnknown;
}

+ (NSString* _Nullable)keyMethodToString:(MUKXKeyMethod)method
{
    switch (method) {
        case MUKXKeyMethodNone:
            return MUK_EXT_X_KEY_METHOD_NONE;
        case MUKXKeyMethodAes128:
            return MUK_EXT_X_KEY_METHOD_AES_128;
        case MUKXKeyMethodSampleAes:
            return MUK_EXT_X_KEY_METHOD_SAMPLE_AES;
        default:
            return nil;
    }
}

#pragma mark - MUKAttributeSerializing

+ (NSDictionary<NSString*, NSString*>* _Nonnull)keyByPropertyKey
{
    return @{ @"METHOD" : @"method",
              @"URI" : @"uri",
              @"IV" : @"aesInitializeVector",
              @"KEYFORMAT" : @"keyFormat",
              @"KEYFORMATVERSIONS" : @"keyFormatVersions" };
}

+ (NSArray<NSString*>* _Nonnull)attributeOrder
{
    return @[ @"METHOD", @"URI", @"IV", @"KEYFORMAT", @"KEYFORMATVERSIONS" ];
}

+ (NSDictionary<NSString*, NSNumber*>* _Nonnull)minimumAttributeSupportedVersions
{
    return @{ @"IV" : @(2),
              @"KEYFORMAT" : @(5),
              @"KEYFORMATVERSIONS" : @(5) };
}

+ (MUKTransformer* _Nonnull)methodTransformer
{
    return [MUKTransformer transformerWithBlock:^id _Nullable(MUKAttributeValue* _Nonnull value) {
        if (value.isQuotedString) {
            return nil;
        } else {
            return @([self keyMethodFromString:value.value]);
        }
    }
        reverseBlock:^MUKAttributeValue* _Nullable(id _Nonnull value) {
            NSString* s = [self keyMethodToString:(MUKXKeyMethod)[value unsignedIntegerValue]];
            if (s) {
                return [[MUKAttributeValue alloc] initWithValue:s isQuotedString:NO];
            } else {
                return nil;
            }
        }];
}

+ (MUKTransformer* _Nonnull)keyFormatVersionsTransformer
{
    return [MUKTransformer transformerWithBlock:^id _Nullable(MUKAttributeValue* _Nonnull value) {
        if (value.isQuotedString) {
            NSArray<NSString*>* formats = [value.value componentsSeparatedByString:@"/"];
            NSMutableArray<NSNumber*>* keyFormatVersions = [NSMutableArray arrayWithCapacity:formats.count];
            NSInteger num;

            for (NSString* format in formats) {
                if ((num = [format integerValue])) {
                    [keyFormatVersions addObject:[NSNumber numberWithInteger:num]];
                } else {
                    return nil;
                }
            }
            return keyFormatVersions;
        } else {
            return nil;
        }
    }
        reverseBlock:^MUKAttributeValue* _Nullable(id _Nonnull value) {
            NSParameterAssert([value isKindOfClass:NSArray.class]);

            NSMutableString* str = [NSMutableString string];
            for (NSNumber* num in value) {
                if (str.length > 0) {
                    [str appendString:@"/"];
                }
                [str appendString:[num stringValue]];
            }
            return [[MUKAttributeValue alloc] initWithValue:str isQuotedString:YES];
        }];
}

#pragma mark - MUKAttributeModel (Override)

- (BOOL)validate:(NSError* _Nullable* _Nullable)error
{
    if (self.method != MUKXKeyMethodNone && self.uri.length == 0) {
        SET_ERROR(error, MUKErrorInvalidEncrypt,
                  ([NSString stringWithFormat:@"Uri is REQUIRED unless the method is NONE. method is %@",
                                              [self.class keyMethodToString:self.method]]));
        return NO;
    }

    for (NSNumber* value in self.keyFormatVersions) {
        if (value.integerValue <= 0) {
            SET_ERROR(error, MUKErrorInvalidEncrypt, @"KeyFormatVersions MUST be an array of positive integer");
            return NO;
        }
    }
    return YES;
}

@end
