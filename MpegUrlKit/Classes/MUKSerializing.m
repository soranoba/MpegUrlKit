//
//  MUKSerializing.m
//  MpegUrlKit
//
//  Created by Hinagiku Soranoba on 2017/01/06.
//  Copyright © 2017年 Hinagiku Soranoba. All rights reserved.
//

#import "MUKSerializing.h"

@implementation MUKSerializing

#pragma mark - Lifecycle

- (instancetype _Nullable)initWithPlaylistUrl:(NSURL* _Nullable)url
{
    if (self = [super init]) {
        self.playlistUrl = url;
        self.serializer = [[MUKAttributeSerializer alloc] initWithVersion:nil baseUri:self.playlistUrl];
    }
    return self;
}

#pragma mark - Public Methods

- (NSDictionary<NSString*, MUKTagAction>* _Nonnull)tagActions
{
    return @{};
}

#pragma mark - MUKSerializable

- (void)beginSerialization
{
    // NOP
}

- (MUKTagActionResult)appendLine:(NSString* _Nonnull)line error:(NSError* _Nullable* _Nullable)error
{
    NSDictionary<NSString*, MUKTagAction>* tagActions = self.tagActions;
    for (NSString* prefix in tagActions) {
        if (([prefix hasSuffix:@":"] && [line hasPrefix:prefix])
            || [line isEqualToString:prefix]) {

            NSString* value = [line substringWithRange:NSMakeRange(prefix.length, line.length - prefix.length)];
            return (tagActions[prefix])(value, error);
        }
    }
    if (tagActions[@""]) {
        return (tagActions[@""])(line, error);
    }
    return MUKTagActionResultIgnored;
}

- (void)endSerialization
{
    // NOP
}

- (BOOL)validate:(NSError* _Nullable* _Nullable)error
{
    return YES;
}

@end
