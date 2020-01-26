import 'platform.dart';
import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'bridge.dart';

typedef Native_InvokeDartFromJS = Pointer<Utf8> Function(Pointer<Utf8>);
typedef Native_RegisterInvokeDartFromJS = Void Function(Pointer<NativeFunction<Native_InvokeDartFromJS>>);
typedef Dart_RegisterInvokeDartFromJS = void Function(Pointer<
    NativeFunction<Native_InvokeDartFromJS>>);

final Dart_RegisterInvokeDartFromJS _registerDartFn = nativeDynamicLibrary
  .lookup<NativeFunction<Native_RegisterInvokeDartFromJS>>('registerInvokeDartFromJS')
  .asFunction();

Pointer<Utf8> __invokeDartFromJS(Pointer<Utf8> data) {
  String args = Utf8.fromUtf8(data);
  String result = krakenJsToDart(args);
  return Utf8.toUtf8(result);
}

void registerInvokeDartFromJS() {
  Pointer<NativeFunction<Native_InvokeDartFromJS>> pointer = Pointer.fromFunction(__invokeDartFromJS);
  _registerDartFn(pointer);
}

void registerDartFunctionIntoCpp() {
  registerInvokeDartFromJS();
}
