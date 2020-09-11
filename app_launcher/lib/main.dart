import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:kraken/widget.dart';
import 'dart:ui';

void main() {
  Kraken kraken = Kraken(
    viewportWidth: window.physicalSize.width / window.devicePixelRatio,
    viewportHeight: window.physicalSize.height / window.devicePixelRatio,
    onLoad: (controller) {
      controller.methodChannel.onMethodCall = (String method, dynamic arguments) async {
        return 'methods' + method;
      };
    },
  );
  runApp(MaterialApp(
      title: 'Loading Test',
      debugShowCheckedModeBanner: false,
      home: kraken
  ));
}
