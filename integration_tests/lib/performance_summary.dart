import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:kraken/widget.dart';

// Called by CI
// `flutter run --target=integration_tests/performance-summery.dart`
void main() async {
  runApp(MaterialApp(
    title: 'Kraken Intergration Test',
    debugShowCheckedModeBanner: false,
    home: Scaffold(
      body: Kraken(
        viewportWidth: 360,
        viewportHeight: 640,
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
