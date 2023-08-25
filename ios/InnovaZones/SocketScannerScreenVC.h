//
//  SocketScannerScreenVC.h
//  InnovaZones
//
//  Created by KARTHI on 03 FEB, 2020.
//  Copyright © 2019 InnovaZones. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SocketScannerScreenVC : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
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

@end

NS_ASSUME_NONNULL_END
