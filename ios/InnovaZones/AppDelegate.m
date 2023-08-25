/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "AppDelegate.h"
#import <AppCenterReactNative.h>
#import <AppCenterReactNativeAnalytics.h>
#import <AppCenterReactNativeCrashes.h>
#import <CodePush/CodePush.h>

#import "Constants.h"
#import "UIColorMake.h"
#import <React/RCTBundleURLProvider.h>
#import <React/RCTRootView.h>
#import <React/RCTLinkingManager.h>
#import <QuantumSDK/QuantumSDK.h>
#import <TSLAsciiCommands/TSLAsciiCommands.h>
#import "MBProgressHUD.h"
#import <RNCPushNotificationIOS.h>
#import <UserNotifications/UserNotifications.h>

#import <React/RCTBridge.h>
#import <React/RCTBundleURLProvider.h>
#import <React/RCTRootView.h>


#ifdef FB_SONARKIT_ENABLED
#import <FlipperKit/FlipperClient.h>
#import <FlipperKitLayoutPlugin/FlipperKitLayoutPlugin.h>
#import <FlipperKitUserDefaultsPlugin/FKUserDefaultsPlugin.h>
#import <FlipperKitNetworkPlugin/FlipperKitNetworkPlugin.h>
#import <SKIOSNetworkPlugin/SKIOSNetworkAdapter.h>
#import <FlipperKitReactPlugin/FlipperKitReactPlugin.h>
static void InitializeFlipper(UIApplication *application) {
  FlipperClient *client = [FlipperClient sharedClient];
  SKDescriptorMapper *layoutDescriptorMapper = [[SKDescriptorMapper alloc] initWithDefaults];
  [client addPlugin:[[FlipperKitLayoutPlugin alloc] initWithRootNode:application withDescriptorMapper:layoutDescriptorMapper]];
  [client addPlugin:[[FKUserDefaultsPlugin alloc] initWithSuiteName:nil]];
  [client addPlugin:[FlipperKitReactPlugin new]];
  [client addPlugin:[[FlipperKitNetworkPlugin alloc] initWithNetworkAdapter:[SKIOSNetworkAdapter new]]];
  [client start];
}
#endif


@interface AppDelegate (){
  MBProgressHUD *hud;
}

@end

@implementation AppDelegate
@synthesize dicConnectedRFIDDeviceInfo, isRFIDDataTriggered, strBluetoothStatus, isRFIDFirstTimeSearchCompleted, loadingView, outputPowerValue, centralManager;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  #ifdef FB_SONARKIT_ENABLED
    InitializeFlipper(application);
  #endif
//
//  NSURL *jsCodeLocation;
//
//  #ifdef DEBUG
//
//    jsCodeLocation = [[RCTBundleURLProvider sharedSettings] jsBundleURLForBundleRoot:@"index" fallbackResource:nil];
//  #else
//    jsCodeLocation = [CodePush bundleURL];
//  #endif

  if (@available(iOS 14.0, *)) {
     UIDatePicker *picker = [UIDatePicker appearance];
     picker.preferredDatePickerStyle = UIDatePickerStyleWheels;
   }
  
  if (@available(iOS 14.2, *)) {
    UIDatePicker *picker = [UIDatePicker appearance];
    picker.preferredDatePickerStyle = UIDatePickerStyleWheels;
  }

  if (@available(iOS 14.3, *)) {
    UIDatePicker *picker = [UIDatePicker appearance];
    picker.preferredDatePickerStyle = UIDatePickerStyleWheels;
  }
  
  if (@available(iOS 14.4, *)) {
    UIDatePicker *picker = [UIDatePicker appearance];
    picker.preferredDatePickerStyle = UIDatePickerStyleWheels;
  }
  
  if (@available(iOS 14.5, *)) {
    UIDatePicker *picker = [UIDatePicker appearance];
    picker.preferredDatePickerStyle = UIDatePickerStyleWheels;
  }
  
  if (@available(iOS 14.6, *)) {
    UIDatePicker *picker = [UIDatePicker appearance];
    picker.preferredDatePickerStyle = UIDatePickerStyleWheels;
  }
  
  NSString *strBundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
  NSError *error = nil;

  if ([strBundleIdentifier isEqualToString: QA_BUNDLE_ID]){
    [[IPCIQ registerIPCIQ] setDeveloperKey:@"ax6mv94mjITNedVALUGbuWPbSbUT1+jh87fRq2t3YQ52CyA26iduwCqJW8qMMpqcA31xIO8SoNOnWwoWTTIcLS324PhS/XAr6J0Xd3rSuUw=" withError:&error];
  }else if ([strBundleIdentifier isEqualToString:PROD_BUNDLE_ID]){
    [[IPCIQ registerIPCIQ] setDeveloperKey:@"ax6mv94mjITNedVALUGbuWPbSbUT1+jh87fRq2t3YQ7tfMEeqbOr05es/4WHshHSbnbjd5Y/Q3D1VSJRK0SOfucHo8F4MXgplAmQzw3n2iI=" withError:&error];
  }
  
  [TSLLibraryConfiguration sharedInstance].useUTF8 = YES;
  // Create the TSLAsciiCommander used to communicate with the TSL Reader
  // Create the commander
  _commander = [[TSLAsciiCommander alloc] init];
  outputPowerValue = 0;
  
