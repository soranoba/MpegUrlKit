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

@interface MUKXDateRange ()

@property (nonatomic, nonnull, copy, readwrite) NSString* identify;
@property (nonatomic, nullable, copy, readwrite) NSString* klass;
@property (nonatomic, nonnull, strong, readwrite) NSDate* startDate;
@property (nonatomic, nullable, strong, readwrite) NSDate* endDate;
@property (nonatomic, assign, readwrite) NSTimeInterval duration;
@property (nonatomic, assign, readwrite) NSTimeInterval plannedDuration;
@property (nonatomic, assign, readwrite) BOOL isEndOnNext;
@property (nonatomic, nullable, copy, readwrite) NSData* scte35Cmd;
@property (nonatomic, nullable, copy, readwrite) NSData* scte35Out;
@property (nonatomic, nullable, copy, readwrite) NSData* scte35In;
@property (nonatomic, nonnull, copy, readwrite) NSDictionary<NSString*, MUKAttributeValue*>* userDefinedAttributes;

@end

@implementation MUKXDateRange

#pragma mark - Lifecycle

- (instancetype _Nonnull)initWithId:(NSString* _Nonnull)identify
                              klass:(NSString* _Nullable)klass
                              start:(NSDate* _Nonnull)startDate
                                end:(NSDate* _Nullable)endDate
                           duration:(NSTimeInterval)duration
                    plannedDuration:(NSTimeInterval)plannedDuration
                        isEndOnNext:(BOOL)isEndOnNext
                          scte35Cmd:(NSData* _Nullable)scte35Cmd
                          scte35Out:(NSData* _Nullable)scte35Out
                           scte35In:(NSData* _Nullable)scte35In
              userDefinedAttributes:(NSDictionary<NSString*, MUKAttributeValue*>* _Nullable)userDefinedAttributes
{
    NSParameterAssert(identify != nil && startDate != nil);

    if (self = [super init]) {
        self.identify = identify;
        self.klass = klass;
        self.startDate = startDate;
        self.endDate = endDate;
        self.duration = duration;
        self.plannedDuration = plannedDuration;
        self.isEndOnNext = isEndOnNext;
        self.scte35Cmd = scte35Cmd;
        self.scte35Out = scte35Out;
        self.scte35In = scte35In;
        self.userDefinedAttributes = userDefinedAttributes ?: [NSDictionary dictionary];
    }
    return self;
}

#pragma mark - Public Methods

- (BOOL)validate:(NSError* _Nullable* _Nullable)error
{
    if (self.isEndOnNext && !self.klass) {
        SET_ERROR(error, MUKErrorInvalidDateRange, @"If it has END-ON-NEXT, CLASS MUST NOT be contained");
        return NO;
    }
    if (self.isEndOnNext && (self.duration >= 0 || self.endDate)) {
        SET_ERROR(error, MUKErrorInvalidDateRange, @"If it has END-ON-NEXT, DURATION and END-DATE MUST NOT be contained");
        return NO;
    }
    if (!self.endDate && self.duration >= 0 && [self.startDate timeIntervalSinceDate:self.endDate] != self.duration) {
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
