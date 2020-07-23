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
    KrakenSDKPlugin plugin = new KrakenSDKPlugin();
    channel.setMethodCallHandler(plugin);
  }

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "kraken");
    channel.setMethodCallHandler(this);
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }

  public void reload() {
    if (channel != null) {
      channel.invokeMethod("reload", null);
    }
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    String[] group = call.method.split(Kraken.NAME_METHOD_SPLIT);
    String name = group[0];
    String method = group[1];

    Kraken kraken = Kraken.get(name);

    if (kraken == null) {
      result.success(null);
      return;
    }

    if (method.equals("getUrl")) {
      result.success(kraken.getUrl());
    } else if (method.equals("invokeMethod")) {
      String m = call.argument("method");
      Object args = call.argument("args");
      assert m != null;
      MethodCall callWrap = new MethodCall(m, args);
      kraken._handleMethodCall(callWrap, result);
    } else {
      result.notImplemented();
    }
  }
}
