import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:kraken/widget.dart';
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

    KrakenWidget main = KrakenWidget(
      'main',
      360, 640,
      bundleContent: 'console.log("starting main integration test")',);

    KrakenWidget child = KrakenWidget(
      'child',
      360, 640,
      bundleContent: 'console.log("starting child integration test")');

    runApp(MaterialApp(
        title: 'Loading Test',
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          appBar: AppBar(
            title: Text('Kraken Integration Test')
          ),
          body: Wrap(
            children: <Widget>[
              main,
            ],
          )
        )
    ));

    WidgetsBinding.instance
        .addPostFrameCallback((_) async {
      registerDartTestMethodsToCpp();
      int mainContextId = main.controller.view.contextId;
//      int childContextId = child.controller.view.contextId;
      initTestFramework(mainContextId);
//      initTestFramework(childContextId);
      addJSErrorListener(mainContextId, (String err) {
        print(err);
      });
//      addJSErrorListener(childContextId, (String err) {
//        print(err);
//      });

      // Preload load test cases
      for (Map spec in specDescriptions) {
        String filename = spec['filename'];
        String code = spec['code'];
        evaluateTestScripts(mainContextId, code, url: filename);
//        evaluateTestScripts(childContextId, code, url: filename);
      }

      Future<String> mainTestResult = executeTest(mainContextId);
//      Future<String> childTestResult = executeTest(childContextId);

      List<String> results = await Future.wait([mainTestResult]);

      for (int i = 0; i < results.length; i ++) {
        String status = results[i];
        if (status == 'failed') {
          completer.complete('failed');
          break;
        }
      }
    });

    return completer.future;
  });
}
