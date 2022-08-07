/*
 * Copyright (C) 2020-present The WebF authors. All rights reserved.
 */

import 'dart:async';
import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:webf/bridge.dart';

// Steps for using dart:ffi to call a C function from Dart:
// 1. Import dart:ffi.
// 2. Create a typedef with the FFI type signature of the C function.
// 3. Create a typedef for the variable that you’ll use when calling the C function.
// 4. Open the dynamic library that contains the C function.
// 5. Get a reference to the C function, and put it into a variable.
// 6. Call the C function.

// Init Test Framework
typedef NativeInitTestFramework = Void Function(Int32 contextId);
typedef DartInitTestFramework = void Function(int contextId);

final DartInitTestFramework _initTestFramework =
    WebFDynamicLibrary.ref.lookup<NativeFunction<NativeInitTestFramework>>('initTestFramework').asFunction();

void initTestFramework(int contextId) {
  _initTestFramework(contextId);
}

// Register evaluteTestScripts
typedef NativeEvaluateTestScripts = Int8 Function(Int32 contextId, Pointer<NativeString>, Pointer<Utf8>, Int32);
typedef DartEvaluateTestScripts = int Function(int contextId, Pointer<NativeString>, Pointer<Utf8>, int);

final DartEvaluateTestScripts _evaluateTestScripts =
    WebFDynamicLibrary.ref.lookup<NativeFunction<NativeEvaluateTestScripts>>('evaluateTestScripts').asFunction();

void evaluateTestScripts(int contextId, String code, {String url = 'test://', int line = 0}) {
  Pointer<Utf8> _url = (url).toNativeUtf8();
  _evaluateTestScripts(contextId, stringToNativeString(code), _url, line);
}

typedef NativeExecuteCallback = Void Function(Int32 contextId, Pointer<NativeString> status);
typedef DartExecuteCallback = void Function(int);
typedef NativeExecuteTest = Void Function(Int32 contextId, Pointer<NativeFunction<NativeExecuteCallback>>);
typedef DartExecuteTest = void Function(int contextId, Pointer<NativeFunction<NativeExecuteCallback>>);

final DartExecuteTest _executeTest =
    WebFDynamicLibrary.ref.lookup<NativeFunction<NativeExecuteTest>>('executeTest').asFunction();

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
