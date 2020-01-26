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
