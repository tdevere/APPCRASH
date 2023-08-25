//
//  Constants.h
//  CareConnect
//
//  Created by <ios_team> on 13/08/15.
//  Copyright © 2016 ConcertCare. All rights reserved.
//
#import <Foundation/Foundation.h>

#define APPLICATION_TITLE                                   @""

#define QA_BUNDLE_ID                                        @"com.InnovaZones.RNTreeQAIZHips"
#define PROD_BUNDLE_ID                                      @"com.InnovaZones.RNTreeIZHips"

#define TIMEOUT_INTERVAL                                    160.0
#define KEYBOARD_OFFSET                                     300

#define RED_NAVIGATION                                      @"5ec3e3"
#define GRAY_TOAST_MESSAGE_COLOR                            @"CCCCCC"
#define BLACK_COLOR                                         @"000000"
#define WHITE_GRAY_LIGHTER                                  @"F6F6F6"

#define LEFT_MARGIN                                         10.0f
#define RIGHT_MARGIN                                        10.0f
#define KEYBOARD_OFFSET                                     300
#define IPAD_FONT_SIZE                                      18.0f
#define IPHONE_FONT_SIZE                                    14.0f

#define SCAN_TYPE_SINGLE                                    0
#define SCAN_TYPE_MULTIPLE                                  1

#define INFINEA_DEVICE_QA_DEVELOPER_KEY                     @"ax6mv94mjITNedVALUGbuWPbSbUT1+jh87fRq2t3YQ7tfMEeqbOr05es/4WHshHSbnbjd5Y/Q3D1VSJRK0SOfucHo8F4MXgplAmQzw3n2iI=",
#define INFINEA_DEVICE_PROD_DEVELOPER_KEY                   @"ax6mv94mjITNedVALUGbuWPbSbUT1+jh87fRq2t3YQ7tfMEeqbOr05es/4WHshHSbnbjd5Y/Q3D1VSJRK0SOfucHo8F4MXgplAmQzw3n2iI=",


#define SOCKET_SCANNER_QA_DEVELOPER_ID                      @"5ea16148-b842-ea11-a812-000d3a378f47"
#define SOCKET_SCANNER_QA_APP_KEY                           @"MC0CFHwc6KbV+2KhvrTg1F0LNxs539pkAhUAkavPmxWCRIaojMc/e4nAqXtesL8="
#define SOCKET_SCANNER_PROD_DEVELOPER_ID                    @"5ea16148-b842-ea11-a812-000d3a378f47"
#define SOCKET_SCANNER_PROD_APP_KEY                         @"MCwCFGC9pdNd74R57skae55ExxOwmuJrAhRzAusJqpAy4/VFOx/hIuzKpYELGw=="

#define SCAN_TYPE_PRODUCT                                   @"PRODUCT"
#define SCAN_TYPE_CART                                      @"CART"
#define SCAN_TYPE_ENROLL                                    @"ENROLL"
#define SCAN_TYPE_LOGIN                                     @"LOGIN"
#define SCAN_TYPE_ASSET_NO                                  @"ASSET_NO"
#define SCAN_TYPE_REPORT_ASSET_NO                           @"REPORT_ASSET_NO"
#define SCAN_TYPE_UNIFORM_EMPLOYEE_ID                       @"UNIFORM_EMPLOYEE_ID"
#define SCAN_TYPE_UNIFROM_ASSET_NO                          @"UNIFORM_ASSET_NO"
#define SCAN_TYPE_STATION_ASSET_NO                          @"STATION_ASSET_NO"

#define SCANNED_VALUE                                       @"SCANNED_VALUE"
#define DEVICE_CONNECTED_STATUS                             @"DEVICE_CONNECTED_STATUS"
#define DEVICE_BATTERY_STATUS                               @"DEVICE_BATTERY_STATUS"
#define BUTTON_OK                                           @"OK"
#define BUTTON_YES                                          @"YES"
#define BUTTON_CANCEL                                       @"Cancel"
#define BLUETOOTH_TURNED_OFF_MESSAGE                        @"Bluetooth is turned off. Turn it on to find and connect devices"
#define BLUETOOTH_NOT_SUPPORTED_MESSAGE                     @"Bluetooth is not supported in your device"
#define BLUETOOTH_NOT_AUTHORIZED_MESSAGE                    @"The app is not authorized to use Bluetooth Low Energy."
#define CONNECTED                                           @"CONNECTED"

// To check the iPad/ iPhone and iPhone modals
#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_RETINA ([[UIScreen mainScreen] scale] >= 2.0)

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define SCREEN_MAX_LENGTH (MAX(SCREEN_WIDTH, SCREEN_HEIGHT))
#define SCREEN_MIN_LENGTH (MIN(SCREEN_WIDTH, SCREEN_HEIGHT))

#define IS_IPHONE_4_OR_LESS (IS_IPHONE && SCREEN_MAX_LENGTH < 568.0)
#define IS_IPHONE_5 (IS_IPHONE && SCREEN_MAX_LENGTH == 568.0)
#define IS_IPHONE_6 (IS_IPHONE && SCREEN_MAX_LENGTH == 667.0)
#define IS_IPHONE_6P (IS_IPHONE && SCREEN_MAX_LENGTH == 736.0)
#define IS_IPHONE_X  (IS_IPHONE && SCREEN_MAX_LENGTH == 812.0)
#define IS_IPHONE_XR  (IS_IPHONE && SCREEN_MAX_LENGTH == 896.0)

