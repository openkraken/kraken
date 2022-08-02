/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
import 'package:flutter/rendering.dart';
import 'package:webf/css.dart';
import 'package:webf/dom.dart';
import 'package:webf/foundation.dart';
import 'package:webf/gesture.dart';
import 'package:webf/launcher.dart';
import 'package:webf/rendering.dart';
import 'package:webf/src/dom/element_registry.dart' as element_registry;
import 'package:webf/widget.dart';

class Document extends Node {
  final WebFController controller;
  final AnimationTimeline animationTimeline = AnimationTimeline();
  RenderViewportBox? _viewport;
  GestureListener? gestureListener;
  WidgetDelegate? widgetDelegate;

  Document(
    BindingContext context, {
    required this.controller,
    required RenderViewportBox viewport,
    this.gestureListener,
    this.widgetDelegate,
  })  : _viewport = viewport,
        super(NodeType.DOCUMENT_NODE, context) {
    _scriptRunner = ScriptRunner(this, context.contextId);
  }

  // https://github.com/WebKit/WebKit/blob/main/Source/WebCore/dom/Document.h#L1898
  late ScriptRunner _scriptRunner;
  ScriptRunner get scriptRunner => _scriptRunner;

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

  // https://github.com/WebKit/WebKit/blob/main/Source/WebCore/dom/Document.h#L770
  bool parsing = false;

  int _requestCount = 0;
  bool get hasPendingRequest => _requestCount > 0;
  void incrementRequestCount() {
    _requestCount++;
  }

  void decrementRequestCount() {
    assert(_requestCount > 0);
    _requestCount--;
  }

  // https://github.com/WebKit/WebKit/blob/main/Source/WebCore/dom/Document.h#L2091
  // Counters that currently need to delay load event, such as parsing a script.
  int _loadEventDelayCount = 0;
  bool get isDelayingLoadEvent => _loadEventDelayCount > 0;
  void incrementLoadEventDelayCount() {
    _loadEventDelayCount++;
  }

  void decrementLoadEventDelayCount() {
    _loadEventDelayCount--;

    // Try to check when the request is complete.
    if (_loadEventDelayCount == 0) {
      controller.checkCompleted();
    }
  }

  Element? _documentElement;
  Element? get documentElement => _documentElement;
  set documentElement(Element? element) {
    if (_documentElement == element) {
      return;
    }

    RenderViewportBox? viewport = _viewport;
    // When document is disposed, viewport is null.
    if (viewport != null) {
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
