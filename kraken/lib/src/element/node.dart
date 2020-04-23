/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'package:flutter/rendering.dart';
import 'package:kraken/element.dart';
import 'package:kraken/rendering.dart';
import 'package:kraken/style.dart';
import 'package:meta/meta.dart';
import 'package:matcher/matcher.dart';

const String DATA = 'data';

enum NodeType {
  ELEMENT_NODE,
  TEXT_NODE,
  COMMENT_NODE,
  DOCUMENT_NODE,
  DOCUMENT_FRAGMENT_NODE,
}

class Comment extends Node {
  Comment(int targetId, this.data) : super(NodeType.COMMENT_NODE, targetId, '#comment');

  // The comment information.
  String data;
}

class TextNode extends Node with NodeLifeCycle, TextStyleMixin {
  static bool _isWhitespace(String ch) =>
      ch == ' ' || ch == '\n' || ch == '\r' || ch == '\t';

  TextNode(int targetId, this._data)
      : super(NodeType.TEXT_NODE, targetId, '#text') {
    // Update text after connected.
    queueAfterConnected(_onTextNodeConnected);
  }

  RenderTextBox renderTextBox;

  void _onTextNodeConnected() {
    Element parentElement = parentNode;
    renderTextBox = RenderTextBox(
      targetId: targetId,
      text: data,
      // inherit parent style
      style: parentElement.style,
    );
    parentElement.renderLayoutBox.add(renderTextBox);
  }

  static const String NORMAL_SPACE = '\u0020';
  // The text string.
  String _data;
  String get data {
    // @TODO(zl): Need to judge style white-spacing.
    String collapsedData = collapseWhitespace(_data);
    // Append space while prev is element.
    //   Consider:
    //        <ltr><span>foo</span>bar</ltr>
    // Append space while next is node(including textNode).
    //   Consider: (PS: ` is text node seperater.)
    //        <ltr><span>foo</span>`bar``hello`</ltr>
    if (previousSibling is Element && _isWhitespace(_data[0])) {
      collapsedData = NORMAL_SPACE + collapsedData;
    }

    if (nextSibling is Node && _isWhitespace(_data[_data.length - 1])) {
      collapsedData = collapsedData + NORMAL_SPACE;
    }
    return collapsedData;
  }
  set data(String newData) {
    assert(newData != null);
    _data = newData;
    updateTextStyle();
  }

  void updateTextStyle() {
    if (isConnected) {
      _doUpdateTextStyle();
    } else {
      queueAfterConnected(_doUpdateTextStyle);
    }
  }

  void _doUpdateTextStyle() {
    // parentNode must be an element.
    Element parentElement = parentNode;
    renderTextBox.text = data;
    renderTextBox.style = parentElement.style;
  }
}

mixin NodeLifeCycle on Node {
  List<VoidCallback> _afterConnected = [];
  List<VoidCallback> _beforeDisconnected = [];

  void fireAfterConnected() {
    _afterConnected.forEach((VoidCallback fn) {
      fn();
    });
    _afterConnected = [];
  }

  void queueAfterConnected(VoidCallback callback) {
    _afterConnected.add(callback);
  }

  void fireBeforeDisconnected() {
    _beforeDisconnected.forEach((VoidCallback fn) {
      fn();
    });
    _beforeDisconnected = [];
  }

  void queueBeforeDisconnected(VoidCallback callback) {
    _beforeDisconnected.add(callback);
  }
}

class Node extends EventTarget {
  List<Node> childNodes = [];
  Node parentNode;
  NodeType nodeType;
  String nodeName;

  Element get parent => this.parentNode;
  Element get parentElement => parent;

  List<Element> get children {
    List<Element> _children = [];
    for (var child in this.childNodes) {
      if (child is Element) _children.add(child);
    }
    return _children;
  }

  Node(this.nodeType, int targetId, this.nodeName) : super(targetId) {
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
    return parent == ElementManager().getRootElement();
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
