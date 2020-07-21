import 'dart:convert';
import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart' show MaterialApp;
import 'package:flutter/widgets.dart';
import 'package:kraken/widget.dart';
import 'package:flutter/rendering.dart';
import 'package:kraken/css.dart';
import 'package:ansicolor/ansicolor.dart';
import 'package:flutter_driver/driver_extension.dart';
import '../bridge/from_native.dart';
import '../bridge/to_native.dart';

String pass = (AnsiPen()..green())('[TEST PASS]');
String err = (AnsiPen()..red())('[TEST FAILED]');

void main() {
  // Set render font family AlibabaPuHuiTi to resolve rendering difference.
  CSSTextMixin.DEFAULT_FONT_FAMILY_FALLBACK = ['AlibabaPuHuiTi'];

  // This line enables the extension.
  enableFlutterDriverExtension(handler: (String payload) async {
    Completer<String> completer = Completer();
    List specDescriptions = jsonDecode(payload);

    runApp(MaterialApp(
        title: 'Loading Test',
        debugShowCheckedModeBanner: false,
        home: LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
          return KrakenWidget(
              window.physicalSize.width / window.devicePixelRatio, window.physicalSize.height / window.devicePixelRatio,
              bundleURL: 'http://127.0.0.1:8080/bundle.js');
        })));

    WidgetsBinding.instance
        .addPostFrameCallback((_) async {
      registerDartTestMethodsToCpp();
      initTestFramework();
      addJSErrorListener((String err) {
        print(err);
      });

      // Preload load test cases
      for (Map spec in specDescriptions) {
        String filename = spec['filename'];
        String code = spec['code'];
        evaluateTestScripts(code, url: filename);
      }

      String status = await executeTest();
      if (status == 'failed') {
        print('$err with $status.');
        completer.complete('failed');
      } else {
        print('$pass with $status.');
        completer.complete('success');
      }
    });

    return completer.future;
  });
}
