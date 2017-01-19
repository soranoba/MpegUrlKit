//
//  MUKTypeEncodingTests.m
//  MpegUrlKit
//
//  Created by Hinagiku Soranoba on 2017/01/19.
//  Copyright © 2017年 Hinagiku Soranoba. All rights reserved.
//

#import "MUKTypeEncoding.h"

typedef struct __MUKTStruct1 {
    int i;
    double d;
} MUKTStruct1;

typedef struct __MUKTStruct2 {
    int i;
    double d;
} MUKTStruct2;

@interface MUKTTypeEncodingModel : NSObject
@property (nonatomic, assign) double d;
@property (nonatomic, assign) char* cp;
@property (nonatomic, assign) int* ip;
@property (nonatomic, assign) MUKTStruct1 s1;
@property (nonatomic, copy) NSString* str;
@end

@implementation MUKTTypeEncodingModel
@end

QuickSpecBegin(MUKTypeEncodingTests)
{
    describe(@"initWithProperty:", ^{
        it(@"can handle double type correctly", ^{
            objc_property_t property = class_getProperty(MUKTTypeEncodingModel.class, "d");
            MUKTypeEncoding* enc = [[MUKTypeEncoding alloc] initWithProperty:property];
            expect(strcmp(enc.objCType, @encode(double))).to(equal(0));
            expect(enc.klass).to(beNil());
        });

        it(@"can handle char* type correctly", ^{
            objc_property_t property = class_getProperty(MUKTTypeEncodingModel.class, "cp");
            MUKTypeEncoding* enc = [[MUKTypeEncoding alloc] initWithProperty:property];
            expect(strcmp(enc.objCType, @encode(char*))).to(equal(0));
            expect(strcmp(enc.objCType, @encode(int*))).notTo(equal(0));
            expect(enc.klass).to(beNil());
        });

        it(@"can handle pointer type correctly", ^{
            objc_property_t property = class_getProperty(MUKTTypeEncodingModel.class, "ip");
            MUKTypeEncoding* enc = [[MUKTypeEncoding alloc] initWithProperty:property];
            expect(strcmp(enc.objCType, @encode(int*))).to(equal(0));
            expect(strcmp(enc.objCType, @encode(void*))).notTo(equal(0));
            expect(enc.klass).to(beNil());
        });

        it(@"can handle struct type correctly", ^{
            objc_property_t property = class_getProperty(MUKTTypeEncodingModel.class, "s1");
            MUKTypeEncoding* enc = [[MUKTypeEncoding alloc] initWithProperty:property];
            expect(strcmp(enc.objCType, @encode(MUKTStruct1))).to(equal(0));
            expect(strcmp(enc.objCType, @encode(MUKTStruct2))).notTo(equal(0));
            expect(enc.klass).to(beNil());
        });

        it(@"can handle object type correctly", ^{
            objc_property_t property = class_getProperty(MUKTTypeEncodingModel.class, "str");
            MUKTypeEncoding* enc = [[MUKTypeEncoding alloc] initWithProperty:property];
            expect(strcmp(enc.objCType, @encode(id))).to(equal(0));
            expect(enc.klass).to(equal(NSString.class));
            expect(enc.klass).notTo(equal(NSMutableString.class));
        });
    });
}
QuickSpecEnd
