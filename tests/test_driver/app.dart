import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/widgets.dart' show WidgetsBinding;
import 'package:flutter/rendering.dart';
import 'package:flutter/foundation.dart' show debugDefaultTargetPlatformOverride, TargetPlatform;
import 'package:kraken/kraken.dart';
import 'package:kraken/element.dart';
import 'package:flutter_driver/driver_extension.dart';

void onFrameBegin(Duration timeStamp) {
  emitUIEvent(FRAME_BEGIN);
  WidgetsBinding.instance.addPostFrameCallback(onFrameBegin);
}

void main() {
  initBridge();
  if (Platform.isMacOS) debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

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

  // To start onFrameBegin tick.
  WidgetsBinding.instance.addPostFrameCallback(onFrameBegin);
}
