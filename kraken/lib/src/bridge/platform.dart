/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:ffi';
import 'dart:io' show Platform;

import 'package:path/path.dart';

abstract class KrakenPlatform {
  static final String _defaultLibraryPath = Platform.isLinux ? '\$ORIGIN' : '';

  /// The search path that dynamic library be load, if null using default.
  static String _dynamicLibraryPath = _defaultLibraryPath;
  static String get dynamicLibraryPath => _dynamicLibraryPath;
  static set dynamicLibraryPath(String value) {
    _dynamicLibraryPath = value;
  }

  // The kraken library name.
  static String libName = 'libkraken';

  static String get nativeDynamicLibraryName {
    if (Platform.isMacOS) {
      return '$libName.dylib';
    } else if (Platform.isIOS) {
      return 'kraken_bridge.framework/kraken_bridge';
    } else if (Platform.isWindows) {
      return '$libName.dll';
    } else if (Platform.isAndroid || Platform.isLinux) {
      return '$libName.so';
    } else {
      throw UnimplementedError('Not supported platform.');
    }
  }

  static DynamicLibrary? _nativeDynamicLibrary;
  static DynamicLibrary get nativeDynamicLibrary {
    DynamicLibrary? nativeDynamicLibrary = _nativeDynamicLibrary;
    _nativeDynamicLibrary = nativeDynamicLibrary ??= DynamicLibrary.open(join(_dynamicLibraryPath, nativeDynamicLibraryName));
    return nativeDynamicLibrary;
  }
}
