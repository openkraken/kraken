import 'dart:async';
import 'package:kraken/dom.dart';
import 'package:kraken/widget.dart';
import 'package:flutter/material.dart' show TextDirection, TextStyle, Color, Image, Text, AssetImage, Widget, BuildContext hide Element;

class TextWidgetElement extends WidgetElement {
  TextWidgetElement(EventTargetContext? context) :
        super(context);

  @override
  Widget build(BuildContext context, Map<String, dynamic> properties) {
    return Text(properties['value'] ?? '', textDirection: TextDirection.ltr, style: TextStyle(color: Color.fromARGB(255, 100, 100, 100)));
  }
}

class ImageWidgetElement extends WidgetElement {
  ImageWidgetElement(EventTargetContext? context) :
        super(context);

  @override
  Widget build(BuildContext context, Map<String, dynamic> properties) {
    return Image(image: AssetImage(properties['src']));
  }
}

void defineKrakenCustomElements() {
  Kraken.defineCustomElement('sample-element', (EventTargetContext? context) {
    return SampleElement(context);
  });
  Kraken.defineCustomElement('flutter-text', (EventTargetContext? context) {
    return TextWidgetElement(context);
  });
  Kraken.defineCustomElement('flutter-asset-image', (EventTargetContext? context) {
    return ImageWidgetElement(context);
  });
}

class SampleElement extends Element {
  SampleElement(EventTargetContext? context)
      : super(context);

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
        return (List<dynamic> argv) async {
          Completer<dynamic> completer = Completer();
          Timer(Duration(seconds: 1), () {
            completer.complete(argv[0]);
          });
          return completer.future;
        };
      case 'asyncFnFailed':
        return (List<dynamic> args) async {
          Completer<String> completer = Completer();
          Timer(Duration(milliseconds: 100), () {
            completer.completeError(AssertionError('Asset error'));
          });
          return completer.future;
        };
      default:
        return super.getProperty(key);
    }
  }
}


