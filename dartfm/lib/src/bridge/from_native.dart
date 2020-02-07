import 'dart:ui';

import 'package:flutter/painting.dart';

import 'platform.dart';
import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'bridge.dart';
import 'native_structs.dart';

// Functions signature for ffi
typedef Native_InvokeDartFromJS = Pointer<Utf8> Function(Pointer<Utf8>);
typedef Native_RegisterInvokeDartFromJS = Void Function(
    Pointer<NativeFunction<Native_InvokeDartFromJS>>);
typedef Dart_RegisterInvokeDartFromJS = void Function(
    Pointer<NativeFunction<Native_InvokeDartFromJS>>);

typedef Native_ReloadApp = Void Function();
typedef Native_RegisterReloadApp = Void Function(
    Pointer<NativeFunction<Native_ReloadApp>>);
typedef Dart_RegisterReloadApp = void Function(
    Pointer<NativeFunction<Native_ReloadApp>>);

typedef Native_SetTimeout = Int32 Function(Int32, Int32);
typedef Native_RegisterSetTimeout = Void Function(
    Pointer<NativeFunction<Native_SetTimeout>>);
typedef Dart_RegisterSetTimeout = void Function(
    Pointer<NativeFunction<Native_SetTimeout>>);

typedef Native_SetInterval = Int32 Function(Int32, Int32);
typedef Native_RegisterSetInterval = Void Function(
    Pointer<NativeFunction<Native_SetTimeout>>);
typedef Dart_RegisterSetInterval = void Function(
    Pointer<NativeFunction<Native_SetTimeout>>);

typedef Native_ClearTimeout = Void Function(Int32);
typedef Native_RegisterClearTimeout = Void Function(
    Pointer<NativeFunction<Native_ClearTimeout>>);
typedef Dart_RegisterClearTimeout = void Function(
    Pointer<NativeFunction<Native_ClearTimeout>>);

typedef Native_RequestAnimationFrame = Int32 Function(Int32);
typedef Native_RegisterRequestAnimationFrame = Void Function(
    Pointer<NativeFunction<Native_RequestAnimationFrame>>);
typedef Dart_RegisterRequestAnimationFrame = void Function(
    Pointer<NativeFunction<Native_RequestAnimationFrame>>);

typedef Native_CancelAnimationFrame = Void Function(Int32);
typedef Native_RegisterCancelAnimationFrame = Void Function(
    Pointer<NativeFunction<Native_CancelAnimationFrame>>);
typedef Dart_RegisterCancelAnimationFrame = void Function(
    Pointer<NativeFunction<Native_CancelAnimationFrame>>);

typedef Native_GetScreen = Pointer<ScreenSize> Function();
typedef Native_RegisterGetScreen = Void Function(
    Pointer<NativeFunction<Native_GetScreen>>);
typedef Dart_RegisterGetScreen = void Function(
    Pointer<NativeFunction<Native_GetScreen>>);

typedef Native_InvokeFetch = Void Function(Int32, Pointer<Utf8>, Pointer<Utf8>);
typedef Native_RegisterInvokeFetch = Void Function(
    Pointer<NativeFunction<Native_InvokeFetch>>);
typedef Dart_RegisterInvokeFetch = void Function(
    Pointer<NativeFunction<Native_InvokeFetch>>);

typedef Native_DevicePixelRatio = Double Function();
typedef Native_RegisterDevicePixelRatio = Void Function(
    Pointer<NativeFunction<Native_DevicePixelRatio>>);
typedef Dart_RegisterDevicePixelRatio = void Function(
    Pointer<NativeFunction<Native_DevicePixelRatio>>);

typedef Native_PlatformBrightness = Pointer<Utf8> Function();
typedef Native_RegisterPlatformBrightness = Void Function(
    Pointer<NativeFunction<Native_PlatformBrightness>>);
typedef Dart_RegisterPlatformBrightness = void Function(
    Pointer<NativeFunction<Native_PlatformBrightness>>);

typedef Native_OnPlatformBrightnessChanged = Void Function();
typedef Native_RegisterOnPlatformBrightnessChanged = Void Function(
    Pointer<NativeFunction<Native_OnPlatformBrightnessChanged>>);
typedef Dart_RegisterOnPlatformBrightnessChanged = void Function(
    Pointer<NativeFunction<Native_OnPlatformBrightnessChanged>>);


final Dart_RegisterInvokeDartFromJS _registerDartFn = nativeDynamicLibrary
    .lookup<NativeFunction<Native_RegisterInvokeDartFromJS>>(
        'registerInvokeDartFromJS')
    .asFunction();

final Dart_RegisterReloadApp _registerReloadApp = nativeDynamicLibrary
    .lookup<NativeFunction<Native_RegisterReloadApp>>('registerReloadApp')
    .asFunction();

final Dart_RegisterSetTimeout _registerSetTimeout = nativeDynamicLibrary
    .lookup<NativeFunction<Native_RegisterSetTimeout>>('registerSetTimeout')
    .asFunction();

final Dart_RegisterSetInterval _registerSetInterval = nativeDynamicLibrary
    .lookup<NativeFunction<Native_RegisterSetTimeout>>('registerSetInterval')
    .asFunction();

final Dart_RegisterClearTimeout _registerClearTimeout = nativeDynamicLibrary
    .lookup<NativeFunction<Native_RegisterClearTimeout>>('registerClearTimeout')
    .asFunction();

final Dart_RegisterRequestAnimationFrame _registerRequestAnimationFrame =
    nativeDynamicLibrary
        .lookup<NativeFunction<Native_RegisterRequestAnimationFrame>>(
            'registerRequestAnimationFrame')
        .asFunction();

