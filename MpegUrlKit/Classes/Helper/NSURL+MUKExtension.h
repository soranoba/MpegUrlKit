//
//  NSURL+MUKExtension.h
//  MpegUrlKit
//
//  Created by Hinagiku Soranoba on 2017/01/21.
//  Copyright © 2017年 Hinagiku Soranoba. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (MUKExtension)

#pragma mark - Lifecycle

/**
 * URLWithString:relativeToURL behaves incorrectly if `/` does not exist at the end of baseURL.
 * It corresponds to this initializer
 *
 * @see NSURL # URLWithString:relativeToURL
 */
+ (instancetype _Nonnull)muk_URLWithString:(NSString* _Nonnull)urlString
                             relativeToURL:(NSURL* _Nonnull)baseUrl;

@end
