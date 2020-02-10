import 'dart:convert';
import 'dart:ffi';
import 'dart:ui';

import 'package:ffi/ffi.dart';
import 'package:flutter/painting.dart';
import 'package:kraken/element.dart';
import 'package:kraken/kraken.dart';
import 'package:requests/requests.dart';

import 'fetch.dart';
import 'platform.dart';
import 'screen.dart';
import 'timer.dart';

KrakenTimer timer = KrakenTimer();

// Steps for using dart:ffi to call a Dart function from C:
// 1. Import dart:ffi.
// 2. Create a typedef with the FFI type signature of the Dart function.
// 3. Create a typedef for the variable that you’ll use when calling the Dart function.
// 4. Open the dynamic library that register in the C.
// 5. Get a reference to the C function, and put it into a variable.
// 6. Call from C.

// Register invokeDartFromJS
typedef Native_InvokeDartFromJS = Pointer<Utf8> Function(Pointer<Utf8>);
typedef Native_RegisterInvokeDartFromJS = Void Function(
    Pointer<NativeFunction<Native_InvokeDartFromJS>>);
typedef Dart_RegisterInvokeDartFromJS = void Function(
    Pointer<NativeFunction<Native_InvokeDartFromJS>>);

final Dart_RegisterInvokeDartFromJS _registerInvokeDartFromJS =
    nativeDynamicLibrary
        .lookup<NativeFunction<Native_RegisterInvokeDartFromJS>>(
            'registerInvokeDartFromJS')
        .asFunction();

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

String handleJSToDart(List directive) {
  ElementAction action = getAction(directive[0]);
  List payload = directive[1];
  var result = ElementManager().applyAction(action, payload);

  if (result == null) {
    return '';
  }

  switch (result.runtimeType) {
    case String:
      {
        return result;
      }
    case Map:
    case List:
      return jsonEncode(result);
    default:
      return result.toString();
  }
}

String krakenJsToDart(String args) {
  dynamic directives = jsonDecode(args);
  if (directives[0] == BATCH_UPDATE) {
    List<dynamic> children = directives[1];
    List<String> result = [];
    for (dynamic child in children) {
      result.add(handleJSToDart(child as List));
    }
    return result.join(',');
  } else {
    return handleJSToDart(directives);
  }
}

Pointer<Utf8> _invokeDartFromJS(Pointer<Utf8> data) {
  String args = Utf8.fromUtf8(data);
  String result = krakenJsToDart(args);
  return Utf8.toUtf8(result);
}

void registerInvokeDartFromJS() {
  Pointer<NativeFunction<Native_InvokeDartFromJS>> pointer =
      Pointer.fromFunction(_invokeDartFromJS);
  _registerInvokeDartFromJS(pointer);
}

// Register reloadApp
typedef Native_ReloadApp = Void Function();
typedef Native_RegisterReloadApp = Void Function(
    Pointer<NativeFunction<Native_ReloadApp>>);
typedef Dart_RegisterReloadApp = void Function(
    Pointer<NativeFunction<Native_ReloadApp>>);

final Dart_RegisterReloadApp _registerReloadApp = nativeDynamicLibrary
    .lookup<NativeFunction<Native_RegisterReloadApp>>('registerReloadApp')
    .asFunction();

void _reloadApp() {
  reloadApp();
}

void registerReloadApp() {
  Pointer<NativeFunction<Native_ReloadApp>> pointer =
      Pointer.fromFunction(_reloadApp);
  _registerReloadApp(pointer);
}

// Register setTimeout
typedef Native_SetTimeout = Int32 Function(Int32, Int32);
typedef Native_RegisterSetTimeout = Void Function(
    Pointer<NativeFunction<Native_SetTimeout>>);
typedef Dart_RegisterSetTimeout = void Function(
    Pointer<NativeFunction<Native_SetTimeout>>);

final Dart_RegisterSetTimeout _registerSetTimeout = nativeDynamicLibrary
    .lookup<NativeFunction<Native_RegisterSetTimeout>>('registerSetTimeout')
    .asFunction();

int _setTimeout(int callbackId, int timeout) {
  return timer.setTimeout(callbackId, timeout);
}

void registerSetTimeout() {
  Pointer<NativeFunction<Native_SetTimeout>> pointer =
      Pointer.fromFunction(_setTimeout, 0);
  _registerSetTimeout(pointer);
}

// Register setInterval
typedef Native_SetInterval = Int32 Function(Int32, Int32);
typedef Native_RegisterSetInterval = Void Function(
    Pointer<NativeFunction<Native_SetTimeout>>);
typedef Dart_RegisterSetInterval = void Function(
    Pointer<NativeFunction<Native_SetTimeout>>);

