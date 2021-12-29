import 'dart:async';
import 'package:kraken/dom.dart' as dom;
import 'package:kraken/widget.dart';
import 'package:waterfall_flow/waterfall_flow.dart';
import 'package:flutter/material.dart';

class WaterfallFlowWidgetElement extends WidgetElement {
  WaterfallFlowWidgetElement(dom.EventTargetContext? context) :
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
  TextWidgetElement(dom.EventTargetContext? context) :
        super(context);

  @override
  Widget build(BuildContext context, Map<String, dynamic> properties, List<Widget> children) {
    return Text(properties['value'] ?? '', textDirection: TextDirection.ltr, style: TextStyle(color: Color.fromARGB(255, 100, 100, 100)));
  }
}

class ImageWidgetElement extends WidgetElement {
  ImageWidgetElement(dom.EventTargetContext? context) :
        super(context);

  @override
  Widget build(BuildContext context, Map<String, dynamic> properties, List<Widget> children) {
    return Image(image: AssetImage(properties['src']));
  }
}

class ContainerWidgetElement extends WidgetElement {
  ContainerWidgetElement(dom.EventTargetContext? context) :
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

class SampleElement extends dom.Element {
  SampleElement(dom.EventTargetContext? context)
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

void defineKrakenCustomElements() {
  Kraken.defineCustomElement('waterfall-flow', (dom.EventTargetContext? context) {
    return WaterfallFlowWidgetElement(context);
  });
  Kraken.defineCustomElement('flutter-container', (dom.EventTargetContext? context) {
    return ContainerWidgetElement(context);
  });
  Kraken.defineCustomElement('sample-element', (dom.EventTargetContext? context) {
    return SampleElement(context);
  });
  Kraken.defineCustomElement('flutter-text', (dom.EventTargetContext? context) {
    return TextWidgetElement(context);
  });
  Kraken.defineCustomElement('flutter-asset-image', (dom.EventTargetContext? context) {
    return ImageWidgetElement(context);
  });
}
