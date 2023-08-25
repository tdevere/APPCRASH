//
//  UHFRFIDModule.h
//  InnovaZones
//
//  Created by User on 7/17/19.
//  Copyright © 2019 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>
#import "UHFRFIDScreenVC.h"

NS_ASSUME_NONNULL_BEGIN

@interface UHFRFIDModule : RCTEventEmitter <RCTBridgeModule, UHFRFIDScannerResponseDelegate >

@end

NS_ASSUME_NONNULL_END
