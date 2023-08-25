package com.InnovaZones.RNTreeIZHips.serialio;


import android.Manifest;
import android.app.ProgressDialog;
import android.bluetooth.BluetoothDevice;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.graphics.Typeface;
import android.os.Build;
import android.os.Environment;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;
import androidx.annotation.RequiresApi;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import com.InnovaZones.RNTreeIZHips.CustomReactPackage;
import com.InnovaZones.RNTreeIZHips.R;
import com.InnovaZones.RNTreeIZHips.nativemodules.RFIDModule;


import java.util.ArrayList;


public class DeviceListRFIDActivity extends AppCompatActivity {
    private static final String TAG = "DeviceListRFIDActivity";
    public static final int SELECT_DEVICE_REQUEST = 0x5344;
    private RecyclerView mRecyclerView;
    private DeviceListAdapter mAdapter;



    ArrayList<BluetoothDevice> BtDevicesList;

    public static final String SDCARD_PATH = Environment.getExternalStorageDirectory().getAbsolutePath().replace("/mnt", "");  //"/sdcard";
    public static final String FOLDER_NAME = "/SampleSDM_files";
    public static final String FOLDER_PATH = SDCARD_PATH + FOLDER_NAME;
    public static final String LOG_FULLPATH = FOLDER_PATH + "/SampleSDMLog.txt";


    public static int DEVICE_INITIAL = 1;
    public static int DEVICE_CONNECT = 2;
    public static int DEVICE_DISCONNECT = 3;
    public static int SCAN_BLUETOOTH_DEVICE = 4;
    ProgressDialog mProgressDialog;



    @RequiresApi(api = Build.VERSION_CODES.M)
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_device_list_rfidactivity);
        mProgressDialog = new ProgressDialog(this);


        ((ImageView) findViewById((R.id.rfid_back_img))).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                finish();
            }
        });
        ((ImageView) findViewById((R.id.rfid_search_img))).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                rfidStateChange(SCAN_BLUETOOTH_DEVICE, -1);
            }
        });
        BtDevicesList =new ArrayList<BluetoothDevice>();
        hasPermission();
        mRecyclerView = (RecyclerView) findViewById(R.id.reader_recycler_view_rfid);
        mRecyclerView.setLayoutManager(new LinearLayoutManager(this));
        mAdapter = new DeviceListAdapter(BtDevicesList, this);
        mRecyclerView.setAdapter(mAdapter);



        ((LinearLayout) findViewById((R.id.connected_device_lay_rfid))).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                rfidStateChange(DEVICE_DISCONNECT, -1);
//                String AddressName = ((TextView) view.findViewById(R.id.nameTextViewRFID)).getText().toString();
//                Log.d("AddStrToLog", AddressName);
            }
        });

        CustomReactPackage.mRFIDModule.setCustomObjectListener(new RFIDModule.MyCustomRFIDListener() {
            @Override
            public void onFoundDeviceList(ArrayList<BluetoothDevice> BtDevicesList) {
                mAdapter = new DeviceListAdapter(BtDevicesList, DeviceListRFIDActivity.this);
                mRecyclerView.setAdapter(mAdapter);
                Log.d(TAG, "onFoundDeviceList ********: ");
                mAdapter.notifyDataSetChanged();
            }

            @Override
            public void onDeviceState(Boolean deviceStatus, String name) {
                if (deviceStatus) {
                    ((LinearLayout) findViewById(R.id.connected_device_lay_rfid)).setVisibility(View.VISIBLE);
                    ((TextView) findViewById(R.id.deviceName)).setText(name);
                    ((ImageView) findViewById(R.id.imageViewRfid)).setVisibility(View.VISIBLE);
                } else {
                    ((LinearLayout) findViewById(R.id.connected_device_lay_rfid)).setVisibility(View.GONE);
                }
            }

            @Override
            public void showProgressbar(Boolean isShowLoading, String message) {

                if(isShowLoading){
                    showProgressDialog(message);
                }else {
                    hideProgressDialog();
                }

            }
        });


    }

    void initapp() {
        rfidStateChange(DEVICE_INITIAL, -1);
    }

    /**
     * Show progress dialog
     */
    public void showProgressDialog(String message) {
        if (mProgressDialog.isShowing()) {
            mProgressDialog.dismiss();
        }
        mProgressDialog.setMessage(message);
        mProgressDialog.setCancelable(false);
        mProgressDialog.setCanceledOnTouchOutside(false);
        mProgressDialog.show();
    }

    /**
     * hide progress dialog
     */
    public void hideProgressDialog() {
        if (mProgressDialog.isShowing()) {
            mProgressDialog.dismiss();
        }
    }
    public void hasPermission() {
        if (ContextCompat.checkSelfPermission(DeviceListRFIDActivity.this,
                Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
            if (ActivityCompat.shouldShowRequestPermissionRationale(DeviceListRFIDActivity.this,
                    Manifest.permission.ACCESS_FINE_LOCATION)) {
                ActivityCompat.requestPermissions(DeviceListRFIDActivity.this,
                        new String[]{Manifest.permission.ACCESS_FINE_LOCATION}, 1);
            } else {
                ActivityCompat.requestPermissions(DeviceListRFIDActivity.this,
                        new String[]{Manifest.permission.ACCESS_FINE_LOCATION}, 1);
            }
        } else {
            initapp();
        }
    }

    public void OnClickReadrItem(View view, int adapterPosition) {
        Log.d(TAG, "OnClickReadrItem ********: ");
        rfidStateChange(DEVICE_CONNECT, adapterPosition);
    }

    void rfidStateChange(int state, int position) {
        CustomReactPackage.mRFIDModule.resultFromActivity(state, position);
    }


    @Override
    protected void onDestroy() {
        super.onDestroy();
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, String[] permissions,
                                           int[] grantResults) {
        switch (requestCode) {
            case 1: {
                if (grantResults.length > 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                    if (ContextCompat.checkSelfPermission(DeviceListRFIDActivity.this,
                            Manifest.permission.ACCESS_FINE_LOCATION) == PackageManager.PERMISSION_GRANTED) {
                        Toast.makeText(this, "Permission Granted", Toast.LENGTH_SHORT).show();
                        initapp();
                    }
                } else {
                    initapp();
                    Toast.makeText(this, "Permission Denied", Toast.LENGTH_SHORT).show();
                }
                return;
            }
        }
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        switch (requestCode) {
            case 1001: {
                rfidStateChange(DEVICE_INITIAL, -1);
                break;
            }
        }
    }

}