final Dart_RegisterCancelAnimationFrame _registerCancelAnimationFrame =
    nativeDynamicLibrary
        .lookup<NativeFunction<Native_RegisterCancelAnimationFrame>>(
            'registerCancelAnimationFrame')
        .asFunction();

final Dart_RegisterGetScreen _registerGetScreen = nativeDynamicLibrary
    .lookup<NativeFunction<Native_RegisterGetScreen>>('registerGetScreen')
    .asFunction();

final Dart_RegisterInvokeFetch _registerInvokeFetch = nativeDynamicLibrary
    .lookup<NativeFunction<Native_RegisterInvokeFetch>>('registerInvokeFetch')
    .asFunction();

final Dart_RegisterDevicePixelRatio _registerDevicePixelRatio =
    nativeDynamicLibrary
        .lookup<NativeFunction<Native_RegisterDevicePixelRatio>>(
            'registerDevicePixelRatio')
        .asFunction();

final Dart_RegisterPlatformBrightness _registerPlatformBrightness =
    nativeDynamicLibrary
        .lookup<NativeFunction<Native_RegisterPlatformBrightness>>(
            'registerPlatformBrightness')
        .asFunction();

final Dart_RegisterOnPlatformBrightnessChanged _registerOnPlatformBrightnessChanged =
    nativeDynamicLibrary
        .lookup<NativeFunction<Native_RegisterOnPlatformBrightnessChanged>>(
            'registerOnPlatformBrightnessChanged')
        .asFunction();

Pointer<Utf8> _invokeDartFromJS(Pointer<Utf8> data) {
  String args = Utf8.fromUtf8(data);
  String result = krakenJsToDart(args);
  return Utf8.toUtf8(result);
}

void _reloadApp() {
  reloadApp();
}

int _setTimeout(int callbackId, int timeout) {
  return setTimeout(callbackId, timeout);
}

int _setInterval(int callbackId, int timeout) {
  return setInterval(callbackId, timeout);
}

void _clearTimeout(int timerId) {
  clearTimeout(timerId);
}

int _requestAnimationFrame(int callbackId) {
  return requestAnimationFrame(callbackId);
}

void _cancelAnimationFrame(int timerId) {
  cancelAnimationFrame(timerId);
}

void _invokeFetch(int callbackId, Pointer<Utf8> url, Pointer<Utf8> json) {
  fetch(callbackId, Utf8.fromUtf8(url), Utf8.fromUtf8(json));
}

Pointer<ScreenSize> _getScreen() {
  Size size = window.physicalSize;;
  return ScreenSize.fromSize(size);
}

double _devicePixelRatio() {
  return window.devicePixelRatio;
}

final Pointer<Utf8> _dark = Utf8.toUtf8('dark');
final Pointer<Utf8> _light = Utf8.toUtf8('light');

Pointer<Utf8> _platformBrightness() {
  return window.platformBrightness == Brightness.dark ? _dark : _light;
}

void _onPlatformBrightnessChanged() {
  onPlatformBrightnessChanged();
}

void registerInvokeDartFromJS() {
  Pointer<NativeFunction<Native_InvokeDartFromJS>> pointer =
      Pointer.fromFunction(_invokeDartFromJS);
  _registerDartFn(pointer);
}

void registerReloadApp() {
  Pointer<NativeFunction<Native_ReloadApp>> pointer =
      Pointer.fromFunction(_reloadApp);
  _registerReloadApp(pointer);
}

void registerSetTimeout() {
  Pointer<NativeFunction<Native_SetTimeout>> pointer =
      Pointer.fromFunction(_setTimeout, 0);
  _registerSetTimeout(pointer);
}

void registerSetInterval() {
  Pointer<NativeFunction<Native_SetInterval>> pointer =
      Pointer.fromFunction(_setInterval, 0);
  _registerSetInterval(pointer);
}

void registerClearTimeout() {
  Pointer<NativeFunction<Native_ClearTimeout>> pointer =
      Pointer.fromFunction(_clearTimeout);
  _registerClearTimeout(pointer);
}

void registerRequestAnimationFrame() {
  Pointer<NativeFunction<Native_RequestAnimationFrame>> pointer =
      Pointer.fromFunction(_requestAnimationFrame, 0);
  _registerRequestAnimationFrame(pointer);
}

void registerCancelAnimationFrame() {
  Pointer<NativeFunction<Native_CancelAnimationFrame>> pointer =
      Pointer.fromFunction(_cancelAnimationFrame);
  _registerCancelAnimationFrame(pointer);
}

void registerGetScreen() {
  Pointer<NativeFunction<Native_GetScreen>> pointer =
      Pointer.fromFunction(_getScreen);
  _registerGetScreen(pointer);
}

void registerInvokeFetch() {
  Pointer<NativeFunction<Native_InvokeFetch>> pointer =
      Pointer.fromFunction(_invokeFetch);
  _registerInvokeFetch(pointer);
}

void registerDevicePixelRatio() {
  Pointer<NativeFunction<Native_DevicePixelRatio>> pointer =
      Pointer.fromFunction(_devicePixelRatio, 0.0);
  _registerDevicePixelRatio(pointer);
}

void registerPlatformBrightness() {
  Pointer<NativeFunction<Native_PlatformBrightness>> pointer =
      Pointer.fromFunction(_platformBrightness);
  _registerPlatformBrightness(pointer);
}

void registerOnPlatformBrightnessChanged() {
  Pointer<NativeFunction<Native_OnPlatformBrightnessChanged>> pointer =
      Pointer.fromFunction(_onPlatformBrightnessChanged);
  _registerOnPlatformBrightnessChanged(pointer);
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
}
