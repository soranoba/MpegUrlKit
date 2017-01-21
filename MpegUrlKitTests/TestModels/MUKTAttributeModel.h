//
//  MUKTAttributeModel.h
//  MpegUrlKit
//
//  Created by Hinagiku Soranoba on 2017/01/15.
//  Copyright © 2017年 Hinagiku Soranoba. All rights reserved.
//

#import "MUKAttributeModel.h"

typedef NS_ENUM(NSUInteger, MUKTEnum) {
    MUKTEnumA = 1,
    MUKTEnumB = 2,
};

@interface MUKTAttributeModel : MUKAttributeModel <MUKAttributeSerializing>

@property (nonatomic, assign) BOOL b;
@property (nonatomic, assign) NSUInteger i;
@property (nonatomic, assign) double d;
@property (nonatomic, assign) CGSize size;
@property (nonatomic, nullable, strong) NSString* s;
@property (nonatomic, assign) MUKTEnum e;
@property (nonatomic, nullable, strong) NSURL* url;
@property (nonatomic, nullable, strong) NSData* data;
@property (nonatomic, nullable, strong) NSDate* date;

@end
