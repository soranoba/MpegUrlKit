//
//  MUKXMediaTests.m
//  MpegUrlKit
//
//  Created by Hinagiku Soranoba on 2017/01/14.
//  Copyright © 2017年 Hinagiku Soranoba. All rights reserved.
//

#import "MUKXMedia.h"

@interface MUKXMedia ()
@property (nonatomic, assign, readwrite) MUKXMediaType mediaType;
@property (nonatomic, nullable, copy, readwrite) NSURL* uri;
@property (nonatomic, nonnull, copy, readwrite) NSString* groupId;
@property (nonatomic, nullable, copy, readwrite) NSString* language;
@property (nonatomic, nullable, copy, readwrite) NSString* associatedLanguage;
@property (nonatomic, nonnull, copy, readwrite) NSString* name;
@property (nonatomic, assign, readwrite, getter=isDefaultRendition) BOOL defaultRendition;
@property (nonatomic, assign, readwrite, getter=canAutoSelect) BOOL autoSelect;
@property (nonatomic, assign, readwrite) BOOL forced;
@property (nonatomic, nullable, copy, readwrite) NSString* instreamId;
@property (nonatomic, nullable, copy, readwrite) NSArray<NSString*>* characteristics;
@property (nonatomic, nullable, copy, readwrite) NSArray<NSNumber*>* channels;

+ (MUKTransformer* _Nonnull)mediaTypeTransformer;
+ (MUKTransformer* _Nonnull)characteristicsTransformer;
+ (MUKTransformer* _Nonnull)channelsTransformer;
@end

