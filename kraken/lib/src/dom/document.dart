/*
 * Copyright (C) 2021-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'dart:ui' as ui;
import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:kraken/css.dart';
import 'package:kraken/dom.dart';
import 'package:kraken/gesture.dart';
import 'package:kraken/launcher.dart';
import 'package:kraken/rendering.dart';
import 'package:kraken/src/dom/element_registry.dart' as element_registry;
import 'package:kraken/src/scheduler/fps.dart';
import 'package:kraken/widget.dart';

class Document extends Node {

  RenderViewportBox viewport;
  KrakenController controller;
  GestureListener? gestureListener;
  WidgetDelegate? widgetDelegate;
  bool showPerformanceOverlay = false;

  Document(EventTargetContext context,
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

  double get viewportWidth => viewport.viewportSize.width;
  double get viewportHeight => viewport.viewportSize.height;

  Element? _documentElement;
  Element? get documentElement {
    return _documentElement;
  }
  set documentElement(Element? element) {
    _documentElement = element;
    viewport.child = element?.renderer;

    // Flush pending style immediately.
    element?.style.flushPendingProperties();

    // Must scrollable.
    element?.setRenderStyleProperty(OVERFLOW_X, CSSOverflowType.scroll);
    element?.setRenderStyleProperty(OVERFLOW_Y, CSSOverflowType.scroll);
    // Must init with viewport height.
    element?.renderStyle.height = CSSLengthValue(viewportHeight, CSSLengthType.PX);
  }

  double getRootFontSize() {
    RenderBoxModel rootBoxModel = documentElement!.renderBoxModel!;
    return rootBoxModel.renderStyle.fontSize.computedValue;
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

  Element createElement(EventTargetContext context, String type) {
    Element element = element_registry.createElement(context, type);
    element.ownerDocument = this;
    return element;
  }

  TextNode createTextNode(EventTargetContext context, String data) {
    TextNode textNode = TextNode(context, data);
    textNode.ownerDocument = this;
    return textNode;
  }

  DocumentFragment createDocumentFragment(EventTargetContext context) {
    DocumentFragment documentFragment = DocumentFragment(context);
    documentFragment.ownerDocument = this;
    return documentFragment;
  }

  Comment createComment(EventTargetContext context) {
    Comment comment = Comment(context);
    comment.ownerDocument = this;
    return comment;
  }

  // TODO: https://wicg.github.io/construct-stylesheets/#using-constructed-stylesheets
  List<CSSStyleSheet> adoptedStyleSheets = [];
  List<CSSStyleSheet> styleSheets = [];

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

  RenderBox buildRenderBox({bool showPerformanceOverlay = false}) {
    this.showPerformanceOverlay = showPerformanceOverlay;

    RenderBox renderBox = viewport;

    if (showPerformanceOverlay) {
      RenderPerformanceOverlay renderPerformanceOverlay =
          RenderPerformanceOverlay(optionsMask: 15, rasterizerThreshold: 0);
      RenderConstrainedBox renderConstrainedPerformanceOverlayBox = RenderConstrainedBox(
        child: renderPerformanceOverlay,
        additionalConstraints: BoxConstraints.tight(Size(
          math.min(350.0, ui.window.physicalSize.width),
          math.min(150.0, ui.window.physicalSize.height),
        )),
      );
      RenderFpsOverlay renderFpsOverlayBox = RenderFpsOverlay();

      renderBox = RenderStack(
        children: [
          renderBox,
          renderConstrainedPerformanceOverlayBox,
          renderFpsOverlayBox,
        ],
        textDirection: TextDirection.ltr,
      );
    }

    return renderBox;
  }

  void attach(RenderObject parent, RenderObject? previousSibling, {bool showPerformanceOverlay = false}) {
    RenderObject root = buildRenderBox(showPerformanceOverlay: showPerformanceOverlay);

    if (parent is ContainerRenderObjectMixin) {
      parent.insert(root, after: previousSibling);
    } else if (parent is RenderObjectWithChildMixin) {
      parent.child = root;
    }
  }

  void detach() {
    RenderObject? parent = viewport.parent as RenderObject?;
    if (parent == null) return;

    // Detach renderObject.
    documentElement?.disposeRenderObject();
  }

  @override
  void dispose() {
    documentElement?.dispose();
    debugDOMTreeChanged = null;
    super.dispose();
  }

  // Hooks for DevTools.
  VoidCallback? debugDOMTreeChanged;
  void _debugDOMTreeChanged() {
    VoidCallback? f = debugDOMTreeChanged;
    if (f != null) {
      f();
    }
  }
}
