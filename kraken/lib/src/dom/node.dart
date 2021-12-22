/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:kraken/dom.dart';
import 'package:meta/meta.dart';
import 'package:kraken/widget.dart';

enum NodeType {
  ELEMENT_NODE,
  TEXT_NODE,
  COMMENT_NODE,
  DOCUMENT_NODE,
  DOCUMENT_FRAGMENT_NODE,
}

/// [RenderObjectNode] provide the renderObject related abstract life cycle for
/// [Node] or [Element]s, which wrap [RenderObject]s, which provide the actual
/// rendering of the application.
abstract class RenderObjectNode {
  RenderBox? get renderer => throw FlutterError('This node has no render object implemented.');

  /// Creates an instance of the [RenderObject] class that this
  /// [RenderObjectNode] represents, using the configuration described by this
  /// [RenderObjectNode].
  ///
  /// This method should not do anything with the children of the render object.
  /// That should instead be handled by the method that overrides
  /// [Node.attachTo] in the object rendered by this object.
  RenderBox createRenderer();

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

/// Lifecycles that triggered when NodeTree changes.
/// Ref: https://html.spec.whatwg.org/multipage/custom-elements.html#concept-custom-element-definition-lifecycle-callbacks
abstract class LifecycleCallbacks {
  // Invoked each time the custom element is appended into a document-connected element.
  // This will happen each time the node is moved, and may happen before the element's
  // contents have been fully parsed.
  void connectedCallback();

  // Invoked each time the custom element is disconnected from the document's DOM.
  void disconnectedCallback();

// Invoked each time the custom element is moved to a new document.
// @TODO: Currently only single document exists, this callback will never be triggered.
// void adoptedCallback();

// @TODO: [attributeChangedCallback] works with static getter [observedAttributes].
// void attributeChangedCallback();
}

abstract class Node extends EventTarget implements RenderObjectNode, LifecycleCallbacks {
  KrakenElementToFlutterElementAdaptor? flutterElement;
  KrakenElementToWidgetAdaptor? flutterWidget;
  List<Node> childNodes = [];
  /// The Node.parentNode read-only property returns the parent of the specified node in the DOM tree.
  Node? parentNode;
  NodeType nodeType;
  String get nodeName;

  // The read-only ownerDocument property of the Node interface returns the top-level document object of the node.
  late Document ownerDocument;

  /// The Node.parentElement read-only property returns the DOM node's parent Element,
  /// or null if the node either has no parent, or its parent isn't a DOM Element.
  Element? get parentElement {
    if (parentNode != null && parentNode!.nodeType == NodeType.ELEMENT_NODE) {
      return parentNode as Element;
    }
    return null;
  }

  List<Element> get children {
    List<Element> _children = [];
    for (var child in childNodes) {
      if (child is Element) _children.add(child);
    }
    return _children;
  }

  Node(this.nodeType, EventTargetContext? context)
      : super(context);

  // If node is on the tree, the root parent is body.
  bool get isConnected {
    Node parent = this;
    while (parent.parentNode != null) {
      parent = parent.parentNode!;
    }
    return parent == ownerDocument;
  }

  Node get firstChild => childNodes.first;

  Node get lastChild => childNodes.last;

  Node? get previousSibling {
    if (parentNode == null) return null;
    int index = parentNode!.childNodes.indexOf(this);
    if (index - 1 < 0) return null;
    return parentNode!.childNodes[index - 1];
  }

  Node? get nextSibling {
    if (parentNode == null) return null;
    int index = parentNode!.childNodes.indexOf(this);
    if (index + 1 > parentNode!.childNodes.length - 1) return null;
    return parentNode!.childNodes[index + 1];
  }
  // Is child renderObject attached.
  bool get isRendererAttached => renderer != null && renderer!.attached;

  bool contains(Node child) {
    return childNodes.contains(child);
  }

  /// Attach a renderObject to parent.
  void attachTo(Element parent, {RenderBox? after}) {}

