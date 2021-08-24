import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kraken/foundation.dart';

import 'foundation.dart' as foundation;
import 'local_http_server.dart';

// The main entry for kraken unit test.
// Setup all common logic.
void main() {
  // Setup environment.
  WidgetsFlutterBinding.ensureInitialized();

  // Start local HTTP server.
  LocalHttpServer.basePath = 'test/fixtures';
  var httpServer = LocalHttpServer.getInstance();
  print('Local HTTP Server started at ${httpServer.getUri()}');

  // Work around with path_provider.
  Directory tempDirectory = Directory('./temp');
  getKrakenMethodChannel().setMockMethodCallHandler((MethodCall methodCall) async {
    if (methodCall.method == 'getTemporaryDirectory') {
      return tempDirectory.path;
    }
    throw FlutterError('Not implemented for method ${methodCall.method}.');
  });

  // Start tests.
  foundation.main();

  tearDownAll(() {
    if (tempDirectory.existsSync()) {
      tempDirectory.deleteSync(recursive: true);
    }
  });
}
