//
//  MUKMediaPlaylistTests.m
//  MpegUrlKit
//
//  Created by Hinagiku Soranoba on 2017/01/06.
//  Copyright © 2017年 Hinagiku Soranoba. All rights reserved.
//

#import "MUKMediaPlaylist.h"
#import "MUKSerializer.h"

#define SerializeFailed(__PlaylistStr, __Code)                                           \
    do {                                                                                 \
        __block NSError* error = nil;                                                    \
        expect([serializer serializeFromString:__PlaylistStr error:&error]).to(beNil()); \
        expect(error.code).to(equal(__Code));                                            \
    } while (0)

QuickSpecBegin(MUKMediaPlaylistTests)
{

    MUKSerializer* serializer = [MUKSerializer new];
    serializer.serializableClasses = @[ MUKMediaPlaylist.class ];

    describe(@"#EXTM3U", ^{
        it(@"gets an error, if another tag comes before #EXTM3U", ^{
            NSString* playlist = @"#EXT-X-VERSION:1\n"
                                 @"#EXT-X-TARGETDURATION:5\n";
            SerializeFailed(playlist, MUKErrorInvalidM3UFormat);
        });

        it(@"through second #EXTM3U", ^{
            NSString* playlist = @"#EXTM3U\n"
                                 @"#EXTM3U\n"
                                 @"#EXT-X-TARGETDURATION:5\n";

            __block NSError* error = nil;
            expect([serializer serializeFromString:playlist error:&error]).notTo(beNil());
        });

        it(@"gets an error, if playlist is empty string", ^{
            NSString* playlist = @"";
            SerializeFailed(playlist, MUKErrorInvalidM3UFormat);
        });
    });

    describe(@"#EXT-X-VERSION", ^{
        it(@"version is 1, if playlist doesn't have EXT-X-VERSION", ^{
            NSString* playlistStr = @"#EXTM3U\n"
                                    @"#EXT-X-TARGETDURATION:5\n";

            __block NSError* error = nil;
            __block MUKMediaPlaylist* playlist;
            expect(playlist = [serializer serializeFromString:playlistStr error:&error]).notTo(beNil());
            expect(playlist.version).to(equal(@1));
        });

        it(@"version is correct", ^{
            NSString* playlistStr = @"#EXTM3U\n"
                                    @"#EXT-X-VERSION:3\n"
                                    @"#EXT-X-TARGETDURATION:5\n";

            __block NSError* error = nil;
            __block MUKMediaPlaylist* playlist;
            expect(playlist = [serializer serializeFromString:playlistStr error:&error]).notTo(beNil());
            expect(playlist.version).to(equal(@3));
        });
    });

    describe(@"#EXTINF", ^{
        it(@"gets an error, if version is less 3 and duration format is float", ^{
            NSString* playlistStr = @"#EXTM3U\n"
                                    @"#EXT-X-VERSION:2\n"
                                    @"#EXT-X-TARGETDURATION:5\n"
                                    @"\n"
                                    @"#EXTINF:1.0,\n"
                                    @"url";

            SerializeFailed(playlistStr, MUKErrorInvalidMediaSegment);
        });

        it(@"support float duration, if version is 3", ^{
            NSString* playlistStr = @"#EXTM3U\n"
                                    @"#EXT-X-VERSION:3\n"
                                    @"#EXT-X-TARGETDURATION:5\n"
                                    @"\n"
                                    @"#EXTINF:1.0,\n"
                                    @"url";

            __block NSError* error = nil;
            __block MUKMediaPlaylist* playlist;
            expect(playlist = [serializer serializeFromString:playlistStr error:&error]).notTo(beNil());
            expect([playlist.mediaSegments count]).to(equal(@1));
            expect(playlist.mediaSegments[0].uri).to(equal(@"url"));
            expect(playlist.mediaSegments[0].duration).to(equal(@1.0));
            expect(playlist.mediaSegments[0].title).to(equal(@""));
        });

        it(@"support integer duration", ^{
            NSString* playlistStr = @"#EXTM3U\n"
                                    @"#EXT-X-TARGETDURATION:5\n"
                                    @"\n"
                                    @"#EXTINF:1,\n"
                                    @"url";

            __block NSError* error = nil;
            __block MUKMediaPlaylist* playlist;
            expect(playlist = [serializer serializeFromString:playlistStr error:&error]).notTo(beNil());
            expect([playlist.mediaSegments count]).to(equal(@1));
            expect(playlist.mediaSegments[0].uri).to(equal(@"url"));
            expect(playlist.mediaSegments[0].duration).to(equal(@1));
            expect(playlist.mediaSegments[0].title).to(equal(@""));
        });

        it(@"support title", ^{
            NSString* playlistStr = @"#EXTM3U\n"
                                    @"#EXT-X-VERSION:3\n"
                                    @"#EXT-X-TARGETDURATION:5\n"
                                    @"\n"
                                    @"#EXTINF:1,title\n"
                                    @"url";

            __block NSError* error = nil;
            __block MUKMediaPlaylist* playlist;
            expect(playlist = [serializer serializeFromString:playlistStr error:&error]).notTo(beNil());
            expect([playlist.mediaSegments count]).to(equal(@1));
            expect(playlist.mediaSegments[0].uri).to(equal(@"url"));
            expect(playlist.mediaSegments[0].duration).to(equal(@1));
            expect(playlist.mediaSegments[0].title).to(equal(@"title"));
        });

        it(@"gots an error, if EXTINF doesn't include comma character", ^{
            NSString* playlistStr = @"#EXTM3U\n"
                                    @"#EXT-X-VERSION:3\n"
                                    @"#EXT-X-TARGETDURATION:5\n"
                                    @"\n"
                                    @"#EXTINF:1\n"
                                    @"url";

            SerializeFailed(playlistStr, MUKErrorInvalidMediaSegment);
        });

        it(@"gots an error, if media segment uri is not found", ^{
            NSString* playlistStr = @"#EXTM3U\n"
                                    @"#EXT-X-VERSION:3\n"
                                    @"#EXT-X-TARGETDURATION:5\n"
                                    @"\n"
                                    @"#EXTINF:1\n";

            SerializeFailed(playlistStr, MUKErrorInvalidMediaSegment);
        });

        it(@"support multiple segments", ^{
            NSString* playlistStr = @"#EXTM3U\n"
                                    @"#EXT-X-TARGETDURATION:5\n"
                                    @"\n"
                                    @"#EXTINF:1,\n"
                                    @"url\n"
                                    @"#EXTINF:2,\n"
                                    @"url2\n";

            __block NSError* error = nil;
            __block MUKMediaPlaylist* playlist;
            expect(playlist = [serializer serializeFromString:playlistStr error:&error]).notTo(beNil());
            expect([playlist.mediaSegments count]).to(equal(@2));
            expect(playlist.mediaSegments[1].uri).to(equal(@"url2"));
            expect(playlist.mediaSegments[1].duration).to(equal(@2));
        });
    });

    describe(@"#EXT-X-BYTERANGE", ^{
        it(@"ignored, if version is less 4", ^{
            NSString* playlistStr = @"#EXTM3U\n"
                                    @"#EXT-X-VERSION:3\n"
                                    @"#EXT-X-TARGETDURATION:5\n"
                                    @"\n"
                                    @"#EXTINF:1,\n"
                                    @"#EXT-X-BYTERANGE:100@0\n"
                                    @"url\n";

            __block NSError* error = nil;
            __block MUKMediaPlaylist* playlist;
            expect(playlist = [serializer serializeFromString:playlistStr error:&error]).notTo(beNil());
            expect([playlist.mediaSegments count]).to(equal(@1));
            expect(playlist.mediaSegments[0].byteRange.location).to(equal(@0));
            expect(playlist.mediaSegments[0].byteRange.length).to(equal(@0));
        });

        it(@"gots error, if location is not found and previous segment not found", ^{
            NSString* playlistStr = @"#EXTM3U\n"
                                    @"#EXT-X-VERSION:4\n"
                                    @"#EXT-X-TARGETDURATION:5\n"
                                    @"\n"
                                    @"#EXTINF:1,\n"
                                    @"#EXT-X-BYTERANGE:100\n"
                                    @"url\n";

            SerializeFailed(playlistStr, MUKErrorInvalidByteRange);
        });

        it(@"gots error, if location is not found and previous segment is not same resource", ^{
            NSString* playlistStr = @"#EXTM3U\n"
                                    @"#EXT-X-VERSION:4\n"
                                    @"#EXT-X-TARGETDURATION:5\n"
                                    @"\n"
                                    @"#EXTINF:1,\n"
                                    @"#EXT-X-BYTERANGE:100@0\n"
                                    @"url\n"
                                    @"#EXT-X-BYTERANGE:100\n"
                                    @"#EXTINF:1,\n"
                                    @"url2\n";

            SerializeFailed(playlistStr, MUKErrorInvalidByteRange);
        });

        it(@"support that it's location is before EXTINF", ^{
            NSString* playlistStr = @"#EXTM3U\n"
                                    @"#EXT-X-VERSION:4\n"
                                    @"#EXT-X-TARGETDURATION:5\n"
                                    @"\n"
                                    @"#EXT-X-BYTERANGE:100@0\n"
                                    @"#EXTINF:1,\n"
                                    @"url\n"
                                    @"#EXT-X-BYTERANGE:200\n"
                                    @"#EXTINF:1,\n"
                                    @"url\n";

            __block NSError* error = nil;
            __block MUKMediaPlaylist* playlist;
            expect(playlist = [serializer serializeFromString:playlistStr error:&error]).notTo(beNil());
            expect([playlist.mediaSegments count]).to(equal(@2));
            expect(playlist.mediaSegments[0].byteRange.location).to(equal(0));
            expect(playlist.mediaSegments[0].byteRange.length).to(equal(100));
            expect(playlist.mediaSegments[1].byteRange.location).to(equal(100));
            expect(playlist.mediaSegments[1].byteRange.length).to(equal(200));
        });

        it(@"support that it's location is after EXTINF", ^{
            NSString* playlistStr = @"#EXTM3U\n"
                                    @"#EXT-X-VERSION:4\n"
                                    @"#EXT-X-TARGETDURATION:5\n"
                                    @"\n"
                                    @"#EXTINF:1,\n"
                                    @"#EXT-X-BYTERANGE:100@0\n"
                                    @"url\n"
                                    @"#EXTINF:1,\n"
                                    @"#EXT-X-BYTERANGE:200\n"
                                    @"url\n";

            __block NSError* error = nil;
            __block MUKMediaPlaylist* playlist;
            expect(playlist = [serializer serializeFromString:playlistStr error:&error]).notTo(beNil());
            expect([playlist.mediaSegments count]).to(equal(@2));
            expect(playlist.mediaSegments[0].byteRange.location).to(equal(0));
            expect(playlist.mediaSegments[0].byteRange.length).to(equal(100));
            expect(playlist.mediaSegments[1].byteRange.location).to(equal(100));
            expect(playlist.mediaSegments[1].byteRange.length).to(equal(200));
        });
    });

    describe(@"#EXT-X-DISCONTINUITY", ^{
        it(@"can parse", ^{
            NSString* playlistStr = @"#EXTM3U\n"
                                    @"#EXT-X-TARGETDURATION:5\n"
                                    @"\n"
                                    @"#EXTINF:1,\n"
                                    @"url1\n"
                                    @"#EXT-X-DISCONTINUITY\n"
                                    @"#EXTINF:1,\n"
                                    @"url2\n";

            __block NSError* error = nil;
            __block MUKMediaPlaylist* playlist;
            expect(playlist = [serializer serializeFromString:playlistStr error:&error]).notTo(beNil());
            expect(playlist.mediaSegments.count).to(equal(@2));
            expect(playlist.mediaSegments[0].discontinuity).to(equal(NO));
            expect(playlist.mediaSegments[1].discontinuity).to(equal(YES));
        });
    });

    describe(@"#EXT-X-KEY", ^{
        it(@"gots error, if it have duplicate attributes", ^{
            NSString* playlistStr = @"#EXTM3U\n"
                                    @"#EXT-X-VERSION:3\n"
                                    @"#EXT-X-TARGETDURATION:5\n"
                                    @"\n"
                                    @"#EXTINF:1,\n"
                                    @"#EXT-X-KEY:METHOD=NONE,METHOD=NONE\n"
                                    @"url\n";

            SerializeFailed(playlistStr, MUKErrorInvalidAttributeList);
        });

        it(@"gots error, if attribute format is invalid", ^{
            NSString* playlistStr = @"#EXTM3U\n"
                                    @"#EXT-X-VERSION:3\n"
                                    @"#EXT-X-TARGETDURATION:5\n"
                                    @"\n"
                                    @"#EXTINF:1,\n"
                                    @"#EXT-X-KEY:METHOD\n"
                                    @"url\n";

            SerializeFailed(playlistStr, MUKErrorInvalidAttributeList);
        });

        it(@"ignore KEYFORMAT, if version is less than 5", ^{
            NSString* playlistStr = @"#EXTM3U\n"
                                    @"#EXT-X-VERSION:4\n"
                                    @"#EXT-X-TARGETDURATION:5\n"
                                    @"\n"
                                    @"#EXTINF:1,\n"
                                    @"#EXT-X-KEY:METHOD=AES-128,URI=\"uri\",KEYFORMAT=\"hoge\"\n"
                                    @"url\n";

            __block NSError* error = nil;
            __block MUKMediaPlaylist* playlist;
            expect(playlist = [serializer serializeFromString:playlistStr error:&error]).notTo(beNil());
            expect(playlist.mediaSegments.count).to(equal(@1));
            expect(playlist.mediaSegments[0].encrypt.keyFormat).to(equal(@"identity"));
        });

        it(@"ignore IV, if version is less than 2", ^{
            NSString* playlistStr = @"#EXTM3U\n"
                                    @"#EXT-X-VERSION:1\n"
                                    @"#EXT-X-TARGETDURATION:5\n"
                                    @"\n"
                                    @"#EXTINF:1,\n"
                                    @"#EXT-X-KEY:METHOD=AES-128,URI=\"uri\",IV=0x9c7db8778570d05c3177c349fd9236aa\n"
                                    @"url\n";

            __block NSError* error = nil;
            __block MUKMediaPlaylist* playlist;
            expect(playlist = [serializer serializeFromString:playlistStr error:&error]).notTo(beNil());
            expect(playlist.mediaSegments.count).to(equal(@1));
            expect(playlist.mediaSegments[0].encrypt.aesInitializeVector).to(beNil());
        });

        it(@"ignore KEYFORMATVERSIONS , if version is less than 5", ^{
            NSString* playlistStr = @"#EXTM3U\n"
                                    @"#EXT-X-VERSION:4\n"
                                    @"#EXT-X-TARGETDURATION:5\n"
                                    @"\n"
                                    @"#EXTINF:1,\n"
                                    @"#EXT-X-KEY:METHOD=AES-128,URI=\"uri\",KEYFORMATVERSIONS=\"1/2\"\n"
                                    @"url\n";

            __block NSError* error = nil;
            __block MUKMediaPlaylist* playlist;
            expect(playlist = [serializer serializeFromString:playlistStr error:&error]).notTo(beNil());
            expect(playlist.mediaSegments.count).to(equal(@1));
            expect(playlist.mediaSegments[0].encrypt.keyFormatVersions).to(equal(@[ @1 ]));
        });

        it(@"gots error, if method is not NONE and URI is not found", ^{
            NSString* playlistStr = @"#EXTM3U\n"
                                    @"#EXT-X-VERSION:3\n"
                                    @"#EXT-X-TARGETDURATION:5\n"
                                    @"\n"
                                    @"#EXTINF:1,\n"
                                    @"#EXT-X-KEY:METHOD=AES-128\n"
                                    @"url\n";

            SerializeFailed(playlistStr, MUKErrorInvalidEncrypt);
        });

        it(@"parse successed, if it is correct", ^{
            NSString* playlistStr = @"#EXTM3U\n"
                                    @"#EXT-X-VERSION:5\n"
                                    @"#EXT-X-TARGETDURATION:5\n"
                                    @"\n"
                                    @"#EXTINF:1,\n"
                                    @"#EXT-X-KEY:METHOD=AES-128,URI=\"enc1\",IV=0x9c7db8778570d05c3177c349fd9236aa,KEYFORMAT=\"hoge\","
                                    @"KEYFORMATVERSIONS=\"1/2\"\n"
                                    @"url1\n"
                                    @"#EXTINF:1,\n"
                                    @"url2\n"
                                    @"#EXT-X-KEY:METHOD=SAMPLE-AES,URI=\"enc2\"\n"
                                    @"url3\n";

            unsigned char iv[16] = { 0x9c, 0x7d, 0xb8, 0x77, 0x85, 0x70, 0xd0, 0x5c,
                                     0x31, 0x77, 0xc3, 0x49, 0xfd, 0x92, 0x36, 0xaa };
            NSData* expectedIv = [NSData dataWithBytes:iv length:16];

            __block NSError* error = nil;
            __block MUKMediaPlaylist* playlist;
            expect(playlist = [serializer serializeFromString:playlistStr error:&error]).notTo(beNil());
            expect(playlist.mediaSegments.count).to(equal(@3));
            expect(@(playlist.mediaSegments[0].encrypt.method)).to(equal(MUKXKeyMethodAes128));
            expect(playlist.mediaSegments[0].encrypt.uri.absoluteString).to(equal(@"enc1"));
            expect(playlist.mediaSegments[0].encrypt.aesInitializeVector).to(equal(expectedIv));
            expect(playlist.mediaSegments[0].encrypt.keyFormat).to(equal(@"hoge"));
            expect(playlist.mediaSegments[0].encrypt.keyFormatVersions).to(equal(@[ @1, @2 ]));

            expect(playlist.mediaSegments[0].encrypt).to(equal(playlist.mediaSegments[1].encrypt));

            expect(@(playlist.mediaSegments[2].encrypt.method)).to(equal(MUKXKeyMethodSampleAes));
            expect(playlist.mediaSegments[2].encrypt.uri.absoluteString).to(equal(@"enc2"));
            expect(playlist.mediaSegments[2].encrypt.aesInitializeVector).to(beNil());
            expect(playlist.mediaSegments[2].encrypt.keyFormat).to(equal(@"identity")); // default
            expect(playlist.mediaSegments[2].encrypt.keyFormatVersions).to(equal(@[ @1 ])); // default
        });
    });

    describe(@"#EXT-X-PROGRAM-DATE-TIME", ^{
        it(@"can parse", ^{
            NSString* playlistStr = @"#EXTM3U\n"
                                    @"#EXT-X-TARGETDURATION:5\n"
                                    @"\n"
                                    @"#EXTINF:5,\n"
                                    @"url1\n"
                                    @"#EXTINF:5,\n"
                                    @"#EXT-X-PROGRAM-DATE-TIME:2017-01-08T21:20:00.0Z\n"
                                    @"url2\n"
                                    @"#EXTINF:5,\n"
                                    @"#EXT-X-PROGRAM-DATE-TIME:2017-01-08T21:20:05.0Z\n"
                                    @"url3\n";

            __block NSError* error = nil;
            __block MUKMediaPlaylist* playlist;
            expect(playlist = [serializer serializeFromString:playlistStr error:&error]).notTo(beNil());
            expect(playlist.mediaSegments.count).to(equal(3));
            expect(playlist.mediaSegments[0].programDate).to(beNil());
            expect([playlist.mediaSegments[2].programDate timeIntervalSinceDate:playlist.mediaSegments[1].programDate]).to(equal(5));
        });
    });

    describe(@"EXT-X-DATERANGE", ^{
        it(@"ignore EXT-X-DATERANGE tags with illegal syntax", ^{
            NSString* playlistStr = @"#EXTM3U\n"
                                    @"#EXT-X-TARGETDURATION:5\n"
                                    @"\n"
                                    @"#EXT-X-DATERANGE:START-DATE=\"2016-12-25T00:00:00.00Z\"\n" // id is required
                                    @"#EXT-X-DATERANGE:ID=\"hoge\"\n" // start-date is required
                                    @"#EXT-X-DATERANGE:invalid-format\n"; // invalid format

            __block NSError* error = nil;
            __block MUKMediaPlaylist* playlist;
            expect(playlist = [serializer serializeFromString:playlistStr error:&error]).notTo(beNil());
            expect(playlist.dateRanges.count).to(equal(0));
        });

        it(@"can parse", ^{
            NSString* playlistStr = @"#EXTM3U\n"
                                    @"#EXT-X-TARGETDURATION:5\n"
                                    @"\n"
                                    @"#EXT-X-DATERANGE:ID=\"id\",CLASS=\"class\",START-DATE=\"2016-12-25T00:00:00.00Z\","
                                    @"END-DATE=\"2016-12-25T00:00:05.50Z\",DURATION=5.5,PLANNED-DURATION=10.5,"
                                    @"X-CUSTOM=YES\n";

            __block NSError* error = nil;
            __block MUKMediaPlaylist* playlist;
            expect(playlist = [serializer serializeFromString:playlistStr error:&error]).notTo(beNil());
            expect(playlist.dateRanges.count).to(equal(1));
            expect(playlist.dateRanges[0].identifier).to(equal(@"id"));
            expect(playlist.dateRanges[0].klass).to(equal(@"class"));
            expect(playlist.dateRanges[0].startDate).notTo(beNil());
            expect(playlist.dateRanges[0].endDate).notTo(beNil());
            expect(playlist.dateRanges[0].duration).to(equal(5.5));
            expect(playlist.dateRanges[0].plannedDuration).to(equal(10.5));
            expect(playlist.dateRanges[0].userDefinedAttributes.count).to(equal(1));
            expect(playlist.dateRanges[0].userDefinedAttributes[@"X-CUSTOM"].value).to(equal(@"YES"));
        });
    });

    describe(@"#EXT-X-TARGETDURATION", ^{
        it(@"gots error, target duration is not found", ^{
            NSString* playlistStr = @"#EXTM3U\n";
            SerializeFailed(playlistStr, MUKErrorMissingRequiredTag);
        });

        it(@"can parse", ^{
            NSString* playlistStr = @"#EXTM3U\n"
                                    @"#EXT-X-TARGETDURATION:5";

            __block NSError* error = nil;
            __block MUKMediaPlaylist* playlist;
            expect(playlist = [serializer serializeFromString:playlistStr error:&error]).notTo(beNil());
            expect(playlist.targetDuration).to(equal(5));
        });

        it(@"gots error, if target duration format is float", ^{
            NSString* playlistStr = @"#EXTM3U\n"
                                    @"#EXT-X-TARGETDURATION:2.5\n";
            SerializeFailed(playlistStr, MUKErrorInvalidType);
        });

        it(@"gots error, if target duration is duplicated", ^{
            NSString* playlistStr = @"#EXTM3U\n"
                                    @"#EXT-X-TARGETDURATION:5\n"
                                    @"#EXT-X-TARGETDURATION:5\n";
            SerializeFailed(playlistStr, MUKErrorDuplicateTag);
        });
    });

    describe(@"#EXT-X-MEDIA-SEQUENCE", ^{
        it(@"can parse", ^{
            NSString* playlistStr = @"#EXTM3U\n"
                                    @"#EXT-X-TARGETDURATION:5\n"
                                    @"#EXT-X-MEDIA-SEQUENCE:2\n";

            __block NSError* error = nil;
            __block MUKMediaPlaylist* playlist;
            expect(playlist = [serializer serializeFromString:playlistStr error:&error]).notTo(beNil());
            expect(playlist.firstSequenceNumber).to(equal(2));
        });

        it(@"media-sequence is 0, if media-sequence is not found", ^{
            NSString* playlistStr = @"#EXTM3U\n"
                                    @"#EXT-X-TARGETDURATION:5\n";

            __block NSError* error = nil;
            __block MUKMediaPlaylist* playlist;
            expect(playlist = [serializer serializeFromString:playlistStr error:&error]).notTo(beNil());
            expect(playlist.firstSequenceNumber).to(equal(0));
        });

        it(@"gots error, if media-sequence is duplicated", ^{
            NSString* playlistStr = @"#EXTM3U\n"
                                    @"#EXT-X-TARGETDURATION:5\n"
                                    @"#EXT-X-MEDIA-SEQUENCE:2\n"
                                    @"#EXT-X-MEDIA-SEQUENCE:2\n";
            SerializeFailed(playlistStr, MUKErrorDuplicateTag);
        });

        it(@"gots error, if media-sequence location appear after the first Media Segment", ^{
            NSString* playlistStr = @"#EXTM3U\n"
                                    @"#EXT-X-TARGETDURATION:5\n"
                                    @"\n"
                                    @"#EXTINF:5,\n"
                                    @"url1"
                                    @"\n"
                                    @"#EXT-X-MEDIA-SEQUENCE:2\n";
            SerializeFailed(playlistStr, MUKErrorLocationIncorrect);
        });
    });

    describe(@"#EXT-X-DISCONTINUITY-SEQUENCE", ^{
        it(@"can parse", ^{
            NSString* playlistStr = @"#EXTM3U\n"
                                    @"#EXT-X-TARGETDURATION:5\n"
                                    @"#EXT-X-DISCONTINUITY-SEQUENCE:2\n";

            __block NSError* error = nil;
            __block MUKMediaPlaylist* playlist;
            expect(playlist = [serializer serializeFromString:playlistStr error:&error]).notTo(beNil());
            expect(playlist.firstDiscontinuitySequenceNumber).to(equal(2));
        });

        it(@"media-sequence is 0, if discontinuity-sequence is not found", ^{
            NSString* playlistStr = @"#EXTM3U\n"
                                    @"#EXT-X-TARGETDURATION:5\n";

            __block NSError* error = nil;
            __block MUKMediaPlaylist* playlist;
            expect(playlist = [serializer serializeFromString:playlistStr error:&error]).notTo(beNil());
            expect(playlist.firstDiscontinuitySequenceNumber).to(equal(0));
        });

        it(@"gots error, if discontinuity-sequence is duplicated", ^{
            NSString* playlistStr = @"#EXTM3U\n"
                                    @"#EXT-X-TARGETDURATION:5\n"
                                    @"#EXT-X-DISCONTINUITY-SEQUENCE:2\n"
                                    @"#EXT-X-DISCONTINUITY-SEQUENCE:2\n";
            SerializeFailed(playlistStr, MUKErrorDuplicateTag);
        });

        it(@"gots error, if discontinuity-sequence location appear after the first Media Segment", ^{
            NSString* playlistStr = @"#EXTM3U\n"
                                    @"#EXT-X-TARGETDURATION:5\n"
                                    @"\n"
                                    @"#EXTINF:5,\n"
                                    @"url1"
                                    @"\n"
                                    @"#EXT-X-DISCONTINUITY-SEQUENCE:2\n";
            SerializeFailed(playlistStr, MUKErrorLocationIncorrect);
        });
    });

    describe(@"EXT-X-ENDLIST", ^{
        it(@"ignore the segment after ENDLIST", ^{
            NSString* playlistStr = @"#EXTM3U\n"
                                    @"#EXT-X-TARGETDURATION:5\n"
                                    @"\n"
                                    @"#EXTINF:5,\n"
                                    @"url1\n"
                                    @"\n"
                                    @"#EXT-X-ENDLIST\n"
                                    @"\n"
                                    @"#EXTINF:5,\n"
                                    @"url2";

            __block NSError* error = nil;
            __block MUKMediaPlaylist* playlist;
            expect(playlist = [serializer serializeFromString:playlistStr error:&error]).notTo(beNil());
            expect(playlist.mediaSegments.count).to(equal(1));
            expect(playlist.hasEndList).to(equal(YES));
        });
    });

    describe(@"EXT-X-PLAYLIST-TYPE", ^{
        it(@"gots error, in case of unacceptable values", ^{
            NSString* playlistStr = @"#EXTM3U\n"
                                    @"#EXT-X-TARGETDURATION:5\n"
                                    @"#EXT-X-PLAYLIST-TYPE:vod\n";

            SerializeFailed(playlistStr, MUKErrorInvalidType);
        });

        it(@"can parse", ^{
            NSString* playlistStr = @"#EXTM3U\n"
                                    @"#EXT-X-TARGETDURATION:5\n"
                                    @"#EXT-X-PLAYLIST-TYPE:VOD\n";

            __block NSError* error = nil;
            __block MUKMediaPlaylist* playlist;
            expect(playlist = [serializer serializeFromString:playlistStr error:&error]).notTo(beNil());
            expect(@(playlist.playlistType)).to(equal(MUKPlaylistTypeVod));

            playlistStr = @"#EXTM3U\n"
                          @"#EXT-X-TARGETDURATION:5\n"
                          @"#EXT-X-PLAYLIST-TYPE:EVENT\n";

            expect(playlist = [serializer serializeFromString:playlistStr error:&error]).notTo(beNil());
            expect(@(playlist.playlistType)).to(equal(MUKPlaylistTypeEvent));
        });
    });

    describe(@"EXT-X-I-FRAMES-ONLY", ^{
        it(@"can parse", ^{
            NSString* playlistStr = @"#EXTM3U\n"
                                    @"#EXT-X-VERSION:4\n"
                                    @"#EXT-X-TARGETDURATION:5\n"
                                    @"#EXT-X-I-FRAMES-ONLY\n";

            __block NSError* error = nil;
            __block MUKMediaPlaylist* playlist;
            expect(playlist = [serializer serializeFromString:playlistStr error:&error]).notTo(beNil());
            expect(playlist.isIframesOnly).to(equal(YES));
        });

        it(@"ignore, if version is less than 4", ^{
            NSString* playlistStr = @"#EXTM3U\n"
                                    @"#EXT-X-VERSION:3\n"
                                    @"#EXT-X-TARGETDURATION:5\n"
                                    @"#EXT-X-I-FRAMES-ONLY\n";

            __block NSError* error = nil;
            __block MUKMediaPlaylist* playlist;
            expect(playlist = [serializer serializeFromString:playlistStr error:&error]).notTo(beNil());
            expect(playlist.isIframesOnly).to(equal(NO));
        });
    });

    describe(@"convert between playlist type and string", ^{
        it(@"to string", ^{
            expect([MUKMediaPlaylist playlistTypeToString:MUKPlaylistTypeVod]).to(equal(@"VOD"));
            expect([MUKMediaPlaylist playlistTypeToString:MUKPlaylistTypeEvent]).to(equal(@"EVENT"));
            expect([MUKMediaPlaylist playlistTypeToString:MUKPlaylistTypeUnknown]).to(beNil());
        });

        it(@"from string", ^{
            expect(@([MUKMediaPlaylist playlistTypeFromString:@"VOD"])).to(equal(MUKPlaylistTypeVod));
            expect(@([MUKMediaPlaylist playlistTypeFromString:@"EVENT"])).to(equal(MUKPlaylistTypeEvent));
            expect(@([MUKMediaPlaylist playlistTypeFromString:@"vod"])).to(equal(MUKPlaylistTypeUnknown));
        });
    });
}
QuickSpecEnd
