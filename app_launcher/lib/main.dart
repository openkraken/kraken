import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart' as OfficialWidget;
import 'package:kraken/element.dart';
import 'package:kraken/kraken.dart' as kraken;
import 'package:kraken/kraken.dart';
import 'package:kraken_app_launcher/title_bar.dart';

void main() {
//  kraken.launch(bundleURLOverride: 'https://dev.g.alicdn.com/kraken/kraken-demos/richtext/build/kraken/index.js');
  WidgetsFlutterBinding.ensureInitialized();
  OfficialWidget.runApp(MaterialApp(
      title: 'Loading Test',
      home: Material(
        clipBehavior: Clip.none,
        child: SafeArea(
          child: Column(
            children: <Widget>[
              TitleBar("这是个标题"),
              LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    print(constraints);
                return KrakenWidget(
                    "https://dev.g.alicdn.com/kraken/kraken-demos/richtext/build/kraken/index.js");
              })
//              KrakenWidget(
//                  "https://dev.g.alicdn.com/kraken/kraken-demos/dragable-list/build/kraken/index.js")
            ],
          ),
        ),
      )));
}
