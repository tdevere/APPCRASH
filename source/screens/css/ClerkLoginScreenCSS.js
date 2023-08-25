/*************************************************
 * InnovaZone
 * ClerkLoginScreenCSS.js
 * Created by Karthi Nalliyappan on 27/03/2018
 * Copyright © 2018 InnovaZone. All rights reserved.
 *************************************************/

'use strict';

/**
 * Returns all the styles used in the ClerkLoginScreen
 */
import React from 'react-native';
let {
  StyleSheet,
  Dimensions,
} = React;
import { FONT_FAMILY, COLOR } from '../../common/Constants';
let deviceHeight = Dimensions.get('window').height;

module.exports = StyleSheet.create({
  container: {
    flex: 1,
  },
  cardContainer: {
    borderWidth: 2,
    borderRadius: 10,
    backgroundColor: '#fff',
    borderColor: 'rgba(0,0,0,0.1)',
    marginVertical: -5,
    paddingHorizontal: 10,
    shadowColor: '#ccc',
    shadowOffset: { width: 4, height: 4 },
    shadowOpacity: 3,
    shadowRadius: 10,
  },
  crnNoTxt: {
    fontSize: 25,
    color: 'black',
    fontWeight: 'bold',
    marginBottom: deviceHeight / 60,
    fontFamily:FONT_FAMILY.HELVETICA_CONDENSEDBOLD, 
  },
  textInputStyle: {
    height: 60,
    fontSize: 22,
    paddingLeft: 20,
    color: 'black',
    backgroundColor: '#EFEFEF',
    borderWidth: 2,
    borderColor: 'gainsboro',
    borderRadius: 10,
    fontFamily:FONT_FAMILY.HELVETICA_CONDENSEDBOLD, 
  },
  button: {
    alignItems: 'center',
    justifyContent: 'center',
    marginTop: deviceHeight * (1 / 30),
    borderRadius: 10,
    padding: deviceHeight / 60,
    backgroundColor: COLOR.THEME,
  },
  buttonText: {
    fontSize: 25,
    color: 'white',
    fontWeight: 'bold',
    fontFamily:FONT_FAMILY.HELVETICA_CONDENSEDBOLD, 
  },
  segmentText:{
    textAlign: 'center', 
    fontSize: 24, 
    paddingVertical: 10,
    fontFamily:FONT_FAMILY.HELVETICA_CONDENSEDBOLD, 
  },
  bottomPowerbyContainer:{
    position: 'absolute', 
    bottom: 0, 
    left: 0, 
    right: 0, 
    alignItems: 'center',
  },
  versionText:{
    color:'black', 
    marginRight:15, 
    fontWeight:'800',
    fontFamily:FONT_FAMILY.HELVETICA_CONDENSEDBOLD, 
  },
});