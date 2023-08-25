
/*************************************************
 * InnovaZone
 * BackgoundImage.js
 * Created by  Vijayalakshmi K on 26/03/2018
 * Copyright © 2018 InnovaZone. All rights reserved.
 *************************************************/

'use strict';

import React, { Component } from 'react';
import {
  View,
  Dimensions,
  Image,
} from 'react-native';

let deviceWidth = Dimensions.get('window').width;
let deviceHeight = Dimensions.get('window').height;
let screenHeight = Dimensions.get('window').height;
let screenWidth = Dimensions.get('window').width;
let isLandscape = false;
import globalStyle from './css/GlobalStyleCSS';

class  BackgoundImage extends Component {


/**
 * Method is called when view size changed due to screen orientation changed.
 */
  static onLayout(e) {
    if (deviceWidth > deviceHeight) {
      screenHeight = deviceWidth;
      isLandscape = true; 
    }
    else {
      screenWidth = deviceHeight;
      isLandscape = false;
    }
  }


  /**
   * Render BackgroundImage 
   */
  static renderBackgroundImage() {
    let backgroundImg = require('../images/LaunchImagePortrait.png');
    if (isLandscape) {
      backgroundImg = require('../images/LaunchImageLandscape.png');
    }
    return(
      <View style ={globalStyle.container}
        onLayout={this.onLayout.bind(this)}
      >        
        <Image source={backgroundImg} resizeMode="cover" style={{height: screenHeight, width: screenWidth}} />
      </View>
    );    
  }
}

export default BackgoundImage;
