import 'package:flutter/rendering.dart';
import 'package:kraken/dom.dart';
import 'dart:ffi';
import 'package:kraken/bridge.dart';
import 'package:kraken/rendering.dart';

class Document extends Node {
  final Pointer<NativeDocument> nativeDocumentPtr;
  final HTMLElement documentElement;
  final RenderViewportBox renderView;

  Document(int targetId, this.nativeDocumentPtr, ElementManager elementManager, this.documentElement, this.renderView)
      : super(NodeType.DOCUMENT_NODE, targetId, nativeDocumentPtr.ref.nativeNode, elementManager, '#document') {
    appendChild(documentElement);
    renderView.getEventHandlers = getEventHandlers;
  }

  void _handleEvent(Event event) {
    emitUIEvent(elementManager.controller.view.contextId, nativeDocumentPtr.ref.nativeNode.ref.nativeEventTarget, event);
  }

  Map<String, List<EventHandler>> getEventHandlers() {
    return eventHandlers;
  }

  @override
  void addEvent(String eventName) {
    super.addEvent(eventName);
    if (eventHandlers.containsKey(eventName)) return; // Only listen once.
    addEventListener(eventName, _handleEvent);
  }

  @override
  RenderObject? get renderer => throw FlutterError('Document did\'t have renderObject.');

  double scrollX() {
    return documentElement.scrollLeft;
  }

  double scrollY() {
    return documentElement.scrollTop;
  }

  void scrollTo(num x, num y) {
    documentElement.scrollTo(x: x, y: y, withAnimation: false);
  }

  void scrollBy(num x, num y) {
    documentElement.scrollBy(dx: x, dy: y, withAnimation: false);
  }

}
