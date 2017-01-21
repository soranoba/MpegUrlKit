MpegUrlKit
=======
MpegUrlKit is a serializer/deserializer of m3u (m3u8) format used in HLS.

[![CI Status](http://img.shields.io/travis/soranoba/MpegUrlKit.svg?style=flat)](https://travis-ci.org/soranoba/MpegUrlKit)
[![Version](https://img.shields.io/cocoapods/v/MpegUrlKit.svg?style=flat)](http://cocoapods.org/pods/MpegUrlKit)
[![License](https://img.shields.io/cocoapods/l/MpegUrlKit.svg?style=flat)](http://cocoapods.org/pods/MpegUrlKit)
[![Platform](https://img.shields.io/cocoapods/p/MpegUrlKit.svg?style=flat)](http://cocoapods.org/pods/MpegUrlKit)

## Overview

It can serialize and deserialize of m3u8 file formats.

- It supported up to version 7 (`#EXT-X-VERSION:7`).
- It provide a way to parse your original tags.

### What is MpegUrl ?

The Internet Media Type of [M3U](https://en.wikipedia.org/wiki/M3U) is `application/mpegurl`.

I am taking it from here.

I avoided the name of M3U in order to avoid conflict with other libraries.

### Reference link

- [HTTP Live Streaming draft-pantos-http-live-streaming](https://tools.ietf.org/html/draft-pantos-http-live-streaming-20)
- [ISO-8601](http://www.iso.org/iso/catalogue_detail?csnumber=40874)

## Installation

MpegUrlKit is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'MpegUrlKit'
```

## How to use functions of MpegUrlKit

### Parse a M3U8 file

```objc
// #import <MpegUrlKit/MUKSerializer.h>
// #import <MpegUrlKit/MUKMediaPlaylist.h>

MUKSerializer* serializer = [MUKSerializer new];
serializer.serializableClasses = @[ MUKMediaPlaylist.class ];

NSError* error;
MUKMediaPlaylist* playlist = [serializer serializeFromString:@"#EXTM3U\n"
                                                             @"#EXT-X-TARGETDURATION:5\n"
                                                             @"...."
                                                       error:&error];
```

### Generate a M3U8 file

TODO

### Create a parser corresponding to your own tag

TODO

### How to use AttributeModel (AttributeSerializer)

One of tag formats of HLS has [Attribute Lists](https://tools.ietf.org/html/draft-pantos-http-live-streaming-20#section-4.2).

This library contains the model converter of the Attribute List.

When creating AttributeModel, inherit from `MUKAttributeModel` and define `MUKAttributeSerializing` protocol.

```objc
#import <MpegUrlKit/MUKAttributeModel.h>

@interface MUKXKey : MUKAttributeModel <MUKAttributeSerializing>
@end
```

```objc
@implementation MUKXKey

#pragma mark - MUKAttributeSerializing

+ (NSDictionary<NSString*, NSString*>* _Nonnull)propertyByAttributeKey
{
    //
    // {AttributeKey : PropertyName}
    //
    return @{ @"METHOD" : @"method",
              @"URI" : @"uri",
              @"IV" : @"aesInitializeVector",
              @"KEYFORMAT" : @"keyFormat",
              @"KEYFORMATVERSIONS" : @"keyFormatVersions" };
}
```

If it is a supported type, MUKAttributeSerializer automatically converts it according to the type of property.

In the case of a type that does not support or if you want to perform special conversion, you need to define transformer.

```objc
#pragma mark MUKAttributeSerializing (Optional)

///
/// + (MUKTransformer* _Nonnull) ${propertyName}Transformer
///
+ (MUKTransformer* _Nonnull)keyFormatVersionsTransformer
{
    return [MUKTransformer transformerWithBlock:^id _Nullable(MUKAttributeValue* _Nonnull value) {
        // If format of the value is "quoted-string", it is YES.
        if (value.isQuotedString) {
            return [value.value componentsSeparatedByString:@"/"];
        } else {
            // It returns nil that means unsupported format. So, conversion fails.
            return nil;
        }
    }
        reverseBlock:^MUKAttributeValue* _Nullable(id _Nonnull value) {
            NSString* str = [value appendString:@"/"];
            return [[MUKAttributeValue alloc] initWithValue:str isQuotedString:YES];
        }];
}
```

For details, please see below
- [MUKAttributeModel's document](MpegUrlKit/Classes/AttributeSerializer/MUKAttributeModel.h)
- [MUKAttributeSerializer's document](MpegUrlKit/Classes/AttributeSerializer/MUKAttributeSerializer.h)
- [MUKAttributeModel sample](MpegUrlKit/Classes/Models/Properties/MUKXKey.m)

## Contribute

Pull request is welcome =D

## License

[MIT License](LICENSE)
