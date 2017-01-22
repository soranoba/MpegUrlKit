//
//  MUKXSessionData.h
//  MpegUrlKit
//
//  Created by Hinagiku Soranoba on 2017/01/15.
//  Copyright © 2017年 Hinagiku Soranoba. All rights reserved.
//

#import "MUKAttributeModel.h"
#import "MUKErrorCode.h"
#import <Foundation/Foundation.h>

/**
 * 4.3.4.4. EXT-X-SESSION-DATA
 * It carries session data.
 */
@interface MUKXSessionData : MUKAttributeModel <MUKAttributeSerializing>

/// It is identifies.
/// It SHOULD conform to a reverse DNS naming convention, such as "com.example.movie.title"
@property (nonatomic, nonnull, copy, readonly) NSString* dataId;

/// It contains the data identified by DATA-ID.
@property (nonatomic, nullable, copy, readonly) NSString* value;

/// The uri specifies contents that be formatted JSON.
@property (nonatomic, nullable, strong, readonly) NSURL* uri;

/// It is a language tag (RFC5646)
@property (nonatomic, nullable, copy, readonly) NSString* language;

#pragma mark - Lifecycle

/**
 * Create an instance.
 *
 * @param dataId    DATA-ID field.
 * @param value     VALUE field.
 * @param uri       URI field.
 * @param language  LANGUAGE field.
 * @return instance
 */
- (instancetype _Nullable)initWithDataId:(NSString* _Nonnull)dataId
                                   value:(NSString* _Nullable)value
                                     uri:(NSString* _Nullable)uri
                                language:(NSString* _Nullable)language;

@end
