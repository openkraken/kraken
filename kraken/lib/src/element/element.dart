/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:kraken/bridge.dart';
import 'package:kraken/element.dart';
import 'package:kraken/module.dart';
import 'package:kraken/rendering.dart';
import 'package:kraken/style.dart';
import 'package:meta/meta.dart';

import 'event_handler.dart';
import 'bounding_client_rect.dart';

typedef TestElement = bool Function(Element element);

abstract class Element extends Node
    with
        NodeLifeCycle,
        EventHandlerMixin,
        TextStyleMixin,
        BackgroundImageMixin,
        RenderDecoratedBoxMixin,
        DimensionMixin,
        FlexMixin,
        FlowMixin,
        StyleOverflowMixin,
        ColorMixin,
        TransformStyleMixin,
        TransitionStyleMixin {
  Element({
    @required int nodeId,
    @required this.tagName,
    @required this.defaultDisplay,
    this.properties = const {},
    this.needsReposition = false,
    this.allowChildren = true,
    this.events,
  })  : assert(nodeId != null),
        assert(tagName != null),
        assert(defaultDisplay != null),
        super(NodeType.ELEMENT_NODE, nodeId, tagName) {
    setDefaultProps(properties);
    /// Element style render
    _style = Style(properties[STYLE]);
    _style.set('display', style.get('display') ?? defaultDisplay);

    // Mark element needs to reposition according to position CSS.
    if (_isPositioned(_style)) needsReposition = true;

    if (allowChildren) {
      renderObject =
          renderLayoutElement = createRenderLayoutBox(_style, null);
    }

    // padding
    renderObject = renderPadding = initRenderPadding(renderObject, _style);

    // overflow
    if (allowChildren) {
      renderObject = initOverflowBox(renderObject, _style, _scrollListener);
    }

    // background image
    if (_style.backgroundAttachment == 'local' &&
        _style.backgroundImage != null) {
      renderObject = initBackgroundImage(renderObject, _style, nodeId);
    }

    // position
    if (_style.position != 'static') {
      renderObject = renderStack = RenderPosition(
        textDirection: TextDirection.ltr,
        fit: StackFit.passthrough,
        overflow: Overflow.visible,
        children: [renderObject],
      );
    }
    // border
    renderObject = initRenderDecoratedBox(renderObject, _style, this);

    // constrained box
    renderObject =
        renderConstrainedBox = initRenderConstrainedBox(renderObject, _style);

    // Pointer event listener
    renderObject = RenderPointerListener(
      child: renderObject,
      onPointerDown: this.handlePointDown,
      onPointerMove: this.handlePointMove,
      onPointerUp: this.handlePointUp,
      onPointerCancel: this.handlePointCancel,
      behavior: HitTestBehavior.translucent,
    );

    // Intersection observer
    renderObject = renderIntersectionObserver =
        RenderIntersectionObserver(child: renderObject);
    // opacity
    renderObject = initRenderOpacity(renderObject, _style);

    // transition
    initTransition(style);

    // RenderRepaintBoundary to support toBlob.
    renderObject =
        renderRepaintBoundary = RenderRepaintBoundary(child: renderObject);

    // Margin
    renderObject = initRenderMargin(renderObject, _style, this);

    // The layout boundary of element.
    renderObject = renderElementBoundary = initTransform(renderObject, style, nodeId);

    // Add element event listener
    events?.forEach((String eventName) {
      addEvent(eventName);
    });
  }

  Map<String, dynamic> properties;
  List<String> events;

  // A point reference to treed renderObject.
  RenderObject renderObject;
  RenderConstrainedBox renderConstrainedBox;
  RenderObject stickyPlaceholder;
  RenderRepaintBoundary renderRepaintBoundary;
  RenderStack renderStack;
  ContainerRenderObjectMixin renderLayoutElement;
  RenderPadding renderPadding;
  RenderIntersectionObserver renderIntersectionObserver;
  RenderElementBoundary renderElementBoundary;

  bool allowChildren = true; // Whether element allows children
  bool needsReposition =
  false; // whether element needs reposition when append to tree or changing position property
  bool shouldBlockStretch = true;
  double cropWidth = 0;
  double cropHeight = 0;
  double cropBorderWidth = 0;
  double cropBorderHeight = 0;
  double offsetTop = null; // offset to the top of viewport
  bool stickyFixed = false;

  final String tagName;

  /// The default display type of
  final String defaultDisplay;

  // Set default properties, override this for individual element
  void setDefaultProps(Map<String, dynamic> props) {}

  Element get parent => this.parentNode;

  Style _style;
  Style get style => _style;
  set style(Style newStyle) {
    newStyle.set('display', newStyle.get('display') ?? defaultDisplay);

    // Update style;
    ///1.update layout properties
    if (renderLayoutElement != null) {
      String oldDisplay = style.get('display');
      String newDisplay = newStyle.get('display');
      bool hasFlexChange = isFlexStyleChanged(newStyle);
      if (newDisplay != oldDisplay || hasFlexChange) {
        ContainerRenderObjectMixin oldRenderElement = renderLayoutElement;
        List<RenderBox> children = [];
        RenderObjectVisitor visitor = (child) {
          children.add(child);
        };
        oldRenderElement
          ..visitChildren(visitor)
          ..removeAll();
        renderPadding.child = null;
        renderLayoutElement = createRenderLayoutBox(newStyle, children);
        renderPadding.child = renderLayoutElement as RenderBox;
        // update style reference
        renderElementBoundary.style = newStyle;
      }

      if (newDisplay == 'flex' || newDisplay == 'inline-flex') {
        // update flex layout properties
        decorateRenderFlex(renderLayoutElement, newStyle);
      } else {
        // update flow layout properties
        decorateRenderFlow(renderLayoutElement, newStyle);
      }

      // update style reference
      if (renderLayoutElement is RenderFlowLayout) {
        (renderLayoutElement as RenderFlowLayout).style = newStyle;
      } else {
        (renderLayoutElement as RenderFlexLayout).style = newStyle;
      }
    }

    // update transiton map
    if (newStyle.contains('transition')) {
      initTransition(newStyle);
    }

    ///2.update overflow
    updateOverFlowBox(newStyle, _scrollListener);

    ///3.update padding
    updateRenderPadding(newStyle, transitionMap);

    ///4.update constrained
    updateConstraints(newStyle, transitionMap);

    ///5.update decorated
    updateRenderDecoratedBox(newStyle, this, transitionMap);

    ///6.update margin
    updateRenderMargin(newStyle, this, transitionMap);

    ///7.update position
    String newPosition = newStyle['position'] ?? 'static';
    String oldPosition = _style['position'] ?? 'static';
    bool positionChanged = false;
    if (newPosition != oldPosition) {
      positionChanged = true;
    }

    // position change
    if (positionChanged) {
      needsReposition = true;
      updatePosition(newStyle);
    } else if (newPosition != 'static') {
      int newZIndex = newStyle.zIndex;
      int oldZIndex = _style.zIndex;
      // zIndex change
      if (newZIndex != oldZIndex) {
        needsReposition = true;
        _updateZIndex(newStyle);
      }

      // offset change
      if (newStyle.top != _style.top ||
          newStyle.bottom != _style.bottom ||
          newStyle.left != _style.left ||
          newStyle.right != _style.right ||
          newStyle.width != _style.width ||
          newStyle.height != _style.height) {
        _updateOffset(newStyle);
      }
    }

    ///8.update opacity and visiblity
    updateRenderOpacity(
      style,
      newStyle,
      parentRenderObject: renderRepaintBoundary,
    );

    ///9.update transform
    updateTransform(newStyle, transitionMap);

    if (transitionMap != null) {
      for (Transition transition in transitionMap.values) {
        transition?.apply();
      }
    }

    /// 10.update childNodes style if need
    updateChildNodesStyle();

    _style = newStyle;
  }

  markShouldUpdateMargin() {
    updateRenderMargin(style, this);
  }

  bool isFlexStyleChanged(Style newStyle) {
    String display = newStyle.get('display');
    List flexStyles = [
      'flexDirection',
      'flexWrap',
      'alignItems',
      'justifyContent',
      'alignContent',
    ];
    bool hasChanged = false;
    if (display == 'flex' || display == 'inline-flex') {
      flexStyles.forEach((key) {
        if (style.get(key) != newStyle.get(key)) {
          hasChanged = true;
        }
      });
    }
    return hasChanged;
  }

  void _scrollListener(double scrollTop) {
    // Only trigger on body element
    if (this != ElementManager().getRootElement()) {
      return;
    }
    _updateStickyPosition(scrollTop);
  }

  // Calculate sticky status according to scrollTop
  void _updateStickyPosition(double scrollTop) {
    List<Element> stickyElements = findStickyChildren(this);
    stickyElements.forEach((Element el) {
      Style elStyle = el.style;
      bool isFixed;

      if (el.offsetTop == null) {
        double offsetTop = el.getOffsetY();
        // save element original offset to viewport
        el.offsetTop = offsetTop;
      }

      if (elStyle.get('top') != null) {
        double top = baseGetDisplayPortedLength(elStyle.get('top'));
        isFixed = el.offsetTop - scrollTop <= top;
      } else if (elStyle.get('bottom') != null) {
        double bottom = baseGetDisplayPortedLength(elStyle.get('bottom'));
        double viewPortHeight = renderMargin?.size?.height;
        double elViewPortTop = el.offsetTop - scrollTop;
        isFixed = viewPortHeight - elViewPortTop <= bottom;
      }

      if (isFixed) {
        // change to fixed behavior
        if (!el.stickyFixed) {
          el.stickyFixed = true;
          el.updatePosition(elStyle.copyWith({'position': 'fixed'}));
        }
      } else {
        // change to relative behavior
        if (el.stickyFixed) {
          el.stickyFixed = false;
          el.updatePosition(elStyle.copyWith({'position': 'sticky'}));
        }
      }
    });
  }

  void updatePosition(Style newStyle) {
    // remove stack node when change to non positioned
    if (newStyle.position == 'static') {
      RenderObject child = renderStack.firstChild;
      renderStack.remove(child);
      (renderStack.parent as RenderDecoratedBox).child = child;
      renderStack = null;
    } else {
      // add stack node when change to positioned
      if (renderStack == null) {
        RenderObject child = renderDecoratedBox.child;
        renderDecoratedBox.child = null;
        RenderStack renderNewStack = RenderPosition(
          textDirection: TextDirection.ltr,
          fit: StackFit.passthrough,
          overflow: Overflow.visible,
          children: [child],
        );

        renderStack = renderDecoratedBox.child = renderNewStack;
      }
    }

    // move element back to document flow
    if (newStyle.position == 'static' ||
        newStyle.position == 'relative' ||
        (newStyle.position == 'sticky' && !stickyFixed)) {
      // move element back to document flow
      if (style.position == 'absolute' ||
          style.position == 'fixed' ||
          (style.position == 'sticky' && stickyFixed)) {
        Element parentElementWithStack;
        // find positioned element to remove
        if (style.position == 'absolute') {
          parentElementWithStack = findParent(this, (element) => element.renderStack != null);
        } else {
          parentElementWithStack = ElementManager().getRootElement();
        }
        parentElementWithStack.renderStack.remove(renderElementBoundary);

        // remove sticky placeholder
        if (style.position == 'sticky') {
          removeStickyPlaceholder();
        }
        // find pre non positioned element
        var preNonPositionedElement = null;
        var currentElement = nodeMap[nodeId];
        var parentElement = currentElement.parentNode;
        int curIdx = parentElement.childNodes.indexOf(currentElement);
        for (int i = curIdx - 1; i > -1; i--) {
          var element = parentElement.childNodes[i];
          var style = element.properties['style'];
          if (style == null ||
              !style.containsKey('position') ||
              (style.containsKey('position') &&
                  style['position'] == 'static')) {
            preNonPositionedElement = element;
            break;
          }
        }
        // find pre non positioned renderObject
        RenderElementBoundary preNonPositionedObject = null;
        if (preNonPositionedElement != null) {
          RenderObjectVisitor visitor = (child) {
            if (child is RenderElementBoundary &&
                preNonPositionedElement.nodeId == child.nodeId) {
              preNonPositionedObject = child;
            }
          };
          parentElement.renderLayoutElement.visitChildren(visitor);
        }
        // insert non positioned renderObject to parent element in the order of original element tree
        parentElement.renderLayoutElement
            .insert(renderElementBoundary, after: preNonPositionedObject);

        needsReposition = false;
      }
    } else {
      // move element out of document flow

      // append element to positioned parent
      _repositionElement(this);
    }

    // loop positioned children to reposition
    List<Element> targets = findPositionedChildren(this);
    if (targets != null) {
      targets.forEach((target) {
        _repositionElement(target);
      });
    }
  }

  void removeStickyPlaceholder() {
    (stickyPlaceholder.parent as ContainerRenderObjectMixin)
        .remove(stickyPlaceholder);
  }

  void insertStickyPlaceholder() {
    Style pStyle = Style({
      'width': renderMargin.size.width.toString() + 'px',
      'height': renderMargin.size.height.toString() + 'px',
    });
    stickyPlaceholder = initRenderConstrainedBox(stickyPlaceholder, pStyle);
    stickyPlaceholder = initRenderDecoratedBox(stickyPlaceholder, pStyle, this);
    (renderObject.parent as ContainerRenderObjectMixin)
        .insert(stickyPlaceholder, after: renderObject);
  }

  // reposition element with position absolute/fixed
  void _repositionElement(Element el) {
    RenderObject renderObject = el.renderObject;
    Style style = el.style;
    int nodeId = el.nodeId;

    // new node not in the tree, wait for append in appenedElement
    if (renderObject.parent == null) {
      return;
    }

    // find positioned element to attach
    Element parentElementWithStack;
    if (style.position == 'absolute') {
      parentElementWithStack =
          findParent(el, (element) => element.renderStack != null);
    } else {
      parentElementWithStack = ElementManager().getRootElement();
    }
    // not found positioned parent element, wait for append in appenedElement
    if (parentElementWithStack == null) return;

    // add placeholder for sticky element before moved
    if (style.position == 'sticky') {
      insertStickyPlaceholder();
    }

    // remove non positioned element from parent element
    // TODO(refactor): remove as cast.
    (renderObject.parent as ContainerRenderObjectMixin).remove(renderObject);
    RenderStack parentStack = parentElementWithStack.renderStack;

    StackParentData stackParentData = getPositionParentDataFromStyle(style);
    renderObject.parentData = stackParentData;

    Element currentElement = nodeMap[nodeId];

    // current element's zIndex
    int currentZIndex = 0;
    if (currentElement.style.contains('zIndex') &&
        currentElement.style['zIndex'] != null) {
      currentZIndex = currentElement.style['zIndex'];
    }
    // add current element back to parent stack by zIndex
    insertByZIndex(parentStack, renderObject, el, currentZIndex);
  }

  void _updateZIndex(Style style) {
    // new node not in the tree, wait for append in appenedElement
    if (renderObject.parent == null) {
      return;
    }
    Element parentElementWithStack =
        findParent(this, (element) => element.renderStack != null);
    RenderStack parentStack = parentElementWithStack.renderStack;

    // remove current element from parent stack
    parentStack.remove(renderObject);

    StackParentData stackParentData = getPositionParentDataFromStyle(style);
    renderObject.parentData = stackParentData;

    // current element's zIndex
    int currentZIndex = 0;
    if (style['zIndex'] != null) {
      currentZIndex = int.parse(style['zIndex']);
    }
    // add current element back to parent stack by zIndex
    insertByZIndex(parentStack, renderObject, this, currentZIndex);
  }

  void _updateOffset(Style style) {
    ZIndexParentData zIndexParentData;
    AbstractNode renderParent = renderObject.parent;
    if (renderParent is RenderPosition &&
        renderObject.parentData is ZIndexParentData) {
      zIndexParentData = renderObject.parentData;
      Transition allTransition,
          topTransition,
          leftTransition,
          rightTransition,
          bottomTransition,
          widthTransition,
          heightTransition;
      double topDiff, leftDiff, rightDiff, bottomDiff, widthDiff, heightDiff;
      double topBase, leftBase, rightBase, bottomBase, widthBase, heightBase;
      ZIndexParentData progressParentData = zIndexParentData;

      if (transitionMap != null) {
        allTransition = transitionMap['all'];
        if (style.top != _style.top) {
          topTransition = transitionMap['top'];
          topDiff = (style.top ?? 0) - (_style.top ?? 0);
          topBase = _style.top ?? 0;
        }
        if (style.left != _style.left) {
          leftTransition = transitionMap['left'];
          leftDiff = (style.left ?? 0) - (_style.left ?? 0);
          leftBase = _style.left ?? 0;
        }
        if (style.right != _style.right) {
          rightTransition = transitionMap['right'];
          rightDiff = (style.right ?? 0) - (_style.left ?? 0);
          rightBase = _style.right ?? 0;
        }
        if (style.bottom != _style.bottom) {
          bottomTransition = transitionMap['bottom'];
          bottomDiff = (style.bottom ?? 0) - (_style.bottom ?? 0);
          bottomBase = _style.bottom ?? 0;
        }
        if (style.width != _style.width) {
          widthTransition = transitionMap['width'];
          widthDiff = (style.width ?? 0) - (_style.width ?? 0);
          widthBase = _style.bottom ?? 0;
        }
        if (style.height != _style.height) {
          heightTransition = transitionMap['height'];
          heightDiff = (style.height ?? 0) - (_style.height ?? 0);
          heightBase = _style.height ?? 0;
        }
      }
      if (allTransition != null ||
          topTransition != null ||
          leftTransition != null ||
          rightTransition != null ||
          bottomTransition != null ||
          widthTransition != null ||
          heightTransition != null) {
        bool hasTop = false,
            hasLeft = false,
            hasRight = false,
            hasBottom = false,
            hasWidth = false,
            hasHeight = false;
        if (topDiff != null) {
          if (topTransition == null) {
            hasTop = true;
          } else {
            topTransition.addProgressListener((percent) {
              progressParentData.top = topBase + topDiff * percent;
              renderObject.parentData = progressParentData;
              renderParent.markNeedsLayout();
            });
          }
        }
        if (leftDiff != null) {
          if (leftTransition == null) {
            hasLeft = true;
          } else {
            leftTransition.addProgressListener((percent) {
              progressParentData.left = leftBase + leftDiff * percent;
              renderObject.parentData = progressParentData;
              renderParent.markNeedsLayout();
            });
          }
        }
        if (rightDiff != null) {
          if (rightTransition == null) {
            hasRight = true;
          } else {
            rightTransition.addProgressListener((percent) {
              progressParentData.right = rightBase + rightDiff * percent;
              renderObject.parentData = progressParentData;
              renderParent.markNeedsLayout();
            });
          }
        }
        if (bottomDiff != null) {
          if (bottomTransition == null) {
            hasBottom = true;
          } else {
            bottomTransition.addProgressListener((percent) {
              progressParentData.bottom = bottomBase + bottomDiff * percent;
              renderObject.parentData = progressParentData;
              renderParent.markNeedsLayout();
            });
          }
        }
        if (widthDiff != null) {
          if (widthTransition == null) {
            hasWidth = true;
          } else {
            widthTransition.addProgressListener((percent) {
              progressParentData.width = widthBase + widthDiff * percent;
              renderObject.parentData = progressParentData;
              renderParent.markNeedsLayout();
            });
          }
        }
        if (heightDiff != null) {
          if (heightTransition == null) {
            hasHeight = true;
          } else {
            heightTransition.addProgressListener((percent) {
              progressParentData.height = heightBase + heightDiff * percent;
              renderObject.parentData = progressParentData;
              renderParent.markNeedsLayout();
            });
          }
        }
        if (allTransition != null &&
            (hasTop ||
                hasBottom ||
                hasLeft ||
                hasRight ||
                hasWidth ||
                hasHeight)) {
          allTransition.addProgressListener((percent) {
            if (hasTop) {
              progressParentData.top = topBase + topDiff * percent;
            }
            if (hasLeft) {
              progressParentData.left = leftBase + leftDiff * percent;
            }
            if (hasRight) {
              progressParentData.right = rightBase + rightDiff * percent;
            }
            if (hasBottom) {
              progressParentData.bottom = bottomBase + bottomDiff * percent;
            }
            if (hasWidth) {
              progressParentData.width = widthBase + widthDiff * percent;
            }
            if (hasHeight) {
              progressParentData.height = heightBase + heightDiff * percent;
            }
            renderObject.parentData = progressParentData;
            renderParent.markNeedsLayout();
          });
        }
      } else {
        zIndexParentData.zIndex = style.zIndex;
        zIndexParentData.top = style.top;
        zIndexParentData.left = style.left;
        zIndexParentData.right = style.right;
        zIndexParentData.bottom = style.bottom;
        zIndexParentData.width = style.width;
        zIndexParentData.height = style.height;
        renderObject.parentData = zIndexParentData;
        renderParent.markNeedsLayout();
      }
    }
  }

  Element getElementById(Element parentElement, int nodeId) {
    Element result = null;
    List childNodes = parentElement.childNodes;

    for (int i = 0; i < childNodes.length; i++) {
      Element element = childNodes[i];
      if (element.nodeId == nodeId) {
        result = element;
        break;
      }
    }
    return result;
  }

  List<Element> get children {
    List<Element> _children = [];
    for (var child in this.childNodes) {
      if (child is Element) _children.add(child);
    }
    return _children;
  }

  void addChild(RenderObject child) {
    if (renderLayoutElement != null) {
      renderLayoutElement.add(child);
    } else {
      renderPadding.child = child;
    }
  }

  ContainerRenderObjectMixin createRenderLayoutBox(
      Style newStyle, List<RenderBox> children) {
    String display = newStyle.get('display');
    String flexWrap = newStyle.get('flexWrap');
    bool isFlexWrap =
        (display == 'flex' || display == 'inline-flex') && flexWrap == 'wrap';
    if ((display == 'flex' || display == 'inline-flex') && flexWrap != 'wrap') {
      ContainerRenderObjectMixin flexLayout = RenderFlexLayout(
        textDirection: TextDirection.ltr,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: children,
        style: newStyle,
        nodeId: nodeId,
      );
      decorateRenderFlex(flexLayout, newStyle);
      return flexLayout;
    } else if (display == 'none' ||
        display == 'inline' ||
        display == 'inline-block' ||
        display == 'block' ||
        isFlexWrap) {
      MainAxisAlignment runAlignment = MainAxisAlignment.start;
      switch (newStyle['alignContent']) {
        case 'end':
          runAlignment = MainAxisAlignment.end;
          break;
        case 'center':
          runAlignment = MainAxisAlignment.center;
          break;
        case 'space-around':
          runAlignment = MainAxisAlignment.spaceAround;
          break;
        case 'space-between':
          runAlignment = MainAxisAlignment.spaceBetween;
          break;
        case 'space-evenly':
          runAlignment = MainAxisAlignment.spaceEvenly;
          break;
      }
      ContainerRenderObjectMixin flowLayout = RenderFlowLayout(
        runAlignment: runAlignment,
        children: children,
        style: newStyle,
        nodeId: nodeId,
      );

      if (isFlexWrap) {
        decorateRenderFlex(flowLayout, newStyle);
      } else {
        decorateRenderFlow(flowLayout, newStyle);
      }
      return flowLayout;
    } else {
      throw FlutterError('Not supported display type $display: $this');
    }
  }

  @override
  @mustCallSuper
  Node appendChild(Node child) {
    super.appendChild(child);

    VoidCallback doAppendChild = () {
      // Only append node types which is visible in RenderObject tree
      if (child is NodeLifeCycle) {
        appendElement(child);
        child.fireAfterConnected();
      }
    };

    if (isConnected) {
      doAppendChild();
    } else {
      queueAfterConnected(doAppendChild);
    }

    return child;
  }

  @override
  @mustCallSuper
  Node removeChild(Node child) {
    // Not remove node type which is not present in RenderObject tree such as Comment
    // Only append node types which is visible in RenderObject tree
    if (child is NodeLifeCycle) {
      removeElement(child);
    }

    super.removeChild(child);
    return child;
  }

  @override
  @mustCallSuper
  Node insertBefore(Node child, Node referenceNode) {
    int referenceIndex = childNodes.indexOf(referenceNode);

    // Node.insertBefore will change element tree structure,
    // so get the referenceIndex before calling it.
    Node node = super.insertBefore(child, referenceNode);

    VoidCallback doInsertBefore = () {
      if (referenceIndex != -1) {
        Node after;
        RenderObject afterRenderObject;
        if (referenceIndex == 0) {
          after = null;
        } else {
          do {
            after = childNodes[--referenceIndex];
          } while (after is! Element && referenceIndex > 0);
          if (after is Element) {
            afterRenderObject = after?.renderObject;
          }
        }
        appendElement(child, afterRenderObject: afterRenderObject, isAppend: false);
        if (child is NodeLifeCycle) child.fireAfterConnected();
      }
    };

    if (isConnected) {
      doInsertBefore();
    } else {
      queueAfterConnected(doInsertBefore);
    }
    return node;
  }

  // Loop element's children to find elements need to reposition
  List<Element> findPositionedChildren(Element element,
      {bool needsReposition = false}) {
    assert(element != null);
    List<Element> result = [];

    element.children.forEach((Element child) {
      if (_isPositioned(child.style)) {
        if (needsReposition) {
          if (child.needsReposition) result.add(child);
        } else {
          result.add(child);
        }
      }

      List<Element> mergeChildren =
          findPositionedChildren(child, needsReposition: needsReposition);
      if (mergeChildren != null) {
        mergeChildren.forEach((Element child) {
          result.add(child);
        });
      }
    });

    return result;
  }

  void removeElement(Node child) {
    List<RenderObject> children = [];
    RenderObjectVisitor visitor = (child) {
      children.add(child);
    };
    renderLayoutElement..visitChildren(visitor);

    if (children.isNotEmpty) {
      int childIdx;
      children.forEach((childNode) {
        int childId;
        if (childNode is RenderTextBox) {
          childId = childNode.nodeId;
        } else if (childNode is RenderElementBoundary) {
          childId = childNode.nodeId;
        }
        if (childId == child.nodeId) {
          childIdx = children.indexOf(childNode);
        }
      });
      renderLayoutElement.remove(children[childIdx]);
    }
  }

  void appendElement(Node child,
      {RenderObject afterRenderObject, bool isAppend = true}) {
    if (child is Element) {
      RenderObject childRenderObject = child.renderObject;
      Style childStyle = child.style;
      String childPosition = childStyle['position'] ?? 'static';
      String display = style.get('display');
      bool isFlex = display == 'flex' || display == 'inline-flex';

      // Set audio element size to zero
      // TODO(refactor): Should not exists here.
      if (child is AudioElement) {
        RenderConstrainedBox renderConstrainedBox = child.renderConstrainedBox;
        renderConstrainedBox.additionalConstraints = BoxConstraints();
      }

      if (isFlex) {
        // Add FlexItem wrap for flex child node.
        if (child.renderLayoutElement != null) {
          child.renderPadding.child = null;
          child.renderPadding.child =
              RenderFlexItem(child: child.renderLayoutElement as RenderBox);
        }
      }

      RenderBox getStackedRenderBox(Element element) {
        ZIndexParentData stackParentData =
            getPositionParentDataFromStyle(element.style);
        RenderBox stackedRenderBox = element.renderObject as RenderBox;


        if (!isFlex) {
          stackParentData.hookRenderObject =
              RenderPadding(padding: EdgeInsets.zero);
        }
        stackedRenderBox.parentData = stackParentData;
        return stackedRenderBox;
      }

      if (childPosition == 'absolute') {
        Element parentStackedElement =
            findParent(child, (element) => element.renderStack != null);
        if (parentStackedElement != null) {
          RenderObject renderBoxToBeStacked = getStackedRenderBox(child);
          insertByZIndex(parentStackedElement.renderStack, renderBoxToBeStacked,
              child, childStyle.zIndex);
          return;
        }
      } else if (childPosition == 'fixed') {
        final RenderPosition rootRenderStack =
            ElementManager().getRootElement().renderStack;
        if (rootRenderStack != null) {
          RenderBox stackedRenderBox = getStackedRenderBox(child);
          insertByZIndex(
              rootRenderStack, stackedRenderBox, child, childStyle.zIndex);
          return;
        }

        if (isFlex) return;
      }

      if (isAppend) {
        addChild(childRenderObject);
      } else {
        renderLayoutElement.insert(childRenderObject, after: afterRenderObject);
      }

      ParentData childParentData = childRenderObject.parentData;
      if (isFlex) {
        assert(childParentData is KrakenFlexParentData);
        final KrakenFlexParentData parentData = childParentData;
        KrakenFlexParentData flexParentData =
            FlexItem.getParentData(childStyle);
        parentData.flexGrow = flexParentData.flexGrow;
        parentData.flexShrink = flexParentData.flexShrink;
        parentData.flexBasis = flexParentData.flexBasis;
        parentData.fit = flexParentData.fit;
        String alignItems = style[FlexItem.ALIGN_ITEMS];
        if (alignItems != null && style[FlexItem.ALIGN_ITEMS] != 'stretch') {
          flexParentData.fit = FlexFit.tight;
        }

        child.markShouldUpdateMargin(); // Update margin for flex child.
        renderObject.markNeedsLayout();
      }

      // @TODO move to connected callback instead use of timer
      Timer(Duration(milliseconds: 0), () {
        // Trigger sticky update logic after node is connected
        if (childStyle.get('position') == 'sticky') {
          _updateStickyPosition(0);
        }
      });
    }
  }

  void insertByZIndex(RenderStack renderStack, RenderObject renderObject,
      Element el, int zIndex) {
    el.needsReposition = false;
    RenderBox child = renderStack.lastChild;
    while (child != null) {
      ParentData parentData = child.parentData;
      if (parentData is ZIndexParentData) {
        if (parentData.zIndex <= zIndex) {
          renderStack.insert(renderObject, after: child);
        } else {
          final ContainerParentDataMixin childParentData = child.parentData;
          renderStack.insert(renderObject,
              after: childParentData.previousSibling);
        }
        return;
      } else if (zIndex >= 0) {
        renderStack.insert(renderObject, after: child);
        return;
      }
      final ContainerParentDataMixin childParentData = child.parentData;
      child = childParentData.previousSibling;
    }
    renderStack.insert(renderObject, after: null);
  }

  static ZIndexParentData getPositionParentDataFromStyle(Style style) {
    ZIndexParentData parentData = ZIndexParentData();

    if (style.contains('top')) {
      parentData..top = Length.toDisplayPortValue(style['top']);
    }
    if (style.contains('left')) {
      parentData..left = Length.toDisplayPortValue(style['left']);
    }
    if (style.contains('bottom')) {
      parentData..bottom = Length.toDisplayPortValue(style['bottom']);
    }
    if (style.contains('right')) {
      parentData..right = Length.toDisplayPortValue(style['right']);
    }
    parentData.width = Length.toDisplayPortValue(style['width']);
    parentData.height = Length.toDisplayPortValue(style['height']);
    parentData.zIndex = style.zIndex;
    return parentData;
  }

  // Update textNode style when container style changed
  void updateChildNodesStyle() {
    childNodes.forEach((node) {
      if (node is TextNode) node.updateTextStyle();
    });
  }

  @mustCallSuper
  void setStyle(String key, String value) {
    Style newStyle = _style.copyWith({ key: value });
    properties['style'] = newStyle.getOriginalStyleMap();
    style = newStyle;
  }

  @mustCallSuper
  void setProperty(String key, value) {
    properties[key] = value;

    if (key == 'style') {
      style = _style.copyWith(value);
    }
  }

  @mustCallSuper
  void removeProperty(String key) {
    properties.remove(key);
  }

  method(String name, List args) {
    switch (name) {
      case 'offsetTop':
        return getOffsetY();
      case 'offsetLeft':
        return getOffsetX();
      case 'offsetWidth':
        return renderMargin.hasSize ? renderMargin.size.width : 0;
      case 'offsetHeight':
        return renderMargin.hasSize ? renderMargin.size.height : 0;
      case 'clientWidth':
        return renderPadding.hasSize ? renderPadding.size.width : 0;
      case 'clientHeight':
        return renderPadding.hasSize ? renderPadding.size.height : 0;
      case 'clientLeft':
        return renderPadding.hasSize
            ? renderPadding
                .localToGlobal(Offset.zero, ancestor: renderMargin)
                .dx
            : 0;
      case 'clientTop':
        return renderPadding.hasSize
            ? renderPadding
                .localToGlobal(Offset.zero, ancestor: renderMargin)
                .dy
            : 0;
      case 'scrollTop':
        return getScrollTop();
      case 'scrollLeft':
        return getScrollLeft();
      case 'scrollHeight':
        return getScrollHeight();
      case 'scrollWidth':
        return getScrollWidth();
      case 'getBoundingClientRect':
        return getBoundingClientRect();
      case 'click':
        return click();
      default:
        debugPrint('Unknown method call. name: $name, args: ${args}');
    }
  }

  String getBoundingClientRect() {
    BoundingClientRect boundingClientRect;

    if (isConnected) {
      // Force flush layout.
      renderBorderHolder.markNeedsLayout();
      renderBorderHolder.owner.flushLayout();

      Offset offset = getOffset(renderBorderHolder);
      Size size = renderBorderHolder.size;
      boundingClientRect = BoundingClientRect(
        x: offset.dx,
        y: offset.dy,
        width: size.width,
        height: size.height,
        top: offset.dy,
        left: offset.dx,
        right: offset.dx + size.width,
        bottom: offset.dy + size.height,
      );
    } else {
      boundingClientRect = BoundingClientRect();
    }

    return boundingClientRect.toJSON();
  }

  double getOffsetX() {
    double offset = 0;
    if (renderObject is RenderBox && renderObject.attached) {
      Offset relative = getOffset(renderObject as RenderBox);
      offset += relative.dx;
    }
    return offset;
  }

  double getOffsetY() {
    double offset = 0;
    if (renderObject is RenderBox && renderObject.attached) {
      Offset relative = getOffset(renderObject as RenderBox);
      offset += relative.dy;
    }
    return offset;
  }

  Offset getOffset(RenderBox renderBox) {
    Element element =
        findParent(this, (element) => element.renderStack != null);
    if (element == null) {
      element = ElementManager().getRootElement();
    }
    return renderBox.localToGlobal(Offset.zero, ancestor: element.renderObject);
  }

  void addEvent(String eventName) {
    if (this.eventHandlers.containsKey(eventName)) return; // Only listen once.
    super.addEventListener(eventName, this._eventResponder);

    if (_isIntersectionObserverEvent(eventName)) {
      renderIntersectionObserver.onIntersectionChange =
          handleIntersectionChange;
    }
  }

  void removeEvent(String eventName) {
    if (!this.eventHandlers.containsKey(eventName)) return; // Only listen once.
    super.removeEventListener(eventName, this._eventResponder);

    if (_isIntersectionObserverEvent(eventName)) {
      if (!_hasIntersectionObserverEvent(this.eventHandlers)) {
        renderIntersectionObserver.onIntersectionChange = null;
      }
    }
  }

  void _eventResponder(Event event) {
    String json = jsonEncode([nodeId, event]);
    emitUIEvent(json);
  }

  void click() {
    Event clickEvent = Event('click', EventInit());

    if (isConnected) {
      final RenderBox box = renderElementBoundary;
      // Must flush every times, or child may has no size.
      box.markNeedsLayout();
      box.owner.flushLayout();

      // Position the center of element.
      Offset position = box.localToGlobal(box.size.center(Offset.zero));
      final BoxHitTestResult boxHitTestResult = BoxHitTestResult();
      GestureBinding.instance.hitTest(boxHitTestResult, position);
      bool hitTest = true;
      Element currentElement = this;
      while (hitTest) {
        currentElement.handleClick(clickEvent);
        if (currentElement.parent != null) {
          currentElement = currentElement.parent;
          hitTest = currentElement
              .renderElementBoundary
              .hitTest(boxHitTestResult, position: position);
        } else {
          hitTest = false;
        }
      }
    } else {
      // If element not in tree, click is fired and only response to itself.
      handleClick(clickEvent);
    }
  }

  Future<Uint8List> toBlob({double devicePixelRatio}) {
    if (devicePixelRatio == null) {
      devicePixelRatio = window.devicePixelRatio;
    }

    Completer<Uint8List> completer = new Completer();

    // need to make sure all renderObject had repainted.
    renderObject.markNeedsPaint();
    RendererBinding.instance.addPostFrameCallback((_) async {
      Image image =
          await renderRepaintBoundary.toImage(pixelRatio: devicePixelRatio);
      ByteData byteData = await image.toByteData(format: ImageByteFormat.png);
      completer.complete(byteData.buffer.asUint8List());
    });

    return completer.future;
  }
}

Element findParent(Element element, TestElement testElement) {
  Element _el = element?.parent;
  while (_el != null && !testElement(_el)) {
    _el = _el.parent;
  }
  return _el;
}

List<Element> findStickyChildren(Element element) {
  assert(element != null);
  List<Element> result = [];

  element.children.forEach((Element child) {
    if (_isSticky(child.style)) result.add(child);

    List<Element> mergedChildren = findStickyChildren(child);
    mergedChildren.forEach((Element child) {
      result.add(child);
    });
  });

  return result;
}

bool _isIntersectionObserverEvent(String eventName) {
  return eventName == 'appear' ||
      eventName == 'disappear' ||
      eventName == 'intersectionchange';
}

bool _hasIntersectionObserverEvent(eventHandlers) {
  return eventHandlers.containsKey('appear') ||
      eventHandlers.containsKey('disappear') ||
      eventHandlers.containsKey('intersectionchange');
}

bool _isPositioned(Style style) {
  return style.contains('position') && style.position == 'absolute' ||
      style.position == 'fixed';
}

bool _isSticky(Style style) {
  return style.position == 'sticky' && style.top != null ||
      style.bottom != null;
}
