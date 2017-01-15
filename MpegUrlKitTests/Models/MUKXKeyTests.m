//
//  MUKXKeyTests.m
//  MpegUrlKit
//
//  Created by Hinagiku Soranoba on 2017/01/07.
//  Copyright © 2017年 Hinagiku Soranoba. All rights reserved.
//

#import "MUKXKey.h"

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

    describe(@"validate", ^{
        it(@"return NO, if keyFormatVersions include negative integers", ^{
            MUKXKey* encrypt = [[MUKXKey alloc] initWithMethod:MUKXKeyMethodSampleAes
                                                           uri:@"uri"
                                                            iv:nil
                                                     keyFormat:@"identity"
                                             keyFormatVersions:@[ @-1, @2 ]];
            __block NSError* error = nil;
            expect([encrypt validate:&error]).to(equal(NO));
            expect(error.code).to(equal(MUKErrorInvalidEncrypt));
        });

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
                                                            uri:@"uri"
                                                             iv:[NSData dataWithBytes:iv length:128]
                                                      keyFormat:@"format"
                                              keyFormatVersions:@[ @1, @2 ]];
            expect([encrypt2 validate:&error]).to(equal(YES));
        });
    });
}
QuickSpecEnd
