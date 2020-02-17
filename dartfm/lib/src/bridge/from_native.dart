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

ElementAction getAction(String action) {
  switch (action) {
    case 'createElement':
      return ElementAction.createElement;
    case 'createTextNode':
      return ElementAction.createTextNode;
    case 'insertAdjacentNode':
      return ElementAction.insertAdjacentNode;
    case 'removeNode':
      return ElementAction.removeNode;
    case 'setStyle':
      return ElementAction.setStyle;
    case 'setProperty':
      return ElementAction.setProperty;
    case 'removeProperty':
      return ElementAction.removeProperty;
    case 'addEvent':
      return ElementAction.addEvent;
    case 'removeEvent':
      return ElementAction.removeEvent;
    case 'method':
      return ElementAction.method;
    default:
      return null;
  }
}

String handleDirective(List directive) {
  ElementAction action = getAction(directive[0]);
  List payload = directive[1];
  var result = ElementManager().applyAction(action, payload);

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
      result.add(handleDirective(item as List));
    }
    return result.join(',');
  } else {
    return handleDirective(directive);
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

// Register InvokeModuleManager
typedef Native_InvokeModuleManager = Pointer<Utf8> Function(Pointer<Utf8>, Int32);
typedef Native_RegisterInvokeModuleManager = Void Function(Pointer<NativeFunction<Native_InvokeModuleManager>>);
typedef Dart_RegisterInvokeModuleManager = void Function(Pointer<NativeFunction<Native_InvokeModuleManager>>);

final Dart_RegisterInvokeModuleManager _registerInvokeModuleManager = nativeDynamicLibrary
    .lookup<NativeFunction<Native_RegisterInvokeModuleManager>>('registerInvokeModuleManager')
    .asFunction();

String invokeModuleManager(String json, int callbackId) {
  dynamic args = jsonDecode(json);
  String method = args[0];

  var result;
  if (method == 'getConnectivity') {
    getConnectivity(callbackId);
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

Pointer<Utf8> _invokeModuleManager(Pointer<Utf8> json, int callbackId) {
  String result = invokeModuleManager(Utf8.fromUtf8(json), callbackId);
  return Utf8.toUtf8(result);
}

void registerInvokeModuleManager() {
  Pointer<NativeFunction<Native_InvokeModuleManager>> pointer = Pointer.fromFunction(_invokeModuleManager);
  _registerInvokeModuleManager(pointer);
}

// Register reloadApp
typedef Native_ReloadApp = Void Function();
typedef Native_RegisterReloadApp = Void Function(Pointer<NativeFunction<Native_ReloadApp>>);
typedef Dart_RegisterReloadApp = void Function(Pointer<NativeFunction<Native_ReloadApp>>);

final Dart_RegisterReloadApp _registerReloadApp =
    nativeDynamicLibrary.lookup<NativeFunction<Native_RegisterReloadApp>>('registerReloadApp').asFunction();

void _reloadApp() {
  reloadApp();
}

void registerReloadApp() {
  Pointer<NativeFunction<Native_ReloadApp>> pointer = Pointer.fromFunction(_reloadApp);
  _registerReloadApp(pointer);
}

typedef NativeAsyncCallback = Void Function(Pointer<Void> context);
typedef DartAsyncCallback = void Function(Pointer<Void> context);
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

void registerSetTimeout() {
  Pointer<NativeFunction<Native_SetTimeout>> pointer = Pointer.fromFunction(_setTimeout, 0);
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

void registerSetInterval() {
  Pointer<NativeFunction<Native_SetInterval>> pointer = Pointer.fromFunction(_setInterval, 0);
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
typedef Native_RequestAnimationFrame = Int32 Function(Pointer<NativeFunction<NativeAsyncCallback>>, Pointer<Void>);
typedef Native_RegisterRequestAnimationFrame = Void Function(Pointer<NativeFunction<Native_RequestAnimationFrame>>);
typedef Dart_RegisterRequestAnimationFrame = void Function(Pointer<NativeFunction<Native_RequestAnimationFrame>>);

final Dart_RegisterRequestAnimationFrame _registerRequestAnimationFrame = nativeDynamicLibrary
    .lookup<NativeFunction<Native_RegisterRequestAnimationFrame>>('registerRequestAnimationFrame')
    .asFunction();

int _requestAnimationFrame(Pointer<NativeFunction<NativeAsyncCallback>> callback, Pointer<Void> context) {
  return requestAnimationFrame(() {
    DartAsyncCallback func = callback.asFunction();
    func(context);
  });
}

const int RAF_ERROR_CODE = -1;
// `-1` represents some error occured in requestAnimationFrame execution.
void registerRequestAnimationFrame() {
  Pointer<NativeFunction<Native_RequestAnimationFrame>> pointer = Pointer.fromFunction(_requestAnimationFrame, RAF_ERROR_CODE);
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

// Register fetch
typedef Native_InvokeFetch = Void Function(Int32, Pointer<Utf8>, Pointer<Utf8>);
typedef Native_RegisterInvokeFetch = Void Function(Pointer<NativeFunction<Native_InvokeFetch>>);
typedef Dart_RegisterInvokeFetch = void Function(Pointer<NativeFunction<Native_InvokeFetch>>);

final Dart_RegisterInvokeFetch _registerInvokeFetch =
    nativeDynamicLibrary.lookup<NativeFunction<Native_RegisterInvokeFetch>>('registerInvokeFetch').asFunction();

void _invokeFetch(int callbackId, Pointer<Utf8> url, Pointer<Utf8> json) {
  fetch(Utf8.fromUtf8(url), Utf8.fromUtf8(json)).then((Response response) {
    response.raiseForStatus();
    invokeFetchCallback(callbackId, '', response.statusCode, response.content());
  }).catchError((e) {
    if (e is HTTPException) {
      invokeFetchCallback(callbackId, e.message, e.response.statusCode, "");
    } else {
      invokeFetchCallback(callbackId, e.toString(), e.response.statusCode, "");
    }
  });
}

void registerInvokeFetch() {
  Pointer<NativeFunction<Native_InvokeFetch>> pointer = Pointer.fromFunction(_invokeFetch);
  _registerInvokeFetch(pointer);
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

void registerDartMethodsToCpp() {
  registerInvokeUIManager();
  registerInvokeModuleManager();
  registerReloadApp();
  registerSetTimeout();
  registerSetInterval();
  registerClearTimeout();
  registerRequestAnimationFrame();
  registerCancelAnimationFrame();
  registerGetScreen();
  registerInvokeFetch();
  registerDevicePixelRatio();
  registerPlatformBrightness();
  registerOnPlatformBrightnessChanged();
}
