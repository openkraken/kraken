/*
 * Copyright (C) 2020-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
// ignore_for_file: unused_import, undefined_function

import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io' show Platform;
import 'dart:typed_data';
import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';
import 'package:kraken/launcher.dart';
import 'package:kraken/bridge.dart';
import 'package:flutter/rendering.dart';
import 'package:test/test.dart';

import 'platform.dart';
import 'match_snapshots.dart';

// Steps for using dart:ffi to call a Dart function from C:
// 1. Import dart:ffi.
// 2. Create a typedef with the FFI type signature of the Dart function.
// 3. Create a typedef for the variable that you’ll use when calling the Dart function.
// 4. Open the dynamic library that register in the C.
// 5. Get a reference to the C function, and put it into a variable.
// 6. Call from C.

typedef Native_JSError = Void Function(Int32 contextId, Pointer<Utf8>);
typedef Native_RegisterJSError = Void Function(Pointer<NativeFunction<Native_JSError>>);
typedef Dart_RegisterJSError = void Function(Pointer<NativeFunction<Native_JSError>>);

final Dart_RegisterJSError _registerOnJSError =
    nativeDynamicLibrary.lookup<NativeFunction<Native_RegisterJSError>>('registerJSError').asFunction();

typedef JSErrorListener = void Function(String);

List<JSErrorListener> _listenerList = List(10);

void addJSErrorListener(int contextId, JSErrorListener listener) {
  _listenerList[contextId] = listener;
}

void _onJSError(int contextId, Pointer<Utf8> charStr) {
  if (_listenerList[contextId] == null) return;
  String msg = Utf8.fromUtf8(charStr);
  _listenerList[contextId](msg);
}

void registerJSError() {
  Pointer<NativeFunction<Native_JSError>> pointer = Pointer.fromFunction(_onJSError);
  _registerOnJSError(pointer);
}

typedef Native_RefreshPaintCallback = Void Function(Pointer<JSCallbackContext>, Int32 contextId, Pointer<Utf8>);
typedef Dart_RefreshPaintCallback = void Function(Pointer<JSCallbackContext>, int contextId, Pointer<Utf8>);
typedef Native_RefreshPaint = Void Function(Pointer<JSCallbackContext>, Int32 contextId, Pointer<NativeFunction<Native_RefreshPaintCallback>>);
typedef Native_RegisterRefreshPaint = Void Function(Pointer<NativeFunction<Native_RefreshPaint>>);
typedef Dart_RegisterRefreshPaint = void Function(Pointer<NativeFunction<Native_RefreshPaint>>);

final Dart_RegisterRefreshPaint _registerRefreshPaint =
    nativeDynamicLibrary.lookup<NativeFunction<Native_RegisterRefreshPaint>>('registerRefreshPaint').asFunction();

void _refreshPaint(Pointer<JSCallbackContext> callbackContext, int contextId, Pointer<NativeFunction<Native_RefreshPaintCallback>> pointer) {
  Dart_RefreshPaintCallback callback = pointer.asFunction();
  KrakenController controller = KrakenController.getControllerOfJSContextId(contextId);
  try {
    controller.view.testRefreshPaint();
    callback(callbackContext, contextId, nullptr);
  } catch (e) {
    print(e);
  }
}

void registerRefreshPaint() {
  Pointer<NativeFunction<Native_RefreshPaint>> pointer = Pointer.fromFunction(_refreshPaint);
  _registerRefreshPaint(pointer);
}

typedef Native_MatchImageSnapshotCallback = Void Function(Pointer<JSCallbackContext> callbackContext, Int32 contextId, Int8);
typedef Dart_MatchImageSnapshotCallback = void Function(Pointer<JSCallbackContext> callbackContext, int contextId, int);
typedef Native_MatchImageSnapshot = Void Function(
    Pointer<JSCallbackContext> callbackContext, Int32 contextId,
    Pointer<Uint8>, Int32, Pointer<Utf8>, Pointer<NativeFunction<Native_MatchImageSnapshotCallback>>);
typedef Native_RegisterMatchImageSnapshot = Void Function(Pointer<NativeFunction<Native_MatchImageSnapshot>>);
typedef Dart_RegisterMatchImageSnapshot = void Function(Pointer<NativeFunction<Native_MatchImageSnapshot>>);

final Dart_RegisterMatchImageSnapshot _registerMatchImageSnapshot = nativeDynamicLibrary
    .lookup<NativeFunction<Native_RegisterMatchImageSnapshot>>('registerMatchImageSnapshot')
    .asFunction();

void _matchImageSnapshot(Pointer<JSCallbackContext> callbackContext, int contextId, Pointer<Uint8> bytes, int size, Pointer<Utf8> snapshotNamePtr, Pointer<NativeFunction<Native_MatchImageSnapshotCallback>> pointer) {
  Dart_MatchImageSnapshotCallback callback = pointer.asFunction();
  matchImageSnapshot(bytes.asTypedList(size), Utf8.fromUtf8(snapshotNamePtr)).then((value) {
    callback(callbackContext, contextId, value ? 1 : 0);
  });
}

void registerMatchImageSnapshot() {
  Pointer<NativeFunction<Native_MatchImageSnapshot>> pointer = Pointer.fromFunction(_matchImageSnapshot);
  _registerMatchImageSnapshot(pointer);
}

typedef Native_Environment = Pointer<Utf8> Function();
typedef Dart_Environment = Pointer<Utf8> Function();

typedef Native_RegisterEnvironment = Void Function(Pointer<NativeFunction<Native_Environment>>);
typedef Dart_RegisterEnvironment = void Function(Pointer<NativeFunction<Native_Environment>>);

final Dart_RegisterEnvironment _registerEnvironment =
    nativeDynamicLibrary.lookup<NativeFunction<Native_RegisterEnvironment>>('registerEnvironment').asFunction();

Pointer<Utf8> _environment() {
  return Utf8.toUtf8(jsonEncode(Platform.environment));
}

void registerEnvironment() {
  Pointer<NativeFunction<Native_Environment>> pointer = Pointer.fromFunction(_environment);
  _registerEnvironment(pointer);
}

void registerDartTestMethodsToCpp() {
  registerJSError();
  registerRefreshPaint();
  registerMatchImageSnapshot();
  registerEnvironment();
}
