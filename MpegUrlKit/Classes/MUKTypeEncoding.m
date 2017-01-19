//
//  MUKTypeEncoding.m
//  MpegUrlKit
//
//  Created by Hinagiku Soranoba on 2017/01/19.
//  Copyright © 2017年 Hinagiku Soranoba. All rights reserved.
//

#import "MUKTypeEncoding.h"

@interface MUKTypeEncoding ()
@property (nonatomic, nonnull, assign, readwrite) char* const objCType;
@property (nonatomic, nullable, copy, readwrite) Class klass;
@end

@implementation MUKTypeEncoding

#pragma mark - Lifecycle

- (instancetype _Nullable)init
{
    NSAssert(NO, @"%@ MUST initialize using the designed initializer", self.class);
    return nil;
}

- (instancetype _Nullable)initWithProperty:(objc_property_t _Nonnull)property
{
    NSParameterAssert(property != nil);

    if (self = [super init]) {
        const char* const attributeStr = property_getAttributes(property);

        if (attributeStr[0] != 'T') {
            return nil;
        }

        const char *start, *end;
        char* buf = nil;
        size_t size;

        if (attributeStr[1] == '@' && attributeStr[2] == '"') {
            start = &(attributeStr[3]);
            end = strchr(start, '"');

            size = sizeof(char) * (end - start + 1);
            buf = malloc(size);
            if (!buf) {
                return nil;
            }
            strncpy(buf, start, end - start);
            buf[end - start] = '\0';
            self.klass = NSClassFromString([NSString stringWithCString:buf encoding:NSString.defaultCStringEncoding]);
            free(buf);
            buf = nil;

            start = &(attributeStr[1]);
            end = &(attributeStr[2]);
        } else {
            start = &(attributeStr[1]);
            end = strchr(start, ',');
        }

        size = end - start + 1;
        buf = malloc(sizeof(char) * size);
        if (!buf) {
            return nil;
        }
        strncpy(buf, start, end - start);
        buf[end - start] = '\0';

        self.objCType = buf;
    }
    return self;
}

- (void)dealloc
{
    if (self.objCType) {
        free(self.objCType);
    }
}

@end
