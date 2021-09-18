import 'dart:ffi';
import 'dart:async';
import 'package:kraken/bridge.dart';
import 'package:kraken/dom.dart';
import 'package:kraken/widget.dart';
import 'package:flutter/material.dart' show TextDirection, TextStyle, Color, Image, Text, AssetImage;

void defineKrakenCustomElements() {
  Kraken.defineCustomElement<WidgetCreator>('flutter-text', (Map<String, dynamic> properties) {
    return Text(properties['value'] ?? '', textDirection: TextDirection.ltr, style: TextStyle(color: Color.fromARGB(255, 100, 100, 100)));
  });

  Kraken.defineCustomElement<WidgetCreator>('flutter-asset-image', (Map<String, dynamic> properties) {
    return Image(image: AssetImage(properties['src']));
  });

  Kraken.defineCustomElement<ElementCreator>('sample-element', (int targetId, Pointer<NativeEventTarget> nativeEventTarget, ElementManager elementManager) {
    return SampleElement(targetId, nativeEventTarget, elementManager);
  });
}

class SampleElement extends Element {
  SampleElement(int targetId, Pointer<NativeEventTarget> nativeEventTarget, ElementManager elementManager)
      : super(targetId, nativeEventTarget, elementManager, tagName: 'sample-element');

  @override
  getProperty(String key) {
    switch(key) {
      case 'ping':
        return 'pong';
      case '_fake':
        return 1234;
      case 'fn':
        return (List<dynamic> args) {
          return List.generate(args.length, (index) {
            return args[index] * 2;
          });
        };
      case 'asyncFn':
        return (List<dynamic> args) async {
          Completer<String> completer = Completer();
          Timer(Duration(seconds: 1), () {
            completer.complete('helloworld');
          });
          return completer.future;
        };
      case 'asyncFnFailed':
        return (List<dynamic> args) async {
          Completer<String> completer = Completer();
          Timer(Duration(seconds: 1), () {
            completer.completeError(AssertionError('Asset error'));
          });
          return completer.future;
        };
      default:
        return super.getProperty(key);
    }
  }
}


