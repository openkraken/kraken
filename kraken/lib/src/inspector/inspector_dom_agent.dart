/*
 * Copyright (C) 2020-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'package:kraken/element.dart';
import 'package:kraken/inspector.dart';

const String DOM_GET_DOCUMENT = 'DOM.getDocument';
const String DOM_REQUEST_CHILD_NODES = 'DOM.requestChildNodes';
const String DOM_SET_CHILD_NODES = 'DOM.setChildNodes';

class InspectorDomAgent {
  Node _root;
  Map<Node, int> idToNodeMap = {};
  int count = 0;

  InspectorDomAgent(this._root) {
    idToNodeMap[_root] = 0;
  }

  ResponseState onRequest(
      Map<String, Object> params, String method, ResponseData responseData) {
    switch (method) {
      case DOM_GET_DOCUMENT:
        getDocument(responseData);
        break;
      case DOM_REQUEST_CHILD_NODES:
        break;
      case DOM_SET_CHILD_NODES:
        break;
    }
    return ResponseState.Success;
  }

  ResponseState getDocument(ResponseData responseData) {
    if (_root == null) return ResponseState.Error;
  }

}

class ProtocolNode {
  int nodeId;
  int backendNodeId;
  List<ProtocolNode> children;
  int childNodeCount;
  String localName;
  String nodeName;
  int nodeType;

  void setNodeType(int value) {
    nodeType = value;
  }

  void setNodeName(String value) {
    nodeName = value;
  }

  void setNodeId(int value) {
    nodeId = value;
  }

}
