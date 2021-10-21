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
import 'package:kraken/dom.dart';
import 'package:kraken/bridge.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:test/test.dart';

import 'test_input.dart';
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
typedef JSErrorListener = void Function(String);

List<JSErrorListener> _listenerList = List.filled(10, (String string) {
  throw new Exception('unimplemented JS ErrorListener');
});

void addJSErrorListener(int contextId, JSErrorListener listener) {
  _listenerList[contextId] = listener;
}

void _onJSError(int contextId, Pointer<Utf8> charStr) {
  String msg = (charStr).toDartString();
  _listenerList[contextId](msg);
}

final Pointer<NativeFunction<Native_JSError>> _nativeOnJsError = Pointer.fromFunction(_onJSError);

typedef Native_MatchImageSnapshotCallback = Void Function(Pointer<Void> callbackContext, Int32 contextId, Int8, Pointer<Utf8>);
typedef Dart_MatchImageSnapshotCallback = void Function(Pointer<Void> callbackContext, int contextId, int, Pointer<Utf8>);
typedef Native_MatchImageSnapshot = Void Function(
    Pointer<Void> callbackContext, Int32 contextId,
    Pointer<Uint8>, Int32, Pointer<NativeString>, Pointer<NativeFunction<Native_MatchImageSnapshotCallback>>);

void _matchImageSnapshot(Pointer<Void> callbackContext, int contextId, Pointer<Uint8> bytes, int size, Pointer<NativeString> snapshotNamePtr, Pointer<NativeFunction<Native_MatchImageSnapshotCallback>> pointer) {
  Dart_MatchImageSnapshotCallback callback = pointer.asFunction();
  String filename = nativeStringToString(snapshotNamePtr);
  matchImageSnapshot(bytes.asTypedList(size), filename).then((value) {
    callback(callbackContext, contextId, value ? 1 : 0, nullptr);
  }).catchError((e, stack) {
    String errmsg = '$e\n$stack';
    callback(callbackContext, contextId, 0, errmsg.toNativeUtf8());
  });
}

final Pointer<NativeFunction<Native_MatchImageSnapshot>> _nativeMatchImageSnapshot = Pointer.fromFunction(_matchImageSnapshot);

typedef NativeEnvironment = Pointer<Utf8> Function();
typedef DartEnvironment = Pointer<Utf8> Function();

Pointer<Utf8> _environment() {
  return (jsonEncode(Platform.environment)).toNativeUtf8();
}

final Pointer<NativeFunction<NativeEnvironment>> _nativeEnvironment = Pointer.fromFunction(_environment);

typedef Native_SimulatePointer = Void Function(Pointer<Pointer<MousePointer>>,  Int32 length, Int32 pointer);
typedef Native_SimulateInputText = Void Function(Pointer<NativeString>);

PointerChange _getPointerChange(double change) {
  return PointerChange.values[change.toInt()];
}

class MousePointer extends Struct {
  @Int32()
  external int contextId;

  @Double()
  external double x;

  @Double()
  external double y;

  @Double()
  external double change;
}

void _simulatePointer(Pointer<Pointer<MousePointer>> mousePointerList, int length, int pointer) {
  List<PointerData> data = [];

  for (int i = 0; i < length; i ++) {
    int contextId = mousePointerList[i].ref.contextId;
    double x = mousePointerList[i].ref.x;
    double y = mousePointerList[i].ref.y;

    double change = mousePointerList[i].ref.change;
    data.add(PointerData(
      // TODO: remove hardcode '360' width that for double testing in one flutter window
      physicalX: (360 * contextId + x) * window.devicePixelRatio,
      physicalY: (56.0 + y) * window.devicePixelRatio,
      // MouseEvent will trigger [RendererBinding.dispatchEvent] -> [BaseMouseTracker.updateWithEvent]
      // which handle extra mouse connection phase for [event.kind = PointerDeviceKind.mouse].
      // Prefer to use touch event.
      kind: PointerDeviceKind.touch,
      change: _getPointerChange(change),
      pointerIdentifier: pointer
    ));
  }

  PointerDataPacket dataPacket = PointerDataPacket(data: data);
  window.onPointerDataPacket!(dataPacket);
}

final Pointer<NativeFunction<Native_SimulatePointer>> _nativeSimulatePointer = Pointer.fromFunction(_simulatePointer);
late TestTextInput testTextInput;

void _simulateInputText(Pointer<NativeString> nativeChars) {
  String text = nativeStringToString(nativeChars);
  testTextInput.enterText(text);
}

final Pointer<NativeFunction<Native_SimulateInputText>> _nativeSimulateInputText = Pointer.fromFunction(_simulateInputText);

final List<int> _dartNativeMethods = [
  _nativeOnJsError.address,
  _nativeMatchImageSnapshot.address,
  _nativeEnvironment.address,
  _nativeSimulatePointer.address,
  _nativeSimulateInputText.address
];

typedef Native_RegisterTestEnvDartMethods = Void Function(Pointer<Uint64> methodBytes, Int32 length);
typedef Dart_RegisterTestEnvDartMethods = void Function(Pointer<Uint64> methodBytes, int length);

final Dart_RegisterTestEnvDartMethods _registerTestEnvDartMethods =
nativeDynamicLibrary.lookup<NativeFunction<Native_RegisterTestEnvDartMethods>>('registerTestEnvDartMethods').asFunction();


void registerDartTestMethodsToCpp() {
  Pointer<Uint64> bytes = malloc.allocate<Uint64>(sizeOf<Uint64>() * _dartNativeMethods.length);
  Uint64List nativeMethodList = bytes.asTypedList(_dartNativeMethods.length);
  nativeMethodList.setAll(0, _dartNativeMethods);
  _registerTestEnvDartMethods(bytes, _dartNativeMethods.length);
}
