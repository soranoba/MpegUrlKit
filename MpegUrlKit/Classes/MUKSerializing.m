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

- (instancetype _Nullable)init
{
    if (self = [super init]) {
        self.playlistUrl = nil;
    }
    return self;
}

- (instancetype _Nullable)initWithPlaylistUrl:(NSURL* _Nullable)url
{
    if (self = [super init]) {
        self.playlistUrl = url;
    }
    return self;
}

#pragma mark - Custom Accessor

- (void)setPlaylistUrl:(NSURL* _Nullable)playlistUrl
{
    _playlistUrl = playlistUrl;
    self.serializer = [[MUKAttributeSerializer alloc] initWithVersion:nil baseUri:self.playlistUrl];
}

#pragma mark - Public Methods

- (NSDictionary<NSString*, MUKTagAction>* _Nonnull)tagActions
{
    return @{};
}

#pragma mark - MUKSerializing

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

- (void)finalizeForToModel
{
    // NOP
}

- (NSDictionary<NSString*, id>* _Nonnull)renderObject
{
    return @{};
}

- (NSString* _Nonnull)renderTemplate
{
    return @"";
}

- (BOOL)validate:(NSError* _Nullable* _Nullable)error
{
    return YES;
}

@end
