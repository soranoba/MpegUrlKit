//
//  MUKXStreamInfTests.m
//  MpegUrlKit
//
//  Created by Hinagiku Soranoba on 2017/01/22.
//  Copyright © 2017年 Hinagiku Soranoba. All rights reserved.
//

#import "MUKXStreamInf.h"

@interface MUKXStreamInf ()
@property (nonatomic, assign, readwrite) NSUInteger maxBitrate;
@property (nonatomic, assign, readwrite) NSUInteger averageBitrate;
@property (nonatomic, nullable, copy, readwrite) NSArray<NSString*>* codecs;
@property (nonatomic, assign, readwrite) CGSize resolution;
@property (nonatomic, assign, readwrite) double maxFrameRate;
@property (nonatomic, assign, readwrite) MUKXStreamInfHdcpLevel hdcpLevel;
@property (nonatomic, nullable, copy, readwrite) NSString* audioGroupId;
@property (nonatomic, nullable, copy, readwrite) NSString* videoGroupId;
@property (nonatomic, nullable, copy, readwrite) NSString* subtitlesGroupId;
@property (nonatomic, nullable, copy, readwrite) NSString* closedCaptionsGroupId;
@property (nonatomic, nonnull, copy, readwrite) NSURL* uri;

+ (MUKTransformer* _Nonnull)codecsTransformer;
+ (MUKTransformer* _Nonnull)hdcpLevelTransformer;
+ (MUKTransformer* _Nonnull)closedCaptionGroupIdTransformer;
@end

