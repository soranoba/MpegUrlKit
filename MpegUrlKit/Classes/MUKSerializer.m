//
//  MUKSerializer.m
//  MpegUrlKit
//
//  Created by Hinagiku Soranoba on 2017/01/06.
//  Copyright © 2017年 Hinagiku Soranoba. All rights reserved.
//

#import "MUKSerializer.h"
#import "MUKAttributeModel.h"
#import "MUKMasterPlaylist.h"
#import "MUKMediaPlaylist.h"
#import "NSError+MUKErrorDomain.h"

#ifdef MPEG_URL_KIT_MUSTACHE_ENABLE
#import <GRMustache/GRMustache.h>
#endif

@interface MUKSerializer ()

@end

@implementation MUKSerializer

#pragma mark - Lifecycle

- (instancetype _Nonnull)init
{
    if (self = [super init]) {
        self.serializableClasses = @[ MUKMediaPlaylist.class, MUKMasterPlaylist.class ];
    }
    return self;
}

#pragma mark - Custom Accessor

- (void)setSerializableClasses:(NSArray<Class>* _Nonnull)serializableClasses
{
    NSParameterAssert(serializableClasses != nil);

#if !defined(NS_BLOCK_ASSERTIONS)
    for (Class class in serializableClasses) {
        NSAssert([class conformsToProtocol:@protocol(MUKSerializing)],
                 @"%@ is NOT MUKSerializing class", class);
    }
#endif
    _serializableClasses = [serializableClasses copy];
}

#pragma mark - Public Methods

- (id<MUKSerializing> _Nullable)modelFromString:(NSString* _Nonnull)string
                                          error:(NSError* _Nullable* _Nullable)error
{
    return [self modelFromString:string withUrl:nil error:error];
}

- (id<MUKSerializing> _Nullable)modelFromString:(NSString* _Nonnull)string
                                        withUrl:(NSURL* _Nullable)url
                                          error:(NSError* _Nullable* _Nullable)error
{
    NSParameterAssert(string != nil);

    __block NSMutableArray<id<MUKSerializing> >* objs = [NSMutableArray array];
    __block NSMutableArray<id<MUKSerializing> >* processedObjs;
    __block NSMutableArray<id<MUKSerializing> >* ignoredObjs;

    __block NSError* tmpError;

    for (Class class in self.serializableClasses) {
        id<MUKSerializing> obj = [[class alloc] initWithPlaylistUrl:url];
        if (obj) {
            [objs addObject:obj];
        }
    }

    [string enumerateLinesUsingBlock:^(NSString* _Nonnull line, BOOL* _Nonnull stop) {
        processedObjs = [NSMutableArray arrayWithCapacity:objs.count];
        ignoredObjs = [NSMutableArray arrayWithCapacity:objs.count];

        for (id<MUKSerializing> obj in objs) {
            switch ([obj appendLine:line error:&tmpError]) {
                case MUKTagActionResultProcessed:
                    [processedObjs addObject:obj];
                    break;
                case MUKTagActionResultIgnored:
                    [ignoredObjs addObject:obj];
                    break;
                default:
                    break;
            }
        }

        if ([processedObjs count]) {
            objs = processedObjs;
        } else if ([ignoredObjs count]) {
            objs = ignoredObjs;
        } else {
            objs = [NSMutableArray array];
            *stop = YES;
        }
    }];

    for (id<MUKSerializing> obj in objs) {
        [obj finalizeForToModel];
        if ([obj validate:&tmpError]) {
            return obj;
        }
    }

    if (error) {
        *error = tmpError;
    }
    return nil;
}

- (id<MUKSerializing> _Nullable)modelFromData:(NSData* _Nonnull)data
                                      withUrl:(NSURL* _Nullable)url
                                        error:(NSError* _Nullable* _Nullable)error
{
    return [self modelFromData:data encoding:NSUTF8StringEncoding withUrl:url error:error];
}

- (id<MUKSerializing> _Nullable)modelFromData:(NSData* _Nonnull)data
                                     encoding:(NSStringEncoding)encoding
                                      withUrl:(NSURL* _Nullable)url
                                        error:(NSError* _Nullable* _Nullable)error
{
    NSParameterAssert(data != nil);

    NSString* str = [[NSString alloc] initWithData:data encoding:encoding];
    return [self modelFromString:str withUrl:url error:error];
}

- (NSString* _Nullable)stringFromModel:(id<MUKSerializing> _Nonnull)model
                                 error:(NSError* _Nullable* _Nullable)error
{
    NSParameterAssert([model conformsToProtocol:@protocol(MUKSerializing)]);

#ifdef MPEG_URL_KIT_MUSTACHE_ENABLE

    NSDictionary* originalObject = [model renderObject];
    NSMutableDictionary* object = [NSMutableDictionary dictionary];
    for (NSString* key in originalObject) {
        if ([key hasPrefix:@"#"]) {
            object[[key substringFromIndex:1]] = originalObject[key];
        } else {
            object[key] = originalObject[key];
        }
    }

    return [GRMustacheTemplate renderObject:object
                                 fromString:[model renderTemplate]
                                      error:error];

#else
    if (error) {
        *error = [NSError muk_errorWithMUKErrorCode:MUKErrorBuildSettings];
    }
    return nil;
#endif
}

- (NSData* _Nullable)dataFromModel:(id<MUKSerializing> _Nonnull)model
                             error:(NSError* _Nullable* _Nullable)error
{
    return [self dataFromModel:model encoding:NSUTF8StringEncoding error:error];
}

- (NSData* _Nullable)dataFromModel:(id<MUKSerializing> _Nonnull)model
                          encoding:(NSStringEncoding)encoding
                             error:(NSError* _Nullable* _Nullable)error
{
    NSString* str = [self stringFromModel:model error:error];
    if (!str) {
        return nil;
    }
    return [str dataUsingEncoding:encoding];
}

@end
