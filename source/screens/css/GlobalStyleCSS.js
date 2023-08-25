/*************************************************
 * InnovaZone
 * CRNLoginScreenCSS.js
 * Created by Vijayalakshmi on 07/04/2018
 * Copyright © 2018 InnovaZone. All rights reserved.
 *************************************************/

'use strict';

/**
 * Returns all the styles used in the CRNLoginScreen
 */

import React from 'react-native';
let {
  StyleSheet,
  Dimensions,
} = React;

import { FONT_SIZE, COLOR } from '../../common/Constants';
let deviceWidth = Dimensions.get('window').width;
let deviceHeight = Dimensions.get('window').height;

module.exports = StyleSheet.create({
  container: {
    flex: 1,
  },
  toolbar: {
    flexDirection: 'row',
    backgroundColor: 'black',
    alignItems: 'center',
  },
  backImage: {
    height: 30,
    width:30,
    marginLeft:20,
  },
  toolbarLeftView: {
    height: 1,
    width: 40,
    marginLeft: 20,
  },
  toolbarRightView: {
    height: 1,
    width: 40,
    marginRight: 20,
  },
  toolbarTitleText: {
    flex: 8,
    textAlign: 'center',
    fontSize: FONT_SIZE.SCREEN_TITLE,
    fontWeight: 'bold',
    padding: 20,
    color: 'white',
    fontFamily:'HelveticaNeue-CondensedBold',
  },
  noDataFoundContainer:{
    height: deviceHeight * (3/5), 
    alignItems: 'center', 
    justifyContent: 'center',
  },
  noDataFoundText:{
    fontSize: deviceHeight/41.69, 
    paddingHorizontal:deviceWidth/18.75, 
    color: COLOR.TEXT_LIGHT_GRAY_COLOR,
    fontFamily:'HelveticaNeue-CondensedBold',
    textAlign:'center',
  },
  bottomPowerByLogoMainContainer:{
    position: 'absolute', 
    bottom: 0, 
    left: 0, 
    right: 0, 
    alignItems: 'center',
  },
});