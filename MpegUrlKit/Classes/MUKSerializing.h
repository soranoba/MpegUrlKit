//
//  MUKSerializing.h
//  MpegUrlKit
//
//  Created by Hinagiku Soranoba on 2017/01/06.
//  Copyright © 2017年 Hinagiku Soranoba. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, MUKLineActionResult) {
    /// The line was supported, but it was considered abnormal data for reasons such as invalid.
    MUKLineActionResultErrored = -1,
    /// The line was ignored, because it is an unsupported.
    MUKLineActionResultIgnored = 0,
    /// The line was supported and processed.
    MUKLineActionResultProcessed = 1
};

typedef MUKLineActionResult (^MUKLineAction)(NSString* _Nonnull line, NSError* _Nullable* _Nullable error);

@protocol MUKSerializing <NSObject>

/**
 * Do not create other designated initializer.
 * MUKSerializing object is always initialized by this method.
 *
 * @return instance
 */
@required
- (instancetype _Nullable)init;

/**
 * If you want to do specific processing when starting serialize, initialize here.
 */
@optional
- (void)beginSerialization;

/**
 * Processing on a line.
 *
 * @param line   A string of a line.
 * @param error  When returning MUKLineActionResultErrored, more detailed error information needs to be stored here.
 * @return Processing result of the line.
 *         If it return MUKLineActionResultErrored, the serialize process is terminated halfway.
 */
@required
- (MUKLineActionResult)appendLine:(NSString* _Nonnull)line error:(NSError* _Nullable* _Nullable)error;

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

/**
 * Returns processing action by lines.
 *
 * @return Key is prefix string. Value is callback block, if line has prefix the key.
 *         Subclass needs to override this return value according to your implementation.
 */
- (NSDictionary<NSString*, MUKLineAction>* _Nonnull)lineActions;

@end
