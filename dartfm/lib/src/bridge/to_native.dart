import 'package:kraken/kraken.dart';
import 'package:kraken/src/bridge/native_structs.dart';

import 'platform.dart';
import 'dart:ffi';
import 'package:ffi/ffi.dart';

typedef Native_EvaluateScripts = Void Function(
    Pointer<Utf8>, Pointer<Utf8>, Int32);
typedef Dart_EvaluateScripts = void Function(Pointer<Utf8>, Pointer<Utf8>, int);

typedef Native_InitJSEngine = Void Function();
typedef Dart_InitJSEngine = void Function();

typedef Native_ReloadJSContext = Void Function();
typedef Dart_ReloadJSContext = void Function();

typedef Native_InvokeKrakenCallback = Void Function(Pointer<Utf8>);
typedef Dart_InvokeKrakenCallback = void Function(Pointer<Utf8>);

typedef Native_CreateScreen = Pointer<ScreenSize> Function(
    Double width, Double height);
typedef Dart_CreateScreen = Pointer<ScreenSize> Function(
    double width, double height);

final Dart_EvaluateScripts _evaluateScripts = nativeDynamicLibrary
    .lookup<NativeFunction<Native_EvaluateScripts>>('evaluateScripts')
    .asFunction();

final Dart_InitJSEngine _initJsEngine = nativeDynamicLibrary
    .lookup<NativeFunction<Native_InitJSEngine>>('initJsEngine')
    .asFunction();

final Dart_ReloadJSContext _reloadJSContext = nativeDynamicLibrary
    .lookup<NativeFunction<Native_ReloadJSContext>>('reloadJsContext')
    .asFunction();

final Dart_InvokeKrakenCallback _invokeKrakenCallback = nativeDynamicLibrary
    .lookup<NativeFunction<Native_InvokeKrakenCallback>>('invokeKrakenCallback')
    .asFunction();

final Dart_CreateScreen _createScreen = nativeDynamicLibrary
    .lookup<NativeFunction<Native_CreateScreen>>('createScreen')
    .asFunction();

void evaluateScripts(String code, String url, int line) {
  Pointer<Utf8> _code = Utf8.toUtf8(code);
  Pointer<Utf8> _url = Utf8.toUtf8(url);
  _evaluateScripts(_code, _url, line);
}

void initJSEngine() {
  _initJsEngine();
}

void invokeKrakenCallback(String data) {
  Pointer<Utf8> buf = Utf8.toUtf8(data);
  _invokeKrakenCallback(buf);
}

Future<void> reloadJSContext() async {
  return Future.microtask(() {
    _reloadJSContext();
  });
}

Pointer<ScreenSize> createScreen(double width, double height) {
  return _createScreen(width, height);
}
