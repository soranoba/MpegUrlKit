//
//  MUKXStartTests.m
//  MpegUrlKit
//
//  Created by Hinagiku Soranoba on 2017/01/22.
//  Copyright © 2017年 Hinagiku Soranoba. All rights reserved.
//

#import "MUKXStart.h"

@interface MUKXStart ()
+ (MUKTransformer* _Nonnull)timeOffsetTransformer;
@end

QuickSpecBegin(MUKXStartTests)
{
    describe(@"timeOffsetTransformer", ^{
        it(@"does not have block (it means default transform)", ^{
            expect([[MUKXStart timeOffsetTransformer] hasTransformBlock]).to(beFalse());
        });

        it(@"can convert to string from double", ^{
            MUKAttributeValue* value = [[MUKAttributeValue alloc] initWithValue:@"5.5" isQuotedString:NO];
            expect([[MUKXStart timeOffsetTransformer] reverseTransformedValue:@5.5]).to(equal(value));

            value = [[MUKAttributeValue alloc] initWithValue:@"5" isQuotedString:NO];
            expect([[MUKXStart timeOffsetTransformer] reverseTransformedValue:@5]).to(equal(value));
        });
    });
}
QuickSpecEnd
