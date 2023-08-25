package com.InnovaZones.RNTreeIZHips.nativemodules;


import androidx.annotation.Nullable;
import android.util.Log;
import android.widget.TextView;

import com.InnovaZones.RNTreeIZHips.Constant;
import com.facebook.react.BuildConfig;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.modules.core.DeviceEventManagerModule;
import com.socketmobile.capture.AppKey;
import com.socketmobile.capture.CaptureError;
import com.socketmobile.capture.android.Capture;
import com.socketmobile.capture.client.CaptureClient;
import com.socketmobile.capture.client.ConnectionCallback;
import com.socketmobile.capture.client.ConnectionState;
import com.socketmobile.capture.client.DataEvent;
import com.socketmobile.capture.client.DeviceClient;
import com.socketmobile.capture.client.DeviceState;
import com.socketmobile.capture.client.DeviceStateEvent;

import org.greenrobot.eventbus.Subscribe;
import org.greenrobot.eventbus.ThreadMode;
import org.json.JSONException;
import org.json.JSONObject;


public class SocketScannerModule extends ReactContextBaseJavaModule {

    public static ReactApplicationContext mReactContext;

    String scanType = null;

    public SocketScannerModule(ReactApplicationContext reactContext) {
        super(reactContext);
        this.mReactContext = reactContext;
    }

    @Override
    public String getName() {
        return "SocketScannerModule";
    }

    @ReactMethod
    public void startScoketScan(String strInput){
        try {
        JSONObject mInputObj = new JSONObject(strInput);
        scanType = mInputObj.getString("scanType");

//            AppKey appkey = new AppKey("MCwCFADxGsI+7GcBRBBHku1LfoFiNSunAhQ1m+UTVHXvAlles9wrnieSkW/6sg==",
//                    "android:com.InnovaZones.RNTreeIZHips",
//                    "5ea16148-b842-ea11-a812-000d3a378f47");
//            CaptureClient client = new CaptureClient(appkey);

//        Capture.builder(getCurrentActivity().getApplicationContext())
//                .enableLogging(BuildConfig.DEBUG)
//                .build();

            WritableMap params = Arguments.createMap();
            params.putString("type", "DEVICE_CONNECTED_STATUS");
            params.putString("deviceName", "MP-Scanner");
            params.putString("response", "Scocket scanner Initiated");
            sendEvent(Constant.SOCKET_SCANNER_EVENT_PRODUCT, params);

//        AppKey appkey = new AppKey("android:com.InnovaZones.RNTreeIZHips", "MCwCFDuTPKXnog6KvJQDnHUCJhKUZyHFAhR7KaNXet8TSLm8C3orQzGkJet+Bg==", "5ea16148-b842-ea11-a812-000d3a378f47");
//        CaptureClient client = new CaptureClient(appkey);
//        client.setListener(new CaptureClient.Listener() {
//            @Override
//            public void onDeviceStateEvent(DeviceStateEvent event) {
////                mDevice = event.getDevice();
//                DeviceState state = event.getState();
//                switch (state.intValue()) {
//                    case DeviceState.GONE:
//                        // Scanner is gone
//                        break;
//                    case DeviceState.AVAILABLE:
//                        // Scanner is connected to the service. You can choose to open the device or not.
//                        break;
//                    case DeviceState.OPEN:
//                        // Scanner is open, but you do not have control of it. It may be in the process of
//                        // opening or another application may have opened the scanner.
//                        break;
//                    case DeviceState.READY:
//                        // Scanner is ready. Configure scanner
//                        break;
//                }
//            }
//
//            @Override
//            public void onData(DataEvent dataEvent) {
//            String data = dataEvent.getData().getString();
//            String dataSource = dataEvent.getData().getDataSource().getName();
//            WritableMap params = Arguments.createMap();
//            params.putString("type", "SCANNED_VALUE");
//            params.putString("deviceName", "");
//            params.putString("response", data);
//            sendEvent(Constant.SOCKET_SCANNER_EVENT_PRODUCT, params);
//
//            }
//
//            @Override
//            public void onError(CaptureError captureError) {
//
//            }
//        });
//        client.connect(new ConnectionCallback() {
//            @Override
//            public void onConnectionStateChanged(ConnectionState state) {
//                if (state.isReady()) {
//
//                }else if(state.isConnected()) {
//                    WritableMap params = Arguments.createMap();
//                    params.putString("type", "DEVICE_CONNECTED_STATUS");
//                    params.putString("deviceName", "");
//                    params.putString("response", "Connected");
//                    sendEvent(Constant.SOCKET_SCANNER_EVENT_PRODUCT, params);
//                } else if (state.isDisconnected()) {
//                    WritableMap params1 = Arguments.createMap();
//                    params1.putString("type", "DEVICE_CONNECTED_STATUS");
//                    params1.putString("deviceName", "");
//                    params1.putString("response", "DisConnected");
//                    sendEvent(Constant.SOCKET_SCANNER_EVENT_PRODUCT, params1);
//                }
//            }
//        });
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

//    @Subscribe(threadMode = ThreadMode.MAIN)
//    public void onScan(DataEvent event) {
//        String data = event.getData().getString();
//        String dataSource = event.getData().getDataSource().getName();
//    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onData(DataEvent event) {
        String data = event.getData().getString();
        String dataSource = event.getData().getDataSource().getName();
        WritableMap params = Arguments.createMap();
        params.putString("type", "SCANNED_VALUE");
        params.putString("deviceName", "");
        params.putString("response", data);
        sendEvent(Constant.SOCKET_SCANNER_EVENT_PRODUCT, params);
    }

    @Subscribe(threadMode = ThreadMode.MAIN, sticky = true)
    public void onCaptureDeviceStateChange(DeviceStateEvent event) {
        DeviceClient device = event.getDevice();
        DeviceState state = event.getState();

        switch(state.intValue()) {
            case DeviceState.READY:
                // Ready to use
                WritableMap params = Arguments.createMap();
                params.putString("type", "DEVICE_CONNECTED_STATUS");
                params.putString("deviceName", "");
                params.putString("response", "Connected");
                sendEvent(Constant.SOCKET_SCANNER_EVENT_PRODUCT, params);
                break;
            case DeviceState.GONE:
                // Device disconnecetd
                WritableMap params1 = Arguments.createMap();
                params1.putString("type", "DEVICE_CONNECTED_STATUS");
                params1.putString("deviceName", "");
                params1.putString("response", "DisConnected");
                sendEvent(Constant.SOCKET_SCANNER_EVENT_PRODUCT, params1);
                break;
            default:
                // Device not ready for use
        }
    }


    public static void sendEvent(String eventName,
                                 @Nullable WritableMap params) {
        try {
            mReactContext
                    .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
                    .emit(eventName, params);
        }catch (Exception e){
            e.printStackTrace();
        }
    }

}
