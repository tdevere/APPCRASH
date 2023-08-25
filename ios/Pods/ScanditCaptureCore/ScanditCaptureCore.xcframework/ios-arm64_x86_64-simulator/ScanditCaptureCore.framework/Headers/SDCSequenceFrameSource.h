/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2022- Scandit AG. All rights reserved.
 */

#import <AVFoundation/AVFoundation.h>
#import <ScanditCaptureCore/SDCFrameSource.h>

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(SequenceFrameSource)
SDC_EXPORTED_SYMBOL
@interface SDCSequenceFrameSource : NSObject <SDCFrameSource>

- (instancetype)initWithCaptureDevicePosition:(AVCaptureDevicePosition)captureDevicePosition
                                 lensPosition:(CGFloat)lensPosition;

- (void)switchToDesiredState:(SDCFrameSourceState)state;
- (void)addSampleBuffer:(CMSampleBufferRef)sampleBuffer;

@end

NS_ASSUME_NONNULL_END
