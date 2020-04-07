import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class KrakenSDKPlugin {
  static VoidCallback reloadListener;
  static const MethodChannel _channel = const MethodChannel('kraken_sdk');

  static void setReloadListener(VoidCallback reloadListener) {
    KrakenSDKPlugin.reloadListener = reloadListener;
  }

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<String> getUrl() async {
    return await _channel.invokeMethod('getUrl');
  }

  static void setMethodCallback(Future<dynamic> handler(MethodCall call)) {
    _channel.setMethodCallHandler(handler);
  }

  // Support for method channel
  static Future<dynamic> invokeMethod(String method, args) async {
    Map<String, String> argsWrap = {
      'method': method,
      'args': args,
    };
    return await _channel.invokeMethod('invokeMethod', argsWrap);
  }
}
