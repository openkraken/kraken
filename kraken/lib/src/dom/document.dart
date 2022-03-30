/*
 * Copyright (C) 2021-present The Kraken authors. All rights reserved.
 */
import 'package:flutter/rendering.dart';
import 'package:kraken/css.dart';
import 'package:kraken/dom.dart';
import 'package:kraken/foundation.dart';
import 'package:kraken/gesture.dart';
import 'package:kraken/launcher.dart';
import 'package:kraken/rendering.dart';
import 'package:kraken/src/dom/element_registry.dart' as element_registry;
import 'package:kraken/widget.dart';


class Document extends Node {
  final KrakenController controller;
  RenderViewportBox? _viewport;
  GestureListener? gestureListener;
  WidgetDelegate? widgetDelegate;

  Document(context, {
    required this.controller,
    required RenderViewportBox viewport,
    this.gestureListener,
    this.widgetDelegate,
  }) : _viewport = viewport,
        super(NodeType.DOCUMENT_NODE, context);

  @override
  EventTarget? get parentEventTarget => defaultView;

  RenderViewportBox? get viewport => _viewport;

  @override
  Document get ownerDocument => this;

  Element? focusedElement;

  // Returns the Window object of the active document.
  // https://html.spec.whatwg.org/multipage/window-object.html#dom-document-defaultview-dev
  Window get defaultView => controller.view.window;

  @override
  String get nodeName => '#document';

  @override
  RenderBox? get renderer => _viewport;

  Element? _documentElement;
  Element? get documentElement => _documentElement;
  set documentElement(Element? element) {
    if (_documentElement == element) {
      return;
    }

    RenderViewportBox? viewport = _viewport;
    // When document is disposed, viewport is null.
    if (viewport == null) return;

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

  Element createElement(String type, [BindingContext? context]) {
    Element element = element_registry.createElement(type, context);
    element.ownerDocument = this;
    return element;
  }

  TextNode createTextNode(String data, [BindingContext? context]) {
    TextNode textNode = TextNode(data, context);
    textNode.ownerDocument = this;
    return textNode;
  }

  DocumentFragment createDocumentFragment([BindingContext? context]) {
    DocumentFragment documentFragment = DocumentFragment(context);
    documentFragment.ownerDocument = this;
    return documentFragment;
  }

  Comment createComment([BindingContext? context]) {
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
    _viewport = null;
    gestureListener = null;
    widgetDelegate = null;
    styleSheets.clear();
    adoptedStyleSheets.clear();
    super.dispose();
  }
}
