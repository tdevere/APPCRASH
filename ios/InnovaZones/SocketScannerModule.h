//
//  SocketScannerModule.h
//  InnovaZones
//
//  Created by KARTHI on 03 FEB, 2020.
//  Copyright © 2019 InnovaZones. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>
#import <SKTCaptureObjC/SktCaptureHelper.h>

NS_ASSUME_NONNULL_BEGIN

@interface SocketScannerModule : RCTEventEmitter <RCTBridgeModule, SKTCaptureHelperDelegate>

@end

NS_ASSUME_NONNULL_END
