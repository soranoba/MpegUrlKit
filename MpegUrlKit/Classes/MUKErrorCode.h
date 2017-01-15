//
//  MUKErrorCode.h
//  MpegUrlKit
//
//  Created by Hinagiku Soranoba on 2017/01/06.
//  Copyright © 2017年 Hinagiku Soranoba. All rights reserved.
//

typedef NS_ENUM(NSUInteger, MUKErrorCode) {
    MUKErrorUnknown = 0,

    MUKErrorInvalidM3UFormat,
    MUKErrorInvalidVersion,
    MUKErrorInvalidMediaSegment,
    MUKErrorInvalidByteRange,
    MUKErrorInvalidEncrypt,
    MUKErrorInvalidAttributeList,
    MUKErrorInvalidType,
    MUKErrorInvalidMap,
    MUKErrorDuplicateTag,
    MUKErrorLocationIncorrect,
    MUKErrorMissingRequiredTag,
    MUKErrorInvalidDateRange,
    MUKErrorInvalidMedia,
    MUKErrorInvalidStreamInf,
    MUKErrorInvalidSesseionData,
    MUKErrorUnsupportedVersion,
};

extern NSString* const MUKErrorDomain;
