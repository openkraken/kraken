/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'package:flutter/rendering.dart';
import 'package:kraken/element.dart';
import 'package:meta/meta.dart';

const String DATA = 'data';

enum NodeType {
  ELEMENT_NODE,
  TEXT_NODE,
  COMMENT_NODE,
  DOCUMENT_NODE,
  DOCUMENT_FRAGMENT_NODE,
}

class Comment extends Node {
  Comment({int targetId, int nativePtr, ElementManager elementManager, this.data})
      : super(NodeType.COMMENT_NODE, targetId, nativePtr, elementManager, '#comment');

  // The comment information.
  String data;
}

mixin NodeLifeCycle on Node {
  List<VoidCallback> _afterConnected = [];
  List<VoidCallback> _beforeDisconnected = [];

  void fireAfterConnected() {
    for (VoidCallback callback in _afterConnected) {
      callback();
    }
    _afterConnected = [];
  }

  void queueAfterConnected(VoidCallback callback) {
    _afterConnected.add(callback);
  }

  void fireBeforeDisconnected() {
    for (VoidCallback callback in _beforeDisconnected) {
      callback();
    }
    _beforeDisconnected = [];
  }

  void queueBeforeDisconnected(VoidCallback callback) {
    _beforeDisconnected.add(callback);
  }
}

abstract class Node extends EventTarget {
  List<Node> childNodes = [];
  Node parentNode;
  NodeType nodeType;
  String nodeName;

  Element get parent => parentNode;
  Element get parentElement => parent;

  List<Element> get children {
    List<Element> _children = [];
    for (var child in childNodes) {
      if (child is Element) _children.add(child);
    }
    return _children;
  }

  Node(this.nodeType, int targetId, int nativePtr, ElementManager elementManager, this.nodeName) : super(targetId, nativePtr, elementManager) {
    assert(nodeType != null);
    assert(targetId != null);
    nodeName = nodeName ?? '';
  }

  // If node is on the tree, the root parent is body.
  bool get isConnected {
    Node parent = this;
    while (parent.parentNode != null) {
      parent = parent.parentNode;
    }
    return parent == elementManager.getRootElement();
  }

  Node get firstChild => childNodes?.first;
  Node get lastChild => childNodes?.last;
  Node get previousSibling {
    if (parentNode == null) return null;
    int index = parentNode.childNodes?.indexOf(this);
    if (index == null) return null;
    if (index - 1 < 0) return null;
    return parentNode.childNodes[index - 1];
  }

  Node get nextSibling {
    if (parentNode == null) return null;
    int index = parentNode.childNodes?.indexOf(this);
    if (index == null) return null;
    if (index + 1 > parentNode.childNodes.length - 1) return null;
    return parentNode.childNodes[index + 1];
  }

  // Is child renderObject attached.
  bool get attached => false;

  /// Attach a renderObject to parent.
  void attachTo(Element parent, {RenderObject after}) {}

  /// Detach renderObject from parent.
  void detach() {}

  void _ensureDetached() {
    if (parent != null) {
      parent.removeChild(this);
    }
  }

  @mustCallSuper
  Node appendChild(Node child) {
    child._ensureDetached();
    child.parentNode = this;
    childNodes.add(child);

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
    newNode._ensureDetached();
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
