package com.InnovaZones.RNTreeIZHips.serialio;

import android.bluetooth.BluetoothDevice;
import android.content.Context;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.arch.core.internal.SafeIterableMap;
import androidx.recyclerview.widget.RecyclerView;

import com.InnovaZones.RNTreeIZHips.R;

import java.util.ArrayList;


public class DeviceListAdapter extends RecyclerView.Adapter<DeviceListAdapter.ViewHolder>{

    ArrayList<BluetoothDevice> BtDevicesList;
    private Context mContext;

    public DeviceListAdapter(ArrayList<BluetoothDevice> BtDevicesList, Context context) {
        this.BtDevicesList = BtDevicesList;
        this.mContext = context;
    }

    @Override
    public ViewHolder onCreateViewHolder(ViewGroup viewGroup, int position) {
        View v = LayoutInflater.from(viewGroup.getContext()).inflate(R.layout.device_list_row, viewGroup, false);
        return new ViewHolder(v);
    }

    @Override
    public void onBindViewHolder(ViewHolder viewHolder, int position) {
          final BluetoothDevice bluetoothDevice = BtDevicesList.get(position);
        viewHolder.nameTextViewRFID.setText(bluetoothDevice.getName());
    }


    @Override
    public int getItemCount() {
        return BtDevicesList == null ? 0 : BtDevicesList.size();
    }


    public class ViewHolder extends RecyclerView.ViewHolder implements View.OnClickListener {
        public TextView nameTextViewRFID;
        public ViewHolder(View itemView) {
            super(itemView);
            nameTextViewRFID = (TextView) itemView.findViewById(R.id.nameTextViewRFID);
            nameTextViewRFID.setOnClickListener(this);

        }

        @Override
        public void onClick(View view) {

            ((DeviceListRFIDActivity)mContext).OnClickReadrItem(view,getAdapterPosition());

        }
    }
}