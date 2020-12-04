import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:kraken/dom.dart';
import 'package:kraken/module.dart';
import 'package:kraken/widget.dart';
import 'package:kraken/css.dart';
import 'package:ansicolor/ansicolor.dart';
import 'package:path/path.dart' as path;
import '../bridge/from_native.dart';
import '../bridge/to_native.dart';
import 'custom/custom_object_element.dart';

String pass = (AnsiPen()..green())('[TEST PASS]');
String err = (AnsiPen()..red())('[TEST FAILED]');

final Directory specsDirectory = Directory(Platform.environment['KRAKEN_SPEC_DIR'] + '/integration/.specs');
final Directory snapshotsDirectory = Directory(Platform.environment['KRAKEN_SPEC_DIR'] + '/integration/snapshots');

void main() async {
  // Set render font family AlibabaPuHuiTi to resolve rendering difference.
  CSSText.DEFAULT_FONT_FAMILY_FALLBACK = ['AlibabaPuHuiTi'];
  CSSText.DEFAULT_FONT_SIZE = 14.0;
  setObjectElementFactory(customObjectElementFactory);

  List<FileSystemEntity> specs = specsDirectory.listSync(recursive: true);
  List<Map<String, String>> mainTestPayload = [];
  for (FileSystemEntity file in specs) {
    if (file.path.endsWith('js')) {
      String filename = path.basename(file.path);
      String code = File(file.path).readAsStringSync();
      mainTestPayload.add({
        'filename': filename,
        'filepath': file.path,
        'code': code,
      });
    }
  }

  List<List<Map<String, String>>> allSpecsPayload = [
    mainTestPayload,
    mainTestPayload.reversed.toList()
  ];
  List<Kraken> widgets = [];

  for (int i = 0; i < 1; i ++) {
    KrakenJavaScriptChannel javaScriptChannel = KrakenJavaScriptChannel();
    javaScriptChannel.onMethodCall = (String method, dynamic arguments) async {
      javaScriptChannel.invokeMethod(method, arguments);
      return 'method: ' + method;
    };

    Kraken widget = Kraken(
      viewportWidth: 360,
      viewportHeight: 640,
      bundleContent: 'console.log("starting integration test")',
      disableViewportWidthAssertion: true,
      disableViewportHeightAssertion: true,
      javaScriptChannel: javaScriptChannel,
      debugEnableInspector: false,
    );
    widgets.add(widget);
  }

  runApp(MaterialApp(
    title: 'Kraken Intergration Test',
    debugShowCheckedModeBanner: false,
    home: Scaffold(
      appBar: AppBar(
        title: Text('Kraken Integration Test')
      ),
      body: Wrap(
        children: widgets,
      ),
    ),
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

      List<Map<String, String>> testPayload = allSpecsPayload[i];

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
        exit(1);
        return;
      }
    }

    exit(0);
  });
}
