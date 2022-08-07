package com.openwebf.webf;

import android.os.Handler;
import android.os.Looper;

import java.util.HashMap;
import java.util.Map;

import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.plugins.PluginRegistry;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class WebF {

  private String url;
  private String dynamicLibraryPath;
  private FlutterEngine flutterEngine;

  private MethodChannel.MethodCallHandler handler;
  private static Map<FlutterEngine, WebF> sdkMap = new HashMap<>();

  public WebF(FlutterEngine flutterEngine) {
    if (flutterEngine != null) {
      this.flutterEngine = flutterEngine;
      sdkMap.put(flutterEngine, this);
    } else {
      throw new IllegalArgumentException("flutter engine must not be null.");
    }
  }

  public static WebF get(FlutterEngine engine) {
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
          WebFPlugin webFPlugin = (WebFPlugin) pluginRegistry.get(WebFPlugin.class);
          if (webFPlugin != null && webFPlugin.channel != null) {
            webFPlugin.channel.invokeMethod(method, arguments);
          }
        }
      }
    });
  }

  public void reload() {
    if (flutterEngine != null) {
      PluginRegistry pluginRegistry = flutterEngine.getPlugins();
      WebFPlugin webFPlugin = (WebFPlugin) pluginRegistry.get(WebFPlugin.class);
      if (webFPlugin != null) {
        webFPlugin.reload();
      }
    }
  }

  public void destroy() {
    sdkMap.remove(flutterEngine);
    flutterEngine = null;
  }
}
