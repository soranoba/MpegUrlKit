//
//  MUKAttributeSerializerTests.m
//  MpegUrlKit
//
//  Created by Hinagiku Soranoba on 2017/01/15.
//  Copyright © 2017年 Hinagiku Soranoba. All rights reserved.
//

#import "MUKAttributeSerializer.h"
#import "MUKTAttributeModel.h"
#import "MUKTAttributeModel2.h"

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

        it(@"can convert to NSURL from string", ^{
            NSError* error = nil;
            MUKTAttributeModel* m = [[MUKAttributeSerializer sharedSerializer] modelOfClass:MUKTAttributeModel.class
                                                                                 fromString:@"URL=\"http://host/path1\""
                                                                                      error:&error];
            expect(m.url.absoluteString).to(equal(@"http://host/path1"));

            MUKAttributeSerializer* serializer
                = [[MUKAttributeSerializer alloc] initWithVersion:nil
                                                          baseUri:[NSURL URLWithString:@"http://host/path1/variant.m3u8"]];

            m = [serializer modelOfClass:MUKTAttributeModel.class fromString:@"URL=\"../path2/data.json\"" error:&error];
            expect(m.url.absoluteString).to(equal(@"http://host/path2/data.json"));
        });

        it(@"return nil, if URL is invalid", ^{
            NSError* error = nil;
            MUKTAttributeModel* m = [[MUKAttributeSerializer sharedSerializer] modelOfClass:MUKTAttributeModel.class
                                                                                 fromString:@"URL=http://host"
                                                                                      error:&error];
            expect(m).to(beNil());
            expect(error.code).to(equal(MUKErrorInvalidType));
        });

        it(@"can convert to NSData from string", ^{
            NSError* error = nil;
            MUKTAttributeModel* m = [[MUKAttributeSerializer sharedSerializer] modelOfClass:MUKTAttributeModel.class
                                                                                 fromString:@"DATA=0x616A"
                                                                                      error:&error];
            expect(m.data).to(equal([NSData dataWithBytes:"aj" length:2]));
        });

        it(@"return nil, if DATA is invalid", ^{
            NSError* error = nil;
            MUKTAttributeModel* m = [[MUKAttributeSerializer sharedSerializer] modelOfClass:MUKTAttributeModel.class
                                                                                 fromString:@"DATA=\"0x123\""
                                                                                      error:&error];
            expect(m).to(beNil());
            expect(error.code).to(equal(MUKErrorInvalidType));
        });

        it(@"can convert to NSDate from string", ^{
            NSError* error = nil;
            MUKTAttributeModel* m = [[MUKAttributeSerializer sharedSerializer] modelOfClass:MUKTAttributeModel.class
                                                                                 fromString:@"DATE=\"2017-01-01T00:00:00.00Z\""
                                                                                      error:&error];

            NSCalendar* calendar = [NSCalendar currentCalendar];
            calendar.timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
            NSDateComponents* components = [NSDateComponents new];
            components.year = 2017;
            components.month = 1;
            components.day = 1;

            expect(m.date).to(equal([calendar dateFromComponents:components]));
        });

        it(@"return nil, if DATE is invalid", ^{
            NSError* error = nil;
            MUKTAttributeModel* m = [[MUKAttributeSerializer sharedSerializer] modelOfClass:MUKTAttributeModel.class
                                                                                 fromString:@"DATE=\"2016-12-11 10:00:00\""
                                                                                      error:&error];
            expect(m).to(beNil());
            expect(error.code).to(equal(MUKErrorInvalidType));
        });

        it(@"ignore attributes, when the version doesn't support the attributes", ^{
            NSError* error = nil;
            MUKAttributeSerializer* serializer = [[MUKAttributeSerializer alloc] initWithVersion:@(2) baseUri:nil];
            MUKTAttributeModel2* m = [serializer modelOfClass:MUKTAttributeModel2.class
                                                   fromString:@"V1=\"1\",V2=\"2\",V3=\"3\",V4=\"4\""
                                                        error:&error];
            expect(m).notTo(beNil());
            expect(m.v1).to(equal(@"1"));
            expect(m.v2).to(equal(@"2"));
            expect(m.v3).to(beNil());
            expect(m.v4).to(beNil());
            expect(error).to(beNil());

            serializer = [[MUKAttributeSerializer alloc] initWithVersion:@(3) baseUri:nil];
            m = [serializer modelOfClass:MUKTAttributeModel2.class
                              fromString:@"V1=\"1\",V2=\"2\",V3=\"3\",V4=\"4\""
                                   error:&error];
            expect(m).to(beNil());
            expect(error).notTo(beNil());
            expect(error.code).to(equal(MUKErrorUnsupportedVersion));
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
            expect(error).to(beNil());
        });

        it(@"can ignore attribute, if it use transformer and object type", ^{
            MUKTAttributeModel* m = [MUKTAttributeModel new];
            __block NSError* error = nil;
            expect([[MUKAttributeSerializer sharedSerializer] stringFromModel:m error:&error])
                .to(equal(@"BOOL=NO,INTEGER=0,DOUBLE=0,SIZE=0x0"));
            expect(error).to(beNil());
        });

        it(@"can convert to string from NSURL", ^{
            __block NSError* error = nil;

            MUKTAttributeModel* m = [MUKTAttributeModel new];
            m.url = [NSURL URLWithString:@"http://host/path1/data.json"];

            expect([[MUKAttributeSerializer sharedSerializer] stringFromModel:m error:&error])
                .to(equal(@"BOOL=NO,INTEGER=0,DOUBLE=0,SIZE=0x0,URL=\"http://host/path1/data.json\""));

            m.url = [NSURL URLWithString:@"data.json" relativeToURL:nil];
            MUKAttributeSerializer* serializer
                = [[MUKAttributeSerializer alloc] initWithVersion:nil
                                                          baseUri:[NSURL URLWithString:@"http://host/path1/variant.m3u8"]];
            expect([serializer stringFromModel:m error:&error])
                .to(equal(@"BOOL=NO,INTEGER=0,DOUBLE=0,SIZE=0x0,URL=\"data.json\""));
        });

        it(@"can convert to string from NSData", ^{
            __block NSError* error = nil;

            MUKTAttributeModel* m = [MUKTAttributeModel new];
            m.data = [NSData dataWithBytes:"abc" length:3];

            expect([[MUKAttributeSerializer sharedSerializer] stringFromModel:m error:&error])
                .to(equal(@"BOOL=NO,INTEGER=0,DOUBLE=0,SIZE=0x0,DATA=0x616263"));
        });

        it(@"can convert to string from NSDate", ^{
            __block NSError* error = nil;

            MUKTAttributeModel* m = [MUKTAttributeModel new];

            NSCalendar* calendar = [NSCalendar currentCalendar];
            calendar.timeZone = [NSTimeZone timeZoneWithName:@"JST"];
            NSDateComponents* components = [NSDateComponents new];
            components.year = 2016;
            components.month = 1;
            components.day = 21;

            m.date = [calendar dateFromComponents:components];
            [NSTimeZone setDefaultTimeZone:[NSTimeZone timeZoneWithName:@"JST"]];

            expect([[MUKAttributeSerializer sharedSerializer] stringFromModel:m error:&error])
                .to(equal(@"BOOL=NO,INTEGER=0,DOUBLE=0,SIZE=0x0,DATE=\"2016-01-21T00:00:00.000+09:00\""));
        });

        it(@"ignore attributes, when the version doesn't support the attributes", ^{
            __block NSError* error = nil;
            MUKAttributeSerializer* serializer = [[MUKAttributeSerializer alloc] initWithVersion:@(2) baseUri:nil];

            MUKTAttributeModel2* m = [MUKTAttributeModel2 new];
            m.v1 = @"1";
            m.v2 = @"2";
            m.v3 = @"3";
            m.v4 = @"4";

            expect([serializer stringFromModel:m error:&error]).to(equal(@"V1=\"1\",V2=\"2\""));
            expect(error).to(beNil());

            serializer = [[MUKAttributeSerializer alloc] initWithVersion:@(3) baseUri:nil];
            expect([serializer stringFromModel:m error:&error]).to(beNil());
            expect(error).notTo(beNil());
            expect(error.code).to(equal(MUKErrorUnsupportedVersion));
        });
    });
}
QuickSpecEnd
