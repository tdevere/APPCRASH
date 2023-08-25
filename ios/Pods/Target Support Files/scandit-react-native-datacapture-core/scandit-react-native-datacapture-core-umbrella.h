#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "ScanditDataCaptureCore/RCTEventEmitter+Private.h"
#import "ScanditDataCaptureCore/SDCDataCaptureView+Defaults.h"
#import "ScanditDataCaptureCore/ScanditDataCaptureCore-Bridging-Header.h"
#import "ScanditDataCaptureCore/ScanditDataCaptureCore.h"

FOUNDATION_EXPORT double ScanditDataCaptureCoreVersionNumber;
FOUNDATION_EXPORT const unsigned char ScanditDataCaptureCoreVersionString[];

