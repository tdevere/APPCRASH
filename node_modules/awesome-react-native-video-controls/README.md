# awesome-react-native-video-controls
This package is forked from react-native-video-controls.
Enhance functionality for react native video Controls available at [react-native-video-controls](https://github.com/react-native-community/react-native-video-controls)
## Features
**SUBTITLE SUPPORT ADDED** 
In This package, you can pass a function as 'toggleFullscreen' prop to component to control the functionality of toggle fullscreen button.

You can find other features in [react-native-video-controls] (https://github.com/react-native-community/react-native-video-controls)
and [react-native-video](https://github.com/react-native-community/react-native-video) pages.

## Installation
Run `npm install --save react-native-video awesome-react-native-video-controls`

Then run `react-native link react-native-video`

If you're using RN < 39 run `npm install --save react-native-video-controls@1.0.1`. Note this version includes `react-native-video` as a normal dependency instead of a peer-dependency.


##SUBTITLE 
In order to use subtitles you should follow the below instructions : 
First if your subtitle format is srt you should convert it to JSON(use websites like : http://multiverso.me/srtToJSON/)
Then when you got the array of JSONs, you can pass this array to VideoPlayer as below : 
```javascript
<VideoPlayer
   subtitle={this.props.subtitle}
/>
```

## OTHER FEATURES AND USAGE
The `<VideoPlayer>` component can take a number of inputs to customize it as needed. They are outlined below:
The `<VideoPlayer>` component follows the API of the `<Video>` component at [react-native-video](https://github.com/react-native-community/react-native-video) and [react-native-video-controls](https://github.com/react-native-community/react-native-video-controls)

take a number of inputs to customize it as needed. They are outlined below:

```javascript
// At the top where our imports are...
import VideoPlayer from 'awesome-react-native-video-controls';

// in the component's render() function
<VideoPlayer
    source={{ uri: 'https://vjs.zencdn.net/v/oceans.mp4' }}
    navigator={ this.props.navigator }
    toggleFullscreen={YourCustomizedFunction}
    subtitle={this.props.subtitle}
/>
```