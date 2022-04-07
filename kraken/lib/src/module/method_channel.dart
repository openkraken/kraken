/*
 * Copyright (C) 2021-present The Kraken authors. All rights reserved.
 */
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:kraken/kraken.dart';

typedef MethodCallCallback = Future<dynamic> Function(String method, Object? arguments);
const String METHOD_CHANNEL_NOT_INITIALIZED = 'MethodChannel not initialized.';
const String CONTROLLER_NOT_INITIALIZED = 'Kraken controller not initialized.';
const String METHOD_CHANNEL_NAME = 'MethodChannel';

class MethodChannelModule extends BaseModule {
  @override
  String get name => METHOD_CHANNEL_NAME;
  MethodChannelModule(ModuleManager? moduleManager) : super(moduleManager);

  @override
  void dispose() {}

  @override
  String invoke(String method, params, callback) {
    if (method == 'invokeMethod') {
      _invokeMethodFromJavaScript(moduleManager!.controller, params[0], params[1]).then((result) {
        callback(data: result);
      }).catchError((e, stack) {
        callback(error: '$e\n$stack');
      });
    }
    return '';
  }
}

void setJSMethodCallCallback(KrakenController controller) {
  if (controller.methodChannel == null) return;

  controller.methodChannel!._onJSMethodCall = (String method, arguments) async {
    try {
      controller.module.moduleManager.emitModuleEvent(METHOD_CHANNEL_NAME, data: [method, arguments]);
    } catch (e, stack) {
      print('Error invoke module event: $e, $stack');
    }
  };
}

abstract class KrakenMethodChannel {
  MethodCallCallback? _onJSMethodCallCallback;

  set _onJSMethodCall(MethodCallCallback? value) {
    assert(value != null);
    _onJSMethodCallCallback = value;
  }

  Future<dynamic> invokeMethodFromJavaScript(String method, List arguments);

  static void setJSMethodCallCallback(KrakenController controller) {
    controller.methodChannel?._onJSMethodCall = (String method, arguments) async {
      controller.module.moduleManager.emitModuleEvent(METHOD_CHANNEL_NAME, data: [method, arguments]);
    };
  }
}

class KrakenJavaScriptChannel extends KrakenMethodChannel {
  Future<dynamic> invokeMethod(String method, arguments) async {
    MethodCallCallback? jsMethodCallCallback = _onJSMethodCallCallback;
    if (jsMethodCallCallback != null) {
      return jsMethodCallCallback(method, arguments);
    } else {
      return null;
    }
  }

  MethodCallCallback? _methodCallCallback;

  MethodCallCallback? get methodCallCallback => _methodCallCallback;

  set onMethodCall(MethodCallCallback? value) {
    assert(value != null);
    _methodCallCallback = value;
  }

  @override
  Future<dynamic> invokeMethodFromJavaScript(String method, List arguments) {
    MethodCallCallback? methodCallCallback = _methodCallCallback;
    if (methodCallCallback != null) {
      return _methodCallCallback!(method, arguments);
    } else {
      return Future.value(null);
    }
  }
}

class KrakenNativeChannel extends KrakenMethodChannel {
  // Flutter method channel used to communicate with public SDK API
  // Only works when integration wieh public SDK API

  static final MethodChannel _nativeChannel = getKrakenMethodChannel()
    ..setMethodCallHandler((call) async {
      String method = call.method;
      KrakenController? controller = KrakenController.getControllerOfJSContextId(0);

      if (controller == null) return;

      if ('reload' == method) {
        await controller.reload();
      } else if (controller.methodChannel!._onJSMethodCallCallback != null) {
        return controller.methodChannel!._onJSMethodCallCallback!(method, call.arguments);
      }

      return Future<dynamic>.value(null);
    });

  @override
  Future<dynamic> invokeMethodFromJavaScript(String method, List arguments) async {
    Map<String, dynamic> argsWrap = {
      'method': method,
      'args': arguments,
    };
    return _nativeChannel.invokeMethod('invokeMethod', argsWrap);
  }

  Future<String?> getUrl() async {
    // Maybe url of zip bundle or js bundle
    String? url = await _nativeChannel.invokeMethod('getUrl');

    // @NOTE(zhuoling.lcl): Android plugin protocol cannot return `null` directly, which
    // will case method channel invoke failed with exception, use empty
    // string to represent null value.
    if (url != null && url.isEmpty) url = null;
    return url;
  }

  static Future<void> syncDynamicLibraryPath() async {
    String? path = await _nativeChannel.invokeMethod('getDynamicLibraryPath');
    if (path != null) {
      KrakenDynamicLibrary.dynamicLibraryPath = path;
    }
  }
}

Future<dynamic> _invokeMethodFromJavaScript(KrakenController? controller, String method, List args) {
  KrakenMethodChannel? krakenMethodChannel = controller?.methodChannel;
  if (krakenMethodChannel != null) {
    return krakenMethodChannel.invokeMethodFromJavaScript(method, args);
  } else {
    return Future.error(FlutterError(METHOD_CHANNEL_NOT_INITIALIZED));
  }
}
