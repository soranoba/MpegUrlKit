//
//  MUKXSessionData.m
//  MpegUrlKit
//
//  Created by Hinagiku Soranoba on 2017/01/15.
//  Copyright © 2017年 Hinagiku Soranoba. All rights reserved.
//

#import "MUKXSessionData.h"
#import "NSError+MUKErrorDomain.h"

@implementation MUKXSessionData

#pragma mark - Lifecycle

- (instancetype _Nullable)initWithDataId:(NSString* _Nonnull)dataId
                                   value:(NSString* _Nullable)value
                                     uri:(NSString* _Nullable)uri
                                language:(NSString* _Nullable)language
{
    NSParameterAssert(dataId != nil);

    if (self = [super init]) {
        self.dataId = dataId;
        self.value = value;
        self.uri = uri;
        self.language = language;
    }
    return self;
}

#pragma mark - Public Methods

- (BOOL)validate:(NSError* _Nullable* _Nullable)error
{
    if (!self.value && !self.uri) {
        SET_ERROR(error, MUKErrorInvalidSesseionData, @"It MUST be contain either a VALUE or URI");
        return NO;
    }
    return YES;
}

@end
