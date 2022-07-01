/*
 * Copyright (C) 2022-present The Kraken authors. All rights reserved.
 */
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:kraken/bridge.dart';
import 'package:kraken/css.dart';
import 'package:kraken/dom.dart';
import 'package:kraken/foundation.dart';
import 'package:kraken/widget.dart';
import 'package:ansicolor/ansicolor.dart';
import 'package:path/path.dart' as path;
import 'package:kraken_websocket/kraken_websocket.dart';
import 'package:kraken_video_player/kraken_video_player.dart';
import 'package:kraken_webview/kraken_webview.dart';

import 'bridge/from_native.dart';
import 'bridge/to_native.dart';
import 'custom/custom_object_element.dart';

String? pass = (AnsiPen()..green())('[TEST PASS]');
String? err = (AnsiPen()..red())('[TEST FAILED]');

final String __dirname = path.dirname(Platform.script.path);
final String testDirectory =
    Platform.environment['KRAKEN_TEST_DIR'] ?? __dirname;

const int KRAKEN_NUM = 1;
Map<int, Kraken> krakenMap = Map();

// Test for UriParser.
class IntegrationTestUriParser extends UriParser {
  @override
  Uri resolve(Uri base, Uri relative) {
    if (base.toString().isEmpty && relative.path.startsWith('assets/')) {
      return Uri.file(relative.path);
    } else {
      return super.resolve(base, relative);
    }
  }
}

// By CLI: `KRAKEN_ENABLE_TEST=true flutter run`
void main() async {
  // Overrides library name.
  KrakenDynamicLibrary.libName = 'libkraken_test';

  KrakenWebsocket.initialize();
  KrakenVideoPlayer.initialize();
  KrakenWebView.initialize();
  setObjectElementFactory(customObjectElementFactory);

  // FIXME: This is a workaround for testcase
  ParagraphElement.defaultStyle = {
    DISPLAY: BLOCK,
  };

  // Set render font family AlibabaPuHuiTi to resolve rendering difference.
  CSSText.DEFAULT_FONT_FAMILY_FALLBACK = ['AlibabaPuHuiTi'];

  File specs = File(path.join(testDirectory, '.specs/plugin.build.js'));

  List<Map<String, String>> allSpecsPayload = [
    {
      'filename': path.basename(specs.path),
      'filepath': specs.path,
      'code': specs.readAsStringSync()
    }
  ];
  List<Widget> widgets = [];

  for (int i = 0; i < KRAKEN_NUM; i++) {
    var kraken = krakenMap[i] = Kraken(
      viewportWidth: 360,
      viewportHeight: 640,
      bundle: KrakenBundle.fromContent('console.log("Starting Plugin tests...")'),
      disableViewportWidthAssertion: true,
      disableViewportHeightAssertion: true,
      uriParser: IntegrationTestUriParser(),
    );
    widgets.add(kraken);
  }

  runApp(MaterialApp(
    title: 'Kraken Plugin Tests',
    debugShowCheckedModeBanner: false,
    home: Scaffold(
      appBar: AppBar(title: Text('Kraken Plugin Tests')),
      body: Wrap(
        children: widgets,
      ),
    ),
  ));

  WidgetsBinding.instance!.addPostFrameCallback((_) async {
    List<Future<String>> testResults = [];

    for (int i = 0; i < widgets.length; i++) {
      int contextId = i;
      initTestFramework(contextId);
      addJSErrorListener(contextId, (String err) {
        print(err);
      });
      registerDartTestMethodsToCpp(contextId);

      Map<String, String> payload = allSpecsPayload[i];

      // Preload load test cases
      String filename = payload['filename']!;
      String code = payload['code']!;
      evaluateTestScripts(contextId, code, url: filename);

      testResults.add(executeTest(contextId));
    }

    List<String> results = await Future.wait(testResults);

    for (int i = 0; i < results.length; i++) {
      String status = results[i];
      if (status == 'failed') {
        exit(1);
      }
    }

    exit(0);
  });
}
