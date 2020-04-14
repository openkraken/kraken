package com.taobao.kraken;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/**
 * KrakenBundlePlugin
 */
public class KrakenSDKPlugin implements FlutterPlugin, MethodCallHandler {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    public MethodChannel channel;
    private FlutterEngine flutterEngine;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        channel = new MethodChannel(flutterPluginBinding.getFlutterEngine().getDartExecutor(), "kraken");
        flutterEngine = flutterPluginBinding.getFlutterEngine();
        channel.setMethodCallHandler(this);
    }

    public void reload() {
        if (channel != null) {
            channel.invokeMethod("reload", null);
        }
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        Kraken kraken = Kraken.get(flutterEngine);
        if (call.method.equals("getUrl")) {
            result.success(kraken == null ? "" : kraken.getUrl());
        } else if (call.method.equals("invokeMethod")) {
            String method = call.argument("method");
            Object args = call.argument("args");
            assert method != null;
            MethodCall callWrap = new MethodCall(method, args);
            kraken._handleMethodCall(callWrap, result);
        } else {
            result.notImplemented();
        }
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
        Kraken.get(flutterEngine).destory();
        flutterEngine = null;
    }
}
