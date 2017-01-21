//
//  MUKAttributeValue.h
//  MpegUrlKit
//
//  Created by Hinagiku Soranoba on 2017/01/07.
//  Copyright © 2017年 Hinagiku Soranoba. All rights reserved.
//

#import "MUKErrorCode.h"
#import <Foundation/Foundation.h>

/**
 * This class expresses attribute value.
 */
@interface MUKAttributeValue : NSObject

/// If the value is quoted-string, it returns YES. Otherwise, it returns NO.
@property (nonatomic, assign, readonly, getter=isQuotedString) BOOL quotedString;
/// A string of the value.
/// If the value is quoted-string, it does NOT contain double quotes.
@property (nonatomic, nonnull, copy, readonly) NSString* value;

#pragma mark - Lifecycle

/**
 * Create a instance
 *
 * @param value          An attribute value. In the case of quoted-string, it must not contain double quotes.
 * @param isQuotedString In the case of quoted-string, it is YES.
 * @return instance
 */
- (instancetype _Nonnull)initWithValue:(NSString* _Nonnull)value
                        isQuotedString:(BOOL)isQuotedString;

#pragma mark - Public Methods

/**
 * Validate and return YES if it is correct.
 *
 * @param error  If it return NO, detailed error information is saved here.
 * @return If it is correct, it return YES. Otherwise, return NO.
 */
- (BOOL)validate:(NSError* _Nullable* _Nullable)error;

@end
