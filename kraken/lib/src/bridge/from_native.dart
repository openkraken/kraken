import 'dart:convert';
import 'dart:ffi';
import 'dart:ui';

import 'package:ffi/ffi.dart';
import 'package:flutter/painting.dart';
import 'package:kraken/bridge.dart';
import 'package:kraken/element.dart';
import 'package:kraken/kraken.dart';
import 'package:kraken/module.dart';
import 'package:requests/requests.dart';

import 'platform.dart';

// Steps for using dart:ffi to call a Dart function from C:
// 1. Import dart:ffi.
// 2. Create a typedef with the FFI type signature of the Dart function.
// 3. Create a typedef for the variable that you’ll use when calling the Dart function.
// 4. Open the dynamic library that register in the C.
// 5. Get a reference to the C function, and put it into a variable.
// 6. Call from C.

// Register InvokeUIManager
typedef Native_InvokeUIManager = Pointer<Utf8> Function(Pointer<Utf8>);
typedef Native_RegisterInvokeUIManager = Void Function(Pointer<NativeFunction<Native_InvokeUIManager>>);
typedef Dart_RegisterInvokeUIManager = void Function(Pointer<NativeFunction<Native_InvokeUIManager>>);

final Dart_RegisterInvokeUIManager _registerInvokeUIManager =
    nativeDynamicLibrary.lookup<NativeFunction<Native_RegisterInvokeUIManager>>('registerInvokeUIManager').asFunction();

const String BATCH_UPDATE = 'batchUpdate';

String handleAction(List directive) {
  String action = directive[0];
  List payload = directive[1];

  var result;
  try {
    result = ElementManager.applyAction(action, payload);
  } catch (error, stackTrace) {
    print(error);
    print(stackTrace);
  }

  if (result == null) {
    return '';
  }

  switch (result.runtimeType) {
    case String:
      return result;
    case Map:
    case List:
      return jsonEncode(result);
    default:
      return result.toString();
  }
}

String invokeUIManager(String json) {
  dynamic directive = jsonDecode(json);
  if (directive[0] == BATCH_UPDATE) {
    List<dynamic> directiveList = directive[1];
    List<String> result = [];
    for (dynamic item in directiveList) {
      result.add(handleAction(item as List));
    }
    return result.join(',');
  } else {
    return handleAction(directive);
  }
}

Pointer<Utf8> _invokeUIManager(Pointer<Utf8> json) {
  String result = invokeUIManager(Utf8.fromUtf8(json));
  return Utf8.toUtf8(result);
}

void registerInvokeUIManager() {
  Pointer<NativeFunction<Native_InvokeUIManager>> pointer = Pointer.fromFunction(_invokeUIManager);
  _registerInvokeUIManager(pointer);
}

// Register InvokeModule
typedef NativeAsyncModuleCallback = Void Function(Pointer<Utf8>, Pointer<Void>);
typedef DartAsyncModuleCallback = void Function(Pointer<Utf8>, Pointer<Void>);

typedef Native_InvokeModule = Pointer<Utf8> Function(
    Pointer<Utf8>, Pointer<NativeFunction<NativeAsyncModuleCallback>>, Pointer<Void>);
typedef Native_RegisterInvokeModule = Void Function(Pointer<NativeFunction<Native_InvokeModule>>);
typedef Dart_RegisterInvokeModule = void Function(Pointer<NativeFunction<Native_InvokeModule>>);

final Dart_RegisterInvokeModule _registerInvokeModule =
    nativeDynamicLibrary.lookup<NativeFunction<Native_RegisterInvokeModule>>('registerInvokeModule').asFunction();

