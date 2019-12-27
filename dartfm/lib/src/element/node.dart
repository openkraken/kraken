/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'package:meta/meta.dart';
import 'package:kraken/element.dart';

const String DATA = 'data';
const String COMMENT = 'Comment';
enum NodeType {
  ELEMENT_NODE,
  TEXT_NODE,
  COMMENT_NODE,
  DOCUMENT_NODE,
  DOCUMENT_FRAGMENT_NODE,
}

class Comment extends Node {
  Comment(int nodeId) : super(NodeType.COMMENT_NODE, nodeId, '#comment');
}

class TextNode extends Node {
  String data;

  TextNode(int nodeId, this.data) : super(NodeType.TEXT_NODE, nodeId, '#text') {
    assert(data != null);
  }

  TextNode.create(int nodeId, this.data)
      : super(NodeType.TEXT_NODE, nodeId, '#text') {
    assert(data != null);
  }
}

abstract class Node extends EventTarget {
  int nodeId;
  List<Node> childNodes = [];
  Node parentNode;
  NodeType nodeType;
  String nodeName;

  Node(this.nodeType, this.nodeId, this.nodeName) {
    assert(nodeType != null);
    assert(nodeId != null);
    nodeName = nodeName ?? '';
  }

  Node get firstChild => childNodes?.first;
  Node get lastChild => childNodes?.last;
  Node get nextSibling {
    if (parentNode == null) return null;
    int index = parentNode.childNodes?.indexOf(this);
    if (index == null) return null;
    return parentNode.childNodes[index + 1];
  }

  void setProperty(String key, dynamic value) {}
  void removeProperty(String key) {}

  @mustCallSuper
  Node appendChild(Node child) {
    child.parentNode = this;
    this.childNodes.add(child);
    return child;
  }

  bool contains(Node child) {
    return childNodes.contains(child);
  }

  Node getRootNode() {
    Node root = this;
    while (root.parentNode != null) {
      root = root.parentNode;
    }
    return root;
  }

  @mustCallSuper
  Node insertBefore(Node newNode, Node referenceNode) {
    int referenceIndex = childNodes.indexOf(referenceNode);
    if (referenceIndex == -1) {
      return appendChild(newNode);
    } else {
      newNode.parentNode = this;
      childNodes.insert(referenceIndex, newNode);
      return newNode;
    }
  }

  @mustCallSuper
  Node removeChild(Node child) {
    if (childNodes.contains(child)) {
      childNodes.remove(child);
      child.parentNode = null;
    }
    return child;
  }

  @mustCallSuper
  Node replaceChild(Node newNode, Node oldNode) {
    Node replacedNode;
    if (childNodes.contains(oldNode)) {
      num referenceIndex = childNodes.indexOf(oldNode);
      oldNode.parentNode = null;
      replacedNode = oldNode;
      childNodes[referenceIndex] = newNode;
    } else {
      appendChild(newNode);
    }
    return replacedNode;
  }
}
