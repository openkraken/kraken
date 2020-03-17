import 'dart:convert';
import 'dart:async';
import 'package:kraken/kraken.dart';
import 'package:kraken/style.dart';
import 'package:ansicolor/ansicolor.dart';
import 'package:flutter_driver/driver_extension.dart';
import '../bridge/from_native.dart';
import '../bridge/to_native.dart';

String pass = (AnsiPen()..green())('[TEST PASS]');
String err = (AnsiPen()..red())('[TEST FAILED]');

void main() {
  initTestFramework();
  registerDartTestMethodsToCpp();

  // Set render font family AlibabaPuHuiTi to resolve rendering difference.
  TextStyleMixin.DEFAULT_FONT_FAMILY_FALLBACK = ['AlibabaPuHuiTi'];

  // This line enables the extension.
  enableFlutterDriverExtension(handler: (String payload) async {
    Completer<String> completer = Completer();
    List specDescriptions = jsonDecode(payload);


    // Preload load test cases
    for (Map spec in specDescriptions) {
      String filename = spec['filename'];
      String code = spec['code'];
      evaluateTestScripts(code, url: filename);
    }

    runApp(
      shouldInitializeBinding: false,
      enableDebug: true,
      afterConnected: () async {
        String status = await executeTest();
        if (status == 'failed') {
          print('$err with $status.');
          completer.complete('failed');
        } else {
          print('$pass with $status.');
          completer.complete('success');
        }
      },
    );

    return completer.future;
  });
}
