import 'dart:async';
import 'package:kraken/dom.dart' as dom;
import 'package:kraken/foundation.dart';
import 'package:kraken/widget.dart';
import 'package:waterfall_flow/waterfall_flow.dart';
import 'package:flutter/material.dart';

class WaterfallFlowWidgetElement extends WidgetElement {
  WaterfallFlowWidgetElement(BindingContext? context) :
        super(context);

  List<Widget> _children = [];

  Widget _func (BuildContext context, int index) {
    return _children[index];
  }

  @override
  Widget build(BuildContext context, Map<String, dynamic> properties, List<Widget> children) {
    _children = children;

    return WaterfallFlow.builder(
      itemBuilder: _func,
      padding: EdgeInsets.all(5.0),
      gridDelegate: SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 5.0,
        mainAxisSpacing: 5.0,
        lastChildLayoutTypeBuilder: (index) => index == children.length
            ? LastChildLayoutType.foot
            : LastChildLayoutType.none,
      ),
    );
  }
}

class TextWidgetElement extends WidgetElement {
  TextWidgetElement(BindingContext? context) :
        super(context);

  @override
  Widget build(BuildContext context, Map<String, dynamic> properties, List<Widget> children) {
    return Text(properties['value'] ?? '', textDirection: TextDirection.ltr, style: TextStyle(color: Color.fromARGB(255, 100, 100, 100)));
  }
}

class ImageWidgetElement extends WidgetElement {
  ImageWidgetElement(BindingContext? context) :
        super(context);

  @override
  Widget build(BuildContext context, Map<String, dynamic> properties, List<Widget> children) {
    return Image(image: AssetImage(properties['src']));
  }
}

class ContainerWidgetElement extends WidgetElement {
  ContainerWidgetElement(BindingContext? context) :
        super(context);

  @override
  Widget build(BuildContext context, Map<String, dynamic> properties, List<Widget> children) {
    return Container(
      width: 200,
      height: 200,
      decoration: const BoxDecoration(
        border: Border( top: BorderSide( width: 5, color: Colors.red ), bottom: BorderSide( width: 5, color: Colors.red ), left: BorderSide( width: 5, color: Colors.red ), right: BorderSide( width: 5, color: Colors.red )),
      ),
      child: Column(
        children: children,
      ),
    );
  }
}

class SampleElement extends dom.Element implements BindingObject {
  SampleElement(BindingContext? context)
      : super(context);

  getBindingProperty(String key) {
    switch (key) {
      case 'ping': return ping;
      case 'fake': return fake;
      case 'fn': return fn;
      case 'asyncFn': return asyncFn;
      case 'asyncFnFailed': return asyncFnFailed;
    }
  }

  String get ping => 'pong';

  int get fake => 1234;

  Function get fn => (List<dynamic> args) {
    return List.generate(args.length, (index) {
      return args[index] * 2;
    });
  };

  Function get asyncFn => (List<dynamic> argv) async {
    Completer<dynamic> completer = Completer();
    Timer(Duration(seconds: 1), () {
      completer.complete(argv[0]);
    });
    return completer.future;
  };

  Function get asyncFnFailed => (List<dynamic> args) async {
    Completer<String> completer = Completer();
    Timer(Duration(milliseconds: 100), () {
      completer.completeError(AssertionError('Asset error'));
    });
    return completer.future;
  };
}

void defineKrakenCustomElements() {
  Kraken.defineCustomElement('waterfall-flow', (BindingContext? context) {
    return WaterfallFlowWidgetElement(context);
  });
  Kraken.defineCustomElement('flutter-container', (BindingContext? context) {
    return ContainerWidgetElement(context);
  });
  Kraken.defineCustomElement('sample-element', (BindingContext? context) {
    return SampleElement(context);
  });
  Kraken.defineCustomElement('flutter-text', (BindingContext? context) {
    return TextWidgetElement(context);
  });
  Kraken.defineCustomElement('flutter-asset-image', (BindingContext? context) {
    return ImageWidgetElement(context);
  });
}
