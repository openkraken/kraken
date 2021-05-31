// @dart=2.9

import 'package:kraken/dom.dart';
import 'dart:ffi';
import 'package:kraken/bridge.dart';

class Document extends Node {
  final Pointer<NativeDocument> nativeDocumentPtr;
  final HTMLElement documentElement;

  Document(int targetId, this.nativeDocumentPtr, ElementManager elementManager, this.documentElement)
      : assert(targetId != null),
        super(NodeType.DOCUMENT_NODE, targetId, nativeDocumentPtr.ref.nativeNode, elementManager, '#document') {
    appendChild(documentElement);
  }

  void _handleEvent(Event event) {
    emitUIEvent(elementManager.controller.view.contextId, nativeDocumentPtr.ref.nativeNode.ref.nativeEventTarget, event);
  }

  @override
  void addEvent(String eventName) {
    super.addEvent(eventName);
    if (eventHandlers.containsKey(eventName)) return; // Only listen once.
    addEventListener(eventName, _handleEvent);
  }
}
