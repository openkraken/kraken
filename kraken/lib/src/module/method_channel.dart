import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

typedef MethodCallback = Future<dynamic> Function(MethodCall call);

class KrakenMethodChannel {
  static VoidCallback _reloadHandler;
  static MethodCallback _methodCallHandler;
//  static MethodChannel _channel = MethodChannel('kraken')
//    ..setMethodCallHandler((call) async {
//    if ('reload' == call.method && _reloadHandler != null) {
//      await _reloadHandler();
//    } else if (_methodCallHandler != null) {
//      return _methodCallHandler(call);
//    }
//
//    return Future<dynamic>.value(null);
//  });

  static void setReloadHandler(VoidCallback reloadHandler) {
    _reloadHandler = reloadHandler;
  }

  static void setMethodCallHandler(Future<dynamic> handler(MethodCall call)) {
    _methodCallHandler = handler;
  }

  // Support for method channel
  static Future<dynamic> invokeMethod(String method, List args) async {
    Map<String, dynamic> argsWrap = {
      'method': method,
      'args': args,
    };

//    return await _channel.invokeMethod('invokeMethod', argsWrap);
  }

  static Future<String> getPlatformVersion() async {
//    return await _channel.invokeMethod('getPlatformVersion');
  }

  static Future<String> getUrl() async {
    // Maybe url of zip bundle or js bundle
//    return await _channel.invokeMethod('getUrl');
  }

}
