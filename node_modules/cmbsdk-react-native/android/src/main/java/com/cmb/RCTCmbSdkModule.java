
package com.cmb;

import static com.cmb.RCTCmbEvent.CMBEvent.COMMAND_COMPLETED;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.pm.PackageManager;
import android.os.Handler;
import android.os.Looper;

import com.cognex.cmbcrossplatform.CCPBridge;
import com.cognex.cmbcrossplatform.interfaces.APIResponseListener;
import com.cognex.cmbcrossplatform.interfaces.PermissionBridgeListener;
import com.cognex.cmbcrossplatform.interfaces.ReaderDeviceBridgeListener;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.LifecycleEventListener;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.modules.core.DeviceEventManagerModule;
import com.facebook.react.modules.core.PermissionAwareActivity;
import com.manateeworks.BarcodeScanner;

import org.json.JSONException;
import org.json.JSONObject;

public class RCTCmbSdkModule extends ReactContextBaseJavaModule {

    private final ReactApplicationContext reactContext;

    private CCPBridge ccpBridge;
    private AlertDialog connectingAlert;

    LifecycleEventListener lifecycleEventListener = new LifecycleEventListener() {
        @Override
        public void onHostResume() {
            ccpBridge = new CCPBridge(getCurrentActivity(), readerDeviceBridgeListener, permissionBridgeListener);
            getReactApplicationContext().removeLifecycleEventListener(lifecycleEventListener);
        }

        @Override
        public void onHostPause() {
        }

        @Override
        public void onHostDestroy() {
        }
    };

    public RCTCmbSdkModule(ReactApplicationContext reactContext) {
        super(reactContext);
        this.reactContext = reactContext;

        getReactApplicationContext().addLifecycleEventListener(lifecycleEventListener);
    }

    // Permission
    private PermissionAwareActivity getPermissionAwareActivity() {
        Activity activity = getCurrentActivity();
        if (activity == null) {
            throw new IllegalStateException("Tried to use permissions API while not attached to an " +
                    "Activity.");
        } else if (!(activity instanceof PermissionAwareActivity)) {
            throw new IllegalStateException("Tried to use permissions API but the host Activity doesn't" +
                    " implement PermissionAwareActivity.");
        }
        return (PermissionAwareActivity) activity;
    }

    PermissionBridgeListener permissionBridgeListener = new PermissionBridgeListener() {
        @Override
        public void requestPermission(String[] permissions, int requestCode) {
            try {
                getPermissionAwareActivity().requestPermissions(permissions, requestCode, (requestCode1, permissions1, grantResults) -> {
                    if (requestCode1 == CCPBridge.CAMERA_REQUEST_PERMISSION_CODE) {
                        if (grantResults.length > 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                            ccpBridge.connect(null);
                        }
                    }
                    return false;
                });
            } catch (Exception ignored) {
            }
        }
    };

