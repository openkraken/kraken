import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:kraken/kraken.dart';
import 'package:kraken/widget.dart';
import 'dart:ui';

void main() {
  Kraken kraken = Kraken(
    viewportWidth: window.physicalSize.width / window.devicePixelRatio,
    viewportHeight: window.physicalSize.height / window.devicePixelRatio,
  );
  runApp(MaterialApp(
      title: 'Loading Test',
      debugShowCheckedModeBanner: false,
      home: kraken
  ));
}
