//
//  MUKMasterPlaylistTests.m
//  MpegUrlKit
//
//  Created by Hinagiku Soranoba on 2017/01/20.
//  Copyright © 2017年 Hinagiku Soranoba. All rights reserved.
//

#import "MUKMasterPlaylist.h"
#import "MUKSerializer.h"

QuickSpecBegin(MUKMasterPlaylistTests)
{
    MUKSerializer* serializer = [MUKSerializer new];
    serializer.serializableClasses = @[ MUKMasterPlaylist.class ];

    describe(@"EXT-X-MEDIA", ^{
        it(@"can parse", ^{
            NSString* playlistStr = @"#EXTM3U\n"
                                    @"#EXT-X-MEDIA:TYPE=AUDIO,GROUP-ID=\"aac\",NAME=\"English\","
                                    @"DEFAULT=YES,AUTOSELECT=YES,LANGUAGE=\"en\",ASSOC-LANGUAGE=\"ja\","
                                    @"FORCED=YES,CHARACTERISTICS=\"com.a,com.b\","
                                    @"CHANNELS=\"1/2/4\",URI=\"main/english-audio.m3u8\"\n";

            __block NSError* error = nil;
            __block MUKMasterPlaylist* playlist;
            expect(playlist = [serializer modelFromString:playlistStr error:&error]).notTo(beNil());
            expect(playlist.medias.count).to(equal(1));
            expect(@(playlist.medias[0].mediaType)).to(equal(MUKXMediaTypeAudio));
            expect(playlist.medias[0].groupId).to(equal(@"aac"));
            expect(playlist.medias[0].name).to(equal(@"English"));
            expect(playlist.medias[0].isDefaultRendition).to(beTrue());
            expect(playlist.medias[0].canAutoSelect).to(beTrue());
            expect(playlist.medias[0].language).to(equal(@"en"));
            expect(playlist.medias[0].associatedLanguage).to(equal(@"ja"));
            expect(playlist.medias[0].forced).to(beTrue());
            expect(playlist.medias[0].characteristics).to(equal(@[ @"com.a", @"com.b" ]));
            expect(playlist.medias[0].channels).to(equal(@[ @1, @2, @4 ]));
            expect(playlist.medias[0].uri.absoluteString).to(equal(@"main/english-audio.m3u8"));
        });

        it(@"can parse", ^{
            NSString* playlistStr = @"#EXTM3U\n"
                                    @"#EXT-X-MEDIA:TYPE=CLOSED-CAPTIONS,GROUP-ID=\"1\",NAME=\"1\",INSTREAM-ID=\"CC1\"\n"
                                    @"\n"
                                    @"#EXT-X-MEDIA:TYPE=CLOSED-CAPTIONS,GROUP-ID=\"2\",NAME=\"2\",INSTREAM-ID=\"SERVICE1\"\n";

            __block NSError* error = nil;
            __block MUKMasterPlaylist* playlist;
            expect(playlist = [serializer modelFromString:playlistStr error:&error]).notTo(beNil());
            expect(playlist.medias.count).to(equal(2));
            expect(@(playlist.medias[0].mediaType)).to(equal(MUKXMediaTypeClosedCaptions));
            expect(playlist.medias[0].instreamId).to(equal(@"CC1"));
            expect(playlist.medias[0].name).to(equal(@"1"));
            expect(playlist.medias[1].name).to(equal(@"2"));
        });
    });

    describe(@"EXT-X-STREAM-INF", ^{
        it(@"can parse", ^{
            NSString* playlistStr = @"#EXTM3U\n"
                                    @"#EXT-X-STREAM-INF:BANDWIDTH=1280000,AVERAGE-BANDWIDTH=1000000,"
                                    @"CODECS=\"mp4a.40.2,avc1.4d401e\",RESOLUTION=100x200,FRAME-RATE=24.5,"
                                    @"HDCP-LEVEL=TYPE-0,AUDIO=\"a\",VIDEO=\"v\",SUBTITLES=\"s\",CLOSED-CAPTIONS=\"c\"\n"
                                    @"\n"
                                    @"http://example.com/low.m3u8\n";

            __block NSError* error = nil;
            __block MUKMasterPlaylist* playlist;
            expect(playlist = [serializer modelFromString:playlistStr error:&error]).notTo(beNil());
            expect(playlist.streamInfs.count).to(equal(1));
            expect(playlist.streamInfs[0].maxBitrate).to(equal(1280000));
            expect(playlist.streamInfs[0].averageBitrate).to(equal(1000000));
            expect(playlist.streamInfs[0].codecs).to(equal(@[ @"mp4a.40.2", @"avc1.4d401e" ]));
            expect(playlist.streamInfs[0].resolution.width).to(equal(100));
            expect(playlist.streamInfs[0].resolution.height).to(equal(200));
            expect(playlist.streamInfs[0].maxFrameRate).to(equal(24.5));
            expect(@(playlist.streamInfs[0].hdcpLevel)).to(equal(MUKXStreamInfHdcpLevelType0));
            expect(playlist.streamInfs[0].audioGroupId).to(equal(@"a"));
            expect(playlist.streamInfs[0].videoGroupId).to(equal(@"v"));
            expect(playlist.streamInfs[0].subtitlesGroupId).to(equal(@"s"));
            expect(playlist.streamInfs[0].closedCaptionsGroupId).to(equal(@"c"));
            expect(playlist.streamInfs[0].uri.absoluteString).to(equal(@"http://example.com/low.m3u8"));
        });
    });

    describe(@"EXT-X-I-FRAME-STREAM-INF", ^{
        it(@"can parse", ^{
            NSString* playlistStr = @"#EXTM3U\n"
                                    @"#EXT-X-I-FRAME-STREAM-INF:BANDWIDTH=1280000,AVERAGE-BANDWIDTH=1000000,"
                                    @"CODECS=\"mp4a.40.2,avc1.4d401e\",RESOLUTION=100x200,FRAME-RATE=24.5,"
                                    @"HDCP-LEVEL=TYPE-0,AUDIO=\"a\",VIDEO=\"v\",SUBTITLES=\"s\",CLOSED-CAPTIONS=\"c\","
                                    @"URI=\"http://example.com/low.m3u8\"\n";

            __block MUKMasterPlaylist* playlist;
            __block NSError* error = nil;
            expect(playlist = [serializer modelFromString:playlistStr error:&error]).notTo(beNil());
            expect(playlist.streamInfs.count).to(equal(1));
            expect([playlist.streamInfs[0] isKindOfClass:MUKXIframeStreamInf.class]).to(equal(YES));
            expect(playlist.streamInfs[0].maxBitrate).to(equal(1280000));
            expect(playlist.streamInfs[0].averageBitrate).to(equal(1000000));
            expect(playlist.streamInfs[0].codecs).to(equal(@[ @"mp4a.40.2", @"avc1.4d401e" ]));
            expect(playlist.streamInfs[0].resolution.width).to(equal(100));
            expect(playlist.streamInfs[0].resolution.height).to(equal(200));
            expect(playlist.streamInfs[0].maxFrameRate).to(equal(0));
            expect(@(playlist.streamInfs[0].hdcpLevel)).to(equal(MUKXStreamInfHdcpLevelType0));
            expect(playlist.streamInfs[0].audioGroupId).to(beNil());
            expect(playlist.streamInfs[0].videoGroupId).to(equal(@"v"));
            expect(playlist.streamInfs[0].subtitlesGroupId).to(beNil());
            expect(playlist.streamInfs[0].closedCaptionsGroupId).to(beNil());
            expect(playlist.streamInfs[0].uri.absoluteString).to(equal(@"http://example.com/low.m3u8"));
        });
    });

    describe(@"EXT-X-SESSION-DATA", ^{
        it(@"can parse", ^{
            NSString* playlistStr = @"#EXTM3U\n"
                                    @"#EXT-X-SESSION-DATA:DATA-ID=\"com.example.titles\",VALUE=\"hoge\",LANGUAGE=\"en\"\n"
                                    @"#EXT-X-SESSION-DATA:DATA-ID=\"com.example.lyrics\",URI=\"lyrics.json\",LANGUAGE=\"en\"\n";

            __block MUKMasterPlaylist* playlist;
            __block NSError* error = nil;
            expect(playlist = [serializer modelFromString:playlistStr error:&error]).notTo(beNil());
            expect(playlist.sessionDatas.count).to(equal(2));
            expect(playlist.sessionDatas[0].dataId).to(equal(@"com.example.titles"));
            expect(playlist.sessionDatas[0].value).to(equal(@"hoge"));
            expect(playlist.sessionDatas[0].language).to(equal(@"en"));
            expect(playlist.sessionDatas[0].uri).to(beNil());

            expect(playlist.sessionDatas[1].dataId).to(equal(@"com.example.lyrics"));
            expect(playlist.sessionDatas[1].uri.absoluteString).to(equal(@"lyrics.json"));
            expect(playlist.sessionDatas[1].language).to(equal(@"en"));
            expect(playlist.sessionDatas[1].value).to(beNil());
        });
    });

    describe(@"EXT-X-SESSION-KEY", ^{
        it(@"can parse", ^{
            NSString* playlistStr = @"#EXTM3U\n"
                                    @"#EXT-X-SESSION-KEY:METHOD=AES-128,URI=\"https://priv.example.com/key.php?r=52\"\n";

            __block MUKMasterPlaylist* playlist;
            __block NSError* error;
            expect(playlist = [serializer modelFromString:playlistStr error:&error]).notTo(beNil());
            expect(playlist.sessionKeys.count).to(equal(1));
            expect(@(playlist.sessionKeys[0].method)).to(equal(MUKXKeyMethodAes128));
            expect(playlist.sessionKeys[0].uri.absoluteString).to(equal(@"https://priv.example.com/key.php?r=52"));
        });
    });

    describe(@"stringFromModel:error:", ^{

        it(@"can generate master playlist", ^{
            __block NSError* error = nil;
            MUKMasterPlaylist* playlist = [MUKMasterPlaylist new];
            playlist.independentSegment = YES;
            playlist.sessionDatas = @[ [[MUKXSessionData alloc] initWithDataId:@"DATA-ID" value:@"value" uri:nil language:nil] ];
            playlist.streamInfs = @[ [[MUKXStreamInf alloc] initWithMaxBitrate:10000
                                                                averageBitrate:0
                                                                        codecs:nil
                                                                    resolution:CGSizeZero
                                                                  maxFrameRate:30
                                                                     hdcpLevel:MUKXStreamInfHdcpLevelUnknown
                                                                  audioGroupId:nil
                                                                  videoGroupId:@"video"
                                                              subtitlesGroupId:nil
                                                         closedCaptionsGroupId:nil
                                                                           uri:[NSURL URLWithString:@"http://host/path1"]],
                                     [[MUKXIframeStreamInf alloc] initWithMaxBitrate:5000
                                                                      averageBitrate:0
                                                                              codecs:nil
                                                                          resolution:CGSizeZero
                                                                           hdcpLevel:MUKXStreamInfHdcpLevelUnknown
                                                                        videoGroupId:nil
                                                                                 uri:[NSURL URLWithString:@"http://host/path2"]] ];
            playlist.sessionKeys = @[ [[MUKXKey alloc] initWithMethod:MUKXKeyMethodNone
                                                                  uri:nil
                                                                   iv:nil
                                                            keyFormat:nil
                                                    keyFormatVersions:nil] ];
            playlist.medias = @[ [[MUKXMedia alloc] initWithType:MUKXMediaTypeVideo
                                                             uri:[NSURL URLWithString:@"http://host/video"]
                                                         groupId:@"group-id"
                                                        language:nil
                                              associatedLanguage:nil
                                                            name:@"rend1"
                                              isDefaultRendition:YES
                                                   canAutoSelect:YES
                                                          forced:YES
                                                      instreamId:nil
                                                 characteristics:nil
                                                        channels:nil] ];
            playlist.startOffset = [[MUKXStart alloc] initWithTimeOffset:2.5 precise:YES];

            expect([serializer stringFromModel:playlist error:&error])
                .to(equal(@"#EXTM3U\n"
                          @"\n"
                          @"#EXT-X-INDEPENDENT-SEGMENTS\n"
                          @"\n\n"
                          @"#EXT-X-START:TIME-OFFSET=2.5,PRECISE=YES\n"
                          @"\n\n"
                          @"#EXT-X-SESSION-KEY:METHOD=NONE,KEYFORMAT=\"identity\",KEYFORMATVERSIONS=\"1\"\n"
                          @"\n\n"
                          @"#EXT-X-MEDIA:TYPE=VIDEO,URI=\"http://host/video\",GROUP-ID=\"group-id\","
                          @"NAME=\"rend1\",DEFAULT=YES,AUTOSELECT=YES,FORCED=YES\n"
                          @"\n\n"
                          @"#EXT-X-STREAM-INF:BANDWIDTH=10000,FRAME-RATE=30,VIDEO=\"video\"\n"
                          @"http://host/path1\n"
                          @"\n"
                          @"#EXT-X-I-FRAME-STREAM-INF:BANDWIDTH=5000,URI=\"http://host/path2\"\n"
                          @"\n\n"
                          @"#EXT-X-SESSION-DATA:DATA-ID=\"DATA-ID\",VALUE=\"value\"\n"
                          @"\n"));
            expect(error).to(beNil());
        });
    });
}
QuickSpecEnd
