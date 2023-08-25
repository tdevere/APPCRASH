/*************************************************
 * InnovaZone
 * ClerkLoginScreen.js
 * Created by Selvin Thamodharan on 14/02/2018
 * Copyright © 2018 InnovaZone. All rights reserved.
 *************************************************/

'use strict';

import React, { Component } from 'react';
import {
  View,
  Dimensions,
  Image,
  Text,
  TouchableHighlight,
  TouchableOpacity,
  TextInput,
  Platform,
  DeviceEventEmitter,
  NativeEventEmitter,
  Alert,
  Keyboard,
  ScrollView,
} from 'react-native';
import PropTypes from 'prop-types';

import {
  SCREEN_TITLE, COLOR, VALIDATION_MSG, SUCCESS_MSG, ALERT, STORAGE, PASSWORD,
  CONFIGURATIONKEY, REACT_TIMEOUT, NETWORK_ERROR, SCANNER, DEVICE_RESPONSE, FONT_SIZE, TOAST_DURATION, FONT_FAMILY, SERVER, KEYS, STATIC_DATA,
} from '../common/Constants';
import { KeyboardAwareScrollView } from 'react-native-keyboard-aware-scroll-view';
import Utility, { getDatabaseCheckAPICall, myLog } from '../utils/Utility';
import screenStyle from './css/ClerkLoginScreenCSS';
import globalStyle from './css/GlobalStyleCSS';
import * as Animatable from 'react-native-animatable';
// import Permissions from 'react-native-permissions';
// import Toast from 'react-native-toast-native';
import Toast from 'react-native-simple-toast';

import CustomSpinner from '../utils/components/Spinner';
import Spinner from 'react-native-spinkit';
import RNLocalNotifications from 'react-native-local-notifications';
import moment from 'moment';
import SegmentedControlTab from 'react-native-segmented-control-tab';
import Events from 'react-native-simple-events';
import _ from 'lodash';
import PreventDoubleClick from '../common/PreventDoubleClick';
import CodePushUpdateView from '../utils/components/CodePushUpdateView';
import {check, PERMISSIONS, RESULTS} from 'react-native-permissions';
import ScanditScannerDataCapture from '../utils/components/ScanditScannerDataCapture';
import CodePush from 'react-native-code-push';


const TouchableOpacityEx = PreventDoubleClick(TouchableOpacity);
const TouchableHighlightEx = PreventDoubleClick(TouchableHighlight);
let deviceWidth = Dimensions.get('window').width;
let deviceHeight = Dimensions.get('window').height;
let validClerkDetails;

let timer;
let isLoginButtonSubmit;
let isSyncButtonTap = false;
let isRFIDModuleOpen = false;

/**
 * Handles Clerk Login functionality
 * Check the clerk id authentication in database 
 * After successful clerk id validation, we are navigating to clerk dashboard.
 */
class ClerkLoginScreen extends Component {

  static propTypes = {
    navigation: PropTypes.object,
  };

  constructor(props) {
    super(props);
    validClerkDetails = {};
    isLoginButtonSubmit = false;

    this.state = {
      isLandscape: false,
      selectedTab: 1,
      visibleHud: false,
      clerkIdInputTxt: '', //Value set for easy login during deveopment. It should be removed on Build Delivery.
      clerkPasswordInputTxt: '',
      isClerkHavePassword: false,
      powerByLogoImageURL: '',
      companyLogoImageURL: '',
      clerkLoginButtonTitle: 'Login',
      segBarcodeTitle: 'Barcode',
      segClerkIdTitle: 'Clerk ID',
      txtLableTitle: 'Clerk ID',
      isBarcodeSegmentHidden: false,
      isClerkIdSegmentHidden: false,
      activityIndicatorVisible: false,
      isRFIDEnabled: false,
      isInfineaLaserEnabled: false,
      isMagneticEnabled: false,
      messageHud: '',
      isInfraredEnabled: false,
      isScreenDataLoaded: true,
      isScanditEnabled: true,
      selectedIndex: 0,
      txtTempScanValue: '',
      isCognexEnabled: false,

      socketScannerDeviceConnectStatus: global.socketScannerDeviceConnectStatus,
      isRescan: false,
      isRFIDAutoReconnect: false,
      infineaDeviceConnectStatus: global.infineaDeviceConnectStatus,
      isCompanyImageError: false,
      isSocketScannerEnabled: false,
    };
  }

