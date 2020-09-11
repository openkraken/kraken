import 'dart:async';

import 'package:flutter/services.dart';
import 'package:kraken/kraken.dart';

typedef MethodCallHandler = Future<dynamic> Function(String method, dynamic arguments);

enum IntegrationMode {
  dart,
  native
}

class KrakenMethodChannel {
  // Flutter method channel used to communicate with public SDK API
  // Only works when integration wieh public SDK API
  static MethodChannel _nativeChannel = MethodChannel('kraken')
    ..setMethodCallHandler((call) async {
      String method = call.method;
      KrakenController controller = KrakenController.getControllerOfJSContextId(0);

      if ('reload' == method) {
        await controller.reload();
      } else if (controller.methodChannel._jsMethodCallHandler != null) {
        return controller.methodChannel._jsMethodCallHandler(method, call.arguments);
      }

      return Future<dynamic>.value(null);
    });

  final IntegrationMode mode;

  KrakenMethodChannel(this.mode, KrakenController controller);

  MethodCallHandler _methodCallHandler;
  MethodCallHandler get methodCallHandler => _methodCallHandler;
  set methodCallHandler(MethodCallHandler value) {
    assert(value != null);
    _methodCallHandler = value;
  }

  MethodCallHandler _jsMethodCallHandler;
  set jsMethodCallHandler(MethodCallHandler value) {
    assert(value != null);
    _jsMethodCallHandler = value;
  }

  // Support for method channel
  Future<dynamic> _invokeNativeMethod(String method, List args) async {
    Map<String, dynamic> argsWrap = {
      'method': method,
      'args': args,
    };
    return _nativeChannel.invokeMethod('invokeMethod', argsWrap);
  }

  Future<dynamic> _invokeDartMethod(String method, List args) async {
    return _methodCallHandler(method, args);
  }

  Future<dynamic> invokeMethod(String method, dynamic arguments) async {
    if (_jsMethodCallHandler == null) {
      return null;
    }

    return _jsMethodCallHandler(method, arguments);
  }

  Future<dynamic> proxyMethods(String method, List args) {
    if (mode == IntegrationMode.dart) {
      return _invokeDartMethod(method, args);
    } else {
      return _invokeNativeMethod(method, args);
    }
  }

  Future<String> getUrl() async {
    // Maybe url of zip bundle or js bundle
    String url = await _nativeChannel.invokeMethod('getUrl');

    // @NOTE(zhuoling.lcl): Android plugin protocol cannot return `null` directly, which
    // will case method channel invoke failed with exception, use empty
    // string to represent null value.
    if (url != null && url.isEmpty) url = null;
    return url;
  }
}
