//
//  MUKMediaEncrypt.h
//  MpegUrlKit
//
//  Created by Hinagiku Soranoba on 2017/01/07.
//  Copyright © 2017年 Hinagiku Soranoba. All rights reserved.
//

#import "MUKErrorCode.h"
#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, MUKEncryptMethod) {
    MUKEncryptUnknown = 0,
    MUKEncryptNone,
    MUKEncryptAes128,
    MUKEncryptSampleAes,
};

/*
 * 4.3.2.4 EXT-X-KEY
 * It have information that how to decrypt media segments.
 */
@interface MUKMediaEncrypt : NSObject

@property (nonatomic, assign, readonly) MUKEncryptMethod method;
@property (nonatomic, nullable, copy, readonly) NSString* uri;
/// 5.2 IV for AES_128
/// IV means 16-octet Initialization Vector
@property (nonatomic, nullable, copy, readonly) NSData* aesInitializeVector;
/// It is "identity", the key file (specified uri) is a single packed array of 16 octets in binary format.
@property (nonatomic, nonnull, copy, readonly) NSString* keyFormat;
/// Array of positive integer (NSUInteger)
@property (nonatomic, nonnull, copy, readonly) NSArray<NSNumber*>* keyFormatVersions;

#pragma mark - Lifecycle

/**
 * Create a instance.
 *
 * @param method            encrypt method
 * @param uri               key file's uri
 * @param iv                AES initialize vector
 * @param keyFormat         A string of key format
 * @param keyFormatVersions An array of positive integer (NSUInteger)
 * @return instance
 */
- (instancetype _Nonnull)initWithMethod:(MUKEncryptMethod)method
                                    uri:(NSString* _Nullable)uri
                                     iv:(NSData* _Nullable)iv
                              keyFormat:(NSString* _Nullable)keyFormat
                      keyFormatVersions:(NSArray<NSNumber*>* _Nullable)keyFormatVersions;

#pragma mark - Public Methods

/**
 * Validate and return YES if it is correct.
 *
 * @param error  If it return NO, detailed error information is saved here.
 * @return If it is correct, it return YES. Otherwise, return NO.
 */
- (BOOL)validate:(NSError* _Nullable* _Nullable)error;

/**
 * Convert to MUKEncryptMethod from NSString.
 *
 * @param string An enumerated-string
 * @return Return MUKEncryptUnknown, if the string is not supported string. 
 *         Otherwise, return converted enumerated-value.
 */
+ (MUKEncryptMethod)encryptMethodFromString:(NSString* _Nonnull)string;

/**
 * Convert to NSString from MUKEncryptMethod.
 *
 * @param method An enumerated-value
 * @return Return nil, if the method is MUKEncryptUnknown (or not enumerated-value).
 *         Otherwise, return an enumerated-string.
 */
+ (NSString* _Nullable)encryptMethodToString:(MUKEncryptMethod)method;

@end
