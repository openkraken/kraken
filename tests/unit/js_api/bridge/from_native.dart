import 'dart:convert';
import 'dart:ffi';
import 'dart:typed_data';
import 'dart:ui';

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
typedef Native_Describe = Void Function(Pointer<Utf8> name, Pointer<Void> context, Pointer<NativeFunction<NativeDescribeCallback>>);
typedef Native_RegisterDescribe = Void Function(Pointer<NativeFunction<Native_Describe>>);
typedef Dart_RegisterDescribe = void Function(Pointer<NativeFunction<Native_Describe>>);

final Dart_RegisterDescribe _registerDescribe =
nativeDynamicLibrary.lookup<NativeFunction<Native_RegisterDescribe>>('registerDescribe').asFunction();

void _describe(Pointer<Utf8> namePtr, Pointer<Void> context, Pointer<NativeFunction<NativeDescribeCallback>> callbackPtr) {
  DartDescribeCallback callback = callbackPtr.asFunction();
  group(Utf8.fromUtf8(namePtr), () {
    callback(context);
  });
}

void registerDescribe() {
  Pointer<NativeFunction<Native_Describe>> pointer = Pointer.fromFunction(_describe);
  _registerDescribe(pointer);
}


typedef Native_OnJSError = Void Function(Pointer<Utf8>);
typedef Native_RegisterOnJSError = Void Function(
    Pointer<NativeFunction<Native_OnJSError>>);
typedef Dart_RegisterOnJSError = void Function(
    Pointer<NativeFunction<Native_OnJSError>>);

final Dart_RegisterOnJSError _registerOnJSError = nativeDynamicLibrary
    .lookup<NativeFunction<Native_RegisterOnJSError>>('registerOnJSError')
    .asFunction();

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
  Pointer<NativeFunction<Native_OnJSError>> pointer =
  Pointer.fromFunction(_onJSError);
  _registerOnJSError(pointer);
}


void registerDartTestMethodsToCpp() {
  registerDescribe();
  registerOnJSError();
}
