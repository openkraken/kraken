import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:kraken/widget.dart';
import 'dart:ui';

void main() {
  runApp(MaterialApp(
      title: 'Loading Test',
      debugShowCheckedModeBanner: false,
      home: KrakenWidget(
          window.physicalSize.width / window.devicePixelRatio, window.physicalSize.height / window.devicePixelRatio,
          bundleURL: 'http://localhost:9999/kraken/index.js')
  ));
}
