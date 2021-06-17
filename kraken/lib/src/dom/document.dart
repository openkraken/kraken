import 'package:flutter/rendering.dart';
import 'package:kraken/dom.dart';
import 'dart:ffi';
import 'package:kraken/bridge.dart';

class Document extends Node {
  final Pointer<NativeDocument> nativeDocumentPtr;
  final HTMLElement documentElement;

  Document(int targetId, this.nativeDocumentPtr, ElementManager elementManager, this.documentElement)
      : super(NodeType.DOCUMENT_NODE, targetId, nativeDocumentPtr.ref.nativeNode, elementManager, '#document');

  void _handleEvent(Event event) {
    emitUIEvent(elementManager.controller.view.contextId, nativeDocumentPtr.ref.nativeNode.ref.nativeEventTarget, event);
  }

  @override
  void addEvent(String eventName) {
    super.addEvent(eventName);
    documentElement.addEventListener(eventName, _handleEvent);
  }

  @override
  RenderObject? get renderer => throw FlutterError('Document did\'t have renderObject.');
}
