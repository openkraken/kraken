/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'package:flutter/rendering.dart';
import 'package:kraken/dom.dart';
import 'dart:ffi';
import 'package:kraken/bridge.dart';
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
  final Pointer<NativeCommentNode> nativeCommentNodePtr;

  Comment({int targetId, this.nativeCommentNodePtr, ElementManager elementManager, this.data})
      : super(NodeType.COMMENT_NODE, targetId, nativeCommentNodePtr.ref.nativeNode, elementManager, '#comment');

  // The comment information.
  String data;
}

// TODO: remove it.
mixin NodeLifeCycle on Node {}

/// [RenderObjectNode] provide the renderObject related abstract life cycle for
/// [Node] or [Element]s, which wrap [RenderObject]s, which provide the actual
/// rendering of the application.
abstract class RenderObjectNode {
  RenderObject get renderer => throw FlutterError('This node has no render object implemented.');

  /// Creates an instance of the [RenderObject] class that this
  /// [RenderObjectNode] represents, using the configuration described by this
  /// [RenderObjectNode].
  ///
  /// This method should not do anything with the children of the render object.
  /// That should instead be handled by the method that overrides
  /// [Node.attachTo] in the object rendered by this object.
  RenderObject createRenderer();

  /// The renderObject will be / has been insert into parent. You can apply properties
  /// to renderObject.
  ///
  /// This method should not do anything to update the children of the render
  /// object.
  @protected
  void willAttachRenderer();

  @protected
  void didAttachRenderer();

  /// A render object previously associated with this Node will be / has been removed
  /// from the tree. The given [RenderObject] will be of the same type as
  /// returned by this object's [createRenderer].
  @protected
  void willDetachRenderer();

  @protected
  void didDetachRenderer();
}

abstract class Node extends EventTarget implements RenderObjectNode {
  List<VoidCallback> _afterConnected = [];
  List<VoidCallback> _beforeDisconnected = [];

  RenderObject _renderer;

  final Pointer<NativeNode> nativeNodePtr;

  @override
  RenderObject get renderer => _renderer;

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

  Node(this.nodeType, int targetId, this.nativeNodePtr, ElementManager elementManager, this.nodeName)
      : super(targetId, nativeNodePtr.ref.nativeEventTarget, elementManager) {
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
  bool get isRendererAttached => renderer != null && renderer.attached;

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

  /// Attach a renderObject to parent.
  void attachTo(Element parent, {RenderObject after}) {}

  /// Detach renderObject from parent.
  void detach() {}

  /// Dispose renderObject, but not do anything.
  void dispose() {}

  @override
  RenderObject createRenderer() => null;

  @override
  void didAttachRenderer() {}

  @override
  void didDetachRenderer() {}

  @override
  void willAttachRenderer() {}

  @override
  void willDetachRenderer() {}

  @mustCallSuper
  Node appendChild(Node child) {
    child._ensureOrphan();
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
    newNode._ensureOrphan();
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

  /// Ensure node is not connected to a parent element.
  void _ensureOrphan() {
    if (parent != null) {
      parent.removeChild(this);
    }
  }

  /// Ensure child and child's child render object is attached.
  void ensureChildAttached() {}
}
