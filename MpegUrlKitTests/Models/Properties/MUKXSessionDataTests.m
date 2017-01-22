//
//  MUKXSessionDataTests.m
//  MpegUrlKit
//
//  Created by Hinagiku Soranoba on 2017/01/22.
//  Copyright © 2017年 Hinagiku Soranoba. All rights reserved.
//

#import "MUKXSessionData.h"

@interface MUKXSessionData ()
@property (nonatomic, nonnull, copy, readwrite) NSString* dataId;
@property (nonatomic, nullable, copy, readwrite) NSString* value;
@property (nonatomic, nullable, strong, readwrite) NSURL* uri;
@property (nonatomic, nullable, copy, readwrite) NSString* language;
@end

QuickSpecBegin(MUKXSessionDataTests)
{
    describe(@"validate:", ^{
        it(@"DATA-ID is REQUIRED. And, either VALUE or URI is REQUIRED", ^{
            MUKXSessionData* sessionData = [MUKXSessionData new];
            sessionData.dataId = @"DATA-ID";
            sessionData.value = @"value";
            sessionData.uri = [NSURL URLWithString:@"http://host/path1"];

            __block NSError* error = nil;
            expect([sessionData validate:&error]).to(equal(NO));
            expect(error.code).to(equal(MUKErrorInvalidSesseionData));

            error = nil;
            sessionData.value = nil;
            expect([sessionData validate:&error]).to(equal(YES));
            expect(error).to(beNil());

            sessionData.uri = nil;
            sessionData.value = @"value";
            expect([sessionData validate:&error]).to(equal(YES));
            expect(error).to(beNil());

            sessionData = [MUKXSessionData new];
            sessionData.value = @"value";
            expect([sessionData validate:&error]).to(equal(NO));
            expect(error.code).to(equal(MUKErrorInvalidSesseionData));
        });
    });
}
QuickSpecEnd
