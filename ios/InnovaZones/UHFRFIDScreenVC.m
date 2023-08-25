//
//  UHFRFIDScreenVC.m
//  InnovaZones
//
//  Created by User on 7/17/19.
//  Copyright © 2019 Facebook. All rights reserved.
//

#import "UHFRFIDScreenVC.h"
#import "UIColorMake.h"
#import "DeviceListCell.h"
#import "AppDelegate.h"
#import "Utility.h"
#import "Constants.h"
#import <ExternalAccessory/ExternalAccessory.h>
#import <ExternalAccessory/EAAccessoryManager.h>


@interface UHFRFIDScreenVC (){
  NSMutableArray *arrSerialioDeviceList;
  NSMutableArray *arrScannerDataList;
  BOOL isDidSelectRS3ToConnect;
  NSLayoutConstraint *sliderValueLabelCenterXConstraint;
  NSLayoutConstraint *sliderValueLabelLeadingConstraint;
  NSLayoutConstraint *tblDeviceListHeightConstraints;
  
  NSArray * _accessoryList;
  TSLAsciiCommander *_commander;
  TSLInventoryCommand *_inventoryResponder;
  TSLBarcodeCommand *_barcodeResponder;
  
}
@property (nonatomic, readwrite) int transpondersSeen;
@property (nonatomic, readwrite) NSString *partialResultMessage;
@end

@implementation UHFRFIDScreenVC
@synthesize UHFRFIDScannerResponseDelegate, strMultiScan, strScanStartType;

- (void)viewDidLoad {
  [self UHFRFIDInitialSetup];
  [self customizeControl];
  activityIndicator.hidden = YES;
  activityIndicator.color = [UIColor whiteColor];
  tblDeviceList.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
  arrSerialioDeviceList = [NSMutableArray new];
  arrScannerDataList = [NSMutableArray new];
  imgRadioActive.hidden = YES;
  AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
  lblSliderOutputPower.text = [NSString stringWithFormat:@"Output Power : %d", (appDelegate.outputPowerValue == 0) ? 15 : appDelegate.outputPowerValue] ;
  sliderOutputPower.value = (appDelegate.outputPowerValue == 0) ? 15 : appDelegate.outputPowerValue;
  
  if ([self.strScanStartType isEqualToString:@"OPEN"]) {
    sliderValueLabelCenterXConstraint = [NSLayoutConstraint constraintWithItem:lblSliderOutputPower
                                                                     attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:sliderOutputPower attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0];
    
    //  sliderValueLabelLeadingConstraint = [NSLayoutConstraint constraintWithItem:lblSliderOutputPower
    //                                                                   attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:sliderOutputPower attribute:NSLayoutAttributeLeading multiplier:1.0f constant:0];
    
    
    //  [self.view addConstraint:sliderValueLabelLeadingConstraint];
    [self.view addConstraint:sliderValueLabelCenterXConstraint];
    
    //  [self powerLabelStartPosition];
    [self labelCenterXPositionChanged: [[NSString stringWithFormat:@"%0.0f", sliderOutputPower.value] intValue]];
    
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    
    tblDeviceListHeightConstraints = [NSLayoutConstraint constraintWithItem:tblDeviceList attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1.0 constant:screenHeight/ 2.73];
    [self.view addConstraint:tblDeviceListHeightConstraints];
  }
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)UHFRFIDInitialSetup{
  // Use a single AsciiCommander held in the AppDelegate
  _commander = ((AppDelegate *)[[UIApplication sharedApplication]delegate]).commander;
  
  // Create a TSLInventoryCommand
  _inventoryResponder = [[TSLInventoryCommand alloc] init];
  
  // Listen for accessory connect/disconnects
  [[EAAccessoryManager sharedAccessoryManager] registerForLocalNotifications];
  
  _accessoryList = [[EAAccessoryManager sharedAccessoryManager] connectedAccessories];
  
  if (_accessoryList.count) {
    [self uiControlsCustomize:NO];
  }else {
    [self uiControlsCustomize:YES];
  }
  
  // Use a single AsciiCommander held in the AppDelegate
  _commander = ((AppDelegate *)[[UIApplication sharedApplication]delegate]).commander;
  
  // Note: the weakSelf is used to avoid warning of retain cycles when self is used in Blocks
  __strong typeof(self) strongSelf = self;
  
  
  //
  // Performing an inventory could potentially take a long time if many transponders are in range so it is best to handle responses asynchronously
  //
  // The TSLInventoryCommand is also a TSLAsciiResponder for inventory responses and can have a transponderDataReceivedBlock
  // that is informed of each transponder as it is received
  
  // Create a TSLInventoryCommand
  _inventoryResponder = [[TSLInventoryCommand alloc] init];
  
  // Use the TransponderData-based per transponder Block callback
  arrScannerDataList = [NSMutableArray new];
  _inventoryResponder.transponderDataReceivedBlock = ^(TSLTransponderData *transponder, BOOL moreAvailable)
  {
    // Append the transponder EPC identifier and RSSI to the results
    NSString *strResult = (transponder.epc == nil) ? @"" : transponder.epc;
    NSString *myString = [transponder.rssi stringValue];
    
    NSMutableDictionary *dicScannedData = [NSMutableDictionary new];
    [dicScannedData setObject:strResult forKey:@"data"];
    
    if (![arrScannerDataList containsObject:dicScannedData]) {
      [arrScannerDataList  addObject:strResult];
    }
    // This changes UI elements so perform it on the UI thread
    // Avoid sending too many screen updates as it can stall the display
    if( !moreAvailable) // || _transpondersSeen < 3 || _transpondersSeen % 10 == 0
    {
      if (SCAN_TYPE_MULTIPLE == [strongSelf.strMultiScan intValue]) {
        [strongSelf performSelectorOnMainThread: @selector(updateResultList:) withObject:arrScannerDataList waitUntilDone:NO];
        [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(clearScannedDataList) userInfo:nil repeats:NO];
      }else {
        [strongSelf performSelectorOnMainThread: @selector(updateResults:) withObject:strResult waitUntilDone:NO];
        [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(clearScannedDataList) userInfo:nil repeats:NO];
      }
    }
  };
  
  // Pulling the Reader trigger will generate inventory responses that are not from the library.
  // To ensure these are also seen requires explicitly requesting handling of non-library command responses
  _inventoryResponder.captureNonLibraryResponses = YES;
  
  // Add the inventory responder to the commander's responder chain
  [_commander addResponder:_inventoryResponder];
  
  //
  // Handling barcode responses is similar to the inventory
  //
  _barcodeResponder = [[TSLBarcodeCommand alloc] init];
  _barcodeResponder.barcodeReceivedDelegate = self;
  _barcodeResponder.captureNonLibraryResponses = YES;
  
  [_commander addResponder:_barcodeResponder];
  
  // No transponders seen yet
  _transpondersSeen = 0;
  
  _partialResultMessage = @"";
  
  
  // Handling barcode responses is similar to the inventory
  _barcodeResponder = [[TSLBarcodeCommand alloc] init];
  _barcodeResponder.barcodeReceivedDelegate = self;
  _barcodeResponder.captureNonLibraryResponses = YES;
  [_commander addResponder:_barcodeResponder];
}

