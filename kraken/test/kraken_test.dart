import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'foundation.dart' as foundation;
import 'local_http_server.dart';

// The main entry for kraken unit test.
// Setup all common logic.
void main() {
  // Setup environment.
  WidgetsFlutterBinding.ensureInitialized();

  // Start local HTTP server.
  LocalHttpServer.basePath = 'test/res';
  var httpServer = LocalHttpServer.getInstance();
  print('Local HTTP Server started at ${httpServer.getUri()}');

  // Work around with path_provider.
  Directory tempDirectory = Directory('./temp');
  const MethodChannel channel = MethodChannel('plugins.flutter.io/path_provider');
  channel.setMockMethodCallHandler((MethodCall methodCall) async => tempDirectory.path);

  // Start tests.
  foundation.main();

  tearDownAll(() {
    if (tempDirectory.existsSync()) {
      tempDirectory.deleteSync(recursive: true);
    }
  });
}
