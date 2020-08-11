/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:ui';
import 'dart:math' as math;
import 'package:kraken/css.dart';
import 'package:flutter/rendering.dart';
import 'package:kraken/element.dart';
import 'package:kraken/rendering.dart';
import 'padding.dart';

class RenderLayoutParentData extends ContainerBoxParentData<RenderBox> {
  /// The distance by which the child's top edge is inset from the top of the stack.
  double top;

  /// The distance by which the child's right edge is inset from the right of the stack.
  double right;

  /// The distance by which the child's bottom edge is inset from the bottom of the stack.
  double bottom;

  /// The distance by which the child's left edge is inset from the left of the stack.
  double left;

  /// The child's width.
  ///
  /// Ignored if both left and right are non-null.
  double width;

  /// The child's height.
  ///
  /// Ignored if both top and bottom are non-null.
  double height;

  bool isPositioned = false;

  /// Row index of child when wrapping
  int runIndex = 0;

  RenderPositionHolder renderPositionHolder;
  int zIndex = 0;
  CSSPositionType position = CSSPositionType.static;

  /// Get element original position offset to parent(layoutBox) should be.
  Offset get stackedChildOriginalRelativeOffset {
    if (renderPositionHolder == null) return Offset.zero;
    return (renderPositionHolder.parentData as BoxParentData).offset;
  }

  // Whether offset is already set
  bool isOffsetSet = false;

  @override
  String toString() {
    return 'zIndex=$zIndex; position=$position; isPositioned=$isPositioned; renderPositionHolder=$renderPositionHolder; ${super.toString()}; runIndex: $runIndex;';
  }
}

class RenderLayoutBox extends RenderBoxModel
    with
        ContainerRenderObjectMixin<RenderBox, ContainerBoxParentData<RenderBox>>,
        RenderBoxContainerDefaultsMixin<RenderBox, ContainerBoxParentData<RenderBox>> {
  RenderLayoutBox({int targetId, CSSStyleDeclaration style, ElementManager elementManager})
      : super(targetId: targetId, style: style, elementManager: elementManager);
}

class RenderBoxModel extends RenderBox with RenderPaddingMixin, RenderOverflowMixin, RenderPointerListenerMixin {
  RenderBoxModel({this.targetId, this.style, this.elementManager});

  bool _debugHasBoxLayout = false;

  BoxConstraints _contentConstraints;
  BoxConstraints get contentConstraints {
    assert(_debugHasBoxLayout, 'can not access contentConstraints, RenderBoxModel has not layout: ${toString()}');
    assert(_contentConstraints != null);
    return _contentConstraints;
  }

  // id of current element
  int targetId;

  // Element style;
  CSSStyleDeclaration style;

  ElementManager elementManager;

  BoxSizeType widthSizeType;
  BoxSizeType heightSizeType;

  RenderBoxModel fromCopy(RenderBoxModel newBox) {
    if (padding != null) {
      newBox.padding = padding;
    }

    return newBox;
  }

  // @FIXME: fake border width, remove this after border had merged into renderObject.
  double borderLeft = 0.0;
  double borderTop = 0.0;
  double borderRight = 0.0;
  double borderBottom = 0.0;

  double _width;
  double get width {
    return _width;
  }
  set width(double value) {
    if (_width == value) return;
    _width = value;
    markNeedsLayout();
  }

  double _height;
  double get height {
    return _height;
  }
  set height(double value) {
    if (_height == value) return;
    _height = value;
    markNeedsLayout();
  }

  double _minWidth;
  double get minWidth {
    return _minWidth;
  }
  set minWidth(double value) {
    if (_minWidth == value) return;
    _minWidth = value;
    markNeedsLayout();
  }

  double _maxWidth;
  double get maxWidth {
    return _maxWidth;
  }
  set maxWidth(double value) {
    if (_maxWidth == value) return;
    _maxWidth = value;
    markNeedsLayout();
  }

  double _minHeight;
  double get minHeight {
    return _minHeight;
  }
  set minHeight(double value) {
    if (_minHeight == value) return;
    _minHeight = value;
    markNeedsLayout();
  }