  componentDidMount() {
    // this._checkCameraAndPhotos();
    this._checkCameraPermission();

    global.isAutoCRNReset = true;
  }

 


  /**
   * Gets triggered when the view unlods
   * Removes all listeners
   */
  componentWillUnmount() {
    if (Platform.OS === 'ios') {
      //
    } else {
      DeviceEventEmitter.removeAllListeners('infineaLoginScannedText');
      // DeviceEventEmitter.removeAllListeners('rfidLoginScannedText');
    }
    Events.remove('onNetworkonNetworkStatusClerkLogin', 'ClerkLogin');
    window.EventBus.off('onNotificationHideHudLoading');
    Events.trigger('onCognexScannerStopScan', {});
    Events.trigger('onCRNResetScreen', {});

  }



  _checkCameraPermission(){
    console.log('********************* _checkCameraPermission *********************');
    check( (Platform.OS === 'ios') ? PERMISSIONS.IOS.CAMERA : PERMISSIONS.ANDROID.CAMERA)
      .then((result) => {
        console.log('********************* _checkCameraPermission result *********************:', result);
        switch (result) {
          case RESULTS.UNAVAILABLE:
            console.log(
              '********************* This feature is not available (on this device / in this context)',
            );
            break;
          case RESULTS.DENIED:
            console.log(
              '********************* The permission has not been requested / is denied but requestable',
            );
            break;
          case RESULTS.GRANTED:
            console.log('********************* The permission is granted');
            break;
          case RESULTS.BLOCKED:
            console.log('********************* The permission is denied and not requestable anymore');
            break;
        }
      })
      .catch((error) => {
      // …
      });
  }
  


  _alertAppBackgroundMode(deviceName) {
    let message = `The "${deviceName}" accessory would like to open "InnoVaZone"`;
    RNLocalNotifications.createNotification(1, message, moment(new Date()).add(1, 'seconds').format('YYYY-MM-DD HH:mm:ss'), 'default');
  }

  /**
   * This method request permission to access user bluetooth
   */
  _requestPermission() {
    Permissions.request('bluetooth').then((response) => {
      // Returns once the user has chosen to 'allow' or to 'not allow' access
      // Response is one of: 'authorized', 'denied', 'restricted', or 'undetermined'
      this._CheckLocationEnabledClicked();
    }).catch((error) => console.log('Permissions.request : ', error));
  }

  /**
   * This method check permission to access user location
   * If authorized then get state short name
   * Then call speciality category list 
   */
  _CheckLocationEnabledClicked() {
    this.setState({ 'locationLoading': true });
    Permissions.check('bluetooth').then((response) => {
      // Response is one of: 'authorized', 'denied', 'restricted', or 'undetermined'
      this.setState({ bluetoothPermission: response });
      if (response === 'authorized') {
        // set state
      } else {
        this._showPermissionAlert(response);
      }
    }).catch((error) => console.log('Permissions.check : ', error));
  }


  /**
   * Show alert to enable location permission
   */
  _showPermissionAlert(response) {
    Alert.alert(
      ALERT.INFO,
      ALERT.TITLE.BLUETOOTH_TURNED_OFF_MESSAGE,
      [
        {
          text: 'Not Now',
          onPress: () => { },
          style: 'cancel',
        },
        response === 'undetermined'
          ? { text: 'OK', onPress: () => this._requestPermission() }
          : { text: 'Open Settings', onPress: () => Permissions.openSettings() },
      ],
    );
  }




  /**
   *  Check the status of multiple permissions
   */
  _checkCameraAndPhotos = () => {
    Permissions.check('camera').then((response) => {
      //response is an object mapping type to permission
      this.setState({
        cameraPermission: response.camera,
      });
    }).catch((error) => {
    });
  }



