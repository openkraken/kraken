package com.lyokone.location;

import android.app.Activity;
import android.os.Bundle;
import android.util.Log;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;

/**
 * LocationPlugin
 */
public class LocationPlugin implements FlutterPlugin, ActivityAware {
    private static final String TAG = "LocationPlugin";
    @Nullable
    private MethodCallHandlerImpl methodCallHandler;
    @Nullable
    private StreamHandlerImpl streamHandlerImpl;

    @Nullable
    private FlutterLocation location;

    private FlutterPluginBinding pluginBinding;
    private ActivityPluginBinding activityBinding;
    private Activity activity;

    public static void registerWith(Registrar registrar) {
        FlutterLocation flutterLocation = new FlutterLocation(registrar.context(), registrar.activity());
        flutterLocation.setActivity(registrar.activity());

        MethodCallHandlerImpl handler = new MethodCallHandlerImpl(flutterLocation);
        handler.startListening(registrar.messenger());

        StreamHandlerImpl streamHandlerImpl = new StreamHandlerImpl(flutterLocation);
        streamHandlerImpl.startListening(registrar.messenger());
    }

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
        pluginBinding = binding;

        location = new FlutterLocation(binding.getApplicationContext(), /* activity= */ null);
        methodCallHandler = new MethodCallHandlerImpl(location);
        methodCallHandler.startListening(binding.getBinaryMessenger());

        streamHandlerImpl = new StreamHandlerImpl(location);
        streamHandlerImpl.startListening(binding.getBinaryMessenger());
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        pluginBinding = null;

        if (methodCallHandler != null) {
            methodCallHandler.stopListening();
            methodCallHandler = null;
        }

        if (streamHandlerImpl != null) {
            streamHandlerImpl.stopListening();
            streamHandlerImpl = null;
        }

        location = null;
    }

    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
        location.setActivity(binding.getActivity());

        activityBinding = binding;
        setup(pluginBinding.getBinaryMessenger(), activityBinding.getActivity(), null);
    }

    @Override
    public void onDetachedFromActivity() {
        tearDown();
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {
        onDetachedFromActivity();
    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
        onAttachedToActivity(binding);
    }

    private void setup(final BinaryMessenger messenger, final Activity activity,
            final PluginRegistry.Registrar registrar) {
        this.activity = activity;
        if (registrar != null) {
            // V1 embedding setup for activity listeners.
            registrar.addActivityResultListener(location);
            registrar.addRequestPermissionsResultListener(location);
        } else {
            // V2 embedding setup for activity listeners.
            activityBinding.addActivityResultListener(location);
            activityBinding.addRequestPermissionsResultListener(location);
        }
    }

    private void tearDown() {
        activityBinding.removeActivityResultListener(location);
        activityBinding.removeRequestPermissionsResultListener(location);
        location = null;
    }

}
