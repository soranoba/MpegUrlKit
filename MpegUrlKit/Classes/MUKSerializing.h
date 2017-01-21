//
//  MUKSerializing.h
//  MpegUrlKit
//
//  Created by Hinagiku Soranoba on 2017/01/06.
//  Copyright © 2017年 Hinagiku Soranoba. All rights reserved.
//

#import "MUKAttributeSerializer.h"
#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, MUKTagActionResult) {
    /// The tag was supported, but it was considered abnormal data for reasons such as invalid.
    MUKTagActionResultErrored = -1,
    /// The tag was ignored, because it is an unsupported.
    MUKTagActionResultIgnored = 0,
    /// The tag was supported and processed.
    MUKTagActionResultProcessed = 1
};

typedef MUKTagActionResult (^MUKTagAction)(NSString* _Nonnull tagValue, NSError* _Nullable* _Nullable error);

@protocol MUKSerializing <NSObject>

/**
 * Do not create other designated initializer.
 * MUKSerializing object is always initialized by this method.
 *
 * @param url  A url of the playlist.
 * @return instance
 */
@required
- (instancetype _Nullable)initWithPlaylistUrl:(NSURL* _Nullable)url;

/**
 * If you want to do specific processing when starting serialize, initialize here.
 */
@optional
- (void)beginSerialization;

/**
 * Processing on a line.
 *
 * @param line   A string of a line.
 * @param error  When returning MUKTagActionResultErrored, more detailed error information needs to be stored here.
 * @return Processing result of the line.
 *         If it return MUKTagActionResultErrored, the serialize process is terminated halfway.
 */
@required
- (MUKTagActionResult)appendLine:(NSString* _Nonnull)line error:(NSError* _Nullable* _Nullable)error;

/**
 * If you want to do specific processing when ending serialize, processing here.
 * It will NOT be called if serialize finished by an error.
 */
@optional
- (void)endSerialization;

/**
 * If you want to execute validate after serialize, please define it.
 */
@optional
- (BOOL)validate:(NSError* _Nullable* _Nullable)error;

@end

/**
 * MUKSerializing class is a MUKSerializing helper class.
 * This class automatically performs the processing by registering the action corresponding to the prefix.
 *
 * You do not necessarily have to use this class.
 */
@interface MUKSerializing : NSObject <MUKSerializing>

@property (nonatomic, nullable, strong) NSURL* playlistUrl;
@property (nonatomic, nullable, strong) MUKAttributeSerializer* serializer;

/**
 * Returns processing action by tags.
 *
 * Subclass needs to override this return value according to your implementation.
 *
 * @return Key is tag string. Value is callback block, if line has prefix the key.
 *         For tags with value you need to include `:`.
 *         The key of the empty string has a special meaning of action when it does not match any other.
 */
- (NSDictionary<NSString*, MUKTagAction>* _Nonnull)tagActions;

@end
