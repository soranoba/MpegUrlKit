//
//  MUKAttributeSerializer.h
//  MpegUrlKit
//
//  Created by Hinagiku Soranoba on 2017/01/15.
//  Copyright © 2017年 Hinagiku Soranoba. All rights reserved.
//

#import "MUKAttributeModel.h"
#import "MUKAttributeValue.h"
#import "MUKErrorCode.h"
#import <Foundation/Foundation.h>

/*
 * 4.2. Attribute Lists.
 *
 * This class is performs character string conversion of attribute list.
 */
@interface MUKAttributeSerializer : NSObject

/**
 * Create an instance.
 *
 * @param version A version specified EXT-X-VERSION. It is a number of NSUInteger.
 * @param baseUri A uri of the playlist uri.
 * @return instance
 */
- (instancetype _Nonnull)initWithVersion:(NSNumber* _Nullable)version
                                 baseUri:(NSURL* _Nullable)baseUri;

/**
 * Return a shared serializer instance.
 *
 * If you want to instance that have version is nil and baseUri is nil, you may call this method.
 *
 * @return instance
 */
+ (instancetype _Nonnull)sharedSerializer;

#pragma mark - Public Methods

/**
 * Convert to Model from NSString of AttributeList.
 *
 * @param modelClass The class MUST be subclass of MUKAttributeModel and MUST implement MUKAttributeSerializing.
 * @param string     A string of AttributeList.
 * @param error      If it return NO, detailed error information is saved here.
 * @return If serializing success, it returns instance of the modelClass. Otherwise, it returns nil.
 */
- (id<MUKAttributeSerializing> _Nullable)modelOfClass:(Class _Nonnull)modelClass
                                           fromString:(NSString* _Nonnull)string
                                                error:(NSError* _Nullable* _Nullable)error;

/**
 * Convert to NSString from MUKAttributeSerializing model object.
 *
 * @param model  The model.class MUST be subclass of MUKAttributeModel and MUST implement MUKAttributeSerializing.
 * @param error  If it return NO, detailed error information is saved here.
 * @return If deserializing success, it returns a string of AttributeList. Otherwise, it returns nil.
 */
- (NSString* _Nullable)stringFromModel:(id<MUKAttributeSerializing> _Nonnull)model
                                 error:(NSError* _Nullable* _Nullable)error;

#pragma mark Helper Methods for Conversion

/**
 * Convert to NSDictionary from NSString of AttributeList.
 *
 * @param string A string of AttributeList.
 * @param error  If it return NO, detailed error information is saved here.
 * @return A dictionary of MUKAttributeList.
 */
+ (NSDictionary<NSString*, MUKAttributeValue*>* _Nullable)parseFromString:(NSString* _Nonnull)string
                                                                    error:(NSError* _Nullable* _Nullable)error;

/**
 * Convert to NSString from NSDictionary of AttributeList.
 *
 * @param attributes   An attributes
 * @param orderedKeys  An array of attribute keys. All its values MUST be contained attributes.
 * @param error        If it return NO, detailed error information is saved here.
 * @return A string of AttributeList.
 */
+ (NSString* _Nullable)makeStringFromDict:(NSDictionary<NSString*, MUKAttributeValue*>* _Nonnull)attributes
                                    order:(NSArray<NSString*>* _Nonnull)orderedKeys
                                    error:(NSError* _Nullable* _Nullable)error;

@end