-(void)clearScannedDataList{
  [arrScannerDataList removeAllObjects];
}

/**
 * Result get from the UHF RFID scanner
 */
-(void)updateResults:(NSString *)data {
  if (data.length) {
    if ([UHFRFIDScannerResponseDelegate respondsToSelector:@selector(UHFRFIDScannerResponseSuccess:withType:)]) {
      [UHFRFIDScannerResponseDelegate UHFRFIDScannerResponseSuccess:data withType: SCANNED_VALUE];
    }
  }
}

/**
 * Result list of codes get from the UHF RFID scanner
 */
-(void)updateResultList:(NSArray *)data {
  if ([data count]) {
    if ([UHFRFIDScannerResponseDelegate respondsToSelector:@selector(UHFRFIDScannerResponseSuccess:withType:)]) {
      [UHFRFIDScannerResponseDelegate UHFRFIDScannerResponseListSuccess:data];
    }
  }
}

-(void)uiControlsCustomize:(BOOL)value {
  lblSliderOutputPower.hidden = value;
  sliderOutputPower.hidden = value;
  btnSave.hidden = value;
  lblOutputPower.hidden = value;
  vwSlider.hidden = value;
}

-(void)viewWillAppear:(BOOL)animated {
  // Listen for change in TSLAsciiCommander state
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(commanderChangedState:) name:TSLCommanderStateChangedNotification object:_commander];

  // Update list of connected accessories
  _accessoryList = [[EAAccessoryManager sharedAccessoryManager] connectedAccessories];

  // Prepare and show the connected reader, if any
  [self initConnectedReader: _commander.isConnected];
  [self showConnectedReader:_commander.isConnected];

  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accessoryDidConnect:) name:EAAccessoryDidConnectNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accessoryDidDisconnect:) name:EAAccessoryDidDisconnectNotification object:nil];
}

