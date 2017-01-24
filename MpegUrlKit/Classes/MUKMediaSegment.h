//
//  MUKMediaSegment.h
//  MpegUrlKit
//
//  Created by Hinagiku Soranoba on 2017/01/06.
//  Copyright © 2017年 Hinagiku Soranoba. All rights reserved.
//

#import "MUKXKey.h"
#import "MUKXMap.h"
#import <Foundation/Foundation.h>

@class MUKMediaSegment;
typedef BOOL (^MUKSegmentValidator)(MUKMediaSegment* _Nonnull, NSError* _Nullable* _Nullable);

@interface MUKMediaSegment : NSObject
@property (nonatomic, assign) double duration;
@property (nonatomic, nullable, copy) NSString* title;
@property (nonatomic, nullable, strong) NSURL* uri;
@property (nonatomic, assign) NSRange byteRange;
@property (nonatomic, assign) BOOL discontinuity;
@property (nonatomic, nullable, strong) MUKXKey* encrypt;
@property (nonatomic, nullable, strong) MUKXMap* initializationMap;
@property (nonatomic, nullable, strong) NSDate* programDate;

- (instancetype _Nonnull)initWithDuration:(double)duration
                                      uri:(NSURL* _Nonnull)uri;

@end
