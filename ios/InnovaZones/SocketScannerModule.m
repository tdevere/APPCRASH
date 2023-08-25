//
//  SocketScannerModule.m
//  InnovaZones
//
//  Created by KARTHI on 03 FEB, 2020.
//  Copyright © 2019 InnovaZones. All rights reserved.
//

#import "SocketScannerModule.h"
#import "Constants.h"
#import "SocketScannerScreenVC.h"

@implementation SocketScannerModule{
  NSMutableString *status;
  NSMutableString *debug;
  NSString *strInfineaDeviceScanType;
  NSString *strScanType;
  SKTCaptureHelper* capture ;
}

RCT_EXPORT_MODULE(SocketScannerModule)

- (NSArray<NSString *> *)supportedEvents {
  return @[@"socketScannerLoginScannedText", @"socketScannerProductScannedText", @"socketScannerCartScannedText", @"socketScannerEnrollScannedText", @"socketScannerReportAssetScannedText"];
}

/*!
 * @brief It is being called in react native classes. Used to scan barcode using Socket Scanner device
 * @discussion
 * This Method calls to detect the bardcode using the Socket Scanner device and sends the resposne through a event listener to the react native
 */
RCT_EXPORT_METHOD(startScoketScan:(NSString * ) socketScanType) {
  NSData *dataJson = [socketScanType dataUsingEncoding:NSUTF8StringEncoding];
  NSDictionary *dicJsonResponse = [NSJSONSerialization JSONObjectWithData:dataJson options:kNilOptions error:nil];
  strScanType = dicJsonResponse[@"scanType"];

  // Fill out the AppInfo with the
  // developer ID, App Bundle ID, AppKey
  // coming from the Socket Mobile developer portal when registering your application for an AppKey
  SKTAppInfo* appInfo = [SKTAppInfo new];
  NSString *strCustomBundleIdentifier = [NSString stringWithFormat:@"ios:%@",[[NSBundle mainBundle] bundleIdentifier]];
  appInfo.AppID = strCustomBundleIdentifier;
  NSString *strBundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
  NSString *strDeveloperId  = ([strBundleIdentifier isEqualToString: QA_BUNDLE_ID]) ? SOCKET_SCANNER_QA_DEVELOPER_ID : SOCKET_SCANNER_PROD_DEVELOPER_ID;
  appInfo.DeveloperID = strDeveloperId;
  NSString *strAppkey =  ([strBundleIdentifier isEqualToString: QA_BUNDLE_ID]) ? SOCKET_SCANNER_QA_APP_KEY : SOCKET_SCANNER_PROD_APP_KEY;
  appInfo.AppKey = strAppkey;
  SKTCaptureHelper* capture = [SKTCaptureHelper sharedInstance];
  capture = [SKTCaptureHelper sharedInstance];
  [capture pushDelegate:self];
 [capture openWithAppInfo:appInfo completionHandler:^(SKTResult result) {
   NSLog(@"Opening Capture returns: %ld", result);
   }];
}

#pragma mark - Utilities
-(void)updateStatusFromDevices:(NSArray*)devices {
  NSString* status = @"";
  for(SKTCaptureHelperDevice* device in devices){
    status = [NSString stringWithFormat:@"%@ %@", status, device.friendlyName];
  }
  if(status.length == 0){
    status = @"No device connected";
  }
//  self.status.text = status;
}


#pragma mark - SKTCaptureHelper delegate
/**
 * called when a error needs to be reported to the application
 *
 * @param error contains the error code
 * @param message contains an optional message, can be null
 */
-(void)didReceiveError:(SKTResult) error withMessage:(NSString*) message{
  NSLog(@"didReceiveError %ld with message: %@", error, message);
}

/**
 * called when a device has connected to the host
 *
 * @param device identifies the device that just connected
 * @param result contains an error if something went wrong during the device connection
 */
-(void)didNotifyArrivalForDevice:(SKTCaptureHelperDevice*) r withResult:(SKTResult) result{
//  [self updateStatusFromDevices:[capture getDevicesList]];
  [self sendScannedTextByEvent:@"Connected" withType:DEVICE_CONNECTED_STATUS withResponseCode:0];
}

/**
 * called when a device has disconnected from the host
 *
 * @param device identifies the device that has just disconnected
 * @param result contains an error if something went wrong during the device disconnection
 */
-(void)didNotifyRemovalForDevice:(SKTCaptureHelperDevice*) device withResult:(SKTResult) result{
//  [self updateStatusFromDevices:[capture getDevicesList]];
  [self sendScannedTextByEvent:@"DisConnected" withType:DEVICE_CONNECTED_STATUS withResponseCode:0];
}

/**
 * called when decoded data are received from a device
 *
 * @param decodedData contains the decoded data
 * @param device identifies the device from which the decoded data comes from
 * @param result contains an error if something wrong happen while getting the decoded data
 * or if the SoftScan trigger operation has been cancelled
 */
-(void)didReceiveDecodedData:(SKTCaptureDecodedData*) decodedData fromDevice:(SKTCaptureHelperDevice*) device withResult:(SKTResult) result{
  NSString *text = [[decodedData.stringFromDecodedData componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] componentsJoinedByString:@""];
  [self sendScannedTextByEvent:[NSString stringWithFormat:@"%@", text] withType:SCANNED_VALUE withResponseCode:0];
//  [self.decodedDataText.text stringByAppendingString: @"\r\n"];
}


/*
 * Call back event from native to React Native based on the scan type.
 */
- (void)sendScannedTextByEvent:(NSString *) Value withType: (NSString *) Type withResponseCode:(int) ResponseCode{
  if ([strScanType isEqualToString:SCAN_TYPE_LOGIN]) {
    [self sendEventWithName:@"socketScannerLoginScannedText" body:@{@"response": Value, @"type": Type,  @"responseCode": [NSNumber numberWithFloat:ResponseCode] }];
  }else if ([strScanType isEqualToString:SCAN_TYPE_PRODUCT]) {
    [self sendEventWithName:@"socketScannerProductScannedText" body:@{@"response": Value, @"type": Type,  @"responseCode": [NSNumber numberWithFloat:ResponseCode] }];
  }else if ([strScanType isEqualToString:SCAN_TYPE_CART]) {
    [self sendEventWithName:@"socketScannerCartScannedText" body:@{@"response": Value, @"type": Type,  @"responseCode": [NSNumber numberWithFloat:ResponseCode] }];
  }else if ([strScanType isEqualToString:SCAN_TYPE_ENROLL]) {
    [self sendEventWithName:@"socketScannerEnrollScannedText" body:@{@"response": Value, @"type": Type,  @"responseCode": [NSNumber numberWithFloat:ResponseCode] }];
  }else if ([strScanType isEqualToString:SCAN_TYPE_REPORT_ASSET_NO]) {
    [self sendEventWithName:@"socketScannerReportAssetScannedText" body:@{@"response": Value, @"type": Type,  @"responseCode": [NSNumber numberWithFloat:ResponseCode] }];
  }
}


RCT_EXPORT_METHOD(customScanService:(NSString * ) value) {
  NSData *dataJson = [value dataUsingEncoding:NSUTF8StringEncoding];
  NSDictionary *dicJsonResponse = [NSJSONSerialization JSONObjectWithData:dataJson options:kNilOptions error:nil];
  dispatch_async(dispatch_get_main_queue(), ^{
    [self sendScannedTextByEvent:[NSString stringWithFormat:@"%@", dicJsonResponse[@"scanValue"]] withType:SCANNED_VALUE withResponseCode:0];
  });
}

@end
