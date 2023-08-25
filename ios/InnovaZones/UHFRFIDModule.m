//
//  UHFRFIDModule.m
//  InnovaZones
//
//  Created by User on 7/17/19.
//  Copyright © 2019 Facebook. All rights reserved.
//

#import "UHFRFIDModule.h"
#import "UHFRFIDScreenVC.h"
#import "Constants.h"
#import "AppDelegate.h"

@implementation UHFRFIDModule{
  NSString *strScanType;
}

RCT_EXPORT_MODULE(UHFRFIDModule);

-(NSArray<NSString *> *) supportedEvents {
  return @[@"UHFRFIDProductScannedValue", @"UHFRFIDReportAssetScannedValue", @"UHFRFIDCartScannedValue", @"UHFRFIDUniformScannedValue",  @"UHFRFIDStationZoneAssetNoScannedValue"];
}

RCT_EXPORT_METHOD(openUHFRFIDScannerSettingsView:(NSString *)rifidInfo) {
  NSData *dataJson = [rifidInfo dataUsingEncoding:NSUTF8StringEncoding];
  NSDictionary *dicJsonResponse = [NSJSONSerialization JSONObjectWithData:dataJson options:kNilOptions error:nil];
  strScanType =  dicJsonResponse[@"scanType"];
  UIStoryboard *rfidStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
  UHFRFIDScreenVC * rfidViewController = [rfidStoryBoard instantiateViewControllerWithIdentifier:@"toUHFRFIDViewController"];
  rfidViewController.UHFRFIDScannerResponseDelegate = self;
  rfidViewController.strMultiScan =  dicJsonResponse[@"isMultiScan"];
  rfidViewController.strScanStartType = @"OPEN";
  dispatch_async(dispatch_get_main_queue(), ^{
    UIWindow *window=[UIApplication sharedApplication].keyWindow;
    UIViewController *root = [window rootViewController];
    [root presentViewController:rfidViewController animated:YES completion:nil];
  });
}

RCT_EXPORT_METHOD(startUHFRFIDScanner:(NSString *)rifidInfo) {
  NSData *dataJson = [rifidInfo dataUsingEncoding:NSUTF8StringEncoding];
  NSDictionary *dicJsonResponse = [NSJSONSerialization JSONObjectWithData:dataJson options:kNilOptions error:nil];
  strScanType =  dicJsonResponse[@"scanType"];
  dispatch_async(dispatch_get_main_queue(), ^{
    UHFRFIDScreenVC* uhfRFIDScreen = [[UHFRFIDScreenVC alloc] init];
    uhfRFIDScreen.UHFRFIDScannerResponseDelegate = self;
    uhfRFIDScreen.strMultiScan  =  dicJsonResponse[@"isMultiScan"];
    uhfRFIDScreen.strScanStartType = @"START";
    [uhfRFIDScreen viewDidLoad];
    [uhfRFIDScreen viewWillAppear:YES];
  });
}

/**
 * Call back delegate - from UHF-RFIDScreen
 */
- (void)UHFRFIDScannerResponseSuccess:(NSString *)scannerResponse withType:(NSString *)type{
  if ([type isEqualToString:SCANNED_VALUE]) {
    [self sendScannedTextByEvent:scannerResponse withDeviceName:@"" withType:SCANNED_VALUE];
  }else if ([type isEqualToString:DEVICE_BATTERY_STATUS]){
    [self sendScannedTextByEvent:scannerResponse withDeviceName:@"" withType:DEVICE_BATTERY_STATUS];
  }
}

/**
 * Call back delegate - from UHF-RFIDScreen
 */
-(void)UHFRFIDScannerResponseListSuccess:(NSArray *)responseList{
  if ([strScanType isEqualToString:SCAN_TYPE_PRODUCT]) {
    [self sendEventWithName:@"UHFRFIDProductScannedValue" body:@{
                                                                 @"response": responseList,
                                                                 @"type": SCANNED_VALUE,
                                                                 @"deviceName": @"",
                                                                 }];
  } else if ([strScanType isEqualToString:SCAN_TYPE_REPORT_ASSET_NO]) {
    [self sendEventWithName:@"UHFRFIDReportAssetScannedValue" body:@{
                                                                     @"response": responseList,
                                                                     @"type": SCANNED_VALUE,
                                                                     @"deviceName": @"",
                                                                     }];
  }else if ([strScanType isEqualToString:SCAN_TYPE_CART]) {
    [self sendEventWithName:@"UHFRFIDCartScannedValue" body:@{
                                                              @"response": responseList,
                                                              @"type": SCANNED_VALUE,
                                                              @"deviceName": @"",
                                                              }];
  }else if ([strScanType isEqualToString:SCAN_TYPE_UNIFROM_ASSET_NO]) {
    [self sendEventWithName:@"UHFRFIDUniformScannedValue" body:@{
                                                                 @"response": responseList,
                                                                 @"type": SCANNED_VALUE,
                                                                 @"deviceName": @"",
                                                                 }];
  }else if ([strScanType isEqualToString:SCAN_TYPE_STATION_ASSET_NO]) {
    [self sendEventWithName:@"UHFRFIDStationZoneAssetNoScannedValue" body:@{
                                                                            @"response": responseList,
                                                                            @"type": SCANNED_VALUE,
                                                                            @"deviceName": @"",
                                                                            }];
  }
}

/**
 * Call back event from native to React Native.
 */
- (void)sendScannedTextByEvent:(NSString *) Value withDeviceName: (NSString *) DeviceName withType: (NSString *) Type  {
  if ([strScanType isEqualToString:SCAN_TYPE_PRODUCT]) {
    [self sendEventWithName:@"UHFRFIDProductScannedValue" body:@{
                                                                 @"response": Value,
                                                                 @"type": Type,
                                                                 @"deviceName": DeviceName,
                                                                 }];
    
  }else if ([strScanType isEqualToString:SCAN_TYPE_CART]) {
    [self sendEventWithName:@"UHFRFIDCartScannedValue" body:@{
                                                              @"response": Value,
                                                              @"type": Type,
                                                              @"deviceName": DeviceName,
                                                              }];
  } else if ([strScanType isEqualToString:SCAN_TYPE_REPORT_ASSET_NO]) {
    [self sendEventWithName:@"UHFRFIDReportAssetScannedValue" body:@{
                                                                     @"response": Value,
                                                                     @"type": Type,
                                                                     @"deviceName": DeviceName,
                                                                     }];
  }else if ([strScanType isEqualToString:SCAN_TYPE_UNIFROM_ASSET_NO]) {
    [self sendEventWithName:@"UHFRFIDUniformScannedValue" body:@{
                                                                 @"response": Value,
                                                                 @"type": Type,
                                                                 @"deviceName": DeviceName,
                                                                 }];
  }else if ([strScanType isEqualToString:SCAN_TYPE_STATION_ASSET_NO]) {
    [self sendEventWithName:@"UHFRFIDStationZoneAssetNoScannedValue" body:@{
                                                                            @"response": Value,
                                                                            @"type": Type,
                                                                            @"deviceName": DeviceName,
                                                                            }];
  }
}

@end
