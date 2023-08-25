import React, { Component } from 'react';
import { Alert, AppState, BackHandler, Platform, View, Dimensions,   PermissionsAndroid } from 'react-native';
import {
  BarcodeCapture,
  BarcodeCaptureOverlay,
  BarcodeCaptureOverlayStyle,
  BarcodeCaptureSettings,
  Symbology,
  SymbologyDescription,
} from 'scandit-react-native-datacapture-barcode';
import {
  Brush,
  Color,
  Camera,
  CameraSettings,
  DataCaptureContext,
  DataCaptureView,
  FrameSourceState,
  RectangularViewfinder,
  RectangularViewfinderStyle,
  RectangularViewfinderLineStyle,
  VideoResolution,
  SizeWithUnit,
  NumberWithUnit,
  MeasureUnit,
  TorchState,
  TorchSwitchControl,
} from 'scandit-react-native-datacapture-core';
import PropTypes from 'prop-types';
import Events from 'react-native-simple-events';
import { 
  QA_BUNDLE_ID,
  SCANDIT_LICENSE_KEY_QA_IOS,
  SCANDIT_LICENSE_KEY_QA_ANDROID,
  SCANDIT_LICENSE_KEY_PRODUCTION_IOS,
  SCANDIT_LICENSE_KEY_PRODUCTION_ANDROID,
} from '../../webservice/URL';

import { requestCameraPermissionsIfNeeded } from './camera-permission-handler';
import DeviceInfo from 'react-native-device-info';
import ContextSingleton from './ContextSingleton';
import { EventRegister } from 'react-native-event-listeners';
import base64FlashLightOffString from './FlashLightOffData';
import base64FlashLightOnString from './FlashLighOnData';

let deviceWidth = Dimensions.get('window').width;
let deviceHeight = Dimensions.get('window').height;



export default class ScanditScannerDataCapture extends Component {
  static propTypes = {
    onBarCodeRead: PropTypes.func,
    isPopUpScanner: PropTypes.bool,
    isRectangularViewScanner : PropTypes.bool,
    isFromSharpenZone : PropTypes.bool,
    isLandscape : PropTypes.bool,
    isScannerPause : PropTypes.bool,
    isFromInjectionZone: PropTypes.bool,
  };
 

  static defaultProps = {
    isPopUpScanner: false,
    isRectangularViewScanner :false,
    isFromSharpenZone : false,
    isLandscape :false,
    isScannerPause: true,
    isFromInjectionZone : false,
  };

  constructor(props) {
    super(props);
    this.state ={
      isLandscape : false,
    };

    this.dataCaptureContext = ContextSingleton.instance.getDataCaptureContext();
    this.viewRef = React.createRef();
  }


  componentWillMount() {
    this.listener = EventRegister.addEventListener('onScanditScannerResume', (data) => {
      this.barcodeCaptureMode.isEnabled = true;
    });
    this.listener = EventRegister.addEventListener('onRemoveScanditListener', (data) => {
      console.log('componentWillMount ==onRemoveScanditListener called ======');
      this.componentWillUnmount();
    });
  }

  async componentDidMount() {
    // window.EventBus.on('onScanditScannerResume', this._scanditScannerResumEventHandlerFunc.bind(this));
    // Events.on('onScanditScannerResume', 'Scandit', this._scanditScannerResumEventHandlerFunc.bind(this));
    this.listener = EventRegister.addEventListener('onRemoveScanditListener', (data) => {
      console.log('componentDidMount ==onRemoveScanditListener called ======');
      this.componentWillUnmount();
    });
    AppState.addEventListener('change', this.handleAppStateChange);
   
    // AppState.addEventListener('change', this.handleAppStateChange);
    const hasPermission = await this.hasCameraPermission();
    if (hasPermission) {
      this.cameraPermissionGranted();
    } else {
      await this.requestCameraPermission();
    }
    this.setupScanning();
    this.startCapture();
    this.camera.desiredTorchState = TorchState.On;

  }

  componentWillReceiveProps(nextProps){
    if (nextProps.isRectangularViewScanner) {
      if (nextProps.isLandscape) {
        deviceWidth = Dimensions.get('window').width;
        deviceHeight = Dimensions.get('window').height;    
      }else {
        deviceWidth = Dimensions.get('window').width;
        deviceHeight = Dimensions.get('window').height; 
      }
    }
  }