#ifdef DEBUG
  // Log all Reader responses when debugging
  [_commander addResponder:[[TSLLoggerResponder alloc] init]];
#endif
  
  // Some synchronous commands will be used in the app
  [_commander addSynchronousResponder];
  
  [AppCenterReactNativeCrashes registerWithAutomaticProcessing];  // Initialize AppCenter crashes
  [AppCenterReactNativeAnalytics registerWithInitiallyEnabled:true];  // Initialize AppCenter analytics
  [AppCenterReactNative register];  // Initialize AppCenter

   centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
  
  if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]) {
    [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeSound categories:nil]];
  }
  
  NSUserDefaults * standardUserDefaults = [NSUserDefaults standardUserDefaults];
  NSString * server_preference = [standardUserDefaults objectForKey:@"server_preference"];
  if (!server_preference) {
    [self registerDefaultsFromSettingsBundle];
  }
  
  // Define UNUserNotificationCenter
  UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
  center.delegate = self;

  
  RCTBridge *bridge = [[RCTBridge alloc] initWithDelegate:self launchOptions:launchOptions];
   RCTRootView *rootView = [[RCTRootView alloc] initWithBridge:bridge
                                                    moduleName:@"InnovaZones"
                                             initialProperties:nil];
  
  self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
  UIViewController *rootViewController = [UIViewController new];
  rootViewController.view = rootView;
  self.window.rootViewController = rootViewController;
  [self.window makeKeyAndVisible];
  return YES;
}

- (NSURL *)sourceURLForBridge:(RCTBridge *)bridge
{
#if DEBUG
  return [[RCTBundleURLProvider sharedSettings] jsBundleURLForBundleRoot:@"index" fallbackResource:nil];
#else
  return [CodePush bundleURL];
#endif
}


- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
   if ([central state] == CBCentralManagerStatePoweredOff) {
     strBluetoothStatus = @"Powered off";
   }else if ([central state] == CBCentralManagerStatePoweredOn) {
     NSLog(@"Bluetooth on");
     strBluetoothStatus = @"Powered on";
   }
}


- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
            options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options
{
  return [RCTLinkingManager application:application openURL:url options:options];
}

#pragma NSUserDefaults
- (void)registerDefaultsFromSettingsBundle {
  // this function writes default settings as settings
  NSString *settingsBundle = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"bundle"];
  if(!settingsBundle) {
    NSLog(@"Could not find Settings.bundle");
    return;
  }
  
  NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:[settingsBundle stringByAppendingPathComponent:@"Root.plist"]];
  NSArray *preferences = [settings objectForKey:@"PreferenceSpecifiers"];
  
  NSMutableDictionary *defaultsToRegister = [[NSMutableDictionary alloc] initWithCapacity:[preferences count]];
  for(NSDictionary *prefSpecification in preferences) {
    NSString *key = [prefSpecification objectForKey:@"Key"];
    if(key) {
      [defaultsToRegister setObject:[prefSpecification objectForKey:@"DefaultValue"] forKey:key];
      NSLog(@"writing as default %@ to the key %@",[prefSpecification objectForKey:@"DefaultValue"],key);
    }
  }
  [[NSUserDefaults standardUserDefaults] registerDefaults:defaultsToRegister];
}

/**
 * Start loading view with animating.
 */
-(void)showLoadingView:(NSString *)strMessage {
  //NSLog(@"show loading view called");
  if (loadingView == nil)
  {
    loadingView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f,[UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height)];
    loadingView.opaque = NO;
    loadingView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3f];
    
    UILabel *lblTemp = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 300, 30.0f)];
    lblTemp.text = strMessage;
    [lblTemp setFont:[UIFont systemFontOfSize:15.0]];
    [lblTemp sizeToFit];
    lblTemp.textColor= [UIColor clearColor];
    [self.window addSubview:lblTemp];
    
    float tempWidth = lblTemp.frame.size.width;
    if(strMessage.length == 0){
      tempWidth = 80.0f;
    }
    [lblTemp removeFromSuperview];
    
    UIView *subloadview=[[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, tempWidth + 20, 100.0f)];
    subloadview.center = loadingView.center;
    subloadview.backgroundColor =  [UIColorMake ColorFromString: @"333333"];
    subloadview.layer.cornerRadius = 10.0;
    subloadview.alpha=1.0;
    subloadview.layer.masksToBounds = YES;
    
    if (strMessage.length == 0) {
      UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(tempWidth/2.0f -7.0f, 30.0f, 35.0f, 35.0f)];
      [activity startAnimating];
      activity.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
      [subloadview addSubview:activity];
    }else {
      UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(tempWidth/2.0f -7.0f, 20.0f, 35.0f, 35.0f)];
      [activity startAnimating];
      activity.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
      [subloadview addSubview:activity];
      
      UILabel *lblMessage = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 60, tempWidth, 25.0f)];
      lblMessage.text = strMessage;
      lblMessage.textColor = [UIColorMake ColorFromString: @"F3F3F3"];
      [lblMessage setFont:[UIFont systemFontOfSize:15.0]];
      [subloadview addSubview:lblMessage];
    }
    
    [loadingView addSubview:subloadview];
  }
  [self.window addSubview:loadingView];
}

