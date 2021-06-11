/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
// ignore_for_file: unused_import, undefined_function

import 'dart:ffi';
import 'dart:io' show Platform;
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:path/path.dart';

/// Search dynamic lib from env.KRAKEN_LIBRARY_PATH or /usr/lib
const String KRAKEN_LIBRARY_PATH = 'KRAKEN_LIBRARY_PATH';
const String KRAKEN_JS_ENGINE = 'KRAKEN_JS_ENGINE';
const String KRAKEN_ENABLE_TEST = 'KRAKEN_ENABLE_TEST';
final String kkLibraryPath = Platform.environment[KRAKEN_LIBRARY_PATH] ?? (Platform.isLinux ? '\$ORIGIN' : '');
final String kkJsEngine = Platform.environment[KRAKEN_JS_ENGINE] ??
    ((Platform.isIOS || Platform.isMacOS || Platform.isAndroid) ? 'jsc' : 'v8');
final String libName = Platform.environment[KRAKEN_ENABLE_TEST] == 'true' ? 'libkraken_test_$kkJsEngine' : 'libkraken_$kkJsEngine';
final String nativeDynamicLibraryName = Platform.isMacOS
    ? '$libName.dylib'
    : Platform.isIOS ? 'kraken_bridge.framework/kraken_bridge' : Platform.isWindows ? '$libName.dll' : '$libName.so';
DynamicLibrary nativeDynamicLibrary =
    DynamicLibrary.open(join(kkLibraryPath, nativeDynamicLibraryName));
