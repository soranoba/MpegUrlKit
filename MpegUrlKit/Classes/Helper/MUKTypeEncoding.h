//
//  MUKTypeEncoding.h
//  MpegUrlKit
//
//  Created by Hinagiku Soranoba on 2017/01/19.
//  Copyright © 2017年 Hinagiku Soranoba. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

/**
 * A Class that holds information by analyzing the type of property.
 */
@interface MUKTypeEncoding : NSObject

/// A type information.
///
/// e.g.
///
/// if (strcmp(self.objCType, @ encode(int)) == 0) { // Please remove a space after the @.
///     // If the objCType is `int`, the scope will execute.
/// }
///
@property (nonatomic, nonnull, assign, readonly) char* const objCType;

/// If the objCType is equal `@ encode(id)`, it returns a object type.
/// Otherwise, it return nil.
@property (nonatomic, nullable, copy, readonly) Class klass;

#pragma mark - Lifecycle

/**
 * Create an instance.
 *
 * @param property A property that you want to analyze type.
 * @return instance
 */
- (instancetype _Nullable)initWithProperty:(objc_property_t _Nonnull)property;

@end
