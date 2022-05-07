/*
 * Copyright (C) 2022-present The Kraken authors. All rights reserved.
 */
import 'package:flutter/widgets.dart';
import 'package:kraken/dom.dart' as dom;

class KrakenElementToWidgetAdaptor extends RenderObjectWidget {
  final dom.Node _krakenNode;

  KrakenElementToWidgetAdaptor(this._krakenNode, { Key? key }): super(key: key) {
    _krakenNode.flutterWidget = this;
  }

  @override
  RenderObjectElement createElement() {
    _krakenNode.flutterElement = KrakenElementToFlutterElementAdaptor(this);
    return _krakenNode.flutterElement as RenderObjectElement;
  }

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _krakenNode.renderer!;
  }
}

class KrakenElementToFlutterElementAdaptor extends RenderObjectElement {
  KrakenElementToFlutterElementAdaptor(RenderObjectWidget widget) : super(widget);

  @override
  KrakenElementToWidgetAdaptor get widget => super.widget as KrakenElementToWidgetAdaptor;

  @override
  void mount(Element? parent, Object? newSlot) {
    widget._krakenNode.createRenderer();
    super.mount(parent, newSlot);

    widget._krakenNode.ensureChildAttached();

    if (widget._krakenNode is dom.Element) {
      dom.Element element = (widget._krakenNode as dom.Element);
      element.applyStyle(element.style);

      if (element.renderer != null) {
        // Flush pending style before child attached.
        element.style.flushPendingProperties();
      }
    }
  }

  @override
  void unmount() {
    // Flutter element unmount call dispose of _renderObject, so we should not call dispose in unmountRenderObject.
    dom.Element element = (widget._krakenNode as dom.Element);
    element.unmountRenderObject(dispose: false);

    super.unmount();
  }

  @override
  void insertRenderObjectChild(RenderObject child, Object? slot) {}

  @override
  void moveRenderObjectChild(covariant RenderObject child, covariant Object? oldSlot, covariant Object? newSlot) {}
}
