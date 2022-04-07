/*
 * Copyright (C) 2022-present The Kraken authors. All rights reserved.
 */
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:kraken/css.dart';
import 'package:kraken/bridge.dart';
import 'package:kraken/dom.dart';
import 'package:kraken/gesture.dart';
import 'package:kraken/kraken.dart';
import 'package:kraken/module.dart';
import 'package:kraken/widget.dart';
import 'package:ansicolor/ansicolor.dart';
import 'package:path/path.dart' as path;

import 'bridge/from_native.dart';
import 'bridge/to_native.dart';
import 'bridge/test_input.dart';
import 'custom/custom_element.dart';
import 'local_http_server.dart';

String? pass = (AnsiPen()..green())('[TEST PASS]');
String? err = (AnsiPen()..red())('[TEST FAILED]');

final String __dirname = path.dirname(Platform.script.path);
final String testDirectory = Platform.environment['KRAKEN_TEST_DIR'] ?? __dirname;

// By CLI: `KRAKEN_ENABLE_TEST=true flutter run`
void main() async {
  // Overrides library name.
  KrakenDynamicLibrary.libName = 'libkraken_test';
  defineKrakenCustomElements();

  // FIXME: This is a workaround for testcases.
  ParagraphElement.defaultStyle = { DISPLAY: BLOCK };

  // Start local HTTP server.
  var httpServer = LocalHttpServer.getInstance();
  print('Local HTTP server started at: ${httpServer.getUri()}');

  String codeInjection = '''
    // This segment inject variables for test environment.
    LOCAL_HTTP_SERVER = '${httpServer.getUri().toString()}';
  ''';

  // Set render font family AlibabaPuHuiTi to resolve rendering difference.
  CSSText.DEFAULT_FONT_FAMILY_FALLBACK = ['AlibabaPuHuiTi'];

  final String specTarget = '.specs/core.build.js';
  final File spec = File(path.join(testDirectory, specTarget));
  KrakenJavaScriptChannel javaScriptChannel = KrakenJavaScriptChannel();
  javaScriptChannel.onMethodCall = (String method, dynamic arguments) async {
    javaScriptChannel.invokeMethod(method, arguments);
    return 'method: ' + method;
  };

  // This is a virtual location for test program to test [Location] functionality.
  final String specUrl = 'assets:///test.js';
  late Kraken kraken;

  kraken = Kraken(
    viewportWidth: 360,
    viewportHeight: 640,
    bundle: KrakenBundle.fromContent('console.log("Starting integration tests...")', url: specUrl),
    disableViewportWidthAssertion: true,
    disableViewportHeightAssertion: true,
    javaScriptChannel: javaScriptChannel,
    gestureListener: GestureListener(
      onDrag: (GestureEvent gestureEvent) {
        if (gestureEvent.state == EVENT_STATE_START) {
          var event = CustomEvent('nativegesture', CustomEventInit(detail: 'nativegesture'));
          kraken.controller!.view.document.documentElement?.dispatchEvent(event);
        }
      },
    ),
  );

  runZonedGuarded(() {
    runApp(MaterialApp(
      title: 'Kraken Integration Tests',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text('Kraken Integration Tests')
        ),
        body: Wrap(
          children: [
            kraken,
          ],
        ),
      ),
    ));
  }, (Object error, StackTrace stack) {
    print('$error\n$stack');
  });

  testTextInput = TestTextInput();

  WidgetsBinding.instance!.addPostFrameCallback((_) async {
    registerDartTestMethodsToCpp();
    int contextId = kraken.controller!.view.contextId;

    initTestFramework(contextId);
    addJSErrorListener(contextId, print);
    // Preload load test cases
    String code = spec.readAsStringSync();
    evaluateTestScripts(contextId, codeInjection + code, url: specUrl);
    String result = await executeTest(contextId);
    // Manual dispose context for memory leak check.
    disposePage(kraken.controller!.view.contextId);

    exit(result == 'failed' ? 1 : 0);
  });
}