  /**
   * Navigates to Reset CRN Screen 
   */
  _navigateToResetCRNScreen() {
    // Get the local upadte is available or not from database 
    CodePush.restartApp();
  }

  /**
   * After successful clerk user name / barcode validation, we are navigating to ClerkDashboard Screen.
   * Set clerk details to AppSession-CURRENTCLERK 
   * @param  {} clerkDetails - Clerk details values in dictionary
   */
  _navigateToClerkDashboardScreen(clerkDetails) {
  }

  /**
   * Method is called when user tapped login button validate the clerk id from data base 
   * Check if clerk contains password in database show the password field
   * After successful clerk login, Navigate to clerk dashboard screen.
   */
  _loginButtonSubmit(clerkID) {
    isLoginButtonSubmit = true;
    const { selectedTab, clerkIdInputTxt } = this.state;
    if (selectedTab == 2) {
      if (clerkIdInputTxt.trim() == '') {
        Utility.showAlert(ALERT.TITLE.INFO, VALIDATION_MSG.NO_CLERK_ID);
        return;
      }
    }
    this._loginAuthenticationWithDatabase(clerkID, selectedTab, 0);
  }

  _loginInfraredAuthenticationWithDatabase(clerkID, selectedTab, isScandit) {
    // Using common login validation method for both clerk login screen and employee login screen
    // isClerk is boolean for identify the user login as clerk login / employee login screen
    let isClerk = true;
  }

  /**
  * Method is called when user tapped login button validate the clerk id from data base 
  * Check if clerk contains password in database show the password field
  * After successful clerk login, Navigate to clerk dashboard screen.
  */
  _loginAuthenticationWithDatabase(clerkID, selectedTab, isScandit) {
    const { isInfraredEnabled } = this.state;
    Keyboard.dismiss();
    alert(clerkID);
    // Using common login validation method for both clerk login screen and employee login screen
    // isClerk is boolean for identify the user login as clerk login / employee login screen
    let isClerk = true;

  }


  /**
   * Method is called when user tapped login button validate the clerk password from data base
   * Navigate to clerk dashboard screen.
   */
  _passwordLoginButtonSubmit() {
    this.setState({ activityIndicatorVisible: true });
    if (this.state.clerkPasswordInputTxt.trim() == '') {
      this.setState({ activityIndicatorVisible: false });
      setTimeout(() => {
        Utility.showAlert(ALERT.TITLE.INFO, VALIDATION_MSG.NO_PASSWORD);
      }, REACT_TIMEOUT.VALIDATION_ALERT);
      return;
    }

  }

  /**
   * Method is called when user tapped back button hide the password text field and show the user id feild
   */
  _passwordBackButtonTapped() {
    this.setState({ isClerkHavePassword: false, clerkPasswordInputTxt: '' });
  }

 

  _rfidButtonTap() {
    isRFIDModuleOpen = true;
  }

  /**
   * Method is called when view size changed due to screen orientation changed.
   */
  onLayout(e) {
    deviceWidth = Dimensions.get('window').width;
    deviceHeight = Dimensions.get('window').height;
    if (deviceWidth > deviceHeight) {
      this.setState({ isLandscape: true });
    } else {
      this.setState({ isLandscape: false });
    }
  }

  /**
   * On change clerk id called based on typing.
   * @param  {} value - Clerk id text
   */
  _onClerkIdValueChanged(value) {
    const { isInfraredEnabled, isMagneticEnabled } = this.state;
    this.setState({ clerkIdInputTxt: value });
    if ((isInfraredEnabled || isMagneticEnabled) && !isLoginButtonSubmit) {
      if (timer) {
        clearTimeout(timer);
      }
      timer = setInterval(() => {
        clearTimeout(timer);
        if (value.length && timer) {
          this._loginInfraredAuthenticationWithDatabase(value, 1, 0);
        }
      }, 1000); // 1000= 1 second , the timer will run every second
    }
  }

