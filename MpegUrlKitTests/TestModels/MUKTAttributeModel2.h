//
//  MUKTAttributeModel2.h
//  MpegUrlKit
//
//  Created by Hinagiku Soranoba on 2017/01/21.
//  Copyright © 2017年 Hinagiku Soranoba. All rights reserved.
//

#import "MUKAttributeModel.h"
#import <Foundation/Foundation.h>

@interface MUKTAttributeModel2 : MUKAttributeModel <MUKAttributeSerializing>

@property (nonatomic, nullable, strong) NSString* v1;
@property (nonatomic, nullable, strong) NSString* v2;
@property (nonatomic, nullable, strong) NSString* v3;
@property (nonatomic, nullable, strong) NSString* v4;

@end
