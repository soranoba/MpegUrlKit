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

- (instancetype _Nonnull)initWithMethod:(MUKXKeyMethod)method
                                    uri:(NSString* _Nullable)uri
                                     iv:(NSData* _Nullable)iv
                              keyFormat:(NSString* _Nullable)keyFormat
                      keyFormatVersions:(NSArray<NSNumber*>* _Nullable)keyFormatVersions
{
    if (self = [super init]) {
        self.method = method;
        self.uri = uri;
        self.aesInitializeVector = iv;
        self.keyFormat = keyFormat ?: @"identity"; // default: "identity"
        self.keyFormatVersions = keyFormatVersions ?: @[ @1 ]; // default: 1
    }
    return self;
}

#pragma mark - Public Methods

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

@end
