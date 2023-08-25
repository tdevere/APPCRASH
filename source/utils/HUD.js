
//     react-native-loading-spinner-overlay
//     Copyright (c) 2016- Nick Baugh <niftylettuce@gmail.com>
//     MIT Licensed

// * Author: [@niftylettuce](https://twitter.com/#!/niftylettuce)
// * Source:
// <https://github.com/niftylettuce/react-native-loading-spinner-overlay>

// # react-native-loading-spinner-overlay
//
// <https://github.com/facebook/react-native/issues/2501>
// <https://rnplay.org/apps/1YkBCQ>
// <https://github.com/facebook/react-native/issues/2501>
// <https://github.com/brentvatne/react-native-overlay>
//

import React from 'react';
import {
  StyleSheet,
  View,
  Modal,
  ActivityIndicator,
  Text,
} from 'react-native';

import PropTypes from 'prop-types';

/**
 * Modifed by Selvin Thamodharan on 13/02/2018
 * Added a backgorund view and text under the activity indicator
 */
const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: 'transparent',
    position: 'absolute',
    top: 0,
    bottom: 0,
    left: 0,
    right: 0,
  },
  background: {
    position: 'absolute',
    top: 0,
    bottom: 0,
    left: 0,
    right: 0,
    justifyContent: 'center',
    alignItems: 'center',
  },
});

const SIZES = ['small', 'normal', 'large'];

export default class HUD extends React.Component {

  static propTypes = {
    visible: PropTypes.bool,
    message:PropTypes.string,
    messgeColor: PropTypes.string,
    color: PropTypes.string,
    size: PropTypes.oneOf(SIZES),
    backgroundColor: PropTypes.string,
    overlayColor: PropTypes.string,
  };

  static defaultProps = {
    visible: false,
    message: '',
    messgeColor: 'white',
    color: 'white',
    size: 'large', 
    backgroundColor: '#2D2F30',
    overlayColor: 'rgba(0, 0, 0, 0.25)',
  };

  constructor(props) {
    super(props);
    this.state = { visible: this.props.visible};
    global.isHudVisible = this.props.visible;
  }

  componentWillReceiveProps(nextProps) {
    const { visible } = nextProps;
    this.setState({ visible });
    global.isHudVisible = visible;
  }

  _renderSpinner() {
    const spinner = (
      <View style={styles.container} key={`spinner_${Date.now()}`}>
        <View
          style={[
            styles.background,
            { backgroundColor: this.props.overlayColor },
          ]}
        >
          <View style={{backgroundColor: this.props.backgroundColor, padding: 25, paddingHorizontal:35, borderRadius: 10 }}>
            <ActivityIndicator
              color={this.props.color}
              size={this.props.size}
            />
            <Text style={{color: this.props.messgeColor,  marginTop:(this.props.message.length > 0 ) ? 10 : -15,  fontSize: 20}}>
              {this.props.message}
            </Text>
          </View>
        </View>
      </View>
    );

    return (
      <Modal
        animationType={'none'}
        // supportedOrientations={['portrait']}
        onRequestClose={() => {}}
        visible={this.state.visible}
        transparent={true}
      >
        {spinner}
      </Modal>
    );
  }

  render() {
    return this._renderSpinner();
  }

}
