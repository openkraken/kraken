/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
// ignore_for_file: unused_import, undefined_function

import 'dart:io' show Platform;
import 'dart:ffi';
import 'package:path/path.dart';
// We inject KrakenCallback() and KrakenEvaluateCallback() function into dart:ui
// from out customized flutter engine, so don't remove this line
import 'dart:ui';

typedef InitKrakenCallbackFunc = Void Function();
typedef InitKrakenCallback = void Function();
typedef ReloadJSContextFn = Void Function();
typedef ReloadJSContext = void Function();

/// Search dynamic lib from env.KRAKEN_LIBRARY_PATH or /usr/lib
const String KRAKEN_LIBRARY_PATH = 'KRAKEN_LIBRARY_PATH';
final String kkLibraryPath = Platform.environment[KRAKEN_LIBRARY_PATH];
final String nativeDynamicLibraryPath = Platform.isMacOS
    ? 'libkraken.dylib'
    : Platform.isWindows ? 'libkraken.dll' : 'libkraken.so';
DynamicLibrary nativeDynamicLibrary = DynamicLibrary.open(
    join(kkLibraryPath ?? '\$ORIGIN', nativeDynamicLibraryPath));
final initKrakenCallbackFunc = nativeDynamicLibrary
    .lookup<NativeFunction<InitKrakenCallbackFunc>>("init_callback");
final _initKrakenCallback =
    initKrakenCallbackFunc.asFunction<InitKrakenCallback>();
final ReloadJSContextFunc = nativeDynamicLibrary.lookup<NativeFunction<ReloadJSContextFn>>('reload_js_context');
final _reloadJSContext = ReloadJSContextFunc.asFunction<ReloadJSContext>();

void initKrakenCallback() {
  _initKrakenCallback();
}

void invokeKrakenCallback(String data) {
  KrakenCallback(data);
}

Future<void> reloadJSContext() async {
  return Future.microtask(() {
    _reloadJSContext();
  });
}

void evaluateScripts(String content, String url, {int startLine = 0}) {
  assert(content != null);
  assert(url != null);
  KrakenEvaluateCallback(content, url, startLine);
}
