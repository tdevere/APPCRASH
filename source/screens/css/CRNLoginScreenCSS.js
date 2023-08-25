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
  Platform,
} = React;
import { FONT_FAMILY, COLOR } from '../../common/Constants';
let deviceHeight = Dimensions.get('window').height;

module.exports = StyleSheet.create({
  
  containerViewMain: {
    flex: 1,
    position: 'absolute', 
    top: 0, 
    bottom: 0, 
    left: 0, 
    right: 0, 
    alignItems: 'center',
  },
  
  cardContainer: {
    borderWidth: 2,
    borderRadius: 10,
    backgroundColor: '#fff',
    borderColor: 'rgba(0,0,0,0.1)',
    marginVertical: 5,
    padding: 10,
    shadowColor: '#ccc',
    shadowOffset: { width: 4, height: 4 },
    shadowOpacity: 3,
    shadowRadius: 10,
  },
  crnNoTxt: {
    fontSize: 22, 
    color: 'black', 
    fontWeight: '100', 
    marginBottom: deviceHeight/60,
    fontFamily: FONT_FAMILY.HELVETICA_CONDENSEDBOLD,
  },
  textInputStyle: {
    height: 60,
    fontSize: 22,
    paddingLeft: 20,
    color: 'black',
    backgroundColor: '#EFEFEF',
    borderWidth: 2,
    borderColor: 'gainsboro',
    borderRadius: 5,
    fontFamily: FONT_FAMILY.HELVETICA_CONDENSEDBOLD,
  },
  button: {
    alignItems: 'center',
    justifyContent: 'center',
    marginTop: deviceHeight * (1/20),
    borderRadius: 5,
    padding: deviceHeight/60,
    paddingVertical:10,
    backgroundColor: COLOR.THEME,
  },
  buttonText: {
    fontSize: 30,
    color: 'white',
    fontWeight: 'bold',
    fontFamily: FONT_FAMILY.HELVETICA_CONDENSEDBOLD,
  },
  versionText:{
    color:'black', 
    marginRight:15, 
    fontWeight:'600',
    fontFamily:FONT_FAMILY.HELVETICA_CONDENSEDBOLD, 
  },

});