    ReaderDeviceBridgeListener readerDeviceBridgeListener = new ReaderDeviceBridgeListener() {
        @Override
        public void connectionStateChanged(int connectionState) {
            new RCTCmbEvent(RCTCmbEvent.CMBEvent.CONNECTION_STATE_CHANGED, connectionState).sendUsingEmitter(getEmitter());
        }

        @Override
        public void readResultReceived(JSONObject result) {
            try {
                // In RCT, we use different keys for the result object than in CCP
                // Replace keys:
                // results -> readResults
                // subResults -> subReadResults
                result.put("readResults", result.getJSONArray("results"));
                result.put("subReadResults", result.getJSONArray("subResults"));
                result.remove("results");
                result.remove("subResults");

                WritableMap resultMap = RCTCmbUtility.convertJsonToMap(result);
                new RCTCmbEvent(RCTCmbEvent.CMBEvent.READ_RESULT_RECEIVED, resultMap).sendUsingEmitter(getEmitter());
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        @Override
        public void availabilityChanged(int availability) {
            new RCTCmbEvent(RCTCmbEvent.CMBEvent.AVAILABILITY_CHANGED, availability).sendUsingEmitter(getEmitter());
        }

        @Override
        public void scanningStateChanged(boolean state) {
            new RCTCmbEvent(RCTCmbEvent.CMBEvent.SCANNING_STATE_CHANGED, state).sendUsingEmitter(getEmitter());
        }
    };

    @Override
    public String getName() {
        return "RCTCmbSdk";
    }

    // Response helpers
    private APIResponseListener createResponseListener( final Promise apResult) {
        return new APIResponseListener() {
            @Override
            public void successWithObject(Object result) {
                apResult.resolve(result);
            }

            @Override
            public void error(String errorCode, String errorMessage) {
                apResult.reject(errorCode, errorMessage);
            }
        };
    }

    // Command event response
    private APIResponseListener createCommandResponseListener( final String commandID,  final String eventType,  final String command) {

        WritableMap eventBody = Arguments.createMap();
        eventBody.putString(RCTCmbEvent.CMBEventKey.CMD_ID.toString(), commandID);
        eventBody.putString(RCTCmbEvent.CMBEventKey.EVENT_TYPE.toString(), eventType);
        if (command != null)
            eventBody.putString(RCTCmbEvent.CMBEventKey.CMD.toString(), command);

        return new APIResponseListener() {
            @Override
            public void successWithObject(Object result) {
                eventBody.putBoolean(RCTCmbEvent.CMBEventKey.SUCCESS.toString(), true);

                if (result instanceof String) {
                    eventBody.putString(RCTCmbEvent.CMBEventKey.MESSAGE.toString(), (String) result);
                } else if (result instanceof Boolean) {
                    eventBody.putBoolean(RCTCmbEvent.CMBEventKey.MESSAGE.toString(), (Boolean) result);
                } else if (result instanceof Integer) {
                    eventBody.putInt(RCTCmbEvent.CMBEventKey.MESSAGE.toString(), (Integer) result);
                } else if (result instanceof Double) {
                    eventBody.putDouble(RCTCmbEvent.CMBEventKey.MESSAGE.toString(), (Double) result);
                }

                new RCTCmbEvent(COMMAND_COMPLETED, eventBody).sendUsingEmitter(getEmitter());
            }

            @Override
            public void error(String errorCode, String errorMessage) {
                eventBody.putBoolean(RCTCmbEvent.CMBEventKey.SUCCESS.toString(), false);
                eventBody.putString(RCTCmbEvent.CMBEventKey.MESSAGE.toString(), errorMessage);

                new RCTCmbEvent(COMMAND_COMPLETED, eventBody).sendUsingEmitter(getEmitter());
            }
        };
    }

    //Custom API methods
    @ReactMethod
    private void loadScanner(final int deviceType, final Promise promise) {
        ccpBridge.loadScanner(createResponseListener(promise), deviceType);
    }

    @ReactMethod
    private void connect(final Promise promise) {
        ccpBridge.connect(createResponseListener(promise));
    }

    @ReactMethod
    private void disconnect(final Promise promise) {
        ccpBridge.disconnect(createResponseListener(promise));
    }

    @ReactMethod
    private void startScanning(final Promise promise) {
        ccpBridge.startScanning(createResponseListener(promise));
    }

    @ReactMethod
    private void stopScanning(final Promise promise) {
        ccpBridge.stopScanning(createResponseListener(promise));
    }

    @ReactMethod
    private void setSymbology(int symbology, boolean enable, final String cmdIdentifier) {
        ccpBridge.setSymbologyEnabled(createCommandResponseListener(cmdIdentifier, "setSymbology", null), symbology, enable);
    }

    @ReactMethod
    private void isSymbologyEnabled(int symbology, final String cmdIdentifier) {
        ccpBridge.isSymbologyEnabled(createCommandResponseListener(cmdIdentifier, "isSymbologyEnabled", null), symbology);
    }

    @ReactMethod
    private void setCameraMode(int cameraMode) {
        ccpBridge.setCameraMode(cameraMode);
    }

    @ReactMethod
    private void setPreviewOptions(int previewOptions) {
        ccpBridge.setPreviewOptions(previewOptions);
    }

    @ReactMethod
    public void setPreviewOverlayMode(int arg) {
        ccpBridge.setPreviewOverlayMode(arg);
    }

    @ReactMethod
    public void setPreviewContainerPositionAndSize(ReadableArray args) {
        int x = args.getInt(0);
        int y = args.getInt(1);
        int width = args.getInt(2);
        int height = args.getInt(3);

        new Handler(Looper.getMainLooper()).post(() -> {
            ccpBridge.setPreviewContainerPositionAndSize(x, y, width, height);
        });
    }

    @ReactMethod
    private void setLightsOn(boolean on, final Promise promise) {
        ccpBridge.setLightsOn(createResponseListener(promise), on);
    }

    @ReactMethod
    private void isLightsOn(final Promise promise) {
        ccpBridge.isLightsOn(createResponseListener(promise));
    }

    @ReactMethod
    private void enableImage(boolean arg, Promise promise) {
        ccpBridge.enableImage(createResponseListener(promise), arg);
    }

    @ReactMethod
    private void enableImageGraphics(boolean arg, Promise promise) {
        ccpBridge.enableImageGraphics(createResponseListener(promise), arg);
    }

    @ReactMethod
    private void sendCommand(final String commandString, final String cmdIdentifier) {
        ccpBridge.sendCommand(createCommandResponseListener(cmdIdentifier, "command", commandString), commandString);
    }

    @ReactMethod
    private void resetConfig(final Promise promise) {
        ccpBridge.resetConfig(createResponseListener(promise));
    }

    @ReactMethod
    private void registerSDK(String key) {
        ccpBridge.registerSDK(key);
    }

    @ReactMethod
    private void getAvailability(Promise promise) {
        ccpBridge.getAvailability(createResponseListener(promise));
    }

    @ReactMethod
    private void getConnectionState(Promise promise) {
        ccpBridge.getConnectionState(createResponseListener(promise));
    }

    @ReactMethod
    private void beep(Promise promise) {
        ccpBridge.beep(createResponseListener(promise));
    }

    @ReactMethod
    private void getDeviceBatteryLevel(final Promise promise) {
        ccpBridge.getDeviceBatteryLevel(createResponseListener(promise));
    }

    @ReactMethod
    private void getSdkVersion(final Promise promise) {
        ccpBridge.getSdkVersion(createResponseListener(promise));
    }

    @ReactMethod
    public void setPreviewContainerFullScreen() {
        ccpBridge.setPreviewContainerFullScreen(null);
    }

    @ReactMethod
    public void setStopScannerOnRotate(boolean arg) {
        ccpBridge.setStopScannerOnRotate(arg);
    }

    @ReactMethod
    private void enableCameraFlag(ReadableMap arg, Promise promise) {
        editCameraFlag(arg, promise, true);
    }

    @ReactMethod
    private void disableCameraFlag(ReadableMap arg, Promise promise) {
        editCameraFlag(arg, promise, false);
    }

    private void editCameraFlag(ReadableMap arg, Promise promise, boolean enable) {
        int mask = arg.getInt("codeMask");
        int flag = arg.getInt("flag");

        ccpBridge.editCameraFlag(createResponseListener(promise), mask, flag, enable);
    }

    @ReactMethod
    private void setParser(int arg, Promise promise) {
        ccpBridge.setParser(createResponseListener(promise), arg);
    }

    @ReactMethod
    private void setReadStringEncoding(int arg, Promise promise) {
        ccpBridge.setReadStringEncoding(createResponseListener(promise), arg);
    }

    @ReactMethod
    public void getCameraExposureCompensationRange(Promise promise) {
        ccpBridge.getCameraExposureCompensationRange(createResponseListener(promise));
    }

    @ReactMethod
    public void setCameraExposureCompensation(float arg, Promise promise) {
        ccpBridge.setCameraExposureCompensation(createResponseListener(promise), arg);
    }

    @ReactMethod
    private void setCameraParam(ReadableMap arg, Promise promise) {
        int mask = arg.getInt("codeMask");
        int param = arg.getInt("param");
        int value = arg.getInt("value");

        int result = BarcodeScanner.MWBsetParam(mask, param, value);
        if (result == BarcodeScanner.MWB_RT_OK) {
            promise.resolve("");
        } else {
            String resultAsString = String.valueOf(result);
            promise.reject(resultAsString, resultAsString);
        }
    }

    @ReactMethod
    private void imageFromSVG(String svg, final Promise promise) {
        String image = RCTCmbUtility.base64ImageFromSVG(svg);
        if (image != null) {
            promise.resolve(image);
        } else {
            promise.reject("0", "Failed to convert svg to image");
        }
    }

    @ReactMethod
    private void toggleConnectionAlert(boolean arg) {
        if (arg) {
            if (connectingAlert == null) {
                final Activity activity = getCurrentActivity();
                if (activity != null) {
                    activity.runOnUiThread(() -> {
                        AlertDialog.Builder connectingAlertBuilder = new AlertDialog.Builder(activity);
                        connectingAlertBuilder
                                .setTitle("Connecting")
                                .setMessage("Please wait...")
                                .setCancelable(false);
                        connectingAlert = connectingAlertBuilder.create();
                        connectingAlert.show();
                    });
                }

            }
        } else {
            if (connectingAlert != null) {
                final Activity activity = getCurrentActivity();
                if (activity != null) {
                    activity.runOnUiThread(() -> {
                        connectingAlert.dismiss();
                        connectingAlert = null;
                    });
                }
            }
        }
    }

    // RCT NativeEventEmitter methods

    private DeviceEventManagerModule.RCTDeviceEventEmitter getEmitter() {
        return reactContext.getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class);
    }

    @ReactMethod
    private void getSupportedEventNames(Callback callback) {
        int totalEvents = RCTCmbEvent.CMBEvent.values().length;

        String[] events = new String[totalEvents];
        for (int i = 0; i < totalEvents; i++) {
            events[i] = RCTCmbEvent.CMBEvent.values()[i].name();
        }

        callback.invoke((Object[]) events);
    }

    @ReactMethod
    public void addListener(String eventName) {
        // Intentionally left blank. This is required by RCT NativeEventEmitter.
    }

    @ReactMethod
    public void removeListeners(Integer count) {
        // Intentionally left blank. This is required by RCT NativeEventEmitter.
    }

}
