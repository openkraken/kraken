/*
 * Copyright (C) 2020-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
// ignore_for_file: unused_import, undefined_function

import 'dart:async';
import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:test/test.dart';

import 'platform.dart';

// Steps for using dart:ffi to call a Dart function from C:
// 1. Import dart:ffi.
// 2. Create a typedef with the FFI type signature of the Dart function.
// 3. Create a typedef for the variable that you’ll use when calling the Dart function.
// 4. Open the dynamic library that register in the C.
// 5. Get a reference to the C function, and put it into a variable.
// 6. Call from C.

typedef NativeDescribeCallback = Void Function(Pointer<Void> context);
typedef DartDescribeCallback = void Function(Pointer<Void> context);
typedef Native_Describe = Void Function(
    Pointer<Utf8> name, Pointer<Void> context, Pointer<NativeFunction<NativeDescribeCallback>>);
typedef Native_RegisterDescribe = Void Function(Pointer<NativeFunction<Native_Describe>>);
typedef Dart_RegisterDescribe = void Function(Pointer<NativeFunction<Native_Describe>>);

final Dart_RegisterDescribe _registerDescribe =
    nativeDynamicLibrary.lookup<NativeFunction<Native_RegisterDescribe>>('registerDescribe').asFunction();

void _describe(
    Pointer<Utf8> namePtr, Pointer<Void> context, Pointer<NativeFunction<NativeDescribeCallback>> callbackPtr) {
  DartDescribeCallback callback = callbackPtr.asFunction();
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

void _it(Pointer<Utf8> namePtr, Pointer<Void> context, Pointer<NativeFunction<NativeItCallback>> callbackPtr) {
  DartItCallback callback = callbackPtr.asFunction();
  test(Utf8.fromUtf8(namePtr), () async {
    Completer completer = Completer<void>();

    // cache completer into an list, and use callback to consume it later.
    testCompleter.add(completer);

    print(testCompleter.length);

    callback(context, testCompleter.length);

    return completer.future;
  });
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

void _itDone(int completerId, Pointer<Utf8> errmsg) {
  if (testCompleter[completerId - 1] == null) return;
  Completer<void> completer = testCompleter[completerId - 1];

  if (errmsg == nullptr) {
    completer.complete();
  } else {
    completer.completeError(new Exception(Utf8.fromUtf8(errmsg)));
  }
}

void registerItDone() {
  Pointer<NativeFunction<Native_ItDone>> pointer = Pointer.fromFunction(_itDone);
  _registerItDone(pointer);
}

typedef Native_OnJSError = Void Function(Pointer<Utf8>);
typedef Native_RegisterOnJSError = Void Function(Pointer<NativeFunction<Native_OnJSError>>);
typedef Dart_RegisterOnJSError = void Function(Pointer<NativeFunction<Native_OnJSError>>);

final Dart_RegisterOnJSError _registerOnJSError =
    nativeDynamicLibrary.lookup<NativeFunction<Native_RegisterOnJSError>>('registerOnJSError').asFunction();

typedef JSErrorListener = void Function(String);

JSErrorListener _listener;

void addOnJSErrorListener(JSErrorListener listener) {
  _listener = listener;
}

void _onJSError(Pointer<Utf8> charStr) {
  if (_listener == null) return;
  String msg = Utf8.fromUtf8(charStr);
  _listener(msg);
}

void registerOnJSError() {
  Pointer<NativeFunction<Native_OnJSError>> pointer = Pointer.fromFunction(_onJSError);
  _registerOnJSError(pointer);
}

void registerDartTestMethodsToCpp() {
  registerDescribe();
  registerIt();
  registerItDone();
  registerOnJSError();
}
