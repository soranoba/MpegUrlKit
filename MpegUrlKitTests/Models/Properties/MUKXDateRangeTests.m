//
//  MUKXDateRangeTests.m
//  MpegUrlKit
//
//  Created by Hinagiku Soranoba on 2017/01/21.
//  Copyright © 2017年 Hinagiku Soranoba. All rights reserved.
//

#import "MUKXDateRange.h"

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

QuickSpecBegin(MUKXDataRangeTests)
{
    describe(@"validate:", ^{
        it(@"ID and START-DATE is REQUIRED", ^{
            MUKXDateRange* dateRange = [MUKXDateRange new];
            __block NSError* error = nil;

            expect([dateRange validate:&error]).to(equal(NO));
            expect(error.code).to(equal(MUKErrorInvalidDateRange));

            error = nil;
            dateRange.identify = @"ID";
            expect([dateRange validate:&error]).to(equal(NO));
            expect(error.code).to(equal(MUKErrorInvalidDateRange));

            error = nil;
            dateRange.startDate = [NSDate date];
            expect([dateRange validate:&error]).to(equal(YES));
            expect(error).to(beNil());
        });

        it(@"END-DATE MUST be equal to or later than START-DATE", ^{
            MUKXDateRange* dateRange = [MUKXDateRange new];
            dateRange.identify = @"ID";
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
    });
}
QuickSpecEnd
