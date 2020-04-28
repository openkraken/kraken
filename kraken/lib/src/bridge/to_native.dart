import 'dart:ffi';
import 'dart:convert';
import 'package:ffi/ffi.dart';
import 'package:kraken/element.dart';

import 'from_native.dart';
import 'platform.dart';

// Steps for using dart:ffi to call a C function from Dart:
// 1. Import dart:ffi.
// 2. Create a typedef with the FFI type signature of the C function.
// 3. Create a typedef for the variable that you’ll use when calling the C function.
// 4. Open the dynamic library that contains the C function.
// 5. Get a reference to the C function, and put it into a variable.
// 6. Call the C function.

// Register invokeEventListener
typedef Native_InvokeEventListener = Void Function(Int32, Pointer<Utf8>);
typedef Dart_InvokeEventListener = void Function(int, Pointer<Utf8>);

final Dart_InvokeEventListener _invokeEventListener = nativeDynamicLibrary
    .lookup<NativeFunction<Native_InvokeEventListener>>('invokeEventListener')
    .asFunction();

void invokeEventListener(int type, String data) {
  _invokeEventListener(type, Utf8.toUtf8(data));
}

const UI_EVENT = 0;
const MODULE_EVENT = 1;

void emitUIEvent(String data) {
  invokeEventListener(UI_EVENT, data);
}

void emitModuleEvent(String data) {
  invokeEventListener(MODULE_EVENT, data);
}

// Register invokeOnloadCallback
typedef Native_InvokeOnloadCallback = Void Function();
typedef Dart_InvokeOnLoadCallback = void Function();

final Dart_InvokeOnLoadCallback _invokeOnloadCallback = nativeDynamicLibrary
    .lookup<NativeFunction<Native_InvokeOnloadCallback>>('invokeOnloadCallback')
    .asFunction();

void invokeOnloadCallback() {
  _invokeOnloadCallback();
}

void invokeOnPlatformBrightnessChangedCallback() {
  String json = jsonEncode([WINDOW_ID, Event('colorschemechange')]);
  emitUIEvent(json);
}

// Register createScreen
typedef Native_CreateScreen = Pointer<ScreenSize> Function(Double, Double);
typedef Dart_CreateScreen = Pointer<ScreenSize> Function(double, double);

final Dart_CreateScreen _createScreen = nativeDynamicLibrary
    .lookup<NativeFunction<Native_CreateScreen>>('createScreen')
    .asFunction();

Pointer<ScreenSize> createScreen(double width, double height) {
  return _createScreen(width, height);
}

// Register evaluateScripts
typedef Native_EvaluateScripts = Void Function(
    Pointer<Utf8>, Pointer<Utf8>, Int32);
typedef Dart_EvaluateScripts = void Function(Pointer<Utf8>, Pointer<Utf8>, int);

final Dart_EvaluateScripts _evaluateScripts = nativeDynamicLibrary
    .lookup<NativeFunction<Native_EvaluateScripts>>('evaluateScripts')
    .asFunction();

void evaluateScripts(String code, String url, int line) {
  Pointer<Utf8> _code = Utf8.toUtf8(code);
  Pointer<Utf8> _url = Utf8.toUtf8(url);
  try {
    _evaluateScripts(_code, _url, line);
  } catch (e, stack) {
    print('$e\n$stack');
  }
}

// Register initJsEngine
typedef Native_InitJSEngine = Void Function();
typedef Dart_InitJSEngine = void Function();

final Dart_InitJSEngine _initJsEngine = nativeDynamicLibrary
    .lookup<NativeFunction<Native_InitJSEngine>>('initJsEngine')
    .asFunction();

void initJSEngine() {
  _initJsEngine();
}

// Register reloadJsContext
typedef Native_ReloadJSContext = Void Function();
typedef Dart_ReloadJSContext = void Function();

final Dart_ReloadJSContext _reloadJSContext = nativeDynamicLibrary
    .lookup<NativeFunction<Native_ReloadJSContext>>('reloadJsContext')
    .asFunction();

Future<void> reloadJSContext() async {
  return Future.microtask(() {
    _reloadJSContext();
  });
}

// Register flushUITask
typedef Native_FlushUITask = Void Function();
typedef Dart_FlushUITask = void Function();

final Dart_FlushUITask _flushUITask = nativeDynamicLibrary
    .lookup<NativeFunction<Native_FlushUITask>>('flushUITask')
    .asFunction();

void flushUITask() {
  _flushUITask();
}
