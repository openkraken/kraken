import 'package:kraken/dom.dart';
import 'dart:ffi';
import 'package:kraken/bridge.dart';

class Document extends Node {
  final Pointer<NativeDocument> nativeDocumentPtr;

  final BodyElement body;

  Document(int targetId, this.nativeDocumentPtr, ElementManager elementManager, this.body)
      : assert(targetId != null),
        super(NodeType.DOCUMENT_NODE, targetId, nativeDocumentPtr.ref.nativeNode, elementManager, '#document');

  @override
  void addEvent(String eventName) {
    super.addEvent(eventName);
    if (eventHandlers.containsKey(eventName)) return; // Only listen once.
    addEventListener(eventName, (Event event) {
      emitUIEvent(elementManager.controller.view.contextId, nativeDocumentPtr.ref.nativeNode.ref.nativeEventTarget, event);
    });
  }
}
