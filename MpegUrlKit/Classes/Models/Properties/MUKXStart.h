//
//  MUKXStreamInf.h
//  MpegUrlKit
//
//  Created by Hinagiku Soranoba on 2017/01/21.
//  Copyright © 2017年 Hinagiku Soranoba. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MUKAttributeModel.h"
#import "MUKErrorCode.h"

@interface MUKXStart : MUKAttributeModel <MUKAttributeSerializing>

@property(nonatomic, assign, readonly) double timeOffset;
@property(nonatomic, assign, readonly, getter=isPrecise) BOOL precise;

@end
