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

#pragma mark - MUKAttributeSerializing

+ (NSDictionary<NSString*, NSString*>* _Nonnull)keyByPropertyKey
{
    return @{ @"DATA-ID" : @"dataId",
              @"VALUE" : @"value",
              @"URI" : @"uri",
              @"LANGUAGE" : @"language" };
}

+ (NSArray<NSString*>* _Nonnull)attributeOrder
{
    return @[ @"DATA-ID", @"VALUE", @"URI", @"LANGUAGE" ];
}

#pragma mark - MUKAttributeModel (Override)

- (BOOL)validate:(NSError* _Nullable* _Nullable)error
{
    if (!self.dataId) {
        SET_ERROR(error, MUKErrorInvalidSesseionData, @"DATA-ID is REQUIRED");
        return NO;
    }

    if (!self.value && !self.uri) {
        SET_ERROR(error, MUKErrorInvalidSesseionData, @"It MUST be contain either a VALUE or URI");
        return NO;
    }
    return YES;
}

@end
