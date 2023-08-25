/*************************************************
 * InnovaZone
 * AppCenterAnalytics.js
 * Created by Karthi Nalliyappan on 30/10/2019
 * Copyright © 2019 InnovaZone. All rights reserved.
 *************************************************/

'use strict';

import Analytics from 'appcenter-analytics';
import codePush from 'react-native-code-push';
import { Platform } from 'react-native';
import { ALERT, CODE_PUSH } from './Constants';
import { Alert } from 'react-native';
import Events from 'react-native-simple-events';
import { myLog } from '../utils/Utility';
import * as Sentry from '@sentry/react-native';

let appCenterUpdateCheckTimer = undefined;
let appCenterDownloadCompleted = false;

let deploymentKey = '';

if (Platform.OS === 'ios') {
  deploymentKey = CODE_PUSH.IOS.DEVELOPMENT;
} else {
  deploymentKey = CODE_PUSH.ANDROID.DEVELOPMENT;
}

/**
  * Enables Analytics according to the user's preference.
  * @param {boolean} isEnabled Flag to enable Analytics 
  */

export const setEnabled = (isEnabled) => { 
  Analytics.setEnabled(isEnabled);
   
}; 


/**
  * Sends event details to App Center - Analytics.
  * @param {string} eventName Name of the screen in which event occurs
  * @param {string} message Event message to be send to Analytics.
  */
export const setAppCenterUpdateCheckTimer = (timeInterval) => {
  // set timer to refresh token
  if(appCenterUpdateCheckTimer !== undefined) {
    return;
  }
  
  codePush.sync({
    deploymentKey,
    checkFrequency: codePush.CheckFrequency.ON_APP_RESUME,
    isFirstRun: true,
    /**
      * Active update, which lets the end user know
      * about each update, and displays it to them
      * immediately after downloading it
      */
    installMode: codePush.InstallMode.ON_NEXT_RESTART,
    updateDialog: {
      appendReleaseDescription: true,
      updateTitle: 'You have an update',
      optionalUpdateMessage: 'An update is available. Would you like to install it?',
      optionalIgnoreButtonLabel: 'Later',
      optionalInstallButtonLabel: 'Install',
    },
  },
  (status) => {
    switch (status) {
      case codePush.SyncStatus.CHECKING_FOR_UPDATE:
        console.log('$$$$$$$$$$$  Checking for updates...  $$$$$$$$$$$$$$$$$');
        // this.setState({updateMessage: 'Checking for updates...'});
        break;
      case codePush.SyncStatus.DOWNLOADING_PACKAGE:
        console.log('$$$$$$$$$$$  Downloading packages...  $$$$$$$$$$$$$$$$$');
        // this.setState({ updateMessage: 'Downloading packages...' });
        break;
      case codePush.SyncStatus.INSTALLING_UPDATE:
        console.log('$$$$$$$$$$$  Installing updates...  $$$$$$$$$$$$$$$$$');
        // this.setState({ updateMessage: 'Installing updates...' });
        break;
      case codePush.SyncStatus.UP_TO_DATE:
        // this.setState({ updateMessage: '' });
        break;
      case codePush.SyncStatus.UPDATE_INSTALLED:
        console.log('$$$$$$$$$$$  Update Installed  $$$$$$$$$$$$$$$$$');
        if (appCenterDownloadCompleted) {
          appCenterDownloadCompleted = false;
          Alert.alert(ALERT.TITLE.INFO, 'App center bundle download completed. Would you like to restart the App',[
            {text: 'Later', onPress: () => {
              appCenterDownloadCompleted = true;
            }},
            {text: 'Restart', onPress: () => {
              if (Platform.OS === 'android') {
                codePush.restartApp();
              }
            }},
          ],
          { cancelable: false }
          );
        }
          
        ////
        break;
      case codePush.SyncStatus.UNKNOWN_ERROR:
        ////
        break;
    }
  },
  ({ receivedBytes, totalBytes }) => {
    /* Update download modal progress */
    console.log('$$$$$$$$$$$  Downloading Progress...  $$$$$$$$$$$$$$$$$', `${Math.round(((receivedBytes / totalBytes) * 100))}% downloaded...`);
    appCenterDownloadCompleted = true;
  }).then((val) => {
    console.log('$$$$$$$$$$$  Start the App val $$$$$$$$$$$$$$$$$', val);
  }).catch((e) => {
    console.log('$$$$$$$$$$$  Start the App error $$$$$$$$$$$$$$$$$', e.message);
  });
};


