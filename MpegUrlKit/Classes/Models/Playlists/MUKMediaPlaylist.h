//
//  MUKMediaPlaylist.h
//  MpegUrlKit
//
//  Created by Hinagiku Soranoba on 2017/01/06.
//  Copyright © 2017年 Hinagiku Soranoba. All rights reserved.
//

#import "MUKErrorCode.h"
#import "MUKMediaSegment.h"
#import "MUKSerializing.h"
#import "MUKXDateRange.h"
#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, MUKPlaylistType) {
    MUKPlaylistTypeUnknown = 0,
    MUKPlaylistTypeEvent,
    MUKPlaylistTypeVod
};

@interface MUKMediaPlaylist : MUKSerializing

@property (nonatomic, assign) NSUInteger version;
@property (nonatomic, assign) NSUInteger targetDuration;
@property (nonatomic, assign) NSUInteger firstSequenceNumber;
@property (nonatomic, assign) NSUInteger firstDiscontinuitySequenceNumber;
@property (nonatomic, assign) MUKPlaylistType playlistType;
@property (nonatomic, assign) BOOL hasEndList;
@property (nonatomic, assign) BOOL isIframesOnly;
@property (nonatomic, nonnull, copy) NSArray<MUKMediaSegment*>* mediaSegments;
@property (nonatomic, nonnull, copy) NSArray<MUKXDateRange*>* dateRanges;

/**
 * Convert to string from playlist type
 *
 * @param type A playlist type
 * @return If playlist is MUKPlaylistTypeUnknown, it returns nil. Otherwise, it returns string of playlist type.
 */
+ (NSString* _Nullable)playlistTypeToString:(MUKPlaylistType)type;

/**
 * Convert to playlist type from string
 *
 * @param string A string of playlist type
 * @return If string is not supported, it returns MUKPlaylistUnknown. Otherwise, it returns playlist type.
 */
+ (MUKPlaylistType)playlistTypeFromString:(NSString* _Nonnull)string;

@end
