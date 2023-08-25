//
//  SerialioRFIDVC.m
//  InnovaZones
//
//  Created by KARTHI NALLIYAPPAN on 31/10/20.
//  Copyright © 2020 INNOVAZONES. All rights reserved.
//

#import "SerialioRFIDVC.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "UIColorMake.h"
#import "DeviceListCell.h"
#import "AppDelegate.h"
#import "Utility.h"
#import "Constants.h"
#import <SDM/SDM-Swift.h>

@interface SerialioRFIDVC (){
  NSMutableArray *arrSerialioDeviceList;
  BOOL isRS3ToConnected;
}

@end

@implementation SerialioRFIDVC
@synthesize RFIDScannerResponseDelegate, isRFIDAutoReconnect, strScanStartType;

- (void)viewDidLoad {
    [self customizeControl];
    activityIndicator.hidden = YES;
    activityIndicator.color = [UIColor whiteColor];
    tblDeviceList.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    arrSerialioDeviceList = [NSMutableArray new];
    imgRadioActive.hidden = YES;
 
    [[SerialioDeviceManager shared] setUseNotifications:YES];
    [[SerialioDeviceManager shared] start];
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(changedBluetoothState:) name:SerialioDeviceManager.BLEStateChanged object:nil];
    [nc addObserver:self selector:@selector(connected:) name:SerialioDeviceManager.ConnectedToDevice object:nil];
    [nc addObserver:self selector:@selector(disconnected:) name:SerialioDeviceManager.DisconnectedDevice object:nil];
    [nc addObserver:self selector:@selector(receivedData:) name:SerialioDeviceManager.ReceivedScan object:nil];
    [nc addObserver:self selector:@selector(foundDevice:) name:SerialioDeviceManager.FoundDevice object:nil];

    // reconnect to previously connected (recent) devices on application start
    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    if ([appDelegate.strBluetoothStatus isEqualToString:@"Powered on"]) {
       if ([isRFIDAutoReconnect isEqualToString:@"YES"]) {
         /// Enables to connect to last recent devices
         [SerialioDeviceManager shared].connectToLastRecentDevicesEnabled = YES;
       }else {
        [SerialioDeviceManager shared].connectToLastRecentDevicesEnabled = NO;
      }
    } else {
      [SerialioDeviceManager shared].connectToLastRecentDevicesEnabled = NO;
    }
  
  /// Max number of recent devices, new connected device will remove oldest device from recent
  [SerialioDeviceManager shared].maxRecentDevices = 1;
  
  NSArray<Device*>* connected = SerialioDeviceManager.shared.connectedDevices;
    for (Device* device in connected) {
       lblConnectedDeviceName.text = [NSString stringWithFormat:@"%@ (%@)", device.name, device.bluetoothAddress];
       imgRadioActive.hidden = NO;
       isRS3ToConnected = true;
        if (!appDelegate.isRFIDNativeScreenOpen) {
//          if ([RFIDScannerResponseDelegate respondsToSelector:@selector(RFIDScannerConnectionStatus:withDeviceName:withBluetoothAddress:)]) {
//            [RFIDScannerResponseDelegate RFIDScannerConnectionStatus:@"Connected" withDeviceName:device.name withBluetoothAddress:device.bluetoothAddress];
//          }
        }
       [self stopAnimating];
    }
  [self checkSerialioRFID];


  
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

/**
 * Customize the UIcontrols background colors and labels corner radius.
 */
- (void)customizeControl {
  vwNavigation.backgroundColor = [UIColorMake ColorFromString:@"686868"];
  vwTop.backgroundColor = [UIColor whiteColor];
  vwDeviceList.backgroundColor = [UIColor whiteColor];
  lblScreenTitle.textColor = [UIColor whiteColor];
  lblConnectedDeviceTitile.textColor = [UIColorMake ColorFromString: @"6d6d72"];
  lblFoundDeviceTitile.textColor = [UIColorMake ColorFromString: @"6d6d72"];
}

