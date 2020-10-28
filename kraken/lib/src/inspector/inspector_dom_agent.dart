/*
 * Copyright (C) 2020-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'package:kraken/element.dart';
import 'package:kraken/inspector.dart';

const String DOM_GET_DOCUMENT = 'DOM.getDocument';
const String DOM_REQUEST_CHILD_NODES = 'DOM.requestChildNodes';
const String DOM_SET_CHILD_NODES = 'DOM.setChildNodes';

/// Document default attributes
const int _documentId = -3;
const String _documentName = '#document';

// https://www.w3.org/TR/DOM-Level-3-Core/core.html#ID-1950641247
const int _elementType = 1;
const int _textType = 3;
const int _commentType = 8;
const int _documentType = 9;

class InspectorDomAgent {
  ElementManager _elementManager;
  Map<int, InspectorDomNode> idToDomNodeMap = {};
  int count = 0;

  InspectorDomAgent(this._elementManager);

  Node getElementById(int id) {
    return _elementManager.getEventTargetByTargetId<Element>(id);
  }

  InspectorDomNode getDomNode(int nodeId) {
    if (nodeId == null) return null;

    InspectorDomNode domNode = idToDomNodeMap[nodeId];

    if (domNode == null) return null;

    return domNode;
  }

  ResponseState onRequest(
      Map<String, dynamic> params, String method, InspectorData protocolData) {
    switch (method) {
      case DOM_GET_DOCUMENT:
        return getDocument(protocolData);
        break;
      case DOM_REQUEST_CHILD_NODES:
        int nodeId = params['nodeId'];
        return requestChildNodes(protocolData, nodeId);
        break;
      default:
        break;
    }
    return ResponseState.Success;
  }

  ResponseState requestChildNodes(InspectorData jsonData, int nodeId) {
    if (nodeId == null) return ResponseState.Error;

    InspectorDomNode domNode = idToDomNodeMap[nodeId];

    if (domNode == null) return ResponseState.Error;

    int targetId = domNode.getBackendNodeId();
    Node node = _elementManager.getEventTargetByTargetId<Node>(targetId);

    if (node == null) return ResponseState.Error;

    List<Map<String, dynamic>> nodes = [];
    node.childNodes.forEach((Node child) {
      InspectorDomNode domNode = buildDomNode(child);
      if (domNode != null) nodes.add(domNode.toJson());
    });

    if (nodes.isNotEmpty) {
      RequestData request = RequestData() // Extra JSON-RPC request object
        ..setMethod(DOM_SET_CHILD_NODES)
        ..setParams('parentId', nodeId)
        ..setParams('nodes', nodes);

      jsonData.addExtra(request);
    }

    return ResponseState.Success;
  }

  ResponseState getDocument(InspectorData jsonData) {
    Node root = _elementManager.getRootElement();
    if (root == null) return ResponseState.Error;

    InspectorDomNode body = buildDomNode(root, depth: 2);

    InspectorDomNode document = InspectorDomNode()
      ..setNodeId(++count)
      ..setNodeType(_documentType)
      ..setBackendNodeId(_documentId)
      ..setNodeName(_documentName)
      ..setChildNodeCount(1)
      ..setChildren([body]);

    jsonData.setResult('root', document.toJson());

    return ResponseState.Success;
  }

  InspectorDomNode buildDomNode(Node node, {int depth = 1}) {
    InspectorDomNode domNode;
    String nodeName = node.nodeName;
    int backendNodeId = node.targetId;

    domNode = InspectorDomNode()
      ..setNodeId(++count)
      ..setBackendNodeId(backendNodeId)
      ..setNodeName(nodeName);

    idToDomNodeMap[count] = domNode;

    if (node is TextNode) {
      String nodeValue = node.data;
      domNode
        ..setNodeValue(nodeValue)
        ..setNodeType(_textType);

      return domNode;
    }

    if (node is Element) {
      String tagName = node.tagName.toLowerCase();
      List<String> attributes;

      node.properties.forEach((k, v) {
        attributes.add(k);
        attributes.add(v);
      });

      domNode
        ..setLocalName(tagName)
        ..setAttributes(attributes)
        ..setNodeType(_elementType);

      int childCount = node.childNodes.length;

      if (childCount > 0) {
        domNode.setChildNodeCount(childCount);

        if (childCount == 1 && node.childNodes[0] is TextNode) {
          InspectorDomNode child = buildDomNode(node.childNodes[0]);

          if (child != null) {
            domNode.setChildren([child]);
          }
        }

        if (depth > 1) {
          List<InspectorDomNode> children = [];
          int parentId = count;

          node.childNodes.forEach((node) {
            InspectorDomNode child = buildDomNode(node);

            child.setParentId(parentId);
            if (child != null) children.add(child);
          });

          domNode.setChildren(children);
        }
      }

      return domNode;
    }

    if (node is Comment) {
      domNode.setNodeType(_commentType);
      return domNode;
    }

    return null;
  }
}

/// A base node mirror type.
///
/// Used by inspector DOM interaction to represent the actual DOM nodes.
class InspectorDomNode {
  /// Node identifier that is passed into the rest of the DOM messages as the [nodeId]
  int nodeId = 0;

  /// The BackendNodeId for this node.
  int backendNodeId = 0;

  /// [Node]'s nodeType
  int nodeType = 0;

  /// [Node]'s localName
  String localName = '';

  /// [Node]'s nodeName
  String nodeName = '';

  /// [Node]'s nodeValue
  String nodeValue = '';

  /// Attributes of the [Element] node in the form of flat array
  List<String> attributes;

  /// Optional: Child count forContainer nodes.
  int childNodeCount;

  /// Optional: The id of the parent node if any.
  int parentId;

  /// Optional: Child nodes of this node when requested with children.
  List<InspectorDomNode> children;

  /// Optional: Base URL that [Document] node uses for URL completion.
  String baseURL;

  // InspectorDomNode(this.nodeId, this.backendNodeId, this.nodeName);

  void setNodeId(int value) {
    nodeId = value;
  }

  void setNodeType(int value) {
    nodeType = value;
  }

  void setNodeName(String value) {
    nodeName = value;
  }

  void setLocalName(String value) {
    localName = value;
  }

  void setChildNodeCount(int value) {
    childNodeCount = value;
  }

  void setChildren(List<InspectorDomNode> value) {
    children = value;
  }

  void setBackendNodeId(int value) {
    backendNodeId = value;
  }

  int getBackendNodeId() {
    return backendNodeId;
  }

  void setParentId(int value) {
    parentId = value;
  }

  void setNodeValue(String value) {
    nodeValue = value;
  }

  void setBaseUrl(String value) {
    baseURL = value;
  }

  void setAttributes(List<String> value) {
    attributes = value;
  }

  Map<String, dynamic> toJson() {
    return {
      'nodeId': nodeId,
      'backendNodeId': backendNodeId,
      'nodeType': nodeType,
      'localName': localName,
      'nodeName': nodeName,
      'nodeValue': nodeValue,
      if (parentId != null) 'parentId': parentId,
      if (childNodeCount != null) 'childNodeCount': childNodeCount,
      if (children != null)
        'children': children.map((node) => node.toJson()).toList(),
      if (baseURL != null) 'baseURL': baseURL,
      if (attributes != null) 'attributes': attributes,
    };
  }
}
