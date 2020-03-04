package com.lyokone.location;

import android.util.Log;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.EventChannel.StreamHandler;
import io.flutter.plugin.common.EventChannel.EventSink;

class StreamHandlerImpl implements StreamHandler {
    private static final String TAG = "StreamHandlerImpl";

    private final FlutterLocation location;
    private EventChannel channel;

    private static final String STREAM_CHANNEL_NAME = "lyokone/locationstream";

    StreamHandlerImpl(FlutterLocation location) {
        this.location = location;
    }

    /**
     * Registers this instance as a stream events handler on the given
     * {@code messenger}.
     */
    void startListening(BinaryMessenger messenger) {
        if (channel != null) {
            Log.wtf(TAG, "Setting a method call handler before the last was disposed.");
            stopListening();
        }

        channel = new EventChannel(messenger, STREAM_CHANNEL_NAME);
        channel.setStreamHandler(this);
    }

    /**
     * Clears this instance from listening to stream events.
     */
    void stopListening() {
        if (channel == null) {
            Log.d(TAG, "Tried to stop listening when no MethodChannel had been initialized.");
            return;
        }

        channel.setStreamHandler(null);
        channel = null;
    }

    @Override
    public void onListen(Object arguments, final EventSink eventsSink) {
        location.events = eventsSink;
        if (!location.checkPermissions()) {
            location.requestPermissions();
            return;
        }
        location.startRequestingLocation();
    }

    @Override
    public void onCancel(Object arguments) {
        location.mFusedLocationClient.removeLocationUpdates(location.mLocationCallback);
        location.events = null;
    }

}
