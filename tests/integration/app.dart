import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart' show debugDefaultTargetPlatformOverride, TargetPlatform;
import 'package:kraken/kraken.dart';
import 'package:kraken/style.dart';
import 'package:ansicolor/ansicolor.dart';
import 'package:flutter_driver/driver_extension.dart';
import '../bridge/from_native.dart';
import '../bridge/to_native.dart';

String pass = (AnsiPen()..green())('[TEST]');
String err = (AnsiPen()..red())('[TEST]');

void main() {
  initTestFramework();
  registerDartTestMethodsToCpp();

  if (Platform.isMacOS) debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

  // Set render font family AlibabaPuHuiTi to resolve rendering difference.
  TextStyleMixin.DEFAULT_FONT_FAMILY_FALLBACK = ['AlibabaPuHuiTi'];

  // This line enables the extension.
  enableFlutterDriverExtension(handler: (String payload) async {
    Completer<String> completer = Completer();
    List<Map<String, dynamic>> fileInfo = jsonDecode(payload);

    // preload load test cases
    for (Map<String, dynamic> file in fileInfo) {
      String filename = file['filename'];
      String code = file['code'];
      evaluateTestScripts(code, url: filename);
    }

    // init flutter app at first time
    runApp(
        shouldInitializeBinding: false,
        enableDebug: true,
        afterConnected: () async {
          String status = await executeTest();
          print('test $status');
          completer.complete();
        });
//
    return completer.future;
  });
}
