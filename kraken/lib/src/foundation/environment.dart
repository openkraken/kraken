/*
 * Copyright (C) 2020-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:io';

import 'package:path_provider/path_provider.dart';

// Judge is production mode.
const bool PRODUCTION = bool.fromEnvironment('dart.vm.product');

String? _krakenTemporaryPath;
Future<String> getKrakenTemporaryPath() async {
  if (_krakenTemporaryPath == null) {
    Directory temporaryDirectory = await getTemporaryDirectory();
    _krakenTemporaryPath = temporaryDirectory.path + '/Kraken';
  }
  return _krakenTemporaryPath!;
}
