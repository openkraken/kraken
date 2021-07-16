/*
 * Copyright (C) 2020-present Alibaba Inc. All rights reserved.
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
final String? kkLibraryPath = Platform.environment[KRAKEN_LIBRARY_PATH];
final String kkJsEngine = Platform.environment[KRAKEN_JS_ENGINE] ?? 'quickjs';
final String libName = 'libkraken_test_$kkJsEngine';
final String nativeDynamicLibraryName = Platform.isMacOS || Platform.isIOS
    ? '$libName.dylib'
    : Platform.isWindows ? '$libName.dll' : '$libName.so';
DynamicLibrary nativeDynamicLibrary = DynamicLibrary.open(join(
    kkLibraryPath ?? (Platform.isLinux ? '\$ORIGIN' : ''),
    nativeDynamicLibraryName));
