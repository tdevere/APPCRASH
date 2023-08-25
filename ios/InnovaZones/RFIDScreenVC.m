////
////  RFIDScreenVC.m
////  InnovaZones
////
////  Created by KARTHI NALLIYAPPAN on 28/05/18.
////  Copyright © 2018 INNOVAZONES. All rights reserved.
////
//
//#import "RFIDScreenVC.h"
//#import "UIColorMake.h"
//#import "DeviceListCell.h"
//#import "AppDelegate.h"
//#import "Utility.h"
//#import "Constants.h"
//#import <SDM/SDM-Swift.h>
//
//@interface RFIDScreenVC (){
//  NSMutableArray *arrSerialioDeviceList;
//  BOOL isDidSelectRS3ToConnect;
//  BOOL isDidSelectedRS3;
//  BOOL isDeviceSearching;
//  Device *connectedDevice;
//  BOOL isConnectedDeviceTapped;
//  BOOL isDisConnectedDeviceTapped;
//  NSMutableArray* arrConnectedDevice;
//  NSString *strConnectedDeviceName;
//  NSNotificationCenter* nc ;
//}
//@end
//
//@implementation RFIDScreenVC
//@synthesize RFIDScannerResponseDelegate, isRFIDAutoReconnect;
//- (void)viewDidLoad {
//  [self customizeControl];
//  activityIndicator.hidden = YES;
//  activityIndicator.color = [UIColor whiteColor];
//  tblDeviceList.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
//  arrSerialioDeviceList = [NSMutableArray new];
//  imgRadioActive.hidden = YES;
//  isDisConnectedDeviceTapped = true;
//  arrConnectedDevice = @[].mutableCopy;
//  strConnectedDeviceName = @"";
//  [[SerialioDeviceManager shared] setUseNotifications:YES];
//  [[SerialioDeviceManager shared] start];
//  nc = [NSNotificationCenter defaultCenter];
//
//  [nc addObserver:self selector:@selector(connected:) name:SerialioDeviceManager.ConnectedToDevice object:nil];
//  [nc addObserver:self selector:@selector(disconnected:) name:SerialioDeviceManager.DisconnectedDevice object:nil];
//  [nc addObserver:self selector:@selector(receivedData:) name:SerialioDeviceManager.ReceivedScan object:nil];
//  [nc addObserver:self selector:@selector(connecting:) name:SerialioDeviceManager.ConnectingToDevice object:nil];
//  [nc addObserver:self selector:@selector(detectedTag:) name:SerialioDeviceManager.DetectedTag object:nil];
//  [nc addObserver:self selector:@selector(lostTag:) name:SerialioDeviceManager.LostTag object:nil];
//  [nc addObserver:self selector:@selector(foundDevice:) name:SerialioDeviceManager.FoundDevice object:nil];
//
//  [nc addObserver:self selector:@selector(notifyText:) name:SerialioDeviceManager.NotifyText object:nil];
//  [nc addObserver:self selector:@selector(notifyWheel:) name:SerialioDeviceManager.NotifyIndeterminate object:nil];
//  [nc addObserver:self selector:@selector(notifyProgress:) name:SerialioDeviceManager.NotifyDeterminate object:nil];
//  [nc addObserver:self selector:@selector(notifyHide:) name:SerialioDeviceManager.NotifyHide object:nil];
//
//
//  // reconnect to previously connected (recent) devices on application start
//  if ([isRFIDAutoReconnect isEqualToString:@"YES"]) {
//   [SerialioDeviceManager shared].connectToLastRecentDevicesEnabled = YES;
//
//  }else {
//   [SerialioDeviceManager shared].connectToLastRecentDevicesEnabled = NO;
//  }
//  [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(checkDevice) userInfo:nil repeats:NO];
//  [super viewDidLoad];
//  // Do any additional setup after loading the view.
//}
//
//-(void)checkDevice{
//  if (![arrSerialioDeviceList count] && !isDidSelectRS3ToConnect) {
//    isDeviceSearching = true;
//     [self btnSearchTouched:btnSearch];
//   }
//
//    NSArray<Device*>* found  = [SerialioDeviceManager shared].connectedDevices;
//    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
//      [found enumerateObjectsUsingBlock:^(Device * _Nonnull device, NSUInteger idx, BOOL * _Nonnull stop) {
//         if (device.state == ConnectionStateConnected) {
//            lblConnectedDeviceName.text = [NSString stringWithFormat:@"%@ (%@)", device.name, device.bluetoothAddress];
//            imgRadioActive.hidden = NO;
//            isDidSelectRS3ToConnect = true;
//            connectedDevice = device;
//           strConnectedDeviceName = device.name;
//            [self stopAnimating];
//  //         tblDeviceList.hidden = YES;
//         }
//       }];
//    if (isDidSelectRS3ToConnect) {
//       if (!appDelegate.isRFIDNativeScreenOpen) {
//        if ([RFIDScannerResponseDelegate respondsToSelector:@selector(RFIDScannerConnectionStatus:withDeviceName:withBluetoothAddress:)]) {
//          [RFIDScannerResponseDelegate RFIDScannerConnectionStatus:@"Connected" withDeviceName:connectedDevice.name withBluetoothAddress:connectedDevice.bluetoothAddress];
//        }
//      }
//      tblDeviceList.hidden = YES;
//      if ([RFIDScannerResponseDelegate respondsToSelector:@selector(RFIDScannerConnectionStatus:withDeviceName:withBluetoothAddress:)]) {
//                [RFIDScannerResponseDelegate RFIDScannerConnectionStatus:@"DeviceConnected" withDeviceName:connectedDevice.name withBluetoothAddress:connectedDevice.bluetoothAddress];
//       }
//    }else {
//
//      if (!appDelegate.isRFIDNativeScreenOpen) {
//           if ([RFIDScannerResponseDelegate respondsToSelector:@selector(RFIDScannerConnectionStatus:withDeviceName:withBluetoothAddress:)]) {
//             [RFIDScannerResponseDelegate RFIDScannerConnectionStatus:@"Notfound" withDeviceName:connectedDevice.name withBluetoothAddress:connectedDevice.bluetoothAddress];
//           }
//      }
//
////      arrSerialioDeviceList = found.mutableCopy;
////      [tblDeviceList reloadData];
//    }
//
//}
//
///**
// * Customize the UIcontrols background colors and labels corner radius.
// */
//- (void)customizeControl {
//  vwNavigation.backgroundColor = [UIColorMake ColorFromString:@"686868"];
//  vwTop.backgroundColor = [UIColor whiteColor];
//  vwDeviceList.backgroundColor = [UIColor whiteColor];
//  lblScreenTitle.textColor = [UIColor whiteColor];
//  lblConnectedDeviceTitile.textColor = [UIColorMake ColorFromString: @"6d6d72"];
//  lblFoundDeviceTitile.textColor = [UIColorMake ColorFromString: @"6d6d72"];
//}
//
//
//#pragma mark -- IBAction
///**
// * Button action for back button.
// */
//- (IBAction)btnbackTouched:(id)sender {
//  AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
//  appDelegate.isRFIDNativeScreenOpen = false;
//  [self dismissViewControllerAnimated:YES completion:nil];
//}
//
//
//- (void)connected:(NSNotification*)notification {
//  AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
////  if (isDisConnectedDeviceTapped) {
//    Device* device = notification.userInfo[SerialioDeviceManager.UserInfoDeviceKey];
//    connectedDevice = device;
//    strConnectedDeviceName = device.name;
//    lblConnectedDeviceName.text = [NSString stringWithFormat:@"%@ (%@)", device.name, device.bluetoothAddress];
//    imgRadioActive.hidden = NO;
//    isDidSelectedRS3 = false;
//    [appDelegate hideLoadingView];
//    [self stopAnimating];
//    NSString *strMessage = [NSString stringWithFormat:@"RFID Device %@ (%@) Connected", device.name, device.bluetoothAddress];
//    [appDelegate showToastMessage:strMessage];
//    if ([RFIDScannerResponseDelegate respondsToSelector:@selector(RFIDScannerConnectionStatus:withDeviceName:withBluetoothAddress:)]) {
//             [RFIDScannerResponseDelegate RFIDScannerConnectionStatus:@"DeviceConnected" withDeviceName:connectedDevice.name withBluetoothAddress:connectedDevice.bluetoothAddress];
//    }
//    isDisConnectedDeviceTapped = false;
//    isConnectedDeviceTapped = true;
//    isDidSelectRS3ToConnect = true;
//    for (int i =0 ; i < arrSerialioDeviceList.count; i++) {
//      DeviceInfo* deviceInfo =  arrSerialioDeviceList[i];
//      if ([deviceInfo.displayName isEqualToString:device.name]) {
//        [arrSerialioDeviceList removeObjectAtIndex:i];
//        [tblDeviceList reloadData];
//      }
//    }
////  }
//  [appDelegate hideLoadingView];
//  [tblDeviceList reloadData];
//  [[NSUserDefaults standardUserDefaults] setObject:@"CONNECTED" forKey:@"isRS3RFIDConnectedFirstTime"];
//  [[NSUserDefaults standardUserDefaults] synchronize];
//  arrConnectedDevice = @[].mutableCopy;
//}
//
//- (void)disconnected:(NSNotification*)notification {
//
//  if (isConnectedDeviceTapped) {
//    Device* device = notification.userInfo[SerialioDeviceManager.UserInfoDeviceKey];
//    lblConnectedDeviceName.text = @"";
//    imgRadioActive.hidden = YES;
//    strConnectedDeviceName = @"";
//    NSLog(@"Disonnected: %@", device.name);
//    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
//    NSString *strMessage = [NSString stringWithFormat:@"RFID Device %@ (%@) Disconnected", device.name, device.bluetoothAddress];
//    [appDelegate showToastMessage:strMessage];
//    tblDeviceList.hidden = NO;
//    isDidSelectedRS3 = false;
//    isConnectedDeviceTapped = false;
//    isDisConnectedDeviceTapped = true;
//  }
//}
//
//- (void)receivedData:(NSNotification*)notification {
//  AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
//
//  if (!appDelegate.isRFIDDataTriggered) {
//      appDelegate.isRFIDDataTriggered = true;
//
//      Device* device = notification.userInfo[SerialioDeviceManager.UserInfoDeviceKey];
//      Scan* scan = notification.userInfo[SerialioDeviceManager.UserInfoScanKey];
//
//      NSLog(@"[%@] %@: %@:", device.name, [Helper stringWithDataType:scan.dataLabel], scan.data ?: @"");
//
//    if ([RFIDScannerResponseDelegate respondsToSelector:@selector(RFIDScannerResponseSuccess:)]) {
//      [RFIDScannerResponseDelegate RFIDScannerResponseSuccess:scan.data];
//    }
//
//  [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(scanTriggerReset) userInfo:nil repeats:NO];
//  }
//}
//
//- (void)notifyText:(NSNotification*)notification {
//    NSString* text = notification.userInfo[SerialioDeviceManager.UserInfoTextKey];
//    NSString* details = notification.userInfo[SerialioDeviceManager.UserInfoDetailsKey];
//}
//
//- (void)notifyWheel:(NSNotification*)notification {
//    NSString* text = notification.userInfo[SerialioDeviceManager.UserInfoTextKey];
//    NSString* details = notification.userInfo[SerialioDeviceManager.UserInfoDetailsKey];
//}
//
//- (void)notifyProgress:(NSNotification*)notification {
//    NSString* text = notification.userInfo[SerialioDeviceManager.UserInfoTextKey];
//    NSString* details = notification.userInfo[SerialioDeviceManager.UserInfoDetailsKey];
//    CGFloat progress = [notification.userInfo[SerialioDeviceManager.UserInfoProgressKey] floatValue];
//}
//
//- (void)notifyHide:(NSNotification*)notification {
//    //[self hideHUD];
//}
//
//-(void)scanTriggerReset{
//  AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
//  appDelegate.isRFIDDataTriggered = false;
//}
//
// - (void)foundDevice:(NSNotification*)notification {
//   NSArray<DeviceInfo*>* found = SerialioDeviceManager.shared.foundDevices;
//   arrSerialioDeviceList = found.mutableCopy;
//   tblDeviceList.hidden = NO;
//   [self stopAnimating];
//
//   if (isDidSelectRS3ToConnect) {
//     for (int i =0 ; i < arrSerialioDeviceList.count; i++) {
//       DeviceInfo* deviceInfo =  arrSerialioDeviceList[i];
//       if ([deviceInfo.displayName isEqualToString: strConnectedDeviceName]) {
//         [arrSerialioDeviceList removeObjectAtIndex:i];
//         [tblDeviceList reloadData];
//       }
//     }
//   }
//
//   [tblDeviceList reloadData];
//
//   if ([isRFIDAutoReconnect isEqualToString:@"YES"]) {
//         DeviceInfo* deviceInfo = notification.userInfo[SerialioDeviceManager.UserInfoDeviceKey];
//     if ([arrConnectedDevice containsObject:deviceInfo.displayName]) {
//        [[SerialioDeviceManager shared] connectWithDeviceInfo:deviceInfo];
//     }
//   }
//}
//
//
//
//- (void)connecting:(NSNotification*)notification {
//    Device* device = notification.userInfo[SerialioDeviceManager.UserInfoDeviceKey];
//    NSLog(@"****** Connecting ******: %@", device.name);
//    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
//    if (isDidSelectedRS3) {
//      [appDelegate showLoadingView:@"Connecting..."];
//    }
//}
//
//- (void)detectedTag:(NSNotification*)notification {
//    Device* device = notification.userInfo[SerialioDeviceManager.UserInfoDeviceKey];
//    TagType tagType = (TagType)[notification.userInfo[SerialioDeviceManager.UserInfoTagTypeKey] integerValue];
//    NSLog(@"detectedTag: %@: %@", device.name, [Helper stringWithTagType:tagType]);
//}
//
//- (void)lostTag:(NSNotification*)notification {
//    Device* device = notification.userInfo[SerialioDeviceManager.UserInfoDeviceKey];
//    TagType tagType = (TagType)[notification.userInfo[SerialioDeviceManager.UserInfoTagTypeKey] integerValue];
//    NSLog(@"lostTag: %@: %@", device.name, [Helper stringWithTagType:tagType]);
//}
//
//
///**
// * Button action for search button.
// */
//- (IBAction)btnSearchTouched:(id)sender {
//    NSString *savedValue = [[NSUserDefaults standardUserDefaults] stringForKey:@"isRS3RFIDConnectedFirstTime"];
//    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
//    if (![savedValue isEqual:@"CONNECTED"] && appDelegate.isRFIDNativeScreenOpen) {
//      UINavigationController* nc = [[UINavigationController alloc] initWithRootViewController: SerialioDeviceManager.shared.viewController];
//      nc.modalPresentationStyle = UIModalPresentationFormSheet;
//      [self presentViewController:nc animated:YES completion:nil];
//    }
//    [self startAnimating];
//    NSArray<DeviceInfo*>* found = SerialioDeviceManager.shared.foundDevices;
//    arrSerialioDeviceList = found.mutableCopy;
//    for (DeviceInfo* device in found) {
//      [SerialioDeviceManager.shared connectWithDeviceInfo:device];
//    }
//    [tblDeviceList reloadData];
//}
//
//  /**
//   * Button action for connected device.
//   * Call the dicconnect device events
//   */
//- (IBAction)btnConnectedDeviceTouched:(id)sender {
//  lblConnectedDeviceName.text = @"";
//  isDidSelectRS3ToConnect = false;
//  isConnectedDeviceTapped = true;
//  imgRadioActive.hidden = YES;
//  NSArray<Device*>* connected = SerialioDeviceManager.shared.connectedDevices;
//  for (Device* device in connected) {
//    [SerialioDeviceManager.shared disconnectWithDevice:device];
//    [arrConnectedDevice addObject: device.name];
//  }
//  [tblDeviceList reloadData];
//}
//
//
//#pragma mark -- Table View Delegates
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//  tblDeviceList = tableView;
//  tblDeviceList.backgroundColor = [UIColor clearColor];
//  return 1;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger) section {
//  return [arrSerialioDeviceList count];
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//  return 50.0f;
//}
//
//- (UITableViewCell *)tableView : (UITableView *)atableView cellForRowAtIndexPath : (NSIndexPath *)indexPath {
//  static NSString *cellIdentifier = @"deviceListIdentifier";
//  DeviceListCell *deviceListCell = [atableView dequeueReusableCellWithIdentifier : cellIdentifier];
//  if (deviceListCell == nil) {
//    deviceListCell = [[DeviceListCell alloc]initWithStyle : UITableViewCellStyleDefault reuseIdentifier : cellIdentifier];
//  }
//
//  DeviceInfo* device =  [arrSerialioDeviceList objectAtIndex:indexPath.row];;
//  deviceListCell.lblDeviceName.textColor = [UIColorMake ColorFromString: @"#000000"];
//  deviceListCell.lblDeviceName.text = device.displayName;
//  deviceListCell.lblDeviceName.textAlignment = NSTextAlignmentLeft;
//  deviceListCell.selectionStyle = UITableViewCellSelectionStyleGray;
//  return deviceListCell;
//}
//
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//  isDidSelectRS3ToConnect = true;
//  isDidSelectedRS3 = true;
//  isDisConnectedDeviceTapped = true;
//  [SerialioDeviceManager.shared connectWithDeviceInfo:[arrSerialioDeviceList objectAtIndex:indexPath.row]];
//  AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
//  [appDelegate showLoadingView:@"Connecting..."];
//
//}
//
//#pragma mark - Serialio Device Manager Handlers
//
//-(void)stopAnimating{
//  activityIndicator.hidden = YES;
//  [activityIndicator stopAnimating];
//}
//
//
//-(void)startAnimating{
//  activityIndicator.hidden = NO;
//  [activityIndicator startAnimating];
//}
//
//- (void)didReceiveMemoryWarning {
//    [super didReceiveMemoryWarning];
//    // Dispose of any resources that can be recreated.
//}
//
//@end
//
//
//
