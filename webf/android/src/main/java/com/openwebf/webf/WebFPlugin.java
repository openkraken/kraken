package com.openwebf.webf;

import android.content.Context;

import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/**
 * WebFPlugin
 */
public class WebFPlugin implements FlutterPlugin, MethodCallHandler {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    public MethodChannel channel;
    private FlutterEngine flutterEngine;
    private Context mContext;
    private WebF mWebF;

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
        final MethodChannel channel = new MethodChannel(registrar.messenger(), "webf");
      WebFPlugin plugin = new WebFPlugin();
        plugin.mContext = registrar.context();
        channel.setMethodCallHandler(plugin);
    }

    @Override
    public void onAttachedToEngine(FlutterPluginBinding flutterPluginBinding) {
        mContext = flutterPluginBinding.getApplicationContext();
        channel = new MethodChannel(flutterPluginBinding.getFlutterEngine().getDartExecutor(), "webf");
        flutterEngine = flutterPluginBinding.getFlutterEngine();
        channel.setMethodCallHandler(this);
    }

    public void reload() {
        if (channel != null) {
            channel.invokeMethod("reload", null);
        }
    }

    WebF getWebF() {
      if (mWebF == null) {
        mWebF = WebF.get(flutterEngine);
      }
      return mWebF;
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        switch (call.method) {
          case "getUrl": {
            WebF webf = getWebF();
            result.success(webf == null ? "" : webf.getUrl());
            break;
          }

          case "getDynamicLibraryPath": {
            WebF webf = getWebF();
            result.success(webf == null ? "" : webf.getDynamicLibraryPath());
            break;
          }

          case "invokeMethod": {
            WebF webf = getWebF();
            if (webf != null) {
              String method = call.argument("method");
              Object args = call.argument("args");
              assert method != null;
              MethodCall callWrap = new MethodCall(method, args);
              webf._handleMethodCall(callWrap, result);
            } else {
              result.error("WebF instance not found.", null, null);
            }
            break;
          }

          case "getTemporaryDirectory":
            result.success(getTemporaryDirectory());
            break;

          default:
            result.notImplemented();
        }
    }

    @Override
    public void onDetachedFromEngine(FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
        WebF webf = WebF.get(flutterEngine);
        if (webf == null) return;
        webf.destroy();
        flutterEngine = null;
    }

    private String getTemporaryDirectory() {
      return mContext.getCacheDir().getPath() + "/WebF";
    }
}
