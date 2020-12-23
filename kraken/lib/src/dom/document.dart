import 'package:kraken/dom.dart';
import 'dart:ffi';
import 'package:kraken/bridge.dart';

class Document extends Node {
  final Pointer<NativeDocument> nativeDocumentPtr;

  final BodyElement body;

  Document(int targetId, this.nativeDocumentPtr, ElementManager elementManager, this.body)
      : assert(targetId != null),
        super(NodeType.DOCUMENT_NODE, targetId, nativeDocumentPtr.ref.nativeNode, elementManager, '#document');
}