String invokeModule(String json, DartAsyncModuleCallback callback, Pointer<Void> context) {
  dynamic args = jsonDecode(json);
  String method = args[0];
  String result = '';
  if (method == 'getConnectivity') {
    getConnectivity((String json) {
      callback(Utf8.toUtf8(json), context);
    });
  } else if (method == 'onConnectivityChanged') {
    onConnectivityChanged();
  } else if (method == 'fetch') {
    List fetchArgs = args[1];
    String url = fetchArgs[0];
    Map<String, dynamic> options = fetchArgs[1];
    fetch(url, options).then((Response response) {
      response.raiseForStatus();
      String json = jsonEncode(['', response.statusCode, response.content()]);
      callback(Utf8.toUtf8(json), context);
    }).catchError((e) {
      String errorMessage = e is HTTPException ? e.message : e.toString();
      String json = jsonEncode([errorMessage, e.response.statusCode, '']);
      callback(Utf8.toUtf8(json), context);
    });
  } else if (method == 'getDeviceInfo') {
    getDeviceInfo().then((String json) {
      callback(Utf8.toUtf8(json), context);
    });
  } else if (method == 'getHardwareConcurrency') {
    result = getHardwareConcurrency().toString();
  } else if (method == 'AsyncStorage.getItem') {
    List getItemArgs = args[1];
    String key = getItemArgs[0];
    AsyncStorage.getItem(key).then((String value) {
      callback(Utf8.toUtf8(value), context);
    });
  } else if (method == 'AsyncStorage.setItem') {
    List setItemArgs = args[1];
    String key = setItemArgs[0];
    String value = setItemArgs[1];
    AsyncStorage.setItem(key, value).then((bool o) {
      callback(Utf8.toUtf8(value), context);
    });
  } else if (method == 'AsyncStorage.removeItem') {
    List removeItemArgs = args[1];
    String key = removeItemArgs[0];
    AsyncStorage.removeItem(key).then((bool value) {
      callback(Utf8.toUtf8(value.toString()), context);
    });
  } else if (method == 'AsyncStorage.getAllKeys') {
    AsyncStorage.getAllKeys().then((Set<String> set) {
      List<String> list = List.from(set);
      callback(Utf8.toUtf8(jsonEncode(list)), context);
    });
  } else if (method == 'AsyncStorage.clear') {
    AsyncStorage.clear().then((bool value) {
      callback(Utf8.toUtf8(value.toString()), context);
    });
  }

  return result;
}

Pointer<Utf8> _invokeModule(
    Pointer<Utf8> json, Pointer<NativeFunction<NativeAsyncModuleCallback>> callback, Pointer<Void> context) {
  String result = invokeModule(Utf8.fromUtf8(json), callback.asFunction(), context);
  return Utf8.toUtf8(result);
}

void registerInvokeModule() {
  Pointer<NativeFunction<Native_InvokeModule>> pointer = Pointer.fromFunction(_invokeModule);
  _registerInvokeModule(pointer);
}

// Register reloadApp
typedef Native_ReloadApp = Void Function();
typedef Native_RegisterReloadApp = Void Function(Pointer<NativeFunction<Native_ReloadApp>>);
typedef Dart_RegisterReloadApp = void Function(Pointer<NativeFunction<Native_ReloadApp>>);

final Dart_RegisterReloadApp _registerReloadApp =
    nativeDynamicLibrary.lookup<NativeFunction<Native_RegisterReloadApp>>('registerReloadApp').asFunction();

void _reloadApp() {
  try {
    reloadApp();
  } catch (err, stack) {
    print('$err\n$stack');
  }
}

void registerReloadApp() {
  Pointer<NativeFunction<Native_ReloadApp>> pointer = Pointer.fromFunction(_reloadApp);
  _registerReloadApp(pointer);
}

typedef NativeAsyncCallback = Void Function(Pointer<Void> context);
typedef NativeRAFAsyncCallback = Void Function(Pointer<Void> context, Double data);
typedef DartAsyncCallback = void Function(Pointer<Void> context);
typedef DartRAFAsyncCallback = void Function(Pointer<Void> context, double data);

// Register requestBatchUpdate
typedef Native_RequestBatchUpdate = Void Function(Pointer<NativeFunction<NativeAsyncCallback>>, Pointer<Void>);
typedef Native_RegisterRequestBatchUpdate = Void Function(Pointer<NativeFunction<Native_RequestBatchUpdate>>);
typedef Dart_RegisterRequestBatchUpdate = void Function(Pointer<NativeFunction<Native_RequestBatchUpdate>>);

final Dart_RegisterRequestBatchUpdate _registerRequestBatchUpdate = nativeDynamicLibrary
    .lookup<NativeFunction<Native_RegisterRequestBatchUpdate>>('registerRequestBatchUpdate')
    .asFunction();