  /**
   * Render rfid image view
   */
  _renderRFIDImageView() {
    if (this.state.isRFIDEnabled) {
      return (
        <Image
          resizeMode="contain"
          source={require('../images/Rfidscan.png')}
          style={{ height: 30, width: 50 }}
        />
      );
    }
  }

  /**
   * Render barcode image view
   */
  _renderBarcodeImageView() {
    if (this.state.isInfineaLaserEnabled) {
      return (
        <Image
          resizeMode="contain"
          source={require('../images/BarcodeScanBlack.png')}
          style={{ left: -5, height: 43, width: 50 }}
        />
      );
    }
  }
  _renderMagneticImageView() {
    if (this.state.isMagneticEnabled) {
      return (
        <Image
          resizeMode="contain"
          source={require('../images/ImageMagcardScan.png')}
          style={{ left: -5, height: 43, width: 50 }}
        />
      );
    }
  }

  _renderSocketScanImageView() {
    if (this.state.isSocketScannerEnabled) {
      return (
        <Image
          resizeMode="contain"
          source={require('../images/socketScanner.png')}
          style={{ left: -5, height: 43, width: 50 }}
        />
      );
    }
  }

  handleIndexChange = (index) => {
    if (index == 0) {
      this.setState({
        ...this.state,
        selectedIndex: index,
        selectedTab: 1,
      });
    } else {
      this.setState({
        ...this.state,
        selectedIndex: index,
        selectedTab: 2,
      });
    }

  };


  /**
   * Render screen content with in card view
   */
  _renderBarcodeEmployee() {
    return (
      <View style={{ flex: 1, margin: (this.state.isRFIDEnabled === true || this.state.isInfineaLaserEnabled === true || this.state.isMagneticEnabled === true) ? 0 : 30 }}>
        <View style={{ flexDirection: 'row' }}>
          <View style={{ flex: 1 }} />
          <View style={{ flex: 6, borderWidth: 2, borderColor: COLOR.THEME }}>
            <View style={{ flexDirection: 'row' }}>
              {this._renderSegmentBarcode()}

              <View style={{ width: 2, backgroundColor: COLOR.THEME }} />
              {this._renderSegmentClerkId()}
            </View>
          </View>

          <View style={{ flex: 1 }} />
        </View>

        <View style={{ flex: 1, marginTop: 20 }}>
          {this._renderScannerOrManual()}
        </View>
      </View>
    );
  }


  /**
   * Render screen except header bar
   */
  _renderScreen() {
    return (
      <View style={screenStyle.cardContainer}>
        <View style={{ alignItems: 'center', justifyContent: 'center', flexDirection: 'row', marginVertical: 3 }}>
          {this._renderRFIDImageView()}
          {this._renderBarcodeImageView()}
          {this._renderMagneticImageView()}
          {this._renderSocketScanImageView()}
        </View>
        <View style={{
          height: (this.state.isLandscape) ? deviceHeight * (3 / 5) : deviceHeight / 2,
          width: (this.state.isLandscape) ? deviceWidth * (3 / 5) : deviceWidth * (4 / 5),
        }}
        >
          {
            !this.state.isBarcodeSegmentHidden &&
              !this.state.isClerkIdSegmentHidden ?
              this._renderScreenContent() : this._renderBarcodeEmployee()
          }

        </View>
      </View>
    );
  }

  /**
   * Render the segment title view
   * If EmployeeID feature is not Enables then Hide this Section from the Segment Control
   */
  _renderSegmentClerkId() {
    if (!this.state.isClerkIdSegmentHidden) {
      return (
        <TouchableHighlight style={{ flex: 1 }}
          underlayColor={'transparent'}
          onPress={() => {
            this.setState({ selectedTab: 2 });
          }}
        >
          <Text style={[screenStyle.segmentText, {
            color: (this.state.selectedTab === 1) ? COLOR.THEME : 'white',
            backgroundColor: (this.state.selectedTab === 1) ? 'white' : COLOR.THEME,
          }]}
          >
            {this.state.segClerkIdTitle}
          </Text>
        </TouchableHighlight>
      );
    } else {
      return (
        <View />
      );
    }
  }