  double _maxHeight;
  double get maxHeight {
    return _maxHeight;
  }
  set maxHeight(double value) {
    if (_maxHeight == value) return;
    _maxHeight = value;
    markNeedsLayout();
  }

  double getContentWidth() {
    double cropWidth = 0;
    // @FIXME, need to remove elementManager in the future.
    Node hostNode = elementManager.getEventTargetByTargetId<Node>(targetId);
    Element hostElement;
    CSSStyleDeclaration style;
    String display;
    if (hostNode is Element) {
      style = hostNode.style;
      display = RenderSizingHelper.getElementRealDisplayValue(targetId, elementManager);
      hostElement = hostNode;
    } else if (hostNode is TextNode) {
      style = hostNode.parent.style;
      display = RenderSizingHelper.getElementRealDisplayValue(hostNode.parent.targetId, elementManager);
      hostElement = hostNode.parentElement;
    }

    double width = _width;

    void cropMargin(Element childNode) {
      cropWidth += childNode.cropMarginWidth;
    }

    void cropPaddingBorder(Element childNode) {
      cropWidth += childNode.cropBorderWidth;
      cropWidth += childNode.cropPaddingWidth;
    }

    if (minWidth != null && (width == null || width < minWidth)) {
      width = minWidth;
    } else if (maxWidth != null && (width == null || width > maxWidth)) {
      width = maxWidth;
    }

    switch (display) {
      case BLOCK:
      case FLEX:
        // Get own width if exists else get the width of nearest ancestor width width
        if (style.contains(WIDTH)) {
          width = CSSLength.toDisplayPortValue(style[WIDTH]) ?? 0;
          cropPaddingBorder(hostElement);
        } else {
          while (true) {
            if (hostElement.parentNode != null) {
              cropMargin(hostElement);
              cropPaddingBorder(hostElement);
              hostElement = hostElement.parentNode;
            } else {
              break;
            }
            if (hostElement is Element) {
              CSSStyleDeclaration style = hostElement.style;
              String display = RenderSizingHelper.getElementRealDisplayValue(hostElement.targetId, elementManager);

              // Set width of element according to parent display
              if (display != INLINE) {
                // Skip to find upper parent
                if (style.contains(WIDTH)) {
                  // Use style width
                  width = CSSLength.toDisplayPortValue(style[WIDTH]) ?? 0;
                  cropPaddingBorder(hostElement);
                  break;
                } else if (display == INLINE_BLOCK || display == INLINE_FLEX) {
                  // Collapse width to children
                  width = null;
                  break;
                }
              }
            }
          }
        }
        break;
      case INLINE_BLOCK:
      case INLINE_FLEX:
        if (style.contains(WIDTH)) {
          width = CSSLength.toDisplayPortValue(style[WIDTH]) ?? 0;
          cropPaddingBorder(hostNode);
        } else {
          width = null;
        }
        break;
      case INLINE:
        width = null;
        break;
      default:
        break;
    }

    if (width != null) {
      return math.max(0, width - cropWidth);
    } else {
      return null;
    }
  }

