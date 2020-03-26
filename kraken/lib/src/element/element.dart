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

  Map<String, dynamic> properties;
  List<String> events;

  // Whether element allows children.
  bool allowChildren = true;

  /// whether element needs reposition when append to tree or
  /// changing position property.
  bool needsReposition = false;

  bool shouldBlockStretch = true;

  double offsetTop = null; // offset to the top of viewport
  bool stickyFixed = false;

  final String tagName;

  /// The default display type of
  final String defaultDisplay;

  // Set default properties, override this for individual element
  void setDefaultProps(Map<String, dynamic> props) {}

  // Style declaration from user.
  StyleDeclaration style;


  // A point reference to treed renderObject.
  RenderObject renderObject;
  RenderConstrainedBox renderConstrainedBox;
  RenderObject stickyPlaceholder;
  RenderRepaintBoundary renderRepaintBoundary;
  RenderStack renderStack;
  ContainerRenderObjectMixin renderLayoutBox;
  RenderPadding renderPadding;
  RenderIntersectionObserver renderIntersectionObserver;
  RenderElementBoundary renderElementBoundary;
  RenderPadding renderPositionedPlaceholder;

  // Horizontal margin dimension (left + right)
  double get cropMarginWidth => renderMargin.margin.horizontal;
  // Vertial margin dimension (top + bottom)
  double get cropMarginHeight => renderMargin.margin.vertical;
  // Horizontal padding dimension (left + right)
  double get cropPaddingWidth => renderPadding.padding.horizontal;
  // Vertial padding dimension (top + bottom)
  double get cropPaddingHeight => renderPadding.padding.vertical;
  // Horizontal border dimension (left + right)
  double get cropBorderWidth => renderBorderHolder.margin.horizontal;
  // Vertial border dimension (top + bottom)
  double get cropBorderHeight => renderBorderHolder.margin.vertical;

  Element({
    @required int nodeId,
    @required this.tagName,
    this.defaultDisplay = 'block',
    this.properties = const {},
    this.needsReposition = false,
    this.allowChildren = true,
    this.events,
  })  : assert(nodeId != null),
        assert(tagName != null),
        super(NodeType.ELEMENT_NODE, nodeId, tagName) {
    setDefaultProps(properties);
    style = StyleDeclaration(style: properties[STYLE]);

    String display = style['display'];

    _registerStyleChangedListeners();

    // Mark element needs to reposition according to position CSS.
    if (_isPositioned(style)) needsReposition = true;

    if (allowChildren) {
      // Content children layout, BoxModel content.
      renderObject =
          renderLayoutBox = createRenderLayoutBox(style, null);
    }

    // background image
    if (shouldInitBackgroundImage(style)) {
      renderObject = initBackgroundImage(renderObject, style, nodeId);
    }

    // BoxModel Padding.
    renderObject = renderPadding = initRenderPadding(renderObject, style);

    // Overflow.
    if (allowChildren) {
      renderObject = initOverflowBox(renderObject, style, _scrollListener);
    }


    // border
    renderObject = initRenderDecoratedBox(renderObject, style, nodeId);

    // constrained box
    renderObject =
        renderConstrainedBox = initRenderConstrainedBox(renderObject, style);

    // Positioned boundary.
    if (_isPositioned(style)) {
      renderObject = renderStack = RenderPosition(
        textDirection: TextDirection.ltr,
        fit: StackFit.passthrough,
        overflow: Overflow.visible,
        children: [renderObject],
      );
    }

    // Pointer event listener boundary.
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

    // Opacity
    renderObject = initRenderOpacity(renderObject, style);

    // RenderRepaintBoundary to support toBlob.
    renderObject =
        renderRepaintBoundary = RenderRepaintBoundary(child: renderObject);

    // BoxModel Margin
    renderObject = initRenderMargin(renderObject, style);

    bool shouldRender = display != 'none';
    // The layout boundary of element.
    renderObject = renderElementBoundary = initTransform(renderObject, style, nodeId, shouldRender);

    // Add element event listener
    events?.forEach((String eventName) {
      addEvent(eventName);
    });
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
      StyleDeclaration elStyle = el.style;
      bool isFixed;

      if (el.offsetTop == null) {
        double offsetTop = el.getOffsetY();
        // save element original offset to viewport
        el.offsetTop = offsetTop;
      }

      if (elStyle.contains('top')) {
        double top = baseGetDisplayPortedLength(elStyle['top']);
        isFixed = el.offsetTop - scrollTop <= top;
      } else if (elStyle.contains('bottom')) {
        double bottom = baseGetDisplayPortedLength(elStyle['bottom']);
        double viewPortHeight = renderMargin?.size?.height;
        double elViewPortTop = el.offsetTop - scrollTop;
        isFixed = viewPortHeight - elViewPortTop <= bottom;
      }
      if (isFixed) {
        // change to fixed behavior
        if (!el.stickyFixed) {
          el.stickyFixed = true;
          el._doUpdatePosition(el.style['position'], 'fixed');
        }
      } else {
        // change to relative behavior
        if (el.stickyFixed) {
          el.stickyFixed = false;
          el._doUpdatePosition(el.style['position'], 'sticky');
        }
      }
    });
  }

  void _doUpdatePosition(String prevPosition, String currentPosition) {
    if (isEmptyStyleValue(prevPosition)) prevPosition = 'static';
    if (isEmptyStyleValue(currentPosition)) currentPosition = 'static';

    // Remove stack node when change to non positioned.
    if (currentPosition == 'static') {
      RenderObject child = renderStack.firstChild;
      renderStack.remove(child);
      (renderStack.parent as RenderDecoratedBox).child = child;
      renderStack = null;
    } else {
      // Add stack node when change to positioned.
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
    if (currentPosition == 'static' ||
        currentPosition == 'relative' ||
        (currentPosition == 'sticky' && !stickyFixed)) {
      // move element back to document flow
      if (prevPosition == 'absolute' ||
          prevPosition == 'fixed' ||
          (prevPosition == 'sticky')) {

        // Find positioned element to remove
        ContainerRenderObjectMixin parentRenderObject = renderElementBoundary.parent;
        parentRenderObject.remove(renderElementBoundary);

        // Remove sticky placeholder
        if (prevPosition == 'sticky') {
          removeStickyPlaceholder();
        }

        // Find pre non positioned element
        Element preNonPositionedElement = null;
        int currentChildIndex = parent.children.indexOf(this);
        for (int i = currentChildIndex - 1; i > -1; i--) {
          Element childElement = parent.children[i];
          String childPosition = childElement.style['position'];
          if (childPosition == 'static') {
            preNonPositionedElement = childElement;
            break;
          }
        }

        // find pre non positioned renderObject
        RenderElementBoundary preNonPositionedObject = null;
        if (preNonPositionedElement != null) {
          parentElement.renderLayoutBox.visitChildren((child) {
            if (child is RenderElementBoundary &&
                preNonPositionedElement.nodeId == child.nodeId) {
              preNonPositionedObject = child;
            }
          });
        }

        // Insert non positioned renderObject to parent element in the
        // order of original element tree
        parentElement.renderLayoutBox
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
    if (stickyPlaceholder != null) {
      ContainerRenderObjectMixin stickyPlaceholderParent = stickyPlaceholder
          .parent;
      stickyPlaceholderParent.remove(stickyPlaceholder);
    }
  }

  void insertStickyPlaceholder() {
    if (!renderMargin.hasSize) {
      renderMargin.owner.flushLayout();
    }

    StyleDeclaration pStyle = StyleDeclaration(style: {
      'width': renderMargin.size.width.toString() + 'px',
      'height': renderMargin.size.height.toString() + 'px',
    });
    stickyPlaceholder = initRenderConstrainedBox(stickyPlaceholder, pStyle);
    stickyPlaceholder = initRenderDecoratedBox(stickyPlaceholder, pStyle, nodeId);
    (renderObject.parent as ContainerRenderObjectMixin)
        .insert(stickyPlaceholder, after: renderObject);
  }

  // reposition element with position absolute/fixed
  void _repositionElement(Element el) {
    RenderObject renderObject = el.renderObject;
    StyleDeclaration style = el.style;
    int nodeId = el.nodeId;

    // new node not in the tree, wait for append in appenedElement
    if (renderObject.parent == null) {
      return;
    }

    // find positioned element to attach
    Element parentElementWithStack;
    if (style['position'] == 'absolute') {
      parentElementWithStack =
          findParent(el, (element) => element.renderStack != null);
    } else {
      parentElementWithStack = ElementManager().getRootElement();
    }
    // not found positioned parent element, wait for append in appenedElement
    if (parentElementWithStack == null) return;

    // add placeholder for sticky element before moved
    if (style['position'] == 'sticky') {
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
    int currentZIndex = Length.toInt(currentElement.style['zIndex']);
    // add current element back to parent stack by zIndex
    insertByZIndex(parentStack, el, currentZIndex);
  }

  void _updateZIndex() {
    // new node not in the tree, wait for append in appenedElement
    if (renderObject.parent == null) {
      return;
    }

    Element parentElementWithStack = findParent(this, (element) => element.renderStack != null);
    RenderStack parentStack = parentElementWithStack.renderStack;

    // remove current element from parent stack
    parentStack.remove(renderObject);

    StackParentData stackParentData = getPositionParentDataFromStyle(style);
    renderObject.parentData = stackParentData;

    // current element's zIndex
    int currentZIndex = Length.toInt(style['zIndex']);
    // add current element back to parent stack by zIndex
    insertByZIndex(parentStack, this, currentZIndex);
  }

  void _updateOffset({
    Transition definiteTransition,
    String property,
    double diff,
    double original
  }) {
    ZIndexParentData zIndexParentData;
    RenderBox renderParent = renderElementBoundary.parent;
    if (renderParent is RenderPosition
        && renderElementBoundary.parentData is ZIndexParentData) {
      zIndexParentData = renderElementBoundary.parentData;
      ZIndexParentData progressParentData = zIndexParentData;

      Transition allTransition;
      if (transitionMap != null) {
        allTransition = transitionMap['all'];
      }

      if (definiteTransition != null || allTransition != null) {
        assert(diff != null);
        assert(original != null);

        ProgressListener progressListener = (percent) {
          double newValue = original + diff * percent;
          switch (property) {
            case 'top':
              progressParentData.top = newValue;
              break;
            case 'left':
              progressParentData.left = newValue;
              break;
            case 'right':
              progressParentData.right = newValue;
              break;
            case 'bottom':
              progressParentData.bottom = newValue;
              break;
            case 'width':
              progressParentData.width = newValue;
              break;
            case 'height':
              progressParentData.height = newValue;
              break;
          }
          renderElementBoundary.parentData = progressParentData;
          renderParent.markNeedsLayout();
        };

        definiteTransition?.addProgressListener(progressListener);
        allTransition?.addProgressListener(progressListener);
      } else {
        zIndexParentData.zIndex = Length.toInt(style['zIndex']);;
        zIndexParentData.top = Length.toDisplayPortValue(style['top']);
        zIndexParentData.left = Length.toDisplayPortValue(style['left']);
        zIndexParentData.right = Length.toDisplayPortValue(style['right']);
        zIndexParentData.bottom = Length.toDisplayPortValue(style['bottom']);
        zIndexParentData.width = Length.toDisplayPortValue(style['width']);
        zIndexParentData.height = Length.toDisplayPortValue(style['height']);
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

  void addChild(RenderObject child) {
    if (renderLayoutBox != null) {
      renderLayoutBox.add(child);
    } else {
      renderPadding.child = child;
    }
  }

  ContainerRenderObjectMixin createRenderLayoutBox(
      StyleDeclaration style, List<RenderBox> children) {
    String display = isEmptyStyleValue(style['display'])
        ? defaultDisplay
        : style['display'];
    String flexWrap = style['flexWrap'];
    bool isFlexWrap = display.endsWith('flex') && flexWrap == 'wrap';
    if (display.endsWith('flex') && flexWrap != 'wrap') {
      ContainerRenderObjectMixin flexLayout = RenderFlexLayout(
        textDirection: TextDirection.ltr,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: children,
        style: style,
        nodeId: nodeId,
      );
      decorateRenderFlex(flexLayout, style);
      return flexLayout;
    } else if (
      display == 'none' ||
      display == 'inline' ||
      display == 'inline-block' ||
      display == 'block' ||
      isFlexWrap
    ) {
      ContainerRenderObjectMixin flowLayout = RenderFlowLayout(
        children: children,
        style: style,
        nodeId: nodeId,
      );
      if (isFlexWrap) {
        decorateRenderFlex(flowLayout, style);
      } else {
        decorateRenderFlow(flowLayout, style);
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
    renderLayoutBox..visitChildren(visitor);

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
      renderLayoutBox.remove(children[childIdx]);
    }
  }

  RenderBox getStackedRenderBox(Element element) {
    renderPositionedPlaceholder = RenderPadding(padding: EdgeInsets.zero);
    ZIndexParentData stackParentData =
      getPositionParentDataFromStyle(element.style);
    RenderBox stackedRenderBox = element.renderObject as RenderBox;
    stackParentData.hookRenderObject = renderPositionedPlaceholder;
    stackedRenderBox.parentData = stackParentData;
    return stackedRenderBox;
  }

  void addPositionPlaceholder() {
    if (renderPositionedPlaceholder == null ||
        !renderPositionedPlaceholder.attached) {
      addChild(renderPositionedPlaceholder);
    }
  }

  void appendElement(Node child,
      {RenderObject afterRenderObject, bool isAppend = true}) {
    if (child is Element) {
      RenderObject childRenderObject = child.renderObject;
      StyleDeclaration childStyle = child.style;
      String childPosition = childStyle['position'] == '' ? 'static' : childStyle['position'];
      String display = isEmptyStyleValue(style['display']) ? defaultDisplay : style['display'];
      bool isFlex = display.endsWith('flex');

      if (isFlex) {
        // Add FlexItem wrap for flex child node.
        if (child.renderLayoutBox != null) {
          child.renderPadding.child = null;
          child.renderPadding.child =
              RenderFlexItem(child: child.renderLayoutBox as RenderBox);
        }
      }
      if (childPosition == 'absolute') {
        Element parentStackedElement =
          findParent(child, (element) => element.renderStack != null);
        if (parentStackedElement != null) {
          insertByZIndex(
              parentStackedElement.renderStack, child, Length.toInt(childStyle['zIndex']));
          return;
        }
      } else if (childPosition == 'fixed') {
        final RenderPosition rootRenderStack =
            ElementManager().getRootElement().renderStack;
        if (rootRenderStack != null) {
          insertByZIndex(
              rootRenderStack, child, Length.toInt(childStyle['zIndex']));
          return;
        }

        if (isFlex) return;
      }

      if (isAppend) {
        addChild(childRenderObject);
      } else {
        renderLayoutBox.insert(childRenderObject, after: afterRenderObject);
      }

      if (isFlex) {
        children.forEach((Element child) {
          _updateFlexItemStyle(child);
        });
      }

      // Trigger sticky update logic after node is connected
      if (childPosition == 'sticky') {
        // Force flush layout of child
        if (!child.renderMargin.hasSize) {
          child.renderMargin.owner.flushLayout();
        }
        _updateStickyPosition(0);
      }
    }
  }

  void _updateFlexItemStyle(Element element) {
    ParentData childParentData = element.renderObject.parentData;
    if (childParentData is RenderFlexParentData) {
      final RenderFlexParentData parentData = childParentData;
      RenderFlexParentData flexParentData = FlexItem.getParentData(element.style);
      parentData.flexGrow = flexParentData.flexGrow;
      parentData.flexShrink = flexParentData.flexShrink;
      parentData.flexBasis = flexParentData.flexBasis;

      // Update margin for flex child.
      element.updateRenderMargin(element.style);
      element.renderObject.markNeedsLayout();
    }
  }

  void insertByZIndex(RenderStack renderStack, Element el, int zIndex) {
    RenderObject renderObject = getStackedRenderBox(el);
    el.needsReposition = false;
    RenderBox child = renderStack.lastChild;
    while (child != null) {
      ParentData parentData = child.parentData;
      if (parentData is ZIndexParentData) {
        final ContainerParentDataMixin childParentData = child.parentData;
        if (parentData.zIndex <= zIndex) {
          renderStack.insert(renderObject, after: child);
        } else {
          renderStack.insert(renderObject,
              after: childParentData.previousSibling);
        }
        addPositionPlaceholder();
        return;
      } else if (zIndex >= 0) {
        renderStack.insert(renderObject, after: child);
        addPositionPlaceholder();
        return;
      }
      final ContainerParentDataMixin childParentData = child.parentData;
      child = childParentData.previousSibling;
    }
    renderStack.insert(renderObject, after: null);
    addPositionPlaceholder();
  }

  void _registerStyleChangedListeners() {
    style.addStyleChangeListener('display', _styleDisplayChangedListener);
    style.addStyleChangeListener('position', _stylePositionChangedListener);
    style.addStyleChangeListener('zIndex', _stylePositionChangedListener);

    style.addStyleChangeListener('top', _styleOffsetChangedListener);
    style.addStyleChangeListener('left', _styleOffsetChangedListener);
    style.addStyleChangeListener('bottom', _styleOffsetChangedListener);
    style.addStyleChangeListener('right', _styleOffsetChangedListener);

    style.addStyleChangeListener('flexDirection', _styleFlexChangedListener);
    style.addStyleChangeListener('flexWrap', _styleFlexChangedListener);
    style.addStyleChangeListener('flexFlow', _styleFlexItemChangedListener);
    style.addStyleChangeListener('justifyContent', _styleFlexChangedListener);
    style.addStyleChangeListener('alignItems', _styleFlexChangedListener);
    style.addStyleChangeListener('alignContent', _styleFlexChangedListener);
    style.addStyleChangeListener('textAlign', _styleFlexChangedListener);

    style.addStyleChangeListener('flexGrow', _styleFlexItemChangedListener);
    style.addStyleChangeListener('flexShrink', _styleFlexItemChangedListener);
    style.addStyleChangeListener('flexBasis', _styleFlexItemChangedListener);
    style.addStyleChangeListener('alignItems', _styleFlexItemChangedListener);

    style.addStyleChangeListener('textAlign', _styleTextAlignChangedListener);

    style.addStyleChangeListener('padding', _stylePaddingChangedListener);
    style.addStyleChangeListener('paddingLeft', _stylePaddingChangedListener);
    style.addStyleChangeListener('paddingTop', _stylePaddingChangedListener);
    style.addStyleChangeListener('paddingRight', _stylePaddingChangedListener);
    style.addStyleChangeListener('paddingBottom', _stylePaddingChangedListener);

    style.addStyleChangeListener('width', _styleSizeChangedListener);
    style.addStyleChangeListener('min-width', _styleSizeChangedListener);
    style.addStyleChangeListener('max-width', _styleSizeChangedListener);
    style.addStyleChangeListener('height', _styleSizeChangedListener);
    style.addStyleChangeListener('min-height', _styleSizeChangedListener);
    style.addStyleChangeListener('max-height', _styleSizeChangedListener);

    style.addStyleChangeListener('overflow', _styleOverflowChangedListener);
    style.addStyleChangeListener('overflowX', _styleOverflowChangedListener);
    style.addStyleChangeListener('overflowY', _styleOverflowChangedListener);

    style.addStyleChangeListener('backgroundColor', _styleDecoratedChangedListener);
    style.addStyleChangeListener('backgroundAttachment', _styleDecoratedChangedListener);
    style.addStyleChangeListener('backgroundImage', _styleDecoratedChangedListener);
    style.addStyleChangeListener('backgroundRepeat', _styleDecoratedChangedListener);
    style.addStyleChangeListener('backgroundSize', _styleDecoratedChangedListener);
    style.addStyleChangeListener('backgroundPosition', _styleDecoratedChangedListener);

    style.addStyleChangeListener('border', _styleDecoratedChangedListener);
    style.addStyleChangeListener('borderTop', _styleDecoratedChangedListener);
    style.addStyleChangeListener('borderLeft', _styleDecoratedChangedListener);
    style.addStyleChangeListener('borderRight', _styleDecoratedChangedListener);
    style.addStyleChangeListener('borderBottom', _styleDecoratedChangedListener);
    style.addStyleChangeListener('borderWidth', _styleDecoratedChangedListener);
    style.addStyleChangeListener('borderLeftWidth', _styleDecoratedChangedListener);
    style.addStyleChangeListener('borderTopWidth', _styleDecoratedChangedListener);
    style.addStyleChangeListener('borderRightWidth', _styleDecoratedChangedListener);
    style.addStyleChangeListener('borderBottomWidth', _styleDecoratedChangedListener);
    style.addStyleChangeListener('borderStyle', _styleDecoratedChangedListener);
    style.addStyleChangeListener('borderLeftStyle', _styleDecoratedChangedListener);
    style.addStyleChangeListener('borderTopStyle', _styleDecoratedChangedListener);
    style.addStyleChangeListener('borderRightStyle', _styleDecoratedChangedListener);
    style.addStyleChangeListener('borderBottomStyle', _styleDecoratedChangedListener);
    style.addStyleChangeListener('borderColor', _styleDecoratedChangedListener);
    style.addStyleChangeListener('borderLeftColor', _styleDecoratedChangedListener);
    style.addStyleChangeListener('borderTopColor', _styleDecoratedChangedListener);
    style.addStyleChangeListener('borderRightColor', _styleDecoratedChangedListener);
    style.addStyleChangeListener('borderBottomColor', _styleDecoratedChangedListener);
    style.addStyleChangeListener('boxShadow', _styleDecoratedChangedListener);

    style.addStyleChangeListener('margin', _styleMarginChangedListener);
    style.addStyleChangeListener('marginLeft', _styleMarginChangedListener);
    style.addStyleChangeListener('marginTop', _styleMarginChangedListener);
    style.addStyleChangeListener('marginRight', _styleMarginChangedListener);
    style.addStyleChangeListener('marginBottom', _styleMarginChangedListener);

    style.addStyleChangeListener('opacity', _styleOpacityChangedListener);
    style.addStyleChangeListener('visibility', _styleOpacityChangedListener);
    style.addStyleChangeListener('transform', _styleTransformChangedListener);
    style.addStyleChangeListener('transition', _styleTransitionChangedListener);
  }

  void _styleDisplayChangedListener(String property, original, present) {
    // Display change may case width/height doesn't works at all.
    _styleSizeChangedListener(property, original, present);

    String display = style['display'];
    bool shouldRender = display != 'none';
    renderElementBoundary.shouldRender = shouldRender;

    if (renderLayoutBox != null) {
      String prevDisplay = isEmptyStyleValue(original) ? defaultDisplay : original;
      String currentDisplay = isEmptyStyleValue(present) ? defaultDisplay : present;
      if (prevDisplay != currentDisplay) {
        ContainerRenderObjectMixin prevRenderLayoutBox = renderLayoutBox;
        // Collect children of renderLayoutBox and remove their relationship.
        List<RenderBox> children = [];
        prevRenderLayoutBox
          ..visitChildren((child) {
            children.add(child);
          })
          ..removeAll();

        renderPadding.child = null;
        renderLayoutBox = createRenderLayoutBox(style, children);
        renderPadding.child = renderLayoutBox as RenderBox;
      }

      if (currentDisplay.endsWith('flex')) {
        // update flex layout properties
        decorateRenderFlex(renderLayoutBox, style);
      } else {
        // update flow layout properties
        decorateRenderFlow(renderLayoutBox, style);
      }
    }
  }

  void _stylePositionChangedListener(String property, original, present) {
    /// Update position.
    String prevPosition = isEmptyStyleValue(original) ? 'static' : original;
    String currentPosition = isEmptyStyleValue(present) ? 'static' : present;

    // Position changed.
    if (prevPosition != currentPosition) {
      needsReposition = true;
      _doUpdatePosition(prevPosition, currentPosition);
    } else if (currentPosition != 'static') {
      _updateZIndex();
    }
  }

  void _styleOffsetChangedListener(String property, original, present) {
    double _original = Length.toDisplayPortValue(original);

    _updateOffset(
      definiteTransition: transitionMap != null ? transitionMap[property] : null,
      property: property,
      original: _original,
      diff: Length.toDisplayPortValue(present) - _original,
    );
  }

  void _styleTextAlignChangedListener(String property, original, present) {
    _updateDecorationRenderLayoutBox();
  }

  void _updateDecorationRenderLayoutBox() {
    if (renderLayoutBox is RenderFlexLayout) {
      if (style['flexWrap'] == 'wrap') {
        decorateRenderFlow(renderLayoutBox, style);
      } else {
        decorateRenderFlex(renderLayoutBox, style);
      }
    } else if (renderLayoutBox is RenderFlowLayout) {
      decorateRenderFlow(renderLayoutBox, style);
    }
  }

  void _styleTransitionChangedListener(String property, original, present) {
    if (present != null) initTransition(style);
  }

  void _styleOverflowChangedListener(String property, original, present) {
    updateOverFlowBox(style, _scrollListener);
  }

  void _stylePaddingChangedListener(String property, original, present) {
    updateRenderPadding(style, transitionMap);
  }

  void _styleSizeChangedListener(String property, original, present) {
    // Update constrained box.
    updateConstraints(style, transitionMap);

    if (property == 'width' || property == 'height') {
      double _original = Length.toDisplayPortValue(original);
      _updateOffset(
        definiteTransition: transitionMap != null ? transitionMap[property] : null,
        property: property,
        original: _original,
        diff: Length.toDisplayPortValue(present) - _original,
      );
    }
  }

  void _styleMarginChangedListener(String property, original, present) {
    /// Update margin.
    updateRenderMargin(style, transitionMap);
  }

  void _styleFlexChangedListener(String property, original, present) {
    String display = isEmptyStyleValue(style['display'])
        ? defaultDisplay
        : style['display'];
    if (display.endsWith('flex')) {
      ContainerRenderObjectMixin prevRenderLayoutBox = renderLayoutBox;
      // Collect children of renderLayoutBox and remove their relationship.
      List<RenderBox> children = [];
      prevRenderLayoutBox
        ..visitChildren((child) {
          children.add(child);
        })
        ..removeAll();

      renderPadding.child = null;
      renderLayoutBox = createRenderLayoutBox(style, children);
      renderPadding.child = renderLayoutBox as RenderBox;

      this.children.forEach((Element child) {
        _updateFlexItemStyle(child);
      });
    }

    _updateDecorationRenderLayoutBox();
  }

  void _styleFlexItemChangedListener(String property, original, present) {
    String display = isEmptyStyleValue(style['display']) ? defaultDisplay : style['display'];
    if (display.endsWith('flex')) {
      children.forEach((Element child) {
        _updateFlexItemStyle(child);
      });
    }
  }

  void _styleDecoratedChangedListener(String property, original, present) {
    // Update decorated box.
    updateRenderDecoratedBox(style, transitionMap);
    if (shouldInitBackgroundImage(style)) {
      updateBackgroundImage(style, renderPadding, nodeId);
    }
  }

  void _styleOpacityChangedListener(String property, original, present) {
    // Update opacity and visibility.
    double opacity = isEmptyStyleValue(style['opacity'])
        ? 1.0
        : Length.toDouble(style['opacity']);
    if (property == 'visibility') {
      switch (present) {
        case 'hidden': opacity = 0; break;
      }
    }

    updateRenderOpacity(opacity, parentRenderObject: renderRepaintBoundary,);
  }

  void _styleTransformChangedListener(String property, original, present) {
    // Update transform.
    updateTransform(style, transitionMap);
  }

  // Update textNode style when container style changed
  void updateChildNodesStyle() {
    childNodes.forEach((node) {
      if (node is TextNode) node.updateTextStyle();
    });
  }

  // @TODO(refactor): Need to remove it.
  void _flushStyle() {
    if (transitionMap != null) {
      for (Transition transition in transitionMap.values) {
        transition?.apply();
      }
    }

    updateChildNodesStyle();
  }

// Universal style property change callback.
  @mustCallSuper
  void setStyle(String key, value) {
    // @NOTE: See [StyleDeclaration.setProperty], value change will trigger
    // [StyleChangeListener] to be invoked in sync.
    style[key] = value;
    _flushStyle();
  }

  @mustCallSuper
  void setProperty(String key, value) {
    properties[key] = value;

    // Each key change will emit to `setStyle`
    if (key == STYLE) {
      assert(value is Map<String, dynamic>);
      // @TODO: Consider `{ color: red }` to `{}`, need to remove invisible keys.
      (value as Map<String, dynamic>).forEach(setStyle);
    }
  }

  @mustCallSuper
  void removeProperty(String key) {
    properties.remove(key);

    if (key == STYLE) {
      setProperty(STYLE, null);
    }
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
      case 'scroll':
        return scroll(args);
      case 'scrollBy':
        return scroll(args, isScrollBy: true);
      default:
        debugPrint('Unknown method call. name: $name, args: ${args}');
    }
  }

  String getBoundingClientRect() {
    BoundingClientRect boundingClientRect;

    if (isConnected) {
      // Force flush layout.
      if (!renderBorderHolder.hasSize) {
        renderBorderHolder.markNeedsLayout();
        renderBorderHolder.owner.flushLayout();
      }

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
      // HitTest will test rootView's every child (including
      // child's child), so must flush rootView every times,
      // or child may miss size.
      RendererBinding.instance.renderView.owner.flushLayout();

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

bool _isPositioned(StyleDeclaration style) {
  if (style.contains('position')) {
    String position = style['position'];
    return position != 'static' && position != 'relative';
  } else {
    return false;
  }
}

bool _isSticky(StyleDeclaration style) {
  return style['position'] == 'sticky' && style.contains('top') ||
      style.contains('bottom');
}

ZIndexParentData getPositionParentDataFromStyle(StyleDeclaration style) {
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
  parentData.zIndex = Length.toInt(style['zIndex']);
  return parentData;
}

