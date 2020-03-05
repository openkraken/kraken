import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/rendering.dart';
import 'package:flutter/foundation.dart' show debugDefaultTargetPlatformOverride, TargetPlatform;
import 'package:kraken/kraken.dart';
import 'package:kraken/style.dart';
import 'package:flutter_driver/driver_extension.dart';

void main() {
  initBridge();
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

      runApp(
        shouldInitializeBinding: false,
        enableDebug: true,
        afterConnected: () {
          evaluateScripts(payload, 'TEST_CASE', 0);
          RendererBinding.instance.addPostFrameCallback((Duration timeout) {
            completer.complete('done');
          });
        }
      );
    }

    return completer.future;
  });
}
