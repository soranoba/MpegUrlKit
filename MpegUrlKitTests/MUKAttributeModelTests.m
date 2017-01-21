//
//  MUKAttributeModelTests.m
//  MpegUrlKit
//
//  Created by Hinagiku Soranoba on 2017/01/21.
//  Copyright © 2017年 Hinagiku Soranoba. All rights reserved.
//

#import "MUKAttributeModel.h"
#import "MUKTAttributeModel.h"

QuickSpecBegin(MUKAttributeModelTests)
{
    describe(@"description", ^{
        it(@"returns a string that converted from model", ^{
            MUKTAttributeModel* model = [MUKTAttributeModel new];
            model.d = 2.5;
            model.s = @"hoge";

            expect([NSString stringWithFormat:@"%@", model]).to(equal(@"BOOL=NO,INTEGER=0,DOUBLE=2.5,SIZE=0x0,STRING=\"hoge\""));
            expect([model description]).to(equal(@"BOOL=NO,INTEGER=0,DOUBLE=2.5,SIZE=0x0,STRING=\"hoge\""));
        });
    });
}
QuickSpecEnd