-(void)viewWillDisappear:(BOOL)animated {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -- Interface Orientation

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
  [super willRotateToInterfaceOrientation:
   toInterfaceOrientation duration:duration];
  
  UIInterfaceOrientation orientation = toInterfaceOrientation;
  
  CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;

  if (orientation == UIInterfaceOrientationPortrait ||  orientation == UIInterfaceOrientationPortraitUpsideDown) {
    tblDeviceListHeightConstraints.constant = screenHeight/ 2.73;
  }else if (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight) {
    tblDeviceListHeightConstraints.constant = screenHeight/ 4.1;
  }
}

-(void)commanderChangedState:(NSNotification *)notification {
  // The connected state is indicated by the presence or absence of userInfo
  BOOL isConnected = notification.userInfo != nil;
  
  [self initConnectedReader: isConnected];
  [self showConnectedReader: isConnected];
}

-(void)initConnectedReader:(BOOL)isConnected {
  if( isConnected ) {
    // Get version information for the reader
    // Use the TSLVersionInformationCommand synchronously as the returned information is needed below
    TSLVersionInformationCommand * versionCommand = [TSLVersionInformationCommand synchronousCommand];
    [_commander executeCommand:versionCommand];
    TSLBatteryStatusCommand *batteryCommand = [TSLBatteryStatusCommand synchronousCommand];
    [_commander executeCommand:batteryCommand];
    
    // Determine the pop-Loq mode - if not an ePop-Loq Reader then the popLoqMode parameter will be 'Not Specified'
    TSLFactoryDefaultsCommand *fdCommand = [TSLFactoryDefaultsCommand synchronousCommand];
    fdCommand.readParameters = TSL_TriState_YES;
    [_commander executeCommand:fdCommand];

    TSLInventoryCommand * inventoryCommand = [TSLInventoryCommand synchronousCommand];
    inventoryCommand.includeTransponderRSSI = TSL_TriState_YES;
    [_commander executeCommand:inventoryCommand];
    
    // Show the battery level if less than 10 percentage
    if (batteryCommand.batteryLevel < 10) {
      AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
      [appDelegate showToastMessage:@"UHFRFID Reader battery reach less than 10% percentage"];
    }
//    if ([UHFRFIDScannerResponseDelegate respondsToSelector:@selector(UHFRFIDScannerResponseSuccess:withType:)]) {
//      [UHFRFIDScannerResponseDelegate UHFRFIDScannerResponseSuccess:strBatteryLevel withType: DEVICE_BATTERY_STATUS];
//    }
    [self configureInventory];
    [self configureTSLBarcodeCommand];
  }
}

-(void)configureTSLBarcodeCommand {
  // Use the TSLBarcodeCommand
  TSLBarcodeCommand *barCommand = [TSLBarcodeCommand synchronousCommand];
  barCommand.barcodeReceivedDelegate = self;
  [_commander executeCommand:barCommand];
}

/*
 *  Display basic information about the reader
 */
