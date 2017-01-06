//
//  MUKConsts.h
//  MpegUrlKit
//
//  Created by Hinagiku Soranoba on 2017/01/06.
//  Copyright © 2017年 Hinagiku Soranoba. All rights reserved.
//

#import <Foundation/Foundation.h>

#define ACTION(__X) ^(NSString * line, NSError * *error) { \
    return __X;                                            \
}

#define TAG_VALUE(__TAG, __LINE) [(__LINE) substringWithRange:NSMakeRange((__TAG).length, (__LINE).length - (__TAG).length)]

#define SET_ERROR(__ppError, __Code, __Reason)                                             \
    do {                                                                                   \
        if (__ppError) {                                                                   \
            *(__ppError) = [NSError muk_errorWithMUKErrorCode:(__Code) reason:(__Reason)]; \
        }                                                                                  \
    } while (0)

extern NSString* const MUK_EXTM3U;
extern NSString* const MUK_EXT_X_VERSION;
extern NSString* const MUK_EXT_X_STREAM_INF;
extern NSString* const MUK_EXTINF;
extern NSString* const MUK_EXT_X_BYTERANGE;
