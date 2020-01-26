/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
// ignore_for_file: unused_import, undefined_function

import 'dart:io' show Platform;
import 'dart:ffi';
import 'dart:typed_data';
import 'package:ffi/ffi.dart';
import 'package:path/path.dart';
import 'package:kraken/kraken.dart';

/// Search dynamic lib from env.KRAKEN_LIBRARY_PATH or /usr/lib
const String KRAKEN_LIBRARY_PATH = 'KRAKEN_LIBRARY_PATH';
final String kkLibraryPath = Platform.environment[KRAKEN_LIBRARY_PATH];
final String nativeDynamicLibraryPath = Platform.isMacOS
  ? 'libkraken.dylib'
  : Platform.isWindows ? 'libkraken.dll' : 'libkraken.so';
DynamicLibrary nativeDynamicLibrary = DynamicLibrary.open(
  join(kkLibraryPath ?? '\$ORIGIN', nativeDynamicLibraryPath));

//// the dart function callback pass to c
//typedef C_DartFuncCallback = Void Function(Pointer<Utf8>);
//typedef C_RegisterDartFn = Void Function(Pointer<
//  NativeFunction<C_DartFuncCallback>>);
//typedef Dart_RegisterDartFn = void Function(Pointer<
//  NativeFunction<C_DartFuncCallback>>);

//// helloworld
//typedef C_HelloWorld = Void Function(Pointer<Utf8>);
//typedef Dart_HelloWorld = void Function(Pointer<Utf8>);
//
//final Dart_RegisterDartFn _registerDartFn = nativeDynamicLibrary
//  .lookup<NativeFunction<C_RegisterDartFn>>('register_dart_fn')
//  .asFunction();

//final Dart_HelloWorld _helloworld = nativeDynamicLibrary.lookup<
//    NativeFunction<C_HelloWorld>>('helloworld').asFunction();
//
//void dart_callback(Pointer<Utf8> args) {
//  print('dart callback called ${Utf8.fromUtf8(args)}\n');
//}

//void registerDartFn() {
//  Pointer<NativeFunction<C_DartFuncCallback>> pointer =
//  Pointer.fromFunction(dart_callback);
//  _registerDartFn(pointer);
//}

//void callHelloworld(String args) {
//  _helloworld(Utf8.toUtf8(args));
//}

//typedef InitKrakenCallbackFunc = Void Function();
//typedef InitKrakenCallback = void Function();
//typedef ReloadJSContextFn = Void Function();
//typedef ReloadJSContext = void Function();


//typedef Dart_helloworld = void Function(
//    Pointer<NativeFunction<NativeCallbackFnOp>>);

//final initKrakenCallbackFunc = nativeDynamicLibrary
//    .lookup<NativeFunction<InitKrakenCallbackFunc>>("init_callback");
//final _initKrakenCallback =
//    initKrakenCallbackFunc.asFunction<InitKrakenCallback>();
//final ReloadJSContextFunc = nativeDynamicLibrary.lookup<NativeFunction<ReloadJSContextFn>>('reload_js_context');
//final _reloadJSContext = ReloadJSContextFunc.asFunction<ReloadJSContext>();


//void initKrakenCallback() {
//  _initKrakenCallback();
//}

//void invokeKrakenCallback(String data) {
//  if (appLoading) return;
//  KrakenCallback(data);
//  print('invoke kraken callback');
//}

//Future<void> reloadJSContext() async {
//  return Future.microtask(() {
//    _reloadJSContext();
//  });
//}

//void evaluateScripts(String content, String url, {int startLine = 0}) {
//  if (appLoading) return;
//
//  assert(content != null);
//  assert(url != null);
//  KrakenEvaluateCallback(content, url, startLine);
//}