-(void)showConnectedReader:(BOOL)isConnected {
  if( isConnected ){
    // Display the serial number, firmware revision, hardware revision of the successfully connected unit
    lblConnectedDeviceName.text = [NSString stringWithFormat:@"%@ FW: %@ HW: %@", _commander.connectedAccessory.serialNumber, _commander.connectedAccessory.firmwareRevision, _commander.connectedAccessory.hardwareRevision] ;
    imgRadioActive.hidden = NO;
  }else {
    lblConnectedDeviceName.text = @"";
    imgRadioActive.hidden = YES;
  }
  AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
  [appDelegate hideLoadingView];
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

#pragma mark -- Keep the list of connected devices up-to-date

-(void)accessoryDidConnect:(NSNotification *)notification {
  EAAccessory *connectedAccessory = [[notification userInfo] objectForKey:EAAccessoryKey];
  // Only notify of change if the accessory added has valid protocol strings
  if( connectedAccessory.protocolStrings.count != 0 ){
    _accessoryList = [[EAAccessoryManager sharedAccessoryManager] connectedAccessories];
    if (_accessoryList.count) {
      [self uiControlsCustomize:NO];
    }else {
      [self uiControlsCustomize:YES];
    }
    [tblDeviceList reloadData];
  }
}

- (void)accessoryDidDisconnect:(NSNotification *)notification {
  _accessoryList = [[EAAccessoryManager sharedAccessoryManager] connectedAccessories];
  if (_accessoryList.count) {
    [self uiControlsCustomize:NO];
  }else {
    [self uiControlsCustomize:YES];
  }
  [tblDeviceList reloadData];
}

#pragma mark -- IBAction
/**
 * Button action for back button tapped.
 */
- (IBAction)btnbackTouched:(id)sender {
  [self dismissViewControllerAnimated:YES completion:nil];
}

/**
 * Button action for save button tapped.
 */
- (IBAction)btnSaveTouched:(id)sender {
  if( _commander.isConnected ){
    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    [appDelegate showLoadingView:@""];
  }else {
    int value =  [[NSString stringWithFormat:@"%.00f", sliderOutputPower.value] intValue];
    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    appDelegate.outputPowerValue = value;
    [appDelegate showToastMessage:@"UHFRFID Reader :\n Output power changed successfully."];
  }
  [self updateReaderInventoryConfiguration];
}

/**
 * Button action for search button.
 */
- (IBAction)btnSearchTouched:(id)sender {
}

/**
 * Button action for connected device.
 * Call the dicconnect device events
 */
- (IBAction)btnConnectedDeviceTouched:(id)sender {
  if (_commander.isConnected) {
    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    [appDelegate showLoadingView:@"Disconnecting..."];
    [_commander disconnect];
  }
}

/**
 * Button action for slider value changes.
 * Call the output power label center x position change method
 */
- (IBAction)valueChangedSlider:(id)sender {
  lblSliderOutputPower.text = [NSString stringWithFormat:@"Output Power : %0.0f", sliderOutputPower.value];

//  [self powerLabelStartPosition];
  [self labelCenterXPositionChanged: [[NSString stringWithFormat:@"%0.0f", sliderOutputPower.value] intValue]];
}

- (IBAction)outputPowerEditingDidEnd:(id)sender {

//  [self updateReaderInventoryConfiguration];
}

/**
 * Update the reader with all User-modifiable inventory parameters
 */
-(void)updateReaderInventoryConfiguration {
  if( _commander.isConnected ) {
    TSLInventoryCommand *command = [TSLInventoryCommand synchronousCommand];
    command.takeNoAction = TSL_TriState_YES;
    
    [self configureUserInventoryParameters:command];
    
    [_commander executeCommand:command];
    
    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    if( !command.isSuccessful ){
      NSLog(@"!!! Failed to update the reader configuration !!!");
      [appDelegate hideLoadingView];
    }else {
      [appDelegate hideLoadingView];
      [appDelegate showToastMessage:@"UHFRFID Reader :\n Output power changed successfully."];
    }
  }
}

/**
 * Each output power changed from the slider - the output power label leading position.
 */
-(void)powerLabelStartPosition {
  CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;

  CGFloat powerStartposition = sliderOutputPower.frame.origin.x + ((sliderOutputPower.value  - sliderOutputPower.minimumValue) * sliderOutputPower.frame.size.width / (sliderOutputPower.maximumValue - sliderOutputPower.minimumValue)) - ((sliderOutputPower.value > 18) ?  (sliderOutputPower.value > 20) ? 70 : 60 :(screenWidth/15.36) ) ;
  sliderValueLabelLeadingConstraint.constant = powerStartposition;
}

/**
 * Each output power changed from the slider - the output power label center X position.
 */
-(void)labelCenterXPositionChanged:(int) sliderValue {
  CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
  if (sliderValue == 10) {
    sliderValueLabelCenterXConstraint.constant = -(screenWidth/3.2);
  }else if (sliderValue == 11) {
    sliderValueLabelCenterXConstraint.constant = -(screenWidth/3.66);
  }else if (sliderValue == 12) {
    sliderValueLabelCenterXConstraint.constant = -(screenWidth/4.27);
  }else if (sliderValue == 13) {
    sliderValueLabelCenterXConstraint.constant = -(screenWidth/4.8);
  }else if (sliderValue == 14) {
    sliderValueLabelCenterXConstraint.constant = -(screenWidth/6.4);
  }else if (sliderValue == 15) {
    sliderValueLabelCenterXConstraint.constant = -(screenWidth/7.68);
  }else if (sliderValue == 16) {
    sliderValueLabelCenterXConstraint.constant = - (screenWidth/9.6);
  }else if (sliderValue == 17) {
    sliderValueLabelCenterXConstraint.constant = -(screenWidth/15.36);
  }else if (sliderValue == 18) {
    sliderValueLabelCenterXConstraint.constant = -(screenWidth/25.6);
  }else if (sliderValue == 19) {
    sliderValueLabelCenterXConstraint.constant = 0;
  }else if (sliderValue == 20) {
    sliderValueLabelCenterXConstraint.constant = (screenWidth/25.6);
  }else if (sliderValue == 21) {
    sliderValueLabelCenterXConstraint.constant = (screenWidth/12.8);
  }else if (sliderValue == 22) {
    sliderValueLabelCenterXConstraint.constant = (screenWidth/8.53);
  }else if (sliderValue == 23) {
    sliderValueLabelCenterXConstraint.constant = (screenWidth/6.98);
  }else if (sliderValue == 24) {
    sliderValueLabelCenterXConstraint.constant = (screenWidth/5.91);
  }else if (sliderValue == 25) {
    sliderValueLabelCenterXConstraint.constant = (screenWidth/4.8);
  }else if (sliderValue == 26) {
    sliderValueLabelCenterXConstraint.constant = (screenWidth/4.04);
  }else if (sliderValue == 27) {
    sliderValueLabelCenterXConstraint.constant = (screenWidth/3.66);
  }else if (sliderValue == 28) {
    sliderValueLabelCenterXConstraint.constant = (screenWidth/3.2);
  }else if (sliderValue == 29) {
    sliderValueLabelCenterXConstraint.constant = (screenWidth/2.95);
  }
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
  EAAccessory * accessory = [_accessoryList objectAtIndex:indexPath.row];
  deviceListCell.lblDeviceName.text = accessory.serialNumber;
  deviceListCell.selectionStyle = UITableViewCellSelectionStyleNone;
  return deviceListCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];

  // The row is the offset into the list of connected accessories
  EAAccessory *chosenAccessory = [_accessoryList objectAtIndex:indexPath.row];

  if ([lblConnectedDeviceName.text isEqualToString:@""]) {
    [appDelegate showLoadingView:@"Connecting..."];
  }
  [_commander connect:chosenAccessory];
}

