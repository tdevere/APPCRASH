/*************************************************
 * InnovaZone
 * CRNLoginScreen.js
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
  TextInput,
  TouchableHighlight,
  Platform,
  Linking,
  TouchableOpacity,
  Modal,
  ScrollView,
} from 'react-native';

import PropTypes from 'prop-types';
import { NavigationActions } from 'react-navigation';

import HUD from '../utils/HUD';
import BackgroundImage from './BackgoundImage';
import { KeyboardAwareScrollView } from 'react-native-keyboard-aware-scroll-view';
import globalStyle from './css/GlobalStyleCSS';
import screenStyle from './css/CRNLoginScreenCSS';
import _ from 'lodash';
import CodePushUpdateView from '../utils/components/CodePushUpdateView';
import codePush from 'react-native-code-push';

let deviceWidth = Dimensions.get('window').width;
let deviceHeight = Dimensions.get('window').height;
let screenWidth = Dimensions.get('window').width;
let screenHeight = Dimensions.get('window').height;

/**
 * Handles CRN Login functionality
 * Calls CRN login web service 
 * After successful CRN validation, we are navigating to SyncData Screen to perform initial data download.
 */
class CRNLoginScreen extends Component {
  static propTypes = {
    navigation: PropTypes.object,
  };

  constructor(props) {
    super(props);

    this.state = {
      isLandscape: false,
      crnNoInputTxt: '', //qa05022019  Value set for easy login during deveopment. It should be removed on Build Delivery.
      visibleHud: false,
      settingsPopupEnable : false,
      hostName : '',
      apiVersion :'',
      bundleVersion: '',
    };
  }

  async componentDidMount() {
    global.isDatabaseOpened = false;
 
    codePush.getUpdateMetadata().then((metadata) => {
      if (metadata) {
        this.setState({ bundleVersion: metadata.label, version: metadata.appVersion });
      }
    });
  }


  /**
  * Method is called when the user tabs on login button
  * After successful CRN login, Check & Delete server folder path, Store Keychain value, Get the current config from localstorage, navigate to initial download
  */
  _loginButtonSubmit() {
    const moveToFirst = NavigationActions.reset(
      {
        index: 0,
        actions: [
          NavigationActions.navigate({ routeName: 'ClerkLoginScreen', 'params': {} }),
        ],
      });
    this.props.navigation.dispatch(moveToFirst);
   
  }


  /**
  * After successful CRN validation, we are navigating to SyncData Screen to perform initial data download.
  */
  _navigateToSyncDataScreen() {
    const moveToFirst = NavigationActions.reset({
      index: 0,
      actions: [
        NavigationActions.navigate({ routeName: 'SyncDataScreen', 'params': {} }),
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
   * Render screen except header bar
   */
  _renderScreen() {
    return (
      <View style={[screenStyle.cardContainer, { marginTop: Platform.OS == 'ios' ? deviceHeight / 15 : (this.state.isLandscape) ? deviceHeight / 190 : deviceHeight / 15 }]}>
        <View style={{ height: (this.state.isLandscape) ? Platform.OS == 'ios' ? deviceHeight * (1 / 2) : deviceHeight * (1 / 1.9) : deviceHeight * (2 / 5), width: (this.state.isLandscape) ? deviceWidth * (3 / 5) : deviceWidth * (4 / 5), alignItems: 'center', justifyContent: 'center' }}>
          <View>

            <Text style={[screenStyle.crnNoTxt, { bottom: Platform.OS == 'ios' ? 0 : (this.state.isLandscape) ? 40 : 0 }]}>
              CRN#
            </Text>
            <TextInput
              style={[screenStyle.textInputStyle, { width: (this.state.isLandscape) ? deviceWidth * (2 / 5) : deviceWidth * (3 / 5), bottom: Platform.OS == 'ios' ? 0 : (this.state.isLandscape) ? 40 : 0 }]}
              returnKeyType={'done'}
              autoCapitalize="none"
              autoCorrect= {true}
              onChangeText={(crnNoInputTxt) => this.setState({ crnNoInputTxt })}
              value={this.state.crnNoInputTxt}
            />

            <TouchableHighlight style={[screenStyle.button, { bottom: Platform.OS == 'ios' ? 0 : (this.state.isLandscape) ? 40 : 0 }]}
              underlayColor="transparent"
              onPress={() => this._loginButtonSubmit()}
            >
              <Text style={screenStyle.buttonText}>
                Login
              </Text>
            </TouchableHighlight>

          </View>
        </View>

        <HUD
          ref="mHudLoader"
          visible={this.state.visibleHud}
          message={this.state.messageHud}
        />
      </View>
    );
  }

 


  /**
   * Render CRN Login screen.
   */
  render() {
    return (
      <View style={globalStyle.container}
        onLayout={this.onLayout.bind(this)}
      >
        {BackgroundImage.renderBackgroundImage()}
        <View style={[screenStyle.containerViewMain]}>

          {
            //toolbar starts
          }
          <View style={globalStyle.toolbar}>

            <View style={globalStyle.toolbarLeftView} />

            <Text style={globalStyle.toolbarTitleText}>
              CRN Login
            </Text>

            <View style={globalStyle.toolbarRightView} />
          </View>
          {
            //toolbar ends
          }
          <KeyboardAwareScrollView
            keyboardShouldPersistTaps={'always'}
            contentContainerStyle={{ flexGrow: 1 }}
          >
            <View style={{ alignItems: 'center' }}>
              <Image source={require('../images/TopLogo.png')} style={{ height: (this.state.isLandscape) ? deviceHeight / 7 : deviceHeight / 8, width: deviceHeight / 2, marginVertical: (this.state.isLandscape) ? deviceHeight / 100 : deviceHeight / 26 }} resizeMode="contain" />
            </View>
            {this._renderScreen()}

          </KeyboardAwareScrollView>

          <View style={{ flexDirection: 'row', marginRight: 30, bottom: 20, alignItems: 'center', justifyContent: 'center' }}>
            <View style={{ flex: 1 }} />
           

            <TouchableOpacity
              onLongPress={{}}
            >
              <Text style={[screenStyle.versionText, { fontSize: deviceHeight / 64 }]}>
              V 
              </Text>
            </TouchableOpacity>
            {
              (this.state.bundleVersion) ?
                <Text style={[screenStyle.versionText, { fontSize: screenHeight / 64 }]}>
                  Bundle {this.state.bundleVersion}
                </Text>
                :
                null
            }
          </View>
        
          <CodePushUpdateView/>
        </View>
      </View>
    );
  }
}

export default CRNLoginScreen;
