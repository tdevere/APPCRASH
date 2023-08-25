package com.InnovaZones.RNTreeIZHips.nativemodules;

import android.app.Activity;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.SharedPreferences;
import androidx.annotation.Nullable;
import androidx.localbroadcastmanager.content.LocalBroadcastManager;
import android.util.Log;
import android.widget.Toast;

import com.InnovaZones.RNTreeIZHips.Constant;
import com.InnovaZones.RNTreeIZHips.UHFRFID.DeviceListActivity;
import com.facebook.react.bridge.ActivityEventListener;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.LifecycleEventListener;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.WritableArray;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.modules.core.DeviceEventManagerModule;
import com.uk.tsl.rfid.asciiprotocol.AsciiCommander;
import com.uk.tsl.rfid.asciiprotocol.commands.BatteryStatusCommand;
import com.uk.tsl.rfid.asciiprotocol.device.ConnectionState;
import com.uk.tsl.rfid.asciiprotocol.device.IAsciiTransport;
import com.uk.tsl.rfid.asciiprotocol.device.ObservableReaderList;
import com.uk.tsl.rfid.asciiprotocol.device.Reader;
import com.uk.tsl.rfid.asciiprotocol.device.ReaderManager;
import com.uk.tsl.rfid.asciiprotocol.device.TransportType;
import com.uk.tsl.rfid.asciiprotocol.responders.IAsciiCommandResponder;
import com.uk.tsl.rfid.asciiprotocol.responders.LoggerResponder;
import com.uk.tsl.utils.Observable;

import org.json.JSONException;
import org.json.JSONObject;

import java.lang.reflect.Array;

import static com.InnovaZones.RNTreeIZHips.UHFRFID.DeviceListActivity.EXTRA_DEVICE_ACTION;
import static com.InnovaZones.RNTreeIZHips.UHFRFID.DeviceListActivity.EXTRA_DEVICE_INDEX;


public class UHFRFIDModule extends ReactContextBaseJavaModule {

    public static ReactApplicationContext mReactContext;
    int isMultiScan = 0;
    String scanType = null;

    // The Reader currently in use
    private Reader mReader = null;

    WritableArray mValueArray = Arguments.createArray();

    public UHFRFIDModule(ReactApplicationContext reactContext) {
        super(reactContext);
        this.mReactContext = reactContext;
    }

    @Override
    public String getName() {
        return "UHFRFIDModule";
    }

