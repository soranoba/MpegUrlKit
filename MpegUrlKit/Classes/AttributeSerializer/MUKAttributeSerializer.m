//
//  MUKAttributeSerializer.m
//  MpegUrlKit
//
//  Created by Hinagiku Soranoba on 2017/01/15.
//  Copyright © 2017年 Hinagiku Soranoba. All rights reserved.
//

#import "MUKAttributeSerializer.h"
#import "MUKAttributeValue.h"
#import "MUKTypeEncoding.h"
#import "NSError+MUKErrorDomain.h"
#import "NSString+MUKExtension.h"
#import <objc/runtime.h>

@interface MUKAttributeSerializer ()
@property (nonatomic, assign) NSUInteger version;
@property (nonatomic, nullable, copy) NSURL* baseUri;
@end

@implementation MUKAttributeSerializer

#pragma mark - Lifecycle

- (instancetype _Nonnull)initWithVersion:(NSNumber* _Nullable)version
                                 baseUri:(NSURL* _Nullable)baseUri
{
    if (self = [super init]) {
        self.version = version ? [version unsignedIntegerValue] : NSUIntegerMax;
        self.baseUri = baseUri;
    }
    return self;
}

+ (instancetype _Nonnull)sharedSerializer
{
    static MUKAttributeSerializer* sharedObj = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedObj = [[MUKAttributeSerializer alloc] initWithVersion:nil baseUri:nil];
    });
    return sharedObj;
}

#pragma mark - Public Methods

- (id<MUKAttributeSerializing> _Nullable)modelOfClass:(Class _Nonnull)modelClass
                                           fromString:(NSString* _Nonnull)string
                                                error:(NSError* _Nullable* _Nullable)error
{
    NSParameterAssert(modelClass != nil);
    NSParameterAssert([modelClass conformsToProtocol:@protocol(MUKAttributeSerializing)]);
    NSParameterAssert([modelClass isSubclassOfClass:MUKAttributeModel.class]);

    if ([modelClass respondsToSelector:@selector(minimumModelSupportedVersion)]) {
        if (self.version > [modelClass minimumModelSupportedVersion]) {
            SET_ERROR(error, MUKErrorUnsupportedVersion,
                      ([NSString stringWithFormat:@"EXT-X-VERSION is %tu, but %@ is NOT supported less than %tu",
                                                  self.version, modelClass, [modelClass minimumModelSupportedVersion]]));
            return nil;
        }
    }

    NSDictionary<NSString*, MUKAttributeValue*>* attributes = [self.class parseFromString:string error:error];
    if (!attributes) {
        return nil;
    }

    id modelObj = [modelClass new];
    NSDictionary<NSString*, NSString*>* keyByKey = [modelClass keyByPropertyKey];
    NSDictionary<NSString*, NSNumber*>* versions;
    if ([modelClass respondsToSelector:@selector(minimumAttributeSupportedVersions)]) {
        versions = [modelClass minimumAttributeSupportedVersions];
    } else {
        versions = [NSDictionary dictionary];
    }

    MUKAttributeValue* value;
    for (NSString* attributeKey in keyByKey) {
        id transformedObj = nil;

        if (!(value = attributes[attributeKey])) {
            continue;
        }

        if (versions[attributeKey] && [versions[attributeKey] unsignedIntegerValue] > self.version) {
            continue;
        }

        NSString* propertyKey = keyByKey[attributeKey];

        // transform
        SEL transformerSel = [self.class makeSelectorWithPrefix:propertyKey suffix:"Transformer"];
        if (transformerSel) {
            if ([modelClass respondsToSelector:transformerSel]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                MUKTransformer* transformer = [modelClass performSelector:transformerSel];
#pragma clang diagnostic pop
                if ([transformer isKindOfClass:MUKTransformer.class] && [transformer hasTransformBlock]) {
                    transformedObj = [transformer transformedValue:value];
                    if (transformedObj) {
                        [modelObj setValue:transformedObj forKey:propertyKey];
                        continue;
                    } else {
                        SET_ERROR(error, MUKErrorInvalidType,
                                  ([NSString stringWithFormat:@"The value of %@ is invalid", attributeKey]));
                        return nil;
                    }
                }
            }
        }

        if (![self.class setValue:value forObject:modelObj forKey:propertyKey error:error]) {
            return nil;
        }
    }

    if ([modelObj respondsToSelector:@selector(validate:)]) {
        if (![modelObj validate:error]) {
            return nil;
        }
    }

    if ([modelObj respondsToSelector:@selector(finalizeOfFromStringWithAttributes:error:)]) {
        if (![modelObj finalizeOfFromStringWithAttributes:attributes error:error]) {
            return nil;
        }
    }
    return modelObj;
}

