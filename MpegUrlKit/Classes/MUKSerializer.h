//
//  MUKSerializer.h
//  MpegUrlKit
//
//  Created by Hinagiku Soranoba on 2017/01/06.
//  Copyright © 2017年 Hinagiku Soranoba. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MUKSerializer : NSObject

@property (nonatomic, nonnull, copy) NSArray<Class>* serializableClasses;

- (id _Nullable)serializeFromString:(NSString* _Nonnull)string error:(NSError* _Nullable* _Nullable)error;

- (id _Nullable)serializeFromData:(NSData* _Nonnull)data;

@end
