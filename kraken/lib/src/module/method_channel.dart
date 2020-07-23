import 'dart:async';

import 'package:flutter/services.dart';
import 'package:kraken/kraken.dart';

typedef MethodCallHandler = Future<dynamic> Function(String methodd, dynamic arguments);

final String NAME_METHOD_SPLIT = '__';

class KrakenMethodChannel {
  static MethodChannel _channel = MethodChannel('kraken')
    ..setMethodCallHandler((call) async {
      List<String> group = call.method.split(NAME_METHOD_SPLIT);
      String name = group[0];
      String method = group[1];
      KrakenController controller = KrakenController.getControllerOfName(name);

      if ('reload' == method) {
        await controller.reload();
      } else if (controller.methodChannel.methodCallHandler != null) {
        return controller.methodChannel.methodCallHandler(method, call.arguments);
      }
      return Future<dynamic>.value(null);
    });

  KrakenMethodChannel(this._name, KrakenController controller);

  final String _name;
  MethodCallHandler _methodCallHandler;
  MethodCallHandler get methodCallHandler => _methodCallHandler;

  void setMethodCallHandler(MethodCallHandler handler) {
    _methodCallHandler = handler;
  }

  // Support for method channel
  Future<dynamic> invokeMethod(String method, List args) async {
    Map<String, dynamic> argsWrap = {
      'method': method,
      'args': args,
    };

    return await _channel.invokeMethod('${_name}${NAME_METHOD_SPLIT}invokeMethod', argsWrap);
  }

  Future<String> getUrl() async {
    // Maybe url of zip bundle or js bundle
    String url = await _channel.invokeMethod('${_name}${NAME_METHOD_SPLIT}getUrl');

    // @NOTE(zhuoling.lcl): Android plugin protocol cannot return `null` directly, which
    // will case method channel invoke failed with exception, use empty
    // string to represent null value.
    if (url != null && url.isEmpty) url = null;
    return url;
  }
}