- (NSString* _Nullable)stringFromModel:(id<MUKAttributeSerializing> _Nonnull)model
                                 error:(NSError* _Nullable* _Nullable)error
{
    NSParameterAssert([model.class conformsToProtocol:@protocol(MUKAttributeSerializing)]);
    NSParameterAssert([model.class isSubclassOfClass:MUKAttributeModel.class]);

    if ([model.class respondsToSelector:@selector(minimumModelSupportedVersion)]) {
        if (self.version > [model.class minimumModelSupportedVersion]) {
            SET_ERROR(error, MUKErrorUnsupportedVersion,
                      ([NSString stringWithFormat:@"EXT-X-VERSION is %tu, but %@ is NOT supported less than %tu",
                                                  self.version, model.class, [model.class minimumModelSupportedVersion]]));
            return nil;
        }
    }

    NSArray<NSString*>* order;
    if ([model.class respondsToSelector:@selector(attributeOrder)]) {
        order = [model.class attributeOrder];
    } else {
        order = [[model.class keyByPropertyKey] allKeys];
    }

    NSDictionary<NSString*, NSString*>* keyByKey = [[model class] keyByPropertyKey];
    NSMutableDictionary<NSString*, MUKAttributeValue*>* attributes = [NSMutableDictionary dictionary];
    NSDictionary<NSString*, NSNumber*>* versions;
    if ([model.class respondsToSelector:@selector(minimumAttributeSupportedVersions)]) {
        versions = [model.class minimumAttributeSupportedVersions];
    } else {
        versions = [NSDictionary dictionary];
    }

    for (NSString* attributeKey in keyByKey) {
        NSString* propertyKey = keyByKey[attributeKey];

        if (versions[attributeKey] && [versions[attributeKey] unsignedIntegerValue] > self.version) {
            continue;
        }

        // transform
        SEL transformerSel = [self.class makeSelectorWithPrefix:propertyKey suffix:"Transformer"];
        if (transformerSel) {
            if ([[model class] respondsToSelector:transformerSel]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                MUKTransformer* transformer = [[model class] performSelector:transformerSel];
#pragma clang diagnostic pop
                if ([transformer isKindOfClass:MUKTransformer.class] && [transformer hasReverseTransformBlock]) {
                    MUKAttributeValue* transformedValue = [transformer reverseTransformedValue:[(NSObject*)model valueForKey:propertyKey]];
                    if (transformedValue) {
                        attributes[attributeKey] = transformedValue;
                    }
                    continue;
                }
            }
        }

        MUKAttributeValue* v = [self.class valueForObject:model forKey:propertyKey];
        if (v) {
            attributes[attributeKey] = v;
        }
    }

    NSString* serializingStr = [self.class makeStringFromDict:attributes order:order error:error];
    if (serializingStr && [model respondsToSelector:@selector(finalizeOfToString:error:)]) {
        return [model finalizeOfToString:serializingStr error:error];
    }
    return serializingStr;
}

#pragma mark - Private Methods

/**
 * Parse the attribute list.
 *
 * @param string          A string of attribute list
 * @param error           If it return nil, detailed error information is saved here.
 * @return Return nil, if it parse failed. Otherwise, return attribute key-value pairs.
 */
+ (NSDictionary<NSString*, MUKAttributeValue*>* _Nullable)parseFromString:(NSString* _Nonnull)string
                                                                    error:(NSError* _Nullable* _Nullable)error
{
    NSParameterAssert(string != nil);

    NSMutableDictionary<NSString*, MUKAttributeValue*>* attributes = [NSMutableDictionary dictionary];
    NSString *key = nil, *value = nil;
    NSUInteger i, p;

    for (i = 0, p = 0; i < string.length; i++) {
        if ([string characterAtIndex:i] != '=') {
            continue;
        }

        key = [string substringWithRange:NSMakeRange(p, i - p)];
        if (attributes[key]) {
            SET_ERROR(error, MUKErrorInvalidAttributeList,
                      ([NSString stringWithFormat:@"The same attribute key MUST NOT be present. Duplicate key is %@", key]));
            return nil;
        }
        p = ++i;

        if ([string characterAtIndex:i] == '"') { // quoted-string
            for (p = ++i; i < string.length; i++) {
                if ([string characterAtIndex:i] != '"') {
                    continue;
                }

                value = [string substringWithRange:NSMakeRange(p, i - p)];
                if (++i >= string.length || [string characterAtIndex:i] == ',') {
                    attributes[key] = [[MUKAttributeValue alloc] initWithValue:value isQuotedString:YES];
                    break;
                } else {
                    SET_ERROR(error, MUKErrorInvalidAttributeList, @"Characters are present outside double quotes");
                    return nil;
                }
            }
            if (!value) {
                SET_ERROR(error, MUKErrorInvalidAttributeList, @"Quoted-string has not ended");
                return nil;
            }
        } else { // other
            for (; i < string.length; i++) {
                if ([string characterAtIndex:i] == ',') {
                    break;
                }
            }
            value = [string substringWithRange:NSMakeRange(p, i - p)];
            attributes[key] = [[MUKAttributeValue alloc] initWithValue:value isQuotedString:NO];
        }

        if (![attributes[key] validate:error]) {
            return nil;
        }

        p = ++i;
        value = nil;
    }

    if (p + 1 != i) {
        SET_ERROR(error, MUKErrorInvalidAttributeList, @"key-value pairs are broken");
        return nil;
    }
    return attributes;
}

