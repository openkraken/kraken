/*
 * Copyright (C) 2020-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

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
typedef Native_InitTestFramework = Void Function();
typedef Dart_InitTestFramework = void Function();

final Dart_InitTestFramework _initTestFramework = nativeDynamicLibrary
    .lookup<NativeFunction<Native_InitTestFramework>>('initTestFramework')
    .asFunction();

void initTestFramework() {
  initJSEngine();
  _initTestFramework();
}

// Register evaluteTestScripts
typedef Native_EvaluateTestScripts = Int8 Function(
    Pointer<Utf8>, Pointer<Utf8>, Int32);
typedef Dart_EvaluateTestScripts = int Function(
    Pointer<Utf8>, Pointer<Utf8>, int);

final Dart_EvaluateTestScripts _evaluateTestScripts = nativeDynamicLibrary
    .lookup<NativeFunction<Native_EvaluateTestScripts>>('evaluateScripts')
    .asFunction();

void evaluateTestScripts(String code, {String url = 'test://', int line = 0}) {
  Pointer<Utf8> _code = Utf8.toUtf8(code);
  Pointer<Utf8> _url = Utf8.toUtf8(url);
  _evaluateTestScripts(_code, _url, line);
}
