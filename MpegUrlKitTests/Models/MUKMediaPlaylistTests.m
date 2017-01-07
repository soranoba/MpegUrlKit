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
            NSString* playlist = @"#EXT-X-VERSION:1\n";
            SerializeFailed(playlist, MUKErrorInvalidM3UFormat);
        });

        it(@"through second #EXTM3U", ^{
            NSString* playlist = @"#EXTM3U\n"
                                  "#EXTM3U\n";

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
            NSString* playlistStr = @"#EXTM3U\n";

            __block NSError* error = nil;
            __block MUKMediaPlaylist* playlist;
            expect(playlist = [serializer serializeFromString:playlistStr error:&error]).notTo(beNil());
            expect(playlist.version).to(equal(@1));
        });

        it(@"version is correct", ^{
            NSString* playlistStr = @"#EXTM3U\n"
                                    @"#EXT-X-VERSION:3\n";

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
                                    @"\n"
                                    @"#EXTINF:1.0,\n"
                                    @"url";

            SerializeFailed(playlistStr, MUKErrorInvalidMediaSegment);
        });

        it(@"support float duration, if version is 3", ^{
            NSString* playlistStr = @"#EXTM3U\n"
                                    @"#EXT-X-VERSION:3\n"
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
                                    @"\n"
                                    @"#EXTINF:1\n"
                                    @"url";

            SerializeFailed(playlistStr, MUKErrorInvalidMediaSegment);
        });

        it(@"gots an error, if media segment uri is not found", ^{
            NSString* playlistStr = @"#EXTM3U\n"
                                    @"#EXT-X-VERSION:3\n"
                                    @"\n"
                                    @"#EXTINF:1\n";

            SerializeFailed(playlistStr, MUKErrorInvalidMediaSegment);
        });

        it(@"support multiple segments", ^{
            NSString* playlistStr = @"#EXTM3U\n"
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
                                    @"\n"
                                    @"#EXTINF:1,\n"
                                    @"#EXT-X-BYTERANGE:100\n"
                                    @"url\n";

            SerializeFailed(playlistStr, MUKErrorInvalidByteRange);
        });

        it(@"gots error, if location is not found and previous segment is not same resource", ^{
            NSString* playlistStr = @"#EXTM3U\n"
                                    @"#EXT-X-VERSION:4\n"
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

    describe(@"#EXT-X-KEY", ^{
        it(@"gots error, if it have duplicate attributes", ^{
            NSString* playlistStr = @"#EXTM3U\n"
                                    @"#EXT-X-VERSION:3\n"
                                    @"\n"
                                    @"#EXTINF:1,\n"
                                    @"#EXT-X-KEY:METHOD=NONE,METHOD=NONE\n"
                                    @"url\n";

            SerializeFailed(playlistStr, MUKErrorInvalidAttributeList);
        });

        it(@"gots error, if attribute format is invalid", ^{
            NSString* playlistStr = @"#EXTM3U\n"
                                    @"#EXT-X-VERSION:3\n"
                                    @"\n"
                                    @"#EXTINF:1,\n"
                                    @"#EXT-X-KEY:METHOD\n"
                                    @"url\n";

            SerializeFailed(playlistStr, MUKErrorInvalidAttributeList);
        });

        it(@"ignore KEYFORMAT, if version is less than 5", ^{
            NSString* playlistStr = @"#EXTM3U\n"
                                    @"#EXT-X-VERSION:4\n"
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
                                    @"\n"
                                    @"#EXTINF:1,\n"
                                    @"#EXT-X-KEY:METHOD=AES-128\n"
                                    @"url\n";

            SerializeFailed(playlistStr, MUKErrorInvalidEncrypt);
        });

        it(@"parse successed, if it is correct", ^{
            NSString* playlistStr = @"#EXTM3U\n"
                                    @"#EXT-X-VERSION:5\n"
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
            expect(@(playlist.mediaSegments[0].encrypt.method)).to(equal(MUKEncryptAes128));
            expect(playlist.mediaSegments[0].encrypt.uri).to(equal(@"enc1"));
            expect(playlist.mediaSegments[0].encrypt.aesInitializeVector).to(equal(expectedIv));
            expect(playlist.mediaSegments[0].encrypt.keyFormat).to(equal(@"hoge"));
            expect(playlist.mediaSegments[0].encrypt.keyFormatVersions).to(equal(@[ @1, @2 ]));

            expect(playlist.mediaSegments[0].encrypt).to(equal(playlist.mediaSegments[1].encrypt));

            expect(@(playlist.mediaSegments[2].encrypt.method)).to(equal(MUKEncryptSampleAes));
            expect(playlist.mediaSegments[2].encrypt.uri).to(equal(@"enc2"));
            expect(playlist.mediaSegments[2].encrypt.aesInitializeVector).to(beNil());
            expect(playlist.mediaSegments[2].encrypt.keyFormat).to(equal(@"identity")); // default
            expect(playlist.mediaSegments[2].encrypt.keyFormatVersions).to(equal(@[ @1 ])); // default
        });
    });
}
QuickSpecEnd