  componentWillUnmount() {
    // this.appStateEventListener.remove();
    console.log(' this.barcodeCaptureMode===', this.barcodeCaptureMode);
      if(this.barcodeCaptureMode != undefined) {
        this.stopCapture();
        this.barcodeCaptureMode.removeListener(this.barcodeCaptureListener);
      }

    EventRegister.removeEventListener(this.listener);
    this.dataCaptureContext.removeAllModes();
    this.viewRef.current.removeOverlay(this.overlay);
    AppState.removeEventListener('change', this.handleAppStateChange);

    // window.EventBus.off('onScanditScannerResume');
    // Events.remove('onScanditScannerResume', 'Scandit');
    // this.dataCaptureContext.dispose();
  }


  cameraPermissionGranted() {
    // this.appStateEventListener = AppState.addEventListener('change', this.handleAppStateChange);
    AppState.addEventListener('change', this.handleAppStateChange);
  }

      
  // _scanditScannerResumEventHandlerFunc() {
  //   this.setupScanning();
  //   this.startCapture();
  // }
    
  // This method should only be called if the Platform.OS is android.
  cameraPermissionDenied() {
    BackHandler.exitApp();
  }
  

  async requestCameraPermission() {
    if (Platform.OS === 'android') {
      try {
        global.isAlertShowing = true;
        const granted = await PermissionsAndroid.request(PermissionsAndroid.PERMISSIONS.CAMERA);
        if (granted === PermissionsAndroid.RESULTS.GRANTED) {
          this.cameraPermissionGranted();
        } else {
          this.cameraPermissionDenied();
        }
        setTimeout(() => {
          global.isAlertShowing = false;
        }, 100);
      } catch (err) {
        setTimeout(() => {
          global.isAlertShowing = false;
        }, 100);
        console.warn(err);
      }
    } else {
      this.cameraPermissionGranted();
    }
  }
 
  async hasCameraPermission() {
    if (Platform.OS === 'android') {
      const granted = await PermissionsAndroid.check(PermissionsAndroid.PERMISSIONS.CAMERA);
      return granted;
    } else {
      return true;
    }
  }

  handleAppStateChange = async (nextAppState) => {
    if (nextAppState.match(/inactive|background/)) {
      this.stopCapture();
    } else {
      this.startCapture();
      this.camera.desiredTorchState = TorchState.Off;
    }
  }

  startCapture() {
    this.startCamera();
    this.barcodeCaptureMode.isEnabled = true;
  }

  stopCapture() {
      this.barcodeCaptureMode.isEnabled = false;
      this.stopCamera();
  }

  stopCamera() {
    if (this.camera) {
      this.camera.switchToDesiredState(FrameSourceState.Off);
    }
  }

  startCamera() {
    if (!this.camera) {
      // Use the world-facing (back) camera and set it as the frame source of the context. The camera is off by
      // default and must be turned on to start streaming frames to the data capture context for recognition.
      this.camera = Camera.default;
      this.dataCaptureContext.setFrameSource(this.camera);

      const cameraSettings = new CameraSettings();
      cameraSettings.preferredResolution = VideoResolution.FullHD;
      this.camera.applySettings(cameraSettings);
    }

    // Switch camera on to start streaming frames and enable the barcode capture mode.
    // The camera is started asynchronously and will take some time to completely turn on.
    requestCameraPermissionsIfNeeded()
      .then(() => this.camera.switchToDesiredState(FrameSourceState.On))
      .catch(() => BackHandler.exitApp());
  }

