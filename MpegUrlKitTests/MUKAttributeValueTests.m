//
//  MUKAttributeValueTests.m
//  MpegUrlKit
//
//  Created by Hinagiku Soranoba on 2017/01/07.
//  Copyright © 2017年 Hinagiku Soranoba. All rights reserved.
//

#import "MUKAttributeValue.h"

QuickSpecBegin(MUKAttributeValueTests)
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

    describe(@"isEqual:", ^{
        it(@"return YES, when isQuotedString is equal and value is equal", ^{
            MUKAttributeValue* v1 = [[MUKAttributeValue alloc] initWithValue:@"hoge" isQuotedString:YES];
            MUKAttributeValue* v2 = [[MUKAttributeValue alloc] initWithValue:@"hoge" isQuotedString:NO];
            MUKAttributeValue* v3 = [[MUKAttributeValue alloc] initWithValue:@"fugo" isQuotedString:YES];
            MUKAttributeValue* v4 = [[MUKAttributeValue alloc] initWithValue:@"fugo" isQuotedString:NO];
            MUKAttributeValue* v5 = [[MUKAttributeValue alloc] initWithValue:@"hoge" isQuotedString:YES];

            expect(v1).notTo(equal(v2));
            expect(v1).notTo(equal(v3));
            expect(v1).notTo(equal(v4));
            expect(v1).to(equal(v5));
        });
    });
}
QuickSpecEnd
