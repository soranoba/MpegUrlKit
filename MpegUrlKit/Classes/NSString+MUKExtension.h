//
//  NSString+MUKExtension.h
//  MpegUrlKit
//
//  Created by Hinagiku Soranoba on 2017/01/07.
//  Copyright © 2017年 Hinagiku Soranoba. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (MUKExtension)

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

@end
