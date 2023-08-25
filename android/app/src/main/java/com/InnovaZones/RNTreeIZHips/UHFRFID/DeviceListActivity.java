package com.InnovaZones.RNTreeIZHips.UHFRFID;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.Typeface;
import android.os.Bundle;
import android.os.Handler;

import android.util.Log;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.Window;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.SeekBar;
import android.widget.TextView;
import android.widget.Toast;

import androidx.recyclerview.widget.DividerItemDecoration;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.InnovaZones.RNTreeIZHips.Constant;
import com.InnovaZones.RNTreeIZHips.CustomReactPackage;
import com.InnovaZones.RNTreeIZHips.R;
import com.uk.tsl.rfid.asciiprotocol.commands.InventoryCommand;
import com.uk.tsl.rfid.asciiprotocol.device.ObservableReaderList;
import com.uk.tsl.rfid.asciiprotocol.device.Reader;
import com.uk.tsl.rfid.asciiprotocol.device.ReaderManager;
import com.uk.tsl.rfid.asciiprotocol.device.TransportType;
import com.uk.tsl.rfid.asciiprotocol.enumerations.TriState;
import com.uk.tsl.utils.Observable;

/**
 */
public class DeviceListActivity extends Activity {
    // Debugging
    private static final String TAG = "DeviceListActivity";
    private static final boolean D = true;


    // Intent request codes
    public static final int SELECT_DEVICE_REQUEST = 0x5344;


    /// Return Intent extra
    public static String EXTRA_DEVICE_INDEX = "tsl_device_index";
    public static String EXTRA_DEVICE_ACTION = "tsl_device_action";

    /// Actions requested for the chosen device
    public static int DEVICE_CONNECT = 1;
    public static int DEVICE_CHANGE = 2;
    public static int DEVICE_DISCONNECT = 3;


    // Member fields
    private RecyclerView mRecyclerView;
    private ReaderViewAdapter mAdapter;
    private RecyclerView.LayoutManager mLayoutManager;
    private ObservableReaderList mReaders;

    private Reader mSelectedReader = null;

    private SeekBar mPowerSeekBar;
    private TextView mPowerLevelTextView;
    ProgressDialog mProgressDialog;


    private SeekBar.OnSeekBarChangeListener mPowerSeekBarListener = new SeekBar.OnSeekBarChangeListener() {
        @Override
        public void onStartTrackingTouch(SeekBar seekBar) {
            // Nothing to do here
        }
        @Override
        public void onStopTrackingTouch(SeekBar seekBar) {
            // Update the reader's setting only after the user has finished changing the value
            updatePowerSetting(seekBar.getProgress());
        }
        @Override
        public void onProgressChanged(SeekBar seekBar, int progress,
                                      boolean fromUser) {
            updatePowerSetting(progress);
        }
    };

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        // Setup the window
        requestWindowFeature(Window.FEATURE_INDETERMINATE_PROGRESS);
        setContentView(R.layout.reader_list);

        mProgressDialog = new ProgressDialog(this);

        mRecyclerView = (RecyclerView) findViewById(R.id.reader_recycler_view);
        mPowerLevelTextView = findViewById(R.id.power_output_txt);
        mPowerSeekBar = findViewById(R.id.seekBar);
        mPowerSeekBar.setOnSeekBarChangeListener(mPowerSeekBarListener);

        RecyclerView.ItemDecoration itemDecoration = new DividerItemDecoration(this, DividerItemDecoration.VERTICAL);
        mRecyclerView.addItemDecoration(itemDecoration);

        // use this setting to improve performance if you know that changes
        // in content do not change the layout size of the RecyclerView
        //mRecyclerView.setHasFirelativeLayoutxedSize(true);

        // use a linear layout manager
        mLayoutManager = new LinearLayoutManager(this);
        mRecyclerView.setLayoutManager(mLayoutManager);
        mReaders = ReaderManager.sharedInstance().getReaderList();
        mAdapter = new ReaderViewAdapter(mReaders);
        mRecyclerView.setAdapter( mAdapter );