  setupScanning() {
    // The barcode capturing process is configured through barcode capture settings
    // and are then applied to the barcode capture instance that manages barcode recognition.
    const settings = new BarcodeCaptureSettings();

    // The settings instance initially has all types of barcodes (symbologies) disabled. For the purpose of this
    // sample we enable a very generous set of symbologies. In your own app ensure that you only enable the
    // symbologies that your app requires as every additional enabled symbology has an impact on processing times.
    settings.enableSymbologies([
      Symbology.EAN13UPCA,
      Symbology.EAN8,
      Symbology.UPCE,
      Symbology.QR,
      Symbology.DataMatrix,
      Symbology.Code39,
      Symbology.Code128,
      Symbology.Code93,
      Symbology.Code11,
      Symbology.Code25,
      Symbology.Codabar,
      Symbology.MSIPlessey,
      Symbology.Aztec,
      Symbology.MaxiCode,
      Symbology.DotCode,
      Symbology.KIX,
      Symbology.RM4SCC,
      Symbology.GS1Databar,
      Symbology.GS1DatabarExpanded,
      Symbology.GS1DatabarLimited,
      Symbology.PDF417,
      Symbology.MicroPDF417,
      Symbology.MicroQR,
      Symbology.Code32,
      Symbology.Lapa4SC,
      Symbology.IATATwoOfFive,
      Symbology.MatrixTwoOfFive,
      Symbology.USPSIntelligentMail,
      Symbology.InterleavedTwoOfFive,
    ]);

    // Some linear/1d barcode symbologies allow you to encode variable-length data. By default, the Scandit
    // Data Capture SDK only scans barcodes in a certain length range. If your application requires scanning of one
    // of these symbologies, and the length is falling outside the default range, you may need to adjust the "active
    // symbol counts" for this symbology. This is shown in the following few lines of code for one of the
    // variable-length symbologies.
    const symbologySettings = settings.settingsForSymbology(Symbology.Code128);
    symbologySettings.activeSymbolCounts = [4,5,6,7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20,21,22,23,24,25,26,27,28,29,30,31,
      32,33,34,35,36,37,38,39,40];
    // symbologySettings.activeSymbolCounts = [6, 7, 8];
    // Create new barcode capture mode with the settings from above.
    this.barcodeCaptureMode = BarcodeCapture.forContext(this.dataCaptureContext, settings);

    // Register a listener to get informed whenever a new barcode got recognized.
    this.barcodeCaptureListener = {
      didScan: (_, session) => {
        const barcode = session.newlyRecognizedBarcodes[0];
        const symbology = new SymbologyDescription(barcode.symbology);

        // The `alert` call blocks execution until it's dismissed by the user. As no further frames would be processed
        // until the alert dialog is dismissed, we're showing the alert through a timeout and disabling the barcode
        // capture mode until the dialog is dismissed, as you should not block the BarcodeCaptureListener callbacks for
        // longer periods of time. See the documentation to learn more about this.
        this.barcodeCaptureMode.isEnabled = false;
      
        this.props.onBarCodeRead(barcode.data);
        // Alert.alert(
        //   null,
        //   `Scanned: ${barcode.data} (${symbology.readableName})`,
        //   [{ text: 'OK', onPress: () => this.barcodeCaptureMode.isEnabled = true }],
        //   { cancelable: false }
        // );
      },
    };

    this.barcodeCaptureMode.addListener(this.barcodeCaptureListener);

    // Add a barcode capture overlay to the data capture view to render the location of captured barcodes on top of
    // the video preview, using the Frame overlay style. This is optional, but recommended for better visual feedback.
    this.overlay = BarcodeCaptureOverlay.withBarcodeCaptureForViewWithStyle(
      this.barcodeCaptureMode,
      this.viewRef.current,
      BarcodeCaptureOverlayStyle.Frame
    );
    // this.overlay.viewfinder = new RectangularViewfinder(
    //   RectangularViewfinderStyle.Square,
    //   RectangularViewfinderLineStyle.Light,
    // );
    this.overlay.viewfinder = new RectangularViewfinder(
      RectangularViewfinderStyle.Legacy,
    );
  
    const size = new SizeWithUnit(
      new NumberWithUnit(0.9, MeasureUnit.Fraction),
      new NumberWithUnit(0.9, MeasureUnit.Fraction)
    );
  
    this.overlay.viewfinder.setSize(size);

    this.torchControl = new TorchSwitchControl();
    this.torchControl.torchOffImage = base64FlashLightOffString;
    this.torchControl.torchOnImage = base64FlashLightOnString;
    this.torchControl.torchOnPressedImage  = base64FlashLightOnString;
    this.torchControl.torchOffPressedImage = base64FlashLightOffString ; 
    this.viewRef.current.addControl(this.torchControl);

    this.overlay = this.overlay;
  }
  onLayout(e) {
    deviceWidth = Dimensions.get('window').width;
    deviceHeight = Dimensions.get('window').height;
    if (deviceWidth > deviceHeight) {
      this.setState({isLandscape: true});
    } else {
      this.setState({isLandscape: false});
    }
  }

  render() {
    const { isPopUpScanner, isRectangularViewScanner,  isFromSharpenZone, isFromInjectionZone} = this.props;

    return (
      <View 
        style={{
          flex: 1, alignItems:'center', justifyContent:'center',
          flexDirection: 'column'}}
        onLayout={this.onLayout.bind(this)}
      >
        <View style={{
          height: (isRectangularViewScanner) ? (isFromSharpenZone || isFromInjectionZone) ? 200 : 160 : (this.state.isLandscape) ? (isPopUpScanner) ? deviceWidth/2.2 : (Platform.OS === 'android') ? deviceWidth/ 4.4 :deviceWidth/ 3.4 : (isPopUpScanner) ? deviceHeight/2.2 : deviceHeight/2.9,
          width:(isRectangularViewScanner) ? (this.state.isLandscape) ? deviceWidth : deviceWidth : (this.state.isLandscape) ? deviceHeight / 1.4 : deviceWidth/1.4,
        }}
        >       
          <DataCaptureView style={{ flex: 1 }} context={this.dataCaptureContext} ref={this.viewRef} />
        </View>
         
      </View>
    ); 
  }
}