QuickSpecBegin(MUKXMediaTests)
{
    describe(@"mediaTypeFromString:", ^{
        it(@"can convert to enum from string", ^{
            expect(@([MUKXMedia mediaTypeFromString:@"AUDIO"])).to(equal(MUKXMediaTypeAudio));
            expect(@([MUKXMedia mediaTypeFromString:@"VIDEO"])).to(equal(MUKXMediaTypeVideo));
            expect(@([MUKXMedia mediaTypeFromString:@"SUBTITLES"])).to(equal(MUKXMediaTypeSubtitles));
            expect(@([MUKXMedia mediaTypeFromString:@"CLOSED-CAPTIONS"])).to(equal(MUKXMediaTypeClosedCaptions));
            expect(@([MUKXMedia mediaTypeFromString:@"unknown"])).to(equal(MUKXMediaTypeUnknown));
        });
    });

    describe(@"mediaTypeToString:", ^{
        it(@"can convert to string from enum", ^{
            expect([MUKXMedia mediaTypeToString:MUKXMediaTypeAudio]).to(equal(@"AUDIO"));
            expect([MUKXMedia mediaTypeToString:MUKXMediaTypeVideo]).to(equal(@"VIDEO"));
            expect([MUKXMedia mediaTypeToString:MUKXMediaTypeSubtitles]).to(equal(@"SUBTITLES"));
            expect([MUKXMedia mediaTypeToString:MUKXMediaTypeClosedCaptions]).to(equal(@"CLOSED-CAPTIONS"));
            expect([MUKXMedia mediaTypeToString:MUKXMediaTypeUnknown]).to(beNil());
        });
    });

    describe(@"mediaTypeTransformer", ^{
        it(@"can convert to enum from string", ^{
            MUKAttributeValue* value = [[MUKAttributeValue alloc] initWithValue:@"AUDIO" isQuotedString:NO];
            expect([[MUKXMedia mediaTypeTransformer] transformedValue:value]).to(equal(MUKXMediaTypeAudio));

            value = [[MUKAttributeValue alloc] initWithValue:@"VIDEO" isQuotedString:NO];
            expect([[MUKXMedia mediaTypeTransformer] transformedValue:value]).to(equal(MUKXMediaTypeVideo));

            value = [[MUKAttributeValue alloc] initWithValue:@"SUBTITLES" isQuotedString:NO];
            expect([[MUKXMedia mediaTypeTransformer] transformedValue:value]).to(equal(MUKXMediaTypeSubtitles));

            value = [[MUKAttributeValue alloc] initWithValue:@"CLOSED-CAPTIONS" isQuotedString:NO];
            expect([[MUKXMedia mediaTypeTransformer] transformedValue:value]).to(equal(MUKXMediaTypeClosedCaptions));

            value = [[MUKAttributeValue alloc] initWithValue:@"AUDIO" isQuotedString:YES];
            expect([[MUKXMedia mediaTypeTransformer] transformedValue:value]).to(beNil());
        });

        it(@"can convert to string from enum", ^{
            MUKAttributeValue* value = [[MUKAttributeValue alloc] initWithValue:@"AUDIO" isQuotedString:NO];
            expect([[MUKXMedia mediaTypeTransformer] reverseTransformedValue:@(MUKXMediaTypeAudio)]).to(equal(value));

            value = [[MUKAttributeValue alloc] initWithValue:@"VIDEO" isQuotedString:NO];
            expect([[MUKXMedia mediaTypeTransformer] reverseTransformedValue:@(MUKXMediaTypeVideo)]).to(equal(value));

            value = [[MUKAttributeValue alloc] initWithValue:@"SUBTITLES" isQuotedString:NO];
            expect([[MUKXMedia mediaTypeTransformer] reverseTransformedValue:@(MUKXMediaTypeSubtitles)]).to(equal(value));

            value = [[MUKAttributeValue alloc] initWithValue:@"CLOSED-CAPTIONS" isQuotedString:NO];
            expect([[MUKXMedia mediaTypeTransformer] reverseTransformedValue:@(MUKXMediaTypeClosedCaptions)]).to(equal(value));

            expect([[MUKXMedia mediaTypeTransformer] reverseTransformedValue:@(MUKXMediaTypeUnknown)]).to(beNil());
        });
    });

    describe(@"characteristicsTransformer", ^{
        it(@"can convert to array from string", ^{
            MUKAttributeValue* value = [[MUKAttributeValue alloc] initWithValue:@"hoge,fugo" isQuotedString:YES];
            expect([[MUKXMedia characteristicsTransformer] transformedValue:value]).to(equal(@[ @"hoge", @"fugo" ]));

            value = [[MUKAttributeValue alloc] initWithValue:@"hoge,,fugo" isQuotedString:YES];
            expect([[MUKXMedia characteristicsTransformer] transformedValue:value]).to(equal(@[ @"hoge", @"", @"fugo" ]));

            value = [[MUKAttributeValue alloc] initWithValue:@"hoge" isQuotedString:NO];
            expect([[MUKXMedia characteristicsTransformer] transformedValue:value]).to(beNil());
        });

        it(@"can convert to string from array", ^{
            MUKAttributeValue* value = [[MUKAttributeValue alloc] initWithValue:@"hoge,fugo" isQuotedString:YES];
            expect([[MUKXMedia characteristicsTransformer] reverseTransformedValue:@[ @"hoge", @"fugo" ]]).to(equal(value));

            expect([[MUKXMedia characteristicsTransformer] reverseTransformedValue:@[]]).to(beNil());
        });
    });

    describe(@"channelsTransformer", ^{
        it(@"can convert to array from string", ^{
            MUKAttributeValue* value = [[MUKAttributeValue alloc] initWithValue:@"1/2" isQuotedString:YES];
            expect([[MUKXMedia channelsTransformer] transformedValue:value]).to(equal(@[ @1, @2 ]));

            value = [[MUKAttributeValue alloc] initWithValue:@"hoge/fugo" isQuotedString:YES];
            expect([[MUKXMedia channelsTransformer] transformedValue:value]).to(beNil());
        });

        it(@"can convert to string from array", ^{
            MUKAttributeValue* value = [[MUKAttributeValue alloc] initWithValue:@"1/2" isQuotedString:YES];
            expect([[MUKXMedia channelsTransformer] reverseTransformedValue:@[ @1, @2 ]]).to(equal(value));

            expect([[MUKXMedia channelsTransformer] reverseTransformedValue:@[]]).to(beNil());
        });
    });

    describe(@"validate:", ^{
        __block MUKXMedia* gMedia;

        beforeEach(^{
            gMedia = [MUKXMedia new];
            gMedia.mediaType = MUKXMediaTypeVideo;
            gMedia.groupId = @"GROUP-ID";
            gMedia.name = @"NAME";
        });

        it(@"TYPE, GROUP-ID and NAME are REQUIRED", ^{
            MUKXMedia* media = [MUKXMedia new];
            __block NSError* error = nil;

            expect([media validate:&error]).to(equal(NO));
            expect(error.code).to(equal(MUKErrorInvalidMedia));

            error = nil;
            media.mediaType = MUKXMediaTypeVideo;
            expect([media validate:&error]).to(equal(NO));
            expect(error.code).to(equal(MUKErrorInvalidMedia));

            error = nil;
            media.groupId = @"GROUP-ID";
            expect([media validate:&error]).to(equal(NO));
            expect(error.code).to(equal(MUKErrorInvalidMedia));

            error = nil;
            media.name = @"NAME";
            expect([media validate:&error]).to(equal(YES));
            expect(error).to(beNil());
        });

        it(@"CLOSED-CAPTIONS MUST NOT have URI", ^{
            __block NSError* error = nil;
            gMedia.mediaType = MUKXMediaTypeClosedCaptions;
            gMedia.uri = [NSURL URLWithString:@"http://host/path"];
            gMedia.instreamId = @"SERVICE1";

            expect([gMedia validate:&error]).to(equal(NO));
            expect(error.code).to(equal(MUKErrorInvalidMedia));

            gMedia.uri = nil;
            error = nil;
            expect([gMedia validate:&error]).to(equal(YES));
            expect(error).to(beNil());
        });

        it(@"DEFAULT absence indicates an implicit value of NO", ^{
            expect([MUKXMedia new].isDefaultRendition).to(equal(NO));
        });

        it(@"AUTOSELECT absence indicates an implicit value of NO", ^{
            expect([MUKXMedia new].canAutoSelect).to(equal(NO));
        });

        it(@"AUTOSELECT MUST be YES, if the value of the DEFAULT attribute is YES", ^{
            __block NSError* error = nil;
            gMedia.defaultRendition = YES;
            gMedia.autoSelect = NO;
            expect([gMedia validate:&error]).to(equal(NO));
            expect(error.code).to(equal(MUKErrorInvalidMedia));

            error = nil;
            gMedia.autoSelect = YES;
            expect([gMedia validate:&error]).to(equal(YES));
            expect(error).to(beNil());
        });

        it(@"FORCED attribute MUST NOT be present unless the TYPE is SUBTITLES", ^{
            __block NSError* error = nil;
            gMedia.mediaType = MUKXMediaTypeSubtitles;
            gMedia.forced = YES;

            expect([gMedia validate:&error]).to(equal(NO));
            expect(error.code).to(equal(MUKErrorInvalidMedia));

            gMedia.forced = NO;
            error = nil;
            expect([gMedia validate:&error]).to(equal(YES));
            expect(error).to(beNil());
        });

        it(@"If TYPE is CLOSED-CAPTIONS, INSTREAM-ID is REQUIRED. Otherwise, INSTREAM-ID MUST NOT be specified", ^{
            __block NSError* error = nil;
            gMedia.mediaType = MUKXMediaTypeClosedCaptions;

            expect([gMedia validate:&error]).to(equal(NO));
            expect(error.code).to(equal(MUKErrorInvalidMedia));

            error = nil;
            gMedia.instreamId = @"SERVICE1";
            expect([gMedia validate:&error]).to(equal(YES));
            expect(error).to(beNil());

            gMedia.mediaType = MUKXMediaTypeVideo;
            expect([gMedia validate:&error]).to(equal(NO));
            expect(error.code).to(equal(MUKErrorInvalidMedia));

            error = nil;
            gMedia.instreamId = nil;
            expect([gMedia validate:&error]).to(equal(YES));
            expect(error).to(beNil());
        });

        it(@"INSTREAM-ID is one of CC1, CC2, CC3, CC4 or SERVICEn where n MUST be an integer between 1 and 63", ^{
            __block NSError* error = nil;
            gMedia.mediaType = MUKXMediaTypeClosedCaptions;

            for (unsigned long i = 1; i <= 4; i++) {
                gMedia.instreamId = [NSString stringWithFormat:@"CC%lu", i];
                expect([gMedia validate:&error]).to(equal(YES));
                expect(error).to(beNil());
            }

            for (unsigned long i = 1; i <= 63; i++) {
                gMedia.instreamId = [NSString stringWithFormat:@"SERVICE%lu", i];
                expect([gMedia validate:&error]).to(equal(YES));
                expect(error).to(beNil());
            }

            gMedia.instreamId = @"SERVICE64";
            expect([gMedia validate:&error]).to(equal(NO));
            expect(error.code).to(equal(MUKErrorInvalidMedia));

            error = nil;
            gMedia.instreamId = @"CC5";
            expect([gMedia validate:&error]).to(equal(NO));
            expect(error.code).to(equal(MUKErrorInvalidMedia));

            error = nil;
            gMedia.instreamId = @"other";
            expect([gMedia validate:&error]).to(equal(NO));
            expect(error.code).to(equal(MUKErrorInvalidMedia));
        });

        it(@"CHARACTERISTICS MUST NOT contains comma characters", ^{
            __block NSError* error = nil;
            gMedia.characteristics = @[ @"hogefugo" ];

            expect([gMedia validate:&error]).to(equal(YES));
            expect(error).to(beNil());

            gMedia.characteristics = @[ @"hoge,fugo" ];
            expect([gMedia validate:&error]).to(equal(NO));
            expect(error.code).to(equal(MUKErrorInvalidMedia));
        });

        it(@"CHANNELS MUST be ordered", ^{
            __block NSError* error = nil;
            gMedia.channels = @[ @1, @2, @4 ];

            expect([gMedia validate:&error]).to(equal(YES));
            expect(error).to(beNil());

            gMedia.channels = @[ @2, @4, @1 ];
            expect([gMedia validate:&error]).to(equal(NO));
            expect(error.code).to(equal(MUKErrorInvalidMedia));
        });
    });
}
QuickSpecEnd
