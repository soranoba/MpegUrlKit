//
//  MUKAttributeListTests.m
//  MpegUrlKit
//
//  Created by Hinagiku Soranoba on 2017/01/07.
//  Copyright © 2017年 Hinagiku Soranoba. All rights reserved.
//

#import "MUKAttributeList.h"

QuickSpecBegin(MUKAttributeListTests)
{
    describe(@"MUKAttributeValue # validate:", ^{
        it(@"return YES, when it is correct", ^{
            expect([[[MUKAttributeValue alloc] initWithValue:@"128x256" isQuotedString:NO] validate:nil]).to(equal(YES));
        });

        it(@"return NO, when value include double-quote", ^{
            __block NSError* error = nil;
            expect([[[MUKAttributeValue alloc] initWithValue:@"\"hoge\"" isQuotedString:NO] validate:&error]).to(equal(NO));
            expect(error.code).to(equal(MUKErrorInvalidAttributeList));

            expect([[[MUKAttributeValue alloc] initWithValue:@"\"hoge\"" isQuotedString:YES] validate:&error]).to(equal(NO));
            expect(error.code).to(equal(MUKErrorInvalidAttributeList));
        });

        it(@"return NO, when no quoted-string include comma", ^{
            __block NSError* error = nil;
            expect([[[MUKAttributeValue alloc] initWithValue:@"hoge,fugo" isQuotedString:NO] validate:&error]).to(equal(NO));
            expect(error.code).to(equal(MUKErrorInvalidAttributeList));

            expect([[[MUKAttributeValue alloc] initWithValue:@"hoge,fugo" isQuotedString:YES] validate:&error]).to(equal(YES));
        });

        it(@"return NO, when value include CR and LF", ^{
            __block NSError* error = nil;
            expect([[[MUKAttributeValue alloc] initWithValue:@"\n" isQuotedString:NO] validate:&error]).to(equal(NO));
            expect(error.code).to(equal(MUKErrorInvalidAttributeList));

            expect([[[MUKAttributeValue alloc] initWithValue:@"\n" isQuotedString:YES] validate:&error]).to(equal(NO));
            expect(error.code).to(equal(MUKErrorInvalidAttributeList));

            expect([[[MUKAttributeValue alloc] initWithValue:@"\r" isQuotedString:NO] validate:&error]).to(equal(NO));
            expect(error.code).to(equal(MUKErrorInvalidAttributeList));

            expect([[[MUKAttributeValue alloc] initWithValue:@"\r" isQuotedString:YES] validate:&error]).to(equal(NO));
            expect(error.code).to(equal(MUKErrorInvalidAttributeList));
        });
    });

    describe(@"MUKAttributeValue # scan*", ^{
        it(@"decimal-integer", ^{
            __block NSUInteger integer;
            __block NSError* error;

            MUKAttributeValue* value = [[MUKAttributeValue alloc] initWithValue:@"123" isQuotedString:NO];
            expect([value scanDecimalInteger:&integer error:&error]).to(equal(YES));
            expect(integer).to(equal(123));

            value = [[MUKAttributeValue alloc] initWithValue:[NSString stringWithFormat:@"%lu", NSUIntegerMax]
                                              isQuotedString:NO];
            expect([value scanDecimalInteger:&integer error:&error]).to(equal(YES));
            expect(integer).to(equal(NSUIntegerMax));

            value = [[MUKAttributeValue alloc] initWithValue:@"-1" isQuotedString:NO];
            expect([value scanDecimalInteger:&integer error:&error]).to(equal(NO));
            expect(error.code).to(equal(MUKErrorInvalidType));
        });

        it(@"hexadecimal-sequence", ^{
            __block NSData* data;
            __block NSError* error;

            unsigned char expectedData[3] = { 0x10, 0xfd, 0xe0 };
            unsigned char const* p = expectedData;

            MUKAttributeValue* value = [[MUKAttributeValue alloc] initWithValue:@"0x10Fde" isQuotedString:NO];
            expect([value scanHexadecimal:&data error:&error]).to(equal(YES));
            expect(data.length).to(equal(3));
            expect(memcmp(data.bytes, p, data.length)).to(equal(0));

            value = [[MUKAttributeValue alloc] initWithValue:@"0X10Fde" isQuotedString:NO];
            expect([value scanHexadecimal:&data error:&error]).to(equal(YES));
            expect(data.length).to(equal(3));
            expect(memcmp(data.bytes, p, data.length)).to(equal(0));

            value = [[MUKAttributeValue alloc] initWithValue:@"010Fde" isQuotedString:NO];
            expect([value scanHexadecimal:&data error:&error]).to(equal(NO));
            expect(error.code).to(equal(MUKErrorInvalidType));
        });

        it(@"decimal-floating-point", ^{
            __block double d;
            __block NSError* error;

            MUKAttributeValue* value = [[MUKAttributeValue alloc] initWithValue:@"1.25" isQuotedString:NO];
            expect([value scanDouble:&d error:&error]).to(equal(YES));
            expect(d).to(equal(1.25));

            value = [[MUKAttributeValue alloc] initWithValue:@"-1.25" isQuotedString:NO];
            expect([value scanDouble:&d error:&error]).to(equal(YES));
            expect(d).to(equal(-1.25));

            value = [[MUKAttributeValue alloc] initWithValue:@"2.0150625" isQuotedString:NO];
            expect([value scanDouble:&d error:&error]).to(equal(YES));
            expect(d).to(equal(2.0150625));

            value = [[MUKAttributeValue alloc] initWithValue:@"-1.25d" isQuotedString:NO];
            expect([value scanDouble:&d error:&error]).to(equal(NO));
            expect(error.code).to(equal(MUKErrorInvalidType));
        });

        it(@"decimal-resolution", ^{
            __block CGSize size;
            __block NSError* error;

            MUKAttributeValue* value = [[MUKAttributeValue alloc] initWithValue:@"120x240" isQuotedString:NO];
            expect([value scanDecimalResolution:&size error:&error]).to(equal(YES));
            expect(size.width).to(equal(120));
            expect(size.height).to(equal(240));

            value = [[MUKAttributeValue alloc] initWithValue:@"120X240" isQuotedString:NO];
            expect([value scanDecimalResolution:&size error:&error]).to(equal(NO));
            expect(error.code).to(equal(MUKErrorInvalidType));

            value = [[MUKAttributeValue alloc] initWithValue:@"120x240x320" isQuotedString:NO];
            expect([value scanDecimalResolution:&size error:&error]).to(equal(NO));
            expect(error.code).to(equal(MUKErrorInvalidType));
        });
    });

    describe(@"MUKAttributeList # parseFromString:error:", ^{
        it(@"can parse quoted-string and other string", ^{
            NSString* str = @"ENUM_KEY=ENUM_VALUE,INT_KEY=123,QUOTED_KEY=\"quoted,value\"";
            __block NSError* error = nil;
            __block NSDictionary<NSString*, MUKAttributeValue*>* attributes;
            expect(attributes = [MUKAttributeList parseFromString:str error:&error]).notTo(beNil());
            expect(attributes.count).to(equal(3));
            expect(attributes[@"ENUM_KEY"].isQuotedString).to(equal(NO));
            expect(attributes[@"ENUM_KEY"].value).to(equal(@"ENUM_VALUE"));
            expect(attributes[@"INT_KEY"].isQuotedString).to(equal(NO));
            expect(attributes[@"INT_KEY"].value).to(equal(@"123"));
            expect(attributes[@"QUOTED_KEY"].isQuotedString).to(equal(YES));
            expect(attributes[@"QUOTED_KEY"].value).to(equal(@"quoted,value"));
        });

        it(@"return nil, if key-value pairs is broken", ^{
            NSString* str = @"ENUM_KEY=ENUM_VALUE,INT_KEY";
            __block NSError* error = nil;
            expect([MUKAttributeList parseFromString:str error:&error]).to(beNil());
            expect(error.code).to(equal(MUKErrorInvalidAttributeList));
        });

        it(@"return nil, if quoted-string is broken", ^{
            NSString* str = @"ENUM_KEY=ENUM_VALUE,QUOTED_KEY=\"quoted,value\"..";
            __block NSError* error = nil;
            expect([MUKAttributeList parseFromString:str error:&error]).to(beNil());
            expect(error.code).to(equal(MUKErrorInvalidAttributeList));

            str = @"ENUM_KEY=ENUM_VALUE,QUOTED_KEY=\"quoted,value";
            expect([MUKAttributeList parseFromString:str error:&error]).to(beNil());
            expect(error.code).to(equal(MUKErrorInvalidAttributeList));
        });

        it(@"return nil, if no quoted-string has double-quote", ^{
            NSString* str = @"ENUM_KEY=ENUM_\"VALUE";
            __block NSError* error = nil;
            expect([MUKAttributeList parseFromString:str error:&error]).to(beNil());
            expect(error.code).to(equal(MUKErrorInvalidAttributeList));
        });

        it(@"return nil, if it have duplicate key", ^{
            NSString* str = @"INT_KEY=1,INT_KEY=2";
            __block NSError* error = nil;
            expect([MUKAttributeList parseFromString:str error:&error]).to(beNil());
            expect(error.code).to(equal(MUKErrorInvalidAttributeList));
        });
    });

    describe(@"MUKAttributeList # makeFromDict:error:", ^{
        it(@"can make attribute list, it is correct", ^{
            NSDictionary<NSString*, MUKAttributeValue*>* attributes
                = @{ @"KEY1" : [[MUKAttributeValue alloc] initWithValue:@"123" isQuotedString:NO],
                     @"KEY2" : [[MUKAttributeValue alloc] initWithValue:@"quoted-string" isQuotedString:YES] };

            __block NSError* error = nil;
            __block NSString* str = nil;
            expect(str = [MUKAttributeList makeFromDict:attributes error:&error]).notTo(beNil());
            expect([MUKAttributeList parseFromString:str error:&error]).to(equal(attributes));
            expect(error).to(beNil());
        });
    });
}
QuickSpecEnd
