/*
 * Copyright (C) 2020-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
// ignore_for_file: unused_import, undefined_function

import 'dart:async';
import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';
import 'package:test/test.dart';

import 'platform.dart';

// Steps for using dart:ffi to call a Dart function from C:
// 1. Import dart:ffi.
// 2. Create a typedef with the FFI type signature of the Dart function.
// 3. Create a typedef for the variable that you’ll use when calling the Dart function.
// 4. Open the dynamic library that register in the C.
// 5. Get a reference to the C function, and put it into a variable.
// 6. Call from C.

typedef NativeTestCallback = Void Function(Pointer<Void> context);
typedef DartTestCallback = void Function(Pointer<Void> context);

typedef Native_Describe = Void Function(
    Pointer<Utf8> name, Pointer<Void> context, Pointer<NativeFunction<NativeTestCallback>>);
typedef Native_RegisterDescribe = Void Function(Pointer<NativeFunction<Native_Describe>>);
typedef Dart_RegisterDescribe = void Function(Pointer<NativeFunction<Native_Describe>>);

final Dart_RegisterDescribe _registerDescribe =
    nativeDynamicLibrary.lookup<NativeFunction<Native_RegisterDescribe>>('registerDescribe').asFunction();

void _describe(Pointer<Utf8> namePtr, Pointer<Void> context, Pointer<NativeFunction<NativeTestCallback>> callbackPtr) {
  DartTestCallback callback = callbackPtr.asFunction();
  group(Utf8.fromUtf8(namePtr), () {
    callback(context);
  });
}

void registerDescribe() {
  Pointer<NativeFunction<Native_Describe>> pointer = Pointer.fromFunction(_describe);
  _registerDescribe(pointer);
}

List<Completer<void>> testCompleter = [];

typedef NativeItCallback = Void Function(Pointer<Void> context, Int32);
typedef DartItCallback = void Function(Pointer<Void> context, int);
typedef Native_It = Void Function(Pointer<Utf8> name, Pointer<Void> context, Pointer<NativeFunction<NativeItCallback>>);
typedef Native_RegisterIt = Void Function(Pointer<NativeFunction<Native_It>>);
typedef Dart_RegisterIt = void Function(Pointer<NativeFunction<Native_It>>);

final Dart_RegisterIt _registerIt =
    nativeDynamicLibrary.lookup<NativeFunction<Native_RegisterIt>>('registerIt').asFunction();

enum TestEnvironment { Unit, Integration }

TestEnvironment testEnvironment;

void _it(Pointer<Utf8> namePtr, Pointer<Void> context, Pointer<NativeFunction<NativeItCallback>> callbackPtr) {
  DartItCallback callback = callbackPtr.asFunction();

  Future<void> f() {
    Completer completer = Completer<void>();
    // cache completer into an list, and use callback to consume it later.
    testCompleter.add(completer);
    callback(context, testCompleter.length);
    return completer.future;
  }

  if (testEnvironment == TestEnvironment.Unit) {
    test(Utf8.fromUtf8(namePtr), () async {
      return f();
    });
  } else {
    f();
  }
}

void registerIt() {
  Pointer<NativeFunction<Native_It>> pointer = Pointer.fromFunction(_it);
  _registerIt(pointer);
}

typedef Native_ItDone = Void Function(Int32, Pointer<Utf8>);
typedef Native_RegisterItDone = Void Function(Pointer<NativeFunction<Native_ItDone>>);
typedef Dart_RegisterItDone = void Function(Pointer<NativeFunction<Native_ItDone>>);

final Dart_RegisterItDone _registerItDone =
    nativeDynamicLibrary.lookup<NativeFunction<Native_RegisterItDone>>('registerItDone').asFunction();

typedef ItDoneCallback = void Function(String errmsg);

ItDoneCallback _itDoneCallback;

void onItDone(ItDoneCallback callback) {
  _itDoneCallback = callback;
}

void _itDone(int completerId, Pointer<Utf8> errmsg) {
  if (testCompleter[completerId - 1] == null) return;
  Completer<void> completer = testCompleter[completerId - 1];

  if (errmsg == nullptr) {
    completer.complete();
    if (_itDoneCallback != null) {
      _itDoneCallback(null);
    }
  } else {
    String msg = Utf8.fromUtf8(errmsg);
    completer.completeError(new Exception(msg));
    if (_itDoneCallback != null) {
      _itDoneCallback(msg);
    }
  }
}

void registerItDone() {
  Pointer<NativeFunction<Native_ItDone>> pointer = Pointer.fromFunction(_itDone);
  _registerItDone(pointer);
}


typedef Native_BeforeAll = Void Function(Pointer<Void> context, Pointer<NativeFunction<NativeTestCallback>>);
typedef Native_RegisterBeforeAll = Void Function(Pointer<NativeFunction<Native_BeforeAll>>);
typedef Dart_RegisterBeforeAll = void Function(Pointer<NativeFunction<Native_BeforeAll>>);

final Dart_RegisterBeforeAll _registerBeforeAll =
nativeDynamicLibrary.lookup<NativeFunction<Native_RegisterBeforeAll>>('registerBeforeAll').asFunction();

void _beforeAll(Pointer<Void> context, Pointer<NativeFunction<NativeTestCallback>> callbackPtr) {
  DartTestCallback callback = callbackPtr.asFunction();
  setUpAll(() {
    callback(context);
  });
}

void registerBeforeAll() {
  Pointer<NativeFunction<Native_BeforeAll>> pointer = Pointer.fromFunction(_beforeAll);
  _registerBeforeAll(pointer);
}

typedef Native_BeforeEach = Void Function(Pointer<Void> context, Pointer<NativeFunction<NativeTestCallback>>);
typedef Native_RegisterBeforeEach = Void Function(Pointer<NativeFunction<Native_BeforeEach>>);
typedef Dart_RegisterBeforeEach = void Function(Pointer<NativeFunction<Native_BeforeEach>>);

final Dart_RegisterBeforeEach _registerBeforeEach =
nativeDynamicLibrary.lookup<NativeFunction<Native_RegisterBeforeEach>>('registerBeforeEach').asFunction();

void _beforeEach(Pointer<Void> context, Pointer<NativeFunction<NativeTestCallback>> callbackPtr) {
  DartTestCallback callback = callbackPtr.asFunction();
  setUp(() {
    callback(context);
  });
}

void registerBeforeEach() {
  Pointer<NativeFunction<Native_BeforeEach>> pointer = Pointer.fromFunction(_beforeEach);
  _registerBeforeEach(pointer);
}

typedef Native_AfterAll = Void Function(Pointer<Void> context, Pointer<NativeFunction<NativeTestCallback>>);
typedef Native_RegisterAfterAll = Void Function(Pointer<NativeFunction<Native_AfterAll>>);
typedef Dart_RegisterAfterAll = void Function(Pointer<NativeFunction<Native_AfterAll>>);

final Dart_RegisterBeforeEach _registerAfterAll =
nativeDynamicLibrary.lookup<NativeFunction<Native_RegisterAfterAll>>('registerAfterAll').asFunction();

void _afterAll(Pointer<Void> context, Pointer<NativeFunction<NativeTestCallback>> callbackPtr) {
  DartTestCallback callback = callbackPtr.asFunction();
  tearDownAll(() {
    callback(context);
  });
}

void registerAfterAll() {
  Pointer<NativeFunction<Native_AfterAll>> pointer = Pointer.fromFunction(_afterAll);
  _registerAfterAll(pointer);
}

typedef Native_AfterEach = Void Function(Pointer<Void> context, Pointer<NativeFunction<NativeTestCallback>>);
typedef Native_RegisterAfterEach = Void Function(Pointer<NativeFunction<Native_AfterEach>>);
typedef Dart_RegisterAfterEach = void Function(Pointer<NativeFunction<Native_AfterEach>>);

final Dart_RegisterBeforeEach _registerAfterEach =
nativeDynamicLibrary.lookup<NativeFunction<Native_RegisterAfterEach>>('registerAfterEach').asFunction();

void _afterEach(Pointer<Void> context, Pointer<NativeFunction<NativeTestCallback>> callbackPtr) {
  DartTestCallback callback = callbackPtr.asFunction();
  tearDown(() {
    callback(context);
  });
}

void registerAfterEach() {
  Pointer<NativeFunction<Native_AfterEach>> pointer = Pointer.fromFunction(_afterEach);
  _registerAfterEach(pointer);
}

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

void registerDartTestMethodsToCpp() {
  registerDescribe();
  registerIt();
  registerItDone();
  registerBeforeAll();
  registerBeforeEach();
  registerAfterAll();
  registerAfterEach();
  registerJSError();
}
