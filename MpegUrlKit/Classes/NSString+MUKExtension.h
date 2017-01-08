//
//  NSString+MUKExtension.h
//  MpegUrlKit
//
//  Created by Hinagiku Soranoba on 2017/01/07.
//  Copyright © 2017年 Hinagiku Soranoba. All rights reserved.
//

#import "MUKErrorCode.h"
#import <Foundation/Foundation.h>

@interface NSString (MUKExtension)

#pragma mark - Lifecycle

/**
 * Convert from decimal-integer
 *
 * @param integer A integer
 * @return If convert successed, it return instance. Otherwise, return nil.
 */
+ (instancetype _Nullable)muk_stringWithDecimal:(NSUInteger)integer;

/**
 * Convert from data of hexadecimal-sequence
 *
 * @param data data of hexadecimal-sequence
 * @return If convert successed, it return instance. Otherwise, return nil.
 */
+ (instancetype _Nullable)muk_stringHexWithData:(NSData* _Nonnull)data;

/**
 * Convert from double (decimal-floating-point or signed-decimal-floating-point)
 *
 * @param d double value
 * @return If convert successed, it return instance. Otherwise, return nil.
 */
+ (instancetype _Nullable)muk_stringWithDouble:(double)d;

/**
 * Convert from size of decimal-resolution
 *
 * @param size decimal-resolution
 * @return If convert successed, it return instance. Otherwise, return nil.
 */
+ (instancetype _Nullable)muk_stringWithSize:(CGSize)size;

/**
 * Convert to iso-8601 date format string from date
 *
 * @param date A date
 * @return If convert successed, it return instance. Otherwise, return nil.
 */
+ (instancetype _Nullable)muk_stringWithDate:(NSDate* _Nonnull)date;

#pragma mark - Public Methods

/**
 * Read a string of value as a decimal integer (decimal-integer)
 *
 * @param pInteger Pointer to receive results
 * @param error    If it return nil, detailed error information is saved here.
 * @return If it scan succeeded, it return YES. Otherwise, it return NO.
 */
- (BOOL)muk_scanDecimalInteger:(NSUInteger* _Nonnull)pInteger
                         error:(NSError* _Nullable* _Nullable)error;

/**
 * Read a string of value as a hexadecimal (hexadecimal-sequence)
 *
 * @param pData    Pointer to receive results
 * @param error    If it return nil, detailed error information is saved here.
 * @return If it scan succeeded, it return YES. Otherwise, it return NO.
 */
- (BOOL)muk_scanHexadecimal:(NSData* _Nullable* _Nonnull)pData
                      error:(NSError* _Nullable* _Nullable)error;

/**
 * Read a string of value as a double (decimal-floating-point and signed-decimal-floating-point)
 *
 * @param pDouble   Pointer to receive results
 * @param error    If it return nil, detailed error information is saved here.
 * @return If it scan succeeded, it return YES. Otherwise, it return NO.
 */
- (BOOL)muk_scanDouble:(double* _Nonnull)pDouble
                 error:(NSError* _Nullable* _Nullable)error;

/**
 * Read a string of value as a decimal resolution (decimal-resolution)
 *
 * @param pSize    Pointer to receive results
 * @param error    If it return nil, detailed error information is saved here.
 * @return If it scan succeeded, it return YES. Otherwise, it return NO.
 */
- (BOOL)muk_scanDecimalResolution:(CGSize* _Nonnull)pSize
                            error:(NSError* _Nullable* _Nullable)error;

/**
 * Read a string of value as a iso-8601 date format
 *
 * @param pDate    Pointer to receive results
 * @param error    If it return nil, detailed error information is saved here.
 * @return If it scan succeeded, it return YES. Otherwise, it return NO.
 */
- (BOOL)muk_scanDate:(NSDate* _Nullable* _Nonnull)pDate
               error:(NSError* _Nullable* _Nullable)error;

@end
