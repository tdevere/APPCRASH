//
//  CustomSettingsModule.m
//  InnovaZones
//
//  Created by User on 7/1/19.
//  Copyright © 2019 Facebook. All rights reserved.
//

#import "CustomSettingsModule.h"
#import "Constants.h"
#import "AVFoundation/AVFoundation.h"
#import <CommonCrypto/CommonDigest.h>
#import <AVFoundation/AVFoundation.h>

@implementation CustomSettingsModule{
  NSMutableString *status;
  NSMutableString *debug;
  NSString *strInfineaDeviceScanType;
  NSString *strScanType;
}

RCT_EXPORT_MODULE(CustomSettingsModule)

- (NSArray<NSString *> *)supportedEvents {
  return @[@"serverCustomSettings"];
}

/*!
 * @brief It is being called in react native classes. Used to scan barcode and magnetics strip card using Infinea device
 * @discussion
 * This Method calls to detect the bardcode and magnetic stripe using the Infinea device and sends the resposne through a event listener to the react native
 */
RCT_EXPORT_METHOD(startCustomSettings) {
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(defaultsChanged:)
                                               name:NSUserDefaultsDidChangeNotification
                                             object:nil];
  
}

- (void)defaultsChanged:(NSNotification *)notification {
  NSString *strHostName = [[[NSUserDefaults standardUserDefaults]stringForKey:@"host_name"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
  NSString *strAPIVersion = [[[NSUserDefaults standardUserDefaults]stringForKey:@"api_version"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
  NSString *strExistingSelectedHostName = [[NSUserDefaults standardUserDefaults]stringForKey:@"selected_host_name"];
  NSString *strExistingApiVersion = [[NSUserDefaults standardUserDefaults]stringForKey:@"selected_api_version"];

  if ([strExistingSelectedHostName isEqual:[NSNull null]] || strExistingSelectedHostName == nil) {
    [[NSUserDefaults standardUserDefaults] setObject:strHostName forKey:@"selected_host_name"];
    [[NSUserDefaults standardUserDefaults] synchronize];
  }
  
  if ([strExistingApiVersion isEqual:[NSNull null]] || strExistingApiVersion == nil) {
    [[NSUserDefaults standardUserDefaults] setObject:strAPIVersion forKey:@"selected_api_version"];
    [[NSUserDefaults standardUserDefaults] synchronize];
  }
  
  if (![strExistingSelectedHostName isEqualToString:strHostName] && ![strHostName isEqualToString:@""]) {
    [[NSUserDefaults standardUserDefaults] setObject:strHostName forKey:@"selected_host_name"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self sendScannedTextByEvent:strHostName withAPIVersion:strAPIVersion withExistingSelectedHostName:(strExistingSelectedHostName == nil) ? @"" : strExistingSelectedHostName withExistingSelectedApiName:(strExistingApiVersion == nil) ? @"" : strExistingApiVersion];
  }
  
  if (![strExistingApiVersion isEqualToString:strAPIVersion] && ![strAPIVersion isEqualToString:@""]) {
    [[NSUserDefaults standardUserDefaults] setObject:strAPIVersion forKey:@"selected_api_version"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self sendScannedTextByEvent:strHostName withAPIVersion:strAPIVersion withExistingSelectedHostName:(strExistingSelectedHostName == nil) ? @"" : strExistingSelectedHostName withExistingSelectedApiName:(strExistingApiVersion == nil) ? @"" : strExistingApiVersion];
  }
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/*
 * Call back event from native to React Native.
 */
- (void)sendScannedTextByEvent:(NSString *) HostName withAPIVersion:(NSString *) APIVersion withExistingSelectedHostName: (NSString *) ExistingSelectedHostName withExistingSelectedApiName: (NSString *) ExistingSelectedApiName {
    [self sendEventWithName:@"serverCustomSettings" body:@{@"hostName": HostName, @"apiVersion": APIVersion,  @"existingSelectedHostName": ExistingSelectedHostName,  @"existingSelectedApiVersion": ExistingSelectedApiName}];
}

RCT_EXPORT_METHOD(customTorchLevel:(float)torchLevel) {
  dispatch_async(dispatch_get_main_queue(), ^{
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        if ([device hasTorch]) {
            [device lockForConfiguration:nil];
    //          torchLevel = AVCaptureMaxAvailableTorchLevel;
            [device setTorchModeOnWithLevel:torchLevel   error:nil];
            [device unlockForConfiguration];
        }

  });
}

@end