export const checkForNewUpdate = () => {
  codePush.checkForUpdate(
    deploymentKey
  ).then((update) => {
    myLog('$$$$$$$$$$$  checkForNewUpdate update 1111 $$$$$$$$$$$$$$$$$:', update);
    if (update) {
      myLog('$$$$$$$$$$$  description $$$$$$$$$$$$$$$$$:', update.description, update.deploymentKey);
    }

    if (!update) {
      codePush.getUpdateMetadata(codePush.UpdateState.PENDING).then((data) => {
        console.log('$$$$$$$$$$$  data $$$$$$$$$$$$$$$$$', data);
        if (data) {
          Events.trigger('onCodePushBundleRestart', {});
        }
      });
    }else{
      Events.trigger('onCodePushUpdateAvailable', {});
    }
  }).catch((e) => {
    myLog('*********** Error **********:', e.message);
  });
};


export const checkForCodePushNewUpdate = () => {
  // set timer to refresh token
  if(appCenterUpdateCheckTimer !== undefined) {
    return;
  }
  codePush.checkForUpdate(
    deploymentKey,
  ).then((update) => {
    myLog('$$$$$$$$$$$  onCodePushUpdateAvailable update $$$$$$$$$$$$$$$$$:', update);
    if (!update) {
      codePush.getUpdateMetadata(codePush.UpdateState.PENDING).then((data) => {
        if (data) {
          myLog('$$$$$$$$$$$  onCodePushBundleRestart  $$$$$$$$$$$$$$$$$');
          Sentry.init({
            dsn: URL.SENTRY_DSN,
            release: `${update.appVersion}+codepush:${update.label}`,
          });
          Events.trigger('onCodePushBundleRestart', {});
        }
      });
    }else{
      myLog('$$$$$$$$$$$  onCodePushUpdateAvailable  $$$$$$$$$$$$$$$$$');
      Events.trigger('onCodePushUpdateAvailable', {});
    }
  }).catch((e) => {
    myLog('*********** Error **********:', e.message);
  });
};


export const installCodePush = () => {
  myLog('$$$$$$$$$$$  @@@ installCodePush @@@  $$$$$$$$$$$$$$$$$');

  codePush.sync({
    deploymentKey,
    checkFrequency: codePush.CheckFrequency.ON_APP_RESUME,
    /**
    * Active update, which lets the end user know
    * about each update, and displays it to them
    * immediately after downloading it
    */
    installMode: codePush.InstallMode.ON_NEXT_RESTART,
    updateDialog: false,
    isFirstRun: true,
  },
  (status) => {
    switch (status) {
      case codePush.SyncStatus.CHECKING_FOR_UPDATE:
        myLog('$$$$$$$$$$$  Checking for updates...  $$$$$$$$$$$$$$$$$');
        break;
      case codePush.SyncStatus.DOWNLOADING_PACKAGE:
        myLog('$$$$$$$$$$$  Downloading packages...  $$$$$$$$$$$$$$$$$');
        break;
      case codePush.SyncStatus.INSTALLING_UPDATE:
        myLog('$$$$$$$$$$$  Installing updates...  $$$$$$$$$$$$$$$$$');
        break;
      case codePush.SyncStatus.UP_TO_DATE:
        myLog('$$$$$$$$$$$  UP_TO_DATE...  $$$$$$$$$$$$$$$$$');
        break;
      case codePush.SyncStatus.UPDATE_INSTALLED:
        myLog('$$$$$$$$$$$  Update Installed  $$$$$$$$$$$$$$$$$');
        Events.trigger('onCodePushBundleRestart', {});
        break;
      case codePush.SyncStatus.UNKNOWN_ERROR:
        myLog('$$$$$$$$$$$  UNKNOWN_ERROR  $$$$$$$$$$$$$$$$$');
        break;
    }
  },
  ({ receivedBytes, totalBytes }) => {
    /* Update download modal progress */
    Events.trigger('onCodePushBundleDownloadProgress', Math.round(((receivedBytes / totalBytes) * 100)));
    myLog('$$$$$$$$$$$  Downloading Progress... 1122  $$$$$$$$$$$$$$$$$', `${Math.round(((receivedBytes / totalBytes) * 100))}% downloaded...`);
  }).then((val) => {
    myLog('$$$$$$$$$$$  Start the App val $$$$$$$$$$$$$$$$$', val);
  }).catch((e) => {
    myLog('$$$$$$$$$$$  Start the App error $$$$$$$$$$$$$$$$$', e.message);
  });
};