    @ReactMethod
    public void startUHFRFIDScanner(String strInput){
        try {
            JSONObject mInputObj = new JSONObject(strInput);
            isMultiScan = mInputObj.getInt("isMultiScan");
            scanType = mInputObj.getString("scanType");


            if(AsciiCommander.sharedInstance() == null){
                AsciiCommander.createSharedInstance(getReactApplicationContext());
            }

            if (ReaderManager.sharedInstance() == null){
                ReaderManager.create(getReactApplicationContext());
                ReaderManager.sharedInstance().initialiseList();
                ReaderManager.sharedInstance().setWillAutoConnectUsbReaders(true);
                ReaderManager.sharedInstance().setAllowMultipleTransports(true);
            }
            AutoSelectReader(true);
            final AsciiCommander commander = getCommander();

            // Ensure that all existing responders are removed
            commander.clearResponders();

            // Add the LoggerResponder - this simply echoes all lines received from the reader to the log
            // and passes the line onto the next responder
            // This is ADDED FIRST so that no other responder can consume received lines before they are logged.
            commander.addResponder(new LoggerResponder());

            //
            // Add a simple Responder that sends the Reader output to the App message list
            //
            // Note - This is not the recommended way of receiving Reader input - it is just a convenient
            // way to show that the Reader is connected and communicating - see the other Sample Projects
            // for how to Inventory, Read, Write etc....
            //
            commander.addResponder(new IAsciiCommandResponder() {
                @Override
                public boolean isResponseFinished() { return false; }

                @Override
                public void clearLastResponse() {

                }

                @Override
                public boolean processReceivedLine(String fullLine, boolean moreLinesAvailable)
                {

                    if (scanType != null) {
                        if (isMultiScan == 1) {
                            if (fullLine.startsWith("EP:")) {
                                String data = fullLine.replace("EP:", "");
                                mValueArray.pushString(data);
                            } else if (fullLine.startsWith("OK")) {
                                sendScannedValue(scanType, mValueArray);
                                mValueArray = Arguments.createArray();
                            }
                        } else {
                            if (fullLine.startsWith("EP:")) {
                                String data = fullLine.replace("EP:", "");
                                sendScannedValue(scanType, data);
                            }
                        }
                    }
                    // don't consume the line - allow others to receive it
                    return false;
                }
            });

            // Add responder to enable the synchronous commands
            commander.addSynchronousResponder();

            if (ReaderManager.sharedInstance() == null) {
                // Configure the ReaderManager when necessary
                ReaderManager.create(getReactApplicationContext());

                // Add observers for changes
                ReaderManager.sharedInstance().getReaderList().readerAddedEvent().addObserver(mAddedObserver);
                ReaderManager.sharedInstance().getReaderList().readerUpdatedEvent().addObserver(mUpdatedObserver);
                ReaderManager.sharedInstance().getReaderList().readerRemovedEvent().addObserver(mRemovedObserver);
            }


            // Register to receive notifications from the AsciiCommander
            LocalBroadcastManager.getInstance(getCurrentActivity()).unregisterReceiver(mMessageReceiver);

            // Register to receive notifications from the AsciiCommander
            LocalBroadcastManager.getInstance(getCurrentActivity()).registerReceiver(mMessageReceiver, new IntentFilter(AsciiCommander.STATE_CHANGED_NOTIFICATION));

            // Remember if the pause/resume was caused by ReaderManager - this will be cleared when ReaderManager.onResume() is called
            boolean readerManagerDidCauseOnPause = ReaderManager.sharedInstance().didCauseOnPause();

            // The ReaderManager needs to know about Activity lifecycle changes
            ReaderManager.sharedInstance().onResume();

            // The Activity may start with a reader already connected (perhaps by another App)
            // Update the ReaderList which will add any unknown reader, firing events appropriately
            ReaderManager.sharedInstance().updateList();

            // Reconnect to the Reader in use (locate a Reader to use when necessary)

        } catch (JSONException e) {
            e.printStackTrace();
        }

    }
    @ReactMethod
    public void openUHFRFIDScannerSettingsView(String strInput){
        try {
            JSONObject mInputObj = new JSONObject(strInput);
            isMultiScan = mInputObj.getInt("isMultiScan");
            scanType = mInputObj.getString("scanType");


            // Register to receive notifications from the AsciiCommander
            LocalBroadcastManager.getInstance(getCurrentActivity()).unregisterReceiver(mMessageReceiver);

            // Disconnect from the reader to allow other Apps to use it
            // unless pausing when USB device attached or using the DeviceListActivity to select a Reader
//            if( !mIsSelectingReader && !ReaderManager.sharedInstance().didCauseOnPause() && mReader != null )
//            {
//                mReader.disconnect();
//            }

//            ReaderManager.sharedInstance().onPause();

            int index = -1;
            if( mReader != null )
            {
                index = ReaderManager.sharedInstance().getReaderList().list().indexOf(mReader);
            }
            Intent selectIntent = new Intent(getReactApplicationContext(), DeviceListActivity.class);
            if( index >= 0 )
            {
                selectIntent.putExtra(EXTRA_DEVICE_INDEX, index);
            }
            selectIntent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            getCurrentActivity().startActivityForResult(selectIntent, DeviceListActivity.SELECT_DEVICE_REQUEST);
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    public void sendScannedValue(String scanType, String value) {
        WritableMap params = Arguments.createMap();
        params.putString("type", "SCANNED_VALUE");
        params.putString("deviceName", "");
        params.putString("response", value);
        if (scanType.equals(Constant.UHFRFID_SCANTYPE_PRODUCT)) {
            sendEvent(Constant.UHFRFID_EVENT_PRODUCT, params);
        } else if (scanType.equals(Constant.UHFRFID_SCANTYPE_REPORT_ASSET_NO)) {
            sendEvent(Constant.UHFRFID_EVENT_REPORT_ASSET_NO, params);
        } else if (scanType.equals(Constant.UHFRFID_SCANTYPE_CART)) {
            sendEvent(Constant.UHFRFID_EVENT_CART, params);
        } else if (scanType.equals(Constant.UHFRFID_SCANTYPE_UNIFORM_ASSET_NO)) {
            sendEvent(Constant.UHFRFID_EVENT_UNIFORM_ASSET_NO, params);
        } else if (scanType.equals(Constant.UHFRFID_SCANTYPE_STATION_ASSET_NO)) {
            sendEvent(Constant.UHFRFID_EVENT_STATION_ASSET_NO, params);
        }
    }

    public void sendScannedValue(String scanType, WritableArray value) {
        WritableMap params = Arguments.createMap();
        params.putString("type", "SCANNED_VALUE");
        params.putString("deviceName", "");
        params.putArray("response", value);
        if (scanType.equals(Constant.UHFRFID_SCANTYPE_PRODUCT)) {
            sendEvent(Constant.UHFRFID_EVENT_PRODUCT, params);
        } else if (scanType.equals(Constant.UHFRFID_SCANTYPE_REPORT_ASSET_NO)) {
            sendEvent(Constant.UHFRFID_EVENT_REPORT_ASSET_NO, params);
        } else if (scanType.equals(Constant.UHFRFID_SCANTYPE_CART)) {
            sendEvent(Constant.UHFRFID_EVENT_CART, params);
        } else if (scanType.equals(Constant.UHFRFID_SCANTYPE_UNIFORM_ASSET_NO)) {
            sendEvent(Constant.UHFRFID_EVENT_UNIFORM_ASSET_NO, params);
        } else if (scanType.equals(Constant.UHFRFID_SCANTYPE_STATION_ASSET_NO)) {
            sendEvent(Constant.UHFRFID_EVENT_STATION_ASSET_NO, params);
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

    public void resultFromActivity(int readerIndex, int action) {

        // Register to receive notifications from the AsciiCommander
        LocalBroadcastManager.getInstance(getCurrentActivity()).registerReceiver(mMessageReceiver, new IntentFilter(AsciiCommander.STATE_CHANGED_NOTIFICATION));

        // Remember if the pause/resume was caused by ReaderManager - this will be cleared when ReaderManager.onResume() is called
        boolean readerManagerDidCauseOnPause = ReaderManager.sharedInstance().didCauseOnPause();

        // The ReaderManager needs to know about Activity lifecycle changes
        ReaderManager.sharedInstance().onResume();

        // The Activity may start with a reader already connected (perhaps by another App)
        // Update the ReaderList which will add any unknown reader, firing events appropriately
        ReaderManager.sharedInstance().updateList();

        Reader chosenReader = ReaderManager.sharedInstance().getReaderList().list().get(readerIndex);

        // If already connected to a different reader then disconnect it
        if( mReader != null )
        {
            if( action == DeviceListActivity.DEVICE_CHANGE || action == DeviceListActivity.DEVICE_DISCONNECT)
            {
                mReader.disconnect();
                if(action == DeviceListActivity.DEVICE_DISCONNECT)
                {
                    mReader = null;
                }

                storeDevice(null);
            }
        }

        // Use the Reader found
        if( action == DeviceListActivity.DEVICE_CHANGE || action == DeviceListActivity.DEVICE_CONNECT)
        {
            mReader = chosenReader;
            getCommander().setReader(mReader);
            storeDevice(mReader.getDisplayName() + ",,, " + mReader.getDisplayInfoLine());
        }
        JSONObject mObj = new JSONObject();
        try {
            mObj.put("isMultiScan", isMultiScan);
            mObj.put("scanType", scanType);
            startUHFRFIDScanner(mObj.toString());
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    public void storeDevice(String serial_number) {
        SharedPreferences pref = getReactApplicationContext().getSharedPreferences("InnovaZones", 0); // 0 - for private mode
        SharedPreferences.Editor editor = pref.edit();

        editor.putString("serial_number", serial_number);

        editor.commit();
    }

    public String getDevice() {
        SharedPreferences pref = getReactApplicationContext().getSharedPreferences("InnovaZones", 0); // 0 - for private mode
        return pref.getString("serial_number", null);
    }

    //
    // Select the Reader to use and reconnect to it as needed
    //
    private void AutoSelectReader(boolean attemptReconnect)
    {
        ObservableReaderList readerList = ReaderManager.sharedInstance().getReaderList();
        Reader usbReader = null;
        if( readerList.list().size() >= 1)
        {
            // Currently only support a single USB connected device so we can safely take the
            // first CONNECTED reader if there is one
            for (Reader reader : readerList.list())
            {
                IAsciiTransport transport = reader.getActiveTransport();
                if (reader.hasTransportOfType(TransportType.USB))
                {
                    usbReader = reader;
                    break;
                }
            }
        }

        if( mReader == null )
        {
            if( usbReader != null )
            {
                // Use the Reader found, if any
                mReader = usbReader;
                getCommander().setReader(mReader);
            }
            else {
                for (Reader reader : readerList.list())
                {
                    IAsciiTransport transport = reader.getActiveTransport();
                    if ((reader.getDisplayName() + ",,, " + reader.getDisplayInfoLine()).equals(getDevice()))
                    {
                        mReader = reader;
                        getCommander().setReader(mReader);
                        break;
                    }
                }
            }
        }
        else
        {
            // If already connected to a Reader by anything other than USB then
            // switch to the USB Reader
            IAsciiTransport activeTransport = mReader.getActiveTransport();
            if ( activeTransport != null && activeTransport.type() != TransportType.USB && usbReader != null)
            {
                mReader.disconnect();

                mReader = usbReader;

                // Use the Reader found, if any
                getCommander().setReader(mReader);
            }
        }

        // Reconnect to the chosen Reader
        if( mReader != null && (mReader.getActiveTransport()== null || mReader.getActiveTransport().connectionStatus().value() == ConnectionState.DISCONNECTED))
        {
            // Attempt to reconnect on the last used transport unless the ReaderManager is cause of OnPause (USB device connecting)
            if( attemptReconnect )
            {
                if( mReader.allowMultipleTransports() || mReader.getLastTransportType() == null )
                {
                    // Reader allows multiple transports or has not yet been connected so connect to it over any available transport
                    mReader.connect();
                }
                else
                {
                    // Reader supports only a single active transport so connect to it over the transport that was last in use
                    mReader.connect(mReader.getLastTransportType());
                }
            }
        }
    }


    // ReaderList Observers
    Observable.Observer<Reader> mAddedObserver = new Observable.Observer<Reader>()
    {
        @Override
        public void update(Observable<? extends Reader> observable, Reader reader)
        {
            // See if this newly added Reader should be used
            AutoSelectReader(true);
        }
    };

    Observable.Observer<Reader> mUpdatedObserver = new Observable.Observer<Reader>()
    {
        @Override
        public void update(Observable<? extends Reader> observable, Reader reader)
        {
        }
    };

    Observable.Observer<Reader> mRemovedObserver = new Observable.Observer<Reader>()
    {
        @Override
        public void update(Observable<? extends Reader> observable, Reader reader)
        {
            // Was the current Reader removed
            if( reader == mReader)
            {
                mReader = null;

                // Stop using the old Reader
                getCommander().setReader(mReader);
            }
        }
    };


    /**
     * @return the current AsciiCommander
     */
    public AsciiCommander getCommander()
    {
        return AsciiCommander.sharedInstance();
    }


    //
    // Handle the messages broadcast from the AsciiCommander
    //
    private BroadcastReceiver mMessageReceiver = new BroadcastReceiver()
    {
        @Override
        public void onReceive(Context context, Intent intent)
        {
            String connectionStateMsg = getCommander().getConnectionState().toString();
            Log.d("", "AsciiCommander state changed - isConnected: " + getCommander().isConnected() + " (" + connectionStateMsg + ")");

            if(getCommander()!= null)
            {
                if (getCommander().isConnected())
                {
                    // Report the battery level when Reader connects
                    BatteryStatusCommand bCommand = BatteryStatusCommand.synchronousCommand();
                    getCommander().executeCommand(bCommand);
                    int batteryLevel = bCommand.getBatteryLevel();
                }
                else if(getCommander().getConnectionState() == ConnectionState.DISCONNECTED)
                {
                    // A manual disconnect will have cleared mReader
                    if( mReader != null )
                    {
                        // See if this is from a failed connection attempt
                        if (!mReader.wasLastConnectSuccessful())
                        {
                            // Unable to connect so have to choose reader again
                            mReader = null;
                        }
                    }
                }
            }

        }
    };
}