  /// Release any resources held by referenced render object.
  void disposeRenderObject() {}

  /// Release any resources held by this node.
  @override
  void dispose() {
    super.dispose();

    parentNode = null;
    for (int i = 0; i < childNodes.length; i ++) {
      childNodes[i].parentNode = null;
    }
    childNodes.clear();
  }

  @override
  RenderBox createRenderer() => throw FlutterError('[createRenderer] is not implemented.');

  @override
  void willAttachRenderer() {}

  @override
  void didAttachRenderer() {}

  @override
  void willDetachRenderer() {}

  @override
  void didDetachRenderer() {}

  @mustCallSuper
  Node appendChild(Node child) {
    child._ensureOrphan();
    child.parentNode = this;
    childNodes.add(child);

    if (child.isConnected) {
      child.connectedCallback();
    }

    return child;
  }

  @mustCallSuper
  Node insertBefore(Node child, Node referenceNode) {
    child._ensureOrphan();
    int referenceIndex = childNodes.indexOf(referenceNode);
    if (referenceIndex == -1) {
      return appendChild(child);
    } else {
      child.parentNode = this;
      childNodes.insert(referenceIndex, child);
      if (child.isConnected) {
        child.connectedCallback();
      }
      return child;
    }
  }

  @mustCallSuper
  Node removeChild(Node child) {
    if (childNodes.contains(child)) {
      bool isConnected = child.isConnected;
      childNodes.remove(child);
      child.parentNode = null;
      if (isConnected) {
        child.disconnectedCallback();
      }
    }
    return child;
  }

  @mustCallSuper
  Node? replaceChild(Node newNode, Node oldNode) {
    Node? replacedNode;
    if (childNodes.contains(oldNode)) {
      newNode._ensureOrphan();
      bool isOldNodeConnected = oldNode.isConnected;
      int referenceIndex = childNodes.indexOf(oldNode);
      oldNode.parentNode = null;
      replacedNode = oldNode;
      childNodes[referenceIndex] = newNode;

      if (isOldNodeConnected) {
        oldNode.disconnectedCallback();
        newNode.connectedCallback();
      }
    }
    return replacedNode;
  }

  /// Ensure node is not connected to a parent element.
  void _ensureOrphan() {
    Node? _parent = parentNode;
    if (_parent != null) {
      _parent.removeChild(this);
    }
  }

  /// Ensure child and child's child render object is attached.
  void ensureChildAttached() { }

  @override
  void connectedCallback() {
    for (var child in childNodes) {
      child.connectedCallback();
    }
  }

  @override
  void disconnectedCallback() {
    for (var child in childNodes) {
      child.disconnectedCallback();
    }
  }

  @override
  void dispatchEvent(Event event) {
    if (disposed) return;
    super.dispatchEvent(event);

    // Dispatch listener for widget.
    if (ownerDocument.gestureListener != null) {
      if (ownerDocument.gestureListener?.onTouchStart != null && event.type == EVENT_TOUCH_START) {
        ownerDocument.gestureListener?.onTouchStart!(event as TouchEvent);
      }

      if (ownerDocument.gestureListener?.onTouchMove != null && event.type == EVENT_TOUCH_MOVE) {
        ownerDocument.gestureListener?.onTouchMove!(event as TouchEvent);
      }

      if (ownerDocument.gestureListener?.onTouchEnd != null && event.type == EVENT_TOUCH_END) {
        ownerDocument.gestureListener?.onTouchEnd!(event as TouchEvent);
      }
    }
  }
}

/// https://dom.spec.whatwg.org/#dom-node-nodetype
int getNodeTypeValue(NodeType nodeType) {
  switch (nodeType) {
    case NodeType.ELEMENT_NODE:
      return 1;
    case NodeType.TEXT_NODE:
      return 3;
    case NodeType.COMMENT_NODE:
      return 8;
    case NodeType.DOCUMENT_NODE:
      return 9;
    case NodeType.DOCUMENT_FRAGMENT_NODE:
      return 11;
  }
}