  /**
   * Render the segment title view
   * If Barcode feature is not Enables then Hide this Section from the Segment Control
   */
  _renderSegmentBarcode() {
    if (!this.state.isBarcodeSegmentHidden) {
      return (
        <TouchableHighlight style={{ flex: 1 }}
          underlayColor={'transparent'}
          onPress={() => {
            this.setState({ selectedTab: 1 });
          }}
        >
          <Text style={[screenStyle.segmentText, {
            color: (this.state.selectedTab === 1) ? 'white' : COLOR.THEME,
            backgroundColor: (this.state.selectedTab === 1) ? COLOR.THEME : 'white',
          }]}
          >
            {this.state.segBarcodeTitle}
          </Text>
        </TouchableHighlight>
      );
    } else {
      return (
        <View />
      );
    }
  }

  /**
   * Render screen content with in card view
   */
  _renderScreenContent() {
    return (
      <View style={{ flex: 1, margin: (this.state.isRFIDEnabled === true || this.state.isInfineaLaserEnabled === true || this.state.isMagneticEnabled === true) ? 0 : 30, alignItems: 'center' }}>
        <View style={{ flexDirection: 'row' }}>
          <View style={{ flex: 1 }}>
            <SegmentedControlTab
              values={[this.state.segBarcodeTitle, this.state.segClerkIdTitle]}
              activeTabStyle={{ backgroundColor: 'white', shadowColor: 'gray', borderRadius: 10 }}
              activeTabTextStyle={{ color: '#000000' }}
              tabTextStyle={{ fontSize: 22, color: 'black', fontFamily: FONT_FAMILY.HELVETICA_CONDENSEDBOLD }}
              selectedIndex={this.state.selectedIndex}
              onTabPress={this.handleIndexChange}
              tabStyle={{ backgroundColor: '#F1F4F9', height: 50, borderColor: '#F1F4F6', borderWidth: 3 }}
            />
          </View>
        </View>

        <View style={{ flex: 1, marginTop: 20, width:(Platform.OS === 'ios') ? 550 : 400 }}>
          {this._renderScannerOrManual()}
        </View>
      </View>
    );
  }

  _renderScanner() {
    const { isScanditEnabled, isCognexEnabled, selectedTab} = this.state;

    if(isScanditEnabled) {
      return(
        <ScanditScannerDataCapture
          onBarCodeRead={(data) => {
            this._loginAuthenticationWithDatabase(data, 1, 1);    
          }}
        />
      );
    }else if(isCognexEnabled) {
      if(this.state.visibleHud) {
        return(
          <View style ={{flex: 1, backgroundColor:'#000'}}/>
        );
      }else {
        null;
      }
    } else {
      null;
    }
  }

