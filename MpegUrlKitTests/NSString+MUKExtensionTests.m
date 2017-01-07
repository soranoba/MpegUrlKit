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
    });
}
QuickSpecEnd
