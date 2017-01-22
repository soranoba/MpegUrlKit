//
//  MUKXIframeStreamInfTests.m
//  MpegUrlKit
//
//  Created by Hinagiku Soranoba on 2017/01/22.
//  Copyright © 2017年 Hinagiku Soranoba. All rights reserved.
//

#import "MUKXIframeStreamInf.h"

@interface MUKXIframeStreamInf ()
@property (nonatomic, assign, readwrite) NSUInteger maxBitrate;
@property (nonatomic, nonnull, copy, readwrite) NSURL* uri;
@end

QuickSpecBegin(MUKXIframeStreamInfTests)
{
    describe(@"propertyByAttributeKey", ^{
        it(@"have been added a URI and deleted some elements", ^{
            expect([MUKXIframeStreamInf propertyByAttributeKey][@"URI"]).notTo(beNil());
            expect([MUKXIframeStreamInf propertyByAttributeKey][@"FRAME-RATE"]).to(beNil());
            expect([MUKXIframeStreamInf propertyByAttributeKey][@"AUDIO"]).to(beNil());
            expect([MUKXIframeStreamInf propertyByAttributeKey][@"SUBTITLES"]).to(beNil());
            expect([MUKXIframeStreamInf propertyByAttributeKey][@"CLOSED-CAPTIONS"]).to(beNil());
        });
    });

    describe(@"attributeOrder", ^{
        it(@"have been added a URI and deleted some elements", ^{
            expect([[MUKXIframeStreamInf attributeOrder] containsObject:@"URI"]).to(beTrue());
            expect([[MUKXIframeStreamInf attributeOrder] containsObject:@"FRAME-RATE"]).to(beFalse());
            expect([[MUKXIframeStreamInf attributeOrder] containsObject:@"AUDIO"]).to(beFalse());
            expect([[MUKXIframeStreamInf attributeOrder] containsObject:@"SUBTITLES"]).to(beFalse());
            expect([[MUKXIframeStreamInf attributeOrder] containsObject:@"CLOSED-CAPTIONS"]).to(beFalse());
        });
    });

    describe(@"validate:", ^{
        it(@"URI and BANDWIDTH is REQUIRED", ^{
            MUKXIframeStreamInf* inf = [MUKXIframeStreamInf new];
            inf.maxBitrate = 1000;

            __block NSError* error = nil;
            expect([inf validate:&error]).to(equal(NO));
            expect(error.code).to(equal(MUKErrorInvalidStreamInf));

            error = nil;
            inf.uri = [NSURL URLWithString:@"http://host/path1"];
            expect([inf validate:&error]).to(equal(YES));
            expect(error).to(beNil());
        });
    });
}
QuickSpecEnd
