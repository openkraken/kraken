import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:kraken/widget.dart';
import 'package:flutter_test/flutter_test.dart';
import 'dart:ui';

void main() {
  runApp(MaterialApp(
    title: 'Kraken App Demo',
    home: FirstRoute(),
  ));

  Timer(Duration(seconds: 1), () {
    _simulateKeyPress("hello");
  });
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
      bundleContent: '''
    const input1 = document.createElement('input');
    const input2 = document.createElement('input');
    input1.setAttribute('value', 'Input 1');
    input2.setAttribute('value', 'Input 2');
    document.body.appendChild(input1);
    document.body.appendChild(input2);

    input1.addEventListener('blur', function handler(event) {
      console.log(event);
    });

    input1.focus();

    input2.focus();
      ''',
    );

    return kraken;
  }
}

// Limit: only accept a-z0-9 chars.
// Enough for testing.
void _simulateKeyPress(String chars) async {
  if (chars == null) {
    print('Warning: simulateKeyPress chars is null.');
    return;
  }
  print('call _simulateKeyPress $chars');
  for (int i = 0; i < chars.length; i++) {
    String char = chars[i];
    LogicalKeyboardKey key = getLogicalKeyboardKey(char);
    if (key != null) {
      await KeyEventSimulator.simulateKeyDownEvent(key, physicalKey: phyKey);
      sleep(Duration(milliseconds: 200));
      await KeyEventSimulator.simulateKeyUpEvent(key);
    }
  }
}

LogicalKeyboardKey getLogicalKeyboardKey(String char) {
  char = char.toLowerCase();
  switch (char) {
    case 'a': return LogicalKeyboardKey.keyA;
    case 'b': return LogicalKeyboardKey.keyB;
    case 'c': return LogicalKeyboardKey.keyC;
    case 'd': return LogicalKeyboardKey.keyD;
    case 'e': return LogicalKeyboardKey.keyE;
    case 'f': return LogicalKeyboardKey.keyF;
    case 'g': return LogicalKeyboardKey.keyG;
    case 'h': return LogicalKeyboardKey.keyH;
    case 'i': return LogicalKeyboardKey.keyI;
    case 'j': return LogicalKeyboardKey.keyJ;
    case 'k': return LogicalKeyboardKey.keyK;
    case 'l': return LogicalKeyboardKey.keyL;
    case 'm': return LogicalKeyboardKey.keyM;
    case 'n': return LogicalKeyboardKey.keyN;
    case 'o': return LogicalKeyboardKey.keyO;
    case 'p': return LogicalKeyboardKey.keyP;
    case 'q': return LogicalKeyboardKey.keyQ;
    case 'r': return LogicalKeyboardKey.keyR;
    case 's': return LogicalKeyboardKey.keyS;
    case 't': return LogicalKeyboardKey.keyT;
    case 'u': return LogicalKeyboardKey.keyU;
    case 'v': return LogicalKeyboardKey.keyV;
    case 'w': return LogicalKeyboardKey.keyW;
    case 'x': return LogicalKeyboardKey.keyX;
    case 'y': return LogicalKeyboardKey.keyY;
    case 'z': return LogicalKeyboardKey.keyZ;
    case '0': return LogicalKeyboardKey.digit0;
    case '1': return LogicalKeyboardKey.digit1;
    case '2': return LogicalKeyboardKey.digit2;
    case '3': return LogicalKeyboardKey.digit3;
    case '4': return LogicalKeyboardKey.digit4;
    case '5': return LogicalKeyboardKey.digit5;
    case '6': return LogicalKeyboardKey.digit6;
    case '7': return LogicalKeyboardKey.digit7;
    case '8': return LogicalKeyboardKey.digit8;
    case '9': return LogicalKeyboardKey.digit9;
    case '0': return LogicalKeyboardKey.digit0;
  }
  return null;
}

