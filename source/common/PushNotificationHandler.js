
import { 
  Linking,
  Alert,
  Platform,
  AsyncStorage,
} from 'react-native';
// import PushNotification from 'react-native-push-notification';
import PushNotificationIOS from '@react-native-community/push-notification-ios';
import { ALERT, STORE_LINK, FONT_FAMILY } from './Constants';

// import AsyncStorage from '@react-native-community/async-storage';

import { NavigationActions } from 'react-navigation';
import Toast from 'react-native-simple-toast';
import Events from 'react-native-simple-events';


const deviceMessageStyle = {
  backgroundColor: '#000000',
  color: '#ffffff',
  width: 400,
  height : 70,
  borderRadius: 15,
  fontSize : 20,
  fontFamily : FONT_FAMILY.HELVETICA_CONDENSEDBOLD,
};
export const pushNotificationRegisterAndOnnotification = () => { 
   
  console.log('************** pushNotificationRegisterAndOnnotification ***************');
  PushNotification.setApplicationIconBadgeNumber(0);
  PushNotification.configure({

    // (optional) Called when Token is generated (iOS and Android)
    onRegister: (token) => {
      console.log('************** token ***************:', token.token);
      global.deviceToken = token.token;
    },
  
    // (required) Called when a remote or local notification is opened or received
    onNotification: (notification) => {

      // PushNotification.setApplicationIconBadgeNumber(0);
      
      console.log( '*************** NOTIFICATION:', notification );
      // updateAlerFuction();
      // process the notification
      onNotificationProcess(notification);
      // required on iOS only (see fetchCompletionHandler docs: https://facebook.github.io/react-native/docs/pushnotificationios.html)
      notification.finish(PushNotificationIOS.FetchResult.NoData);
    },
  
    // ANDROID ONLY: GCM or FCM Sender ID (product_number) (optional - not required for local notifications, but is need to receive remote push notifications)
    senderID: '720401254615',
  
    // IOS ONLY (optional): default: all - Permissions to register.
    permissions: {
      alert: true,
      badge: true,
      sound: true,
    },
  
    // Should the initial notification be popped automatically
    // default: true
    popInitialNotification: true,
  
    /**
        * (optional) default: true
        * - Specified if permissions (ios) and token (android and ios) will requested or not,
        * - if not, you must call PushNotificationsHandler.requestPermissions() later
        */
    requestPermissions: true,
  });

}; 

export const onNotificationProcess = (data) => {
  console.log('*********** updateCheckedCount ************: 11', data );
  if (data.message === 'CRN RESET') {
    if (global.isNetworkConnected && global.isAutoCRNReset && !global.isPartialSyncRunning && !global.isAPICallRunning) {
      Toast.show('iPad will start the CRN reset now', Toast.SHORT, Toast.BOTTOM, deviceMessageStyle); 
      Events.trigger('onCRNReset', {});
    } else {
      if (global.isAutoCRNReset) {
        Toast.show('CRN reset Will start after 90 seconds', Toast.SHORT, Toast.BOTTOM, deviceMessageStyle); 
        setTimeout(() => {
          onNotificationProcess(data);
        },(60000 * 1.5)); // 2 minute duration will call method  
      }else {
        setTimeout(() => {
          onNotificationProcess(data);
        },(5000)); // 2 minute duration will call method  
      }
    }
   
  } else {
    updateAlerFuction();
  }
  
};


export const updateAlerFuction = async() => {
  // Retrieves value from storage
  const updateCheckedCount =  JSON.parse(await AsyncStorage.getItem('updateCheck')) ;
  console.log('*********** updateCheckedCount ************:', updateCheckedCount);
  if (updateCheckedCount >= 3) {
    Alert.alert(
      ALERT.TITLE.INFO,
      ALERT.TITLE.UPDATE_LATEST_VERSION,
      [
        {
          text: ALERT.BTN.UPDATE, onPress: () => {
            AsyncStorage.setItem('updateCheck', JSON.stringify(0));
            Linking.openURL((Platform.OS === 'ios' ? STORE_LINK.IOS_APP_STORE : STORE_LINK.ANDROID_PLAY_STORE));
          },
        },
      ],
      { cancelable: false }
    );
  } else {
    Alert.alert(
      ALERT.TITLE.INFO,
      ALERT.TITLE.UPDATE_LATEST_VERSION,
      [
        {
          text: ALERT.BTN.UPDATE, onPress: () => {
            AsyncStorage.setItem('updateCheck', JSON.stringify(0));
            Linking.openURL((Platform.OS === 'ios' ? STORE_LINK.IOS_APP_STORE : STORE_LINK.ANDROID_PLAY_STORE));
          },
        },
        {text: ALERT.BTN.LATER, onPress: () => {
          // Saves to storage as a JSON-string
          AsyncStorage.setItem('updateCheck', JSON.stringify(updateCheckedCount + 1));
        }},
      ],
      { cancelable: false }
    );
  }
};


