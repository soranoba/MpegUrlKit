//
//  MUKTransformer.h
//  MpegUrlKit
//
//  Created by Hinagiku Soranoba on 2017/01/15.
//  Copyright © 2017年 Hinagiku Soranoba. All rights reserved.
//

#import "MUKAttributeValue.h"
#import <Foundation/Foundation.h>

/// If conversion succeeded, it returns an object. Otherwise, it returns nil.
typedef id _Nullable (^MUKTransformBlock)(MUKAttributeValue* _Nonnull);
/// If conversion succeeded, it returns a MUKAttributeValue object. Otherwise, it returns nil.
typedef MUKAttributeValue* _Nullable (^MUKReverseTransformBlock)(id _Nonnull);

/**
 * A class that defines how to serialize and deserialize.
 *
 * Use this class if the property of the MUKAttributeModel is not enough for default transformation.
 *
 * @see MUKAttributeModel
 */
@interface MUKTransformer : NSValueTransformer

#pragma mark - Lifecycle

/**
 * Create an instance
 *
 * @param block         A transformation block when transform to model from attribute value.
 * @param reverseBlock  A transformation block when transform to attribute model from model.
 * @return An instance
 */
- (instancetype _Nonnull)initWithBlock:(MUKTransformBlock _Nullable)block
                          reverseBlock:(MUKReverseTransformBlock _Nullable)reverseBlock;

/**
 * @see initWithBlock:reverseBlock:
 */
+ (instancetype _Nonnull)transformerWithBlock:(MUKTransformBlock _Nullable)block
                                 reverseBlock:(MUKReverseTransformBlock _Nullable)reverseBlock;

/**
 * @see initWithBlock:reverseBlock:
 */
+ (instancetype _Nonnull)transformerWithBlock:(MUKTransformBlock _Nonnull)block;

/**
 * @see initWithBlock:reverseBlock:
 */
+ (instancetype _Nonnull)transformerWithReverseBlock:(MUKReverseTransformBlock _Nonnull)reverseBlock;

#pragma mark - Public Methods

/**
 * Returns whether it has transformBlock.
 *
 * @return If it has transformBlock, it returns YES. Otherwise, it returns NO.
 */
- (BOOL)hasTransformBlock;

/**
 * Returns whether it has reverseTransformBlock.
 *
 * @return If it has reverseTransformBlock, it returns YES. Otherwise, it returns NO.
 */
- (BOOL)hasReverseTransformBlock;

@end
