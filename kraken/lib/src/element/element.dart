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
import 'package:kraken/css.dart';
import 'package:meta/meta.dart';

import 'event_handler.dart';
import 'bounding_client_rect.dart';

typedef TestElement = bool Function(Element element);

class Element extends Node
    with
        NodeLifeCycle,
        EventHandlerMixin,
        CSSTextMixin,
        CSSBackgroundMixin,
        CSSDecoratedBoxMixin,
        CSSSizingMixin,
        CSSFlexboxMixin,
        CSSAlignMixin,
        CSSOverflowMixin,
        CSSOpacityMixin,
        CSSTransformMixin,
        CSSVisibilityMixin,
        CSSContentVisibilityMixin,
        CSSTransitionMixin {
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

  // After `this` created, useful to set default properties, override this for individual element.
  void afterConstruct() {}

  // Style declaration from user.
  CSSStyleDeclaration style;

  // A point reference to treed renderObject.
  RenderObject renderObject;
  RenderConstrainedBox renderConstrainedBox;
  RenderObject stickyPlaceholder;
  RenderRepaintBoundary renderRepaintBoundary;
  RenderStack renderStack;
  ContainerRenderObjectMixin renderLayoutBox;
  RenderPadding renderPadding;
  RenderIntersectionObserver renderIntersectionObserver;
  // The boundary of an Element, can be used to logic distinguish difference element
  RenderElementBoundary renderElementBoundary;
  // Placeholder renderObject of positioned element(absolute/fixed)
  // used to get original coordinate before move away from document flow
  RenderObject renderPositionedPlaceholder;

  // Horizontal margin dimension (left + right)
  double get cropMarginWidth => renderMargin.margin.horizontal;
  // Vertical margin dimension (top + bottom)
  double get cropMarginHeight => renderMargin.margin.vertical;
  // Horizontal padding dimension (left + right)
  double get cropPaddingWidth => renderPadding.padding.horizontal;
  // Vertical padding dimension (top + bottom)
  double get cropPaddingHeight => renderPadding.padding.vertical;
  // Horizontal border dimension (left + right)
  double get cropBorderWidth => renderBorderHolder.margin.horizontal;
  // Vertical border dimension (top + bottom)
  double get cropBorderHeight => renderBorderHolder.margin.vertical;

  Element({
    @required int targetId,
    @required this.tagName,
    this.defaultDisplay = 'block',
    this.properties = const {},
    this.events = const [],
    this.needsReposition = false,
    this.allowChildren = true,
  })  : assert(targetId != null),
        assert(tagName != null),
        super(NodeType.ELEMENT_NODE, targetId, tagName) {
    if (properties == null) properties = {};
    if (events == null) events = [];

    afterConstruct();
    style = CSSStyleDeclaration(style: properties[STYLE]);

    _registerStyleChangedListeners();

    // Mark element needs to reposition according to position CSS.
    if (_isPositioned(style)) needsReposition = true;

    if (allowChildren) {
      // Content children layout, BoxModel content.
      renderObject = renderLayoutBox = createRenderLayoutBox(style, null);
    }

    // Background image
    renderObject = initBackground(renderObject, style, targetId);

    // BoxModel Padding
    renderObject = renderPadding = initRenderPadding(renderObject, style);

    // Overflow
    if (allowChildren) {
      renderObject = initOverflowBox(renderObject, style, _scrollListener);
    }

    // BoxModel Border
    renderObject = initRenderDecoratedBox(renderObject, style, targetId);

    // Constrained box
    renderObject =
        renderConstrainedBox = initRenderConstrainedBox(renderObject, style);

    // Positioned boundary
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

    // Opacity
    renderObject = initRenderOpacity(renderObject, style);

    // Content Visibility
    renderObject = initRenderContentVisibility(renderObject, style);

    // Intersection observer
    renderObject = renderIntersectionObserver =
        RenderIntersectionObserver(child: renderObject);

    setContentVisibilityIntersectionObserver(
        renderIntersectionObserver, style['contentVisibility']);

    // Visibility
    renderObject = initRenderVisibility(renderObject, style);

    // RenderRepaintBoundary to support toBlob.
    renderObject =
        renderRepaintBoundary = RenderRepaintBoundary(child: renderObject);

    // BoxModel Margin
    renderObject = initRenderMargin(renderObject, style);

    // The layout boundary of element.
    renderObject =
        renderElementBoundary = initTransform(renderObject, style, targetId);

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
      CSSStyleDeclaration elStyle = el.style;
      bool isFixed;

      if (el.offsetTop == null) {
        double offsetTop = el.getOffsetY();
        // save element original offset to viewport
        el.offsetTop = offsetTop;
      }

      if (elStyle.contains('top')) {
        double top = CSSSizingMixin.getDisplayPortedLength(elStyle['top']);
        isFixed = el.offsetTop - scrollTop <= top;
      } else if (elStyle.contains('bottom')) {
        double bottom =
            CSSSizingMixin.getDisplayPortedLength(elStyle['bottom']);
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
        ContainerRenderObjectMixin parentRenderObject =
            renderElementBoundary.parent;
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
                preNonPositionedElement.targetId == child.targetId) {
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
      ContainerRenderObjectMixin stickyPlaceholderParent =
          stickyPlaceholder.parent;
      stickyPlaceholderParent.remove(stickyPlaceholder);
    }
  }

  void insertStickyPlaceholder() {
    if (!renderMargin.hasSize) {
      renderMargin.owner.flushLayout();
    }

    CSSStyleDeclaration pStyle = CSSStyleDeclaration(style: {
      'width': renderMargin.size.width.toString() + 'px',
      'height': renderMargin.size.height.toString() + 'px',
    });
    stickyPlaceholder = initRenderConstrainedBox(stickyPlaceholder, pStyle);
    stickyPlaceholder =
        initRenderDecoratedBox(stickyPlaceholder, pStyle, targetId);
    (renderObject.parent as ContainerRenderObjectMixin)
        .insert(stickyPlaceholder, after: renderObject);
  }

  // reposition element with position absolute/fixed
  void _repositionElement(Element el) {
    RenderObject renderObject = el.renderObject;
    CSSStyleDeclaration style = el.style;
    int targetId = el.targetId;

    // new node not in the tree, wait for append in appendedElement
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

    Element currentElement = getEventTargetByTargetId<Element>(targetId);

    // current element's zIndex
    int currentZIndex = CSSLength.toInt(currentElement.style['zIndex']);
    // add current element back to parent stack by zIndex
    insertByZIndex(parentStack, el, currentZIndex);
  }

  void _updateZIndex() {
    // new node not in the tree, wait for append in appendedElement
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
    int currentZIndex = CSSLength.toInt(style['zIndex']);
    // add current element back to parent stack by zIndex
    insertByZIndex(parentStack, this, currentZIndex);
  }

  void _updateOffset(
      {CSSTransition definiteTransition,
      String property,
      double diff,
      double original}) {
    ZIndexParentData zIndexParentData;
    RenderBox renderParent = renderElementBoundary.parent;
    if (renderParent is RenderPosition &&
        renderElementBoundary.parentData is ZIndexParentData) {
      zIndexParentData = renderElementBoundary.parentData;
      ZIndexParentData progressParentData = zIndexParentData;

      CSSTransition allTransition;
      if (transitionMap != null) {
        allTransition = transitionMap['all'];
      }

      if (definiteTransition != null || allTransition != null) {
        assert(diff != null);
        assert(original != null);

        CSSTransitionProgressListener progressListener = (percent) {
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
        if (style.contains('zIndex')) {
          zIndexParentData.zIndex = CSSLength.toInt(style['zIndex']);
          ;
        }
        if (style.contains('top')) {
          zIndexParentData.top = CSSLength.toDisplayPortValue(style['top']);
        }
        if (style.contains('left')) {
          zIndexParentData.left = CSSLength.toDisplayPortValue(style['left']);
        }
        if (style.contains('right')) {
          zIndexParentData.right = CSSLength.toDisplayPortValue(style['right']);
        }
        if (style.contains('bottom')) {
          zIndexParentData.bottom =
              CSSLength.toDisplayPortValue(style['bottom']);
        }
        if (style.contains('width')) {
          zIndexParentData.width = CSSLength.toDisplayPortValue(style['width']);
        }
        if (style.contains('height')) {
          zIndexParentData.height =
              CSSLength.toDisplayPortValue(style['height']);
        }
        renderObject.parentData = zIndexParentData;
        renderParent.markNeedsLayout();
      }
    }
  }

  Element getElementById(Element parentElement, int targetId) {
    Element result = null;
    List childNodes = parentElement.childNodes;

    for (int i = 0; i < childNodes.length; i++) {
      Element element = childNodes[i];
      if (element.targetId == targetId) {
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
      CSSStyleDeclaration style, List<RenderBox> children) {
    String display =
        isEmptyStyleValue(style['display']) ? defaultDisplay : style['display'];
    String flexWrap = style['flexWrap'];
    bool isFlexWrap = display.endsWith('flex') && flexWrap == 'wrap';
    if (display.endsWith('flex') && flexWrap != 'wrap') {
      ContainerRenderObjectMixin flexLayout = RenderFlexLayout(
        textDirection: TextDirection.ltr,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: children,
        style: style,
        targetId: targetId,
      );
      decorateRenderFlex(flexLayout, style);
      return flexLayout;
    } else if (display == 'none' ||
        display == 'inline' ||
        display == 'inline-block' ||
        display == 'block' ||
        isFlexWrap) {
      ContainerRenderObjectMixin flowLayout = RenderFlowLayout(
        children: children,
        style: style,
        targetId: targetId,
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
    // Remove child from its parent first
    if (child.parent != null) {
      child.parent.removeChild(child);
    }

    super.appendChild(child);

    VoidCallback doAppendChild = () {
      // Only append node types which is visible in RenderObject tree
      if (child is NodeLifeCycle) {
        // Only append child's renderObject when it has no parent
        RenderObject childNodeParent = (child as Element).renderObject.parent;
        if (childNodeParent == null) {
          appendChildNode(child);
        }
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
    // Only remove child's renderObject when it has parent
    RenderObject childNodeParent = (child as Element).renderObject.parent;
    if (child is NodeLifeCycle && childNodeParent != null) {
      removeChildNode(child);
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
        appendChildNode(child,
            afterRenderObject: afterRenderObject, isAppend: false);
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

  void removeChildNode(Node child) {
    if (child is TextNode) {
      renderLayoutBox.remove(child.renderTextBox);
    } else if (child is Element) {
      AbstractNode childParentNode = child.renderElementBoundary.parent;
      if (childParentNode == renderLayoutBox) {
        renderLayoutBox.remove(child.renderElementBoundary);
      } else if (childParentNode == renderStack) {
        renderStack.remove(child.renderElementBoundary);
      } else {
        // Fixed or sticky.
        final RenderStack rootRenderStack =
            ElementManager().getRootElement().renderStack;
        if (childParentNode == rootRenderStack) {
          rootRenderStack.remove(child.renderElementBoundary);
        }
      }
    }
  }

  // Store placeholder renderObject reference to parentData of element boundary
  // to enable access from parent RenderStack
  RenderBox getStackedRenderBox(Element element) {
    // Positioned element in flex layout will reposition in new layer
    if (renderLayoutBox is RenderFlexLayout) {
      String width =
          element.style['width'] != '' ? element.style['width'] : '0';
      String height =
          element.style['height'] != '' ? element.style['height'] : '0';
      CSSStyleDeclaration placeholderStyle = CSSStyleDeclaration(style: {
        'width': width,
        'height': height,
      });
      renderPositionedPlaceholder =
          initRenderConstrainedBox(null, placeholderStyle);
    } else {
      // Positioned element in flow layout will position in old flow layer
      renderPositionedPlaceholder = RenderPadding(padding: EdgeInsets.zero);
    }

    ZIndexParentData stackParentData =
        getPositionParentDataFromStyle(element.style);
    RenderBox stackedRenderBox = element.renderObject as RenderBox;
    stackParentData.hookRenderObject = renderPositionedPlaceholder;
    stackedRenderBox.parentData = stackParentData;
    return stackedRenderBox;
  }

  // Add placeholder to positioned element for calculate original
  // coordinate before moved away
  void addPositionPlaceholder() {
    if (renderPositionedPlaceholder == null ||
        !renderPositionedPlaceholder.attached) {
      addChild(renderPositionedPlaceholder);
    }
  }

  void appendChildNode(Node child,
      {RenderObject afterRenderObject, bool isAppend = true}) {
    if (child is Element) {
      RenderObject childRenderObject = child.renderObject;
      CSSStyleDeclaration childStyle = child.style;
      String childPosition =
          childStyle['position'] == '' ? 'static' : childStyle['position'];
      String display = isEmptyStyleValue(style['display'])
          ? defaultDisplay
          : style['display'];
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
          insertByZIndex(parentStackedElement.renderStack, child,
              CSSLength.toInt(childStyle['zIndex']));
          return;
        }
      } else if (childPosition == 'fixed') {
        final RenderPosition rootRenderStack =
            ElementManager().getRootElement().renderStack;
        if (rootRenderStack != null) {
          insertByZIndex(
              rootRenderStack, child, CSSLength.toInt(childStyle['zIndex']));
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
      RenderFlexParentData flexParentData =
          CSSFlexItem.getParentData(element.style);
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
    style.addStyleChangeListener('minWidth', _styleSizeChangedListener);
    style.addStyleChangeListener('maxWidth', _styleSizeChangedListener);
    style.addStyleChangeListener('height', _styleSizeChangedListener);
    style.addStyleChangeListener('minHeight', _styleSizeChangedListener);
    style.addStyleChangeListener('maxHeight', _styleSizeChangedListener);

    style.addStyleChangeListener('overflow', _styleOverflowChangedListener);
    style.addStyleChangeListener('overflowX', _styleOverflowChangedListener);
    style.addStyleChangeListener('overflowY', _styleOverflowChangedListener);

    style.addStyleChangeListener('background', _styleBackgroundChangedListener);
    style.addStyleChangeListener(
        'backgroundColor', _styleBackgroundChangedListener);
    style.addStyleChangeListener(
        'backgroundAttachment', _styleBackgroundChangedListener);
    style.addStyleChangeListener(
        'backgroundImage', _styleBackgroundChangedListener);
    style.addStyleChangeListener(
        'backgroundRepeat', _styleBackgroundChangedListener);
    style.addStyleChangeListener(
        'backgroundSize', _styleBackgroundChangedListener);
    style.addStyleChangeListener(
        'backgroundPosition', _styleBackgroundChangedListener);

    style.addStyleChangeListener('border', _styleDecoratedChangedListener);
    style.addStyleChangeListener('borderTop', _styleDecoratedChangedListener);
    style.addStyleChangeListener('borderLeft', _styleDecoratedChangedListener);
    style.addStyleChangeListener('borderRight', _styleDecoratedChangedListener);
    style.addStyleChangeListener(
        'borderBottom', _styleDecoratedChangedListener);
    style.addStyleChangeListener('borderWidth', _styleDecoratedChangedListener);
    style.addStyleChangeListener(
        'borderLeftWidth', _styleDecoratedChangedListener);
    style.addStyleChangeListener(
        'borderTopWidth', _styleDecoratedChangedListener);
    style.addStyleChangeListener(
        'borderRightWidth', _styleDecoratedChangedListener);
    style.addStyleChangeListener(
        'borderBottomWidth', _styleDecoratedChangedListener);
    style.addStyleChangeListener(
        'borderRadius', _styleDecoratedChangedListener);
    style.addStyleChangeListener(
        'borderTopLeftRadius', _styleDecoratedChangedListener);
    style.addStyleChangeListener(
        'borderTopRightRadius', _styleDecoratedChangedListener);
    style.addStyleChangeListener(
        'borderBottomLeftRadius', _styleDecoratedChangedListener);
    style.addStyleChangeListener(
        'borderBottomRightRadius', _styleDecoratedChangedListener);
    style.addStyleChangeListener('borderStyle', _styleDecoratedChangedListener);
    style.addStyleChangeListener(
        'borderLeftStyle', _styleDecoratedChangedListener);
    style.addStyleChangeListener(
        'borderTopStyle', _styleDecoratedChangedListener);
    style.addStyleChangeListener(
        'borderRightStyle', _styleDecoratedChangedListener);
    style.addStyleChangeListener(
        'borderBottomStyle', _styleDecoratedChangedListener);
    style.addStyleChangeListener('borderColor', _styleDecoratedChangedListener);
    style.addStyleChangeListener(
        'borderLeftColor', _styleDecoratedChangedListener);
    style.addStyleChangeListener(
        'borderTopColor', _styleDecoratedChangedListener);
    style.addStyleChangeListener(
        'borderRightColor', _styleDecoratedChangedListener);
    style.addStyleChangeListener(
        'borderBottomColor', _styleDecoratedChangedListener);
    style.addStyleChangeListener('boxShadow', _styleDecoratedChangedListener);

    style.addStyleChangeListener('margin', _styleMarginChangedListener);
    style.addStyleChangeListener('marginLeft', _styleMarginChangedListener);
    style.addStyleChangeListener('marginTop', _styleMarginChangedListener);
    style.addStyleChangeListener('marginRight', _styleMarginChangedListener);
    style.addStyleChangeListener('marginBottom', _styleMarginChangedListener);

    style.addStyleChangeListener('opacity', _styleOpacityChangedListener);
    style.addStyleChangeListener('visibility', _styleVisibilityChangedListener);
    style.addStyleChangeListener(
        'contentVisibility', _styleContentVisibilityChangedListener);
    style.addStyleChangeListener('transform', _styleTransformChangedListener);
    style.addStyleChangeListener(
        'transformOrigin', _styleTransformOriginChangedListener);
    style.addStyleChangeListener('transition', _styleTransitionChangedListener);
    style.addStyleChangeListener(
        'transitionProperty', _styleTransitionChangedListener);
    style.addStyleChangeListener(
        'transitionDuration', _styleTransitionChangedListener);
    style.addStyleChangeListener(
        'transitionTimingFunction', _styleTransitionChangedListener);
    style.addStyleChangeListener(
        'transitionDelay', _styleTransitionChangedListener);
  }

  void _styleDisplayChangedListener(
      String property, String original, String present) {
    // Display change may case width/height doesn't works at all.
    _styleSizeChangedListener(property, original, present);

    bool shouldRender = present != 'none';
    renderElementBoundary.shouldRender = shouldRender;

    if (renderLayoutBox != null) {
      String prevDisplay =
          isEmptyStyleValue(original) ? defaultDisplay : original;
      String currentDisplay =
          isEmptyStyleValue(present) ? defaultDisplay : present;
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

  void _stylePositionChangedListener(
      String property, String original, String present) {
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

  void _styleOffsetChangedListener(
      String property, String original, String present) {
    double _original = CSSLength.toDisplayPortValue(original);

    _updateOffset(
      definiteTransition:
          transitionMap != null ? transitionMap[property] : null,
      property: property,
      original: _original,
      diff: CSSLength.toDisplayPortValue(present) - _original,
    );
  }

  void _styleTextAlignChangedListener(
      String property, String original, String present) {
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

  void _styleTransitionChangedListener(
      String property, String original, String present) {
    if (present != null) initTransition(style, property);
  }

  void _styleOverflowChangedListener(
      String property, String original, String present) {
    updateOverFlowBox(style, _scrollListener);
  }

  void _stylePaddingChangedListener(
      String property, String original, String present) {
    updateRenderPadding(style, transitionMap);
  }

  void _styleSizeChangedListener(
      String property, String original, String present) {
    // Update constrained box.
    updateConstraints(style, transitionMap);

    if (property == 'width' || property == 'height') {
      double _original = CSSLength.toDisplayPortValue(original);
      _updateOffset(
        definiteTransition:
            transitionMap != null ? transitionMap[property] : null,
        property: property,
        original: _original,
        diff: CSSLength.toDisplayPortValue(present) - _original,
      );
    }
  }

  void _styleMarginChangedListener(
      String property, String original, String present) {
    /// Update margin.
    updateRenderMargin(style, transitionMap);
  }

  void _styleFlexChangedListener(
      String property, String original, String present) {
    String display =
        isEmptyStyleValue(style['display']) ? defaultDisplay : style['display'];
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

  void _styleFlexItemChangedListener(
      String property, String original, String present) {
    String display =
        isEmptyStyleValue(style['display']) ? defaultDisplay : style['display'];
    if (display.endsWith('flex')) {
      children.forEach((Element child) {
        _updateFlexItemStyle(child);
      });
    }
  }

  // background may exist on the decoratedBox or single box, because the attachment
  void _styleBackgroundChangedListener(
      String property, String original, String present) {
    updateBackground(property, present, renderPadding, targetId);
    // decoratedBox may contains background and border
    updateRenderDecoratedBox(style, transitionMap);
  }

  void _styleDecoratedChangedListener(
      String property, String original, String present) {
    // Update decorated box.
    updateRenderDecoratedBox(style, transitionMap);
  }

  void _styleOpacityChangedListener(
      String property, String original, String present) {
    // Update opacity.
    updateRenderOpacity(present, parentRenderObject: renderRepaintBoundary);
  }

  void _styleVisibilityChangedListener(
      String property, String original, String present) {
    // Update visibility.
    updateRenderVisibility(present, parentRenderObject: renderRepaintBoundary);
  }

  void _styleContentVisibilityChangedListener(
      String property, original, present) {
    // Update content visibility.
    updateRenderContentVisibility(present,
        parentRenderObject: renderIntersectionObserver,
        renderIntersectionObserver: renderIntersectionObserver);
  }

  void _styleTransformChangedListener(
      String property, String original, String present) {
    // Update transform.
    updateTransform(present, transitionMap);
  }

  void _styleTransformOriginChangedListener(
      String property, String original, String present) {
    // Update transform.
    updateTransformOrigin(present, transitionMap);
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
      for (CSSTransition transition in transitionMap.values) {
        initTransitionEvent(transition);
        transition?.apply();
      }
    }

    updateChildNodesStyle();
  }

  // Universal style property change callback.
  @mustCallSuper
  void setStyle(String key, value) {
    // @NOTE: See [CSSStyleDeclaration.setProperty], value change will trigger
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
  dynamic getProperty(String key) {
    return properties[key];
  }

  @mustCallSuper
  void removeProperty(String key) {
    properties.remove(key);

    if (key == STYLE) {
      setProperty(STYLE, null);
    }
  }

  @mustCallSuper
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

  @override
  void addEvent(String eventName) {
    if (eventHandlers.containsKey(eventName)) return; // Only listen once.
    bool isIntersectionObserverEvent = _isIntersectionObserverEvent(eventName);
    bool hasIntersectionObserverEvent = isIntersectionObserverEvent &&
        _hasIntersectionObserverEvent(eventHandlers);
    super.addEventListener(eventName, _eventResponder);

    // Only add listener once for all intersection related event
    if (isIntersectionObserverEvent && !hasIntersectionObserverEvent) {
      renderIntersectionObserver.addListener(handleIntersectionChange);
    }
  }

  void removeEvent(String eventName) {
    if (!eventHandlers.containsKey(eventName)) return; // Only listen once.
    super.removeEventListener(eventName, _eventResponder);

    // Remove listener when no intersection related event
    if (_isIntersectionObserverEvent(eventName) &&
        !_hasIntersectionObserverEvent(eventHandlers)) {
      renderIntersectionObserver.removeListener(handleIntersectionChange);
    }
  }

  void _eventResponder(Event event) {
    String json = jsonEncode([targetId, event]);
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
          hitTest = currentElement.renderElementBoundary
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

    // Make sure renderObjects has been repainted.
    renderObject.markNeedsPaint();
    RendererBinding.instance.addPostFrameCallback((_) async {
      if (renderRepaintBoundary.size == Size.zero) {
        // Return a blob with zero length.
        completer.complete(Uint8List(0));
      } else {
        Image image =
            await renderRepaintBoundary.toImage(pixelRatio: devicePixelRatio);
        ByteData byteData = await image.toByteData(format: ImageByteFormat.png);
        completer.complete(byteData.buffer.asUint8List());
      }
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

bool _isPositioned(CSSStyleDeclaration style) {
  if (style.contains('position')) {
    String position = style['position'];
    return position != 'static' && position != 'relative';
  } else {
    return false;
  }
}

bool _isSticky(CSSStyleDeclaration style) {
  return style['position'] == 'sticky' && style.contains('top') ||
      style.contains('bottom');
}

ZIndexParentData getPositionParentDataFromStyle(CSSStyleDeclaration style) {
  ZIndexParentData parentData = ZIndexParentData();

  if (style.contains('top')) {
    parentData..top = CSSLength.toDisplayPortValue(style['top']);
  }
  if (style.contains('left')) {
    parentData..left = CSSLength.toDisplayPortValue(style['left']);
  }
  if (style.contains('bottom')) {
    parentData..bottom = CSSLength.toDisplayPortValue(style['bottom']);
  }
  if (style.contains('right')) {
    parentData..right = CSSLength.toDisplayPortValue(style['right']);
  }
  parentData.width = CSSLength.toDisplayPortValue(style['width']);
  parentData.height = CSSLength.toDisplayPortValue(style['height']);
  parentData.zIndex = CSSLength.toInt(style['zIndex']);
  return parentData;
}
