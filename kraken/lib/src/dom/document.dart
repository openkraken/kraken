/*
 * Copyright (C) 2021-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'package:flutter/rendering.dart';
import 'package:kraken/css.dart';
import 'package:kraken/dom.dart';
import 'package:kraken/gesture.dart';
import 'package:kraken/launcher.dart';
import 'package:kraken/rendering.dart';
import 'package:kraken/src/dom/element_registry.dart' as element_registry;
import 'package:kraken/widget.dart';

class Document extends Node {

  final RenderViewportBox viewport;
  KrakenController controller;
  GestureListener? gestureListener;
  WidgetDelegate? widgetDelegate;

  Document(EventTargetContext? context,
  {
    required this.viewport,
    required this.controller,
    this.gestureListener,
    this.widgetDelegate,
  })
  : super(NodeType.DOCUMENT_NODE, context);

  @override
  String get nodeName => '#document';

  @override
  RenderBox? get renderer => viewport;

  Element? _documentElement;
  Element? get documentElement {
    return _documentElement;
  }
  set documentElement(Element? element) {
    if (_documentElement == element) {
      return;
    }

    if (element != null) {
      element.attachTo(this);
      // Should scrollable.
      element.setRenderStyleProperty(OVERFLOW_X, CSSOverflowType.scroll);
      element.setRenderStyleProperty(OVERFLOW_Y, CSSOverflowType.scroll);
      // Init with viewport size.
      element.renderStyle.width = CSSLengthValue(viewport.viewportSize.width, CSSLengthType.PX);
      element.renderStyle.height = CSSLengthValue(viewport.viewportSize.height, CSSLengthType.PX);
    } else {
      // Detach document element.
      viewport.child = null;
    }

    _documentElement = element;
  }

  @override
  Node appendChild(Node child) {
    if (child is Element) {
      documentElement ??= child;
    } else {
      throw UnsupportedError('Only Element can be appended to Document');
    }
    return super.appendChild(child);
  }

  @override
  Node insertBefore(Node child, Node referenceNode) {
    if (child is Element) {
      documentElement ??= child;
    } else {
      throw UnsupportedError('Only Element can be inserted to Document');
    }
    return super.insertBefore(child, referenceNode);
  }

  @override
  Node removeChild(Node child) {
    if (documentElement == child) {
      documentElement = null;
    }
    return super.removeChild(child);
  }

  @override
  Node? replaceChild(Node newNode, Node oldNode) {
    if (documentElement == oldNode) {
      documentElement = newNode is Element ? newNode : null;
    }
    return super.replaceChild(newNode, oldNode);
  }

  addEvent(String eventType) {
    if (eventHandlers.containsKey(eventType)) return; // Only listen once.

    switch (eventType) {
      case EVENT_SCROLL:
        // Fired at the Document or element when the viewport or element is scrolled, respectively.
        return documentElement?.addEventListener(eventType, dispatchEvent);
      default:
        // Events listened on the Window need to be proxied to the Document, because there is a RenderView on the Document, which can handle hitTest.
        // https://github.com/WebKit/WebKit/blob/main/Source/WebCore/page/VisualViewport.cpp#L61
        documentElement?.addEvent(eventType);
        break;
    }
  }

  Element createElement(String type, EventTargetContext? context) {
    Element element = element_registry.createElement(type, context);
    element.ownerDocument = this;
    return element;
  }

  TextNode createTextNode(String data, EventTargetContext? context) {
    TextNode textNode = TextNode(data, context);
    textNode.ownerDocument = this;
    return textNode;
  }

  DocumentFragment createDocumentFragment(EventTargetContext? context) {
    DocumentFragment documentFragment = DocumentFragment(context);
    documentFragment.ownerDocument = this;
    return documentFragment;
  }

  Comment createComment(EventTargetContext? context) {
    Comment comment = Comment(context);
    comment.ownerDocument = this;
    return comment;
  }

  // TODO: https://wicg.github.io/construct-stylesheets/#using-constructed-stylesheets
  List<CSSStyleSheet> adoptedStyleSheets = [];
  // The styleSheets attribute is readonly attribute.
  final List<CSSStyleSheet> styleSheets = [];

  void addStyleSheet(CSSStyleSheet sheet) {
    styleSheets.add(sheet);
    recalculateDocumentStyle();
  }

  void removeStyleSheet(CSSStyleSheet sheet) {
    styleSheets.remove(sheet);
    recalculateDocumentStyle();
  }

  void recalculateDocumentStyle() {
    // Recalculate style for all nodes sync.
    documentElement?.recalculateNestedStyle();
  }

  @override
  void dispose() {
    gestureListener = null;
    widgetDelegate = null;
    styleSheets.clear();
    adoptedStyleSheets.clear();
    super.dispose();
  }
}
