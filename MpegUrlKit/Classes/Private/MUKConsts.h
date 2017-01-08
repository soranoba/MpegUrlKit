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

/// 4.3.2.1. EXTINF
extern NSString* const MUK_EXTINF;
/// 4.3.2.2. EXT-X-BYTERANGE
extern NSString* const MUK_EXT_X_BYTERANGE;
/// 4.3.2.3. EXT-X-DISCONTINUITY
extern NSString* const MUK_EXT_X_DISCONTINUITY;
/// 4.3.2.4. EXT-X-KEY
extern NSString* const MUK_EXT_X_KEY;
/// 4.3.2.5. EXT-X-MAP
extern NSString* const MUK_EXT_X_MAP;
/// 4.3.2.6. EXT-X-PROGRAM-DATE-TIME
extern NSString* const MUK_EXT_X_PROGRAM_DATE_TIME;
/// 4.3.2.7. EXT-X-DATERANGE
extern NSString* const MUK_EXT_X_DATERANGE;

/// 4.3.3.1. EXT-X-TARGETDURATION
extern NSString* const MUK_EXT_X_TARGETDURATION;
/// 4.3.3.2. EXT-X-MEDIA-SEQUENCE
extern NSString* const MUK_EXT_X_MEDIA_SEQUENCE;
/// 4.3.3.3. EXT-X-DISCONTINUITY-SEQUENCE
extern NSString* const MUK_EXT_X_DISCONTINUITY_SEQUENCE;
/// 4.3.3.4. EXT-X-ENDLIST
extern NSString* const MUK_EXT_X_ENDLIST;
/// 4.3.3.5. EXT-X-PLAYLIST-TYPE
extern NSString* const MUK_EXT_X_PLAYLIST_TYPE;
/// 4.3.3.6. EXT-X-I-FRAMES-ONLY
extern NSString* const MUK_EXT_X_I_FRAMES_ONLY;

extern NSString* const MUK_EXT_X_KEY_METHOD_NONE;
extern NSString* const MUK_EXT_X_KEY_METHOD_AES_128;
extern NSString* const MUK_EXT_X_KEY_METHOD_SAMPLE_AES;