final Dart_RegisterSetInterval _registerSetInterval = nativeDynamicLibrary
    .lookup<NativeFunction<Native_RegisterSetTimeout>>('registerSetInterval')
    .asFunction();

int _setInterval(int callbackId, int timeout) {
  return timer.setInterval(callbackId, timeout);
}

void registerSetInterval() {
  Pointer<NativeFunction<Native_SetInterval>> pointer =
      Pointer.fromFunction(_setInterval, 0);
  _registerSetInterval(pointer);
}

// Register clearTimeout
typedef Native_ClearTimeout = Void Function(Int32);
typedef Native_RegisterClearTimeout = Void Function(
    Pointer<NativeFunction<Native_ClearTimeout>>);
typedef Dart_RegisterClearTimeout = void Function(
    Pointer<NativeFunction<Native_ClearTimeout>>);

final Dart_RegisterClearTimeout _registerClearTimeout = nativeDynamicLibrary
    .lookup<NativeFunction<Native_RegisterClearTimeout>>('registerClearTimeout')
    .asFunction();

void _clearTimeout(int timerId) {
  return timer.clearTimeout(timerId);
}

void registerClearTimeout() {
  Pointer<NativeFunction<Native_ClearTimeout>> pointer =
      Pointer.fromFunction(_clearTimeout);
  _registerClearTimeout(pointer);
}

// Register requestAnimationFrame
typedef Native_RequestAnimationFrame = Int32 Function(Int32);
typedef Native_RegisterRequestAnimationFrame = Void Function(
    Pointer<NativeFunction<Native_RequestAnimationFrame>>);
typedef Dart_RegisterRequestAnimationFrame = void Function(
    Pointer<NativeFunction<Native_RequestAnimationFrame>>);

final Dart_RegisterRequestAnimationFrame _registerRequestAnimationFrame =
    nativeDynamicLibrary
        .lookup<NativeFunction<Native_RegisterRequestAnimationFrame>>(
            'registerRequestAnimationFrame')
        .asFunction();

int _requestAnimationFrame(int callbackId) {
  return timer.requestAnimationFrame(callbackId);
}

void registerRequestAnimationFrame() {
  Pointer<NativeFunction<Native_RequestAnimationFrame>> pointer =
      Pointer.fromFunction(_requestAnimationFrame, 0);
  _registerRequestAnimationFrame(pointer);
}

// Register cancelAnimationFrame
typedef Native_CancelAnimationFrame = Void Function(Int32);
typedef Native_RegisterCancelAnimationFrame = Void Function(
    Pointer<NativeFunction<Native_CancelAnimationFrame>>);
typedef Dart_RegisterCancelAnimationFrame = void Function(
    Pointer<NativeFunction<Native_CancelAnimationFrame>>);

final Dart_RegisterCancelAnimationFrame _registerCancelAnimationFrame =
    nativeDynamicLibrary
        .lookup<NativeFunction<Native_RegisterCancelAnimationFrame>>(
            'registerCancelAnimationFrame')
        .asFunction();

void _cancelAnimationFrame(int timerId) {
  timer.cancelAnimationFrame(timerId);
}

void registerCancelAnimationFrame() {
  Pointer<NativeFunction<Native_CancelAnimationFrame>> pointer =
      Pointer.fromFunction(_cancelAnimationFrame);
  _registerCancelAnimationFrame(pointer);
}

// Register screen
typedef Native_GetScreen = Pointer<ScreenSize> Function();
typedef Native_RegisterGetScreen = Void Function(
    Pointer<NativeFunction<Native_GetScreen>>);
typedef Dart_RegisterGetScreen = void Function(
    Pointer<NativeFunction<Native_GetScreen>>);

final Dart_RegisterGetScreen _registerGetScreen = nativeDynamicLibrary
    .lookup<NativeFunction<Native_RegisterGetScreen>>('registerGetScreen')
    .asFunction();

Pointer<ScreenSize> _getScreen() {
  Size size = window.physicalSize;
  return ScreenSize.fromSize(size);
}

void registerGetScreen() {
  Pointer<NativeFunction<Native_GetScreen>> pointer =
      Pointer.fromFunction(_getScreen);
  _registerGetScreen(pointer);
}

// Register fetch
typedef Native_InvokeFetch = Void Function(Int32, Pointer<Utf8>, Pointer<Utf8>);
typedef Native_RegisterInvokeFetch = Void Function(
    Pointer<NativeFunction<Native_InvokeFetch>>);
typedef Dart_RegisterInvokeFetch = void Function(
    Pointer<NativeFunction<Native_InvokeFetch>>);