  /**
   * Render scanner or manual entry option based on selected tab option
   */
  _renderScannerOrManual() {
    const {isClerkHavePassword, selectedIndex, isBarcodeSegmentHidden } = this.state;
    if (!isBarcodeSegmentHidden && selectedIndex == 0) {
      return (
        <View style={{ flex: 1 }}>
          {this._renderScanner()}
        </View>
      );
    } else {
      if (isClerkHavePassword) {
        return (
          <View style={{ flex: 1, flexDirection: 'row' }}>
            <View style={{ flex: 1 }} />

            <View style={{ flex: 6, justifyContent: 'center' }}>
              <Animatable.View animation="fadeInRight"
                duration={200}
                delay={100}
              >
                <Text style={screenStyle.crnNoTxt}>
                  Password :
                </Text>
                <TextInput
                  style={[screenStyle.textInputStyle]}
                  returnKeyType={'done'}
                  autoCapitalize="none"
                  autoCorrect= {true}
                  onChangeText={(clerkPasswordInputTxt) => this.setState({ clerkPasswordInputTxt })}
                  value={this.state.clerkPasswordInputTxt}
                  autoFocus={true}
                  secureTextEntry={true}
                />

                <View style={{ flexDirection: 'row', justifyContent: 'center' }}>
                  <TouchableOpacityEx style={[screenStyle.button, { flex: 1, marginRight: 10 }]}
                    underlayColor="transparent"
                    onPress={() => this._passwordBackButtonTapped()}
                  >
                    <Text style={screenStyle.buttonText}>
                      Back
                    </Text>
                  </TouchableOpacityEx>
                  <TouchableOpacityEx style={[screenStyle.button, { flex: 1, marginLeft: 10 }]}
                    underlayColor="transparent"
                    onPress={() => this._passwordLoginButtonSubmit()}
                  >
                    <Text style={screenStyle.buttonText}>
                      Login
                    </Text>
                  </TouchableOpacityEx>
                </View>
              </Animatable.View>
            </View>

            <View style={{ flex: 1 }} />
          </View>
        );
      } else {
        return (
          <View style={{ flex: 1, flexDirection: 'row' }}>
            <View style={{ flex: 1 }} />

            <View style={{ flex: (Platform.OS === 'ios') ? 10 : 15, justifyContent: 'center' }}>
              <Text style={[screenStyle.crnNoTxt, { fontSize: (Platform.OS === 'ios') ? deviceHeight / 40.96 : 24 }]}>
                {this.state.txtLableTitle}
              </Text>
              <TextInput
                ref="clerkIdInput"
                style={[screenStyle.textInputStyle]}
                returnKeyType={'done'}
                autoCapitalize="none"
                autoCorrect= {true}
                onChangeText={(value) => { this._onClerkIdValueChanged(value); }}
                value={this.state.clerkIdInputTxt}
                autoFocus={true}
              />

              <TouchableHighlightEx style={screenStyle.button}
                underlayColor="transparent"
                onPress={() => this._loginButtonSubmit(this.state.clerkIdInputTxt)}
              >
                <Text style={screenStyle.buttonText}>
                  {this.state.clerkLoginButtonTitle}
                </Text>
              </TouchableHighlightEx>
            </View>

            <View style={{ flex: 1 }} />
          </View>
        );
      }

    }
  }

  _renderRFIDButtonView() {
    if (this.state.isRFIDEnabled) {
      return (
        <TouchableHighlight
          underlayColor={'transparent'}
          onPress={() => {
            this._rfidButtonTap();
          }}
        >
          <Image
            resizeMode="contain"
            tintColor={'white'}
            source={require('../images/RFIDWhitesetting.png')}
            style={{ height: 40, width: 40, marginRight: 25 }}
          />
        </TouchableHighlight>
      );
    }
  }

