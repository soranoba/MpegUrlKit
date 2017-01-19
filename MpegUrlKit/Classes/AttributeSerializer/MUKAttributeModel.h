//
//  MUKAttributeModel.h
//  MpegUrlKit
//
//  Created by Hinagiku Soranoba on 2017/01/15.
//  Copyright © 2017年 Hinagiku Soranoba. All rights reserved.
//

#import "MUKTransformer.h"
#import <Foundation/Foundation.h>

/**
 * The model of AttributeList MUST implement this protocol.
 *
 * ## Transformer
 *
 * ```
 * + (MUKTransformer* _Nonnull) ${propertyName}Transformer;
 * ```
 *
 * If you define a method according to the above naming convention, 
 * you can specify that the conversion method of serialize / deserizlize of that property is different from ordinary.
 *
 * Please refer to MUKTransformer's documents.
 */
@protocol MUKAttributeSerializing <NSObject>

/**
 * It define the association between key of attribute and property name of the model.
 *
 * ```
 * + (NSDictionary*)keyByPropertyKey
 * {
 *     return @{ @"NAME" : @"name" };
 * }
 * ```
 *
 * @return A dictionary of the association.
 *         Its keys are keys of attribute. Its values are property names of the model.
 */
@required
+ (NSDictionary<NSString*, NSString*>* _Nonnull)keyByPropertyKey;

/**
 * When converting from model to a string, it specify the order of attribute.
 *
 * ```
 * + (NSArray*)attributeOrder
 * {
 *     return @[ @"NAME", @"VALUE" ];
 * }
 * ```
 *
 * @return An array of attribute keys.
 *         All its values MUST be contained keyByPropertyKey.
 */
@optional
+ (NSArray<NSString*>* _Nonnull)attributeOrder;

/**
 * This model is not supported on EXT-X-VERSION that is less than the value.
 *
 * If it is undefined, minimumModelSupportedVersion is implicitly 1.
 */
@optional
+ (NSUInteger)minimumModelSupportedVersion;

/**
 * This attributes is not supported on EXT-X-VERSION that is less than the value.
 *
 * If it is undefined or it is not contain the value, it is implicity 1.
 */
@optional
+ (NSDictionary<NSString*, NSNumber*>* _Nonnull)minimumAttributeSupportedVersions;

/**
 * It will called after convert from string to model and before validatation.
 *
 * @param attributes  The attributes parsed input string.
 * @param error       If it return NO, detailed error information is saved here.
 * @return If it is correct, it return YES. Otherwise, return NO.
 */
@optional
- (BOOL)finalizeOfFromStringWithAttributes:(NSDictionary<NSString*, MUKAttributeValue*>* _Nonnull)attributes
                                     error:(NSError* _Nullable* _Nullable)error;

/**
 * It will called after convert to string from model.
 *
 * @param attributeString  A string converted from model.
 * @param error            If it return nil, detailed error information is saved here.
 * @return If it is correct, it return final result of conversion to a string. Otherwise, return nil.
 */
@optional
- (NSString* _Nullable)finalizeOfToString:(NSString* _Nonnull)attributeString
                                    error:(NSError* _Nullable* _Nullable)error;

@end

/**
 * The model of AttributeList MUST inherit this class.
 *
 * Please override validate: if necessary.
 */
@interface MUKAttributeModel : NSObject

#pragma mark - Public Method

/**
 * Validate and return YES if it is correct.
 *
 * @param error  If it return NO, detailed error information is saved here.
 * @return If it is correct, it return YES. Otherwise, return NO.
 */
- (BOOL)validate:(NSError* _Nullable* _Nullable)error;

@end
