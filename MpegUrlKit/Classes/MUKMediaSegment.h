//
//  MUKMediaSegment.h
//  MpegUrlKit
//
//  Created by Hinagiku Soranoba on 2017/01/06.
//  Copyright © 2017年 Hinagiku Soranoba. All rights reserved.
//

#import "MUKMediaEncrypt.h"
#import <Foundation/Foundation.h>

@class MUKMediaSegment;
typedef BOOL (^MUKSegmentValidator)(MUKMediaSegment* _Nonnull, NSError* _Nullable* _Nullable);

@interface MUKMediaSegment : NSObject
@property (nonatomic, assign) float duration;
@property (nonatomic, nullable, copy) NSString* title;
@property (nonatomic, nullable, copy) NSString* uri;
@property (nonatomic, assign) NSRange byteRange;
@property (nonatomic, assign) BOOL discontinuity;
@property (nonatomic, nullable, strong) MUKMediaEncrypt* encrypt;
@end
