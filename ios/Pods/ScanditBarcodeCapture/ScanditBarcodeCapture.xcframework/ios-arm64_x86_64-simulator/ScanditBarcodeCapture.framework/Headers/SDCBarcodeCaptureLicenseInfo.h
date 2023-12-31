/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2022- Scandit AG. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import <ScanditCaptureCore/SDCBase.h>

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(BarcodeCaptureLicenseInfo)
SDC_EXPORTED_SYMBOL
@interface SDCBarcodeCaptureLicenseInfo : NSObject

@property (nonatomic, nonnull, readonly) NSSet<NSNumber *> *licensedSymbologies;
@property (nonatomic, nonnull, readonly) NSString *JSONString;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
