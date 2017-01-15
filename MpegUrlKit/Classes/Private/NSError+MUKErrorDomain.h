//
//  NSError+MUKErrorDomain.h
//  MpegUrlKit
//
//  Created by Hinagiku Soranoba on 2017/01/06.
//  Copyright © 2017年 Hinagiku Soranoba. All rights reserved.
//

#import "MUKErrorCode.h"
#import <Foundation/Foundation.h>

#define SET_ERROR(__ppError, __Code, __Reason)                                             \
    do {                                                                                   \
        if (__ppError) {                                                                   \
            *(__ppError) = [NSError muk_errorWithMUKErrorCode:(__Code) reason:(__Reason)]; \
        }                                                                                  \
    } while (0)

@interface NSError (MUKErrorDomain)

/**
 * Create NSError with error code
 *
 * @param code Error code
 * @return instance
 */
+ (instancetype _Nonnull)muk_errorWithMUKErrorCode:(MUKErrorCode)code;

/**
 * Create NSError with error code and reason
 *
 * @param code   Error code
 * @param reason Error reason
 * @return instance
 */
+ (instancetype _Nonnull)muk_errorWithMUKErrorCode:(MUKErrorCode)code reason:(NSString* _Nonnull)reason;

@end
