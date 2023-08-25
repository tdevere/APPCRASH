//
//  RFIDModule.h
//  InnovaZones
//
//  Created by KARTHI NALLIYAPPAN on 28/05/18.
//  Copyright © 2020 INNOVAZONES. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>
//#import "RFIDScreenVC.h"
#import "SerialioRFIDVC.h"

@interface RFIDModule : RCTEventEmitter <RCTBridgeModule, RFIDScannerResponseDelegate>

@end
