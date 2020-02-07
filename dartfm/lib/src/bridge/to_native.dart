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

typedef Native_InvokeSetTimeoutCallback = Void Function(Int32);
typedef Dart_InvokeSetTimeoutCallback = void Function(int);

typedef Native_InvokeSetIntervalCallback = Void Function(Int32);
typedef Dart_InvokeSetIntervalCallback = void Function(int);

typedef Native_InvokeRequestAnimationFrame = Void Function(Int32);
typedef Dart_InvokeRequestAnimationFrame = void Function(int);

typedef Native_InvokeFetchCallback = Void Function(
    Int32, Pointer<Utf8>, Int32, Pointer<Utf8>);
typedef Dart_InvokeFetchCallback = void Function(
    int, Pointer<Utf8>, int, Pointer<Utf8>);

typedef Native_InvokeOnloadCallback = Void Function();
typedef Dart_InvokeOnLoadCallback = void Function();

typedef Native_InvokeOnPlatformBrightnessChangedCallback = Void Function();
typedef Dart_InvokeOnPlatformBrightnessChangedCallback = void Function();

typedef Native_FlushUITask = Void Function();
typedef Dart_FlushUITask = void Function();

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

final Dart_InvokeSetTimeoutCallback _invokeSetTimeoutCallback =
    nativeDynamicLibrary
        .lookup<NativeFunction<Native_InvokeSetTimeoutCallback>>(
            'invokeSetTimeoutCallback')
        .asFunction();

final Dart_InvokeSetIntervalCallback _invokeSetIntervalCallback =
    nativeDynamicLibrary
        .lookup<NativeFunction<Native_InvokeSetIntervalCallback>>(
            'invokeSetIntervalCallback')
        .asFunction();

final Dart_InvokeRequestAnimationFrame _invokeRequestAnimationFrame =
    nativeDynamicLibrary
        .lookup<NativeFunction<Native_InvokeRequestAnimationFrame>>(
            'invokeRequestAnimationFrameCallback')
        .asFunction();

final Dart_InvokeFetchCallback _invokeFetchCallback = nativeDynamicLibrary
    .lookup<NativeFunction<Native_InvokeFetchCallback>>('invokeFetchCallback')
    .asFunction();

final Dart_InvokeOnLoadCallback _invokeOnloadCallback = nativeDynamicLibrary
    .lookup<NativeFunction<Native_InvokeOnloadCallback>>('invokeOnloadCallback')
    .asFunction();

final Dart_InvokeOnPlatformBrightnessChangedCallback _invokeOnPlatformBrightnessChangedCallback = nativeDynamicLibrary
    .lookup<NativeFunction<Native_InvokeOnPlatformBrightnessChangedCallback>>('invokeOnPlatformBrightnessChangedCallback')
    .asFunction();

final Dart_FlushUITask _flushUITask = nativeDynamicLibrary
.lookup<NativeFunction<Native_FlushUITask>>('flushUITask').asFunction();

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

void invokeSetTimeout(int callbackId) {
  _invokeSetTimeoutCallback(callbackId);
}

void invokeSetIntervalCallback(int callbackId) {
  _invokeSetIntervalCallback(callbackId);
}

void invokeRequestAnimationFrame(int callbackId) {
  _invokeRequestAnimationFrame(callbackId);
}

void invokeFetchCallback(int callbackId, String error, int statusCode, String body) {
  _invokeFetchCallback(callbackId, Utf8.toUtf8(error), statusCode, Utf8.toUtf8(body));
}

void invokeOnloadCallback() {
  _invokeOnloadCallback();
}

void invokeOnPlatformBrightnessChangedCallback() {
  _invokeOnPlatformBrightnessChangedCallback();
}

void flushUITask() {
  _flushUITask();
}
