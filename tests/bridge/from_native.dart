/*
 * Copyright (C) 2020-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
// ignore_for_file: unused_import, undefined_function

import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:ui';
import 'dart:io' show Platform;
import 'dart:typed_data';
import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';
import 'package:kraken/launcher.dart';
import 'package:kraken/bridge.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:test/test.dart';
import 'package:flutter_test/flutter_test.dart';

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

void _refreshPaint(Pointer<JSCallbackContext> callbackContext, int contextId, Pointer<NativeFunction<Native_RefreshPaintCallback>> pointer) async {
  Dart_RefreshPaintCallback callback = pointer.asFunction();
  KrakenController controller = KrakenController.getControllerOfJSContextId(contextId);
  try {
    await controller.testRefreshPaint();
    callback(callbackContext, contextId, nullptr);
  } catch (e, stack) {
    print('$e\n$stack');
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
    Pointer<Uint8>, Int32, Pointer<NativeString>, Pointer<NativeFunction<Native_MatchImageSnapshotCallback>>);
typedef Native_RegisterMatchImageSnapshot = Void Function(Pointer<NativeFunction<Native_MatchImageSnapshot>>);
typedef Dart_RegisterMatchImageSnapshot = void Function(Pointer<NativeFunction<Native_MatchImageSnapshot>>);

final Dart_RegisterMatchImageSnapshot _registerMatchImageSnapshot = nativeDynamicLibrary
    .lookup<NativeFunction<Native_RegisterMatchImageSnapshot>>('registerMatchImageSnapshot')
    .asFunction();

void _matchImageSnapshot(Pointer<JSCallbackContext> callbackContext, int contextId, Pointer<Uint8> bytes, int size, Pointer<NativeString> snapshotNamePtr, Pointer<NativeFunction<Native_MatchImageSnapshotCallback>> pointer) {
  Dart_MatchImageSnapshotCallback callback = pointer.asFunction();
  matchImageSnapshot(bytes.asTypedList(size), nativeStringToString(snapshotNamePtr)).then((value) {
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

typedef Native_SimulatePointer = Void Function(Pointer<Pointer<MousePointer>>,  Int32 length);
typedef Native_SimulateKeyPress = Void Function(Pointer<NativeString>);

typedef Native_RegisterSimulatePointer = Void Function(Pointer<NativeFunction<Native_SimulatePointer>> function);
typedef Native_RegisterSimulateKeyPress = Void Function(Pointer<NativeFunction<Native_SimulateKeyPress>> function);
typedef Dart_RegisterSimulatePointer = void Function(Pointer<NativeFunction<Native_SimulatePointer>> function);
typedef Dart_RegisterSimulateKeyPress = void Function(Pointer<NativeFunction<Native_SimulateKeyPress>> function);

final Dart_RegisterSimulatePointer _registerSimulatePointer =
    nativeDynamicLibrary.lookup<NativeFunction<Native_RegisterSimulatePointer>>('registerSimulatePointer').asFunction();
final Dart_RegisterSimulateKeyPress _registerSimulateKeyPress =
    nativeDynamicLibrary.lookup<NativeFunction<Native_RegisterSimulateKeyPress>>('registerSimulateKeyPress').asFunction();

PointerChange _getPointerChange(double change) {
  return PointerChange.values[change.toInt()];
}

class MousePointer extends Struct {
  @Int32()
  int contextId;

  @Double()
  double x;

  @Double()
  double y;

  @Double()
  double change;
}

void _simulatePointer(Pointer<Pointer<MousePointer>> mousePointerList, int length) {
  List<PointerData> data = [];

  for (int i = 0; i < length; i ++) {
    int contextId = mousePointerList[i].ref.contextId;
    double x = mousePointerList[i].ref.x;
    double y = mousePointerList[i].ref.y;

    double change = mousePointerList[i].ref.change;
    data.add(PointerData(
      physicalX: (360 * contextId + x) * window.devicePixelRatio,
      physicalY: (56.0 + y) * window.devicePixelRatio,
      // MouseEvent will trigger [RendererBinding.dispatchEvent] -> [BaseMouseTracker.updateWithEvent]
      // which handle extra mouse connection phase for [event.kind = PointerDeviceKind.mouse].
      // Prefer to use touch event.
      kind: PointerDeviceKind.touch,
      change: _getPointerChange(change)
    ));
  }
  PointerDataPacket dataPacket = PointerDataPacket(data: data);
  window.onPointerDataPacket(dataPacket);
}

void registerSimulatePointer() {
  Pointer<NativeFunction<Native_SimulatePointer>> pointer = Pointer.fromFunction(_simulatePointer);
  _registerSimulatePointer(pointer);
}

// Limit: only accept a-z0-9 chars.
// Enough for testing.
void _simulateKeyPress(Pointer<NativeString> charsPtr) async {
  String chars = nativeStringToString(charsPtr);
  if (chars == null) {
    print('Warning: simulateKeyPress chars is null.');
    return;
  }
  for (int i = 0; i < chars.length; i++) {
    String char = chars[i];
    LogicalKeyboardKey key = getLogicalKeyboardKey(char);
    if (key != null) {
      await KeyEventSimulator.simulateKeyDownEvent(key);
      await KeyEventSimulator.simulateKeyUpEvent(key);
    }
  }
}

void registerSimulateKeyPress() {
  Pointer<NativeFunction<Native_SimulateKeyPress>> pointer = Pointer.fromFunction(_simulateKeyPress);
  _registerSimulateKeyPress(pointer);
}

LogicalKeyboardKey getLogicalKeyboardKey(String char) {
  char = char.toLowerCase();
  switch (char) {
    case 'a': return LogicalKeyboardKey.keyA;
    case 'b': return LogicalKeyboardKey.keyB;
    case 'c': return LogicalKeyboardKey.keyC;
    case 'd': return LogicalKeyboardKey.keyD;
    case 'e': return LogicalKeyboardKey.keyE;
    case 'f': return LogicalKeyboardKey.keyF;
    case 'g': return LogicalKeyboardKey.keyG;
    case 'h': return LogicalKeyboardKey.keyH;
    case 'i': return LogicalKeyboardKey.keyI;
    case 'j': return LogicalKeyboardKey.keyJ;
    case 'k': return LogicalKeyboardKey.keyK;
    case 'l': return LogicalKeyboardKey.keyL;
    case 'm': return LogicalKeyboardKey.keyM;
    case 'n': return LogicalKeyboardKey.keyN;
    case 'o': return LogicalKeyboardKey.keyO;
    case 'p': return LogicalKeyboardKey.keyP;
    case 'q': return LogicalKeyboardKey.keyQ;
    case 'r': return LogicalKeyboardKey.keyR;
    case 's': return LogicalKeyboardKey.keyS;
    case 't': return LogicalKeyboardKey.keyT;
    case 'u': return LogicalKeyboardKey.keyU;
    case 'v': return LogicalKeyboardKey.keyV;
    case 'w': return LogicalKeyboardKey.keyW;
    case 'x': return LogicalKeyboardKey.keyX;
    case 'y': return LogicalKeyboardKey.keyY;
    case 'z': return LogicalKeyboardKey.keyZ;
    case '0': return LogicalKeyboardKey.digit0;
    case '1': return LogicalKeyboardKey.digit1;
    case '2': return LogicalKeyboardKey.digit2;
    case '3': return LogicalKeyboardKey.digit3;
    case '4': return LogicalKeyboardKey.digit4;
    case '5': return LogicalKeyboardKey.digit5;
    case '6': return LogicalKeyboardKey.digit6;
    case '7': return LogicalKeyboardKey.digit7;
    case '8': return LogicalKeyboardKey.digit8;
    case '9': return LogicalKeyboardKey.digit9;
    case '0': return LogicalKeyboardKey.digit0;
  }
  return null;
}

void registerDartTestMethodsToCpp() {
  registerJSError();
  registerRefreshPaint();
  registerMatchImageSnapshot();
  registerEnvironment();
  registerSimulatePointer();
  registerSimulateKeyPress();
}
