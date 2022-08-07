/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'dart:ffi';
import 'dart:io' show Platform;

import 'package:path/path.dart';

abstract class WebFDynamicLibrary {
  static final String _defaultLibraryPath = Platform.isLinux ? '\$ORIGIN' : '';

  /// The search path that dynamic library be load, if null using default.
  static String _dynamicLibraryPath = _defaultLibraryPath;

  static String get dynamicLibraryPath => _dynamicLibraryPath;

  static set dynamicLibraryPath(String value) {
    _dynamicLibraryPath = value;
  }

  // The kraken library name.
  static String libName = 'libwebf';

  static String get _nativeDynamicLibraryName {
    if (Platform.isMacOS) {
      return '$libName.dylib';
    } else if (Platform.isIOS) {
      return 'webf_bridge.framework/webf_bridge';
    } else if (Platform.isWindows) {
      return '$libName.dll';
    } else if (Platform.isAndroid || Platform.isLinux) {
      return '$libName.so';
    } else {
      throw UnimplementedError('Not supported platform.');
    }
  }

  static DynamicLibrary? _ref;

  static DynamicLibrary get ref {
    DynamicLibrary? nativeDynamicLibrary = _ref;
    _ref = nativeDynamicLibrary ??= DynamicLibrary.open(join(_dynamicLibraryPath, _nativeDynamicLibraryName));
    return nativeDynamicLibrary;
  }
}
