/*************************************************
  * InnovaZone
  * Constants.js
  * Created by Selvin Thamodharan on 13/02/2018
  * Copyright © 2018 InnovaZone. All rights reserved.
  *************************************************/
'use strict';

/**
  * Returns all the constants used in the application
  * Separate constants according to the category and usage
  */
// module.exports = {

export const SERVER = {
  HOST_NAME: '',
  API_VERSION: 'v1',
  VOUCHER_API_VERSION: 'voucher',
  PRINT_API_VERSION: 'utils',

  // Production server host name and api version.
  PRODUCTION_HOST_NAME: '',
  PRODUCTION_API_VERSION: 'v1',

  PROTOCAL: 'https://',
  PATH: '/api',

};

export const SCREEN_TITLE = {
  CRN_LOGIN: 'CRN Login',
  LOGIN: 'Login',
};

export const CODE_PUSH = {
  ANDROID: {
    DEVELOPMENT: 'AB73MdSaA1Iytt8sIYszS5Z1DV2_wA7oBi8tF',
  },
  IOS: {
    DEVELOPMENT: 'PRuPd2puvUMAJSAb3lgB8PyfTczIqO-69-vJn',
  },

  PRODUCTION_UPDATE_CHECK_TIMEOUT :12*1,  // hours-day
  IS_BETA_UPDATE_CHECK_TIMEOUT : 0.5*1,  // hours-day
  DEVELOPMENT_UPDATE_CHECK_TIMEOUT : 0.5*1,  // hours-day  
  // 0.084 --> 5mins
  // 0.25 --> 15mins
  // 0.5  --> 30mins
};

export const FONT_FAMILY = {
  HELVETICA_CONDENSEDBOLD: 'HelveticaNeue-CondensedBold',
  HELVETICA_CONDENSEDBLACK: 'HelveticaNeue-CondensedBlack',
  HELVETICA_CONDENSED_THIN: 'HelveticaNeue-Thin',
  HELVETICA_CONDENSED_ITALIC: 'HelveticaNeue-Italic',
  HELVETICA_CONDENSED_LIGHT: 'HelveticaNeue-Light',
};

export const FONT_SIZE = {
  SCREEN_TITLE: 24,
  SCREEN_NAVIGATION_CONTENT: 21,
  FONT_WEIGHT: '800',
};

export const FONT_WEIGHT = {
  TITLE_FONT_WEIGHT: '800',
};

export const TOP_PADDING = {
  IOS: 20,
  ANDROID: 27,
};

export const HUD_MSG = {
  LOADING: 'Loading...',
};

export const COLOR = {
  THEME: '#e11f26',
  NAVIGATION_BAR_BG: '#252525',
  
};

