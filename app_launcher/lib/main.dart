// import 'package:flutter/material.dart';
// import 'package:flutter/widgets.dart';
// import 'package:kraken/widget.dart';
// import 'dart:ui';
import 'package:kraken/kraken.dart' as kraken;

void main() {
  kraken.launch(
      bundleURLOverride: 'http://127.0.0.1:3300/kraken_debug_server.js');
  // runApp(MaterialApp(
  //     title: 'Loading Test',
  //     debugShowCheckedModeBanner: false,
  //     home: KrakenWidget(
  //       'main',
  //         window.physicalSize.width / window.devicePixelRatio, window.physicalSize.height / window.devicePixelRatio)
  // ));
}