/**
 * Make a string of attribute list
 *
 * @param attributes A attribute key-value pairs.
 * @param order      An array of attribute key which is in display order.
 * @param error      If it return nil, detailed error information is saved here.
 * @return Return nil, if it failed. Otherwise, return a string of attribute list.
 */
+ (NSString* _Nullable)makeStringFromDict:(NSDictionary<NSString*, MUKAttributeValue*>* _Nonnull)attributes
                                    order:(NSArray<NSString*>* _Nonnull)orderedKeys
                                    error:(NSError* _Nullable* _Nullable)error
{
    NSParameterAssert(attributes != nil && orderedKeys != nil);

    NSMutableString* result = [NSMutableString string];
    for (NSString* key in orderedKeys) {
        MUKAttributeValue* value = attributes[key];
        if (!value) {
            continue;
        }

        if (![value validate:error]) {
            return nil;
        }

        if (result.length != 0) {
            [result appendString:@","];
        }

        if (value.isQuotedString) {
            [result appendFormat:@"%@=\"%@\"", key, value.value];
        } else {
            [result appendFormat:@"%@=%@", key, value.value];
        }
    }
    return result;
}

/**
 * Create SEL from prefix and suffix
 *
 * @param prefix Prefix of method name
 * @param suffix Suffix of method name
 * @return A selector.
 */
