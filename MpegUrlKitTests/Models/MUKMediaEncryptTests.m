//
//  MUKMediaEncryptTests.m
//  MpegUrlKit
//
//  Created by Hinagiku Soranoba on 2017/01/07.
//  Copyright © 2017年 Hinagiku Soranoba. All rights reserved.
//

#import "MUKMediaEncrypt.h"

QuickSpecBegin(MUKMediaEncryptTests)
{
    describe(@"Convert between MUKEncryptMethod and NSString", ^{
        it(@"can convert", ^{
            expect([MUKMediaEncrypt encryptMethodToString:[MUKMediaEncrypt encryptMethodFromString:@"NONE"]]).to(equal(@"NONE"));
            expect([MUKMediaEncrypt encryptMethodToString:[MUKMediaEncrypt encryptMethodFromString:@"AES-128"]]).to(equal(@"AES-128"));
            expect([MUKMediaEncrypt encryptMethodToString:[MUKMediaEncrypt encryptMethodFromString:@"SAMPLE-AES"]]).to(equal(@"SAMPLE-AES"));
            expect([MUKMediaEncrypt encryptMethodToString:[MUKMediaEncrypt encryptMethodFromString:@"other"]]).to(beNil());
        });
    });

    describe(@"validate", ^{
        it(@"return NO, if keyFormatVersions include negative integers", ^{
            MUKMediaEncrypt* encrypt = [[MUKMediaEncrypt alloc] initWithMethod:MUKEncryptSampleAes
                                                                           uri:@"uri"
                                                                            iv:nil
                                                                     keyFormat:@"identity"
                                                             keyFormatVersions:@[ @-1, @2 ]];
            __block NSError* error = nil;
            expect([encrypt validate:&error]).to(equal(NO));
            expect(error.code).to(equal(MUKErrorInvalidEncrypt));
        });

        it(@"return NO, if method isn't NONE and uri is nil", ^{
            MUKMediaEncrypt* encrypt = [[MUKMediaEncrypt alloc] initWithMethod:MUKEncryptSampleAes
                                                                           uri:nil
                                                                            iv:nil
                                                                     keyFormat:@"identity"
                                                             keyFormatVersions:@[ @1, @2 ]];
            __block NSError* error = nil;
            expect([encrypt validate:&error]).to(equal(NO));
            expect(error.code).to(equal(MUKErrorInvalidEncrypt));
        });

        it(@"return YES, when validation succeeded", ^{
            MUKMediaEncrypt* encrypt1 = [[MUKMediaEncrypt alloc] initWithMethod:MUKEncryptNone
                                                                            uri:nil
                                                                             iv:nil
                                                                      keyFormat:nil
                                                              keyFormatVersions:nil];
            __block NSError* error = nil;
            expect([encrypt1 validate:&error]).to(equal(YES));

            unsigned char iv[128];
            memset(iv, 1, 128);

            MUKMediaEncrypt* encrypt2 = [[MUKMediaEncrypt alloc] initWithMethod:MUKEncryptAes128
                                                                            uri:@"uri"
                                                                             iv:[NSData dataWithBytes:iv length:128]
                                                                      keyFormat:@"format"
                                                              keyFormatVersions:@[ @1, @2 ]];
            expect([encrypt2 validate:&error]).to(equal(YES));
        });
    });
}
QuickSpecEnd