-(void)checkSerialioRFID{
  NSArray<DeviceInfo*>* found = SerialioDeviceManager.shared.foundDevices;
  if ([isRFIDAutoReconnect isEqualToString:@"YES"]) {
    for (DeviceInfo* device in found) {
      [SerialioDeviceManager.shared connectWithDeviceInfo:device];
    }
    if (![found count]) {
      [self noDeviceFoundcallBackEvent];
    }
  }else {
    if ([found count]) {
      arrSerialioDeviceList = found.mutableCopy;
      tblDeviceList.hidden = NO;
    }
     [tblDeviceList reloadData];
    [self noDeviceFoundcallBackEvent];
  }
  
}

-(void)noDeviceFoundcallBackEvent{
  AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
  if (!appDelegate.isRFIDNativeScreenOpen && !isRS3ToConnected) {
       if ([RFIDScannerResponseDelegate respondsToSelector:@selector(RFIDScannerConnectionStatus:withDeviceName:withBluetoothAddress:)]) {
         [RFIDScannerResponseDelegate RFIDScannerConnectionStatus:@"Notfound" withDeviceName:@""withBluetoothAddress:@""];
       }
  }
}

#pragma mark - Call back meethods

- (void)changedBluetoothState:(NSNotification*)notification {
    CBManagerState state = [notification.userInfo[SerialioDeviceManager.UserInfoStateKey] integerValue];
    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    appDelegate.strBluetoothStatus = [Helper stringWithCbState: state];
    // Powered off
}

- (void)connected:(NSNotification*)notification {
    Device* device = notification.userInfo[SerialioDeviceManager.UserInfoDeviceKey];
  AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];

  lblConnectedDeviceName.text = [NSString stringWithFormat:@"%@ (%@)", device.name, device.bluetoothAddress];
  imgRadioActive.hidden = NO;
  isRS3ToConnected = true;
  [appDelegate hideLoadingView];
  [self stopAnimating];
  NSString *strMessage = [NSString stringWithFormat:@"RFID Device %@ (%@) Connected", device.name, device.bluetoothAddress];
  [appDelegate showToastMessage:strMessage];
  if ([RFIDScannerResponseDelegate respondsToSelector:@selector(RFIDScannerConnectionStatus:withDeviceName:withBluetoothAddress:)]) {
           [RFIDScannerResponseDelegate RFIDScannerConnectionStatus:@"DeviceConnected" withDeviceName:device.name withBluetoothAddress:device.bluetoothAddress];
  }

    for (int i =0 ; i < arrSerialioDeviceList.count; i++) {
      DeviceInfo* deviceInfo =  arrSerialioDeviceList[i];
      if ([deviceInfo.displayName isEqualToString:device.name]) {
        [arrSerialioDeviceList removeObjectAtIndex:i];
        [tblDeviceList reloadData];
      }
    }
    [tblDeviceList reloadData];
    [[NSUserDefaults standardUserDefaults] setObject:@"CONNECTED" forKey:@"isRS3RFIDConnectedFirstTime"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)disconnected:(NSNotification*)notification {
  Device* device = notification.userInfo[SerialioDeviceManager.UserInfoDeviceKey];
  lblConnectedDeviceName.text = @"";
  imgRadioActive.hidden = YES;
  isRS3ToConnected = false;
  NSLog(@"Disonnected: %@", device.name);
  AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
  NSString *strMessage = [NSString stringWithFormat:@"RFID Device %@ (%@) Disconnected", device.name, device.bluetoothAddress];
  [appDelegate showToastMessage:strMessage];
  tblDeviceList.hidden = NO;

}

 - (void)foundDevice:(NSNotification*)notification {
   NSArray<DeviceInfo*>* found = SerialioDeviceManager.shared.foundDevices;
  if ([found count]) {
     arrSerialioDeviceList = found.mutableCopy;
     tblDeviceList.hidden = NO;
   }
    [tblDeviceList reloadData];
}

