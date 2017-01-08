//
//  MUKAttributeList.h
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

@property (nonatomic, assign, readonly) BOOL isQuotedString;
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

/**
 * 4.2. Attribute Lists.
 *
 * This class is performs character string conversion of attribute list.
 */
@interface MUKAttributeList : NSObject

#pragma mark - Public Methods

/**
 * Parse the attribute list.
 *
 * @param string A string of attribute list
 * @param error  If it return nil, detailed error information is saved here.
 * @return Return nil, if it parse failed. Otherwise, return attribute key-value pairs.
 */
+ (NSDictionary<NSString*, MUKAttributeValue*>* _Nullable)parseFromString:(NSString* _Nonnull)string
                                                                    error:(NSError* _Nullable* _Nullable)error;

/**
 * Make a string of attribute list
 *
 * @param attributes A attribute key-value pairs.
 * @param error      If it return nil, detailed error information is saved here.
 * @return Return nil, if it failed. Otherwise, return a string of attribute list.
 */
+ (NSString* _Nullable)makeFromDict:(NSDictionary<NSString*, MUKAttributeValue*>* _Nonnull)attributes
                              error:(NSError* _Nullable* _Nullable)error;

@end
