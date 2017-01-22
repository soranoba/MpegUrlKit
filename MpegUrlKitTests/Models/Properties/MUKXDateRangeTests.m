//
//  MUKXDateRangeTests.m
//  MpegUrlKit
//
//  Created by Hinagiku Soranoba on 2017/01/21.
//  Copyright © 2017年 Hinagiku Soranoba. All rights reserved.
//

#import "MUKXDateRange.h"

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

+ (MUKTransformer* _Nonnull)durationTransformer;
+ (MUKTransformer* _Nonnull)plannedDurationTransformer;
+ (MUKTransformer* _Nonnull)endOnNextTransformer;
@end

QuickSpecBegin(MUKXDataRangeTests)
{
    describe(@"durationTransformer", ^{
        it(@"can convert to number from string", ^{
            MUKAttributeValue* value = [[MUKAttributeValue alloc] initWithValue:@"2.5" isQuotedString:NO];
            expect([[MUKXDateRange durationTransformer] transformedValue:value]).to(equal(@2.5));

            value = [[MUKAttributeValue alloc] initWithValue:@"2" isQuotedString:NO];
            expect([[MUKXDateRange durationTransformer] transformedValue:value]).to(equal(@2));

            value = [[MUKAttributeValue alloc] initWithValue:@"2" isQuotedString:YES];
            expect([[MUKXDateRange durationTransformer] transformedValue:value]).to(beNil());
        });

        it(@"can convert to string from number", ^{
            MUKAttributeValue* value = [[MUKAttributeValue alloc] initWithValue:@"2.5" isQuotedString:NO];
            expect([[MUKXDateRange durationTransformer] reverseTransformedValue:@2.5]).to(equal(value));

            value = [[MUKAttributeValue alloc] initWithValue:@"2" isQuotedString:NO];
            expect([[MUKXDateRange durationTransformer] reverseTransformedValue:@2]).to(equal(value));
        });
    });

    describe(@"plannedDurationTransformer", ^{
        it(@"can convert to number from string", ^{
            MUKAttributeValue* value = [[MUKAttributeValue alloc] initWithValue:@"2.5" isQuotedString:NO];
            expect([[MUKXDateRange plannedDurationTransformer] transformedValue:value]).to(equal(@2.5));

            value = [[MUKAttributeValue alloc] initWithValue:@"2" isQuotedString:NO];
            expect([[MUKXDateRange plannedDurationTransformer] transformedValue:value]).to(equal(@2));

            value = [[MUKAttributeValue alloc] initWithValue:@"2" isQuotedString:YES];
            expect([[MUKXDateRange plannedDurationTransformer] transformedValue:value]).to(beNil());
        });

        it(@"can convert to string from number", ^{
            MUKAttributeValue* value = [[MUKAttributeValue alloc] initWithValue:@"2.5" isQuotedString:NO];
            expect([[MUKXDateRange plannedDurationTransformer] reverseTransformedValue:@2.5]).to(equal(value));

            value = [[MUKAttributeValue alloc] initWithValue:@"2" isQuotedString:NO];
            expect([[MUKXDateRange plannedDurationTransformer] reverseTransformedValue:@2]).to(equal(value));
        });
    });

    describe(@"endOnNextTransformer", ^{
        it(@"can convert to bool from YES", ^{
            MUKAttributeValue* value = [[MUKAttributeValue alloc] initWithValue:@"YES" isQuotedString:NO];
            expect([[MUKXDateRange endOnNextTransformer] transformedValue:value]).to(equal(@YES));

            value = [[MUKAttributeValue alloc] initWithValue:@"NO" isQuotedString:NO];
            expect([[MUKXDateRange endOnNextTransformer] transformedValue:value]).to(beNil());
        });

        it(@"endOnNextTransformer does not have reverse block (it means default transform)", ^{
            expect([[MUKXDateRange endOnNextTransformer] hasReverseTransformBlock]).to(equal(NO));
        });
    });

    describe(@"validate:", ^{
        __block MUKXDateRange* gDateRange;

        beforeEach(^{
            gDateRange = [MUKXDateRange new];
            gDateRange.identifier = @"ID";
            gDateRange.startDate = [NSDate date];
        });

        it(@"ID and START-DATE is REQUIRED", ^{
            MUKXDateRange* dateRange = [MUKXDateRange new];
            __block NSError* error = nil;

            expect([dateRange validate:&error]).to(equal(NO));
            expect(error.code).to(equal(MUKErrorInvalidDateRange));

            error = nil;
            dateRange.identifier = @"ID";
            expect([dateRange validate:&error]).to(equal(NO));
            expect(error.code).to(equal(MUKErrorInvalidDateRange));

            error = nil;
            dateRange.startDate = [NSDate date];
            expect([dateRange validate:&error]).to(equal(YES));
            expect(error).to(beNil());
        });

        it(@"END-DATE MUST be equal to or later than START-DATE", ^{
            MUKXDateRange* dateRange = [MUKXDateRange new];
            dateRange.identifier = @"ID";
            dateRange.startDate = [NSDate date];
            dateRange.endDate = [NSDate dateWithTimeInterval:-1 sinceDate:dateRange.startDate];

            __block NSError* error = nil;
            expect([dateRange validate:&error]).to(equal(NO));
            expect(error.code).to(equal(MUKErrorInvalidDateRange));

            dateRange.endDate = dateRange.startDate;
            error = nil;
            expect([dateRange validate:&error]).to(equal(YES));
            expect(error).to(beNil());
        });

        it(@"DURATION MUST NOT be negative", ^{
            gDateRange.duration = @(-1.0);

            __block NSError* error = nil;
            expect([gDateRange validate:&error]).to(equal(NO));
            expect(error.code).to(equal(MUKErrorInvalidDateRange));

            gDateRange.duration = @(0.0);
            error = nil;
            expect([gDateRange validate:&error]).to(equal(YES));
            expect(error).to(beNil());
        });

        it(@"PLANNED-DURATION NOT be negative", ^{
            gDateRange.plannedDuration = @(-1.0);

            __block NSError* error = nil;
            expect([gDateRange validate:&error]).to(equal(NO));
            expect(error.code).to(equal(MUKErrorInvalidDateRange));

            gDateRange.plannedDuration = @(0.0);
            error = nil;
            expect([gDateRange validate:&error]).to(equal(YES));
            expect(error).to(beNil());
        });

        it(@"X-<client-atribute> MUST have prefix `X-`", ^{
            gDateRange.userDefinedAttributes = @{ @"X-A" : [[MUKAttributeValue alloc] initWithValue:@"a-value" isQuotedString:YES] };

            __block NSError* error = nil;
            expect([gDateRange validate:&error]).to(equal(YES));
            expect(error).to(beNil());

            gDateRange.userDefinedAttributes = @{ @"A" : [[MUKAttributeValue alloc] initWithValue:@"a-value" isQuotedString:YES] };
            error = nil;
            expect([gDateRange validate:&error]).to(equal(NO));
            expect(error.code).to(equal(MUKErrorInvalidDateRange));
        });

        it(@"If END-ON-NEXT is YES, CLASS is REQUIRED", ^{
            gDateRange.endOnNext = YES;
            gDateRange.klass = @"CLASS";

            __block NSError* error = nil;
            expect([gDateRange validate:&error]).to(equal(YES));
            expect(error).to(beNil());

            gDateRange.klass = nil;
            expect([gDateRange validate:&error]).to(equal(NO));
            expect(error.code).to(equal(MUKErrorInvalidDateRange));
        });

        it(@"If END-ON-NEXT is YES, DURATION and END-DATE MUST NOT contained", ^{
            gDateRange.endOnNext = YES;
            gDateRange.klass = @"CLASS";
            gDateRange.duration = @(1.0);

            __block NSError* error = nil;
            expect([gDateRange validate:&error]).to(equal(NO));
            expect(error.code).to(equal(MUKErrorInvalidDateRange));

            error = nil;
            gDateRange.duration = nil;
            gDateRange.endDate = gDateRange.startDate;
            expect([gDateRange validate:&error]).to(equal(NO));
            expect(error.code).to(equal(MUKErrorInvalidDateRange));

            error = nil;
            gDateRange.endDate = nil;
            expect([gDateRange validate:&error]).to(equal(YES));
            expect(error).to(beNil());
        });
    });
}
QuickSpecEnd
