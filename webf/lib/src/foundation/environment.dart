/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

String? _webfTemporaryPath;
Future<String> getWebFTemporaryPath() async {
  if (_webfTemporaryPath == null) {
    String? temporaryDirectory = await getWebFMethodChannel().invokeMethod<String>('getTemporaryDirectory');
    if (temporaryDirectory == null) {
      throw FlutterError('Can\'t get temporary directory from native side.');
    }
    _webfTemporaryPath = temporaryDirectory;
  }
  return _webfTemporaryPath!;
}

MethodChannel _methodChannel = const MethodChannel('webf');
MethodChannel getWebFMethodChannel() {
  return _methodChannel;
}
