//
//  MUKTransformer.m
//  MpegUrlKit
//
//  Created by Hinagiku Soranoba on 2017/01/15.
//  Copyright © 2017年 Hinagiku Soranoba. All rights reserved.
//

#import "MUKTransformer.h"

@interface MUKTransformer ()
@property (nonatomic, nullable, copy) MUKTransformBlock block;
@property (nonatomic, nullable, copy) MUKReverseTransformBlock reverseBlock;
@end

@implementation MUKTransformer

#pragma mark - Lifecycle

- (instancetype _Nonnull)initWithBlock:(MUKTransformBlock _Nullable)block
                          reverseBlock:(MUKReverseTransformBlock _Nullable)reverseBlock
{
    if (self = [super init]) {
        self.block = block;
        self.reverseBlock = reverseBlock;
    }
    return self;
}

+ (instancetype _Nonnull)transformerWithBlock:(MUKTransformBlock _Nullable)block
                                 reverseBlock:(MUKReverseTransformBlock _Nullable)reverseBlock
{
    return [[self alloc] initWithBlock:block reverseBlock:reverseBlock];
}

+ (instancetype _Nonnull)transformerWithBlock:(MUKTransformBlock _Nonnull)block
{
    return [[self alloc] initWithBlock:block reverseBlock:nil];
}

+ (instancetype _Nonnull)transformerWithReverseBlock:(MUKReverseTransformBlock _Nonnull)reverseBlock
{
    return [[self alloc] initWithBlock:nil reverseBlock:reverseBlock];
}

#pragma mark - Public Methods

- (BOOL)hasTransformBlock
{
    return self.block != nil;
}

- (BOOL)hasReverseTransformBlock
{
    return self.reverseBlock != nil;
}

#pragma mark - NSValueTransformer (Override)

+ (BOOL)allowsReverseTransformation
{
    return YES;
}

- (id _Nullable)transformedValue:(id _Nullable)value
{
    if (!value || !self.block) {
        return nil;
    }
    return self.block(value);
}

- (id _Nullable)reverseTransformedValue:(id _Nullable)value
{
    if (!value || !self.reverseBlock) {
        return nil;
    }
    return self.reverseBlock(value);
}

@end