  /**
   * Renders Parent view
   */
  render() {
    const { isScreenDataLoaded, infineaDeviceConnectStatus, isCognexEnabled, socketScannerDeviceConnectStatus } = this.state;

    let backgroundImg = require('../images/LaunchImagePortrait.png');
    if (this.state.isLandscape) {
      backgroundImg = require('../images/LaunchImageLandscape.png');
    } else {
      backgroundImg = require('../images/LaunchImagePortrait.png');
    }
  

    return (
      <View style={globalStyle.container}
        onLayout={this.onLayout.bind(this)}
      >
        <Image source={backgroundImg} resizeMode="cover" style={{ height: deviceHeight, width: deviceWidth }} />
        <View style={[globalStyle.container, { position: 'absolute', top: 0, bottom: 0, left: 0, right: 0, alignItems: 'center' }]}>
          {
            //toolbar starts
          }
          <View style={globalStyle.toolbar}>

            <View style={[globalStyle.toolbarLeftView, { height: 40, flex: 3, alignItems: 'center', justifyContent: 'center' }]}>
              <Text style={{ color: COLOR.DEVICE_CONNECTED_STATUS, fontFamily: 'HelveticaNeue-CondensedBold', fontWeight: 'bold', fontSize: FONT_SIZE.SCREEN_NAVIGATION_CONTENT }}>
                {((infineaDeviceConnectStatus === '' || infineaDeviceConnectStatus === undefined) ? socketScannerDeviceConnectStatus : infineaDeviceConnectStatus)}
              </Text>
            </View>
            {/* <View style={globalStyle.toolbarLeftView} /> */}

            <Text style={[globalStyle.toolbarTitleText, { left: (this.state.isRFIDEnabled) ? 30 : 0, flex: 3, textAlign: 'left' }]}>
              {SCREEN_TITLE.LOGIN}
            </Text>

            {this._renderRFIDButtonView()}

       

            <TouchableHighlight
              underlayColor={'transparent'}
              onPress={() => this._navigateToResetCRNScreen()}
            >
              <Image
                resizeMode="contain"
                source={require('../images/Logout.png')}
                style={{ height: 40, width: 40, marginRight: 20 }}
              />
            </TouchableHighlight>
          </View>
          {
            //toolbar ends
          }

          {
            (isScreenDataLoaded) ?
              <KeyboardAwareScrollView
                keyboardShouldPersistTaps={'always'}
                extraHeight={70}
                enableOnAndroid={true}
                onKeyboardWillShow={(frames) => { }}
              >
                {
                  (_.includes(this.state.companyLogoImageURL, 'require(\'../images/TopLogo.png\')') || (this.state.companyLogoImageURL === ''))?

                    <View style={{ justifyContent: 'center', alignItems: 'center' }}>
                      <Image
                        style={{ height: (this.state.isLandscape) ? deviceHeight / 7 : deviceHeight / 8, width: deviceHeight / 2, marginVertical: (this.state.isLandscape) ? deviceHeight / 100 : deviceHeight / 26 }} 
                        resizeMode="contain" 
                        // onError={(e) => {this.setState({isCompanyImageError : true});}}
                        // onLoadEnd={(e) => {this.setState({isCompanyImageError : false});}}             
                        source={require('../images/TopLogo.png')}
                      />
                    </View>
                    :
                    <View style={{ justifyContent: 'center', alignItems: 'center' }}>
                      <Image
                        style={{ height: (this.state.isLandscape) ? deviceHeight / 7 : deviceHeight / 8, width: deviceHeight / 2, marginVertical: (this.state.isLandscape) ? deviceHeight / 100 : deviceHeight / 26 }} 
                        resizeMode="contain"              
                        // onError={(e) => {this.setState({isCompanyImageError : true});}}
                        // onLoadEnd={(e) => {this.setState({isCompanyImageError : false});}}
                        source={{ uri: this.state.companyLogoImageURL }}
                      />
                    </View>
                }
               

                {this._renderScreen()}

              </KeyboardAwareScrollView>
              :
              <View style={{ flex: 5, justifyContent: 'center', alignItems: 'center' }}>
                <Spinner
                  isVisible={true}
                  size={deviceWidth * 0.05}
                  type={'FadingCircleAlt'}
                  color={COLOR.BLACK}
                />
              </View>
          }


          <View style={[globalStyle.bottomPowerByLogoMainContainer, { flexDirection: 'row', alignItems: 'center', justifyContent: 'center', flex: 1 }]}>

            
          </View>

          <View style ={[globalStyle.bottomPowerByLogoMainContainer,  {position: 'absolute', flex:1,  flexDirection : 'row'}]}>
            <View style={{flex:1}} />
        
          </View>

        </View>

        <CustomSpinner
          ref="mHudLoader"
          visible={this.state.activityIndicatorVisible}
          message={''}
          backgroundColor={'transparent'}
          color={COLOR.BLACK}
        />

        <CustomSpinner
          ref="mHudLoader"
          visible={this.state.visibleHud}
          message={this.state.messageHud}
          // customStyle={{bottom: (isCognexEnabled) ? deviceHeight/4.5 : 0}}
        />

        
        <CodePushUpdateView/>
      </View>
    );
  }
}

const toastStyle = {
  backgroundColor: '#000000',
  color: '#ffffff',
  height: deviceHeight/11.38,
  width: deviceWidth/3.4,
  borderRadius: 15,
};

const deviceMessageStyle = {
  backgroundColor: '#000000',
  color: '#ffffff',
  width: 400,
  height : 70,
  borderRadius: 15,
  fontSize : 20,
  fontFamily : FONT_FAMILY.HELVETICA_CONDENSEDBOLD,
};

export default ClerkLoginScreen;
