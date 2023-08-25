// /*************************************************
//  * InnovaZone
//  * App.js
//  * Created by Jagadisg Sellamuthu on 13/02/2018
//  * Copyright © 2018 InnovaZone. All rights reserved.
//  *************************************************/

'use strict';

import {
  AppRegistry,
} from 'react-native';
import { StackNavigator } from 'react-navigation';
import BackboneEvents from 'backbone-events-standalone';
import codePush from 'react-native-code-push';

import SplashScreen from './screens/SplashScreen';
import CRNLoginScreen from './screens/CRNLoginScreen';
import ClerkLoginScreen from './screens/ClerkLoginScreen';


// global event bus   
window.EventBus = BackboneEvents.mixin({});
const App = StackNavigator({
  SplashScreen : { screen: SplashScreen },
  CRNLoginScreen: { screen: CRNLoginScreen },
  ClerkLoginScreen: { screen: ClerkLoginScreen },
}, {initialRouteName: 'SplashScreen', mode: 'card', headerMode: 'none', navigationOptions: {gesturesEnabled: false}});

AppRegistry.registerComponent('InnovaZones', () => codePush(App));

