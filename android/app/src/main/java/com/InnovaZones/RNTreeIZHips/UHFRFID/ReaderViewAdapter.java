package com.InnovaZones.RNTreeIZHips.UHFRFID;

import android.content.Context;
import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import com.InnovaZones.RNTreeIZHips.R;
import com.uk.tsl.rfid.asciiprotocol.device.ObservableReaderList;
import com.uk.tsl.rfid.asciiprotocol.device.Reader;
import com.uk.tsl.rfid.asciiprotocol.device.TransportType;

public class ReaderViewAdapter extends RecyclerView.Adapter<ReaderViewAdapter.ReaderViewHolder>
{
    private ObservableReaderList mReaders;

    // Provide a reference to the views for each data item
    // Complex data items may need more than one view per item, and
    // you provide access to all the views for a data item in a view holder
    class ReaderViewHolder extends RecyclerView.ViewHolder
    {
        // each data item is just a string in this case
        TextView mNameTextView;

        ReaderViewHolder(View itemView) {
            super(itemView);

            mNameTextView = (TextView) itemView.findViewById(R.id.nameTextView);
            mContext = itemView.getContext();
        }

        private Context mContext;

        void bind(Reader reader, boolean isSelected)
        {
            mNameTextView.setText(reader.getDisplayName());
//            mNameTextView.setTypeface( mNameTextView.getTypeface(), hasSerialNumber ? Typeface.BOLD : Typeface.ITALIC );
        }
    }


    int getSelectedRowIndex()
    {
        return mSelectedRowIndex;
    }

    void setSelectedRowIndex(int selectedRowIndex)
    {
        if( selectedRowIndex != mSelectedRowIndex)
        {
            int oldRowIndex = mSelectedRowIndex;

            mSelectedRowIndex = selectedRowIndex;

            notifyItemChanged(oldRowIndex);
            notifyItemChanged(mSelectedRowIndex);
        }
    }

    private int mSelectedRowIndex = -1;


    // Provide a suitable constructor (depends on the kind of dataset)
    ReaderViewAdapter(ObservableReaderList readers) {
        mReaders = readers;
    }


    // Create new views (invoked by the layout manager)
    @Override
    @NonNull
    public ReaderViewAdapter.ReaderViewHolder onCreateViewHolder(@NonNull ViewGroup parent,
                                                                 int viewType)
    {
        Context context = parent.getContext();
        LayoutInflater inflater = LayoutInflater.from(context);

        // create a new view
        View readerView = inflater.inflate(R.layout.reader_list_row, parent, false);

        return new ReaderViewHolder(readerView);
    }

    // Replace the contents of a view (invoked by the layout manager)
    @Override
    public void onBindViewHolder(@NonNull ReaderViewHolder holder, int position) {
        // - get element from your dataset at this position
        // - replace the contents of the view with that element
        Reader reader = mReaders.list().get(position);
        holder.bind(reader, position == mSelectedRowIndex);
    }

    // Return the size of your dataset (invoked by the layout manager)
    @Override
    public int getItemCount() {
        return mReaders.list().size();
    }
}