QuickSpecBegin(MUKXStreamInfTests)
{
    describe(@"hdcpLevelFromString:", ^{
        it(@"can convert to enum from string", ^{
            expect(@([MUKXStreamInf hdcpLevelFromString:@"NONE"])).to(equal(MUKXStreamInfHdcpLevelNone));
            expect(@([MUKXStreamInf hdcpLevelFromString:@"TYPE-0"])).to(equal(MUKXStreamInfHdcpLevelType0));
            expect(@([MUKXStreamInf hdcpLevelFromString:@"other"])).to(equal(MUKXStreamInfHdcpLevelUnknown));
        });
    });

    describe(@"hdcpLevelToString:", ^{
        it(@"can convert to string from enum", ^{
            expect([MUKXStreamInf hdcpLevelToString:MUKXStreamInfHdcpLevelNone]).to(equal(@"NONE"));
            expect([MUKXStreamInf hdcpLevelToString:MUKXStreamInfHdcpLevelType0]).to(equal(@"TYPE-0"));
            expect([MUKXStreamInf hdcpLevelToString:MUKXStreamInfHdcpLevelUnknown]).to(beNil());
        });
    });

    describe(@"finalizeOfToString:", ^{
        it(@"append the URI to the next line", ^{
            MUKXStreamInf* inf = [MUKXStreamInf new];
            inf.uri = [NSURL URLWithString:@"http://host/path1"];

            expect([inf finalizeOfToString:@"attribute" error:nil]).to(equal(@"attribute\nhttp://host/path1"));
        });
    });

    describe(@"codecsTransformer", ^{
        it(@"can convert to array from string", ^{
            MUKAttributeValue* value = [[MUKAttributeValue alloc] initWithValue:@"a,b" isQuotedString:YES];
            expect([[MUKXStreamInf codecsTransformer] transformedValue:value]).to(equal(@[ @"a", @"b" ]));

            value = [[MUKAttributeValue alloc] initWithValue:@"a,b" isQuotedString:NO];
            expect([[MUKXStreamInf codecsTransformer] transformedValue:value]).to(beNil());
        });

        it(@"can convert to string from array", ^{
            MUKAttributeValue* value = [[MUKAttributeValue alloc] initWithValue:@"a,b" isQuotedString:YES];
            expect([[MUKXStreamInf codecsTransformer] reverseTransformedValue:@[ @"a", @"b" ]]).to(equal(value));

            expect([[MUKXStreamInf codecsTransformer] reverseTransformedValue:@[]]).to(beNil());
        });
    });

    describe(@"hdcpLevelTransformer", ^{
        it(@"can convert to enum from string", ^{
            MUKAttributeValue* value = [[MUKAttributeValue alloc] initWithValue:@"NONE" isQuotedString:NO];
            expect([[MUKXStreamInf hdcpLevelTransformer] transformedValue:value]).to(equal(MUKXStreamInfHdcpLevelNone));

            value = [[MUKAttributeValue alloc] initWithValue:@"TYPE-0" isQuotedString:NO];
            expect([[MUKXStreamInf hdcpLevelTransformer] transformedValue:value]).to(equal(MUKXStreamInfHdcpLevelType0));

            value = [[MUKAttributeValue alloc] initWithValue:@"other" isQuotedString:NO];
            expect([[MUKXStreamInf hdcpLevelTransformer] transformedValue:value]).to(beNil());
        });

        it(@"can convert to string from enum", ^{
            MUKAttributeValue* value = [[MUKAttributeValue alloc] initWithValue:@"NONE" isQuotedString:NO];
            expect([[MUKXStreamInf hdcpLevelTransformer] reverseTransformedValue:@(MUKXStreamInfHdcpLevelNone)]).to(equal(value));

            value = [[MUKAttributeValue alloc] initWithValue:@"TYPE-0" isQuotedString:NO];
            expect([[MUKXStreamInf hdcpLevelTransformer] reverseTransformedValue:@(MUKXStreamInfHdcpLevelType0)]).to(equal(value));

            expect([[MUKXStreamInf hdcpLevelTransformer] reverseTransformedValue:@(MUKXStreamInfHdcpLevelUnknown)]).to(beNil());
        });
    });

    describe(@"closedCaptionGroupIdTransformer", ^{
        it(@"can convert to string from string (attribute value)", ^{
            MUKAttributeValue* value = [[MUKAttributeValue alloc] initWithValue:@"hoge" isQuotedString:YES];
            expect([[MUKXStreamInf closedCaptionGroupIdTransformer] transformedValue:value]).to(equal(@"hoge"));

            value = [[MUKAttributeValue alloc] initWithValue:@"hoge" isQuotedString:NO];
            expect([[MUKXStreamInf closedCaptionGroupIdTransformer] transformedValue:value]).to(beNil());
        });

        it(@"can convert to nil from NONE (enum-string)", ^{
            MUKAttributeValue* value = [[MUKAttributeValue alloc] initWithValue:@"NONE" isQuotedString:NO];
            expect([[MUKXStreamInf closedCaptionGroupIdTransformer] transformedValue:value]).to(equal([NSNull new]));
        });

        it(@"does not have reverse block (it means default transform)", ^{
            expect([[MUKXStreamInf closedCaptionGroupIdTransformer] hasReverseTransformBlock]).to(equal(NO));
        });
    });

    describe(@"validate:", ^{
        __block MUKXStreamInf* gInf;

        beforeEach(^{
            gInf = [MUKXStreamInf new];
            gInf.maxBitrate = 10000;
            gInf.uri = [NSURL URLWithString:@"http://host/path1"];
        });

        it(@"BANDWIDTH is REQUIRED", ^{
            MUKXStreamInf* inf = [MUKXStreamInf new];
            __block NSError* error = nil;

            expect([inf validate:&error]).to(equal(NO));
            expect(error.code).to(equal(MUKErrorInvalidStreamInf));

            error = nil;
            inf.maxBitrate = 1000;
            expect([inf validate:&error]).to(equal(YES));
            expect(error).to(beNil());
        });

        it(@"AVERAGE-BIRATE MUST be less than or equal to BITRATE", ^{
            __block NSError* error = nil;
            gInf.averageBitrate = gInf.maxBitrate;

            expect([gInf validate:&error]).to(equal(YES));
            expect(error).to(beNil());

            gInf.averageBitrate = gInf.maxBitrate + 1;
            expect([gInf validate:&error]).to(equal(NO));
            expect(error.code).to(equal(MUKErrorInvalidStreamInf));
        });

        it(@"CODECS MUST NOT contains comma characters", ^{
            __block NSError* error = nil;
            gInf.codecs = @[ @"hoge,fugo" ];

            expect([gInf validate:&error]).to(equal(NO));
            expect(error.code).to(equal(MUKErrorInvalidStreamInf));

            error = nil;
            gInf.codecs = @[ @"hogefugo" ];

            expect([gInf validate:&error]).to(equal(YES));
            expect(error).to(beNil());
        });
    });
}
QuickSpecEnd
