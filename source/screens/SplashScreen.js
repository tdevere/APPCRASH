/*************************************************
 * InnovaZone
 * SplashScreen.js
 * Created by Selvin Thamodharan on 13/02/2018
 * Copyright © 2018 InnovaZone. All rights reserved.
 *************************************************/

'use strict';

import React, { Component } from 'react';
import {
  View,
  Dimensions,
  Image,
  ActivityIndicator,
  AppState,
  Alert,
  Platform,
  // NetInfo,
  StyleSheet,
  TouchableOpacity,
  Text,
  // NativeEventEmitter,
  Linking,
} from 'react-native';
import PropTypes from 'prop-types';
import NetInfo from '@react-native-community/netinfo';
import { COLOR, ALERT, SUCCESS_MSG, REACT_TIMEOUT, NETWORK_ERROR, CODE_PUSH, FONT_FAMILY, SERVER, CONFIGURATIONKEY
  ,DATE_FORMAT, LENGTH, STORE_LINK  } from '../common/Constants';
import { NavigationActions } from 'react-navigation';
import screenStyle from './css/SplashScreenCSS';
import { setEnabled, checkForCodePushNewUpdate } from '../common/AppCenterAnalytics';
import codePush from 'react-native-code-push';

let deviceWidth = Dimensions.get('window').width;
let deviceHeight = Dimensions.get('window').height;
let isAlertTriggered = false;
// const CustomSettingsEventEmitter = new NativeEventEmitter(CustomSettingsModule);

class SplashScreen extends Component {

  static propTypes = {
    navigation: PropTypes.object,
  };

  constructor(props) {
    // global.applicationLogs = []; // Required for the logs show in the App screen itself
    super(props);
    this.state = {
      isLandscape: false,
      isLoading: true,
      updateMessage: '',
    };
  }

  componentDidMount() {
    console.disableYellowBox = true; // for disable the warning yellow box

    checkForCodePushNewUpdate();

  
    setEnabled(true);
    this._checkCodePush();
    
  }

  componentWillUnmount () {
    const unsubscribe = NetInfo.addEventListener((state) => {
      console.log('Connection type', state.type);
      console.log('Is connected?', state.isConnected);
    });
    this.setState = (state,callback)=>{
      return;
    };
  }

  _checkCodePush() {
    let deploymentKey = '';

    if (Platform.OS === 'ios') {
      deploymentKey = CODE_PUSH.IOS.DEVELOPMENT;
    } else {
      deploymentKey = CODE_PUSH.ANDROID.DEVELOPMENT;
    }
    codePush.sync({
      deploymentKey,
      // checkFrequency: codePush.CheckFrequency.ON_APP_RESUME,

      /**
      * Active update, which lets the end user know
      * about each update, and displays it to them
      * immediately after downloading it
      */
      installMode: codePush.InstallMode.IMMEDIATE,
      // minimumBackgroundDuration: 5,
      // updateDialog: true,
      updateDialog: {
        appendReleaseDescription: true,
        title: 'InnovaZone',
        descriptionPrefix: '\n\n Release Notes:',
        optionalUpdateMessage: '\n An update is available. Would you like to install it?',
      },
      isFirstRun: true,
      /**
      * Download the update silently, and install optional updates
      * on the next restart, but install mandatory updates on the next resume.
      */ 
      // installMode: codePush.InstallMode.ON_NEXT_RESUME,

      // installMode: codePush.InstallMode.ON_NEXT_SUSPEND,

      // installMode: codePush.InstallMode.ON_NEXT_RESTART,
    },
    (status) => {
      switch (status) {
        case codePush.SyncStatus.CHECKING_FOR_UPDATE:
          this.setState({updateMessage: 'Checking for updates...'});
          break;
        case codePush.SyncStatus.DOWNLOADING_PACKAGE:
          this.setState({ updateMessage: 'Downloading packages...' });
          break;
        case codePush.SyncStatus.INSTALLING_UPDATE:
          this.setState({ updateMessage: 'Installing updates...' });
          break;
        case codePush.SyncStatus.UP_TO_DATE:
          this.setState({ updateMessage: '' });
          break;
        case codePush.SyncStatus.UPDATE_INSTALLED:
          this.setState({ updateMessage: '' });
          break;
        case codePush.SyncStatus.UNKNOWN_ERROR:
          this.setState({ updateMessage: '' });
          break;
      }
    },
    ({ receivedBytes, totalBytes }) => {
      /* Update download modal progress */
      this.setState({ updateMessage: `${Math.round(((receivedBytes / totalBytes) * 100))}% downloaded...` });
    }).then((val) => {
      console.log('******* valval ********:', val);
      this._getUsernameFromKeychain();
    }).catch((e) => {
      this._getUsernameFromKeychain();
    });

    codePush.getCurrentPackage()
      .then((update) => {
        // If the current app "session" represents the first time
        // this update has run, and it had a description provided
        // with it upon release, let's show it to the end user
        if (update !== undefined && update !== null && update.isFirstRun && update.description) {
          // Display a "what's new?" modal
          if (!isAlertTriggered) {
            isAlertTriggered = true;
            Alert.alert(ALERT.TITLE.INFO, `\n What's new: Bundle ${update.label}\n ${update.description}`,[
              {text: ALERT.BTN.OK, onPress: () => {
                isAlertTriggered = false;
              }},
            ],
            { cancelable: false }
            ); 
          }
        }
      });

  }
  /**
 * Retrieve username from Keychain and Shared Preferences
 * Set the username from and set it in state.
 */
  async _getUsernameFromKeychain() {
    this._navigateToLoginScreen();
  }

