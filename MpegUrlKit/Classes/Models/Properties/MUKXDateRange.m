//
//  MUKDateRange.m
//  MpegUrlKit
//
//  Created by Hinagiku Soranoba on 2017/01/08.
//  Copyright © 2017年 Hinagiku Soranoba. All rights reserved.
//

#import "MUKXDateRange.h"
#import "MUKConsts.h"
#import "NSError+MUKErrorDomain.h"
#import "NSString+MUKExtension.h"

@interface MUKXDateRange ()

@property (nonatomic, nonnull, copy, readwrite) NSString* identifier;
@property (nonatomic, nullable, copy, readwrite) NSString* klass;
@property (nonatomic, nonnull, strong, readwrite) NSDate* startDate;
@property (nonatomic, nullable, strong, readwrite) NSDate* endDate;
@property (nonatomic, nullable, strong, readwrite) NSNumber* duration;
@property (nonatomic, nullable, strong, readwrite) NSNumber* plannedDuration;
@property (nonatomic, assign, readwrite, getter=isEndOnNext) BOOL endOnNext;
@property (nonatomic, nullable, copy, readwrite) NSData* scte35Cmd;
@property (nonatomic, nullable, copy, readwrite) NSData* scte35Out;
@property (nonatomic, nullable, copy, readwrite) NSData* scte35In;
@property (nonatomic, nonnull, copy, readwrite) NSDictionary<NSString*, MUKAttributeValue*>* userDefinedAttributes;

@end

@implementation MUKXDateRange

#pragma mark - Lifecycle

- (instancetype _Nonnull)initWithId:(NSString* _Nonnull)identifier
                              klass:(NSString* _Nullable)klass
                              start:(NSDate* _Nonnull)startDate
                                end:(NSDate* _Nullable)endDate
                           duration:(NSNumber* _Nullable)duration
                    plannedDuration:(NSNumber* _Nullable)plannedDuration
                        isEndOnNext:(BOOL)isEndOnNext
                          scte35Cmd:(NSData* _Nullable)scte35Cmd
                          scte35Out:(NSData* _Nullable)scte35Out
                           scte35In:(NSData* _Nullable)scte35In
              userDefinedAttributes:(NSDictionary<NSString*, MUKAttributeValue*>* _Nullable)userDefinedAttributes
{
    NSParameterAssert(identifier != nil && startDate != nil);

    if (self = [super init]) {
        self.identifier = identifier;
        self.klass = klass;
        self.startDate = startDate;
        self.endDate = endDate;
        self.duration = duration;
        self.plannedDuration = plannedDuration;
        self.endOnNext = isEndOnNext;
        self.scte35Cmd = scte35Cmd;
        self.scte35Out = scte35Out;
        self.scte35In = scte35In;
        self.userDefinedAttributes = userDefinedAttributes ?: [NSDictionary dictionary];
    }
    return self;
}

#pragma mark - MUKAttributeSerializing

+ (NSDictionary<NSString*, NSString*>* _Nonnull)propertyByAttributeKey
{
    return @{ @"ID" : @"identifier",
              @"CLASS" : @"klass",
              @"START-DATE" : @"startDate",
              @"END-DATE" : @"endDate",
              @"DURATION" : @"duration",
              @"PLANNED-DURATION" : @"plannedDuration",
              @"END-ON-NEXT" : @"endOnNext",
              @"SCTE35-CMD" : @"scte35cmd",
              @"SCTE35-OUT" : @"scte35Out",
              @"SCTE35-IN" : @"scte35In" };
}

+ (MUKTransformer* _Nonnull)durationTransformer
{
    return [MUKTransformer transformerWithBlock:^id _Nullable(MUKAttributeValue* _Nonnull value) {
        if (value.isQuotedString) {
            return nil;
        } else {
            double d;
            if (![value.value muk_scanDouble:&d error:nil]) {
                return nil;
            }
            return @(d);
        }
    }
        reverseBlock:^MUKAttributeValue* _Nullable(id _Nonnull value) {
            NSParameterAssert([value isKindOfClass:NSNumber.class]);

            NSString* str = [NSString muk_stringWithDouble:[value doubleValue]];
            if (!str) {
                return nil;
            }
            return [[MUKAttributeValue alloc] initWithValue:str isQuotedString:NO];
        }];
}

+ (MUKTransformer* _Nonnull)plannedDurationTransformer
{
    return [self durationTransformer];
}

+ (MUKTransformer* _Nonnull)endOnNextTransformer
{
    return [MUKTransformer transformerWithBlock:^id _Nullable(MUKAttributeValue* _Nonnull value) {
        if (value.isQuotedString) {
            return nil;
        } else {
            if ([value.value isEqualToString:@"YES"]) {
                return @YES;
            } else {
                return nil;
            }
        }
    }];
}

- (BOOL)finalizeOfFromStringWithAttributes:(NSDictionary<NSString*, MUKAttributeValue*>* _Nonnull)attributes
                                     error:(NSError* _Nullable* _Nullable)error
{
    NSMutableDictionary<NSString*, MUKAttributeValue*>* userDefinedAttributes = [NSMutableDictionary dictionary];
    for (NSString* key in attributes) {
        if ([key hasPrefix:@"X-"]) {
            userDefinedAttributes[key] = attributes[key];
        }
    }
    self.userDefinedAttributes = userDefinedAttributes;
    return YES;
}

#pragma mark - MUKAttributeModel (Override)

- (BOOL)validate:(NSError* _Nullable* _Nullable)error
{
    if (!self.identifier) {
        SET_ERROR(error, MUKErrorInvalidDateRange, @"ID is REQUIRED");
        return NO;
    }

    if (!self.startDate) {
        SET_ERROR(error, MUKErrorInvalidDateRange, @"START-DATE is REQUIRED");
        return NO;
    }

    if (self.endDate && [self.startDate compare:self.endDate] == NSOrderedDescending) {
        SET_ERROR(error, MUKErrorInvalidDateRange, @"END-DATE MUST be later than START-DATE");
        return NO;
    }

    if (self.duration && [self.duration doubleValue] < 0) {
        SET_ERROR(error, MUKErrorInvalidDateRange, @"DURATION MUST NOT be negative");
        return NO;
    }

    if (self.plannedDuration && [self.plannedDuration doubleValue] < 0) {
        SET_ERROR(error, MUKErrorInvalidDateRange, @"PLANNED-DURATION MUST NOT be negative");
        return NO;
    }

    if (self.isEndOnNext && !self.klass) {
        SET_ERROR(error, MUKErrorInvalidDateRange, @"If it has END-ON-NEXT, CLASS is REQUIRED");
        return NO;
    }

    if (self.isEndOnNext && (self.duration > 0 || self.endDate)) {
        SET_ERROR(error, MUKErrorInvalidDateRange, @"If it has END-ON-NEXT, DURATION and END-DATE MUST NOT be contained");
        return NO;
    }

    if (self.endDate && self.duration && [self.endDate timeIntervalSinceDate:self.startDate] != [self.duration doubleValue]) {
        SET_ERROR(error, MUKErrorInvalidDateRange,
                  @"If it contains both END-DATE and DURATION, it MUST equals START-DATE + duration == END-DATE");
        return NO;
    }

    for (NSString* key in self.userDefinedAttributes) {
        if (![key hasPrefix:@"X-"]) {
            SET_ERROR(error, MUKErrorInvalidDateRange, @"User definied attributes MUST prefix 'X-'");
            return NO;
        }
    }
    return YES;
}

@end
