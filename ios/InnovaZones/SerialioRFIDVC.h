//
//  SerialioRFIDVC.h
//  InnovaZones
//
//  Created by KARTHI NALLIYAPPAN on 31/10/20.
//  Copyright © 2020 INNOVAZONES. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>

NS_ASSUME_NONNULL_BEGIN

@protocol RFIDScannerResponseDelegate <NSObject>
-(void)RFIDScannerResponseSuccess:(NSString *)scannerResponse;
-(void)RFIDScannerConnectionStatus:(NSString *)status withDeviceName:(NSString *)deviceName withBluetoothAddress:(NSString *)bluetoothAddress;
@end


@interface SerialioRFIDVC : UIViewController < UITableViewDelegate, UITableViewDataSource>{
  IBOutlet UIView *vwMain;
  IBOutlet UIView *vwNavigation;
  IBOutlet UIView *vwTop;
  IBOutlet UIView *vwDeviceList;
  IBOutlet UIButton *btnBack;
  IBOutlet UIButton *btnSearch;
  IBOutlet UITableView *tblDeviceList;
  IBOutlet UIImageView *imgRadioActive;
  IBOutlet UILabel *lblConnectedDeviceTitile;
  IBOutlet UILabel *lblConnectedDeviceName;
  IBOutlet UILabel *lblFoundDeviceTitile;
  IBOutlet UILabel *lblScreenTitle;
  IBOutlet UIButton *btnConnectedDevice;

  IBOutlet UIActivityIndicatorView *activityIndicator;
}

@property (nonatomic, retain)id <RFIDScannerResponseDelegate> RFIDScannerResponseDelegate;
@property (nonatomic, retain) NSString *strScanStartType;
@property (nonatomic, retain) NSString * isRFIDAutoReconnect;

@end

NS_ASSUME_NONNULL_END
