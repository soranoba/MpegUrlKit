//
//  MUKAttributeValue.m
//  MpegUrlKit
//
//  Created by Hinagiku Soranoba on 2017/01/07.
//  Copyright © 2017年 Hinagiku Soranoba. All rights reserved.
//

#import "MUKAttributeValue.h"
#import "MUKConsts.h"
#import "NSError+MUKErrorDomain.h"

@interface MUKAttributeValue ()

@property (nonatomic, assign, readwrite) BOOL isQuotedString;
@property (nonatomic, nonnull, copy, readwrite) NSString* value;

@end

@implementation MUKAttributeValue

#pragma mark - Lifecycle

- (instancetype _Nonnull)initWithValue:(NSString* _Nonnull)value
                        isQuotedString:(BOOL)isQuotedString
{
    NSParameterAssert(value != nil);

    if (self = [super init]) {
        self.isQuotedString = isQuotedString;
        self.value = value;
    }
    return self;
}

#pragma mark - Public Methods

- (BOOL)validate:(NSError* _Nullable* _Nullable)error
{
    for (NSUInteger i = 0; i < self.value.length; i++) {
        switch ([self.value characterAtIndex:i]) {
            case '"':
            case '\r':
            case '\n':
                SET_ERROR(error, MUKErrorInvalidAttributeList,
                          @"It MUST NOT include double quotes, CR and LF");
                return NO;
            case ',':
                if (!self.isQuotedString) {
                    SET_ERROR(error, MUKErrorInvalidAttributeList,
                              @"It MUST NOT include commas, when it is not quoted-string.");
                    return NO;
                }
            default:
                break; // NOP
        }
    }
    return YES;
}

#pragma mark - NSObject (Overwrite)

- (BOOL)isEqual:(id _Nullable)object
{
    if ([object isKindOfClass:self.class]) {
        typeof(self) anotherValue = object;
        return self.isQuotedString == anotherValue.isQuotedString && [self.value isEqualToString:anotherValue.value];
    }
    return NO;
}

@end
