import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:kraken/widget.dart';

void main() {
  runApp(Kraken(
    viewportWidth: window.physicalSize.width / window.devicePixelRatio,
    viewportHeight: window.physicalSize.height / window.devicePixelRatio,
  ));
}
