import React, { Component } from 'react';
import {
  Platform,
  AppState,
} from 'react-native';
import {
  Camera,
  DataCaptureContext,
  FrameSourceState,
} from 'scandit-react-native-datacapture-core';
// import DeviceInfo from 'react-native-device-info';

import { 
  SCANDIT_LICENSE_KEY_PRODUCTION_IOS,
  SCANDIT_LICENSE_KEY_PRODUCTION_ANDROID,
} from '../../webservice/URL';

// Singleton Context, Camera and CaptureMode
export default class ContextSingleton {
    static instance = ContextSingleton.instance || new ContextSingleton()

    // getCamera() {
    //   if (!this.camera) {
    //     this.camera = Camera.default;
    //   }
    //   return this.camera;
    // }

    getDataCaptureContext(){

      if (!this.dataCaptureContext) {
        if (Platform.OS === 'android') {
          this.dataCaptureContext = DataCaptureContext.forLicenseKey(SCANDIT_LICENSE_KEY_PRODUCTION_ANDROID);  
        } else {
          this.dataCaptureContext = DataCaptureContext.forLicenseKey(SCANDIT_LICENSE_KEY_PRODUCTION_IOS);
        }
      }
      return this.dataCaptureContext;
    }
}