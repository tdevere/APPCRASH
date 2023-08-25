package com.InnovaZones.RNTreeIZHips.nativemodules;

import android.app.ProgressDialog;
import android.bluetooth.BluetoothDevice;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Build;
import android.os.Environment;
import android.util.Log;
import android.widget.Toast;

import androidx.annotation.Nullable;
import androidx.localbroadcastmanager.content.LocalBroadcastManager;

import com.InnovaZones.RNTreeIZHips.Constant;
import com.InnovaZones.RNTreeIZHips.CustomReactPackage;
import com.InnovaZones.RNTreeIZHips.serialio.DeviceListRFIDActivity;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.modules.core.DeviceEventManagerModule;
import com.restock.scanners.ScannerParams;
import com.restock.serialdevicemanager.devicemanager.BuiltInScannerSettings;
import com.restock.serialdevicemanager.devicemanager.ScannerCommonParams;
import com.restock.serialdevicemanager.devicemanager.SdmError;
import com.restock.serialdevicemanager.devicemanager.SdmHandler;
import com.restock.serialdevicemanager.devicemanager.SdmSingleton;
import com.restock.serialdevicemanager.devicemanager.SioDevice;
import com.restock.serialdevicemanager.devicemanager.iSdmCallbackDiscoverBluetooth;
import com.restock.serialdevicemanager.devicemanager.iSdmCallbacks;
import com.restock.serialdevicemanager.devicemanager.iSdmHandler;
import com.restock.serialdevicemanager.devicemanager.iSdmHandlerDiscoverBluetooth;
import com.restock.serialdevicemanager.utilssio.SearchableList;
import com.uk.tsl.rfid.asciiprotocol.AsciiCommander;
import com.uk.tsl.rfid.asciiprotocol.device.ReaderManager;
import com.uk.tsl.rfid.asciiprotocol.responders.IAsciiCommandResponder;
import com.uk.tsl.rfid.asciiprotocol.responders.LoggerResponder;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.Timer;
import java.util.TimerTask;


public class RFIDModule extends ReactContextBaseJavaModule {

    public static ReactApplicationContext mReactContext;
    ProgressDialog mProgressDialog;
    private int count = 0;
    String isMultiScan = null;
    String scanType = null;

    // SDM - SerialDeviceManager
    // Instance of interface to send commands to SDM
    iSdmHandler sdmHandler;
    // Instance of interface to do Discovering of Bluetooth devices
    iSdmHandlerDiscoverBluetooth sdmHandlerDiscoverBT;
    //List of devices from the database of previously connected devices
    SearchableList<SioDevice> mKnownDevices;
    //The list of currently connected devices
    SearchableList<SioDevice> mConnectedDevices;
    // Class to process callbacks from SDM
    SearchableList<SioDevice> mLastConnectedDevice;

    SdmCallbacks sdmCallbacks;

    ArrayList<BluetoothDevice> BtDevicesList;

    public static final String SDCARD_PATH = Environment.getExternalStorageDirectory().getAbsolutePath().replace("/mnt", "");  //"/sdcard";
    public static final String FOLDER_NAME = "/SampleSDM_files";
    public static final String FOLDER_PATH = SDCARD_PATH + FOLDER_NAME;
    public static final String LOG_FULLPATH = FOLDER_PATH + "/SampleSDMLog.txt";

    SdmBcastReceiver mSdmBcastReceiver = null;
    IntentFilter mSdmIntentFilter;
    String regKey;
    boolean bProcScanBtDevices = false;


    public interface MyCustomRFIDListener {
        public void onFoundDeviceList(ArrayList<BluetoothDevice> BtDevicesList);

        public void onDeviceState(Boolean deviceStatus, String name);

        public void showProgressbar(Boolean isShowLoading ,String message);
    }

    private MyCustomRFIDListener listener;


    public RFIDModule(ReactApplicationContext reactContext) {
        super(reactContext);
        this.mReactContext = reactContext;
        this.listener = null;
    }

    public void setCustomObjectListener(MyCustomRFIDListener listener) {
        this.listener = listener;
    }

    @Override
    public String getName() {
        return "RFIDModule";
    }

    @ReactMethod
    public void startLoader() {
        getCurrentActivity().runOnUiThread(new Runnable() {
            @Override
            public void run() {
                if (mProgressDialog == null) {
                    mProgressDialog = new ProgressDialog(getCurrentActivity());
                }
                if (mProgressDialog.isShowing()) {
                    mProgressDialog.dismiss();
                }
                mProgressDialog.setMessage("Loading...");
                mProgressDialog.setCancelable(false);
                mProgressDialog.setCanceledOnTouchOutside(false);
                mProgressDialog.show();
            }
        });
    }

    @ReactMethod
    public void stopLoader() {
        getCurrentActivity().runOnUiThread(new Runnable() {
            @Override
            public void run() {
                if (mProgressDialog == null) {
                    mProgressDialog = new ProgressDialog(getCurrentActivity());
                } else {
                    if (mProgressDialog.isShowing()) {
                        mProgressDialog.dismiss();
                    }
                }
            }
        });
    }

