MpegUrlKit (WIP)
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

### Other information

## Contribute

Pull request is welcome =D

## License

[MIT License](LICENSE)
