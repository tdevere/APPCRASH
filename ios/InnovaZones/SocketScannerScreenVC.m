//
//  SocketScannerScreenVC.m
//  InnovaZones
//
//  Created by KARTHI on 03 FEB, 2020.
//  Copyright © 2019 InnovaZones. All rights reserved.
//

#import "SocketScannerScreenVC.h"
#import "UIColorMake.h"
#import "DeviceListCell.h"
#import "AppDelegate.h"
#import "Utility.h"
#import "Constants.h"

@interface SocketScannerScreenVC (){
  NSMutableArray *arrSerialioDeviceList;
  NSMutableArray *arrScannerDataList;
  BOOL isDidSelectRS3ToConnect;
  NSLayoutConstraint *sliderValueLabelCenterXConstraint;
  NSLayoutConstraint *sliderValueLabelLeadingConstraint;
  NSLayoutConstraint *tblDeviceListHeightConstraints;
  
  NSArray * _accessoryList;
  
}

@end

@implementation SocketScannerScreenVC

- (void)viewDidLoad {
  [self customizeControl];
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

/**
 * Customize the UIcontrols background colors and labels corner radius.
 */
- (void)customizeControl {
  activityIndicator.hidden = YES;
  imgRadioActive.hidden = YES;
  activityIndicator.color = [UIColor whiteColor];
  tblDeviceList.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
  vwNavigation.backgroundColor = [UIColorMake ColorFromString:@"686868"];
  vwTop.backgroundColor = [UIColor whiteColor];
  vwDeviceList.backgroundColor = [UIColor whiteColor];
  lblScreenTitle.textColor = [UIColor whiteColor];
  lblConnectedDeviceTitile.textColor = [UIColorMake ColorFromString: @"6d6d72"];
  lblFoundDeviceTitile.textColor = [UIColorMake ColorFromString: @"6d6d72"];
  vwSlider.layer.borderWidth = 2.0f;
  vwSlider.layer.borderColor = [UIColorMake ColorFromString:@"6f7179"].CGColor;
  vwSlider.layer.cornerRadius = 5.0f;
  lblOutputPower.textColor = [UIColor blackColor];
  lblSliderOutputPower.textColor = [UIColor blackColor];
  
  [sliderOutputPower setMinimumTrackTintColor:[UIColorMake ColorFromString: @"e93731"]];
  sliderOutputPower.thumbTintColor = [UIColorMake ColorFromString: @"e93731"];
  btnSave.backgroundColor = [UIColorMake ColorFromString: @"e93731"];
  btnSave.layer.cornerRadius = 5.0f;
  lblOutputPower.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:20];
  lblSliderOutputPower.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:20];
}

#pragma mark -- IBAction
/**
 * Button action for back button tapped.
 */
- (IBAction)btnbackTouched:(id)sender {
  [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -- Table View Delegates
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  tblDeviceList = tableView;
  tblDeviceList.backgroundColor = [UIColor clearColor];
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger) section {
  return [_accessoryList count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return 50.0f;
}

- (UITableViewCell *)tableView : (UITableView *)atableView cellForRowAtIndexPath : (NSIndexPath *)indexPath {
  static NSString *cellIdentifier = @"deviceListIdentifier";
  DeviceListCell *deviceListCell = [atableView dequeueReusableCellWithIdentifier : cellIdentifier];
  if (deviceListCell == nil) {
    deviceListCell = [[DeviceListCell alloc]initWithStyle : UITableViewCellStyleDefault reuseIdentifier : cellIdentifier];
  }
//  EAAccessory * accessory = [_accessoryList objectAtIndex:indexPath.row];
//  deviceListCell.lblDeviceName.text = accessory.serialNumber;
  deviceListCell.selectionStyle = UITableViewCellSelectionStyleNone;
  return deviceListCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
  
  // The row is the offset into the list of connected accessories
}

@end