    @ReactMethod
    public void openRFIDScannerSettingsView(String strInput) {
        try {
            JSONObject mInputObj = new JSONObject(strInput);
            isMultiScan = mInputObj.getString("isRFIDAutoReconnect");
            scanType = mInputObj.getString("scanType");

            releaseResources();
            Intent selectIntent = new Intent(getReactApplicationContext(), DeviceListRFIDActivity.class);
            selectIntent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            getCurrentActivity().startActivityForResult(selectIntent, DeviceListRFIDActivity.SELECT_DEVICE_REQUEST);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @ReactMethod
    public void startRFIDScanner(String strInput) {
        try {
            JSONObject mInputObj = new JSONObject(strInput);
            isMultiScan = mInputObj.getString("isRFIDAutoReconnect");
            scanType = mInputObj.getString("scanType");
            Log.d("START RFID ******** ", strInput);
//            releaseResources();
//            initapp();
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    public void resultFromActivity(int action, int position) {

        if (action == DeviceListRFIDActivity.DEVICE_INITIAL) {
            initapp();
        } else if (action == DeviceListRFIDActivity.DEVICE_CONNECT) {
            if(listener != null){
                listener.showProgressbar(true,"Connecting");
            }
            deviceConnect(position);
        } else if (action == DeviceListRFIDActivity.DEVICE_DISCONNECT) {
            if(listener != null){
                listener.showProgressbar(true,"Disconnecting");
            }
            disconnectDevice();
        } else if (action == DeviceListRFIDActivity.SCAN_BLUETOOTH_DEVICE) {
            if(listener != null){
                listener.showProgressbar(true,"Searching Devices");
            }
            doScanBluetoothDevices();
        }
    }

    public void reconnectDevice(){
        Log.d(" mLastConnectedDevice *************:",mLastConnectedDevice.toString());

        if (mLastConnectedDevice != null && mLastConnectedDevice.size() > 0){
            SioDevice device = null;
            String name = "";
            String address = "";

            device = mLastConnectedDevice.get(0);
            name = device.getDeviceName();
            address = device.getDeviceAddr();

            if (address != null) {
                String str = String.format("Connect to %s[%s]", name, address);
                AddStrToLog(TYPE_LOG.SEND, str);
                int RetValue = sdmHandler.connect(address, name, 0);
                if (RetValue != SdmError.SUCCESSFUL)
                    AddStrToLog(TYPE_LOG.ERROR, "Connect error:" + SdmError.getErrorString(RetValue));
            }
        }

    }

    public void deviceConnect(int position) {
        sdmHandlerDiscoverBT.stopDiscoverBluetooth();
        BluetoothDevice device = BtDevicesList.get(position);
        String addr = device.getAddress();
        String name = device.getName();
        int sdm_type = BluetoothDevice.DEVICE_TYPE_CLASSIC;
        int sdm_device_type = SioDevice.DEVICE_TYPE_SPP;
        if (Build.VERSION.SDK_INT >= 18) {
            if (sdm_type == BluetoothDevice.DEVICE_TYPE_CLASSIC)
                sdm_device_type = SioDevice.DEVICE_TYPE_SPP;
            else if (sdm_type == BluetoothDevice.DEVICE_TYPE_LE || sdm_type == BluetoothDevice.DEVICE_TYPE_DUAL)
                sdm_device_type = SioDevice.DEVICE_TYPE_BLE;
        }
        if (addr != null) {
            String str = String.format("Connect to %s[%s]", device.getName(), addr);
            AddStrToLog(TYPE_LOG.SEND, str);
            int RetValue = sdmHandler.connect(addr, name, 0);
            if (RetValue != SdmError.SUCCESSFUL)
                AddStrToLog(TYPE_LOG.ERROR, "Connect error:" + SdmError.getErrorString(RetValue));
        }
    }

    private void disconnectDevice() {
        mConnectedDevices = sdmHandler.getConnectedDeviceList();
        int n = mConnectedDevices.size();
        String S = String.format("ConnectedDevices [%d]:", n);
        SioDevice device = null;
        String name = "";
        String Address = "";
        for (int i = 0; i < n; i++) {
            device = mConnectedDevices.get(i);
            name = device.getDeviceName();
            Address = device.getDeviceAddr();
        }
        if (device.getDeviceState() == SioDevice.STATE_CONNECTED) {
            String str = String.format("Disconnect from to %s[%s]", name, Address);
            AddStrToLog(TYPE_LOG.SEND, str);
            int RetValue = sdmHandler.disconnect(Address);
            if (RetValue != SdmError.SUCCESSFUL)
                AddStrToLog(TYPE_LOG.ERROR, "Disconnect error:" + SdmError.getErrorString(RetValue));
        } else {
            AddStrToLog(TYPE_LOG.ERROR, "NO Device Connected");
        }
    }

    public void sendScannedValue(String scanType, String value) {
        Log.d("sendScannedTYPE: ", scanType);
        Log.d("sendScannedValue: ", value);

        WritableMap params = Arguments.createMap();
        params.putString("type", "SCANNED_VALUE");
        params.putString("deviceName", "");
        params.putString("response", value);
        if (scanType.equals(Constant.UHFRFID_SCANTYPE_PRODUCT)) {
            sendEvent(Constant.RFID_EVENT_PRODUCT, params);
        } else if (scanType.equals(Constant.UHFRFID_SCANTYPE_REPORT_ASSET_NO)) {
            sendEvent(Constant.RFID_EVENT_REPORT_ASSET_NO, params);
        } else if (scanType.equals(Constant.UHFRFID_SCANTYPE_CART)) {
            sendEvent(Constant.RFID_EVENT_CART, params);
        } else if (scanType.equals(Constant.UHFRFID_SCANTYPE_UNIFORM_ASSET_NO)) {
            sendEvent(Constant.RFID_EVENT_UNIFORM_ASSET_NO, params);
        } else if (scanType.equals(Constant.UHFRFID_SCAN_TYPE_ENROLL)) {
            sendEvent(Constant.RFID_ENROLL_SCANNED_TEXT, params);
        } else if (scanType.equals(Constant.UHFRFID_SCAN_TYPE_LOGIN)) {
            sendEvent(Constant.RFID_LOGIN_SCANNED_TEXT, params);
        }
    }

    public static void sendEvent(String eventName,
                                 @Nullable WritableMap params) {
        Log.d("sendEventSTART", "");
        try {
            mReactContext
                    .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
                    .emit(eventName, params);
        } catch (Exception e) {
            Log.d("sendEventERROR", e.toString());
            e.printStackTrace();
        }
    }


    @ReactMethod
    public void test() {
        new Timer().scheduleAtFixedRate(new TimerTask() {
            @Override
            public void run() {
                count++;
                System.out.println("Count Value " + count);
                if (listener != null) {
//                    listener.onDataLoaded(String.valueOf(count));
                }
//                sendEvent("count", String.valueOf(count));
            }
        }, 0, 1000);
    }

    public enum TYPE_LOG {
        SEND, RECEIVE, INFO, ERROR
    }

    public void AddStrToLog(TYPE_LOG type, String s) {
        String line = "";
        if (s != null) {
            String sid = "I";
            String sid1 = "";
            switch (type) {
                case SEND:
                    sid = "S";
                    sid1 = ">";
                    break;
                case RECEIVE:
                    sid = "R";
                    sid1 = "<";
                    break;
                case INFO:
                    sid = "I";
                    sid1 = "";
                    break;
                case ERROR:
                    sid = "E";
                    sid1 = "";
                    break;
            }
            line = sid1 + s;
            String ss = String.format("%s%s", sid, line);
            Log.d("AddStrToLog", ss);
        }
    }

    void initapp() {

        if(mSdmBcastReceiver == null) {
            mSdmIntentFilter = new IntentFilter(iSdmCallbacks.SDM_MESSAGE_INIT_IS_FINISHED);
            mSdmIntentFilter.addAction(iSdmCallbacks.SDM_MESSAGE_BUILTIN_READER_INITIALISED);
            mSdmIntentFilter.addAction(iSdmCallbacks.SDM_MESSAGE_SCANNER_SETUP_START);
            mSdmIntentFilter.addAction(iSdmCallbacks.SDM_MESSAGE_SCANNER_SETUP_DONE_RESULT);
            mSdmIntentFilter.addAction(iSdmCallbacks.SDM_MESSAGE_ERROR);
            mSdmIntentFilter.addAction(iSdmCallbacks.SDM_MESSAGE_PROGRESS);
            mSdmIntentFilter.addAction(iSdmCallbacks.SDM_MESSAGE_TEXT_INFO);
            mSdmIntentFilter.addAction(iSdmCallbacks.SDM_MESSAGE_DATA_FILTERED);
            mSdmIntentFilter.addAction(iSdmCallbacks.SDM_MESSAGE_BATTERY_LEVEL);
            mSdmIntentFilter.addAction(iSdmCallbacks.SDM_MESSAGE_DEVICE_LIST_UPDATED);
            mSdmIntentFilter.addAction(iSdmCallbacks.SDM_MESSAGE_SCANNER_SETTINGS_UPDATED);
            mSdmIntentFilter.addAction(iSdmCallbacks.SDM_MESSAGE_COMMON_SETTINGS_UPDATED);
            mSdmIntentFilter.addAction(iSdmCallbacks.SDM_BLUETOOTH_STATE);
            mSdmIntentFilter.addAction(iSdmCallbacks.SDM_MESSAGE_DEVICE_FW);
            mSdmIntentFilter.addAction(iSdmCallbacks.SDM_MESSAGE_DEVICE_SN);
            mSdmIntentFilter.addAction(iSdmCallbacks.SDM_MESSAGE_SELECTED_DEVICE);
            mSdmIntentFilter.addAction(iSdmCallbacks.SDM_MESSAGE_STREAM_MONITOR_STATE);
            mSdmIntentFilter.addAction(iSdmCallbacks.SDM_MESSAGE_BUILTIN_SETTINGS);
            mSdmIntentFilter.addAction(iSdmCallbacks.SDM_MESSAGE_BOUND_STATE_CHANGED);
            mSdmIntentFilter.addAction(iSdmCallbacks.SDM_MESSAGE_WRITEEPC_RESPONSE);
            mSdmIntentFilter.addAction(iSdmCallbacks.SDM_MESSAGE_WRITETAG_RESPONSE);
            mSdmIntentFilter.addAction(iSdmCallbacks.SDM_MESSAGE_READTAG_RESPONSE);
            mSdmIntentFilter.addAction(iSdmCallbacks.SDM_MESSAGE_SHOW_DIALOG);
            mSdmIntentFilter.addAction(iSdmCallbacks.SDM_MESSAGE_TRUCONNECT_MODE);

            mSdmBcastReceiver = new SdmBcastReceiver();
            LocalBroadcastManager.getInstance(getCurrentActivity()).registerReceiver(mSdmBcastReceiver, mSdmIntentFilter);

            // Get SDM Handler
            sdmHandler = SdmSingleton.getInstance();
            // Get DiscoverBluettoth  Handler
            sdmHandlerDiscoverBT = SdmSingleton.getInstance();

            // Create callback function for SDM
            sdmCallbacks = new SdmCallbacks(getCurrentActivity());
            int iRes = sdmHandler.init(getReactApplicationContext(), sdmCallbacks, FOLDER_PATH);//null
            AddStrToLog(TYPE_LOG.INFO, "Init SdmSingleton. Result: " + String.valueOf(iRes));
        }

        mKnownDevices = sdmHandler.getKnownDeviceList();
        mConnectedDevices = sdmHandler.getConnectedDeviceList();
        mLastConnectedDevice = sdmHandler.getListLastConnected();
        Log.d(" mKnownDevices",mKnownDevices.toString());
        Log.d(" mLastConnectedDevice",mLastConnectedDevice.toString());



        BtDevicesList = new ArrayList<>();

        doScanBluetoothDevices();

    }

    private void doScanBluetoothDevices() {
        BtDevicesList.clear();
        if (!bProcScanBtDevices) {
            if (!sdmHandlerDiscoverBT.isScanningBluetooth()) {
                AddStrToLog(TYPE_LOG.SEND, "startDiscoverBluetooth");
                sdmHandlerDiscoverBT.startDiscoverBluetooth(getCurrentActivity(), sdmCallbacks);
                bProcScanBtDevices = true;
            }
        } else {
            AddStrToLog(TYPE_LOG.SEND, "stopDiscoverBluetooth");
            sdmHandlerDiscoverBT.stopDiscoverBluetooth();
            if(listener != null){
                listener.showProgressbar(false,"");
            }
        }
    }


    public class SdmBcastReceiver extends BroadcastReceiver {
        Context mContext;
        @Override
        public void onReceive(Context context, Intent intent) {
            String s = intent.getAction();
            String sAddress = intent.getStringExtra(iSdmCallbacks.SDM_EXTRA_ADDRESS);

            /**
             * Initialization SDM finished. Now user can send commands to the SDM
             */
            if (s.equals(iSdmCallbacks.SDM_MESSAGE_INIT_IS_FINISHED)) {
                AddStrToLog(TYPE_LOG.INFO, String.format("INIT SDM FINISHED"));

                // Sample how to change Common scanner settings
                ScannerCommonParams cp = sdmHandler.getScannerCommonSettings();

                if (cp != null) {
                    //--- Enable default sound on scan
                    cp.bSound_on_scan = true;
                    cp.strSoundOnScan = "";

                    //--- Disable autoreconnect devices
                    cp.bAutoReconnect = true;

                    //--- Enable vibrate on scan
                    cp.bVibrateOnScan = true;
                    sdmHandler.setScannerCommonSettings(cp);
                    reconnectDevice();
                }
            }

            /**
             * Initialization of Built-In rearer(s) finished. Now user can send commands to the Built-In reader
             * To geе list of the Built-It device call sdmHandler.getBuiltInScannersList();
             */
            else if (s.equals(iSdmCallbacks.SDM_MESSAGE_BUILTIN_READER_INITIALISED)) {
                AddStrToLog(TYPE_LOG.INFO, String.format("BUILTIN_READER_INITIALISED"));
            }

            /**
             * Setup of Scanner is started. Now user can't send commands to the Scanner
             *
             * @param SDM_EXTRA_ADDRESS Address of the device
             * @param SDM_EXTRA_NAME    Name of the device
             */
            else if (s.equals(iSdmCallbacks.SDM_MESSAGE_SCANNER_SETUP_START)) {
                String sName = intent.getStringExtra(iSdmCallbacks.SDM_EXTRA_NAME);
                AddStrToLog(TYPE_LOG.RECEIVE, String.format("SCANNER_SETUP_START[%s]: %s", sAddress, sName));
            }

            /**
             * Setup of Scanner is finished. Now user can send commands to the Scanner
             *
             * @param SDM_EXTRA_ADDRESS Address of the device
             * @param SDM_EXTRA_NAME    Name of the device
             * @param SDM_EXTRA_RESULT  0 - Successful
             */
            else if (s.equals(iSdmCallbacks.SDM_MESSAGE_SCANNER_SETUP_DONE_RESULT)) {
                String sName = intent.getStringExtra(iSdmCallbacks.SDM_EXTRA_NAME);
                int result = intent.getIntExtra(iSdmCallbacks.SDM_EXTRA_RESULT, -1);
                if (result == iSdmCallbacks.CMD_SUCCESS) {
                    //suсcess
                    AddStrToLog(TYPE_LOG.RECEIVE, String.format("SCANNER_SETUP_DONE[%s]: %s", sAddress, sName));
                } else {
                    AddStrToLog(TYPE_LOG.RECEIVE, String.format("SCANNER_SETUP_FAILED[%s]: %s", sAddress, sName));
                }


            }
            /**
             * Error occurred in SDM library
             *
             * @param SDM_EXTRA_ADDRESS Address of the device
             * @param SDM_EXTRA_ID   Error number
             * @param SDM_EXTRA_MESSAGE  The textual representation of the error
             */
            else if (s.equals(iSdmCallbacks.SDM_MESSAGE_ERROR)) {
                int iID = intent.getIntExtra(iSdmCallbacks.SDM_EXTRA_ID, 0);
                String sError = intent.getStringExtra(iSdmCallbacks.SDM_EXTRA_MESSAGE);

                String strData = "";
                if (sError != null && sError.length() > 0) strData = sError;
                AddStrToLog(TYPE_LOG.ERROR, String.format("ERROR: addr:%s error:[%d] %s", sAddress, iID, strData));
            }
            /**
             * Command to show_update_hide SDM progress in App
             *
             * @param SDM_EXTRA_ADDRESS Address of the device
             * @param SDM_EXTRA_ID      Identifier of progress
             * @param SDM_EXTRA_TYPE    Type of action:
             *                PROGRESS_SHOW = 0;
             *                PROGRESS_UPDATE = 1;  // "title" does not used
             *                PROGRESS_HIDE = 2;    // "title" & "message" do not used
             * @param SDM_EXTRA_TITLE   Title of progress
             * @param SDM_EXTRA_MESSAGE Message of progress
             */
            else if (s.equals(iSdmCallbacks.SDM_MESSAGE_PROGRESS)) {
                int iID = intent.getIntExtra(iSdmCallbacks.SDM_EXTRA_ID, 0);
                int iType = intent.getIntExtra(iSdmCallbacks.SDM_EXTRA_TYPE, 0);
                String sTitle = intent.getStringExtra(iSdmCallbacks.SDM_EXTRA_TITLE);
                String sMessage = intent.getStringExtra(iSdmCallbacks.SDM_EXTRA_MESSAGE);
            }
            /**
             * Message from the Scanner
             *
             * @param SDM_EXTRA_ADDRESS Address of the device
             * @param SDM_EXTRA_MESSAGE Text of message
             * @param SDM_EXTRA_VALUE   Duration:
             *  0- Recommended to show the text notification for a usual period of time(Toast.LENGTH_LONG or Toast.SHORT_LONG)
             *  1- Recommended to show the text notification for a short period of time(for example 1 sec) to avoid message queues
             */
            else if (s.equals(iSdmCallbacks.SDM_MESSAGE_TEXT_INFO)) {
                String sMessage = intent.getStringExtra(iSdmCallbacks.SDM_EXTRA_MESSAGE);
                int iDuration = intent.getIntExtra(iSdmCallbacks.SDM_EXTRA_VALUE, 0);

                SioDevice device = mConnectedDevices.get(sAddress);
                if (device != null) {
                    String sName = device.getDeviceName();
                    String sMess = String.format("Device: %s\nMessage: %s", sName, sMessage);
                    AddStrToLog(TYPE_LOG.ERROR, String.format("TEXT_INFO:%s", sMess));


                }
            }
            /**
             * Filtered scan string from SDM (when enabled "Filter of data" logic in SDM).
             *
             * @param SDM_EXTRA_ADDRESS Address of the device
             * @param SDM_EXTRA_DATA Scan string that was filtered
             */
            else if (s.equals(iSdmCallbacks.SDM_MESSAGE_DATA_FILTERED)) {
                String sData = intent.getStringExtra(iSdmCallbacks.SDM_EXTRA_DATA);
                //Toast.makeText(MainSdmActivity.this, String.format("Scan filtered[%s]:%s",sAddress, sData), Toast.LENGTH_SHORT).show();
                AddStrToLog(TYPE_LOG.INFO, String.format("DATA_FILTERED[%s]:%s", sAddress, sData));
            }
            /**
             * Battery level of the device
             *
             * @param SDM_EXTRA_ADDRESS Address of the device
             * @param SDM_EXTRA_VALUE  Level of battery 0-100%
             */
            else if (s.equals(iSdmCallbacks.SDM_MESSAGE_BATTERY_LEVEL)) {
                int iLevel = intent.getIntExtra(iSdmCallbacks.SDM_EXTRA_VALUE, 0);
                AddStrToLog(TYPE_LOG.RECEIVE, String.format("BATTERY_LEVEL: addr:%s level:%d", sAddress, iLevel));
            }
            /**
             * List of devices was changed.
             * After receive this event need to call function to get the updated list. iSdmHandler.getActiveDeviceList()
             */
            else if (s.equals(iSdmCallbacks.SDM_MESSAGE_DEVICE_LIST_UPDATED)) {
                AddStrToLog(TYPE_LOG.INFO, String.format("DEVICE_LIST_UPDATED"));
                mKnownDevices = sdmHandler.getKnownDeviceList();
                //mLastConnectedAdressesOnCurSession = sdmHandler.getLastConnectedAddressesInCurSession();

                int n = mKnownDevices.size();
                String S = String.format("mKnownDevices [%d]:", n);
                SioDevice device;
                for (int i = 0; i < n; i++) {
                    device = mKnownDevices.get(i);
//                    S += String.format("\n#%d addr:%s Name:%s Connected:%s", i, device.getDeviceAddr(), device.getDeviceName());
                }
//                AddStrToLog(TYPE_LOG.INFO, S);
            }
            /**
             * Scanner settings updated
             *
             * @param SDM_EXTRA_ADDRESS Address of the device
             */
            else if (s.equals(iSdmCallbacks.SDM_MESSAGE_SCANNER_SETTINGS_UPDATED)) {
                AddStrToLog(TYPE_LOG.INFO, String.format("SCANNER_SETTINGS_UPDATED: addr:%s", sAddress));
                //to get scanner settings
                try {
                    ScannerParams scanParams = sdmHandler.getScannerSettings(sAddress);
                } catch (Exception e1) {
                    e1.printStackTrace();
                }
            }
            /**
             * Common devices settings were updated
             *
             */
            else if (s.equals(iSdmCallbacks.SDM_MESSAGE_COMMON_SETTINGS_UPDATED)) {
                AddStrToLog(TYPE_LOG.INFO, String.format("COMMON_SETTINGS_UPDATED"));
                //to get common settings
                //sdmHandler.getScannerCommonSettings();
            }
            /**
             * Detecting state changes made to the BluetoothAdapter
             *
             * @param SDM_EXTRA_STATE BluetoothAdapter state: 0-OFF 1-ON
             */
            else if (s.equals(iSdmCallbacks.SDM_BLUETOOTH_STATE)) {
                int state = intent.getIntExtra(iSdmCallbacks.SDM_EXTRA_STATE, 0);
                if(state == 1) {
                    Toast.makeText(context, "Bluetooth is turned on",Toast.LENGTH_SHORT).show();
                }else {
                    Toast.makeText(context, "Bluetooth is turned off. Turn it on to find and connect devices",Toast.LENGTH_SHORT).show();
                }
                AddStrToLog(TYPE_LOG.INFO, String.format("BLUETOOTH_STATE: %d", state));
            }
            /**
             * Response on command to get WF version of device
             *
             * @param SDM_EXTRA_ADDRESS Address of the device
             * @param SDM_EXTRA_MESSAGE   FW version of device
             */
            else if (s.equals(iSdmCallbacks.SDM_MESSAGE_DEVICE_FW)) {
                String sFW = intent.getStringExtra(iSdmCallbacks.SDM_EXTRA_MESSAGE);
                AddStrToLog(TYPE_LOG.INFO, String.format("DEVICE_FW: %s, %s", sAddress, sFW));
            }
            /**
             * Response on command to get Serial Number of device
             *
             * @param SDM_EXTRA_ADDRESS Address of the device
             * @param SDM_EXTRA_MESSAGE   Serial Number of device
             */
            else if (s.equals(iSdmCallbacks.SDM_MESSAGE_DEVICE_SN)) {
                String sSN = intent.getStringExtra(iSdmCallbacks.SDM_EXTRA_MESSAGE);
                AddStrToLog(TYPE_LOG.INFO, String.format("DEVICE_SN[%s]: %s", sAddress, sSN));
            }
            /**
             * Selected device from Activity DeviceList (User selected the device from the list of discovered)
             *
             * @param SDM_EXTRA_ADDRESS Address of the device
             * @param SDM_EXTRA_NAME    Name of the device
             * @param SDM_EXTRA_REASON
             *      REASON_CONNECT = 0;
             *      !=0 - the device would  selected without connect
             */
            else if (s.equals(iSdmCallbacks.SDM_MESSAGE_SELECTED_DEVICE)) {
                String sName = intent.getStringExtra(iSdmCallbacks.SDM_EXTRA_NAME);
                int iReason = intent.getIntExtra(iSdmCallbacks.SDM_EXTRA_REASON, 0);

                AddStrToLog(TYPE_LOG.INFO, String.format("SELECTED_DEVICE[Reason:%d]:\n[%s] %s\n", iReason, sAddress, sName));
            } else if (s.equals(iSdmCallbacks.SDM_MESSAGE_STREAM_MONITOR_STATE)) {
                int state = intent.getIntExtra(iSdmCallbacks.SDM_EXTRA_STATE, 0);
                AddStrToLog(TYPE_LOG.RECEIVE, String.format("STREAM_MONITOR_STATE[%s]: %d", sAddress, state));
            }
            /**
             * Settings of Built-It reader were updated
             *
             * @param SDM_EXTRA_TYPE Type of BuiltIn reader
             */
            else if (s.equals(iSdmCallbacks.SDM_MESSAGE_BUILTIN_SETTINGS)) {
                int type = intent.getIntExtra(iSdmCallbacks.SDM_EXTRA_TYPE, 0);

                // to get the settings:
                BuiltInScannerSettings biSettings = sdmHandler.getBuiltInSettings(type);
                if (biSettings != null) {
                    AddStrToLog(TYPE_LOG.RECEIVE, String.format("BUILTIN_SETTINGS[type:%d]: %s constant_read_mode=%B", biSettings.builtin_type, biSettings.toString(), biSettings.constant_read_mode));
                }
            }
            /**
             * Indicates a change in the bond state of a Bluetooth remote device. For example, if a device is bonded (paired).
             * Possible values are: BluetoothDevice.BOND_NONE(=10), BluetoothDevice.BOND_BONDING(=11), BluetoothDevice.BOND_BONDED(=12).
             *
             * @param SDM_EXTRA_ADDRESS Address of the device
             * @param SDM_EXTRA_STATE   state
             */
            else if (s.equals(iSdmCallbacks.SDM_MESSAGE_BOUND_STATE_CHANGED)) {
                int iState = intent.getIntExtra(iSdmCallbacks.SDM_EXTRA_STATE, 0);
                String strBondState = "UNDEFINED";
                switch (iState) {
                    case BluetoothDevice.BOND_NONE:
                        strBondState = "BOND_NONE";
                        break;
                    case BluetoothDevice.BOND_BONDING:
                        strBondState = "BOND_BONDING";
                        break;
                    case BluetoothDevice.BOND_BONDED:
                        strBondState = "BOND_BONDED";
                        break;
                }
                AddStrToLog(TYPE_LOG.RECEIVE, String.format("BOUND_STATE_CHANGED[%s]: State: %s", sAddress, strBondState));
            }

            /**
             * Message write EPC response
             *
             * @param SDM_EXTRA_ADDRESS (String) Address of the device
             * @param SDM_EXTRA_STATE   (int) state. 0-successful
             */

            else if (s.equals(iSdmCallbacks.SDM_MESSAGE_WRITEEPC_RESPONSE)) {
                int iState = intent.getIntExtra(iSdmCallbacks.SDM_EXTRA_STATE, 0);
                AddStrToLog(TYPE_LOG.RECEIVE, String.format("SDM_MESSAGE_WRITEEPC_RESPONSE[%s]: State: %d", sAddress, iState));
            }

            /**
             * Message write tag response
             *
             * @param SDM_EXTRA_ADDRESS (String) Address of the device
             * @param SDM_EXTRA_STATE   (int) state. 0-successful
             */
            else if (s.equals(iSdmCallbacks.SDM_MESSAGE_WRITETAG_RESPONSE)) {
                int iState = intent.getIntExtra(iSdmCallbacks.SDM_EXTRA_STATE, 0);
                AddStrToLog(TYPE_LOG.RECEIVE, String.format("SDM_MESSAGE_WRITETAG_RESPONSE[%s]: State: %d", sAddress, iState));
            }

            /**
             * Message read tag response
             *
             * @param SDM_EXTRA_ADDRESS (String) Address of the device
             * @param SDM_EXTRA_STATE   (int) state. 0-successful
             */
            else if (s.equals(iSdmCallbacks.SDM_MESSAGE_READTAG_RESPONSE)) {
                int iState = intent.getIntExtra(iSdmCallbacks.SDM_EXTRA_STATE, 0);
                AddStrToLog(TYPE_LOG.RECEIVE, String.format("SDM_MESSAGE_READTAG_RESPONSE[%s]: State: %d", sAddress, iState));
            }
            /**
             * Message from the Serial Device Manager (SDM)that should be shown in some Dialog
             *
             * @param SDM_EXTRA_MESSAGE Text of message
             * @param SDM_EXTRA_VALUE   Duration in milliseconds
             *  if duration dreather than 0 - you should implement autodissmiss logic for Dialog
             */
            else if (s.equals(iSdmCallbacks.SDM_MESSAGE_SHOW_DIALOG)) {

            }
            /**
             * Truconnect mode state of the device (Only supported Serialio devices)
             *
             * @param SDM_EXTRA_ADDRESS (String) Address of the device
             * @param SDM_EXTRA_STATE  Status of connection (DISABLE = 0, ENABLE = 1)
             */
            else if (s.equals(iSdmCallbacks.SDM_MESSAGE_TRUCONNECT_MODE)) {
                int iState = intent.getIntExtra(iSdmCallbacks.SDM_EXTRA_STATE, -1);
                String sMode = String.format("UNDEFINED: %d", iState);
                if (iState == 0) sMode = "STREAM_MODE";
                else if (iState == 1) sMode = "REMOTE_COMMAND_MODE";
                AddStrToLog(TYPE_LOG.RECEIVE, String.format("SDM_MESSAGE_TRUCONNECT_MODE[%s]: %s", sAddress, sMode));
            }

        }
    }

    public class SdmCallbacks implements iSdmCallbacks, iSdmCallbackDiscoverBluetooth {
        Context mContext;

        SdmCallbacks(Context context) {
            this.mContext = context;
        }

        //--------------------- iSdmCallbacks ------------------------------------------------------

        /**
         * Status of Connection of the device
         *
         * @param address Address of the device
         * @param status  Status of connection
         *                STATE_NONE = 0             // we're doing nothing
         *                STATE_CONNECTION_FAIL = 1  // connection is fail
         *                STATE_CONNECTING = 2       // now initiating an outgoing connection
         *                STATE_CONNECTED = 3        // now connected to a remote device
         *                STATE_CONNECTION_LOST = 4  // connection lost
         *                STATE_DISCONNECTING = 5;   // disconnecting
         *                STATE_TRYING = 6;          // trying. when doing a "retry to connect" logic
         */
        @Override
        public void onConnectionStatus(String address, int status) {
            String strStatus = SioDevice.getStateString(status);
            AddStrToLog(TYPE_LOG.INFO, String.format("onConnectionStatus: addr:%s Status:[%d] %s", address, status, strStatus));
            mConnectedDevices = sdmHandler.getConnectedDeviceList();
            mKnownDevices = sdmHandler.getKnownDeviceList();

            if (status == SioDevice.STATE_CONNECTED) {
                int n = mConnectedDevices.size();
                String S = String.format("ConnectedDevices [%d]:", n);
                SioDevice device = null;
                String name = "";
                String Address = "";
                for (int i = 0; i < n; i++) {
                    device = mConnectedDevices.get(i);
                    name = device.getDeviceName();
                    Address = device.getDeviceAddr();
//                    S += String.format("\n#%d addr:%s Name:%s Connected:%s", i, device.getDeviceAddr(), device.getDeviceName());
                }
                String deviceName = name.concat(Address);
                if(BtDevicesList.size()>0){
                    BtDevicesList.remove(BtDevicesList.size()-1);
                    AddStrToLog(TYPE_LOG.INFO, String.valueOf(BtDevicesList.size()));
                }
                AddStrToLog(TYPE_LOG.INFO, S);
                if (listener != null) {
                    listener.onDeviceState(true, deviceName);
                    listener.showProgressbar(false,"Connecting");
                    listener.onFoundDeviceList(BtDevicesList);
                }
                Toast.makeText(mContext, "Connected", Toast.LENGTH_SHORT).show();

            }

            if (status == SioDevice.STATE_NONE) {
                if (listener != null) {
                    listener.onDeviceState(false, "");
                    listener.showProgressbar(false,"Disconnecting");
                    bProcScanBtDevices = false;
                    doScanBluetoothDevices();
                }
            }
        }

        @Override
        public void onReceiveData(String address, int type, int iBuiltInType, int antenna, Object data) {
            String sType[] = {"", "STR", "BYTES", "RAW", "GPS"};
            String strData = String.format("%s Data: ", sType[type]);
            switch (type) {
                case iSdmCallbacks.TYPE_STRING:
                    strData += (String) data;
                    break;

                case iSdmCallbacks.TYPE_BYTES_ARRAY:
                case iSdmCallbacks.TYPE_RAW_BYTES: {
                    byte[] bData = (byte[]) data;
                    if (bData != null) {
                        for (int i = 0; i < bData.length; i++) {
                            String strBuf = String.format("<%02X>", (byte) (bData[i] & 0xFF));
                            strData += strBuf;
                        }
                    }
                    break;
                }

                case iSdmCallbacks.TYPE_GPS_POSITION: {
                    com.restock.scanners.utils.NMEA.GPSPosition gpsPosition = (com.restock.scanners.utils.NMEA.GPSPosition) data;
                    if (gpsPosition != null) {
                        String strGps = gpsPosition.toString().replace("\r", "").replace("\n", "");
                        strData += strGps;
                    }
                    break;
                }
            }
            String sBuiltin = "";
            if (iBuiltInType > 0) sBuiltin = String.format(" BuiltInType: %d ", iBuiltInType);
            AddStrToLog(TYPE_LOG.RECEIVE, String.format("onReceiveData: addr:%s%stype:%d ant:%d data:%s", address, sBuiltin, type, antenna, strData));
            String scanValue = strData.replace("STR Data: ", "");
            sendScannedValue(scanType, scanValue.trim());
        }


        //----- iSdmCallbackDiscoverBluetooth ------------------------------------------------------
        @Override
        public void onFoundBluetoothDevice(BluetoothDevice BluetoothDev, int rssi) {
            String S = "onFoundBluetoothDevice";
            if (BluetoothDev != null) {
                String sType = "";
                if (android.os.Build.VERSION.SDK_INT >= 18) {
                    String sT = "";
                    int t = BluetoothDev.getType();
                    switch (t) {
                        case android.bluetooth.BluetoothDevice.DEVICE_TYPE_UNKNOWN:
                            sT = "DEVICE_TYPE_UNKNOWN";
                            break;
                        case android.bluetooth.BluetoothDevice.DEVICE_TYPE_CLASSIC:
                            sT = "DEVICE_TYPE_CLASSIC";
                            break;
                        case android.bluetooth.BluetoothDevice.DEVICE_TYPE_LE:
                            sT = "DEVICE_TYPE_LE";
                            break;
                        case android.bluetooth.BluetoothDevice.DEVICE_TYPE_DUAL:
                            sT = "DEVICE_TYPE_DUAL";
                            break;
                    }
                    sType = String.format(" Type:%s", sT);
                }
                S += String.format("\n [%s] %s rssi:%d Class:%s%s", BluetoothDev.getAddress(), BluetoothDev.getName(), rssi, BluetoothDev.getBluetoothClass().toString(), sType);
                BtDevicesList.add(BluetoothDev);
                if (listener != null) {
                    listener.onFoundDeviceList(BtDevicesList);
                    listener.showProgressbar(false,"");
                }
            }
            AddStrToLog(TYPE_LOG.RECEIVE, S);
        }

        @Override public void onScanBluetoothFinished() {
            AddStrToLog(TYPE_LOG.INFO, "onScanBluetoothFinished");
            bProcScanBtDevices = false;

        }

        @Override
        public void onErrorBluetoothDiscover(String data) {
            if (data == null) data = "null";
            AddStrToLog(TYPE_LOG.INFO, String.format("onErrorBluetoothDiscover:%s", data));
            bProcScanBtDevices = false;
            if (listener != null) {
                listener.showProgressbar(false,"");
            }

        }
    }

    private void releaseResources() {
        if (mSdmBcastReceiver != null) {
            if (this != null)
                LocalBroadcastManager.getInstance(getCurrentActivity()).unregisterReceiver(mSdmBcastReceiver);
            mSdmBcastReceiver = null;
        }

        if (sdmHandler != null) {
            sdmHandler.deinit();
            sdmHandler = null;
        }
    }
}
