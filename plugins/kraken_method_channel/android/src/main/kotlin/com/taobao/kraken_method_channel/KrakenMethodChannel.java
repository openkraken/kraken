package com.taobao.kraken_method_channel;

import android.os.Handler;
import android.os.Looper;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

interface OnKrakenMe {
  // this can be any type of method
  void onGeekEvent();
}

public class KrakenMethodChannel {
  private static KrakenMethodChannel instance;
  private KrakenMethodChannelPlugin plugin;
  private MethodChannel channel;
  private MethodCallHandler handler;

  public static KrakenMethodChannel getInstance() {
    if (instance == null) {
      synchronized (KrakenMethodChannel.class) {
        if (instance == null) {
          instance = new KrakenMethodChannel();
        }
      }
    }
    return instance;
  }

  public void setMessageHandler(MethodCallHandler handler) {
    this.handler = handler;
  }

  public void handleMessageCall(MethodCall call, Result result) {
    if (this.handler != null) {
      this.handler.onMethodCall(call, result);
    }
  }

  public void invokeMethod(final String method, final Object arguments) {
    final KrakenMethodChannel self = this;
    new Handler(Looper.getMainLooper()).post(new Runnable() {
      @Override
      public void run() {
        self.channel.invokeMethod(method, arguments);
      }
    });
  }

  public void onAttach(KrakenMethodChannelPlugin plugin, MethodChannel channel) {
    this.plugin = plugin;
    this.channel = channel;
  }

  public void onDetach() {
    this.plugin = null;
  }
}