void _requestBatchUpdate(Pointer<NativeFunction<NativeAsyncCallback>> callback, Pointer<Void> context) {
  return requestBatchUpdate((Duration timeStamp) {
    DartAsyncCallback func = callback.asFunction();
    func(context);
  });
}

void registerRequestBatchUpdate() {
  Pointer<NativeFunction<Native_RequestBatchUpdate>> pointer = Pointer.fromFunction(_requestBatchUpdate);
  _registerRequestBatchUpdate(pointer);
}

// Register setTimeout
typedef Native_SetTimeout = Int32 Function(Pointer<NativeFunction<NativeAsyncCallback>>, Pointer<Void>, Int32);
typedef Native_RegisterSetTimeout = Void Function(Pointer<NativeFunction<Native_SetTimeout>>);
typedef Dart_RegisterSetTimeout = void Function(Pointer<NativeFunction<Native_SetTimeout>>);

final Dart_RegisterSetTimeout _registerSetTimeout =
    nativeDynamicLibrary.lookup<NativeFunction<Native_RegisterSetTimeout>>('registerSetTimeout').asFunction();

int _setTimeout(Pointer<NativeFunction<NativeAsyncCallback>> callback, Pointer<Void> context, int timeout) {
  return setTimeout(timeout, () {
    DartAsyncCallback func = callback.asFunction();
    func(context);
  });
}

const int SET_TIMEOUT_ERROR = -1;
void registerSetTimeout() {
  Pointer<NativeFunction<Native_SetTimeout>> pointer = Pointer.fromFunction(_setTimeout, SET_TIMEOUT_ERROR);
  _registerSetTimeout(pointer);
}

// Register setInterval
typedef Native_SetInterval = Int32 Function(Pointer<NativeFunction<NativeAsyncCallback>>, Pointer<Void>, Int32);
typedef Native_RegisterSetInterval = Void Function(Pointer<NativeFunction<Native_SetTimeout>>);
typedef Dart_RegisterSetInterval = void Function(Pointer<NativeFunction<Native_SetTimeout>>);

final Dart_RegisterSetInterval _registerSetInterval =
    nativeDynamicLibrary.lookup<NativeFunction<Native_RegisterSetTimeout>>('registerSetInterval').asFunction();

int _setInterval(Pointer<NativeFunction<NativeAsyncCallback>> callback, Pointer<Void> context, int timeout) {
  return setInterval(timeout, () {
    DartAsyncCallback func = callback.asFunction();
    func(context);
  });
}

const int SET_INTERVAL_ERROR = -1;
void registerSetInterval() {
  Pointer<NativeFunction<Native_SetInterval>> pointer = Pointer.fromFunction(_setInterval, SET_INTERVAL_ERROR);
  _registerSetInterval(pointer);
}

// Register clearTimeout
typedef Native_ClearTimeout = Void Function(Int32);
typedef Native_RegisterClearTimeout = Void Function(Pointer<NativeFunction<Native_ClearTimeout>>);
typedef Dart_RegisterClearTimeout = void Function(Pointer<NativeFunction<Native_ClearTimeout>>);

final Dart_RegisterClearTimeout _registerClearTimeout =
    nativeDynamicLibrary.lookup<NativeFunction<Native_RegisterClearTimeout>>('registerClearTimeout').asFunction();

void _clearTimeout(int timerId) {
  return clearTimeout(timerId);
}

void registerClearTimeout() {
  Pointer<NativeFunction<Native_ClearTimeout>> pointer = Pointer.fromFunction(_clearTimeout);
  _registerClearTimeout(pointer);
}

// Register requestAnimationFrame
typedef Native_RequestAnimationFrame = Int32 Function(Pointer<NativeFunction<NativeRAFAsyncCallback>>, Pointer<Void>);
typedef Native_RegisterRequestAnimationFrame = Void Function(Pointer<NativeFunction<Native_RequestAnimationFrame>>);
typedef Dart_RegisterRequestAnimationFrame = void Function(Pointer<NativeFunction<Native_RequestAnimationFrame>>);

final Dart_RegisterRequestAnimationFrame _registerRequestAnimationFrame = nativeDynamicLibrary
    .lookup<NativeFunction<Native_RegisterRequestAnimationFrame>>('registerRequestAnimationFrame')
    .asFunction();

