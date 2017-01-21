//
//  MUKXMapTests.m
//  MpegUrlKit
//
//  Created by Hinagiku Soranoba on 2017/01/21.
//  Copyright © 2017年 Hinagiku Soranoba. All rights reserved.
//

#import "MUKXMap.h"

@interface MUKXMap ()
@property (nonatomic, nonnull, copy, readwrite) NSURL* uri;
+ (MUKTransformer* _Nonnull)byteRangeTransformer;
@end

QuickSpecBegin(MUKXMapTests)
{
    describe(@"validate", ^{
        it(@"URI is REQUIRED", ^{
            MUKXMap* map = [MUKXMap new];
            __block NSError* error = nil;
            expect([map validate:&error]).to(equal(NO));
            expect(error.code).to(equal(MUKErrorInvalidMap));

            map.uri = [NSURL URLWithString:@"http://host/path1"];
            expect([map validate:&error]).to(equal(YES));
        });

        it(@"EXT-X-MAP REQUIRES a compatibility version number of 5 or grater", ^{
            expect([MUKXMap minimumModelSupportedVersion]).to(equal(@(5)));
        });

        it(@"location of range is NSNotFound, when it is default", ^{
            MUKXMap* map = [MUKXMap new];
            expect(map.byteRange.location).to(equal(NSNotFound));
        });
    });

    describe(@"byteRangeTransformer", ^{
        it(@"can convert to range from string", ^{
            MUKAttributeValue* value = [[MUKAttributeValue alloc] initWithValue:@"500@100" isQuotedString:YES];
            NSRange range = [[[MUKXMap byteRangeTransformer] transformedValue:value] rangeValue];
            expect(range.location).to(equal(100));
            expect(range.length).to(equal(500));

            value = [[MUKAttributeValue alloc] initWithValue:@"100" isQuotedString:YES];
            range = [[[MUKXMap byteRangeTransformer] transformedValue:value] rangeValue];
            expect(range.location).to(equal(0));
            expect(range.length).to(equal(100));

            value = [[MUKAttributeValue alloc] initWithValue:@"100" isQuotedString:NO];
            expect([[MUKXMap byteRangeTransformer] transformedValue:value]).to(beNil());
        });

        it(@"can convert to string from range", ^{
            MUKAttributeValue* value = [[MUKAttributeValue alloc] initWithValue:@"500@100" isQuotedString:YES];
            expect([[MUKXMap byteRangeTransformer] reverseTransformedValue:[NSValue valueWithRange:NSMakeRange(100, 500)]])
                .to(equal(value));

            expect([[MUKXMap byteRangeTransformer] reverseTransformedValue:[NSValue valueWithRange:NSMakeRange(NSNotFound, 100)]])
                .to(beNil());
        });
    });
}
QuickSpecEnd
