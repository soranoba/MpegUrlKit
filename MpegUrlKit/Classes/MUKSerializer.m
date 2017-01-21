//
//  MUKSerializer.m
//  MpegUrlKit
//
//  Created by Hinagiku Soranoba on 2017/01/06.
//  Copyright © 2017年 Hinagiku Soranoba. All rights reserved.
//

#import "MUKSerializer.h"
#import "MUKMasterPlaylist.h"
#import "MUKMediaPlaylist.h"

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

- (id _Nullable)serializeFromString:(NSString* _Nonnull)string error:(NSError* _Nullable* _Nullable)error
{
    NSMutableArray<id<MUKSerializing> >* objs = [NSMutableArray array];
    __block NSError* tmpError;

    for (Class class in self.serializableClasses) {
        id<MUKSerializing> obj = [[class alloc] initWithPlaylistUrl:nil];
        if (obj) {
            [obj beginSerialization];
            [objs addObject:obj];
        }
    }

    [string enumerateLinesUsingBlock:^(NSString* _Nonnull line, BOOL* _Nonnull stop) {
        for (id<MUKSerializing> obj in objs) {
            if ([obj appendLine:line error:&tmpError] == MUKTagActionResultErrored) {
                [objs removeObject:obj];
                if (objs.count == 0) {
                    *stop = YES;
                }
            }
        }
    }];
    for (id<MUKSerializing> obj in objs) {
        [obj endSerialization];
        if (![obj validate:&tmpError]) {
            [objs removeObject:obj];
        }
    }

    if (objs.count) {
        return [objs firstObject];
    } else {
        if (error) {
            *error = tmpError;
        }
        return nil;
    }
}

- (id _Nullable)serializeFromData:(NSData* _Nonnull)data
{
    return [self serializeFromData:data encoding:kCFStringEncodingUTF8];
}

- (id _Nullable)serializeFromData:(NSData* _Nonnull)data encoding:(NSStringEncoding)encoding
{
    NSParameterAssert(data != nil);

    NSString* str = [[NSString alloc] initWithData:data encoding:encoding];
    return [self serializeFromString:str error:nil];
}

@end
