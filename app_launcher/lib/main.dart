import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:kraken/widget.dart';
import 'title_bar.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
      title: 'Loading Test',
      home: Material(
        clipBehavior: Clip.none,
        child: SafeArea(
          child: Column(
            children: <Widget>[
              TitleBar("这是个标题"),
              LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                return KrakenWidget(414, 300, bundleURL: 'http://127.0.0.1:8080/bundle.js');
              })
            ],
          ),
        ),
      )));
}
