package com.InnovaZones.RNTreeIZHips;

import android.os.Handler;
import android.widget.Toast;
import com.facebook.react.ReactActivity;
import android.util.Log;
import android.widget.Toast;
import android.os.Bundle;

import com.facebook.react.BuildConfig;
import com.facebook.react.ReactActivity;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.WritableMap;
import com.socketmobile.capture.android.Capture;
import com.socketmobile.capture.client.ConnectionState;
import com.socketmobile.capture.client.DataEvent;
import com.socketmobile.capture.client.DeviceClient;

import org.greenrobot.eventbus.Subscribe;
import org.greenrobot.eventbus.ThreadMode;

import static com.InnovaZones.RNTreeIZHips.nativemodules.SocketScannerModule.sendEvent;

public class MainActivity extends ReactActivity {


    boolean isBackPressed = false;

    /**
     * Returns the name of the main component registered from JavaScript.
     * This is used to schedule rendering of the component.
     */
    @Override
    protected String getMainComponentName() {
        return "InnovaZones";
    }

    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        Capture.builder(getApplicationContext())
                .enableLogging(Log.DEBUG)
                .build();
    }
//
//
//    @Subscribe()
//    public void onConnectionStateChanged(ConnectionState state){
//        ConnectionState st = state;
//    }
//
//    @Subscribe()
//    public  void onDeviceStateEvent(ConnectionState state){
//        ConnectionState st = state;
//    }
//
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

    @Override
    public void invokeDefaultOnBackPressed() {
        if (isBackPressed) {
            System.exit(0);
            return;
        }else{
            isBackPressed = true;
            Toast.makeText(this,"Tap once again to exit",Toast.LENGTH_LONG).show();
            new Handler().postDelayed(new Runnable() {

                @Override
                public void run() {
                    isBackPressed = false;
                }
            }, 3000);
        }
    }
}



