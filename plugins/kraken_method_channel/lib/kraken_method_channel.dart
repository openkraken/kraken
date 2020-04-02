import 'dart:async';

import 'package:flutter/services.dart';

class KrakenMethodChannel {
  static const MethodChannel _channel =
      const MethodChannel('kraken_method_channel');

  static void setMessageCallback(Future<dynamic> handler(MethodCall call)) {
    _channel.setMethodCallHandler(handler);
  }

  static Future<dynamic> invokeMethod(String method, dynamic args) async {
    dynamic result = await _channel.invokeMethod<dynamic>(method, args);
    return result;
  }
}