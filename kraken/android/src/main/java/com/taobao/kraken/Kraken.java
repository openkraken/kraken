package com.taobao.kraken;

import android.os.Handler;
import android.os.Looper;

import java.util.HashMap;
import java.util.Map;

import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.plugins.PluginRegistry;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class Kraken {
  static String NAME_METHOD_SPLIT = "!!";

  private String url;
  private FlutterEngine flutterEngine;
  // the KrakenWidget's name, use this property to control a KrakenWidget of flutter side.
  private String name;

  private MethodChannel.MethodCallHandler handler;
  private static Map<String, Kraken> sdkMap = new HashMap<>();

  public Kraken(String name, FlutterEngine flutterEngine) {
    if (flutterEngine == null) {
      throw new IllegalArgumentException("flutter engine must not be null!");
    }

    if (name == null) {
      throw new IllegalArgumentException("name must not be null!");
    }

    this.name = name;
    this.flutterEngine = flutterEngine;
    sdkMap.put(name, this);
  }

  public static Kraken get(String name) {
    return sdkMap.get(name);
  }

  public void registerMethodCallHandler(MethodChannel.MethodCallHandler handler) {
    this.handler = handler;
  }
  /**
   * @param url  a absolute URL address which point to a javascript source file.
   */
  public void loadUrl(String url) {
    this.url = url;
  }

  public String getUrl() {
    return url;
  }

  public void _handleMethodCall(MethodCall call, MethodChannel.Result result) {
    if (this.handler != null) {
      this.handler.onMethodCall(call, result);
    }
  }

  public void invokeMethod(final String method, final Object arguments) {
    new Handler(Looper.getMainLooper()).post(new Runnable() {
      @Override
      public void run() {
        if (flutterEngine != null) {
          PluginRegistry pluginRegistry = flutterEngine.getPlugins();
          KrakenSDKPlugin krakenSDKPlugin = (KrakenSDKPlugin) pluginRegistry.get(KrakenSDKPlugin.class);
          if (krakenSDKPlugin != null && krakenSDKPlugin.channel != null) {
            krakenSDKPlugin.channel.invokeMethod(name + NAME_METHOD_SPLIT + method, arguments);
          }
        }
      }
    });
  }

  public void reload() {
    invokeMethod("reload", null);
  }
}
