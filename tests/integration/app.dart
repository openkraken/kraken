import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/rendering.dart';
import 'package:colorize/colorize.dart';
import 'package:flutter/foundation.dart' show debugDefaultTargetPlatformOverride, TargetPlatform;
import 'package:kraken/kraken.dart';
import 'package:kraken/style.dart';
import 'package:kraken/src/bridge/from_native.dart';
import 'package:flutter_driver/driver_extension.dart';
import '../bridge/from_native.dart';
import '../bridge/to_native.dart';

void main() {
  initTestFramework();
  registerDartTestMethodsToCpp();
  registerDartMethodsToCpp();
  addJSErrorListener((String errmsg) {
    Colorize color = Colorize(errmsg);
    color.red();
    print(color);
  });

  if (Platform.isMacOS) debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

  // Set render font family AlibabaPuHuiTi to resolve rendering difference.
  TextStyleMixin.DEFAULT_FONT_FAMILY_FALLBACK = ['AlibabaPuHuiTi'];

  // This line enables the extension.
  enableFlutterDriverExtension(handler: (String message) {
    Completer<String> completer = new Completer();
    unmountApp();

    var ret = jsonDecode(message);
    if (ret['type'] == 'startup') {
      String payload = ret['payload'];
      String caseName = ret['case'];
      runApp(
          shouldInitializeBinding: false,
          enableDebug: true,
          afterConnected: () {
            onItDone((String errmsg) {
              Map<String, double> screenData = {
                'devicePixelRatio': window.devicePixelRatio,
                'width': window.physicalSize.width,
                'height': window.physicalSize.height
              };
              completer.complete(jsonEncode(screenData));
            });

            // javascript it is equal to dart's test().
            evaluateTestScripts(payload, url: caseName);
          });
    }

    return completer.future;
  });
}
