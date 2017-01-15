//
//  MUKXMap.h
//  MpegUrlKit
//
//  Created by Hinagiku Soranoba on 2017/01/08.
//  Copyright © 2017年 Hinagiku Soranoba. All rights reserved.
//

#import "MUKAttributeModel.h"
#import "MUKErrorCode.h"
#import <Foundation/Foundation.h>

/**
 * 4.3.2.5. EXT-X-MAP
 * It have information that how to obtain the Media Initialization Section required to parse the applicable Media Segments.
 * See also 3. Media Segments.
 */
@interface MUKXMap : MUKAttributeModel <MUKAttributeSerializing>

@property (nonatomic, nonnull, copy, readonly) NSString* uri;
/// If BYTERANGE is not found, byteRange.location returns NSNotFound.
/// Otherwise, it returns byteRange of resource that specified uri.
@property (nonatomic, assign, readonly) NSRange byteRange;

#pragma mark - Lifecycle

/**
 * Create a instance without byte range.
 *
 * @see initWithUri:range:
 */
- (instancetype _Nonnull)initWithUri:(NSString* _Nonnull)uri;

/**
 * Create a instance
 *
 * @param uri   A uri indicating resource.
 * @param range A byte range of resource that specified uri.
 * @return instance
 */
- (instancetype _Nonnull)initWithUri:(NSString* _Nonnull)uri
                               range:(NSRange)range;

@end
