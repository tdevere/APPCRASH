//
//  RFIDModule.m
//  InnovaZones
//
//  Created by KARTHI NALLIYAPPAN on 28/05/18.
//  Copyright © 2020 INNOVAZONES. All rights reserved.
//

#import "RFIDModule.h"
//#import "RFIDScreenVC.h"
#import "Constants.h"
#import "AppDelegate.h"
#import "Utility.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import <SDM/SDM-Swift.h>
#import "SerialioRFIDVC.h"

@interface RFIDModule (){
  
}
@property (nonatomic, strong) CBCentralManager* bluetoothManager;
@end

@implementation RFIDModule{
  //  RCTResponseSenderBlock nativeCallback;
  BOOL isRFIDTagRead;
  NSString *strScanType;
}


RCT_EXPORT_MODULE(RFIDModule);


-(NSArray <NSString *> *)supportedEvents {
  return @[@"rfidLoginScannedText", @"rfidProductScannedText", @"rfidCartScannedText", @"rfidEnrollScannedText", @"rfidReportAssetScannedText", @"rfidUniformScannedText"];
  
}

RCT_EXPORT_METHOD(openRFIDScannerSettingsView:(NSString *)rifidInfo) {
  
  NSData *dataJson = [rifidInfo dataUsingEncoding:NSUTF8StringEncoding];
  NSDictionary *dicJsonResponse = [NSJSONSerialization JSONObjectWithData:dataJson options:kNilOptions error:nil];
  strScanType = dicJsonResponse[@"scanType"];
  UIStoryboard *rfidStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
  dispatch_async(dispatch_get_main_queue(), ^{
    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    appDelegate.isRFIDNativeScreenOpen = true;

    SerialioRFIDVC * rfidViewController = [rfidStoryBoard instantiateViewControllerWithIdentifier:@"toSerialioRFIDVC"];
    rfidViewController.RFIDScannerResponseDelegate = self;
    rfidViewController.isRFIDAutoReconnect = dicJsonResponse[@"isRFIDAutoReconnect"];

    UIWindow *window=[UIApplication sharedApplication].keyWindow;
    UIViewController *root = [window rootViewController];
    [root presentViewController:rfidViewController animated:YES completion:nil];
    

  });
  
   [[SerialioDeviceManager shared] setUseNotifications:YES];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedData:) name:SerialioDeviceManager.ReceivedScan object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changedBluetoothState:) name:SerialioDeviceManager.BLEStateChanged object:nil];
   [[SerialioDeviceManager shared] start];
}

/**
 * Method for stop the call ring tone
 */
RCT_EXPORT_METHOD(startRFIDScanner :(NSString *)rifidInfo) {
  NSData *dataJson = [rifidInfo dataUsingEncoding:NSUTF8StringEncoding];
  NSDictionary *dicJsonResponse = [NSJSONSerialization JSONObjectWithData:dataJson options:kNilOptions error:nil];
  strScanType =  dicJsonResponse[@"scanType"];

  dispatch_async(dispatch_get_main_queue(), ^{
    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    appDelegate.isRFIDNativeScreenOpen = false;

    SerialioRFIDVC* RFIDScreen = [[SerialioRFIDVC alloc] init];
    RFIDScreen.RFIDScannerResponseDelegate = self;
    RFIDScreen.strScanStartType = @"START";
    RFIDScreen.isRFIDAutoReconnect = dicJsonResponse[@"isRFIDAutoReconnect"];
    [RFIDScreen viewDidLoad];
  });
  
   [[SerialioDeviceManager shared] setUseNotifications:YES];
  NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
  [nc addObserver:self selector:@selector(changedBluetoothState:) name:SerialioDeviceManager.BLEStateChanged object:nil];
  [nc addObserver:self selector:@selector(receivedData:) name:SerialioDeviceManager.ReceivedScan object:nil];
  [nc addObserver:self selector:@selector(connected:) name:SerialioDeviceManager.ConnectedToDevice object:nil];
  [nc addObserver:self selector:@selector(disconnected:) name:SerialioDeviceManager.DisconnectedDevice object:nil];

   [[SerialioDeviceManager shared] start];
}

- (void)receivedData:(NSNotification*)notification {
  AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
  if (!appDelegate.isRFIDDataTriggered) {
      appDelegate.isRFIDDataTriggered = true;
    Scan* scan = notification.userInfo[SerialioDeviceManager.UserInfoScanKey];
    if (!isRFIDTagRead) {
      [self sendScannedTextByEvent:scan.data withDeviceName:@"" withBluetoothAddress:@"" withType:SCANNED_VALUE];
      isRFIDTagRead = true;
    }
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(scanTriggerReset) userInfo:nil repeats:NO];
  }
}


- (void)connected:(NSNotification*)notification {
   AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
   Device* device = notification.userInfo[SerialioDeviceManager.UserInfoDeviceKey];
  if (!appDelegate.isRFIDNativeScreenOpen) {
    [self sendScannedTextByEvent:@"Connected" withDeviceName:device.name withBluetoothAddress:device.bluetoothAddress withType:DEVICE_CONNECTED_STATUS];
  }
}