+ (SEL _Nullable)makeSelectorWithPrefix:(NSString* _Nonnull)prefix suffix:(const char*)suffix
{
    NSUInteger prefixLength = [prefix maximumLengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    NSUInteger suffixLength = strlen(suffix);

    char transformerMethodName[prefixLength + suffixLength + 1];
    memset(transformerMethodName, 0, prefixLength + suffixLength + 1);

    if (![prefix getBytes:&transformerMethodName
                 maxLength:prefixLength
                usedLength:&prefixLength
                  encoding:NSUTF8StringEncoding
                   options:0
                     range:NSMakeRange(0, prefix.length)
            remainingRange:NULL]) {
        return nil;
    }

    memcpy(transformerMethodName + prefixLength, suffix, suffixLength);
    return sel_registerName(transformerMethodName);
}

/**
 * Takes a value from the specified property of the object, and converts it to MUKAttributeValue and returns it.
 *
 * @param object      An object that has property.
 * @param propertyKey A key of specified property.
 * @return If it can take a value and convert to MUKAttributeValue, it return converted value.
 *         Otherwise, it return nil.
 */
+ (MUKAttributeValue* _Nullable)valueForObject:(id _Nonnull)object
                                        forKey:(NSString* _Nonnull)propertyKey
{
    id value = [object valueForKey:propertyKey];
    if (!value) {
        return nil;
    }

    objc_property_t property = class_getProperty([object class], propertyKey.UTF8String);
    NSAssert(property != nil, @"Property is not exist. Property name is %@", propertyKey);

    MUKTypeEncoding* enc = [[MUKTypeEncoding alloc] initWithProperty:property];
    if (strcmp(enc.objCType, @encode(double)) == 0) {
        return [[MUKAttributeValue alloc] initWithValue:[NSString muk_stringWithDouble:[value doubleValue]]
                                         isQuotedString:NO];
    } else if (strcmp(enc.objCType, @encode(BOOL)) == 0) {
        return [[MUKAttributeValue alloc] initWithValue:([value boolValue] == YES ? @"YES" : @"NO")
                                         isQuotedString:NO];
    } else if (strcmp(enc.objCType, @encode(NSUInteger)) == 0) {
        return [[MUKAttributeValue alloc] initWithValue:[NSString muk_stringWithDecimal:[value unsignedIntegerValue]]
                                         isQuotedString:NO];
    } else if (strcmp(enc.objCType, @encode(CGSize)) == 0) {
        return [[MUKAttributeValue alloc] initWithValue:[NSString muk_stringWithSize:[value CGSizeValue]]
                                         isQuotedString:NO];
    } else if (strcmp(enc.objCType, @encode(id)) == 0) {
        if (enc.klass == NSString.class) {
            return [[MUKAttributeValue alloc] initWithValue:value
                                             isQuotedString:YES];
        } else if (enc.klass == NSDate.class) {
            return [[MUKAttributeValue alloc] initWithValue:[NSString muk_stringWithDate:value]
                                             isQuotedString:YES];
        } else if (enc.klass == NSData.class) {
            return [[MUKAttributeValue alloc] initWithValue:[NSString muk_stringHexWithData:value]
                                             isQuotedString:NO];
        }
    }

    NSAssert(NO, @"%@ # %@ is unsupported type", [object class], propertyKey);
    return nil;
}

/**
 * Set the value for the specified property of the object.
 *
 * @param value       A value to set
 * @param object      An object that has property.
 * @param propertyKey A key of specified property.
 * @param error       If it return NO, detailed error information is saved here.
 * @return If it is succeeded, it returns YES. Otherwise, it returns NO.
 */
+ (BOOL)setValue:(MUKAttributeValue* _Nonnull)value
       forObject:(id _Nonnull)object
          forKey:(NSString* _Nonnull)propertyKey
           error:(NSError* _Nullable* _Nullable)error
{
    objc_property_t property = class_getProperty([object class], propertyKey.UTF8String);

    NSAssert(property != nil, @"Property is not exist. Property name is %@", propertyKey);
    MUKTypeEncoding* enc = [[MUKTypeEncoding alloc] initWithProperty:property];

    BOOL supportedClass = NO;
    BOOL isError = NO;

    if (strcmp(enc.objCType, @encode(id)) == 0) {
        if (!supportedClass && (supportedClass |= (enc.klass == NSString.class)) && value.isQuotedString) {
            [object setValue:value.value forKey:propertyKey];
        } else if (!supportedClass && (supportedClass |= (enc.klass == NSDate.class)) && value.isQuotedString) {
            NSDate* date;
            if (![value.value muk_scanDate:&date error:error]) {
                return NO;
            }
            [object setValue:date forKey:propertyKey];
        } else if (!supportedClass && (supportedClass |= (enc.klass == NSData.class)) && !value.isQuotedString) {
            NSData* data;
            if (![value.value muk_scanHexadecimal:&data error:error]) {
                return NO;
            }
            [object setValue:data forKey:propertyKey];
        } else {
            isError = YES;
        }
    } else if (!supportedClass && (supportedClass |= (strcmp(enc.objCType, @encode(double)) == 0)) && !value.isQuotedString) {
        double d;
        if (![value.value muk_scanDouble:&d error:error]) {
            return NO;
        }
        [object setValue:@(d) forKey:propertyKey];
    } else if (!supportedClass && (supportedClass |= (strcmp(enc.objCType, @encode(BOOL)) == 0)) && !value.isQuotedString) {
        if ([value.value isEqualToString:@"YES"]) {
            [object setValue:@(YES) forKey:propertyKey];
        } else if ([value.value isEqualToString:@"NO"]) {
            [object setValue:@(NO) forKey:propertyKey];
        } else {
            SET_ERROR(error, MUKErrorInvalidType,
                      ([NSString stringWithFormat:@"%@ MUST be either YES or NO", propertyKey]));
            return NO;
        }
    } else if (!supportedClass && (supportedClass |= (strcmp(enc.objCType, @encode(NSUInteger)) == 0)) && !value.isQuotedString) {
        NSUInteger i;
        if (![value.value muk_scanDecimalInteger:&i error:error]) {
            return NO;
        }
        [object setValue:@(i) forKey:propertyKey];
    } else if (!supportedClass && (supportedClass |= (strcmp(enc.objCType, @encode(CGSize)) == 0)) && !value.isQuotedString) {
        CGSize size;
        if (![value.value muk_scanDecimalResolution:&size error:error]) {
            return NO;
        }
        [object setValue:[NSValue valueWithBytes:&size objCType:@encode(CGSize)] forKey:propertyKey];
    } else {
        isError = YES;
    }

    if (!isError) {
        return YES;
    }

    if (supportedClass) {
        SET_ERROR(error, MUKErrorInvalidType,
                  ([NSString stringWithFormat:@"%@ MUST %@be quoted-string",
                                              propertyKey, (value.isQuotedString ? @"NOT " : @"")]));
    } else {
        NSString* reason = [NSString stringWithFormat:@"%@ # %@ is unsupported type", [object class], propertyKey];
        NSAssert(NO, reason);
        SET_ERROR(error, MUKErrorInvalidType, reason);
    }
    return NO;
}

@end
