//
//  MUKSerializer.h
//  MpegUrlKit
//
//  Created by Hinagiku Soranoba on 2017/01/06.
//  Copyright © 2017年 Hinagiku Soranoba. All rights reserved.
//

#import "MUKErrorCode.h"
#import "MUKSerializing.h"
#import <Foundation/Foundation.h>

@interface MUKSerializer : NSObject

/// An array of MUKSerializing class.
/// When modelFromXXX called, it will attempt to convert to the classes set here.
@property (nonatomic, nonnull, copy) NSArray<Class>* serializableClasses;

#pragma mark - Public Methods

/**
 * @see modelFromString:error:
 */
- (id<MUKSerializing> _Nullable)modelFromString:(NSString* _Nonnull)string
                                          error:(NSError* _Nullable* _Nullable)error;

/**
 * Convert to model from string
 *
 * @param string       A string of playlist.
 * @param playlistUrl  A URL of playlist
 * @param error        When it returns nil, more detailed error information needs to be stored here.
 * @return A model instance of playlist
 */
- (id<MUKSerializing> _Nullable)modelFromString:(NSString* _Nonnull)string
                                        withUrl:(NSURL* _Nullable)playlistUrl
                                          error:(NSError* _Nullable* _Nullable)error;

/**
 * Convert to NSString from NSData of UTF 8 and then parse.
 *
 * @see modelFromString:withUrl:error:
 */
- (id<MUKSerializing> _Nullable)modelFromData:(NSData* _Nonnull)data
                                      withUrl:(NSURL* _Nullable)playlistUrl
                                        error:(NSError* _Nullable* _Nullable)error;

/**
 * Convert to NSString from NSData and then parse.
 *
 * @see modelFromString:withUrl:error:
 */
- (id<MUKSerializing> _Nullable)modelFromData:(NSData* _Nonnull)data
                                     encoding:(NSStringEncoding)encoding
                                      withUrl:(NSURL* _Nullable)playlistUrl
                                        error:(NSError* _Nullable* _Nullable)error;

/**
 * Convert to NSString from Model
 *
 * @param model  A model instance of playlist.
 * @param error  When it returns nil, more detailed error information needs to be stored here.
 * @return A string of playlist.
 */
- (NSString* _Nullable)stringFromModel:(id<MUKSerializing> _Nonnull)model
                                 error:(NSError* _Nullable* _Nullable)error;

/**
 * The encoding of the generated NSData is UTF 8
 *
 * @see stringFromModel:error:
 */
- (NSData* _Nullable)dataFromModel:(id<MUKSerializing> _Nonnull)model
                             error:(NSError* _Nullable* _Nullable)error;

/**
 * @see stringFromModel:error:
 */
- (NSData* _Nullable)dataFromModel:(id<MUKSerializing> _Nonnull)model
                          encoding:(NSStringEncoding)encoding
                             error:(NSError* _Nullable* _Nullable)error;

@end
