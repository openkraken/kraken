import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

typedef MethodCallback = Future<dynamic> Function(MethodCall call);
class KrakenSDKPlugin {
  static VoidCallback reloadListener;
  static MethodChannel _channel = MethodChannel('kraken_sdk')
    ..setMethodCallHandler((call) async {
    if ('reload' == call.method && reloadListener != null) {
      await reloadListener();
    } else {
      return _handler(call);
    }
    return Future<dynamic>.value(null);
  });

  static MethodCallback _handler;

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
    _handler = handler;
  }

  // Support for method channel
  static Future<dynamic> invokeMethod(String method, List args) async {
    Map<String, dynamic> argsWrap = {
      'method': method,
      'args': args,
    };

    return await _channel.invokeMethod('invokeMethod', argsWrap);
  }
}