  /**
* Navigates to Sync Data Screen
*/
  _navigateToSyncDataScreen() {
    const moveToFirst = NavigationActions.reset(
      {
        index: 0,
        actions: [
          NavigationActions.navigate({ routeName: 'SyncDataScreen', 'params': {} }),
        ],
      });
    this.props.navigation.dispatch(moveToFirst);
  }

  /**
   * Navigates to Login Screen
   */
  _navigateToLoginScreen() {
    const moveToFirst = NavigationActions.reset(
      {
        index: 0,
        actions: [
          NavigationActions.navigate({ routeName: 'CRNLoginScreen', 'params': {} }),
        ],
      });
    this.props.navigation.dispatch(moveToFirst);

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
  * This method renders loader or retry button
  */
  _renderLoader() {
    const { isLoading } = this.state;
    if (isLoading) {
      return (
        <View>
          <ActivityIndicator
            style={{ marginTop: 350 }}
            color={COLOR.THEME}
            size="large"
          />

          <Text style={{ marginTop: 40, fontSize: deviceHeight / 50 }}>
            {this.state.updateMessage}
          </Text>
        </View>

      );
    } else {
      return (
        <TouchableOpacity style={[styles.buttonView, { width: deviceWidth / 2, height: deviceHeight / 18, marginTop: deviceHeight / 4 }]}
          onPress={() => this._checkCodePush()}
        >
          <Text style={[styles.buttonText, { fontSize: deviceHeight / 40 }]}>
            Retry
          </Text>
        </TouchableOpacity>
      );
    }
  }

  render() {
    let backgroundImg = require('../images/LaunchImagePortrait.png');
    if (this.state.isLandscape) {
      backgroundImg = require('../images/LaunchImageLandscape.png');
    } else {
      backgroundImg = require('../images/LaunchImagePortrait.png');
    }
    return (
      <View style={screenStyle.container}
        onLayout={this.onLayout.bind(this)}
      >
        <Image source={backgroundImg} style={{ height: deviceHeight, width: deviceWidth }} resizeMode="cover" />
        <View style={[screenStyle.container, { position: 'absolute', top: 0, bottom: 0, left: 0, right: 0, alignItems: 'center', justifyContent: 'center' }]}>
          {this._renderLoader()}
        </View>
      </View>
    );
  }
}


export default SplashScreen;

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  backgroundImage: {
    resizeMode: 'cover',
  },
  activityView: {
    position: 'absolute',
    top: 0,
    bottom: 0,
    left: 0,
    right: 0,
    alignItems: 'center',
    justifyContent: 'center',
  },
  buttonView: {
    backgroundColor: COLOR.THEME,
    justifyContent: 'center',
    alignItems: 'center',
    margin: 10,
    borderRadius: 5,
  },
  buttonText: {
    fontWeight: '700',
    color: 'white',
    fontFamily: FONT_FAMILY.HELVETICA_CONDENSEDBOLD,
  },
});

