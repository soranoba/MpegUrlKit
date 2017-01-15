//
//  MUKXDateRange.h
//  MpegUrlKit
//
//  Created by Hinagiku Soranoba on 2017/01/08.
//  Copyright © 2017年 Hinagiku Soranoba. All rights reserved.
//

#import "MUKAttributeModel.h"
#import "MUKErrorCode.h"
#import <Foundation/Foundation.h>

/**
 * 4.3.2.7. EXT-X-DATERANGE
 */
@interface MUKXDateRange : MUKAttributeModel <MUKAttributeSerializing>

@property (nonatomic, nonnull, copy, readonly) NSString* identify;
@property (nonatomic, nullable, copy, readonly) NSString* klass;
@property (nonatomic, nonnull, strong, readonly) NSDate* startDate;
@property (nonatomic, nullable, strong, readonly) NSDate* endDate;
/// If duration is unknown, it return a negative value.
@property (nonatomic, assign, readonly) NSTimeInterval duration;
/// If plannedDuration is unknown, it return a negative value.
@property (nonatomic, assign, readonly) NSTimeInterval plannedDuration;
@property (nonatomic, assign, readonly) BOOL isEndOnNext;
@property (nonatomic, nullable, copy, readonly) NSData* scte35Cmd;
@property (nonatomic, nullable, copy, readonly) NSData* scte35Out;
@property (nonatomic, nullable, copy, readonly) NSData* scte35In;
@property (nonatomic, nonnull, copy, readonly) NSDictionary<NSString*, MUKAttributeValue*>* userDefinedAttributes;

#pragma mark - Lifecycle

/**
 * Create a instance
 *
 * @param identify        ID
 * @param klass           CLASS
 * @param startDate       START-DATE
 * @param endDate         END-DATE
 * @param duration        DURATION
 * @param plannedDuration PLANNED-DURATION
 * @param isEndOnNext     END-ON-NEXT
 * @param scte35Cmd       SCTE35-CMD
 * @param scte35Out       SCTE35-OUT
 * @param scte35In        SCTE35-IN
 * @param userDefinedAttributes  X-<client-attribute>
 * @return instance
 */
- (instancetype _Nonnull)initWithId:(NSString* _Nonnull)identify
                              klass:(NSString* _Nullable)klass
                              start:(NSDate* _Nonnull)startDate
                                end:(NSDate* _Nullable)endDate
                           duration:(NSTimeInterval)duration
                    plannedDuration:(NSTimeInterval)plannedDuration
                        isEndOnNext:(BOOL)isEndOnNext
                          scte35Cmd:(NSData* _Nullable)scte35Cmd
                          scte35Out:(NSData* _Nullable)scte35Out
                           scte35In:(NSData* _Nullable)scte35In
              userDefinedAttributes:(NSDictionary<NSString*, MUKAttributeValue*>* _Nullable)userDefinedAttributes;

@end
