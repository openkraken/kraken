import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:kraken/element.dart';
import 'package:kraken/kraken.dart';
import 'package:kraken/widget.dart';
import 'package:kraken/css.dart';
import 'package:ansicolor/ansicolor.dart';
import 'package:flutter_driver/driver_extension.dart';
import '../bridge/from_native.dart';
import '../bridge/to_native.dart';
import 'custom/custom_object_element.dart';

String pass = (AnsiPen()..green())('[TEST PASS]');
String err = (AnsiPen()..red())('[TEST FAILED]');

void main() {
  // Set render font family AlibabaPuHuiTi to resolve rendering difference.
  CSSText.DEFAULT_FONT_FAMILY_FALLBACK = ['AlibabaPuHuiTi'];
  CSSText.DEFAULT_FONT_SIZE = 14.0;
  setObjectElementFactory(customObjectElementFactory);


  // This line enables the extension.
  enableFlutterDriverExtension(handler: (String payload) async {
    Completer<String> completer = Completer();
    List allSpecsPayload = jsonDecode(payload);

    List<Kraken> widgets = [];

    for (int i = 0; i < 2; i ++) {
      Kraken widget = Kraken(
        viewportWidth: 360,
        viewportHeight: 640,
        bundleContent: 'console.log("starting integration test")',
        disableViewportWidthAssertion: true,
        disableViewportHeightAssertion: true,
        onLoad: (KrakenController controller) {
          controller.methodChannel.onMethodCall = (String method, dynamic arguments) async {
            controller.methodChannel.invokeMethod(method, arguments);
            return 'method: ' + method;
          };
        },
      );
      widgets.add(widget);
    }

    runApp(MaterialApp(
        title: 'Loading Test',
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          appBar: AppBar(
            title: Text('Kraken Integration Test')
          ),
          body: Wrap(
            children: widgets,
          )
        )
    ));

    WidgetsBinding.instance
        .addPostFrameCallback((_) async {
      registerDartTestMethodsToCpp();

      List<Future<String>> testResults = [];

      for (int i = 0; i < widgets.length; i ++) {
        int contextId = i;
        initTestFramework(contextId);
        addJSErrorListener(contextId, (String err) {
          print(err);
        });

        List testPayload = allSpecsPayload[i];

        // Preload load test cases
        for (Map spec in testPayload) {
          String filename = spec['filename'];
          String code = spec['code'];
          evaluateTestScripts(contextId, code, url: filename);
        }

        testResults.add(executeTest(contextId));
      }

      List<String> results = await Future.wait(testResults);

      for (int i = 0; i < results.length; i ++) {
        String status = results[i];
        if (status == 'failed') {
          completer.complete('failed');
          return;
        }
      }

      completer.complete('success');
    });

    return completer.future;
  });
}
