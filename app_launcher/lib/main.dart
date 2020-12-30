import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:kraken/kraken.dart';
import 'package:kraken/widget.dart';
import 'dart:ui';

void main() {
  if (Platform.environment['KRAKEN_MAIN_ENTRY'] == 'cli') {
    launch();
  } else {
    runApp(MaterialApp(
      title: 'Kraken App Demo',
      home: FirstRoute(),
    ));
  }
}

class FirstRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kraken App Demo'),
      ),
      body: Center(
        child: RaisedButton(
          child: Text('Open Kraken Page'),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SecondRoute()),
            );
          },
        ),
      ),
    );
  }
}

class SecondRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Kraken kraken = Kraken(
      viewportWidth: window.physicalSize.width / window.devicePixelRatio,
      viewportHeight: window.physicalSize.height / window.devicePixelRatio,
    );

    return kraken;
  }
}