#pragma mark -- TSLBarcodeCommandTransponderReceivedDelegate methods

/**
 * Each barcode received from the reader is passed to this method
 * Note: This is an asynchronous call from a separate thread
 */
-(void)barcodeReceived:(NSString *)data {
//  if (data.length) {
//    if ([UHFRFIDScannerResponseDelegate respondsToSelector:@selector(UHFRFIDScannerResponseSuccess:withType:)]) {
//      [UHFRFIDScannerResponseDelegate UHFRFIDScannerResponseSuccess:data withType: SCANNED_VALUE];
//    }
//  }
}

/**
 * Use a no-action inventory command to configure the inventory information returned
 */
-(void)configureInventory {
  TSLInventoryCommand *configureInventoryCommand = [TSLInventoryCommand synchronousCommand];
  // Ensure command uses defaults for the non-specified parameters
  configureInventoryCommand.resetParameters = TSL_TriState_YES;
  configureInventoryCommand.takeNoAction = TSL_TriState_YES;
  
  [self configureDefaultInventoryParameters:configureInventoryCommand];
  [self configureUserInventoryParameters:configureInventoryCommand];
  
  if( configureInventoryCommand.isSuccessful ) {
    [_commander executeCommand:configureInventoryCommand];
  } else {
    NSLog(@"!!! Failed to configure the reader inventory command !!!");
  }
}

/**
 * Set the parameters that are not alterable by the user on the given inventory command
 */
-(void)configureDefaultInventoryParameters:(TSLInventoryCommand *)command {
  // Request all available data
  command.includeDateTime = TSL_TriState_YES;
  command.includeEPC = TSL_TriState_YES;
  command.includeIndex = TSL_TriState_YES;
  command.includePC = TSL_TriState_YES;
  command.includeChecksum = TSL_TriState_YES;
  command.includeTransponderRSSI = TSL_TriState_YES;
  
  command.useFastId = TSL_TriState_NO;
}

/**
 * Set the parameters that can be altered by the user on the given inventory command
 */
-(void)configureUserInventoryParameters:(TSLInventoryCommand *)command {
  command.useFastId = TSL_TriState_NO;
  
  // Use the chosen power level
  int value =  [[NSString stringWithFormat:@"%.00f", sliderOutputPower.value] intValue];
  command.outputPower = value;
  AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
  appDelegate.outputPowerValue = value;
}


@end
