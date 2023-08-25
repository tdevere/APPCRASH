
/*************************************************
 * InnovaZone
 * PreventDoubleClick.js
 * Created by KARTHI on 13 NOVEMBER 2020
 * Copyright © 2020 InnovaZone. All rights reserved.
 *************************************************/


import React from 'react';
import debounce from 'lodash/debounce';

const PreventDoubleClick = (WrappedComponent) => {
  
  class PreventDoubleClick extends React.PureComponent {
    
    debouncedOnPress = () => {
      this.props.onPress && this.props.onPress();
    }
    
    onPress = debounce(this.debouncedOnPress, 1000, { leading: true, trailing: false });
    
    render() {
      return <WrappedComponent {...this.props} onPress={this.onPress} />;
    }
  }
  
  PreventDoubleClick.displayName = `PreventDoubleClick(${WrappedComponent.displayName ||WrappedComponent.name})`
  return PreventDoubleClick;
};

export default PreventDoubleClick;