        ItemClickSupport.addTo(mRecyclerView).setOnItemClickListener(new ItemClickSupport.OnItemClickListener() {
            @Override
            public void onItemClicked(RecyclerView recyclerView, int position, View v)
            {
                int oldIndex = mAdapter.getSelectedRowIndex();
//                mAdapter.setSelectedRowIndex(position);
                if( oldIndex == position )
                {
                    // Offer disconnect
//                    offerDisconnect(mReaders.list().get(position), position);
                    Toast.makeText(DeviceListActivity.this, "Device already connected", Toast.LENGTH_SHORT).show();
                }
                else
                {
                    // Warn about disconnection of other reader
                    if( oldIndex >= 0 )
                    {
                        offerChange(mReaders.list().get(oldIndex), oldIndex, mReaders.list().get(position), position);
                    }
                    else
                    {
                        returnSelectedReader(position, DEVICE_CONNECT);
                    }
                }
            }
        });

        // Set result CANCELED in case the user backs out
        setResult(Activity.RESULT_CANCELED);

        // Configure the ReaderManager when necessary
        ReaderManager.create(getApplicationContext());

        // Add observers for changes
        ReaderManager.sharedInstance().getReaderList().readerAddedEvent().addObserver(mAddedObserver);
        ReaderManager.sharedInstance().getReaderList().readerUpdatedEvent().addObserver(mUpdatedObserver);
        ReaderManager.sharedInstance().getReaderList().readerRemovedEvent().addObserver(mRemovedObserver);


        // See if there is a reader currently in use
        Intent intent = getIntent();
        int startIndex = intent.getIntExtra(EXTRA_DEVICE_INDEX, -1);
        if( startIndex >= 0 )
        {
            mSelectedReader = ReaderManager.sharedInstance().getReaderList().list().get(startIndex);
            mRecyclerView.scrollToPosition(startIndex);

            ((LinearLayout)findViewById(R.id.connected_device_lay)).removeAllViews();
            View view = getLayoutInflater().inflate(R.layout.reader_list_row, null, false);
            ((TextView)view.findViewById(R.id.nameTextView)).setText(mSelectedReader.getDisplayName());
            ((TextView)view.findViewById(R.id.nameTextView)).setTypeface(((TextView)view.findViewById(R.id.nameTextView)).getTypeface(), Typeface.BOLD );
            ((ImageView)view.findViewById(R.id.imageView)).setVisibility(View.VISIBLE);
            ((LinearLayout)findViewById(R.id.connected_device_lay)).addView(view);
        }