- (void)disconnected:(NSNotification*)notification {
  AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
   Device* device = notification.userInfo[SerialioDeviceManager.UserInfoDeviceKey];
  if (!appDelegate.isRFIDNativeScreenOpen) {
    [self sendScannedTextByEvent:@"DisConnected" withDeviceName:device.name withBluetoothAddress:device.bluetoothAddress withType:DEVICE_CONNECTED_STATUS];
  }
}

-(void)scanTriggerReset{
  AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
  appDelegate.isRFIDDataTriggered = false;
}

- (void)changedBluetoothState:(NSNotification*)notification {
  CBManagerState state = [notification.userInfo[SerialioDeviceManager.UserInfoStateKey] integerValue];
  NSLog(@"*********** changedBluetoothState **************:%@",  [Helper stringWithCbState: state]);
  AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
  appDelegate.strBluetoothStatus = [Helper stringWithCbState: state];
//  [self sendScannedTextByEvent: [Helper stringWithCbState: state] withDeviceName:@"" withBluetoothAddress:@"" withType:DEVICE_CONNECTED_STATUS];
}

/*
 * Call back delegate - from RFIDScreen
 */
- (void)RFIDScannerResponseSuccess:(NSString *)scannerResponse{
  if (![scannerResponse isEqualToString:@"get us v"]) {
      [self sendScannedTextByEvent:scannerResponse withDeviceName:@"" withBluetoothAddress:@"" withType:SCANNED_VALUE];
  }
}

/*
* Call back delegate - from RFIDScreen
*/
-(void)RFIDScannerConnectionStatus:(NSString *)status withDeviceName:(NSString *)deviceName withBluetoothAddress:(NSString *)bluetoothAddress{
  [self sendScannedTextByEvent:status withDeviceName:(deviceName == nil) ? @"" : deviceName withBluetoothAddress:(bluetoothAddress == nil) ? @"" : bluetoothAddress withType:DEVICE_CONNECTED_STATUS];
}

/*
 * Call back event from native to React Native.
 */
- (void)sendScannedTextByEvent:(NSString *) Value withDeviceName: (NSString *) DeviceName withBluetoothAddress: (NSString *) BluetoothAddress withType: (NSString *) Type  {
  if ([strScanType isEqualToString:SCAN_TYPE_PRODUCT]) {
    [self sendEventWithName:@"rfidProductScannedText" body:@{
                                                             @"response": Value,
                                                             @"type": Type,
                                                             @"deviceName": DeviceName,
                                                             @"bluetoothAddress" : (BluetoothAddress == nil) ? @"" : BluetoothAddress
                                                             }];
  } else if ([strScanType isEqualToString:SCAN_TYPE_LOGIN]) {
    [self sendEventWithName:@"rfidLoginScannedText" body:@{
                                                           @"response": Value,
                                                           @"type": Type,
                                                           @"deviceName": DeviceName,
                                                           @"bluetoothAddress" : (BluetoothAddress == nil) ? @"" : BluetoothAddress
                                                           }];
  }else if ([strScanType isEqualToString:SCAN_TYPE_CART]) {
    [self sendEventWithName:@"rfidCartScannedText" body:@{
                                                          @"response": Value,
                                                          @"type": Type,
                                                          @"deviceName": DeviceName,
                                                          @"bluetoothAddress" : (BluetoothAddress == nil) ? @"" : BluetoothAddress
                                                          }];
  }else if ([strScanType isEqualToString:SCAN_TYPE_ENROLL]) {
    [self sendEventWithName:@"rfidEnrollScannedText" body:@{
                                                            @"response": Value,
                                                            @"type": Type,
                                                            @"deviceName": DeviceName,
                                                            @"bluetoothAddress" : (BluetoothAddress == nil) ? @"" : BluetoothAddress
                                                            }];
  }else if ([strScanType isEqualToString:SCAN_TYPE_REPORT_ASSET_NO]) {
    [self sendEventWithName:@"rfidReportAssetScannedText" body:@{
                                                                 @"response": Value,
                                                                 @"type": Type,
                                                                 @"deviceName": DeviceName,
                                                                 @"bluetoothAddress" : (BluetoothAddress == nil) ? @"" : BluetoothAddress
                                                                 }];
  }
  else if ([strScanType isEqualToString:SCAN_TYPE_UNIFROM_ASSET_NO]) {
    [self sendEventWithName:@"rfidUniformScannedText" body:@{
                                                             @"response": Value,
                                                             @"type": Type,
                                                             @"deviceName": DeviceName,
                                                             @"bluetoothAddress" : (BluetoothAddress == nil) ? @"" : BluetoothAddress
                                                             }];
  }
  [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(stopAnimating) userInfo:nil repeats:NO];

}

-(void)stopAnimating{
  isRFIDTagRead = false;
}

RCT_EXPORT_METHOD(startLoader) {
  dispatch_async(dispatch_get_main_queue(), ^{
    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    [appDelegate showLoadingView:@""];
  });
}

RCT_EXPORT_METHOD(stopLoader) {
  dispatch_async(dispatch_get_main_queue(), ^{
    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    [appDelegate hideLoadingView];
  });
}


@end

