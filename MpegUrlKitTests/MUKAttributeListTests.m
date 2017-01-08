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