/**
 * This function will hide loading view
 */
-(void) hideLoadingView {
  if (loadingView) {
    [loadingView removeFromSuperview];
    loadingView = nil;
  }
}

-(void)showToastMessage:(NSString *)strMessage{
  UIWindow *window = [[[UIApplication sharedApplication] windows] lastObject];
  hud = [MBProgressHUD showHUDAddedTo:window animated:YES];
  hud.mode = MBProgressHUDModeText;
  hud.label.text = strMessage;
  hud.label.textColor = [UIColor whiteColor];
  hud.label.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
//  hud.label.font = [UIFont systemFontOfSize:17];
  hud.label.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:20];
  hud.label.numberOfLines = 0;
  hud.label.lineBreakMode = NSLineBreakByWordWrapping;
  hud.removeFromSuperViewOnHide = YES;
  hud.bezelView.backgroundColor = [UIColorMake ColorFromString:(BLACK_COLOR)];
  [hud hideAnimated:YES afterDelay:1.7];
}

- (void)applicationWillResignActive:(UIApplication *)application {
  // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
  // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
  if( _commander.isConnected ) {
    // Stop any synchronous commands and tell the reader to abort
    // This is to leave the reader in the best possible state for other Apps
    @try
    {
//      [_commander abortSynchronousCommand];
//      [_commander executeCommand:[TSLAbortCommand synchronousCommand]];
//      [_commander disconnect];
    }
    @catch (NSException *exception)
    {
      NSLog( @"Unable to disconnect when resigningActive: %@", exception.reason);
    }
  }
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
  // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
  // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
  // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
  // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  
  // Attempt to reconnect to the last used accessory
  if( !_commander.isConnected ) {
    [_commander connect:nil];
  }
  [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0]; //Allways reset number of notifications shown at the icon
  for (UILocalNotification * notification in [[UIApplication sharedApplication] scheduledLocalNotifications]) { //Also remove all shown notifications
    if ([notification.fireDate compare:[NSDate date]] == NSOrderedAscending) {
      [[UIApplication sharedApplication] cancelLocalNotification:notification];
    }
  }
}

- (void)applicationWillTerminate:(UIApplication *)application {
  // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
  
  // Dispose of the commander
  [_commander halt];
  _commander = nil;
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application{
//  [self showToastMessage:@"Innovazone App - Memory Warning"];
}

// Required to register for notifications
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
  [RNCPushNotificationIOS didRegisterUserNotificationSettings:notificationSettings];
}

// Required for the register event.
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
  [RNCPushNotificationIOS didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
}
// Required for the notification event. You must call the completion handler after handling the remote notification.
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
  [RNCPushNotificationIOS didReceiveRemoteNotification:userInfo fetchCompletionHandler:completionHandler];
}
// Required for the registrationError event.
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
  [RNCPushNotificationIOS didFailToRegisterForRemoteNotificationsWithError:error];
  
  
}
// Required for the localNotification event.
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
  [RNCPushNotificationIOS didReceiveLocalNotification:notification];
}


// Required for localNotification event
-(void)userNotificationCenter:(UNUserNotificationCenter *)center
      willPresentNotification:(UNNotification *)notification
        withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler
{
  NSLog(@"🟢 Notification received in foreground!");
  completionHandler(UNNotificationPresentationOptionSound | UNNotificationPresentationOptionBadge);
  NSDictionary *userInfo = notification.request.content.userInfo;
  [RNCPushNotificationIOS didReceiveRemoteNotification:userInfo fetchCompletionHandler:^void (UIBackgroundFetchResult result){}];
  completionHandler(UNNotificationPresentationOptionNone);
}


//Called when a notification is delivered to a foreground app.
//-(void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler
//{
//  completionHandler(UNNotificationPresentationOptionSound | UNNotificationPresentationOptionAlert | UNNotificationPresentationOptionBadge);
//}



@end
