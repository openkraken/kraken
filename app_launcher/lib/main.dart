import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:kraken/widget.dart';
import 'dart:ui';
import 'title_bar.dart';

void main() {
  runApp(LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return KrakenWidget(400, 300,
            bundleURL: 'http://localhost:9999/kraken/index.js');
      }
  ));
}
