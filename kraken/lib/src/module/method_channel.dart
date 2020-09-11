import 'dart:async';

import 'package:flutter/services.dart';
import 'package:kraken/kraken.dart';

typedef MethodCallCallback = Future<dynamic> Function(String method, dynamic arguments);

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
      } else if (controller.methodChannel._onJSMethodCallCallback != null) {
        return controller.methodChannel._onJSMethodCallCallback(method, call.arguments);
      }

      return Future<dynamic>.value(null);
    });

  final IntegrationMode mode;

  KrakenMethodChannel(this.mode, KrakenController controller);

  MethodCallCallback _methodCalCallback;
  MethodCallCallback get onMethodCall => _methodCalCallback;
  set onMethodCall(MethodCallCallback value) {
    assert(value != null);
    _methodCalCallback = value;
  }

  MethodCallCallback _onJSMethodCallCallback;
  set onJSMethodCall(MethodCallCallback value) {
    assert(value != null);
    _onJSMethodCallCallback = value;
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
    return _methodCalCallback(method, args);
  }

  Future<dynamic> invokeMethod(String method, dynamic arguments) async {
    if (_onJSMethodCallCallback == null) {
      return null;
    }

    return _onJSMethodCallCallback(method, arguments);
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
