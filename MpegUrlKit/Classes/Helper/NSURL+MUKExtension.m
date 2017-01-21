//
//  MpegUrlKit
//
//  Created by Hinagiku Soranoba on 2017/01/21.
//  Copyright © 2017年 Hinagiku Soranoba. All rights reserved.
//

#import "NSURL+MUKExtension.h"

@implementation NSURL (MUKExtension)

#pragma mark - Lifecycle

+ (instancetype _Nonnull)muk_URLWithString:(NSString* _Nonnull)urlString
                             relativeToURL:(NSURL* _Nonnull)baseUrl
{
    if (!baseUrl.path || [baseUrl.path hasSuffix:@"/"]) {
        return [self.class URLWithString:urlString relativeToURL:baseUrl];
    } else {
        NSString* path = [NSString stringWithFormat:@"%@/", baseUrl.path];
        NSString* rewriteBaseUrl = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@",
                                                              (baseUrl.scheme ?: @""), (baseUrl.scheme ? @"://" : @""),
                                                              (baseUrl.host ?: @""),
                                                              (baseUrl.port ? @":" : @""), (baseUrl.port ? [baseUrl.port stringValue] : @""),
                                                              path,
                                                              (baseUrl.query ? @"?" : @""), (baseUrl.query ?: @""),
                                                              (baseUrl.fragment ? @"#" : @""), (baseUrl.fragment ?: @"")];
        return [self.class URLWithString:urlString relativeToURL:[NSURL URLWithString:rewriteBaseUrl]];
    }
}

@end
