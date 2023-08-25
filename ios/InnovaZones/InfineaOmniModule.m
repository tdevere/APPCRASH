//
//  InfineaOmniModule.m
//  InnovaZones
//
//  Created by User on 7/1/19.
//  Copyright © 2019 Facebook. All rights reserved.
//

#import "InfineaOmniModule.h"
#import "Constants.h"
#import "AVFoundation/AVFoundation.h"
#import <CommonCrypto/CommonDigest.h>
#import <QuantumSDK/QuantumSDK.h>

@implementation InfineaOmniModule{
  NSMutableString *status;
  NSMutableString *debug;
//  IPCDTDevices *dtdev;
  IPCDTDevices * scanner;
  NSString *strInfineaDeviceScanType;
  NSString *strScanType;
}

RCT_EXPORT_MODULE(InfineaOmniModule)

- (NSArray<NSString *> *)supportedEvents {
  return @[@"infineaLoginScannedText", @"infineaProductScannedText", @"infineaCartScannedText", @"infineaEnrollScannedText", @"infineaReportAssetScannedText", @"infineaStationZoneScannedText",
  @"infineaUniformZoneScannedText"];
}

/*!
 * @brief It is being called in react native classes. Used to scan barcode and magnetics strip card using Infinea device
 * @discussion
 * This Method calls to detect the bardcode and magnetic stripe using the Infinea device and sends the resposne through a event listener to the react native
 */
RCT_EXPORT_METHOD(startInfineaScan:(NSString * ) infineaDeviceScanType) {
  NSData *dataJson = [infineaDeviceScanType dataUsingEncoding:NSUTF8StringEncoding];
  NSDictionary *dicJsonResponse = [NSJSONSerialization JSONObjectWithData:dataJson options:kNilOptions error:nil];
  strScanType = dicJsonResponse[@"scanType"];

  scanner = [IPCDTDevices sharedDevice];
  [scanner addDelegate:self];
  [scanner connect];
  strInfineaDeviceScanType = dicJsonResponse[@"scanMode"];
    
  NSError *error = nil;
  [scanner barcodeStartScan:&error];
//  dtdev = [IPCDTDevices sharedDevice];
//  [dtdev addDelegate:self];
  
}

#pragma mark - IPCDTDeviceDelegate
-(void)connectionState:(int)state{
  if (state == CONN_CONNECTED) {
    NSError *error = nil;
    [scanner barcodeStartScan:&error];
    [self sendScannedTextByEvent:@"Connected" withType:DEVICE_CONNECTED_STATUS withResponseCode:0];
  } else if (state == CONN_DISCONNECTED) {
    [self sendScannedTextByEvent:@"DisConnected" withType:DEVICE_CONNECTED_STATUS withResponseCode:2];
  } else if (state == CONN_CONNECTING) {
    [self sendScannedTextByEvent:@"Connecting" withType:DEVICE_CONNECTED_STATUS withResponseCode:1];
  }
}

/*
 * This Method calls to detect the bardcode using the Infinea device
 */
-(void)barcodeData:(NSString *)barcode type:(int)type{
  NSLog(@"*********** Scanned bar code Value ***********: %@", barcode);
  
  NSError *error = nil;
  [scanner barcodeStopScan:&error];

  if ([strInfineaDeviceScanType isEqualToString:@"0"] || [strInfineaDeviceScanType isEqualToString:@"2"]) {
    [self sendScannedTextByEvent:barcode withType:SCANNED_VALUE withResponseCode:0];
  }
  
//  [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(scanTriggerReset) userInfo:nil repeats:NO];
}

-(void)scanTriggerReset{
  NSError *error = nil;
  [scanner barcodeStartScan:&error];
}

/*
 * This Method calls to detect the magnetic stripe using the Infinea device
 */
-(void)magneticCardData:(NSString *)track1 track2:(NSString *)track2 track3:(NSString *)track3 source:(int)source {
  NSLog(@"*********** magnetic Card Data Value ***********: %@", track2);
  if ([strInfineaDeviceScanType isEqualToString:@"0"] || [strInfineaDeviceScanType isEqualToString:@"1"]) {
    int sound[]={2730,150,0,30,2730,150};
    [scanner playSound:100 beepData:sound length:sizeof(sound) error:nil];
    [self sendScannedTextByEvent:track2 withType:SCANNED_VALUE withResponseCode:0];
  }
}

AVAudioPlayer *audioPlayer;

+(void)playSound:(NSString *)fileName volume:(float)volume {
  NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] resourcePath],fileName]];
  
  NSError *error;
  audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
  audioPlayer.volume=volume;
  audioPlayer.numberOfLoops = 0;
  
  [audioPlayer play];
}

/*
 * Call back event from native to React Native.
 */
- (void)sendScannedTextByEvent:(NSString *) Value withType: (NSString *) Type withResponseCode:(int) ResponseCode{
  if ([strScanType isEqualToString:SCAN_TYPE_LOGIN]) {
    [self sendEventWithName:@"infineaLoginScannedText" body:@{@"response": Value, @"type": Type,  @"responseCode": [NSNumber numberWithFloat:ResponseCode] }];
  }else if ([strScanType isEqualToString:SCAN_TYPE_PRODUCT]) {
    [self sendEventWithName:@"infineaProductScannedText" body:@{@"response": Value, @"type": Type,  @"responseCode": [NSNumber numberWithFloat:ResponseCode] }];
  }else if ([strScanType isEqualToString:SCAN_TYPE_CART]) {
    [self sendEventWithName:@"infineaCartScannedText" body:@{@"response": Value, @"type": Type,  @"responseCode": [NSNumber numberWithFloat:ResponseCode] }];
  }else if ([strScanType isEqualToString:SCAN_TYPE_ENROLL]) {
    [self sendEventWithName:@"infineaEnrollScannedText" body:@{@"response": Value, @"type": Type,  @"responseCode": [NSNumber numberWithFloat:ResponseCode] }];
  }else if ([strScanType isEqualToString:SCAN_TYPE_REPORT_ASSET_NO]) {
    [self sendEventWithName:@"infineaReportAssetScannedText" body:@{@"response": Value, @"type": Type,  @"responseCode": [NSNumber numberWithFloat:ResponseCode] }];
  }else if ([strScanType isEqualToString:SCAN_TYPE_STATION_ASSET_NO]) {
    [self sendEventWithName:@"infineaStationZoneScannedText" body:@{@"response": Value, @"type": Type,  @"responseCode": [NSNumber numberWithFloat:ResponseCode] }];
  }else if ([strScanType isEqualToString:SCAN_TYPE_UNIFORM_EMPLOYEE_ID]) {
    [self sendEventWithName:@"infineaUniformZoneScannedText" body:@{@"response": Value, @"type": Type,  @"responseCode": [NSNumber numberWithFloat:ResponseCode] }];
  }
}


RCT_EXPORT_METHOD(startScanService) {
  dispatch_async(dispatch_get_main_queue(), ^{
    NSError *error = nil;
    [scanner barcodeStartScan:&error];
  });
}

RCT_EXPORT_METHOD(stopScanService) {
  dispatch_async(dispatch_get_main_queue(), ^{
    NSError *error = nil;
    [scanner barcodeStopScan:&error];
  });
}


@end
