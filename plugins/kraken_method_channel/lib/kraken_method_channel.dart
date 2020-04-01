import 'dart:async';

import 'package:flutter/services.dart';

class KrakenMethodChannel {
  static const MethodChannel _channel =
      const MethodChannel('kraken_method_channel');

  static void setMessageCallback(Future<dynamic> handler(MethodCall call)) {
    _channel.setMethodCallHandler(handler);
  }

  static Future<String> invokeMethod(String method, dynamic args) async {
    String result = await _channel.invokeMethod<String>(method, args);
    return result;
  }
}