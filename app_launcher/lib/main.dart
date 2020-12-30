import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:kraken/widget.dart';
import 'dart:ui';
import 'package:kraken/gesture.dart';

void main() {
  runApp(MaterialApp(
    title: 'Kraken App Demo',
    home: FirstRoute(),
  ));
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

class NativeGestureClient implements GestureClient {
  @override
  void overflowByUpdate(DragUpdateDetails details) {
    print('overflowByUpdate=${details}');
  }

  @override
  void overflowByStart(DragStartDetails details) {
    print('overflowByStart=${details}');
  }

  @override
  void overflowByEnd(DragEndDetails details) {
    print('overflowByEnd=${details}');
  }
}

class SecondRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Kraken kraken = Kraken(
      viewportWidth: window.physicalSize.width / window.devicePixelRatio,
      viewportHeight: window.physicalSize.height / window.devicePixelRatio,
      gestureClient: NativeGestureClient(),
    );

    return kraken;
  }
}
