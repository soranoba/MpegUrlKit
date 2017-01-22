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
 *
 * A class that associates a range of time defined by a starting and ending date.
 */
@interface MUKXDateRange : MUKAttributeModel <MUKAttributeSerializing>

/// A uniquely identifier of a DateRange in the Playlist.
@property (nonatomic, nonnull, copy, readonly) NSString* identifier;
/// It specifies some set of attributes and their associated value semantics.
@property (nonatomic, nullable, copy, readonly) NSString* klass;

/// A starting date of the DateRange.
@property (nonatomic, nonnull, strong, readonly) NSDate* startDate;
/// A ending date of the DateRange.
/// In some cases, the duration exists but the endDate does not exist.
@property (nonatomic, nullable, strong, readonly) NSDate* endDate;
/// A duration of the DateRange.
/// In some cases, the endDate exists but the duration does not exist.
@property (nonatomic, nullable, strong, readonly) NSNumber* duration;
/// The expected duration of the DateRange.
@property (nonatomic, nullable, strong, readonly) NSNumber* plannedDuration;

/// It indicates that the end of the range containing it is equal to the startDate of its Following Range.
@property (nonatomic, assign, readonly, getter=isEndOnNext) BOOL endOnNext;

/// Used to carry SCTE-35 data.
@property (nonatomic, nullable, copy, readonly) NSData* scte35Cmd;
@property (nonatomic, nullable, copy, readonly) NSData* scte35Out;
@property (nonatomic, nullable, copy, readonly) NSData* scte35In;

/// User-defined attributes. Its key MUST have prefix `X-`.
@property (nonatomic, nonnull, copy, readonly) NSDictionary<NSString*, MUKAttributeValue*>* userDefinedAttributes;

#pragma mark - Lifecycle

/**
 * Create a instance
 *
 * @param identifier      ID
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
- (instancetype _Nonnull)initWithId:(NSString* _Nonnull)identifier
                              klass:(NSString* _Nullable)klass
                              start:(NSDate* _Nonnull)startDate
                                end:(NSDate* _Nullable)endDate
                           duration:(NSNumber* _Nullable)duration
                    plannedDuration:(NSNumber* _Nullable)plannedDuration
                        isEndOnNext:(BOOL)isEndOnNext
                          scte35Cmd:(NSData* _Nullable)scte35Cmd
                          scte35Out:(NSData* _Nullable)scte35Out
                           scte35In:(NSData* _Nullable)scte35In
              userDefinedAttributes:(NSDictionary<NSString*, MUKAttributeValue*>* _Nullable)userDefinedAttributes;

@end
