/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import <UIKit/UIKit.h>
#import <TSLAsciiCommands/TSLAsciiCommands.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <UserNotifications/UNUserNotificationCenter.h>
#import <React/RCTBridgeDelegate.h>
#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, CBCentralManagerDelegate, UNUserNotificationCenterDelegate>

@property (nonatomic, strong) UIWindow *window;
@property (strong, nonatomic) NSDictionary *dicConnectedRFIDDeviceInfo;
@property (assign, nonatomic) BOOL isRFIDDataTriggered;
@property (assign, nonatomic) BOOL isRFIDFirstTimeSearchCompleted;
@property (assign, nonatomic) BOOL isRFIDNativeScreenOpen;

@property (assign, nonatomic) int outputPowerValue;

@property (strong, nonatomic) NSString *strBluetoothStatus;
/// The commander to use for communicating with the reader accessory
@property (nonatomic, readonly) TSLAsciiCommander *commander;
@property (strong, nonatomic) UIView *loadingView;
@property (nonatomic, readonly) CBCentralManager *centralManager;

-(void) showLoadingView:(NSString *)strMessage;
-(void) hideLoadingView;
- (void)showToastMessage:(NSString *)strMessage;

@end
