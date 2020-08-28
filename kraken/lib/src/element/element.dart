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

enum BoxSizeType {
  // Element which have intrinsic before layout. Such as <img /> and <video />
  intrinsic,

  // Element which have width or min-width properties defined.
  specified,

  // Element which neither have intrinsic or predefined size.
  automatic,
}

mixin ElementBase {
  RenderLayoutBox renderLayoutBox;
  RenderIntrinsic renderIntrinsic;

  RenderBoxModel getRenderBoxModel() {
    if (renderIntrinsic != null) {
      return renderIntrinsic;
    } else {
      return renderLayoutBox;
    }
  }
}

class Element extends Node
    with
        ElementBase,
        NodeLifeCycle,
        EventHandlerMixin,
        CSSTextMixin,
        CSSDecoratedBoxMixin,
        CSSSizingMixin,
        CSSFlexboxMixin,
        CSSFlowMixin,
        CSSOverflowMixin,
        CSSOpacityMixin,
        CSSTransformMixin,
        CSSVisibilityMixin,
        CSSOffsetMixin,
        CSSContentVisibilityMixin,
        CSSTransitionMixin {
  Map<String, dynamic> properties;
  List<String> events;

  /// whether element needs reposition when append to tree or
  /// changing position property.
  bool needsReposition = false;

  /// Should create repaintBoundary for this element to repaint separately from parent.
  bool repaintSelf;

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

  RenderDecoratedBox stickyPlaceholder;
  // Placeholder renderObject of positioned element(absolute/fixed)
  // used to get original coordinate before move away from document flow
  RenderObject renderPositionedPlaceholder;

  bool get isValidSticky {
    return style[POSITION] == STICKY && (style.contains(TOP) || style.contains(BOTTOM));
  }

  Element(
    int targetId,
    ElementManager elementManager, {
    this.tagName,
    this.defaultStyle = const {},
    this.events = const [],
    this.needsReposition = false,
    // Whether element allows children.
    bool isIntrinsicBox = false,
    this.repaintSelf = false
  }) : assert(targetId != null),
        assert(tagName != null),
        super(NodeType.ELEMENT_NODE, targetId, elementManager, tagName) {
    if (properties == null) properties = {};
    if (events == null) events = [];

    defaultDisplay = defaultStyle.containsKey(DISPLAY) ? defaultStyle[DISPLAY] : BLOCK;
    style = CSSStyleDeclaration(this);
    style.addStyleChangeListener(_onStyleChanged);

    // Mark element needs to reposition according to position CSS.
    if (_isPositioned(style)) needsReposition = true;

    // Content children layout, BoxModel content.
    if (isIntrinsicBox) {
      renderIntrinsic = createRenderIntrinsic(this, repaintSelf: repaintSelf);
    } else {
      renderLayoutBox = createRenderLayout(this, repaintSelf: repaintSelf);
    }

    _setElementSizeType();

    _setDefaultStyle();
  }

  void _setDefaultStyle() {
    if (defaultStyle.isNotEmpty) {
      defaultStyle.forEach((property, dynamic value) {
        style.setProperty(property, value);
      });
    }
  }

  void _setElementSizeType() {
    bool widthDefined = style.contains(WIDTH) || style.contains(MIN_WIDTH);
    bool heightDefined = style.contains(HEIGHT) || style.contains(MIN_HEIGHT);

    BoxSizeType widthType = widthDefined ? BoxSizeType.specified : BoxSizeType.automatic;
    BoxSizeType heightType = heightDefined ? BoxSizeType.specified : BoxSizeType.automatic;

    RenderBoxModel renderBoxModel = getRenderBoxModel();
    renderBoxModel.widthSizeType = widthType;
    renderBoxModel.heightSizeType = heightType;
  }

  void _scrollListener(double scrollOffset, AxisDirection axisDirection) {
    layoutStickyChildren(scrollOffset, axisDirection);
  }

  // Set sticky child offset according to scroll offset and direction
  void layoutStickyChild(Element child, double scrollOffset, AxisDirection axisDirection) {
    CSSStyleDeclaration childStyle = child.style;
    bool isFixed = false;
    RenderBox renderBoxModel = getRenderBoxModel();
    RenderBox childRenderBoxModel = child.getRenderBoxModel();

    if (child.originalScrollContainerOffset == null) {
      Offset horizontalScrollContainerOffset =
          childRenderBoxModel.localToGlobal(Offset.zero, ancestor: child.elementManager.getRootRenderObject())
              - renderBoxModel.localToGlobal(Offset.zero, ancestor: child.elementManager.getRootRenderObject());
      Offset verticalScrollContainerOffset =
          childRenderBoxModel.localToGlobal(Offset.zero, ancestor: child.elementManager.getRootRenderObject())
              - renderBoxModel.localToGlobal(Offset.zero, ancestor: child.elementManager.getRootRenderObject());

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

    RenderLayoutParentData boxParentData = childRenderBoxModel?.parentData;

    if (child.originalOffset == null) {
      child.originalOffset = boxParentData.offset;
    }

    double offsetY = child.originalOffset.dy;
    double offsetX = child.originalOffset.dx;

    double childHeight = childRenderBoxModel?.size?.height;
    double childWidth = childRenderBoxModel?.size?.width;
    // Sticky element cannot exceed the boundary of its parent element container
    RenderBox parentContainer = child.parent.renderLayoutBox;
    double minOffsetY = 0;
    double maxOffsetY = parentContainer.size.height - childHeight;
    double minOffsetX = 0;
    double maxOffsetX = parentContainer.size.width - childWidth;

    if (axisDirection == AxisDirection.down) {
      double offsetTop = child.originalScrollContainerOffset.dy - scrollOffset;
      double viewPortHeight = renderBoxModel?.size?.height;
      double offsetBottom = viewPortHeight - childHeight - offsetTop;

      if (childStyle.contains(TOP)) {
        double top = CSSLength.toDisplayPortValue(childStyle[TOP]) + resolvedPadding.top;
        isFixed = offsetTop < top;
        if (isFixed) {
          offsetY += top - offsetTop;
          if (offsetY > maxOffsetY) {
            offsetY = maxOffsetY;
          }
        }
      } else if (childStyle.contains(BOTTOM)) {
        double bottom = CSSLength.toDisplayPortValue(childStyle[BOTTOM]) + resolvedPadding.bottom;
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
      double viewPortWidth = renderBoxModel?.size?.width;
      double offsetRight = viewPortWidth - childWidth - offsetLeft;

      if (childStyle.contains(LEFT)) {
        double left = CSSLength.toDisplayPortValue(childStyle[LEFT]) + resolvedPadding.left;
        isFixed = offsetLeft < left;
        if (isFixed) {
          offsetX += left - offsetLeft;
          if (offsetX > maxOffsetX) {
            offsetX = maxOffsetX;
          }
        }
      } else if (childStyle.contains(RIGHT)) {
        double right = CSSLength.toDisplayPortValue(childStyle[RIGHT]) + resolvedPadding.right;
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
      childRenderBoxModel.markNeedsPaint();
    } else {
      // Change sticky status to relative
      if (child.stickyStatus == StickyPositionType.fixed) {
        child.stickyStatus = StickyPositionType.relative;
        // Reset child offset to its original offset
        childRenderBoxModel.markNeedsPaint();
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
    RenderBoxModel renderBoxModel = getRenderBoxModel();
    if (renderBoxModel.parentData is RenderLayoutParentData) {
      (renderBoxModel.parentData as RenderLayoutParentData).position = currentPosition;
    }
    // Move element according to position when it's already connected
    if (isConnected) {
      if (currentPosition == CSSPositionType.static) {
        // Loop renderObject children to move positioned children to its containing block
        renderLayoutBox.visitChildren((childRenderObject) {
          if (childRenderObject is RenderBoxModel) {
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
          RenderPositionHolder renderPositionHolder = renderBoxModel.renderPositionHolder;
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
          RenderLayoutParentData boxParentData = renderBoxModel?.parentData;
          boxParentData.isOffsetSet = false;
          renderBoxModel.markNeedsLayout();
          renderBoxModel.markNeedsPaint();
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
      renderIntrinsic.child = child;
    }
  }

  @override
  bool get attached {
    RenderBoxModel renderBoxModel = getRenderBoxModel();
    return renderBoxModel.attached;
  }

  // Attach renderObject of current node to parent
  @override
  void attachTo(Element parent, {RenderObject after}) {
    CSSStyleDeclaration parentStyle = parent.style;
    CSSDisplay parentDisplayValue =
       CSSSizing.getDisplay(CSSStyleDeclaration.isNullOrEmptyValue(parentStyle[DISPLAY]) ? parent.defaultDisplay : parentStyle[DISPLAY]);
    // InlineFlex or Flex
    bool isParentFlexDisplayType = parentDisplayValue == CSSDisplay.flex || parentDisplayValue == CSSDisplay.inlineFlex;

    CSSPositionType positionType = resolvePositionFromStyle(style);
    switch (positionType) {
      case CSSPositionType.absolute:
      case CSSPositionType.fixed:
        parent._addPositionedChild(this, positionType);
        parent.renderLayoutBox.markNeedsSortChildren();
        break;
      case CSSPositionType.sticky:
        parent._addStickyChild(this, after);
        parent.renderLayoutBox.markNeedsSortChildren();
        break;
      case CSSPositionType.relative:
      case CSSPositionType.static:
        RenderBoxModel renderBoxModel = getRenderBoxModel();
        parent.renderLayoutBox.insert(renderBoxModel, after: after);
        break;
    }

    /// Update flex siblings.
    if (isParentFlexDisplayType) parent.children.forEach(_updateFlexItemStyle);
  }

  // Detach renderObject of current node from parent
  @override
  void detach() {
    RenderBoxModel renderBoxModel = getRenderBoxModel();
    RenderPositionHolder renderPositionHolder = renderBoxModel.renderPositionHolder;
    // Remove placeholder of positioned element
    if (renderPositionHolder != null) {
      ContainerRenderObjectMixin parent = renderPositionHolder.parent;
      if (parent != null) {
        parent.remove(renderPositionHolder);
      }
    }
    (renderBoxModel.parent as ContainerRenderObjectMixin).remove(renderBoxModel);
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
            afterRenderObject = after?.getRenderBoxModel();
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
    RenderLayoutBox parentRenderLayoutBox;

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
    CSSDisplay childDisplay = CSSSizing.getDisplay(child.style[DISPLAY]);
    if (childDisplay != CSSDisplay.inline || (position != CSSPositionType.static)) {
      preferredSize = Size(
        CSSLength.toDisplayPortValue(child.style[WIDTH]) ?? 0,
        CSSLength.toDisplayPortValue(child.style[HEIGHT]) ?? 0,
      );
    }

    RenderPositionHolder childPositionHolder = RenderPositionHolder(preferredSize: preferredSize);

    RenderBoxModel childRenderBoxModel = child.getRenderBoxModel();
    child.parent.addChild(childPositionHolder);
    childRenderBoxModel.renderPositionHolder = childPositionHolder;
    setPositionedChildParentData(parentRenderLayoutBox, child);
    childPositionHolder.realDisplayedBox = childRenderBoxModel;

    parentRenderLayoutBox.add(childRenderBoxModel);
  }

  void _addStickyChild(Element child, RenderObject after) {
    RenderBoxModel childRenderBoxModel = child.getRenderBoxModel();
    renderLayoutBox.insert(childRenderBoxModel, after: after);

    // Set sticky element offset
    Element scrollContainer = findScrollContainer(child);
    // Flush layout first to calculate sticky offset
    if (!childRenderBoxModel.hasSize) {
      childRenderBoxModel.owner.flushLayout();
    }
    // Set sticky child offset manually
    scrollContainer.layoutStickyChild(child, 0, AxisDirection.down);
    scrollContainer.layoutStickyChild(child, 0, AxisDirection.right);
  }

  // Inline box including inline/inline-block/inline-flex/...
  bool get isInlineBox {
    String displayValue = style[DISPLAY];
    return displayValue.startsWith(INLINE);
  }

  // Inline content means children should be inline elements.
  bool get isInlineContent {
    String displayValue = style[DISPLAY];
    return displayValue == INLINE;
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
    ParentData childParentData = element.getRenderBoxModel().parentData;
    if (childParentData is RenderFlexParentData) {
      final RenderFlexParentData parentData = childParentData;
      RenderFlexParentData flexParentData = CSSFlex.getParentData(element.style);
      parentData.flexGrow = flexParentData.flexGrow;
      parentData.flexShrink = flexParentData.flexShrink;
      parentData.flexBasis = flexParentData.flexBasis;
      parentData.alignSelf = flexParentData.alignSelf;

      element.getRenderBoxModel().markNeedsLayout();
    }
  }

  void _onStyleChanged(String property, String original, String present, bool inAnimation) {

    switch (property) {
      case DISPLAY:
        _styleDisplayChangedListener(property, original, present);
        break;

      case POSITION:
      case Z_INDEX:
        _stylePositionChangedListener(property, original, present);
        break;

      case TOP:
      case LEFT:
      case BOTTOM:
      case RIGHT:
        _styleOffsetChangedListener(property, original, present);
        break;

      case FLEX_FLOW:
      case FLEX_DIRECTION:
      case FLEX_WRAP:
      case ALIGN_SELF:
      case ALIGN_CONTENT:
      case ALIGN_ITEMS:
      case JUSTIFY_CONTENT:
        _styleFlexChangedListener(property, original, present);
        break;

      case FLEX:
      case FLEX_GROW:
      case FLEX_SHRINK:
      case FLEX_BASIS:
        _styleFlexItemChangedListener(property, original, present);
        break;

      case TEXT_ALIGN:
        _styleTextAlignChangedListener(property, original, present);
        break;

      case PADDING:
      case PADDING_TOP:
      case PADDING_RIGHT:
      case PADDING_BOTTOM:
      case PADDING_LEFT:
        _stylePaddingChangedListener(property, original, present);
        break;

      case WIDTH:
      case MIN_WIDTH:
      case MAX_WIDTH:
      case HEIGHT:
      case MIN_HEIGHT:
      case MAX_HEIGHT:
        _styleSizeChangedListener(property, original, present);
        break;

      case OVERFLOW:
      case OVERFLOW_X:
      case OVERFLOW_Y:
        _styleOverflowChangedListener(property, original, present);
        break;

      case BACKGROUND:
      case BACKGROUND_COLOR:
      case BACKGROUND_ATTACHMENT:
      case BACKGROUND_IMAGE:
      case BACKGROUND_REPEAT:
      case BACKGROUND_POSITION:
      case BACKGROUND_SIZE:
      case BACKGROUND_CLIP:
      case BACKGROUND_ORIGIN:
        _styleBoxChangedListener(property, original, present);
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
        _styleBoxChangedListener(property, original, present);
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

    _updateChildNodesStyle();
  }

  void _styleDisplayChangedListener(String property, String original, String present) {
    // Display change may case width/height doesn't works at all.
    _styleSizeChangedListener(property, original, present);

    CSSDisplay originalDisplay = CSSSizing.getDisplay(CSSStyleDeclaration.isNullOrEmptyValue(original) ? defaultDisplay : original);
    CSSDisplay presentDisplay = CSSSizing.getDisplay(CSSStyleDeclaration.isNullOrEmptyValue(present) ? defaultDisplay : present);

    RenderBoxModel renderBoxModel = getRenderBoxModel();
    renderBoxModel.display = presentDisplay;

    if (renderLayoutBox != null) {
      if (originalDisplay != presentDisplay) {
        RenderLayoutBox prevRenderLayoutBox = renderLayoutBox;
        renderLayoutBox = createRenderLayout(this, prevRenderLayoutBox: prevRenderLayoutBox, repaintSelf: repaintSelf);
        renderLayoutBox.markNeedsLayout();
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
    updateRenderOffset(getRenderBoxModel(), property, present);
  }

  void _styleTextAlignChangedListener(String property, String original, String present) {
    _updateDecorationRenderLayoutBox();
  }

  void _updateDecorationRenderLayoutBox() {
    if (renderLayoutBox is RenderFlexLayout) {
      CSSFlexboxMixin.decorateRenderFlex(renderLayoutBox, style);
    } else if (renderLayoutBox is RenderFlowLayout) {
      CSSFlowMixin.decorateRenderFlow(renderLayoutBox, style);
    }
  }

  void _styleTransitionChangedListener(String property, String original, String present) {
    if (present != null) updateTransition(style);
  }

  void _styleOverflowChangedListener(String property, String original, String present) {
    updateRenderOverflow(getRenderBoxModel(), this, _scrollListener);
  }

  void _stylePaddingChangedListener(String property, String original, String present) {
    updateRenderPadding(getRenderBoxModel(), style, property, present);
  }

  void _styleSizeChangedListener(String property, String original, String present) {
    updateRenderSizing(getRenderBoxModel(), style, property, present);

    _setElementSizeType();

    if (property == WIDTH || property == HEIGHT) {
      updateRenderOffset(getRenderBoxModel(), property, present);
    }
  }

  void _styleMarginChangedListener(String property, String original, String present) {
    /// Update margin.
    updateRenderMargin(getRenderBoxModel(), style, property, present);
  }

  void _styleFlexChangedListener(String property, String original, String present) {
    _updateDecorationRenderLayoutBox();
  }

  void _styleFlexItemChangedListener(String property, String original, String present) {
    CSSDisplay display = CSSSizing.getDisplay(CSSStyleDeclaration.isNullOrEmptyValue(style[DISPLAY]) ? defaultDisplay : style[DISPLAY]);
    if (display == CSSDisplay.flex || display == CSSDisplay.inlineFlex) {
      children.forEach((Element child) {
        _updateFlexItemStyle(child);
      });
    }
  }

  void _styleBoxChangedListener(String property, String original, String present) {
    updateRenderDecoratedBox(getRenderBoxModel(), style, property, original, present);
  }

  void _styleOpacityChangedListener(String property, String original, String present) {
    // Update opacity.
    updateRenderOpacity(getRenderBoxModel(), this, present);
  }

  void _styleVisibilityChangedListener(String property, String original, String present) {
    // Update visibility
    updateRenderVisibility(CSSVisibilityMixin.getVisibility(present));
  }

  void _styleContentVisibilityChangedListener(String property, original, present) {
    // Update content visibility.
    updateRenderContentVisibility(CSSContentVisibilityMixin.getContentVisibility(present));
  }

  void _styleTransformChangedListener(String property, String original, String present) {
    // Update transform.
    updateRenderTransform(getRenderBoxModel(), present);
  }

  void _styleTransformOriginChangedListener(String property, String original, String present) {
    // Update transform.
    updateRenderTransformOrigin(getRenderBoxModel(), present);
  }

  // Update textNode style when container style changed
  void _updateChildNodesStyle() {
    childNodes.forEach((node) {
      if (node is TextNode) node.updateTextStyle();
    });
  }

  // Universal style property change callback.
  @mustCallSuper
  void setStyle(String key, value) {
    // @NOTE: See [CSSStyleDeclaration.setProperty], value change will trigger
    // [StyleChangeListener] to be invoked in sync.
    style.setProperty(key, value);
  }

  @mustCallSuper
  void setProperty(String key, value) {
    // Each key change will emit to `setStyle`
    if (key == STYLE) {
      assert(value is Map<String, dynamic>);
      // @TODO: Consider `{ color: red }` to `{}`, need to remove invisible keys.
      (value as Map<String, dynamic>).forEach(setStyle);
    } else {
      switch(key) {
        case 'scrollTop':
          // need to flush layout to get correct size
          elementManager.getRootRenderObject().owner.flushLayout();
          setScrollTop(value.toDouble());
          break;
        case 'scrollLeft':
          // need to flush layout to get correct size
          elementManager.getRootRenderObject().owner.flushLayout();
          setScrollLeft(value.toDouble());
          break;
      }
      properties[key] = value;
    }
  }

  @mustCallSuper
  dynamic getProperty(String key) {
    RenderBoxModel renderBoxModel = getRenderBoxModel();
    switch(key) {
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
        return renderBoxModel.hasSize ? renderBoxModel.size.width : 0;
      case 'offsetHeight':
        // need to flush layout to get correct size
        elementManager.getRootRenderObject().owner.flushLayout();
        return renderBoxModel.hasSize ? renderBoxModel.size.height : 0;
        // @TODO support clientWidth clientHeight clientLeft clientTop
      case 'clientWidth':
        // need to flush layout to get correct size
        elementManager.getRootRenderObject().owner.flushLayout();
        return renderLayoutBox.clientWidth;
      case 'clientHeight':
        // need to flush layout to get correct size
        elementManager.getRootRenderObject().owner.flushLayout();
        return renderLayoutBox.clientHeight;
      case 'clientLeft':
        // need to flush layout to get correct size
        elementManager.getRootRenderObject().owner.flushLayout();
        return renderLayoutBox.borderLeft;
        break;
      case 'clientTop':
        // need to flush layout to get correct size
        elementManager.getRootRenderObject().owner.flushLayout();
        return renderLayoutBox.borderTop;
        break;
      case 'scrollTop':
        return getScrollTop();
      case 'scrollLeft':
        return getScrollLeft();
      case 'scrollHeight':
        return getScrollHeight(getRenderBoxModel());
      case 'scrollWidth':
        return getScrollWidth(getRenderBoxModel());
      case 'getBoundingClientRect':
        return getBoundingClientRect();
      default:
        return properties[key];
    }
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
    RenderBoxModel renderBoxModel = getRenderBoxModel();
    RenderBox sizedBox = renderBoxModel;
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
    RenderBoxModel renderBoxModel = getRenderBoxModel();
    if (renderBoxModel.attached) {
      Offset relative = getOffset(renderBoxModel);
      offset += relative.dx;
    }
    return offset;
  }

  double getOffsetY() {
    double offset = 0;
    RenderBoxModel renderBoxModel = getRenderBoxModel();
    if (renderBoxModel.attached) {
      Offset relative = getOffset(renderBoxModel);
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
    return renderBox.localToGlobal(Offset.zero, ancestor: element.getRenderBoxModel());
  }

  @override
  void addEvent(String eventName) {
    if (eventHandlers.containsKey(eventName)) return; // Only listen once.
    bool isIntersectionObserverEvent = _isIntersectionObserverEvent(eventName);
    bool hasIntersectionObserverEvent = isIntersectionObserverEvent && _hasIntersectionObserverEvent(eventHandlers);
    super.addEventListener(eventName, _eventResponder);

    // bind pointer responder.
    addEventResponder(getRenderBoxModel());

    // Only add listener once for all intersection related event
    if (isIntersectionObserverEvent && !hasIntersectionObserverEvent) {
      RenderBoxModel renderBoxModel = getRenderBoxModel();
      renderBoxModel.addIntersectionChangeListener(handleIntersectionChange);
    }
  }

  void removeEvent(String eventName) {
    if (!eventHandlers.containsKey(eventName)) return; // Only listen once.
    super.removeEventListener(eventName, _eventResponder);

    // Remove pointer responder.
    removeEventResponder(getRenderBoxModel());

    // Remove listener when no intersection related event
    if (_isIntersectionObserverEvent(eventName) && !_hasIntersectionObserverEvent(eventHandlers)) {
      RenderBoxModel renderBoxModel = getRenderBoxModel();
      renderBoxModel.removeIntersectionChangeListener(handleIntersectionChange);
    }
  }

  void _eventResponder(Event event) {
    String json = jsonEncode([targetId, event]);
    emitUIEvent(elementManager.controller.contextId, json);
  }

  void click() {
    Event clickEvent = Event('click', EventInit());
    RenderBoxModel renderBoxModel = getRenderBoxModel();

    if (isConnected) {
      final RenderBox box = renderBoxModel;
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
          hitTest = currentElement.getRenderBoxModel().hitTest(boxHitTestResult, position: position);
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
    RenderBoxModel renderBoxModel = getRenderBoxModel();

    RenderObject parent = renderBoxModel.parent;
    if (!renderBoxModel.isRepaintBoundary) {
      RenderBoxModel renderReplacedBoxModel;
      if (renderBoxModel is RenderLayoutBox) {
        renderLayoutBox = renderReplacedBoxModel = createRenderLayout(this, prevRenderLayoutBox: renderBoxModel, repaintSelf: true);
      } else {
        renderIntrinsic = renderReplacedBoxModel = createRenderIntrinsic(this, prevRenderIntrinsic: renderBoxModel, repaintSelf: true);
      }

      if (parent is RenderObjectWithChildMixin<RenderBox>) {
        parent.child = null;
        parent.child = renderReplacedBoxModel;
      } else if (parent is ContainerRenderObjectMixin) {
        ContainerBoxParentData parentData = renderBoxModel.parentData;
        RenderObject previousSibling = parentData.previousSibling;
        parent.remove(renderBoxModel);
        parent.insert(renderReplacedBoxModel, after: previousSibling);
      }
      renderBoxModel = renderReplacedBoxModel;
    }

    renderBoxModel.markNeedsLayout();
    renderBoxModel.markNeedsPaint();

    SchedulerBinding.instance.addPostFrameCallback((_) async {
      Uint8List captured;
      if (renderBoxModel.size == Size.zero) {
        // Return a blob with zero length.
        captured = Uint8List(0);
      } else {
        Image image = await renderBoxModel.toImage(pixelRatio: devicePixelRatio);
        ByteData byteData = await image.toByteData(format: ImageByteFormat.png);
        captured = byteData.buffer.asUint8List();
      }

      completer.complete(captured);
    });

    return completer.future;
  }
}

RenderLayoutBox createRenderLayout(Element element, {RenderLayoutBox prevRenderLayoutBox, bool repaintSelf = false}) {
  CSSStyleDeclaration style = element.style;
  CSSDisplay display = CSSSizing.getDisplay(CSSStyleDeclaration.isNullOrEmptyValue(style[DISPLAY]) ? element.defaultDisplay : style[DISPLAY]);
  if (display == CSSDisplay.flex || display == CSSDisplay.inlineFlex) {
    RenderFlexLayout flexLayout;

    if (prevRenderLayoutBox == null) {
      if (repaintSelf) {
        flexLayout = RenderSelfRepaintFlexLayout(style: style, targetId: element.targetId, elementManager: element.elementManager);
      } else {
        flexLayout = RenderFlexLayout(style: style, targetId: element.targetId, elementManager: element.elementManager);
      }

    } else if (prevRenderLayoutBox is RenderFlowLayout) {
      if (prevRenderLayoutBox is RenderSelfRepaintFlowLayout) {
        if (repaintSelf) {
          // RenderSelfRepaintFlowLayout --> RenderSelfRepaintFlexLayout
          flexLayout = prevRenderLayoutBox.toFlexLayout();
        } else {
          // RenderSelfRepaintFlowLayout --> RenderFlexLayout
          flexLayout = prevRenderLayoutBox.toParentRepaintFlexLayout();
        }
      } else {
        if (repaintSelf) {
          // RenderFlowLayout --> RenderSelfRepaintFlexLayout
          flexLayout = prevRenderLayoutBox.toSelfRepaintFlexLayout();
        } else {
          // RenderFlowLayout --> RenderFlexLayout
          flexLayout = prevRenderLayoutBox.toFlexLayout();
        }
      }
    } else if (prevRenderLayoutBox is RenderFlexLayout) {
      if (prevRenderLayoutBox is RenderSelfRepaintFlexLayout) {
        if (repaintSelf) {
          // RenderSelfRepaintFlexLayout --> RenderSelfRepaintFlexLayout
          flexLayout = prevRenderLayoutBox;
          return flexLayout;
        } else {
          // RenderSelfRepaintFlexLayout --> RenderFlexLayout
          flexLayout = prevRenderLayoutBox.toParentRepaint();
        }
      } else {
        if (repaintSelf) {
          // RenderFlexLayout --> RenderSelfRepaintFlexLayout
          flexLayout = prevRenderLayoutBox.toSelfRepaint();
        } else {
          // RenderFlexLayout --> RenderFlexLayout
          flexLayout = prevRenderLayoutBox;
          return flexLayout;
        }
      }
    }

    CSSFlexboxMixin.decorateRenderFlex(flexLayout, style);
    return flexLayout;
  } else if (display == CSSDisplay.block || display == CSSDisplay.none || display == CSSDisplay.inline || display == CSSDisplay.inlineBlock) {
    RenderFlowLayout flowLayout;

    if (prevRenderLayoutBox == null) {
      if (repaintSelf) {
        flowLayout = RenderSelfRepaintFlowLayout(style: style, targetId: element.targetId, elementManager: element.elementManager);
      } else {
        flowLayout = RenderFlowLayout(style: style, targetId: element.targetId, elementManager: element.elementManager);
      }
    } else if (prevRenderLayoutBox is RenderFlowLayout) {
      if (prevRenderLayoutBox is RenderSelfRepaintFlowLayout) {
        if (repaintSelf) {
          // RenderSelfRepaintFlowLayout --> RenderSelfRepaintFlowLayout
          flowLayout = prevRenderLayoutBox;
          return flowLayout;
        } else {
          // RenderSelfRepaintFlowLayout --> RenderFlowLayout
          flowLayout = prevRenderLayoutBox.toParentRepaint();
        }
      } else {
        if (repaintSelf) {
          // RenderFlowLayout --> RenderSelfRepaintFlowLayout
          flowLayout = prevRenderLayoutBox.toSelfRepaint();
        } else {
          // RenderFlowLayout --> RenderFlowLayout
          flowLayout = prevRenderLayoutBox;
          return flowLayout;
        }
      }
    } else if (prevRenderLayoutBox is RenderFlexLayout) {
      if (prevRenderLayoutBox is RenderSelfRepaintFlexLayout) {
        if (repaintSelf) {
          // RenderSelfRepaintFlexLayout --> RenderSelfRepaintFlowLayout
          flowLayout = prevRenderLayoutBox.toFlowLayout();
        } else {
          // RenderSelfRepaintFlexLayout --> RenderFlowLayout
          flowLayout = prevRenderLayoutBox.toParentRepaintFlowLayout();
        }
      } else {
        if (repaintSelf) {
          // RenderFlexLayout --> RenderSelfRepaintFlowLayout
          flowLayout = prevRenderLayoutBox.toSelfRepaintFlowLayout();
        } else {
          // RenderFlexLayout --> RenderFlowLayout
          flowLayout = prevRenderLayoutBox.toFlowLayout();
        }
      }
    }

    CSSFlowMixin.decorateRenderFlow(flowLayout, style);
    return flowLayout;
  } else {
    throw FlutterError('Not supported display type $display');
  }
}

RenderIntrinsic createRenderIntrinsic(Element element, {RenderIntrinsic prevRenderIntrinsic, bool repaintSelf = false}) {
  RenderIntrinsic intrinsic;

  if (prevRenderIntrinsic == null) {
    if (repaintSelf) {
      intrinsic = RenderSelfRepaintIntrinsic(element.targetId, element.style, element.elementManager);
    } else {
      intrinsic = RenderIntrinsic(element.targetId, element.style, element.elementManager);
    }
  } else {
    if (prevRenderIntrinsic is RenderSelfRepaintIntrinsic) {
      if (repaintSelf) {
        // RenderSelfRepaintIntrinsic --> RenderSelfRepaintIntrinsic
        intrinsic = prevRenderIntrinsic;
      } else {
        // RenderSelfRepaintIntrinsic --> RenderIntrinsic
        intrinsic = prevRenderIntrinsic.toParentRepaint();
      }
    } else {
      if (repaintSelf) {
        // RenderIntrinsic --> RenderSelfRepaintIntrinsic
        intrinsic = prevRenderIntrinsic.toSelfRepaint();
      } else {
        // RenderIntrinsic --> RenderIntrinsic
        intrinsic = prevRenderIntrinsic;
      }
    }
  }
  return intrinsic;
}


Element findContainingBlock(Element element) {
  Element _el = element?.parent;
  Element rootEl = element.elementManager.getRootElement();

  while (_el != null) {
    bool isElementNonStatic = _el.style[POSITION] != STATIC && _el.style[POSITION].isNotEmpty;
    bool hasTransform = _el.style[TRANSFORM].isNotEmpty;
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
    List<CSSOverflowType> overflow = getOverflowTypes(_el.style);
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
    List<CSSOverflowType> overflow = getOverflowTypes(child.style);
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
  if (style.contains(POSITION)) {
    String position = style[POSITION];
    return position != '' && position != STATIC;
  } else {
    return false;
  }
}

void setPositionedChildParentData(
    RenderLayoutBox parentRenderLayoutBox, Element child) {
  var parentData;
  if (parentRenderLayoutBox is RenderFlowLayout) {
    parentData = RenderLayoutParentData();
  } else {
    parentData = RenderFlexParentData();
  }
  CSSStyleDeclaration style = child.style;

  CSSPositionType positionType = resolvePositionFromStyle(style);
  parentData.position = positionType;

  if (style.contains(TOP)) {
    parentData.top = CSSLength.toDisplayPortValue(style[TOP]);
  }
  if (style.contains(LEFT)) {
    parentData.left = CSSLength.toDisplayPortValue(style[LEFT]);
  }
  if (style.contains(BOTTOM)) {
    parentData.bottom = CSSLength.toDisplayPortValue(style[BOTTOM]);
  }
  if (style.contains(RIGHT)) {
    parentData.right = CSSLength.toDisplayPortValue(style[RIGHT]);
  }
  parentData.width = CSSLength.toDisplayPortValue(style[WIDTH]) ?? 0.0;
  parentData.height = CSSLength.toDisplayPortValue(style[HEIGHT]) ?? 0.0;

  int zIndex = CSSLength.toInt(style[Z_INDEX]) ?? 0;
  parentData.zIndex = zIndex;

  parentData.isPositioned = positionType == CSSPositionType.absolute || positionType == CSSPositionType.fixed;

  RenderBoxModel childRenderBoxModel = child.getRenderBoxModel();
  childRenderBoxModel.parentData = parentData;
}
