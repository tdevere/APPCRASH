//
//  CCPBridge.h
//  cmbsdk_flutter
//
//  Created by Zhivko Manchev on 12.7.21.
//

#import <Foundation/Foundation.h>
#import <cmbSDK/cmbSDK.h>
#import <CMBCrossPlatform/CCPObservers.h>
#import <CMBCrossPlatform/CCPCompletions.h>

NS_ASSUME_NONNULL_BEGIN

@interface CCPBridge : NSObject

@property (nonatomic, weak) id<CMBReaderDeviceDelegate> ccpPluginDelegate;
@property (nonatomic, weak) id<CMBObserversDelegate> ccpPluginScanningStateDelegate;

// Init and handle connection
- (void)initReaderWithClass:(DataManDeviceClass)deviceClass callback:(CCPCompletion)resultCallback;
- (void)connect:(CCPCompletionWithResponse)resultCallback;
- (void)disconnect:(CCPCompletionWithResponse)resultCallback;

// Trigger
- (void)startScanning:(CCPCompletionWithResponse)resultCallback;
- (void)stopScanning:(CCPCompletionWithResponse)resultCallback;

// Configuration APIs
// Phone Camera reader specific settings
- (void)registerSDK:(NSString *)key;
- (void)setCameraMode:(CDMCameraMode)cameraMode;
- (void)setPreviewOptions:(CDMPreviewOption)previewOptions;
- (void)setPreviewOverlayMode:(int)overlayMode;
- (void)enableCameraFlag:(int)flag forMask:(int)mask completion:(CCPCompletionWithResponse)resultCallback;
- (void)disableCameraFlag:(int)flag forMask:(int)mask completion:(CCPCompletionWithResponse)resultCallback;
- (void)getCameraExposureCompensationRange:(CCPCompletionWithResponse)resultCallback;
- (void)setCameraExposureCompensation:(float)arg completion:(CCPCompletionWithResponse)resultCallback;
// Phone Camera preview container settings
- (void)setPreviewContainerPositionAndSizeX:(float)xp Y:(float)yp width:(float)wp height:(float)hp;
- (void)setPreviewContainerBelowStatusBar:(BOOL)belowStatusBar;
- (void)setPreviewContainerFullScreen;
- (void)showMessage:(NSString *)message;
- (void)hideMessage;
// Common settings
- (void)setStopScannerOnRotate:(BOOL)stopScannerOnRotate;
- (void)enableImage:(BOOL)enabled completion:(CCPCompletionWithResponse)resultCallback;
- (void)enableImageGraphics:(BOOL)enabled completion:(CCPCompletionWithResponse)resultCallback;
- (void)setSymbology:(CMBSymbology)symbology enabled:(BOOL)enabled completion:(CCPCompletionWithResponse)resultCallback;
- (void)isSymbologyEnabled:(CMBSymbology)symbology completion:(CCPCompletionWithResponse)resultCallback;
- (void)setLightsOn:(BOOL)lightsOn completion:(CCPCompletionWithResponse)resultCallback;
- (void)isLightsOnWithCompletion:(CCPCompletionWithResponse)resultCallback;
- (void)sendCommand:(NSString *)dmcc completion:(CCPCompletionWithResponse)resultCallback;
- (void)resetConfigWithCompletion:(CCPCompletionWithResponse)resultCallback;
- (void)beep:(CCPCompletionWithResponse)resultCallback;
- (void)getDeviceBatteryLevel:(CCPCompletionWithResponse)resultCallback;
- (void)getAvailability:(CCPCompletionWithResponse)resultCallback;
- (void)getConnectionState:(CCPCompletionWithResponse)resultCallback;
- (void)getSdkVersion:(CCPCompletionWithResponse)resultCallback;
- (void)setParser:(CMBResultParser)parser completion:(CCPCompletionWithResponse)resultCallback;
- (void)setReadStringEncoding:(CMBReadStringEncoding)readStringEncoding completion:(CCPCompletionWithResponse)completion;
- (void)setMDMReportingEnabled:(BOOL)enabled;
- (void)createMDMAuthCredentialsWithUsername:(NSString *)username password:(NSString *)password clientID:(NSString *)clientID clientSecret:(NSString*)clientSecret;

@end

NS_ASSUME_NONNULL_END
