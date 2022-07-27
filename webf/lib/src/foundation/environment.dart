/*
 * Copyright (C) 2020-present The Kraken authors. All rights reserved.
 */

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

String? _webfTemporaryPath;
Future<String> getWebFTemporaryPath() async {
  if (_webfTemporaryPath == null) {
    String? temporaryDirectory = await getKrakenMethodChannel().invokeMethod<String>('getTemporaryDirectory');
    if (temporaryDirectory == null) {
      throw FlutterError('Can\'t get temporary directory from native side.');
    }
    _webfTemporaryPath = temporaryDirectory;
  }
  return _webfTemporaryPath!;
}

MethodChannel _methodChannel = const MethodChannel('kraken');
MethodChannel getKrakenMethodChannel() {
  return _methodChannel;
}
