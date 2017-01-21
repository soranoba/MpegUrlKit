//
//  MUKXMap.m
//  MpegUrlKit
//
//  Created by Hinagiku Soranoba on 2017/01/08.
//  Copyright © 2017年 Hinagiku Soranoba. All rights reserved.
//

#import "MUKXMap.h"
#import "NSError+MUKErrorDomain.h"

@interface MUKXMap ()
@property (nonatomic, nonnull, copy, readwrite) NSURL* uri;
@property (nonatomic, assign, readwrite) NSRange byteRange;
@end

@implementation MUKXMap

#pragma mark - Lifecycle

- (instancetype _Nonnull)init
{
    if (self = [super init]) {
        self.byteRange = NSMakeRange(NSNotFound, 0);
    }
    return self;
}

- (instancetype _Nonnull)initWithUri:(NSString* _Nonnull)uri
{
    return [self initWithUri:uri range:NSMakeRange(NSNotFound, 0)];
}

- (instancetype _Nonnull)initWithUri:(NSURL* _Nonnull)uri
                               range:(NSRange)range
{
    if (self = [super init]) {
        self.uri = uri;
        self.byteRange = range;
    }
    return self;
}

#pragma mark - MUKAttributeSerializing

+ (NSDictionary<NSString*, NSString*>* _Nonnull)propertyByAttributeKey
{
    return @{ @"URI" : @"uri",
              @"BYTERANGE" : @"byteRange" };
}

+ (NSArray<NSString*>* _Nonnull)attributeOrder
{
    return @[ @"URI", @"BYTERANGE" ];
}

+ (NSUInteger)minimumModelSupportedVersion
{
    return 5;
}

+ (MUKTransformer* _Nonnull)byteRangeTransformer
{
    return [MUKTransformer transformerWithBlock:^id _Nullable(MUKAttributeValue* _Nonnull value) {
        if (value.isQuotedString) {
            NSArray<NSString*>* strs = [value.value componentsSeparatedByString:@"@"];
            switch (strs.count) {
                case 1:
                    return [NSValue valueWithRange:NSMakeRange(0, [strs[0] integerValue])];
                case 2:
                    return [NSValue valueWithRange:NSMakeRange([strs[1] integerValue], [strs[0] integerValue])];
                default:
                    return nil;
            }
        } else {
            return nil;
        }
    }
        reverseBlock:^MUKAttributeValue* _Nullable(id _Nonnull value) {
            NSRange range = [value rangeValue];
            if (range.location == NSNotFound) {
                return nil;
            } else {
                return [[MUKAttributeValue alloc] initWithValue:[NSString stringWithFormat:@"%tu@%tu", range.length, range.location]
                                                 isQuotedString:YES];
            }
        }];
}

#pragma mark - MUKAttributeModel (Override)

- (BOOL)validate:(NSError* _Nullable* _Nullable)error
{
    if (!self.uri) {
        SET_ERROR(error, MUKErrorInvalidMap, @"URI is REQUIRED");
        return NO;
    }
    return YES;
}

@end
