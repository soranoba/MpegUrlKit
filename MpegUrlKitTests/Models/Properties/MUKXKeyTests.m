//
//  MUKXKeyTests.m
//  MpegUrlKit
//
//  Created by Hinagiku Soranoba on 2017/01/07.
//  Copyright © 2017年 Hinagiku Soranoba. All rights reserved.
//

#import "MUKXKey.h"

@interface MUKXKey ()
+ (MUKTransformer* _Nonnull)methodTransformer;
+ (MUKTransformer* _Nonnull)keyFormatVersionsTransformer;
@end

QuickSpecBegin(MUKXKeyTests)
{
    describe(@"Convert between MUKXKeyMethod and NSString", ^{
        it(@"can convert", ^{
            expect([MUKXKey keyMethodToString:[MUKXKey keyMethodFromString:@"NONE"]]).to(equal(@"NONE"));
            expect([MUKXKey keyMethodToString:[MUKXKey keyMethodFromString:@"AES-128"]]).to(equal(@"AES-128"));
            expect([MUKXKey keyMethodToString:[MUKXKey keyMethodFromString:@"SAMPLE-AES"]]).to(equal(@"SAMPLE-AES"));
            expect([MUKXKey keyMethodToString:[MUKXKey keyMethodFromString:@"other"]]).to(beNil());
        });
    });

    describe(@"methodTransformer", ^{
        it(@"can convert to enum from string", ^{
            MUKAttributeValue* value = [[MUKAttributeValue alloc] initWithValue:@"NONE" isQuotedString:NO];
            expect([[MUKXKey methodTransformer] transformedValue:value]).to(equal(MUKXKeyMethodNone));

            value = [[MUKAttributeValue alloc] initWithValue:@"AES-128" isQuotedString:NO];
            expect([[MUKXKey methodTransformer] transformedValue:value]).to(equal(MUKXKeyMethodAes128));

            value = [[MUKAttributeValue alloc] initWithValue:@"SAMPLE-AES" isQuotedString:NO];
            expect([[MUKXKey methodTransformer] transformedValue:value]).to(equal(MUKXKeyMethodSampleAes));

            value = [[MUKAttributeValue alloc] initWithValue:@"other" isQuotedString:NO];
            expect([[MUKXKey methodTransformer] transformedValue:value]).to(equal(MUKXKeyMethodUnknown));
        });

        it(@"can convert to string from enum", ^{
            MUKAttributeValue* value = [[MUKAttributeValue alloc] initWithValue:@"NONE" isQuotedString:NO];
            expect([[MUKXKey methodTransformer] reverseTransformedValue:@(MUKXKeyMethodNone)]).to(equal(value));

            value = [[MUKAttributeValue alloc] initWithValue:@"AES-128" isQuotedString:NO];
            expect([[MUKXKey methodTransformer] reverseTransformedValue:@(MUKXKeyMethodAes128)]).to(equal(value));

            value = [[MUKAttributeValue alloc] initWithValue:@"SAMPLE-AES" isQuotedString:NO];
            expect([[MUKXKey methodTransformer] reverseTransformedValue:@(MUKXKeyMethodSampleAes)]).to(equal(value));

            expect([[MUKXKey methodTransformer] reverseTransformedValue:@(MUKXKeyMethodUnknown)]).to(beNil());
        });
    });

    describe(@"keyFormatVersionsTransformer", ^{
        it(@"can convert to array from string", ^{
            MUKAttributeValue* value = [[MUKAttributeValue alloc] initWithValue:@"1/2/3" isQuotedString:YES];
            expect([[MUKXKey keyFormatVersionsTransformer] transformedValue:value]).to(equal(@[ @1, @2, @3 ]));

            value = [[MUKAttributeValue alloc] initWithValue:@"a/b/c" isQuotedString:YES];
            expect([[MUKXKey keyFormatVersionsTransformer] transformedValue:value]).to(beNil());
        });

        it(@"can convert to string from array", ^{
            MUKAttributeValue* value = [[MUKAttributeValue alloc] initWithValue:@"1/2/3" isQuotedString:YES];
            expect([[MUKXKey keyFormatVersionsTransformer] reverseTransformedValue:@[ @1, @2, @3 ]]).to(equal(value));
        });
    });

    describe(@"validate", ^{
        it(@"return NO, if method isn't NONE and uri is nil", ^{
            MUKXKey* encrypt = [[MUKXKey alloc] initWithMethod:MUKXKeyMethodSampleAes
                                                           uri:nil
                                                            iv:nil
                                                     keyFormat:@"identity"
                                             keyFormatVersions:@[ @1, @2 ]];
            __block NSError* error = nil;
            expect([encrypt validate:&error]).to(equal(NO));
            expect(error.code).to(equal(MUKErrorInvalidEncrypt));
        });

        it(@"IV attribute REQUIRES a compatibility version number of 2 or grater", ^{
            expect([MUKXKey minimumAttributeSupportedVersions][@"IV"]).to(equal(@2));
        });

        it(@"KEYFORMAT attribute REQUIRES a compatibility version number of 5 or grater", ^{
            expect([MUKXKey minimumAttributeSupportedVersions][@"KEYFORMAT"]).to(equal(@5));
        });

        it(@"KEYFORMAT absence indicates an implicit value of 'identity'", ^{
            expect([MUKXKey new].keyFormat).to(equal(@"identity"));
        });

        it(@"return NO, if keyFormatVersions include negative integers", ^{
            MUKXKey* encrypt = [[MUKXKey alloc] initWithMethod:MUKXKeyMethodSampleAes
                                                           uri:[NSURL URLWithString:@"uri"]
                                                            iv:nil
                                                     keyFormat:@"identity"
                                             keyFormatVersions:@[ @-1, @2 ]];
            __block NSError* error = nil;
            expect([encrypt validate:&error]).to(equal(NO));
            expect(error.code).to(equal(MUKErrorInvalidEncrypt));
        });

        it(@"KEYFORMATVERSIONS attribute REQUIRES a compatibility version number of 5 or grater", ^{
            expect([MUKXKey minimumAttributeSupportedVersions][@"KEYFORMATVERSIONS"]).to(equal(@5));
        });

        it(@"value is considered to be 1, if KEYFORMATVERSIONS is not present", ^{
            expect([MUKXKey new].keyFormatVersions).to(equal(@[ @1 ]));
        });

        it(@"return YES, when validation succeeded", ^{
            MUKXKey* encrypt1 = [[MUKXKey alloc] initWithMethod:MUKXKeyMethodNone
                                                            uri:nil
                                                             iv:nil
                                                      keyFormat:nil
                                              keyFormatVersions:nil];
            __block NSError* error = nil;
            expect([encrypt1 validate:&error]).to(equal(YES));

            unsigned char iv[128];
            memset(iv, 1, 128);

            MUKXKey* encrypt2 = [[MUKXKey alloc] initWithMethod:MUKXKeyMethodAes128
                                                            uri:[NSURL URLWithString:@"uri"]
                                                             iv:[NSData dataWithBytes:iv length:128]
                                                      keyFormat:@"format"
                                              keyFormatVersions:@[ @1, @2 ]];
            expect([encrypt2 validate:&error]).to(equal(YES));
        });
    });
}
QuickSpecEnd