        ((ImageView) findViewById((R.id.back_img))).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                finish();
            }
        });

        ((LinearLayout) findViewById((R.id.connected_device_lay))).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                int position = mReaders.list().indexOf(mSelectedReader);
                offerDisconnect(mReaders.list().get(position), position);
            }
        });

        commander().setTakeNoAction(TriState.YES);
        mPowerSeekBar.setMax(19);
        if(commander().getOutputPower() == -1)
        {
            mPowerSeekBar.setProgress(Constant.powerValue - 10);
        }
        else
        {
            mPowerSeekBar.setProgress(commander().getOutputPower()-10);
            Constant.powerValue = commander().getOutputPower();
        }

        TextView saveButton = findViewById(R.id.save_power_txt);
        saveButton.setOnClickListener(new View.OnClickListener() {
            public void onClick(View arg0) {
                if (mSelectedReader != null){
                    if (mSelectedReader.isConnected()) {
                        Constant.powerValue = mPowerSeekBar.getProgress() + 10;
                        commander().setOutputPower(Constant.powerValue);
                        Context context = getApplicationContext();
                        CharSequence text = "RFID Output Power Updated Successfully";

                        Toast.makeText(context, text, Toast.LENGTH_SHORT).show();
                    }
                }
            }
        });

        ImageView searchBtn = findViewById(R.id.search_img);
        searchBtn.setOnClickListener(new View.OnClickListener() {
            public void onClick(View arg0) {
                startActivity(new Intent(android.provider.Settings.ACTION_BLUETOOTH_SETTINGS));
            }
        });
    }


    private void updatePowerSetting(int level)	{
        int mPowerLevel = level +10;
        String powerlevel = String.valueOf(mPowerLevel);
        mPowerLevelTextView.setText("Output Power: "+ powerlevel);
    }
    private InventoryCommand commander(){
        return InventoryCommand.synchronousCommand();
    }

    void offerDisconnect(Reader reader,int index)
    {
        final int confirmedIndex = index;
        AlertDialog.Builder builder = new AlertDialog.Builder(this);
        builder.setMessage("From:  " + reader.getDisplayName() )
                .setTitle("Disconnect?");

        builder.setPositiveButton("Disconnect", new DialogInterface.OnClickListener() {
            public void onClick(DialogInterface dialog, int id)
            {
                returnSelectedReader(confirmedIndex, DEVICE_DISCONNECT);
            }
        });

        builder.setNegativeButton("Cancel", new DialogInterface.OnClickListener() {
            public void onClick(DialogInterface dialog, int id)
            {
                // User cancelled the dialog
            }
        });
        AlertDialog dialog = builder.create();
        dialog.show();
    }


    void offerChange(Reader oldReader, int oldIndex, Reader newReader, int newIndex)
    {
        final int restoreIndex = oldIndex;
        final int confirmedIndex = newIndex;
        AlertDialog.Builder builder = new AlertDialog.Builder(this);
        builder.setMessage(String.format( "From:  %s\n\nTo:  %s", oldReader.getDisplayName(), newReader.getDisplayName() ) )
                .setTitle("Change Reader?");

        builder.setPositiveButton("Change", new DialogInterface.OnClickListener() {
            public void onClick(DialogInterface dialog, int id)
            {
                returnSelectedReader(confirmedIndex, DEVICE_CHANGE);
            }
        });

        builder.setNegativeButton("Cancel", new DialogInterface.OnClickListener() {
            public void onClick(DialogInterface dialog, int id)
            {
                // User cancelled - revert to previous
                mAdapter.setSelectedRowIndex(restoreIndex);
            }
        });
        AlertDialog dialog = builder.create();
        dialog.show();
    }


    void returnSelectedReader(int readerIndex, int action)
    {
        // Create the result Intent
        Intent intent = new Intent();
        intent.putExtra(EXTRA_DEVICE_INDEX, readerIndex);
        intent.putExtra(EXTRA_DEVICE_ACTION, action);

        CustomReactPackage.mUHFRFIDModule.resultFromActivity(readerIndex, action);
        // Set result and finish this Activity
        setResult(Activity.RESULT_OK, intent);
        showProgressDialog((action == DEVICE_DISCONNECT)? "Disconnecting...": "Connecting...");
        final Handler handler = new Handler();
        handler.postDelayed(new Runnable() {
            @Override
            public void run() {
                hideProgressDialog();
                updateConnectedDesign(readerIndex, action);
                commander().setOutputPower(Constant.powerValue);
            }
        }, 7000);
    }

    public void updateConnectedDesign (int readerIndex, int action) {

        if (action == DEVICE_DISCONNECT) {
            ((LinearLayout)findViewById(R.id.connected_device_lay)).removeAllViews();
            View view = getLayoutInflater().inflate(R.layout.reader_list_row, null, false);
            ((LinearLayout)findViewById(R.id.connected_device_lay)).addView(view);
            ((LinearLayout)findViewById(R.id.connected_device_lay)).setVisibility(View.INVISIBLE);
            mAdapter.setSelectedRowIndex(-1);
        } else {
            mSelectedReader = mReaders.list().get(readerIndex);
            if (mSelectedReader.isConnected()) {
                ((LinearLayout)findViewById(R.id.connected_device_lay)).setVisibility(View.VISIBLE);
                ((LinearLayout) findViewById(R.id.connected_device_lay)).removeAllViews();
                View view = getLayoutInflater().inflate(R.layout.reader_list_row, null, false);
                ((TextView) view.findViewById(R.id.nameTextView)).setText(mSelectedReader.getDisplayName());
                ((TextView) view.findViewById(R.id.nameTextView)).setTypeface(((TextView) view.findViewById(R.id.nameTextView)).getTypeface(), Typeface.BOLD);
                ((ImageView) view.findViewById(R.id.imageView)).setVisibility(View.VISIBLE);
                ((LinearLayout) findViewById(R.id.connected_device_lay)).addView(view);
                mAdapter.setSelectedRowIndex(readerIndex);
            } else {
                Toast.makeText(this, "Unable to connect to the device. Please check the device.", Toast.LENGTH_SHORT).show();
            }
        }

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

    @Override
    protected void onDestroy() {
        super.onDestroy();

        // Remove observers for changes
        ReaderManager.sharedInstance().getReaderList().readerAddedEvent().removeObserver(mAddedObserver);
        ReaderManager.sharedInstance().getReaderList().readerUpdatedEvent().removeObserver(mUpdatedObserver);
        ReaderManager.sharedInstance().getReaderList().readerRemovedEvent().removeObserver(mRemovedObserver);
    }

    @Override
    protected void onPause()
    {
        super.onPause();
//        ReaderManager.sharedInstance().onPause();

    }

    @Override
    protected void onResume()
    {
        super.onResume();
        ReaderManager.sharedInstance().onResume();

        // The Activity may start with a reader already connected (perhaps by another App)
        // Update the ReaderList which will add any unknown reader, firing events appropriately
        ReaderManager.sharedInstance().updateList();
        if(mAdapter!=null)
        {
            // Reapply the selected Reader in case the Reader list has been changed while paused
            mAdapter.setSelectedRowIndex(-1);
            mAdapter.notifyDataSetChanged();
            int readerIndex = ReaderManager.sharedInstance().getReaderList().list().indexOf(mSelectedReader);
            mAdapter.setSelectedRowIndex(readerIndex);
        }
    }

    Observable.Observer<Reader> mAddedObserver = new Observable.Observer<Reader>()
    {
        @Override
        public void update(Observable<? extends Reader> observable, Reader reader)
        {
            if (D) { Log.d(TAG, "Reader arrived"); }
            int readerIndex = ReaderManager.sharedInstance().getReaderList().list().indexOf(reader);
            mAdapter.notifyItemInserted(readerIndex);

            // If the new Reader is connected over USB then this will be auto selected and
            if( reader.hasTransportOfType(TransportType.USB))
            {
                returnSelectedReader(readerIndex, mSelectedReader != null ? DEVICE_CHANGE : DEVICE_CONNECT);
            }
        }
    };

    Observable.Observer<Reader> mUpdatedObserver = new Observable.Observer<Reader>()
    {
        @Override
        public void update(Observable<? extends Reader> observable, Reader reader)
        {
            if (D) { Log.d(TAG, "Reader updated"); }
            int readerIndex = ReaderManager.sharedInstance().getReaderList().list().indexOf(reader);
            mAdapter.notifyItemChanged(readerIndex);
        }
    };

    Observable.Observer<Reader> mRemovedObserver = new Observable.Observer<Reader>()
    {
        @Override
        public void update(Observable<? extends Reader> observable, Reader reader)
        {
            if (D) { Log.d(TAG, "Reader Removed"); }
            int readerIndex = ReaderManager.sharedInstance().getReaderList().list().indexOf(reader);
            if(mAdapter.getSelectedRowIndex() == readerIndex)
            {
                mAdapter.setSelectedRowIndex(-1);
            }
            mAdapter.notifyItemRemoved(readerIndex);
        }
    };

}