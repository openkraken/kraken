/*
 * Copyright (C) 2020-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:async';
import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:kraken/bridge.dart';

import 'platform.dart';

// Steps for using dart:ffi to call a C function from Dart:
// 1. Import dart:ffi.
// 2. Create a typedef with the FFI type signature of the C function.
// 3. Create a typedef for the variable that you’ll use when calling the C function.
// 4. Open the dynamic library that contains the C function.
// 5. Get a reference to the C function, and put it into a variable.
// 6. Call the C function.

// Init Test Framework
typedef Native_InitTestFramework = Void Function(Int32 contextId);
typedef Dart_InitTestFramework = void Function(int contextId);

final Dart_InitTestFramework _initTestFramework =
    nativeDynamicLibrary.lookup<NativeFunction<Native_InitTestFramework>>('initTestFramework').asFunction();

void initTestFramework(int contextId) {
  _initTestFramework(contextId);
}

// Register evaluteTestScripts
typedef Native_EvaluateTestScripts = Int8 Function(Int32 contextId, Pointer<NativeString>, Pointer<Utf8>, Int32);
typedef Dart_EvaluateTestScripts = int Function(int contextId, Pointer<NativeString>, Pointer<Utf8>, int);

final Dart_EvaluateTestScripts _evaluateTestScripts =
nativeDynamicLibrary.lookup<NativeFunction<Native_EvaluateTestScripts>>('evaluateTestScripts').asFunction();

void evaluateTestScripts(int contextId, String code, {String url = 'test://', int line = 0}) {
  Pointer<Utf8> _url = (url).toNativeUtf8();
  _evaluateTestScripts(contextId, stringToNativeString(code), _url, line);
}

typedef NativeExecuteCallback = Void Function(Int32 contextId, Pointer<NativeString> status);
typedef DartExecuteCallback = void Function(int);
typedef Native_ExecuteTest = Void Function(Int32 contextId, Pointer<NativeFunction<NativeExecuteCallback>>);
typedef Dart_ExecuteTest = void Function(int contextId, Pointer<NativeFunction<NativeExecuteCallback>>);

final Dart_ExecuteTest _executeTest =
    nativeDynamicLibrary.lookup<NativeFunction<Native_ExecuteTest>>('executeTest').asFunction();

List<Completer<String>?> completerList = List.filled(10, null);

void _executeTestCallback(int contextId, Pointer<NativeString> status) {
  if (completerList[contextId] == null) return;
  completerList[contextId]!.complete(nativeStringToString(status));
  completerList[contextId] = null;
}

Future<String> executeTest(int contextId) async {
  completerList[contextId] = Completer();
  Pointer<NativeFunction<NativeExecuteCallback>> callback = Pointer.fromFunction(_executeTestCallback);
  _executeTest(contextId, callback);
  return completerList[contextId]!.future;
}