int _requestAnimationFrame(Pointer<NativeFunction<NativeRAFAsyncCallback>> callback, Pointer<Void> context) {
  return requestAnimationFrame((double highResTimeStamp) {
    DartRAFAsyncCallback func = callback.asFunction();
    func(context, highResTimeStamp);
  });
}

const int RAF_ERROR_CODE = -1;
// `-1` represents some error occurred in requestAnimationFrame execution.
void registerRequestAnimationFrame() {
  Pointer<NativeFunction<Native_RequestAnimationFrame>> pointer =
      Pointer.fromFunction(_requestAnimationFrame, RAF_ERROR_CODE);
  _registerRequestAnimationFrame(pointer);
}

// Register cancelAnimationFrame
typedef Native_CancelAnimationFrame = Void Function(Int32);
typedef Native_RegisterCancelAnimationFrame = Void Function(Pointer<NativeFunction<Native_CancelAnimationFrame>>);
typedef Dart_RegisterCancelAnimationFrame = void Function(Pointer<NativeFunction<Native_CancelAnimationFrame>>);

final Dart_RegisterCancelAnimationFrame _registerCancelAnimationFrame = nativeDynamicLibrary
    .lookup<NativeFunction<Native_RegisterCancelAnimationFrame>>('registerCancelAnimationFrame')
    .asFunction();

void _cancelAnimationFrame(int timerId) {
  cancelAnimationFrame(timerId);
}

void registerCancelAnimationFrame() {
  Pointer<NativeFunction<Native_CancelAnimationFrame>> pointer = Pointer.fromFunction(_cancelAnimationFrame);
  _registerCancelAnimationFrame(pointer);
}

// Register devicePixelRatio
typedef Native_DevicePixelRatio = Double Function();
typedef Native_RegisterDevicePixelRatio = Void Function(Pointer<NativeFunction<Native_DevicePixelRatio>>);
typedef Dart_RegisterDevicePixelRatio = void Function(Pointer<NativeFunction<Native_DevicePixelRatio>>);

final Dart_RegisterDevicePixelRatio _registerDevicePixelRatio = nativeDynamicLibrary
    .lookup<NativeFunction<Native_RegisterDevicePixelRatio>>('registerDevicePixelRatio')
    .asFunction();

double _devicePixelRatio() {
  return window.devicePixelRatio;
}

void registerDevicePixelRatio() {
  Pointer<NativeFunction<Native_DevicePixelRatio>> pointer = Pointer.fromFunction(_devicePixelRatio, 0.0);
  _registerDevicePixelRatio(pointer);
}

// Register platformBrightness
typedef Native_PlatformBrightness = Pointer<Utf8> Function();
typedef Native_RegisterPlatformBrightness = Void Function(Pointer<NativeFunction<Native_PlatformBrightness>>);
typedef Dart_RegisterPlatformBrightness = void Function(Pointer<NativeFunction<Native_PlatformBrightness>>);

final Dart_RegisterPlatformBrightness _registerPlatformBrightness = nativeDynamicLibrary
    .lookup<NativeFunction<Native_RegisterPlatformBrightness>>('registerPlatformBrightness')
    .asFunction();

final Pointer<Utf8> _dark = Utf8.toUtf8('dark');
final Pointer<Utf8> _light = Utf8.toUtf8('light');

Pointer<Utf8> _platformBrightness() {
  return window.platformBrightness == Brightness.dark ? _dark : _light;
}

void registerPlatformBrightness() {
  Pointer<NativeFunction<Native_PlatformBrightness>> pointer = Pointer.fromFunction(_platformBrightness);
  _registerPlatformBrightness(pointer);
}

// Register onPlatformBrightnessChanged
typedef Native_OnPlatformBrightnessChanged = Void Function();
typedef Native_RegisterOnPlatformBrightnessChanged = Void Function(
    Pointer<NativeFunction<Native_OnPlatformBrightnessChanged>>);
typedef Dart_RegisterOnPlatformBrightnessChanged = void Function(
    Pointer<NativeFunction<Native_OnPlatformBrightnessChanged>>);

final Dart_RegisterOnPlatformBrightnessChanged _registerOnPlatformBrightnessChanged = nativeDynamicLibrary
    .lookup<NativeFunction<Native_RegisterOnPlatformBrightnessChanged>>('registerOnPlatformBrightnessChanged')
    .asFunction();

