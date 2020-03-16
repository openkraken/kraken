/*
 * Copyright (C) 2020-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
// ignore_for_file: unused_import, undefined_function

import 'dart:async';
import 'dart:ffi';
import 'dart:typed_data';
import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';
import 'package:kraken/kraken.dart';
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

typedef NativeTestCallback = Void Function(Pointer<Void> context);
typedef DartTestCallback = void Function(Pointer<Void> context);

typedef Native_JSError = Void Function(Pointer<Utf8>);
typedef Native_RegisterJSError = Void Function(Pointer<NativeFunction<Native_JSError>>);
typedef Dart_RegisterJSError = void Function(Pointer<NativeFunction<Native_JSError>>);

final Dart_RegisterJSError _registerOnJSError =
    nativeDynamicLibrary.lookup<NativeFunction<Native_RegisterJSError>>('registerJSError').asFunction();

typedef JSErrorListener = void Function(String);

JSErrorListener _listener;

void addJSErrorListener(JSErrorListener listener) {
  _listener = listener;
}

void _onJSError(Pointer<Utf8> charStr) {
  if (_listener == null) return;
  String msg = Utf8.fromUtf8(charStr);
  _listener(msg);
}

void registerJSError() {
  Pointer<NativeFunction<Native_JSError>> pointer = Pointer.fromFunction(_onJSError);
  _registerOnJSError(pointer);
}

typedef Native_RefreshPaintCallback = Void Function(Pointer<Void>);
typedef Dart_RefreshPaintCallback = void Function(Pointer<Void>);
typedef Native_RefreshPaint = Void Function(Pointer<Void>, Pointer<NativeFunction<Native_RefreshPaintCallback>>);
typedef Native_RegisterRefreshPaint = Void Function(Pointer<NativeFunction<Native_RefreshPaint>>);
typedef Dart_RegisterRefreshPaint = void Function(Pointer<NativeFunction<Native_RefreshPaint>>);

final Dart_RegisterRefreshPaint _registerRefreshPaint =
    nativeDynamicLibrary.lookup<NativeFunction<Native_RegisterRefreshPaint>>('registerRefreshPaint').asFunction();

void _refreshPaint(Pointer<Void> context, Pointer<NativeFunction<Native_RefreshPaintCallback>> pointer) {
  Dart_RefreshPaintCallback callback = pointer.asFunction();
  refreshPaint().then((_) {
    callback(context);
  });
}

void registerRefreshPaint() {
  Pointer<NativeFunction<Native_RefreshPaint>> pointer = Pointer.fromFunction(_refreshPaint);
  _registerRefreshPaint(pointer);
}

typedef Native_MatchImageSnapshotCallback = Void Function(Pointer<Void>, Int8);
typedef Dart_MatchImageSnapshotCallback = void Function(Pointer<Void>, int);
typedef Native_MatchImageSnapshot = Void Function(
    Pointer<Uint8>, Int32, Pointer<Utf8>, Pointer<Void>, Pointer<NativeFunction<Native_MatchImageSnapshotCallback>>);
typedef Native_RegisterMatchImageSnapshot = Void Function(Pointer<NativeFunction<Native_MatchImageSnapshot>>);
typedef Dart_RegisterMatchImageSnapshot = void Function(Pointer<NativeFunction<Native_MatchImageSnapshot>>);

final Dart_RegisterMatchImageSnapshot _registerMatchImageSnapshot = nativeDynamicLibrary
    .lookup<NativeFunction<Native_RegisterMatchImageSnapshot>>('registerMatchImageSnapshot')
    .asFunction();

void _matchImageSnapshot(Pointer<Uint8> bytes, int size, Pointer<Utf8> snapshotNamePtr, Pointer<Void> context,
    Pointer<NativeFunction<Native_MatchImageSnapshotCallback>> pointer) {
  Dart_MatchImageSnapshotCallback callback = pointer.asFunction();
  matchImageSnapshot(bytes.asTypedList(size), Utf8.fromUtf8(snapshotNamePtr)).then((value) {
    callback(context, value ? 1 : 0);
  });
}

void registerMatchImageSnapshot() {
  Pointer<NativeFunction<Native_MatchImageSnapshot>> pointer = Pointer.fromFunction(_matchImageSnapshot);
  _registerMatchImageSnapshot(pointer);
}

void registerDartTestMethodsToCpp() {
  registerJSError();
  registerRefreshPaint();
  registerMatchImageSnapshot();
}
