import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/rendering.dart';
import 'package:flutter/foundation.dart' show debugDefaultTargetPlatformOverride, TargetPlatform;
import 'package:kraken/element.dart';
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
      String caseName = ret['case'];
      runApp(
        shouldInitializeBinding: false,
        enableDebug: true,
        afterConnected: () {
          evaluateScripts(payload, caseName, 0);
          // Force wait to execute async ops.
          sleep(const Duration(microseconds: 200));

          RendererBinding.instance.addPostFrameCallback((Duration timeout) async {
            BodyElement body = ElementManager().getRootElement();
            Uint8List bodyImage = await body.toBlob(devicePixelRatio: 1.0);
            List<int> bodyImageList = bodyImage.toList();
            completer.complete(jsonEncode(bodyImageList));
          });
        }
      );
    }

    return completer.future;
  });
}
