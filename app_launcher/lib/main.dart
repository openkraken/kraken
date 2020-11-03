import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:kraken/module.dart';
import 'package:kraken/widget.dart';
import 'dart:ui';

void main() {
  KrakenJavaScriptChannel javaScriptChannel = KrakenJavaScriptChannel();
  javaScriptChannel.onMethodCall = (String method, dynamic arguments) async {
    return 'methods: ' + method;
  };

  Kraken kraken = Kraken(
    viewportWidth: window.physicalSize.width / window.devicePixelRatio,
    viewportHeight: window.physicalSize.height / window.devicePixelRatio,
    javaScriptChannel: javaScriptChannel,
    onLoad: (_) {
      javaScriptChannel.invokeMethod('1234', ['123']);
    },
  );
  runApp(MaterialApp(
    title: 'Loading Test',
    debugShowCheckedModeBanner: false,
    home: kraken
  ));
}

