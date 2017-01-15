//
//  MUKAttributeSerializerTests.m
//  MpegUrlKit
//
//  Created by Hinagiku Soranoba on 2017/01/15.
//  Copyright © 2017年 Hinagiku Soranoba. All rights reserved.
//

#import "MUKAttributeSerializer.h"
#import "MUKTAttributeModel.h"

@interface MUKAttributeSerializer ()
+ (SEL)makeSelectorWithPrefix:(NSString* _Nonnull)prefix suffix:(const char*)suffix;
@end

QuickSpecBegin(MUKAttributeSerializerTests)
{
    describe(@"MUKAttrbuteSerializer # makeSelectorWithPrefix:suffix:", ^{
        it(@"can return SEL", ^{
            expect([MUKAttributeSerializer makeSelectorWithPrefix:@"a" suffix:"Transformer"] == sel_registerName("aTransformer")).to(beTruthy());
        });
    });

    describe(@"MUKAttributeSerializer # parseFromString:error:", ^{
        it(@"can parse quoted-string and other string", ^{
            NSString* str = @"ENUM_KEY=ENUM_VALUE,INT_KEY=123,QUOTED_KEY=\"quoted,value\"";
            __block NSError* error = nil;
            __block NSDictionary<NSString*, MUKAttributeValue*>* attributes;
            expect(attributes = [MUKAttributeSerializer parseFromString:str error:&error]).notTo(beNil());
            expect(attributes.count).to(equal(3));
            expect(attributes[@"ENUM_KEY"].isQuotedString).to(equal(NO));
            expect(attributes[@"ENUM_KEY"].value).to(equal(@"ENUM_VALUE"));
            expect(attributes[@"INT_KEY"].isQuotedString).to(equal(NO));
            expect(attributes[@"INT_KEY"].value).to(equal(@"123"));
            expect(attributes[@"QUOTED_KEY"].isQuotedString).to(equal(YES));
            expect(attributes[@"QUOTED_KEY"].value).to(equal(@"quoted,value"));
        });

        it(@"return nil, if key-value pairs is broken", ^{
            NSString* str = @"ENUM_KEY=ENUM_VALUE,INT_KEY";
            __block NSError* error = nil;
            expect([MUKAttributeSerializer parseFromString:str error:&error]).to(beNil());
            expect(error.code).to(equal(MUKErrorInvalidAttributeList));
        });

        it(@"return nil, if quoted-string is broken", ^{
            NSString* str = @"ENUM_KEY=ENUM_VALUE,QUOTED_KEY=\"quoted,value\"..";
            __block NSError* error = nil;
            expect([MUKAttributeSerializer parseFromString:str error:&error]).to(beNil());
            expect(error.code).to(equal(MUKErrorInvalidAttributeList));

            str = @"ENUM_KEY=ENUM_VALUE,QUOTED_KEY=\"quoted,value";
            expect([MUKAttributeSerializer parseFromString:str error:&error]).to(beNil());
            expect(error.code).to(equal(MUKErrorInvalidAttributeList));
        });

        it(@"return nil, if no quoted-string has double-quote", ^{
            NSString* str = @"ENUM_KEY=ENUM_\"VALUE";
            __block NSError* error = nil;
            expect([MUKAttributeSerializer parseFromString:str error:&error]).to(beNil());
            expect(error.code).to(equal(MUKErrorInvalidAttributeList));
        });

        it(@"return nil, if it have duplicate key", ^{
            NSString* str = @"INT_KEY=1,INT_KEY=2";
            __block NSError* error = nil;
            expect([MUKAttributeSerializer parseFromString:str error:&error]).to(beNil());
            expect(error.code).to(equal(MUKErrorInvalidAttributeList));
        });
    });

    describe(@"MUKAttributeSerializer # makeFromDict:order:error:", ^{
        it(@"can make attribute list, it is correct", ^{
            NSDictionary<NSString*, MUKAttributeValue*>* attributes
                = @{ @"KEY1" : [[MUKAttributeValue alloc] initWithValue:@"123" isQuotedString:NO],
                     @"KEY2" : [[MUKAttributeValue alloc] initWithValue:@"quoted-string" isQuotedString:YES] };

            __block NSError* error = nil;
            expect([MUKAttributeSerializer makeStringFromDict:attributes order:@[ @"KEY1", @"KEY2" ] error:&error])
                .to(equal(@"KEY1=123,KEY2=\"quoted-string\""));
            expect(error).to(beNil());

            expect([MUKAttributeSerializer makeStringFromDict:attributes order:@[ @"KEY2", @"KEY1" ] error:&error])
                .to(equal(@"KEY2=\"quoted-string\",KEY1=123"));
            expect(error).to(beNil());
        });

        it(@"return nil, when validate failed", ^{
            NSDictionary<NSString*, MUKAttributeValue*>* attributes
                = @{ @"KEY1" : [[MUKAttributeValue alloc] initWithValue:@"quoted\nstring" isQuotedString:YES] };

            __block NSError* error = nil;
            expect([attributes[@"KEY1"] validate:&error]).to(beFalsy());
            expect(error.code).to(equal(MUKErrorInvalidAttributeList));

            expect([MUKAttributeSerializer makeStringFromDict:attributes order:@[ @"KEY1" ] error:&error]).to(beNil());
            expect(error.code).to(equal(MUKErrorInvalidAttributeList));
        });
    });

    describe(@"MUKAttributeSerializer # modelOfClass:fromString:error:", ^{
        it(@"can convert to model from string", ^{
            NSError* error = nil;
            NSString* str = @"BOOL=YES,INTEGER=1,DOUBLE=2.5,STRING=\"hoge\",SIZE=100x200,ENUM=A";
            MUKTAttributeModel* m = [[MUKAttributeSerializer sharedSerializer] modelOfClass:MUKTAttributeModel.class
                                                                                 fromString:str
                                                                                      error:&error];
            expect(m).notTo(beNil());
            expect(m.b).to(equal(@YES));
            expect(m.i).to(equal(@1));
            expect(m.d).to(equal(@2.5));
            expect(m.s).to(equal(@"hoge"));
            expect(m.size.width).to(equal(@100));
            expect(m.size.height).to(equal(@200));
            expect(@(m.e)).to(equal(@(MUKTEnumA)));
        });

        it(@"return nil, if BOOL is invalid", ^{
            NSError* error = nil;
            MUKTAttributeModel* m = [[MUKAttributeSerializer sharedSerializer] modelOfClass:MUKTAttributeModel.class
                                                                                 fromString:@"BOOL=1"
                                                                                      error:&error];
            expect(m).to(beNil());
            expect(error.code).to(equal(MUKErrorInvalidType));
        });

        it(@"return nil, if INTEGER is invalid", ^{
            NSError* error = nil;
            MUKTAttributeModel* m = [[MUKAttributeSerializer sharedSerializer] modelOfClass:MUKTAttributeModel.class
                                                                                 fromString:@"INTEGER=5.5"
                                                                                      error:&error];
            expect(m).to(beNil());
            expect(error.code).to(equal(MUKErrorInvalidType));
        });

        it(@"return nil, if STRING is invalid", ^{
            NSError* error = nil;
            MUKTAttributeModel* m = [[MUKAttributeSerializer sharedSerializer] modelOfClass:MUKTAttributeModel.class
                                                                                 fromString:@"STRING=1"
                                                                                      error:&error];
            expect(m).to(beNil());
            expect(error.code).to(equal(MUKErrorInvalidType));
        });

        it(@"return nil, if SIZE is invalid", ^{
            NSError* error = nil;
            MUKTAttributeModel* m = [[MUKAttributeSerializer sharedSerializer] modelOfClass:MUKTAttributeModel.class
                                                                                 fromString:@"SIZE=1"
                                                                                      error:&error];
            expect(m).to(beNil());
            expect(error.code).to(equal(MUKErrorInvalidType));
        });

        it(@"return nil, if ENUM is invalid", ^{
            NSError* error = nil;
            MUKTAttributeModel* m = [[MUKAttributeSerializer sharedSerializer] modelOfClass:MUKTAttributeModel.class
                                                                                 fromString:@"BOOL=1"
                                                                                      error:&error];
            expect(m).to(beNil());
            expect(error.code).to(equal(MUKErrorInvalidType));
        });
    });

    describe(@"stringFromModel:error:", ^{
        it(@"can convert to string from model", ^{
            MUKTAttributeModel* m = [MUKTAttributeModel new];
            m.b = YES;
            m.i = 2;
            m.d = 2.5;
            m.e = MUKTEnumB;
            m.s = @"hoge";
            m.size = CGSizeMake(100, 200);

            __block NSError* error = nil;
            expect([[MUKAttributeSerializer sharedSerializer] stringFromModel:m error:&error])
                .to(equal(@"BOOL=YES,INTEGER=2,DOUBLE=2.5,SIZE=100x200,STRING=\"hoge\",ENUM=B"));
        });

        it(@"can ignore attribute, if it use transformer", ^{
            MUKTAttributeModel* m = [MUKTAttributeModel new];
            __block NSError* error = nil;
            expect([[MUKAttributeSerializer sharedSerializer] stringFromModel:m error:&error])
                .to(equal(@"BOOL=NO,INTEGER=0,DOUBLE=0,SIZE=0x0"));
            expect(error).to(beNil());
        });
    });
}
QuickSpecEnd
