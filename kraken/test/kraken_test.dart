import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kraken/foundation.dart';

import 'foundation.dart' as foundation;
import 'mock.dart';

// The main entry for kraken unit test.
// Setup all common logic.
void main() {
  // Setup environment.
  WidgetsFlutterBinding.ensureInitialized();

  // Start mock HTTP server.
  var mockedHttpServer = MockedHttpServer.getInstance();
  print('Mocked HTTP Server started at http://127.0.0.1:${mockedHttpServer.port}');

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
