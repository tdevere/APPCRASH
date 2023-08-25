/*************************************************
 * InnovaZone
 * CodePushUpdateView.js
 * Created by Karthi Nalliyappan on 26 NOVEMBER 2020
 * Copyright © 2019 InnovaZone. All rights reserved.
 *************************************************/

'use strict';

import React, { Component } from 'react';
import { 
  View,
  Dimensions,
  TouchableOpacity,
  Text,
  StyleSheet,
  StatusBar,
  Platform,
} from 'react-native';
import PropTypes from 'prop-types'; 
import { COLOR, FONT_FAMILY } from '../../common/Constants';
import BlinkView from 'react-native-blink-view';
import Events from 'react-native-simple-events';
import { installCodePush, checkForNewUpdate } from '../../common/AppCenterAnalytics';
import codePush from 'react-native-code-push';

let deviceWidth = Dimensions.get('window').width;
let deviceHeight = Dimensions.get('window').height;

export default class CodePushUpdateView extends Component {

  static defaultProps = {
    visible: false,
  };
  static propTypes = {
    visible: PropTypes.bool,
  };

  constructor(props) {
    super(props);
    this.state = {
      codePushUpdateAvailable: false,
      codePushBundleRestartAvailable: false,
      message: '',    
    };
  }

  componentDidMount(){
    Events.on('onCodePushUpdateAvailable', 'CodePush', this._codePushUpdateAvailableEventHandlerFunc.bind(this));
    Events.on('onCodePushBundleRestart', 'CodePush', this._codePushBundleRestartEventHandlerFunc.bind(this));
    Events.on('onCodePushBundleDownloadProgress', 'CodePush', this._codePushBundleDownloadProgressEventHandlerFunc.bind(this));
    checkForNewUpdate(); 
  }

  /**
   * Get triggered when the view is unmounted on the window
   * Put off the EventBus
   */
  componentWillUnmount() {
    //
  }

  /**
   * Event will trigger if the code push update available
   */
  _codePushUpdateAvailableEventHandlerFunc() {
    this.setState({
      codePushUpdateAvailable: true,
      codePushBundleRestartAvailable: false, 
      message: 'Update Available - Click here',   
    });
  }

  /**
   * Event will trigger if the code push bundel restart available
   */
  _codePushBundleRestartEventHandlerFunc(){
    this.setState({
      codePushUpdateAvailable: false,
      codePushBundleRestartAvailable: true,    
      message: 'Restart Available - Click here',   
    });
  }

  /**
   * Event will trigger if the code push bundle download progress value update to UI 
   */
  _codePushBundleDownloadProgressEventHandlerFunc(progressValue){
    this.setState({
      message : `${Math.floor(progressValue)}% downloaded...`,
    });
  }

  /**
   * Button action
   * Download the code push bundle
   * If Restart available -- App will restart
   */
  onPressAction(){
    const {codePushUpdateAvailable, codePushBundleRestartAvailable } = this.state;
    if (codePushUpdateAvailable) {
      installCodePush();
    } else if (codePushBundleRestartAvailable) {
      if (Platform.OS === 'android') {
        codePush.restartApp();
      }
    }
  }

  /**
   * Method is called when the code push update available.
   */
  render() {
    const { codePushUpdateAvailable, codePushBundleRestartAvailable, message } = this.state;
    if (codePushUpdateAvailable || codePushBundleRestartAvailable) {
      return (
        <View style={{ position:'absolute', marginLeft: (global.isLandscape) ? deviceWidth/2.0 : deviceWidth/ 2.9}}>
          <StatusBar hidden />
          <BlinkView blinking={true} delay={1000}>
            <TouchableOpacity
              onPress={()=>{
                this.onPressAction();
              }}
            >
              <View style={styles.containerView}>
                <Text style={styles.messageText}>
                  {message}
                </Text>
              </View>
            </TouchableOpacity>
          </BlinkView>
        </View>
      ); 
    }else{
      return(
        <View/>
      );
    }
  }
}

const styles=StyleSheet.create({
  containerView: {
    backgroundColor: COLOR.GREEN,
    alignItems:'center', 
    justifyContent:'center', 
    borderRadius: 10,
  },
  messageText:{
    fontFamily: FONT_FAMILY.HELVETICA_CONDENSEDBOLD, 
    fontSize: deviceHeight/56.88, 
    color: COLOR.WHITE, 
    textAlign:'center', 
    paddingHorizontal:10,
    paddingVertical:10,
  },
  
});