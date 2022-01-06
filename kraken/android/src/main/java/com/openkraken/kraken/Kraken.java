package com.openkraken.kraken;

import android.os.Handler;
import android.os.Looper;

import java.util.HashMap;
import java.util.Map;

import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.plugins.PluginRegistry;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class Kraken {

  private String url;
  private String dynamicLibraryPath;
  private FlutterEngine flutterEngine;

  private MethodChannel.MethodCallHandler handler;
  private static Map<FlutterEngine, Kraken> sdkMap = new HashMap<>();

  public Kraken(FlutterEngine flutterEngine) {
    if (flutterEngine != null) {
      this.flutterEngine = flutterEngine;
      sdkMap.put(flutterEngine, this);
    } else {
      throw new IllegalArgumentException("flutter engine must not be null.");
    }
  }

  public static Kraken get(FlutterEngine engine) {
    return sdkMap.get(engine);
  }

  public void registerMethodCallHandler(MethodChannel.MethodCallHandler handler) {
    this.handler = handler;
  }
  /**
   * Load url.
   * @param url
   */
  public void loadUrl(String url) {
    this.url = url;
  }

  /**
   * Set the dynamic library path.
   * @param value
   */
  public void setDynamicLibraryPath(String value) {
    this.dynamicLibraryPath = value;
  }

  public String getUrl() {
    return url;
  }

  public String getDynamicLibraryPath() {
    return dynamicLibraryPath != null ? dynamicLibraryPath : "";
  }

  public void _handleMethodCall(MethodCall call, MethodChannel.Result result) {
    if (this.handler != null) {
      this.handler.onMethodCall(call, result);
    } else {
      result.error("No handler found.", null, null);
    }
  }

  public void invokeMethod(final String method, final Object arguments) {
    new Handler(Looper.getMainLooper()).post(new Runnable() {
      @Override
      public void run() {
        if (flutterEngine != null) {
          PluginRegistry pluginRegistry = flutterEngine.getPlugins();
          KrakenPlugin krakenSDKPlugin = (KrakenPlugin) pluginRegistry.get(KrakenPlugin.class);
          if (krakenSDKPlugin != null && krakenSDKPlugin.channel != null) {
            krakenSDKPlugin.channel.invokeMethod(method, arguments);
          }
        }
      }
    });
  }

  public void reload() {
    if (flutterEngine != null) {
      PluginRegistry pluginRegistry = flutterEngine.getPlugins();
      KrakenPlugin krakenSDKPlugin = (KrakenPlugin) pluginRegistry.get(KrakenPlugin.class);
      if (krakenSDKPlugin != null) {
        krakenSDKPlugin.reload();
      }
    }
  }

  public void destroy() {
    sdkMap.remove(flutterEngine);
    flutterEngine = null;
  }
}
