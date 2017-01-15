//
//  MUKTransformer.h
//  MpegUrlKit
//
//  Created by Hinagiku Soranoba on 2017/01/15.
//  Copyright © 2017年 Hinagiku Soranoba. All rights reserved.
//

#import "MUKAttributeValue.h"
#import <Foundation/Foundation.h>

typedef id _Nullable (^MUKTransformBlock)(MUKAttributeValue* _Nonnull);
typedef MUKAttributeValue* _Nullable (^MUKReverseTransformBlock)(id _Nonnull);

@interface MUKTransformer : NSValueTransformer

#pragma mark - Lifecycle

- (instancetype _Nonnull)initWithBlock:(MUKTransformBlock _Nullable)block
                          reverseBlock:(MUKReverseTransformBlock _Nullable)reverseBlock;

+ (instancetype _Nonnull)transformerWithBlock:(MUKTransformBlock _Nullable)block
                                 reverseBlock:(MUKReverseTransformBlock _Nullable)reverseBlock;

#pragma mark - Public Methods

- (BOOL)hasTransformBlock;

- (BOOL)hasReverseTransformBlock;

@end
