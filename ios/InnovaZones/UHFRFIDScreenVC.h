//
//  UHFRFIDScreenVC.h
//  InnovaZones
//
//  Created by User on 7/17/19.
//  Copyright © 2019 Facebook. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TSLAsciiCommands/TSLAsciiCommands.h>

NS_ASSUME_NONNULL_BEGIN

@protocol UHFRFIDScannerResponseDelegate <NSObject>
-(void)UHFRFIDScannerResponseSuccess:(NSString *)scannerResponse withType:(NSString *)type;
-(void)UHFRFIDScannerResponseListSuccess:(NSArray *)responseList;
@end

@interface UHFRFIDScreenVC : UIViewController<UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate, TSLBarcodeCommandBarcodeReceivedDelegate >{
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
  
  IBOutlet UIView *vwSlider;
  IBOutlet UISlider *sliderOutputPower;
  IBOutlet UILabel *lblOutputPower;
  IBOutlet UIButton *btnSave;
  IBOutlet UILabel *lblSliderOutputPower;

  IBOutlet UIActivityIndicatorView *activityIndicator;

}
@property (nonatomic, retain)id <UHFRFIDScannerResponseDelegate> UHFRFIDScannerResponseDelegate;
@property (nonatomic, retain) NSString *strMultiScan;
@property (nonatomic, retain) NSString *strScanStartType;

@end

NS_ASSUME_NONNULL_END