void _onPlatformBrightnessChanged() {
  // TODO: should avoid overwrite old event handler
  window.onPlatformBrightnessChanged = invokeOnPlatformBrightnessChangedCallback;
}

void registerOnPlatformBrightnessChanged() {
  Pointer<NativeFunction<Native_OnPlatformBrightnessChanged>> pointer =
      Pointer.fromFunction(_onPlatformBrightnessChanged);
  _registerOnPlatformBrightnessChanged(pointer);
}

// Register getScreen
class ScreenSize extends Struct {}

typedef Native_GetScreen = Pointer<ScreenSize> Function();
typedef Native_RegisterGetScreen = Void Function(Pointer<NativeFunction<Native_GetScreen>>);
typedef Dart_RegisterGetScreen = void Function(Pointer<NativeFunction<Native_GetScreen>>);

final Dart_RegisterGetScreen _registerGetScreen =
    nativeDynamicLibrary.lookup<NativeFunction<Native_RegisterGetScreen>>('registerGetScreen').asFunction();

Pointer<ScreenSize> _getScreen() {
  Size size = window.physicalSize;
  return createScreen(size.width / window.devicePixelRatio, size.height / window.devicePixelRatio);
}

void registerGetScreen() {
  Pointer<NativeFunction<Native_GetScreen>> pointer = Pointer.fromFunction(_getScreen);
  _registerGetScreen(pointer);
}

typedef Native_StartFlushCallbacksInUIThread = Void Function();
typedef Native_RegisterFlushCallbacksInUIThread = Void Function(
    Pointer<NativeFunction<Native_StartFlushCallbacksInUIThread>>);
typedef Dart_RegisterFlushCallbacksInUIThread = void Function(
    Pointer<NativeFunction<Native_StartFlushCallbacksInUIThread>>);

final Dart_RegisterFlushCallbacksInUIThread _registerStartFlushCallbacksInUIThread = nativeDynamicLibrary
    .lookup<NativeFunction<Native_RegisterFlushCallbacksInUIThread>>('registerStartFlushCallbacksInUIThread')
    .asFunction();

void _startFlushCallbacksInUIThread() {
  startFlushCallbacksInUIThread();
}

void registerStartFlushCallbacksInUIThread() {
  Pointer<NativeFunction<Native_StartFlushCallbacksInUIThread>> pointer =
      Pointer.fromFunction(_startFlushCallbacksInUIThread);
  _registerStartFlushCallbacksInUIThread(pointer);
}

typedef Native_StopFlushCallbacksInUIThread = Void Function();
typedef Native_RegisterStopFlushCallbacksInUIThread = Void Function(
    Pointer<NativeFunction<Native_StopFlushCallbacksInUIThread>>);
typedef Dart_RegisterStopFlushCallbacksInUIThread = void Function(
    Pointer<NativeFunction<Native_StopFlushCallbacksInUIThread>>);

final Dart_RegisterFlushCallbacksInUIThread _registerStopFlushCallbacksInUIThread = nativeDynamicLibrary
    .lookup<NativeFunction<Native_RegisterStopFlushCallbacksInUIThread>>('registerStopFlushCallbacksInUIThread')
    .asFunction();

void _stopFlushCallbacksInUIThread() {
  stopFlushCallbacksInUIThread();
}

void registerStopFlushCallbacksInUIThread() {
  Pointer<NativeFunction<Native_StartFlushCallbacksInUIThread>> pointer =
      Pointer.fromFunction(_stopFlushCallbacksInUIThread);
  _registerStopFlushCallbacksInUIThread(pointer);
}

void registerDartMethodsToCpp() {
  registerInvokeUIManager();
  registerInvokeModule();
  registerRequestBatchUpdate();
  registerReloadApp();
  registerSetTimeout();
  registerSetInterval();
  registerClearTimeout();
  registerRequestAnimationFrame();
  registerCancelAnimationFrame();
  registerGetScreen();
  registerDevicePixelRatio();
  registerPlatformBrightness();
  registerOnPlatformBrightnessChanged();
  registerStartFlushCallbacksInUIThread();
  registerStopFlushCallbacksInUIThread();
}
