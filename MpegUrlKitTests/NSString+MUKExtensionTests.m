//
//  NSString+MUKExtensionTests.m
//  MpegUrlKit
//
//  Created by Hinagiku Soranoba on 2017/01/08.
//  Copyright © 2017年 Hinagiku Soranoba. All rights reserved.
//

#import "NSString+MUKExtension.h"

QuickSpecBegin(NSString_MUKExtensionTests)
{
    describe(@"MUKExtension", ^{
        it(@"stringWithDecimal", ^{
            expect([NSString muk_stringWithDecimal:NSUIntegerMax]).to(equal([NSString stringWithFormat:@"%lu", NSUIntegerMax]));
        });

        it(@"stringHexWithData", ^{
            unsigned char buffer[3] = { 0x1d, 0x34, 0x40 };
            NSData* data = [NSData dataWithBytes:buffer length:3];
            expect([NSString muk_stringHexWithData:data]).to(equal(@"0x1d3440"));
        });

        it(@"stringWithDouble", ^{
            expect([NSString muk_stringWithDouble:2.5]).to(equal(@"2.5"));
            expect([NSString muk_stringWithDouble:-2.5]).to(equal(@"-2.5"));
            expect([NSString muk_stringWithDouble:2.0150625]).to(equal(@"2.0150625"));
        });

        it(@"stringWithSize", ^{
            expect([NSString muk_stringWithSize:CGSizeMake(120, 240)]).to(equal(@"120x240"));
        });

        it(@"stringWithDate", ^{
            __block NSDate* date;
            __block NSError* error;
            expect([@"2010-02-19T14:54:23.031+08:00" muk_scanDate:&date error:&error]).to(equal(YES));

            [NSTimeZone setDefaultTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
            expect([NSString muk_stringWithDate:date]).to(equal(@"2010-02-19T06:54:23.031Z"));
        });
    });

    describe(@"NSString # muk_scan*", ^{
        it(@"decimal-integer", ^{
            __block NSUInteger integer;
            __block NSError* error;

            expect([@"123" muk_scanDecimalInteger:&integer error:&error]).to(equal(YES));
            expect(integer).to(equal(123));

            expect([[NSString stringWithFormat:@"%lu", NSUIntegerMax] muk_scanDecimalInteger:&integer error:&error]).to(equal(YES));
            expect(integer).to(equal(NSUIntegerMax));

            expect([@"-1" muk_scanDecimalInteger:&integer error:&error]).to(equal(NO));
            expect(error.code).to(equal(MUKErrorInvalidType));

            expect([@"1.5" muk_scanDecimalInteger:&integer error:&error]).to(equal(NO));
            expect(error.code).to(equal(MUKErrorInvalidType));

            expect([@"0x12" muk_scanDecimalInteger:&integer error:&error]).to(equal(NO));
            expect(error.code).to(equal(MUKErrorInvalidType));
        });

        it(@"hexadecimal-sequence", ^{
            __block NSData* data;
            __block NSError* error;

            unsigned char expectedData[3] = { 0x10, 0xfd, 0xe0 };
            unsigned char const* p = expectedData;

            expect([@"0x10Fde" muk_scanHexadecimal:&data error:&error]).to(equal(YES));
            expect(data.length).to(equal(3));
            expect(memcmp(data.bytes, p, data.length)).to(equal(0));

            expect([@"0X10Fde" muk_scanHexadecimal:&data error:&error]).to(equal(YES));
            expect(data.length).to(equal(3));
            expect(memcmp(data.bytes, p, data.length)).to(equal(0));

            expect([@"010Fde" muk_scanHexadecimal:&data error:&error]).to(equal(NO));
            expect(error.code).to(equal(MUKErrorInvalidType));
        });

        it(@"decimal-floating-point", ^{
            __block double d;
            __block NSError* error;

            expect([@"1.25" muk_scanDouble:&d error:&error]).to(equal(YES));
            expect(d).to(equal(1.25));

            expect([@"-1.25" muk_scanDouble:&d error:&error]).to(equal(YES));
            expect(d).to(equal(-1.25));

            expect([@"2.0150625" muk_scanDouble:&d error:&error]).to(equal(YES));
            expect(d).to(equal(2.0150625));

            expect([@"-1.25d" muk_scanDouble:&d error:&error]).to(equal(NO));
            expect(error.code).to(equal(MUKErrorInvalidType));

            expect([@"-1" muk_scanDouble:&d error:&error]).to(equal(YES));
            expect(d).to(equal(-1));
        });

        it(@"decimal-resolution", ^{
            __block CGSize size;
            __block NSError* error;

            expect([@"120x240" muk_scanDecimalResolution:&size error:&error]).to(equal(YES));
            expect(size.width).to(equal(120));
            expect(size.height).to(equal(240));

            expect([@"120X240" muk_scanDecimalResolution:&size error:&error]).to(equal(NO));
            expect(error.code).to(equal(MUKErrorInvalidType));

            expect([@"120x240x320" muk_scanDecimalResolution:&size error:&error]).to(equal(NO));
            expect(error.code).to(equal(MUKErrorInvalidType));

            expect([@"120.5x240.5" muk_scanDecimalResolution:&size error:&error]).to(equal(NO));
            expect(error.code).to(equal(MUKErrorInvalidType));
        });

        it(@"iso-8601 date format", ^{
            __block NSDate *date1, *date2;
            __block NSError* error;
            expect([@"2010-02-19T05:54:23.031-01" muk_scanDate:&date1 error:&error]).to(equal(YES));
            expect([@"2010-02-19T15:54:23.031+09:00" muk_scanDate:&date2 error:&error]).to(equal(YES));
            expect(date1).to(equal(date2));

            expect([@"2010-02-19T06:54:23.031Z" muk_scanDate:&date2 error:&error]).to(equal(YES));
            expect(date1).to(equal(date2));

            expect([@"2010-02-19T06:54:23,0310Z" muk_scanDate:&date2 error:&error]).to(equal(YES));
            expect(date1).to(equal(date2));

            expect([@"2010-02-19T06:54:23,0310000Z" muk_scanDate:&date2 error:&error]).to(equal(YES));
            expect(date1).to(equal(date2));

            expect([@"2010-02-19 14:54:23.031+08:00" muk_scanDate:&date1 error:&error]).to(equal(NO));
            expect(error.code).to(equal(MUKErrorInvalidType));
        });
    });
}
QuickSpecEnd