- (void)receivedData:(NSNotification*)notification {
  Device* device = notification.userInfo[SerialioDeviceManager.UserInfoDeviceKey];
  Scan* scan = notification.userInfo[SerialioDeviceManager.UserInfoScanKey];
  AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
  
    if (!appDelegate.isRFIDDataTriggered) {
        appDelegate.isRFIDDataTriggered = true;
        NSLog(@"[%@] %@: %@:", device.name, [Helper stringWithDataType:scan.dataLabel], scan.data ?: @"");
      if ([RFIDScannerResponseDelegate respondsToSelector:@selector(RFIDScannerResponseSuccess:)]) {
        [RFIDScannerResponseDelegate RFIDScannerResponseSuccess:scan.data];
      }
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(scanTriggerReset) userInfo:nil repeats:NO];
    }
}

-(void)scanTriggerReset{
  AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
  appDelegate.isRFIDDataTriggered = false;
}

#pragma mark -- IBAction
/**
 * Button action for back button.
 */
- (IBAction)btnbackTouched:(id)sender {
  AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
  appDelegate.isRFIDNativeScreenOpen = false;
  [self dismissViewControllerAnimated:YES completion:nil];
}

  /**
   * Button action for connected device.
   * Call the dicconnect device events
   */
- (IBAction)btnConnectedDeviceTouched:(id)sender {
  NSArray<Device*>* connected = SerialioDeviceManager.shared.connectedDevices;
   for (Device* device in connected) {
     [SerialioDeviceManager.shared disconnectWithDevice:device];
   }
}

/**
 * Button action for search button.
 */
- (IBAction)btnSearchTouched:(id)sender {
  AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
  if ([appDelegate.strBluetoothStatus isEqualToString:@"Powered on"]){
     NSString *savedValue = [[NSUserDefaults standardUserDefaults] stringForKey:@"isRS3RFIDConnectedFirstTime"];
     AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
     if (![savedValue isEqual:@"CONNECTED"] && appDelegate.isRFIDNativeScreenOpen) {
       UINavigationController* nc = [[UINavigationController alloc] initWithRootViewController: SerialioDeviceManager.shared.viewController];
       nc.modalPresentationStyle = UIModalPresentationFormSheet;
       [self presentViewController:nc animated:YES completion:nil];
     }
     [self startAnimating];
     NSArray<DeviceInfo*>* found = SerialioDeviceManager.shared.foundDevices;
     arrSerialioDeviceList = found.mutableCopy;
     for (DeviceInfo* device in found) {
       [SerialioDeviceManager.shared connectWithDeviceInfo:device];
     }
     [tblDeviceList reloadData];
   } else  if ([appDelegate.strBluetoothStatus isEqualToString:@"Powered off"]) {
     [appDelegate showToastMessage:BLUETOOTH_TURNED_OFF_MESSAGE];
   } else if ([appDelegate.strBluetoothStatus isEqualToString:@"Unsupported"]){
     [appDelegate showToastMessage:BLUETOOTH_NOT_SUPPORTED_MESSAGE];
   } else {
     [appDelegate showToastMessage:BLUETOOTH_TURNED_OFF_MESSAGE];
   }
}

#pragma mark -- Table View Delegates
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  tblDeviceList = tableView;
  tblDeviceList.backgroundColor = [UIColor clearColor];
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger) section {
  return [arrSerialioDeviceList count];
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
    
  DeviceInfo* device =  [arrSerialioDeviceList objectAtIndex:indexPath.row];;
  deviceListCell.lblDeviceName.textColor = [UIColorMake ColorFromString: @"#000000"];
  deviceListCell.lblDeviceName.text = device.displayName;
  deviceListCell.lblDeviceName.textAlignment = NSTextAlignmentLeft;
  deviceListCell.selectionStyle = UITableViewCellSelectionStyleGray;
  return deviceListCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [SerialioDeviceManager.shared connectWithDeviceInfo:[arrSerialioDeviceList objectAtIndex:indexPath.row]];
  AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
  [appDelegate showLoadingView:@"Connecting..."];
}


-(void)stopAnimating{
  activityIndicator.hidden = YES;
  [activityIndicator stopAnimating];
}

-(void)startAnimating{
  activityIndicator.hidden = NO;
  [activityIndicator startAnimating];
}

@end
