/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
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
final String kkLibraryPath = Platform.environment[KRAKEN_LIBRARY_PATH];
final String nativeDynamicLibraryPath = Platform.isMacOS || Platform.isIOS
    ? 'libkraken.dylib'
    : Platform.isWindows ? 'libkraken.dll' : 'libkraken.so';
DynamicLibrary nativeDynamicLibrary = Platform.isAndroid
    ? DynamicLibrary.open('libkraken.so')
    : DynamicLibrary.open(
        join(kkLibraryPath ?? '\$ORIGIN', nativeDynamicLibraryPath));
