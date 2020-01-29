import 'package:flutter/painting.dart';

import 'platform.dart';
import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'bridge.dart';
import 'native_structs.dart';

typedef Native_InvokeDartFromJS = Pointer<Utf8> Function(Pointer<Utf8>);
typedef Native_RegisterInvokeDartFromJS = Void Function(
    Pointer<NativeFunction<Native_InvokeDartFromJS>>);
typedef Dart_RegisterInvokeDartFromJS = void Function(
    Pointer<NativeFunction<Native_InvokeDartFromJS>>);

typedef Native_ReloadJSApp = Void Function();
typedef Native_RegisterReloadJSApp = Void Function(
    Pointer<NativeFunction<Native_ReloadJSApp>>);
typedef Dart_RegisterReloadJSApp = void Function(
    Pointer<NativeFunction<Native_ReloadJSApp>>);

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

final Dart_RegisterInvokeDartFromJS _registerDartFn = nativeDynamicLibrary
    .lookup<NativeFunction<Native_RegisterInvokeDartFromJS>>(
        'registerInvokeDartFromJS')
    .asFunction();

final Dart_RegisterReloadJSApp _registerReloadJSApp = nativeDynamicLibrary
    .lookup<NativeFunction<Native_RegisterReloadJSApp>>('registerReloadApp')
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

Pointer<Utf8> __invokeDartFromJS(Pointer<Utf8> data) {
  String args = Utf8.fromUtf8(data);
  String result = krakenJsToDart(args);
  return Utf8.toUtf8(result);
}

void __reloadJSApp() {
  reloadApp();
}

int __setTimeout(int callbackId, int timeout) {
  return setTimeout(callbackId, timeout);
}

int __setInterval(int callbackId, int timeout) {
  return setInterval(callbackId, timeout);
}

void __clearTimeout(int timerId) {
  clearTimeout(timerId);
}

int __requestAnimationFrame(int callbackId) {
  return requestAnimationFrame(callbackId);
}

void __cancelAnimationFrame(int timerId) {
  cancelAnimationFrame(timerId);
}

Pointer<ScreenSize> __getScreen() {
  Size size = getScreen();
  return ScreenSize.fromSize(size);
}

void registerInvokeDartFromJS() {
  Pointer<NativeFunction<Native_InvokeDartFromJS>> pointer =
      Pointer.fromFunction(__invokeDartFromJS);
  _registerDartFn(pointer);
}

void registerReloadJSApp() {
  Pointer<NativeFunction<Native_ReloadJSApp>> pointer =
      Pointer.fromFunction(__reloadJSApp);
  _registerReloadJSApp(pointer);
}

void registerSetTimeout() {
  Pointer<NativeFunction<Native_SetTimeout>> pointer =
      Pointer.fromFunction(__setTimeout, 0);
  _registerSetTimeout(pointer);
}

void registerSetInterval() {
  Pointer<NativeFunction<Native_SetInterval>> pointer =
      Pointer.fromFunction(__setInterval, 0);
  _registerSetInterval(pointer);
}

void registerClearTimeout() {
  Pointer<NativeFunction<Native_ClearTimeout>> pointer =
      Pointer.fromFunction(__clearTimeout);
  _registerClearTimeout(pointer);
}

void registerRequestAnimationFrame() {
  Pointer<NativeFunction<Native_RequestAnimationFrame>> pointer =
      Pointer.fromFunction(__requestAnimationFrame, 0);
  _registerRequestAnimationFrame(pointer);
}

void registerCancelAnimationFrame() {
  Pointer<NativeFunction<Native_CancelAnimationFrame>> pointer =
      Pointer.fromFunction(__cancelAnimationFrame);
  _registerCancelAnimationFrame(pointer);
}

void registerGetScreen() {
  Pointer<NativeFunction<Native_GetScreen>> pointer = Pointer.fromFunction(__getScreen);
  _registerGetScreen(pointer);
}

void registerDartFunctionIntoCpp() {
  registerInvokeDartFromJS();
  registerReloadJSApp();
  registerSetTimeout();
  registerSetInterval();
  registerClearTimeout();
  registerRequestAnimationFrame();
  registerCancelAnimationFrame();
  registerGetScreen();
}
