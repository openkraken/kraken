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
import 'package:kraken/src/css/style_property.dart';
import 'package:meta/meta.dart';

import '../css/flow.dart';
import 'event_handler.dart';
import 'bounding_client_rect.dart';

const String STYLE = 'style';

/// Defined by W3C Standard,
/// Most elements's default width is 300 in pixel,
/// height is 150 in pixel.
const String ELEMENT_DEFAULT_WIDTH = '300px';
const String ELEMENT_DEFAULT_HEIGHT = '150px';

typedef TestElement = bool Function(Element element);

enum StickyPositionType {
  relative,
  fixed,
}

class Element extends Node
    with
        NodeLifeCycle,
        EventHandlerMixin,
        CSSTextMixin,
        CSSBackgroundMixin,
        CSSDecoratedBoxMixin,
        CSSSizingMixin,
        CSSFlexboxMixin,
        CSSFlowMixin,
        CSSOverflowMixin,
        CSSOpacityMixin,
        CSSTransformMixin,
        CSSVisibilityMixin,
        CSSContentVisibilityMixin,
        CSSTransitionMixin {
  Map<String, dynamic> properties;
  List<String> events;

  // Whether element allows children.
  bool isIntrinsicBox = false;

  /// whether element needs reposition when append to tree or
  /// changing position property.
  bool needsReposition = false;

  bool shouldBlockStretch = true;

  // Position of sticky element changes between relative and fixed of scroll container
  StickyPositionType stickyStatus = StickyPositionType.relative;
  // Original offset to scroll container of sticky element
  Offset originalScrollContainerOffset;
  // Original offset of sticky element
  Offset originalOffset;

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
  RenderLayoutBox renderLayoutBox;
  RenderIntrinsicBox renderIntrinsicBox;
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
  double get cropPaddingWidth {
    if (renderIntrinsicBox != null && renderIntrinsicBox.padding != null) {
      return renderIntrinsicBox.padding.horizontal;
    } else if (renderLayoutBox != null && renderLayoutBox.padding != null) {
      return renderLayoutBox.padding.horizontal;
    }
    return 0.0;
  }

  // Vertical padding dimension (top + bottom)
  double get cropPaddingHeight {
    if (renderIntrinsicBox != null && renderIntrinsicBox.padding != null) {
      return renderIntrinsicBox.padding.vertical;
    } else if (renderLayoutBox != null && renderLayoutBox.padding != null) {
      return renderLayoutBox.padding.vertical;
    }
    return 0.0;
  }

  bool get isValidSticky {
    return style['position'] == 'sticky' && (style.contains('top') || style.contains('bottom'));
  }

  // Horizontal border dimension (left + right)
  double get cropBorderWidth => renderDecoratedBox.borderEdge.horizontal;
  // Vertical border dimension (top + bottom)
  double get cropBorderHeight => renderDecoratedBox.borderEdge.vertical;

  Element(
    int targetId,
    ElementManager elementManager, {
    this.tagName,
    this.defaultStyle = const {},
    this.events = const [],
    this.needsReposition = false,
    this.isIntrinsicBox = false,
  })  : assert(targetId != null),
        assert(tagName != null),
        super(NodeType.ELEMENT_NODE, targetId, elementManager, tagName) {
    if (properties == null) properties = {};
    if (events == null) events = [];

    defaultDisplay = defaultStyle.containsKey('display') ? defaultStyle['display'] : 'block';
    style = CSSStyleDeclaration(style: defaultStyle);

    style.addStyleChangeListener(_onStyleChanged);

    // Mark element needs to reposition according to position CSS.
    if (_isPositioned(style)) needsReposition = true;

    // Content children layout, BoxModel content.
    if (isIntrinsicBox) {
      renderObject = renderIntrinsicBox = RenderIntrinsicBox(targetId, style);
    } else {
      renderObject = renderLayoutBox = createRenderLayoutBox(style);
    }

    // Background image
    renderObject = initBackground(renderObject, style, targetId);

    // Overflow
    renderObject = initOverflowBox(renderObject, style, _scrollListener);

    // BoxModel Border
    renderObject = initRenderDecoratedBox(renderObject, style, targetId);

    // Constrained box
    renderObject = renderConstrainedBox = initRenderConstrainedBox(renderObject, style);

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
    renderObject = renderElementBoundary = initTransform(renderObject, style, targetId, elementManager);

    setElementSizeType();
  }

  void setElementSizeType() {
    bool widthDefined = style.contains('width') || style.contains('minWidth');
    bool heightDefined = style.contains('height') || style.contains('minHeight');

    BoxSizeType widthType = widthDefined ? BoxSizeType.specified : BoxSizeType.automatic;
    BoxSizeType heightType = heightDefined ? BoxSizeType.specified : BoxSizeType.automatic;

    renderElementBoundary.widthSizeType = widthType;
    renderElementBoundary.heightSizeType = heightType;
  }

  void _scrollListener(double scrollOffset, AxisDirection axisDirection) {
    layoutStickyChildren(scrollOffset, axisDirection);
  }

  // Set sticky child offset according to scroll offset and direction
  void layoutStickyChild(Element child, double scrollOffset, AxisDirection axisDirection) {
    CSSStyleDeclaration childStyle = child.style;
    bool isFixed = false;

    if (child.originalScrollContainerOffset == null) {
      Offset horizontalScrollContainerOffset =
          child.renderElementBoundary.localToGlobal(Offset.zero, ancestor: child.elementManager.getRootRenderObject())
              - renderScrollViewPortX.localToGlobal(Offset.zero, ancestor: child.elementManager.getRootRenderObject());
      Offset verticalScrollContainerOffset =
          child.renderElementBoundary.localToGlobal(Offset.zero, ancestor: child.elementManager.getRootRenderObject())
              - renderScrollViewPortY.localToGlobal(Offset.zero, ancestor: child.elementManager.getRootRenderObject());

      double offsetY = verticalScrollContainerOffset.dy;
      double offsetX = horizontalScrollContainerOffset.dx;
      if (axisDirection == AxisDirection.down) {
        offsetY += scrollOffset;
      } else if (axisDirection == AxisDirection.right) {
        offsetX += scrollOffset;
      }
      // Save original offset to scroll container in element tree to
      // act as base offset to compute dynamic sticky offset later
      child.originalScrollContainerOffset = Offset(offsetX, offsetY);
    }

    // Sticky offset to scroll container must include padding
    EdgeInsetsGeometry padding = renderLayoutBox.padding;
    EdgeInsets resolvedPadding = EdgeInsets.all(0);
    if (padding != null) {
      resolvedPadding = padding.resolve(TextDirection.ltr);
    }

    RenderLayoutParentData boxParentData = child.renderElementBoundary?.parentData;

    if (child.originalOffset == null) {
      child.originalOffset = boxParentData.offset;
    }

    double offsetY = child.originalOffset.dy;
    double offsetX = child.originalOffset.dx;

    double childHeight = child.renderElementBoundary?.size?.height;
    double childWidth = child.renderElementBoundary?.size?.width;
    // Sticky element cannot exceed the boundary of its parent element container
    RenderBox parentContainer = child.parent.renderLayoutBox;
    double minOffsetY = 0;
    double maxOffsetY = parentContainer.size.height - childHeight;
    double minOffsetX = 0;
    double maxOffsetX = parentContainer.size.width - childWidth;

    if (axisDirection == AxisDirection.down) {
      double offsetTop = child.originalScrollContainerOffset.dy - scrollOffset;
      double viewPortHeight = renderScrollViewPortY?.size?.height;
      double offsetBottom = viewPortHeight - childHeight - offsetTop;

      if (childStyle.contains('top')) {
        double top = CSSStyleProperty.getDisplayPortValue(childStyle['top']) + resolvedPadding.top;
        isFixed = offsetTop < top;
        if (isFixed) {
          offsetY += top - offsetTop;
          if (offsetY > maxOffsetY) {
            offsetY = maxOffsetY;
          }
        }
      } else if (childStyle.contains('bottom')) {
        double bottom = CSSStyleProperty.getDisplayPortValue(childStyle['bottom']) + resolvedPadding.bottom;
        isFixed = offsetBottom < bottom;
        if (isFixed) {
          offsetY += offsetBottom - bottom;
          if (offsetY < minOffsetY) {
            offsetY = minOffsetY;
          }
        }
      }

      if (isFixed) {
        boxParentData.offset = Offset(
          boxParentData.offset.dx,
          offsetY,
        );
      } else {
        boxParentData.offset = Offset(
          boxParentData.offset.dx,
          child.originalOffset.dy,
        );
      }
    } else if (axisDirection == AxisDirection.right) {
      double offsetLeft = child.originalScrollContainerOffset.dx - scrollOffset;
      double viewPortWidth = renderScrollViewPortX?.size?.width;
      double offsetRight = viewPortWidth - childWidth - offsetLeft;

      if (childStyle.contains('left')) {
        double left = CSSStyleProperty.getDisplayPortValue(childStyle['left']) + resolvedPadding.left;
        isFixed = offsetLeft < left;
        if (isFixed) {
          offsetX += left - offsetLeft;
          if (offsetX > maxOffsetX) {
            offsetX = maxOffsetX;
          }
        }
      } else if (childStyle.contains('right')) {
        double right = CSSStyleProperty.getDisplayPortValue(childStyle['right']) + resolvedPadding.right;
        isFixed = offsetRight < right;
        if (isFixed) {
          offsetX += offsetRight - right;
          if (offsetX < minOffsetX) {
            offsetX = minOffsetX;
          }
        }
      }

      if (isFixed) {
        boxParentData.offset = Offset(
          offsetX,
          boxParentData.offset.dy,
        );
      } else {
        boxParentData.offset = Offset(
          child.originalOffset.dx,
          boxParentData.offset.dy,
        );
      }
    }

    if (isFixed) {
      // Change sticky status to fixed
      child.stickyStatus = StickyPositionType.fixed;
      boxParentData.isOffsetSet = true;
      child.renderElementBoundary.markNeedsPaint();
    } else {
      // Change sticky status to relative
      if (child.stickyStatus == StickyPositionType.fixed) {
        child.stickyStatus = StickyPositionType.relative;
        // Reset child offset to its original offset
        child.renderElementBoundary.markNeedsPaint();
      }
    }
  }

  // Calculate sticky status according to scroll offset and scroll direction
  void layoutStickyChildren(double scrollOffset, AxisDirection axisDirection) {
    List<Element> stickyElements = findStickyChildren(this);
    stickyElements.forEach((Element el) {
      layoutStickyChild(el, scrollOffset, axisDirection);
    });
  }

  void _updatePosition(CSSPositionType prevPosition, CSSPositionType currentPosition) {
    if (renderElementBoundary.parentData is RenderLayoutParentData) {
      (renderElementBoundary.parentData as RenderLayoutParentData).position = currentPosition;
    }
    // Move element according to position when it's already connected
    if (isConnected) {
      if (currentPosition == CSSPositionType.static) {
        // Loop renderObject children to move positioned children to its containing block
        renderLayoutBox.visitChildren((childRenderObject) {
          if (childRenderObject is RenderElementBoundary) {
            Element child = elementManager.getEventTargetByTargetId<Element>(childRenderObject.targetId);
            CSSPositionType childPositionType = resolvePositionFromStyle(child.style);
            if (childPositionType == CSSPositionType.absolute || childPositionType == CSSPositionType.fixed) {
              Element containgBlockElement = findContainingBlock(child);
              child.detach();
              child.attachTo(containgBlockElement);
            }
          }
        });

        // Move self from containing block to original position in element tree
        if (prevPosition == CSSPositionType.absolute || prevPosition == CSSPositionType.fixed) {
          RenderLayoutParentData parentData = renderElementBoundary.parentData;
          RenderPositionHolder renderPositionHolder = parentData.renderPositionHolder;
          if (renderPositionHolder != null) {
            RenderLayoutBox parentLayoutBox = renderPositionHolder.parent;
            int parentTargetId = parentLayoutBox.targetId;
            Element parentElement = elementManager.getEventTargetByTargetId<Element>(parentTargetId);

            List<RenderObject> layoutChildren = [];
            parentLayoutBox.visitChildren((child) {
              layoutChildren.add(child);
            });
            int idx = layoutChildren.indexOf(renderPositionHolder);
            RenderObject previousSibling = idx > 0 ? layoutChildren[idx - 1] : null;
            detach();
            attachTo(parentElement, after: previousSibling);
          }
        }

        // Reset stick element offset to normal flow
        if (prevPosition == CSSPositionType.sticky) {
          RenderLayoutParentData boxParentData = renderElementBoundary?.parentData;
          boxParentData.isOffsetSet = false;
          renderElementBoundary.markNeedsLayout();
          renderElementBoundary.markNeedsPaint();
        }
      } else {
        // Move self to containing block
        if (currentPosition == CSSPositionType.absolute || currentPosition == CSSPositionType.fixed) {
          Element containgBlockElement = findContainingBlock(this);
          detach();
          attachTo(containgBlockElement);
        }

        // Loop children tree to find and append positioned children whose containing block is self
        List<Element> positionedChildren = [];
        _findPositionedChildren(this, positionedChildren);
        positionedChildren.forEach((child) {
          child.detach();
          child.attachTo(this);
        });

        // Set stick element offset
        if (currentPosition == CSSPositionType.sticky) {
          Element scrollContainer = findScrollContainer(this);
          // Set sticky child offset manually
          scrollContainer.layoutStickyChild(this, 0, AxisDirection.down);
          scrollContainer.layoutStickyChild(this, 0, AxisDirection.right);
        }
      }
    }
  }

  void _findPositionedChildren(Element parent, List<Element> positionedChildren) {
    for (int i = 0; i < parent.children.length; i++) {
      Element child = parent.children[i];
      CSSPositionType childPositionType = resolvePositionFromStyle(child.style);
      if (childPositionType == CSSPositionType.absolute || childPositionType == CSSPositionType.fixed) {
        positionedChildren.add(child);
      } else if (child.children.length != 0) {
        _findPositionedChildren(child, positionedChildren);
      }
    }
  }

  void _updateOffset({CSSTransition definiteTransition, String property, double diff, double original}) {
    RenderLayoutParentData positionParentData;
    RenderBox renderParent = renderElementBoundary.parent;
    if (renderElementBoundary.parentData is RenderLayoutParentData) {
      positionParentData = renderElementBoundary.parentData;
      RenderLayoutParentData progressParentData = positionParentData;

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
      renderIntrinsicBox.child = child;
    }
  }

  RenderBoxModel createRenderLayoutBox(CSSStyleDeclaration style, {List<RenderBox> children}) {
    String display = CSSStyleDeclaration.isNullOrEmptyValue(style['display']) ? defaultDisplay : style['display'];
    if (display.endsWith('flex')) {
      RenderFlexLayout flexLayout = RenderFlexLayout(
        children: children,
        style: style,
        targetId: targetId,
        elementManager: elementManager
      );
      decorateRenderFlex(flexLayout, style);
      return flexLayout;
    } else if (display == 'none' ||
        display == 'inline' ||
        display == 'inline-block' ||
        display == 'block') {
      RenderFlowLayoutBox flowLayout = RenderFlowLayoutBox(
        children: children,
        style: style,
        targetId: targetId,
        elementManager: elementManager
      );
      decorateRenderFlow(flowLayout, style);
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
    CSSStyleDeclaration parentStyle = parent.style;
    String parentDisplayValue =
        CSSStyleDeclaration.isNullOrEmptyValue(parentStyle['display']) ? parent.defaultDisplay : parentStyle['display'];
    // InlineFlex or Flex
    bool isParentFlexDisplayType = parentDisplayValue.endsWith('flex');

    // Add FlexItem wrap for flex child node.
    if (isParentFlexDisplayType && renderLayoutBox != null) {
      (renderScrollViewPortX as RenderObjectWithChildMixin<RenderBox>).child = null;
      (renderScrollViewPortX as RenderObjectWithChildMixin<RenderBox>).child = RenderFlexItem(child: renderLayoutBox);
    }

    CSSPositionType positionType = resolvePositionFromStyle(style);
    switch (positionType) {
      case CSSPositionType.absolute:
      case CSSPositionType.fixed:
        parent._addPositionedChild(this, positionType);
        break;
      case CSSPositionType.sticky:
        parent._addStickyChild(this, after);
        break;
      case CSSPositionType.relative:
      case CSSPositionType.static:
        parent.renderLayoutBox.insert(renderElementBoundary, after: after);
        break;
    }

    /// Update flex siblings.
    if (isParentFlexDisplayType) parent.children.forEach(_updateFlexItemStyle);
  }

  // Detach renderObject of current node from parent
  @override
  void detach() {
    // Remove placeholder of positioned element
    RenderLayoutParentData parentData = renderElementBoundary.parentData;
    if (parentData.renderPositionHolder != null) {
      ContainerRenderObjectMixin parent = parentData.renderPositionHolder.parent;
      parent.remove(parentData.renderPositionHolder);
    }
    (renderElementBoundary.parent as ContainerRenderObjectMixin).remove(renderElementBoundary);
  }

  @override
  @mustCallSuper
  Node appendChild(Node child) {
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

  // Add placeholder to positioned element for calculate original
  // coordinate before moved away
  void addPositionPlaceholder() {
    if (renderPositionedPlaceholder == null || !renderPositionedPlaceholder.attached) {
      addChild(renderPositionedPlaceholder);
    }
  }

  void _addPositionedChild(Element child, CSSPositionType position) {
    // RenderPosition parentRenderPosition;
    ContainerRenderObjectMixin parentRenderLayoutBox;

    switch (position) {
      case CSSPositionType.absolute:
        Element containingBlockElement = findContainingBlock(child);
        parentRenderLayoutBox = containingBlockElement.renderLayoutBox;
        break;

      case CSSPositionType.fixed:
        final Element rootEl = elementManager.getRootElement();
        parentRenderLayoutBox = rootEl.renderLayoutBox;
        break;

      case CSSPositionType.sticky:
        Element containingBlockElement = findContainingBlock(child);
        parentRenderLayoutBox = containingBlockElement.renderLayoutBox;
        break;

      default:
        return;
    }
    Size preferredSize = Size.zero;
    String childDisplay = child.style['display'];
    if ((!childDisplay.isEmpty && childDisplay != 'inline') || (position != CSSPositionType.static)) {
      preferredSize = Size(
        CSSLength.toDisplayPortValue(child.style[WIDTH]) ?? 0,
        CSSLength.toDisplayPortValue(child.style[HEIGHT]) ?? 0,
      );
    }

    RenderPositionHolder positionedBoxHolder = RenderPositionHolder(preferredSize: preferredSize);

    var childRenderElementBoundary = child.renderElementBoundary;
    if (position == CSSPositionType.relative || position == CSSPositionType.absolute) {
      childRenderElementBoundary.positionedHolder = positionedBoxHolder;
    }

    child.parent.addChild(positionedBoxHolder);

    setPositionedChildParentData(parentRenderLayoutBox, child, positionedBoxHolder);
    positionedBoxHolder.realDisplayedBox = childRenderElementBoundary;

    parentRenderLayoutBox.add(childRenderElementBoundary);
  }

  void _addStickyChild(Element child, RenderObject after) {
    renderLayoutBox.insert(child.renderElementBoundary, after: after);

    // Set sticky element offset
    Element scrollContainer = findScrollContainer(child);
    // Flush layout first to calculate sticky offset
    if (!child.renderElementBoundary.hasSize) {
      child.renderElementBoundary.owner.flushLayout();
    }
    // Set sticky child offset manually
    scrollContainer.layoutStickyChild(child, 0, AxisDirection.down);
    scrollContainer.layoutStickyChild(child, 0, AxisDirection.right);
  }

  // Inline box including inline/inline-block/inline-flex/...
  bool get isInlineBox {
    String displayValue = style['display'];
    return displayValue.startsWith('inline');
  }

  // Inline content means children should be inline elements.
  bool get isInlineContent {
    String displayValue = style['display'];
    return displayValue == 'inline';
  }

  /// Append a child to childList, if after is null, insert into first.
  void _append(Node child, {RenderBox after}) {
    // @NOTE: Make sure inline-box only have inline children, or print warning.
    if ((child is Element) && !child.isInlineBox) {
      if (isInlineContent) print('[WARN]: Can not nest non-inline element into non-inline parent element.');
    }

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
      parentData.alignSelf = flexParentData.alignSelf;

      // Update margin for flex child.
      element.updateRenderMargin(element.style);
      element.renderObject.markNeedsLayout();
    }
  }

  void _onStyleChanged(String property, String original, String present) {
    switch (property) {
      case 'display':
        _styleDisplayChangedListener(property, original, present);
        break;

      case 'position':
      case 'zIndex':
        _stylePositionChangedListener(property, original, present);
        break;

      case 'top':
      case 'left':
      case 'bottom':
      case 'right':
        _styleOffsetChangedListener(property, original, present);
        break;

      case 'flexDirection':
      case 'flexWrap':
      case 'justifyContent':
      case 'alignItems':
      case 'alignSelf':
      case 'alignContent':
      case 'textAlign':
        _styleFlexChangedListener(property, original, present);
        break;

      case 'flexFlow':
      case 'flexGrow':
      case 'flexShrink':
      case 'flexBasis':
      case 'flex':
      case 'alignItems':
        _styleFlexItemChangedListener(property, original, present);
        break;

      case 'textAlign':
        _styleTextAlignChangedListener(property, original, present);
        break;

      case 'padding':
      case 'paddingLeft':
      case 'paddingTop':
      case 'paddingRight':
      case 'paddingBottom':
        _stylePaddingChangedListener(property, original, present);
        break;

      case 'width':
      case 'minWidth':
      case 'maxWidth':
      case 'height':
      case 'minHeight':
      case 'maxHeight':
        _styleSizeChangedListener(property, original, present);
        break;

      case 'overflow':
      case 'overflowX':
      case 'overflowY':
        _styleOverflowChangedListener(property, original, present);
        break;

      case 'background':
      case 'backgroundColor':
      case 'backgroundAttachment':
      case 'backgroundImage':
      case 'backgroundRepeat':
      case 'backgroundSize':
      case 'backgroundPosition':
        _styleBackgroundChangedListener(property, original, present);
        break;

      case 'border':
      case 'borderTop':
      case 'borderLeft':
      case 'borderRight':
      case 'borderBottom':
      case 'borderWidth':
      case 'borderLeftWidth':
      case 'borderTopWidth':
      case 'borderRightWidth':
      case 'borderBottomWidth':
      case 'borderRadius':
      case 'borderTopLeftRadius':
      case 'borderTopRightRadius':
      case 'borderBottomLeftRadius':
      case 'borderBottomRightRadius':
      case 'borderStyle':
      case 'borderLeftStyle':
      case 'borderTopStyle':
      case 'borderRightStyle':
      case 'borderBottomStyle':
      case 'borderColor':
      case 'borderLeftColor':
      case 'borderTopColor':
      case 'borderRightColor':
      case 'borderBottomColor':
      case 'boxShadow':
        _styleDecoratedChangedListener(property, original, present);
        break;

      case 'margin':
      case 'marginLeft':
      case 'marginTop':
      case 'marginRight':
      case 'marginBottom':
        _styleMarginChangedListener(property, original, present);
        break;

      case 'opacity':
        _styleOpacityChangedListener(property, original, present);
        break;
      case 'visibility':
        _styleVisibilityChangedListener(property, original, present);
        break;
      case 'contentVisibility':
        _styleContentVisibilityChangedListener(property, original, present);
        break;
      case 'transform':
        _styleTransformChangedListener(property, original, present);
        break;
      case 'transformOrigin':
        _styleTransformOriginChangedListener(property, original, present);
        break;
      case 'transition':
      case 'transitionProperty':
      case 'transitionDuration':
      case 'transitionTimingFunction':
      case 'transitionDelay':
        _styleTransitionChangedListener(property, original, present);
        break;
    }
  }

  void _styleDisplayChangedListener(String property, String original, String present) {
    // Display change may case width/height doesn't works at all.
    _styleSizeChangedListener(property, original, present);

    bool shouldRender = present != 'none';
    renderElementBoundary.shouldRender = shouldRender;

    if (renderLayoutBox != null) {
      String prevDisplay = CSSStyleDeclaration.isNullOrEmptyValue(original) ? defaultDisplay : original;
      String currentDisplay = CSSStyleDeclaration.isNullOrEmptyValue(present) ? defaultDisplay : present;
      if (prevDisplay != currentDisplay) {
        ContainerRenderObjectMixin prevRenderLayoutBox = renderLayoutBox;
        // Collect children of renderLayoutBox and remove their relationship.
        List<RenderBox> children = [];
        prevRenderLayoutBox
          ..visitChildren((child) {
            children.add(child);
          })
          ..removeAll();

        (renderScrollViewPortX as RenderObjectWithChildMixin<RenderBox>).child = null;
        renderLayoutBox = renderLayoutBox.fromCopy(createRenderLayoutBox(style, children: children));
        (renderScrollViewPortX as RenderObjectWithChildMixin<RenderBox>).child = renderLayoutBox;
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
    double _original = CSSLength.toDisplayPortValue(original) ?? 0;
    double current = CSSLength.toDisplayPortValue(present) ?? 0;
    _updateOffset(
      definiteTransition: transitionMap != null ? transitionMap[property] : null,
      property: property,
      original: _original,
      diff: current - _original,
    );
  }

  void _styleTextAlignChangedListener(String property, String original, String present) {
    _updateDecorationRenderLayoutBox();
  }

  void _updateDecorationRenderLayoutBox() {
    if (renderLayoutBox is RenderFlexLayout) {
      decorateRenderFlex(renderLayoutBox, style);
    } else if (renderLayoutBox is RenderFlowLayoutBox) {
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
    if (renderLayoutBox != null) {
      updateRenderPadding(renderLayoutBox, style, transitionMap);
    } else {
      updateRenderPadding(renderIntrinsicBox, style, transitionMap);
    }
  }

  void _styleSizeChangedListener(String property, String original, String present) {
    // Update constrained box.
    updateConstraints(style, transitionMap);

    setElementSizeType();

    if (property == WIDTH || property == HEIGHT) {
      double _original = CSSLength.toDisplayPortValue(original) ?? 0;
      double current = CSSLength.toDisplayPortValue(present) ?? 0;
      _updateOffset(
        definiteTransition: transitionMap != null ? transitionMap[property] : null,
        property: property,
        original: _original,
        diff: current - _original,
      );
    }
  }

  void _styleMarginChangedListener(String property, String original, String present) {
    /// Update margin.
    updateRenderMargin(style, transitionMap);
  }

  void _styleFlexChangedListener(String property, String original, String present) {
    String display = CSSStyleDeclaration.isNullOrEmptyValue(style['display']) ? defaultDisplay : style['display'];
    if (display.endsWith('flex')) {
      ContainerRenderObjectMixin prevRenderLayoutBox = renderLayoutBox;
      // Collect children of renderLayoutBox and remove their relationship.
      List<RenderBox> children = [];
      prevRenderLayoutBox
        ..visitChildren((child) {
          children.add(child);
        })
        ..removeAll();

      (renderScrollViewPortX as RenderObjectWithChildMixin<RenderBox>).child = null;
      renderLayoutBox = renderLayoutBox.fromCopy(createRenderLayoutBox(style, children: children));
      (renderScrollViewPortX as RenderObjectWithChildMixin<RenderBox>).child = renderLayoutBox;

      this.children.forEach((Element child) {
        _updateFlexItemStyle(child);
      });
    }

    _updateDecorationRenderLayoutBox();
  }

  void _styleFlexItemChangedListener(String property, String original, String present) {
    String display = CSSStyleDeclaration.isNullOrEmptyValue(style['display']) ? defaultDisplay : style['display'];
    if (display.endsWith('flex')) {
      children.forEach((Element child) {
        _updateFlexItemStyle(child);
      });
    }
  }

  // background may exist on the decoratedBox or single box, because the attachment
  void _styleBackgroundChangedListener(String property, String original, String present) {
    updateBackground(property, present, (renderScrollViewPortX as RenderObjectWithChildMixin<RenderBox>), targetId);
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

    // Each key change will emit to `setStyle`
    if (key == STYLE) {
      assert(value is Map<String, dynamic>);
      // @TODO: Consider `{ color: red }` to `{}`, need to remove invisible keys.
      (value as Map<String, dynamic>).forEach(setStyle);
    } else {
      properties[key] = value;
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
        // need to flush layout to get correct size
        elementManager.getRootRenderObject().owner.flushLayout();
        return getOffsetY();
      case 'offsetLeft':
        // need to flush layout to get correct size
        elementManager.getRootRenderObject().owner.flushLayout();
        return getOffsetX();
      case 'offsetWidth':
        // need to flush layout to get correct size
        elementManager.getRootRenderObject().owner.flushLayout();
        return renderMargin.hasSize ? renderMargin.size.width : 0;
      case 'offsetHeight':
        // need to flush layout to get correct size
        elementManager.getRootRenderObject().owner.flushLayout();
        return renderMargin.hasSize ? renderMargin.size.height : 0;
      // TODO support clientWidth clientHeight clientLeft clientTop
      case 'clientWidth':
        // need to flush layout to get correct size
        elementManager.getRootRenderObject().owner.flushLayout();
        return renderLayoutBox.clientWidth;
      case 'clientHeight':
        // need to flush layout to get correct size
        elementManager.getRootRenderObject().owner.flushLayout();
        return renderLayoutBox.clientHeight;
      case 'clientLeft':
        // TODO: implement this after border has supported in renderLayoutBox
        //  return renderLayoutBox.borderLeft();
        break;
      case 'clientTop':
        // TODO: implement this after border has supported in renderLayoutBox
        // return renderLayoutBox.borderTop;
        break;
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
      // need to flush layout to get correct size
      elementManager.getRootRenderObject().owner.flushLayout();

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
    // need to flush layout to get correct size
    elementManager.getRootRenderObject().owner.flushLayout();

    Element element = findContainingBlock(this);
    if (element == null) {
      element = elementManager.getRootElement();
    }
    return renderBox.localToGlobal(Offset.zero, ancestor: element.renderObject);
  }

  @override
  void addEvent(String eventName) {
    if (eventHandlers.containsKey(eventName)) return; // Only listen once.
    bool isIntersectionObserverEvent = _isIntersectionObserverEvent(eventName);
    bool hasIntersectionObserverEvent = isIntersectionObserverEvent && _hasIntersectionObserverEvent(eventHandlers);
    super.addEventListener(eventName, _eventResponder);

    // Insert pointer listener render if event needs
    insertRenderPointerListener(renderConstrainedBox);

    // Only add listener once for all intersection related event
    if (isIntersectionObserverEvent && !hasIntersectionObserverEvent) {
      renderIntersectionObserver.addListener(handleIntersectionChange);
    }
  }

  void removeEvent(String eventName) {
    if (!eventHandlers.containsKey(eventName)) return; // Only listen once.
    super.removeEventListener(eventName, _eventResponder);

    // Remove pointer listener render if no event needs
    removeRenderPointerListener();

    // Remove listener when no intersection related event
    if (_isIntersectionObserverEvent(eventName) && !_hasIntersectionObserverEvent(eventHandlers)) {
      renderIntersectionObserver.removeListener(handleIntersectionChange);
    }
  }

  void _eventResponder(Event event) {
    String json = jsonEncode([targetId, event]);
    emitUIEvent(elementManager.controller.contextId, json);
  }

  void click() {
    Event clickEvent = Event('click', EventInit());

    if (isConnected) {
      final RenderBox box = renderElementBoundary;
      // HitTest will test rootView's every child (including
      // child's child), so must flush rootView every times,
      // or child may miss size.
      elementManager.getRootRenderObject().owner.flushLayout();

      // Position the center of element.
      Offset position = box.localToGlobal(box.size.center(Offset.zero), ancestor: elementManager.getRootRenderObject());
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

    SchedulerBinding.instance.addPostFrameCallback((_) async {
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

Element findContainingBlock(Element element) {
  Element _el = element?.parent;
  Element rootEl = element.elementManager.getRootElement();

  while (_el != null) {
    bool isElementNonStatic = _el.style['position'] != 'static' && _el.style['position'] != '';
    bool hasTransform = _el.style['transform'] != '';
    // https://www.w3.org/TR/CSS2/visudet.html#containing-block-details
    if (_el == rootEl || isElementNonStatic || hasTransform) {
      break;
    }
    _el = _el.parent;
  }
  return _el;
}

Element findScrollContainer(Element element) {
  Element _el = element?.parent;
  Element rootEl = element.elementManager.getRootElement();

  while (_el != null) {
    List<CSSOverflowType> overflow = getOverflowFromStyle(_el.style);
    CSSOverflowType overflowX = overflow[0];
    CSSOverflowType overflowY = overflow[1];

    if (overflowX != CSSOverflowType.visible || overflowY != CSSOverflowType.visible || _el == rootEl) {
      break;
    }
    _el = _el.parent;
  }
  return _el;
}

List<Element> findStickyChildren(Element element) {
  assert(element != null);
  List<Element> result = [];

  element.children.forEach((Element child) {
    List<CSSOverflowType> overflow = getOverflowFromStyle(child.style);
    CSSOverflowType overflowX = overflow[0];
    CSSOverflowType overflowY = overflow[1];

    if (child.isValidSticky) result.add(child);

    // No need to loop scrollable container children
    if (overflowX != CSSOverflowType.visible || overflowY != CSSOverflowType.visible) {
      return;
    }

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
    return position != '' && position != 'static';
  } else {
    return false;
  }
}

void setPositionedChildParentData(
    ContainerRenderObjectMixin parentRenderLayoutBox, Element child, RenderPositionHolder placeholder) {
  var parentData;
  if (parentRenderLayoutBox is RenderFlowLayoutBox) {
    parentData = RenderLayoutParentData();
  } else {
    parentData = RenderFlexParentData();
  }
  CSSStyleDeclaration style = child.style;

  CSSPositionType positionType = resolvePositionFromStyle(style);
  parentData.renderPositionHolder = placeholder;
  parentData.position = positionType;

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
  parentData.width = CSSLength.toDisplayPortValue(style['width']) ?? 0.0;
  parentData.height = CSSLength.toDisplayPortValue(style['height']) ?? 0.0;
  parentData.zIndex = CSSLength.toInt(style['zIndex']);

  parentData.isPositioned = positionType == CSSPositionType.absolute || positionType == CSSPositionType.fixed;

  RenderElementBoundary childRenderElementBoundary = child.renderElementBoundary;
  childRenderElementBoundary.parentData = parentData;
}