final Dart_RegisterInvokeFetch _registerInvokeFetch = nativeDynamicLibrary
    .lookup<NativeFunction<Native_RegisterInvokeFetch>>('registerInvokeFetch')
    .asFunction();

void fetch(int callbackId, String url, String json) {
  Fetch.fetch(url, json).then((Response response) {
    response.raiseForStatus();
    invokeFetchCallback(
        callbackId, '', response.statusCode, response.content());
  }).catchError((e) {
    if (e is HTTPException) {
      invokeFetchCallback(callbackId, e.message, e.response.statusCode, "");
    } else {
      invokeFetchCallback(callbackId, e.toString(), e.response.statusCode, "");
    }
  });
}

void _invokeFetch(int callbackId, Pointer<Utf8> url, Pointer<Utf8> json) {
  fetch(callbackId, Utf8.fromUtf8(url), Utf8.fromUtf8(json));
}

void registerInvokeFetch() {
  Pointer<NativeFunction<Native_InvokeFetch>> pointer =
      Pointer.fromFunction(_invokeFetch);
  _registerInvokeFetch(pointer);
}

// Register devicePixelRatio
typedef Native_DevicePixelRatio = Double Function();
typedef Native_RegisterDevicePixelRatio = Void Function(
    Pointer<NativeFunction<Native_DevicePixelRatio>>);
typedef Dart_RegisterDevicePixelRatio = void Function(
    Pointer<NativeFunction<Native_DevicePixelRatio>>);

final Dart_RegisterDevicePixelRatio _registerDevicePixelRatio =
    nativeDynamicLibrary
        .lookup<NativeFunction<Native_RegisterDevicePixelRatio>>(
            'registerDevicePixelRatio')
        .asFunction();

double _devicePixelRatio() {
  return window.devicePixelRatio;
}

void registerDevicePixelRatio() {
  Pointer<NativeFunction<Native_DevicePixelRatio>> pointer =
      Pointer.fromFunction(_devicePixelRatio, 0.0);
  _registerDevicePixelRatio(pointer);
}

// Register platformBrightness
typedef Native_PlatformBrightness = Pointer<Utf8> Function();
typedef Native_RegisterPlatformBrightness = Void Function(
    Pointer<NativeFunction<Native_PlatformBrightness>>);
typedef Dart_RegisterPlatformBrightness = void Function(
    Pointer<NativeFunction<Native_PlatformBrightness>>);

final Dart_RegisterPlatformBrightness _registerPlatformBrightness =
    nativeDynamicLibrary
        .lookup<NativeFunction<Native_RegisterPlatformBrightness>>(
            'registerPlatformBrightness')
        .asFunction();

final Pointer<Utf8> _dark = Utf8.toUtf8('dark');
final Pointer<Utf8> _light = Utf8.toUtf8('light');

Pointer<Utf8> _platformBrightness() {
  return window.platformBrightness == Brightness.dark ? _dark : _light;
}

void registerPlatformBrightness() {
  Pointer<NativeFunction<Native_PlatformBrightness>> pointer =
      Pointer.fromFunction(_platformBrightness);
  _registerPlatformBrightness(pointer);
}

// Register onPlatformBrightnessChanged
typedef Native_OnPlatformBrightnessChanged = Void Function();
typedef Native_RegisterOnPlatformBrightnessChanged = Void Function(
    Pointer<NativeFunction<Native_OnPlatformBrightnessChanged>>);
typedef Dart_RegisterOnPlatformBrightnessChanged = void Function(
    Pointer<NativeFunction<Native_OnPlatformBrightnessChanged>>);

final Dart_RegisterOnPlatformBrightnessChanged
    _registerOnPlatformBrightnessChanged = nativeDynamicLibrary
        .lookup<NativeFunction<Native_RegisterOnPlatformBrightnessChanged>>(
            'registerOnPlatformBrightnessChanged')
        .asFunction();

void _onPlatformBrightnessChanged() {
  // TODO: should avoid overwrite old event handler
  window.onPlatformBrightnessChanged =
      invokeOnPlatformBrightnessChangedCallback;
}

void registerOnPlatformBrightnessChanged() {
  Pointer<NativeFunction<Native_OnPlatformBrightnessChanged>> pointer =
      Pointer.fromFunction(_onPlatformBrightnessChanged);
  _registerOnPlatformBrightnessChanged(pointer);
}

// Register DeviceInfo
void registerGetDeviceInfo() {
  // TODO
}

// Register NetInfo
void registerGetNetInfo() {
  // TODO
}

void registerDartFunctionIntoCpp() {
  registerInvokeDartFromJS();
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
  registerGetDeviceInfo();
  registerGetNetInfo();
}
