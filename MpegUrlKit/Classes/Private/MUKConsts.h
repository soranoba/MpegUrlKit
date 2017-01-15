//
//  MUKConsts.h
//  MpegUrlKit
//
//  Created by Hinagiku Soranoba on 2017/01/06.
//  Copyright © 2017年 Hinagiku Soranoba. All rights reserved.
//

#import <Foundation/Foundation.h>

#define ACTION(__X) ^(NSString * tagValue, NSError * *error) { \
    return __X;                                                \
}

extern NSString* const MUK_EXTM3U;
extern NSString* const MUK_EXT_X_VERSION;

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

/// 4.3.4.1. EXT-X-MEDIA
extern NSString* const MUK_EXT_X_MEDIA;
/// 4.3.4.2. EXT-X-STREAM-INF
extern NSString* const MUK_EXT_X_STREAM_INF;
/// 4.3.4.3. EXT-X-I-FRAME-STREAM-INF
extern NSString* const MUK_EXT_X_I_FRAME_STREAM_INF;
/// 4.3.4.4. EXT-X-SESSION-DATA
extern NSString* const MUK_EXT_X_SESSION_DATA;
/// 4.3.4.5. EXT-X-SESSION-KEY
extern NSString* const MUK_EXT_X_SESSION_KEY;

/// 4.3.5.1. EXT-X-INDEPENDENT-SEGMENTS
extern NSString* const MUK_EXT_X_INDEPENDENZT_SEGMENT;
/// 4.3.5.2. EXT-X-START
extern NSString* const MUK_EXT_X_START;
