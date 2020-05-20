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

/// Defined by W3C Standard,
/// Most elements's default width is 300 in pixel,
/// height is 150 in pixel.
const String ELEMENT_DEFAULT_WIDTH = '300px';
const String ELEMENT_DEFAULT_HEIGHT = '150px';

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

  final Map<String, dynamic> defaultStyle;

  /// The default display type of
  String defaultDisplay;

  // After `this` created, useful to set default properties, override this for individual element.
  void afterConstruct() {}

  // Style declaration from user.
  CSSStyleDeclaration style;

  // A point reference to treed renderObject.
  RenderObject renderObject;
  RenderConstrainedBox renderConstrainedBox;
  RenderDecoratedBox stickyPlaceholder;
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
  double get cropBorderWidth => renderDecoratedBox.borderEdge.horizontal;
  // Vertical border dimension (top + bottom)
  double get cropBorderHeight => renderDecoratedBox.borderEdge.vertical;

  Element({
    @required int targetId,
    @required this.tagName,
    this.defaultStyle = const {},
    this.events = const [],
    this.needsReposition = false,
    this.allowChildren = true,
  })  : assert(targetId != null),
        assert(tagName != null),
        super(NodeType.ELEMENT_NODE, targetId, tagName) {
    if (properties == null) properties = {};
    if (events == null) events = [];

    defaultDisplay = defaultStyle.containsKey('display') ? defaultStyle['display'] : 'block';
    style = CSSStyleDeclaration(style: defaultStyle);

    _registerStyleChangedListeners();

    // Mark element needs to reposition according to position CSS.
    if (_isPositioned(style)) needsReposition = true;

    if (allowChildren) {
      // Content children layout, BoxModel content.
      renderObject = renderLayoutBox = createRenderLayoutBox(style);
    }

    // Background image
    renderObject = initBackground(renderObject, style, targetId);

    // BoxModel Padding
    renderObject = renderPadding = initRenderPadding(renderObject, style);

    // Overflow
    renderObject = initOverflowBox(renderObject, style, _scrollListener);

    // BoxModel Border
    renderObject = initRenderDecoratedBox(renderObject, style, targetId);

    // Constrained box
    renderObject = renderConstrainedBox = initRenderConstrainedBox(renderObject, style);

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
    renderObject = renderIntersectionObserver = RenderIntersectionObserver(child: renderObject);

    setContentVisibilityIntersectionObserver(renderIntersectionObserver, style['contentVisibility']);

    // Visibility
    renderObject = initRenderVisibility(renderObject, style);

    // BoxModel Margin
    renderObject = initRenderMargin(renderObject, style);

    // The layout boundary of element.
    renderObject = renderElementBoundary = initTransform(renderObject, style, targetId);

    // Build root render stack.
    if (targetId == BODY_ID) {
      _buildRenderStack();
    }
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
        double bottom = CSSSizingMixin.getDisplayPortedLength(elStyle['bottom']);
        double viewPortHeight = renderMargin?.size?.height;
        double elViewPortTop = el.offsetTop - scrollTop;
        isFixed = viewPortHeight - elViewPortTop <= bottom;
      }
      if (isFixed) {
        // change to fixed behavior
        if (!el.stickyFixed) {
          el.stickyFixed = true;
          el._updatePosition(resolvePositionFromStyle(el.style), CSSPositionType.fixed);
        }
      } else {
        // change to relative behavior
        if (el.stickyFixed) {
          el.stickyFixed = false;
          el._updatePosition(resolvePositionFromStyle(el.style), CSSPositionType.sticky);
        }
      }
    });
  }

  void _buildRenderStack() {
    if (renderStack != null) return;

    List<RenderBox> shouldStackedChildren = [renderDecoratedBox.child];
    renderDecoratedBox.child = null;

    children.forEach((element) {
      if (_isPositioned(element.style)) {
        RenderElementBoundary child = element.renderElementBoundary;
        // Parent should be one of RenderFlowLayout or RenderFlexLayout,
        // Only move attached child.
        // @TODO: can be optimized by common abstract class.
        if (child.attached) {
          (child.parent as ContainerRenderObjectMixin).remove(child);
          shouldStackedChildren.add(child);
        }
      }
    });

    renderStack = RenderPosition(
      textDirection: TextDirection.ltr,
      fit: StackFit.passthrough,
      overflow: Overflow.visible,
      children: shouldStackedChildren,
    );
    renderDecoratedBox.child = renderStack;
  }

  void _dropRenderStack() {
    if (renderStack == null) return;

    RenderBox originalChild = renderStack.firstChild;
    renderStack.remove(originalChild);
    (renderStack.parent as RenderObjectWithChildMixin).child = originalChild;

    if (renderStack.childCount > 0) {
      Element parentPositionedElement = findParent(this, (el) => el.renderStack != null);
      List<RenderBox> stackedChildren = renderStack.getChildrenAsList();
      for (var stackedChild in stackedChildren) {
        renderStack.dropChild(stackedChild);
        parentPositionedElement.renderStack?.add(stackedChild);
      }
    }

    renderStack = null;
  }

  void _updatePosition(CSSPositionType prevPosition, CSSPositionType currentPosition) {
    if (renderElementBoundary.parentData is PositionParentData) {
      (renderElementBoundary.parentData as PositionParentData).position = currentPosition;
    }

    // Remove stack node when change to non positioned.
    if (currentPosition == CSSPositionType.static) {
      _dropRenderStack();
    } else {
      // Add stack node when change to positioned.
      _buildRenderStack();
    }
  }

  void removeStickyPlaceholder() {
    if (stickyPlaceholder != null) {
      ContainerRenderObjectMixin stickyPlaceholderParent = stickyPlaceholder.parent;
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
    stickyPlaceholder = initRenderDecoratedBox(stickyPlaceholder, pStyle, targetId);
    (renderObject.parent as ContainerRenderObjectMixin).insert(stickyPlaceholder, after: renderObject);
  }

  void _updateOffset({CSSTransition definiteTransition, String property, double diff, double original}) {
    PositionParentData positionParentData;
    RenderBox renderParent = renderElementBoundary.parent;
    if (renderParent is RenderPosition && renderElementBoundary.parentData is PositionParentData) {
      positionParentData = renderElementBoundary.parentData;
      PositionParentData progressParentData = positionParentData;

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
          positionParentData.zIndex = CSSLength.toInt(style['zIndex']);
          ;
        }
        if (style.contains('top')) {
          positionParentData.top = CSSLength.toDisplayPortValue(style['top']);
        }
        if (style.contains('left')) {
          positionParentData.left = CSSLength.toDisplayPortValue(style['left']);
        }
        if (style.contains('right')) {
          positionParentData.right = CSSLength.toDisplayPortValue(style['right']);
        }
        if (style.contains('bottom')) {
          positionParentData.bottom = CSSLength.toDisplayPortValue(style['bottom']);
        }
        if (style.contains('width')) {
          positionParentData.width = CSSLength.toDisplayPortValue(style['width']);
        }
        if (style.contains('height')) {
          positionParentData.height = CSSLength.toDisplayPortValue(style['height']);
        }
        renderObject.parentData = positionParentData;
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

  ContainerRenderObjectMixin createRenderLayoutBox(CSSStyleDeclaration style, {List<RenderBox> children}) {
    String display = isEmptyStyleValue(style['display']) ? defaultDisplay : style['display'];
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
  bool get attached => renderElementBoundary.attached;

  // Attach renderObject of current node to parent
  @override
  void attachTo(Element parent, {RenderObject after}) {
    CSSPositionType positionType = resolvePositionFromStyle(style);
    CSSStyleDeclaration parentStyle = parent.style;
    String parentDisplay = isEmptyStyleValue(parentStyle['display']) ? parent.defaultDisplay : parentStyle['display'];
    bool isParentFlex = parentDisplay.endsWith('flex');

    // Add FlexItem wrap for flex child node.
    if (isParentFlex && renderLayoutBox != null) {
      renderPadding.child = null;
      renderPadding.child = RenderFlexItem(child: renderLayoutBox as RenderBox);
    }

    switch (positionType) {
      case CSSPositionType.relative:
      case CSSPositionType.absolute:
      case CSSPositionType.fixed:
        parent._addPositionedChild(this, positionType);
        break;
      case CSSPositionType.sticky:
        parent._addStickyChild(this, positionType);
        break;
      case CSSPositionType.static:
        parent.renderLayoutBox.insert(renderElementBoundary, after: after);
        break;
    }

    /// Update flex siblings.
    if (isParentFlex) parent.children.forEach(_updateFlexItemStyle);
  }

  // Detach renderObject of current node from parent
  @override
  void detach() {
    // Remove element's placeholder RenderObject if exists
    PositionParentData parentData = renderElementBoundary.parentData;
    if (parentData.originalRenderBoxRef != null) {
      ContainerRenderObjectMixin placeholderParent = parentData.originalRenderBoxRef.parent;
      placeholderParent.remove(parentData.originalRenderBoxRef);
    }

    AbstractNode parentRenderObject = renderObject.parent;
    if (parentRenderObject == parent.renderLayoutBox) {
      parent.renderLayoutBox.remove(renderElementBoundary);
    } else if (parentRenderObject == parent.renderStack) {
      parent.renderStack.remove(renderElementBoundary);
    } else {
      // Fixed or sticky.
      final RenderStack rootRenderStack = ElementManager().getRootElement().renderStack;
      if (parent == rootRenderStack) {
        rootRenderStack.remove(renderElementBoundary);
      }
    }
  }

  @override
  @mustCallSuper
  Node appendChild(Node child) {
    assert(allowChildren, 'The element($this) does not support child.');
    super.appendChild(child);

    VoidCallback doAppendChild = () {
      // Only append node types which is visible in RenderObject tree
      if (child is NodeLifeCycle) {
        _append(child, after: renderLayoutBox.lastChild);
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
    // Only remove childNode when it has parent
    if (child is NodeLifeCycle && child.attached) {
      child.detach();
    }

    super.removeChild(child);
    return child;
  }

  @override
  @mustCallSuper
  Node insertBefore(Node child, Node referenceNode) {
    assert(allowChildren, 'The element($this) does not support child.');
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
        _append(child, after: afterRenderObject);
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

  // Store placeholder renderObject reference to parentData of element boundary
  // to enable access from parent RenderStack
  RenderBox getStackedRenderBox(Element element) {
    CSSPositionType positionType = resolvePositionFromStyle(element.style);
    // Positioned element in flex layout will reposition in new layer
    if (renderLayoutBox is RenderFlexLayout) {
      Size preferredSize =
          Size(CSSLength.toDisplayPortValue(element.style[WIDTH]), CSSLength.toDisplayPortValue(element.style[HEIGHT]));

      renderPositionedPlaceholder = RenderPositionHolder(preferredSize: preferredSize, positionType: positionType);
    } else {
      // Positioned element in flow layout will position in old flow layer
      renderPositionedPlaceholder = RenderPositionHolder(preferredSize: Size.zero, positionType: positionType);
    }

    RenderBox stackedRenderBox = element.renderObject as RenderBox;
    stackedRenderBox.parentData = getPositionParentDataFromStyle(element.style, renderPositionedPlaceholder);
    return stackedRenderBox;
  }

  // Add placeholder to positioned element for calculate original
  // coordinate before moved away
  void addPositionPlaceholder() {
    if (renderPositionedPlaceholder == null || !renderPositionedPlaceholder.attached) {
      addChild(renderPositionedPlaceholder);
    }
  }

  void _addPositionedChild(Element child, CSSPositionType position) {
    RenderPosition parentRenderPosition;
    switch (position) {
      case CSSPositionType.relative:
        // Ensure renderStack exists.
        _buildRenderStack();
        parentRenderPosition = renderStack;
        break;

      case CSSPositionType.absolute:
        Element parentStackedElement = findParent(child, (element) => element.renderStack != null);
        parentRenderPosition = parentStackedElement.renderStack;
        break;

      case CSSPositionType.fixed:
        final Element rootEl = ElementManager().getRootElement();
        parentRenderPosition = rootEl.renderStack;
        break;

      case CSSPositionType.static:
      case CSSPositionType.sticky:
      // @TODO: sticky.
      default:
        return;
    }
    Size preferredSize = Size.zero;
    String childDisplay = child.style['display'];
    if ((!childDisplay.isEmpty && childDisplay != 'inline') ||
        (position != CSSPositionType.static && position != CSSPositionType.relative)) {
      preferredSize = Size(
        CSSLength.toDisplayPortValue(child.style[WIDTH]),
        CSSLength.toDisplayPortValue(child.style[HEIGHT]),
      );
    }

    RenderPositionHolder positionedBoxHolder = RenderPositionHolder(preferredSize: preferredSize, positionType: position);

    var childRenderElementBoundary = child.renderElementBoundary;
    if (position == CSSPositionType.relative) {
      childRenderElementBoundary.positionedHolder = positionedBoxHolder;
    }

    addChild(positionedBoxHolder);
    childRenderElementBoundary.parentData = getPositionParentDataFromStyle(child.style, positionedBoxHolder);
    positionedBoxHolder.realDisplayedBox = childRenderElementBoundary;
    parentRenderPosition.add(childRenderElementBoundary);
  }

  void _addStickyChild(Element child, CSSPositionType position) {}

  /// Append a child to childList, if after is null, insert into first.
  void _append(Node child, {RenderBox after}) {
    // Only append childNode when it is not attached.
    if (!child.attached) child.attachTo(this, after: after);
  }

  void _updateFlexItemStyle(Element element) {
    ParentData childParentData = element.renderObject.parentData;
    if (childParentData is RenderFlexParentData) {
      final RenderFlexParentData parentData = childParentData;
      RenderFlexParentData flexParentData = CSSFlexItem.getParentData(element.style);
      parentData.flexGrow = flexParentData.flexGrow;
      parentData.flexShrink = flexParentData.flexShrink;
      parentData.flexBasis = flexParentData.flexBasis;

      // Update margin for flex child.
      element.updateRenderMargin(element.style);
      element.renderObject.markNeedsLayout();
    }
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
    style.addStyleChangeListener('backgroundColor', _styleBackgroundChangedListener);
    style.addStyleChangeListener('backgroundAttachment', _styleBackgroundChangedListener);
    style.addStyleChangeListener('backgroundImage', _styleBackgroundChangedListener);
    style.addStyleChangeListener('backgroundRepeat', _styleBackgroundChangedListener);
    style.addStyleChangeListener('backgroundSize', _styleBackgroundChangedListener);
    style.addStyleChangeListener('backgroundPosition', _styleBackgroundChangedListener);

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
    style.addStyleChangeListener('borderRadius', _styleDecoratedChangedListener);
    style.addStyleChangeListener('borderTopLeftRadius', _styleDecoratedChangedListener);
    style.addStyleChangeListener('borderTopRightRadius', _styleDecoratedChangedListener);
    style.addStyleChangeListener('borderBottomLeftRadius', _styleDecoratedChangedListener);
    style.addStyleChangeListener('borderBottomRightRadius', _styleDecoratedChangedListener);
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
    style.addStyleChangeListener('visibility', _styleVisibilityChangedListener);
    style.addStyleChangeListener('contentVisibility', _styleContentVisibilityChangedListener);
    style.addStyleChangeListener('transform', _styleTransformChangedListener);
    style.addStyleChangeListener('transformOrigin', _styleTransformOriginChangedListener);
    style.addStyleChangeListener('transition', _styleTransitionChangedListener);
    style.addStyleChangeListener('transitionProperty', _styleTransitionChangedListener);
    style.addStyleChangeListener('transitionDuration', _styleTransitionChangedListener);
    style.addStyleChangeListener('transitionTimingFunction', _styleTransitionChangedListener);
    style.addStyleChangeListener('transitionDelay', _styleTransitionChangedListener);
  }

  void _styleDisplayChangedListener(String property, String original, String present) {
    // Display change may case width/height doesn't works at all.
    _styleSizeChangedListener(property, original, present);

    bool shouldRender = present != 'none';
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
        renderLayoutBox = createRenderLayoutBox(style, children: children);
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

  void _stylePositionChangedListener(String property, String original, String present) {
    /// Update position.
    CSSPositionType prevPosition = resolveCSSPosition(original);
    CSSPositionType currentPosition = resolveCSSPosition(present);

    // Position changed.
    if (prevPosition != currentPosition) {
      _updatePosition(prevPosition, currentPosition);
    }
  }

  void _styleOffsetChangedListener(String property, String original, String present) {
    double _original = CSSLength.toDisplayPortValue(original);

    _updateOffset(
      definiteTransition: transitionMap != null ? transitionMap[property] : null,
      property: property,
      original: _original,
      diff: CSSLength.toDisplayPortValue(present) - _original,
    );
  }

  void _styleTextAlignChangedListener(String property, String original, String present) {
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

  void _styleTransitionChangedListener(String property, String original, String present) {
    if (present != null) initTransition(style, property);
  }

  void _styleOverflowChangedListener(String property, String original, String present) {
    updateOverFlowBox(style, _scrollListener);
  }

  void _stylePaddingChangedListener(String property, String original, String present) {
    updateRenderPadding(style, transitionMap);
  }

  void _styleSizeChangedListener(String property, String original, String present) {
    // Update constrained box.
    updateConstraints(style, transitionMap);

    if (property == WIDTH || property == HEIGHT) {
      double _original = CSSLength.toDisplayPortValue(original);
      _updateOffset(
        definiteTransition: transitionMap != null ? transitionMap[property] : null,
        property: property,
        original: _original,
        diff: CSSLength.toDisplayPortValue(present) - _original,
      );
    }
  }

  void _styleMarginChangedListener(String property, String original, String present) {
    /// Update margin.
    updateRenderMargin(style, transitionMap);
  }

  void _styleFlexChangedListener(String property, String original, String present) {
    String display = isEmptyStyleValue(style['display']) ? defaultDisplay : style['display'];
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
      renderLayoutBox = createRenderLayoutBox(style, children: children);
      renderPadding.child = renderLayoutBox as RenderBox;

      this.children.forEach((Element child) {
        _updateFlexItemStyle(child);
      });
    }

    _updateDecorationRenderLayoutBox();
  }

  void _styleFlexItemChangedListener(String property, String original, String present) {
    String display = isEmptyStyleValue(style['display']) ? defaultDisplay : style['display'];
    if (display.endsWith('flex')) {
      children.forEach((Element child) {
        _updateFlexItemStyle(child);
      });
    }
  }

  // background may exist on the decoratedBox or single box, because the attachment
  void _styleBackgroundChangedListener(String property, String original, String present) {
    updateBackground(property, present, renderPadding, targetId);
    // decoratedBox may contains background and border
    updateRenderDecoratedBox(style, transitionMap);
  }

  void _styleDecoratedChangedListener(String property, String original, String present) {
    // Update decorated box.
    updateRenderDecoratedBox(style, transitionMap);
  }

  void _styleOpacityChangedListener(String property, String original, String present) {
    // Update opacity.
    updateRenderOpacity(present, parentRenderObject: renderMargin);
  }

  void _styleVisibilityChangedListener(String property, String original, String present) {
    // Update visibility.
    updateRenderVisibility(present, parentRenderObject: renderMargin);
  }

  void _styleContentVisibilityChangedListener(String property, original, present) {
    // Update content visibility.
    updateRenderContentVisibility(present,
        parentRenderObject: renderIntersectionObserver, renderIntersectionObserver: renderIntersectionObserver);
  }

  void _styleTransformChangedListener(String property, String original, String present) {
    // Update transform.
    updateTransform(present, transitionMap);
  }

  void _styleTransformOriginChangedListener(String property, String original, String present) {
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
        return renderPadding.hasSize ? renderPadding.localToGlobal(Offset.zero, ancestor: renderMargin).dx : 0;
      case 'clientTop':
        return renderPadding.hasSize ? renderPadding.localToGlobal(Offset.zero, ancestor: renderMargin).dy : 0;
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

    RenderBox sizedBox = renderConstrainedBox.child;
    if (isConnected) {
      // Force flush layout.
      if (!sizedBox.hasSize) {
        sizedBox.markNeedsLayout();
        sizedBox.owner.flushLayout();
      }

      Offset offset = getOffset(sizedBox);
      Size size = sizedBox.size;
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
    Element element = findParent(this, (element) => element.renderStack != null);
    if (element == null) {
      element = ElementManager().getRootElement();
    }
    return renderBox.localToGlobal(Offset.zero, ancestor: element.renderObject);
  }

  @override
  void addEvent(String eventName) {
    if (eventHandlers.containsKey(eventName)) return; // Only listen once.
    bool isIntersectionObserverEvent = _isIntersectionObserverEvent(eventName);
    bool hasIntersectionObserverEvent = isIntersectionObserverEvent && _hasIntersectionObserverEvent(eventHandlers);
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
    if (_isIntersectionObserverEvent(eventName) && !_hasIntersectionObserverEvent(eventHandlers)) {
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
          hitTest = currentElement.renderElementBoundary.hitTest(boxHitTestResult, position: position);
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
    // Only capture
    var originalChild = renderMargin.child;
    // Make sure child is detached.
    renderMargin.child = null;
    var renderRepaintBoundary = RenderRepaintBoundary(child: originalChild);
    renderMargin.child = renderRepaintBoundary;
    renderRepaintBoundary.markNeedsLayout();
    renderRepaintBoundary.markNeedsPaint();
    requestAnimationFrame((_) async {
      Uint8List captured;
      if (renderRepaintBoundary.size == Size.zero) {
        // Return a blob with zero length.
        captured = Uint8List(0);
      } else {
        Image image = await renderRepaintBoundary.toImage(pixelRatio: devicePixelRatio);
        ByteData byteData = await image.toByteData(format: ImageByteFormat.png);
        captured = byteData.buffer.asUint8List();
      }
      renderRepaintBoundary.child = null;
      renderMargin.child = originalChild;

      completer.complete(captured);
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
  return eventName == 'appear' || eventName == 'disappear' || eventName == 'intersectionchange';
}

bool _hasIntersectionObserverEvent(eventHandlers) {
  return eventHandlers.containsKey('appear') ||
      eventHandlers.containsKey('disappear') ||
      eventHandlers.containsKey('intersectionchange');
}

bool _isPositioned(CSSStyleDeclaration style) {
  if (style.contains('position')) {
    String position = style['position'];
    return position != 'static';
  } else {
    return false;
  }
}

bool _isSticky(CSSStyleDeclaration style) {
  return style['position'] == 'sticky' && style.contains('top') || style.contains('bottom');
}

PositionParentData getPositionParentDataFromStyle(CSSStyleDeclaration style, RenderPositionHolder placeholder) {
  PositionParentData parentData = PositionParentData();
  parentData.originalRenderBoxRef = placeholder;
  parentData.position = resolvePositionFromStyle(style);

  if (style.contains('top')) {
    parentData.top = CSSLength.toDisplayPortValue(style['top']);
  }
  if (style.contains('left')) {
    parentData.left = CSSLength.toDisplayPortValue(style['left']);
  }
  if (style.contains('bottom')) {
    parentData.bottom = CSSLength.toDisplayPortValue(style['bottom']);
  }
  if (style.contains('right')) {
    parentData.right = CSSLength.toDisplayPortValue(style['right']);
  }
  parentData.width = CSSLength.toDisplayPortValue(style['width']);
  parentData.height = CSSLength.toDisplayPortValue(style['height']);
  parentData.zIndex = CSSLength.toInt(style['zIndex']);
  return parentData;
}
