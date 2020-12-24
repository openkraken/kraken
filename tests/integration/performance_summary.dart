import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:kraken/dom.dart';
import 'package:kraken/module.dart';
import 'package:kraken/widget.dart';
import 'package:kraken/css.dart';
import 'package:ansicolor/ansicolor.dart';
import 'package:path/path.dart' as path;
import '../bridge/from_native.dart';
import '../bridge/to_native.dart';
import 'custom/custom_object_element.dart';

void main() async {
  runApp(MaterialApp(
    title: 'Kraken Intergration Test',
    debugShowCheckedModeBanner: false,
    home: Scaffold(
      body: Kraken(
        viewportWidth: 360,
        viewportHeight: 640,
        debugEnableInspector: false,
      ),
    ),
  ));


  Timer(Duration(seconds: 2), () {
    print('PERFORMANCE_ENTRY_START');
  });

  Timer(Duration(seconds: 5), () {
    print('PERFORMANCE_ENTRY_END');
    exit(0);
  });
}
