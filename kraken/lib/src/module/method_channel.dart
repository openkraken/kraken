import 'dart:async';

import 'package:flutter/services.dart';
import 'package:kraken/kraken.dart';

typedef MethodCallCallback = Future<dynamic> Function(String method, dynamic arguments);

Future<dynamic> invokeMethodFromJavaScript(KrakenController controller, String method, List args) {
  return controller.methodChannel._invokeMethodFromJavaScript(method, args);
}

void onJSMethodCall(KrakenController controller, MethodCallCallback value) {
  controller.methodChannel._onJSMethodCall = value;
}

class KrakenMethodChannel {
  MethodCallCallback _onJSMethodCallCallback;
  set _onJSMethodCall(MethodCallCallback value) {
    assert(value != null);
    _onJSMethodCallCallback = value;
  }

  Future<dynamic> _invokeMethodFromJavaScript(String method, List arguments) async {}
}

class KrakenJavaScriptChannel extends KrakenMethodChannel {
  Future<dynamic> invokeMethod(String method, dynamic arguments) async {
    if (_onJSMethodCallCallback == null) {
      return null;
    }
    return _onJSMethodCallCallback(method, arguments);
  }

  MethodCallCallback _methodCallCallback;
  MethodCallCallback get methodCallCallback => _methodCallCallback;
  set onMethodCall(MethodCallCallback value) {
    assert(value != null);
    _methodCallCallback = value;
  }

  Future<dynamic> _invokeMethodFromJavaScript(String method, List arguments) {
    if (_methodCallCallback == null) return Future.value(null);
    return _methodCallCallback(method, arguments);
  }
}

class KrakenNativeChannel extends KrakenMethodChannel {
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

  Future<dynamic> _invokeMethodFromJavaScript(String method, List arguments) async {
    Map<String, dynamic> argsWrap = {
      'method': method,
      'args': arguments,
    };
    return _nativeChannel.invokeMethod('invokeMethod', argsWrap);
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
