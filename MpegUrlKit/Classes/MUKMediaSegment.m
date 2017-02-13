//
//  MUKMediaSegment.m
//  MpegUrlKit
//
//  Created by Hinagiku Soranoba on 2017/01/06.
//  Copyright © 2017年 Hinagiku Soranoba. All rights reserved.
//

#import "MUKMediaSegment.h"
#import "MUKConsts.h"

@implementation MUKMediaSegment

#pragma mark - Lifecycle

- (instancetype _Nonnull)initWithDuration:(double)duration
                                      uri:(NSURL* _Nonnull)uri
{
    if (self = [super init]) {
        self.duration = duration;
        self.uri = uri;
    }
    return self;
}

#pragma mark - Public Methods

- (NSDictionary<NSString*, id>*)renderObject
{
    NSString* xByteRange = nil;
    if (self.byteRange.location != NSNotFound) {
        xByteRange = [NSString stringWithFormat:@"%tu@%tu", self.byteRange.length, self.byteRange.location];
    }
    NSString* xKey = nil;
    if (self.encrypt) {
    }

    NSString* xMap = nil;
    if (self.initializationMap) {
    }

    NSString* xProgram = nil;
    if (self.programDate) {
    }

    return @{ @"DURATION" : @(self.duration),
              @"TITLE" : self.title ?: @"",
              @"URL" : self.uri.absoluteString ?: @"",
              MUK_EXT_X_BYTERANGE : xByteRange ?: @"",
              MUK_EXT_X_DISCONTINUITY : @(self.discontinuity),
              MUK_EXT_X_KEY : xKey ?: @"",
              MUK_EXT_X_MAP : xMap ?: @"",
              MUK_EXT_X_PROGRAM_DATE_TIME : xProgram ?: @"" };
}

@end