  double getContentHeight() {
    Node hostNode = elementManager.getEventTargetByTargetId<Node>(targetId);

    Element hostElement;
    CSSStyleDeclaration style;
    String display;
    if (hostNode is Element) {
      hostElement = hostNode;
      style = hostNode.style;
      display = RenderSizingHelper.getElementRealDisplayValue(targetId, elementManager);
    } else if (hostNode is TextNode) {
      hostElement = hostNode.parent;
      style = hostElement.style;
      display = RenderSizingHelper.getElementRealDisplayValue(hostElement.targetId, elementManager);
    }

    double height = _height;
    double cropHeight = 0;

    void cropMargin(Element childNode) {
      cropHeight += childNode.cropMarginHeight;
    }

    void cropPaddingBorder(Element childNode) {
      cropHeight += childNode.cropBorderHeight;
      cropHeight += childNode.cropPaddingHeight;
    }

    if (minHeight != null && (height == null || height < minHeight)) {
      height = minHeight;
    } else if (maxHeight != null && (height == null || height > maxHeight)) {
      height = maxHeight;
    }

    // inline element has no height
    if (display == INLINE) {
      return null;
    } else if (style.contains(HEIGHT)) {
      if (hostElement is Element) {
        height = CSSLength.toDisplayPortValue(style[HEIGHT]) ?? 0;
        cropPaddingBorder(hostElement);
      }
    } else {
      while (true) {
        Element current;
        if (hostElement.parentNode != null) {
          cropMargin(hostElement);
          cropPaddingBorder(hostElement);
          current = hostElement;
          hostElement = hostElement.parentNode;
        } else {
          break;
        }
        if (hostElement is Element) {
          CSSStyleDeclaration style = hostElement.style;
          if (RenderSizingHelper.isStretchChildHeight(hostElement, current)) {
            if (style.contains(HEIGHT)) {
              height = CSSLength.toDisplayPortValue(style[HEIGHT]) ?? 0;
              cropPaddingBorder(hostElement);
              break;
            }
          } else {
            break;
          }
        }
      }
    }
    if (height != null) {
      return math.max(0, height - cropHeight);
    } else {
      return null;
    }
  }

  set size(Size value) {
    // set scrollable size from unconstrainted size.
    maxScrollableX = value.width;
    maxScrollableY = value.height;

    Size boxSize = _contentSize = contentConstraints.constrain(value);;
    if (padding != null) {
      boxSize = wrapPaddingSize(boxSize);
    }

    super.size = super.constraints.constrain(boxSize);
  }

  // the contentSize of layout box
  Size _contentSize;
  Size get contentSize {
    if (_contentSize == null) {
      return Size(0, 0);
    }
    return _contentSize;
  }

  double get clientWidth {
    double width = contentSize.width;
    if (padding != null) {
      width += padding.horizontal;
    }
    return width;
  }

  double get clientHeight {
    double height = contentSize.height;
    if (padding != null) {
      height += padding.vertical;
    }
    return height;
  }

  // base layout methods to compute content constraints before content box layout.
  // call this method before content box layout.
  BoxConstraints beforeLayout() {
    _debugHasBoxLayout = true;
    final double contentWidth = getContentWidth();
    final double contentHeight = getContentHeight();
    if (contentWidth != null || contentHeight != null) {
      _contentConstraints = BoxConstraints(
        minWidth: 0.0,
        maxWidth: contentWidth != null ? contentWidth : double.infinity,
        minHeight: 0.0,
        maxHeight: contentHeight != null ? contentHeight : double.infinity
      );
    } else {
      _contentConstraints = super.constraints;
    }

    return _contentConstraints;
  }

  @override
  void applyPaintTransform(RenderBox child, Matrix4 transform) {
    super.applyPaintTransform(child, transform);
    applyOverflowPaintTransform(child, transform);
  }

  // the max scrollable size of X axis.
  double maxScrollableX;
  // the max scrollable size of Y axis.
  double maxScrollableY;

  // hooks when content box had layout.
  void didLayout() {
    Size scrollableSize = Size(
        maxScrollableX + paddingLeft + paddingRight,
        maxScrollableY + paddingTop + paddingBottom
    );
    setUpOverflowScroller(scrollableSize);
  }

  void basePaint(PaintingContext context, Offset offset, PaintingContextCallback callback) {
    paintOverflow(context, offset, callback);
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty('padding', padding));
    properties.add(DiagnosticsProperty('width', width));
    properties.add(DiagnosticsProperty('height', height));
    properties.add(DiagnosticsProperty('maxWidth', maxWidth));
    properties.add(DiagnosticsProperty('minWidth', minWidth));
    properties.add(DiagnosticsProperty('maxHeight', maxHeight));
    properties.add(DiagnosticsProperty('minHeight', minHeight));
    properties.add(DiagnosticsProperty('contentSize', _contentSize));
    properties.add(DiagnosticsProperty('contentConstraints', _contentConstraints));
  }
}
