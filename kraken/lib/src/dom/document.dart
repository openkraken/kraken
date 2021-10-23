import 'package:flutter/rendering.dart';
import 'package:kraken/dom.dart';
import 'dart:ffi';
import 'package:kraken/bridge.dart';

class Document extends Node {
  final HTMLElement documentElement;

  Document(int targetId, Pointer<NativeEventTarget> nativeEventTarget, ElementManager elementManager, this.documentElement)
      : super(NodeType.DOCUMENT_NODE, targetId, nativeEventTarget, elementManager, '#document');

  void _handleEvent(Event event) {
    emitUIEvent(elementManager.controller.view.contextId, nativeEventTargetPtr, event);
  }

  void addEvent(String eventType) {
    documentElement.addEventListener(eventType, _handleEvent);
  }

  @override
  RenderObject? get renderer => throw FlutterError('Document did\'t have renderObject.');

  @override
  handleJSCall(String method, List argv) {
  }
}
