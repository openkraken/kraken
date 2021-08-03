package com.openkraken.kraken;

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
public class KrakenPlugin implements FlutterPlugin, MethodCallHandler {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    public MethodChannel channel;
    private FlutterEngine flutterEngine;

    // This static function is optional and equivalent to onAttachedToEngine. It supports the old
    // pre-Flutter-1.12 Android projects. You are encouraged to continue supporting
    // plugin registration via this function while apps migrate to use the new Android APIs
    // post-flutter-1.12 via https://flutter.dev/go/android-project-migration.
    //
    // It is encouraged to share logic between onAttachedToEngine and registerWith to keep
    // them functionally equivalent. Only one of onAttachedToEngine or registerWith will be called
    // depending on the user's project. onAttachedToEngine or registerWith must both be defined
    // in the same class.
    public static void registerWith(Registrar registrar) {
        final MethodChannel channel = new MethodChannel(registrar.messenger(), "kraken");
        KrakenPlugin plugin = new KrakenPlugin();
        channel.setMethodCallHandler(plugin);
    }

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
        if (kraken == null) {
          result.notImplemented();
          return;
        }

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
        Kraken kraken = Kraken.get(flutterEngine);
        if (kraken == null) return;
        kraken.destroy();
        flutterEngine = null;
    }
}
