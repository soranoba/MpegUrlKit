//
//  NSError+MUKErrorDomain.m
//  MpegUrlKit
//
//  Created by Hinagiku Soranoba on 2017/01/06.
//  Copyright © 2017年 Hinagiku Soranoba. All rights reserved.
//

#import "NSError+MUKErrorDomain.h"

@implementation NSError (MUKErrorDomain)

#pragma mark - Public Methods

+ (instancetype _Nonnull)muk_errorWithMUKErrorCode:(MUKErrorCode)code
{
    NSDictionary* userInfo = @{ NSLocalizedDescriptionKey : [self description:code] };
    return [NSError errorWithDomain:MUKErrorDomain code:code userInfo:userInfo];
}

+ (instancetype _Nonnull)muk_errorWithMUKErrorCode:(MUKErrorCode)code reason:(NSString* _Nonnull)reason
{
    NSDictionary* userInfo = @{ NSLocalizedDescriptionKey : [self description:code],
                                NSLocalizedFailureReasonErrorKey : reason };
    return [NSError errorWithDomain:MUKErrorDomain code:code userInfo:userInfo];
}

#pragma mark - Private Method

/**
 * Return a LocalizedDescription.
 *
 * @param code
 * @return description string
 */
+ (NSString* _Nonnull)description:(MUKErrorCode)code
{
    switch (code) {
        case MUKErrorInvalidM3UFormat:
            return @"Invalid M3U format";
        case MUKErrorInvalidVersion:
            return @"It has EXT-X-VERSION tag, but it is invalid";
        case MUKErrorInvalidMediaSegment:
            return @"Invalid media segment or EXTINF";
        case MUKErrorInvalidByteRange:
            return @"Invalid EXT-X-BYTERANGE";
        case MUKErrorInvalidEncrypt:
            return @"Invalid EXT-X-KEY";
        case MUKErrorInvalidAttributeList:
            return @"Invalid attribute list";
        default:
            return @"Unknown error";
    }
}

@end
