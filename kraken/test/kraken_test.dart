import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kraken/kraken.dart';

import 'local_http_server.dart';

import 'src/foundation/bundle.dart' as bundle;
import 'src/foundation/convert.dart' as convert;
import 'src/foundation/http_cache.dart' as http_cache;
import 'src/foundation/http_client.dart' as http_client;
import 'src/foundation/http_client_interceptor.dart' as http_client_interceptor;
import 'src/foundation/environment.dart' as environment;
import 'src/foundation/uri_parser.dart' as uri_parser;

import 'src/module/fetch.dart' as fetch;

import 'src/css/style_rule_parser.dart' as style_rule_parser;
import 'src/css/style_sheet_parser.dart' as style_sheet_parser;
import 'src/css/values.dart' as css_values;

import 'src/gesture/scroll_physics.dart' as scroll_physics;


// The main entry for kraken unit test.
// Setup all common logic.
void main() {
  // Setup environment.
  TestWidgetsFlutterBinding.ensureInitialized();

  // Start local HTTP server.
  LocalHttpServer.basePath = 'test/fixtures';
  var httpServer = LocalHttpServer.getInstance();
  print('Local HTTP Server started at ${httpServer.getUri()}');

  // Inject a custom user agent, to avoid reading from bridge.
  NavigatorModule.setCustomUserAgent('kraken/test');

  // Work around with path_provider.
  Directory tempDirectory = Directory('./temp');
  getKrakenMethodChannel().setMockMethodCallHandler((MethodCall methodCall) async {
    if (methodCall.method == 'getTemporaryDirectory') {
      return tempDirectory.path;
    }
    throw FlutterError('Not implemented for method ${methodCall.method}.');
  });

  // Start tests.
  group('foundation', () {
    bundle.main();
    convert.main();
    http_cache.main();
    http_client.main();
    http_client_interceptor.main();
    environment.main();
    uri_parser.main();
  });

  group('module', () {
    fetch.main();
  });

  group('css', () {
    style_rule_parser.main();
    style_sheet_parser.main();
    css_values.main();
  });

  group('gesture', () {
    scroll_physics.main();
  });

  tearDownAll(() {
    if (tempDirectory.existsSync()) {
      tempDirectory.deleteSync(recursive: true);
    }
  });
}
