/*
 * Copyright (C) 2021-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:kraken/css.dart';
import 'package:kraken/dom.dart';
import 'package:kraken/rendering.dart';

// CSS Positioned Layout: https://drafts.csswg.org/css-position/

BoxSizeType? _getChildWidthSizeType(RenderBox child) {
  if (child is RenderTextBox) {
    return child.widthSizeType;
  } else if (child is RenderBoxModel) {
    return child.widthSizeType;
  }
  return null;
}

BoxSizeType? _getChildHeightSizeType(RenderBox child) {
  if (child is RenderTextBox) {
    return child.heightSizeType;
  } else if (child is RenderBoxModel) {
    return child.heightSizeType;
  }
  return null;
}

// RenderPositionHolder may be affected by overflow: scroller offset.
// We need to reset these offset to keep positioned elements render at their original position.
// @NOTE: Attention that renderObjects in tree may not all subtype of RenderBoxModel, use `is` to identify.
Offset? _getRenderPositionHolderScrollOffset(RenderPositionPlaceholder holder, RenderObject root) {
  AbstractNode? current = holder.parent;
  while (current != null && current != root) {
    if (current is RenderBoxModel) {
      if (current.clipX || current.clipY) {
        return Offset(current.scrollLeft, current.scrollTop);
      }
    }
    current = current.parent;
  }
  return null;
}

// Get the offset of the RenderPlaceholder of positioned element to its parent RenderBoxModel.
Offset _getPlaceholderToParentOffset(RenderPositionPlaceholder placeholder, RenderBoxModel parent) {
  if (!placeholder.attached) {
    return Offset.zero;
  }
  Offset positionHolderScrollOffset = _getRenderPositionHolderScrollOffset(placeholder, parent) ?? Offset.zero;
  Offset placeholderOffset = placeholder.localToGlobal(positionHolderScrollOffset, ancestor: parent);
  return placeholderOffset;
}


// Margin auto has special rules for positioned element
// which will override the default position rule
// https://www.w3.org/TR/CSS21/visudet.html#abs-non-replaced-width
Offset _getAutoMarginPositionedElementOffset(double? x, double? y, RenderBoxModel child, Size parentSize) {
  RenderStyle childRenderStyle = child.renderStyle;

  CSSLengthValue marginLeft = childRenderStyle.marginLeft;
  CSSLengthValue marginRight = childRenderStyle.marginRight;
  CSSLengthValue marginTop = childRenderStyle.marginTop;
  CSSLengthValue marginBottom = childRenderStyle.marginBottom;
  CSSLengthValue width = childRenderStyle.width;
  CSSLengthValue height = childRenderStyle.height;
  CSSLengthValue left = childRenderStyle.left;
  CSSLengthValue right = childRenderStyle.right;
  CSSLengthValue top = childRenderStyle.top;
  CSSLengthValue bottom = childRenderStyle.bottom;

  // 'left' + 'margin-left' + 'border-left-width' + 'padding-left' + 'width' + 'padding-right'
  // + 'border-right-width' + 'margin-right' + 'right' = width of containing block
  if (left.isNotAuto && right.isNotAuto &&
    (child is! RenderIntrinsic || width.isNotAuto)) {
    if (marginLeft.isAuto) {
      double leftValue = left.computedValue;
      double rightValue = right.computedValue;
      double remainingSpace = parentSize.width - child.boxSize!.width - leftValue - rightValue;

      if (marginRight.isAuto) {
        x = leftValue + remainingSpace / 2;
      } else {
        x = leftValue + remainingSpace;
      }
    }
  }

  if (top.isNotAuto && bottom.isNotAuto &&
    (child is! RenderIntrinsic || height.isNotAuto)) {
    if (marginTop.isAuto) {
      double topValue = top.computedValue;
      double bottomValue = bottom.computedValue;
      double remainingSpace = parentSize.height - child.boxSize!.height - topValue - bottomValue;

      if (marginBottom.isAuto) {
        y = topValue + remainingSpace / 2;
      } else {
        y = topValue + remainingSpace;
      }
    }
  }
  return Offset(x ?? 0, y ?? 0);
}

class CSSPositionedLayout {
  static RenderLayoutParentData getPositionParentData(RenderBoxModel renderBoxModel, RenderLayoutParentData parentData) {
    CSSPositionType positionType = renderBoxModel.renderStyle.position;
    parentData.isPositioned = positionType == CSSPositionType.absolute || positionType == CSSPositionType.fixed;
    return parentData;
  }

  static Offset? getRelativeOffset(RenderStyle renderStyle) {
      CSSLengthValue left = renderStyle.left;
      CSSLengthValue right = renderStyle.right;
      CSSLengthValue top = renderStyle.top;
      CSSLengthValue bottom = renderStyle.bottom;
      if (renderStyle.position == CSSPositionType.relative) {
        double? dx;
        double? dy;

        if (left.isNotAuto) {
          dx = renderStyle.left.computedValue;
        } else if (right.isNotAuto) {
          double _dx = renderStyle.right.computedValue;
          dx = -_dx;
        }

        if (top.isNotAuto) {
          dy = renderStyle.top.computedValue;
        } else if (bottom.isNotAuto) {
          double _dy = renderStyle.bottom.computedValue;
          dy = -_dy;
        }

        if (dx != null || dy != null) {
          return Offset(dx ?? 0, dy ?? 0);
        }
      }
      return null;
    }

  static void applyRelativeOffset(Offset? relativeOffset, RenderBox renderBox) {
    RenderLayoutParentData? boxParentData = renderBox.parentData as RenderLayoutParentData?;

    if (boxParentData != null) {
      Offset? styleOffset;
      // Text node does not have relative offset
      if (renderBox is RenderBoxModel) {
        styleOffset = getRelativeOffset(renderBox.renderStyle);
      }

      if (relativeOffset != null) {
        if (styleOffset != null) {
          boxParentData.offset = relativeOffset.translate(styleOffset.dx, styleOffset.dy);
        } else {
          boxParentData.offset = relativeOffset;
        }
      } else {
        boxParentData.offset = styleOffset!;
      }
    }
  }

  static bool isSticky(RenderBoxModel child) {
    final renderStyle = child.renderStyle;
    return renderStyle.position == CSSPositionType.sticky &&
        (renderStyle.top.isNotAuto ||
        renderStyle.left.isNotAuto ||
        renderStyle.bottom.isNotAuto ||
        renderStyle.right.isNotAuto);
  }

  /// Set horizontal offset of sticky element
  static bool _applyStickyChildHorizontalOffset(
    RenderBoxModel scrollContainer,
    RenderBoxModel child,
    Offset childOriginalOffset,
    Offset childToScrollContainerOffset,
  ) {
    bool isHorizontalFixed = false;
    double offsetX = childOriginalOffset.dx;
    double childWidth = child.boxSize!.width;
    double scrollContainerWidth = scrollContainer.boxSize!.width;
    // Dynamic offset to scroll container
    double offsetLeftToScrollContainer = childToScrollContainerOffset.dx - scrollContainer.scrollLeft;
    double offsetRightToScrollContainer = scrollContainerWidth - childWidth - offsetLeftToScrollContainer;
    RenderStyle childRenderStyle = child.renderStyle;
    RenderStyle? scrollContainerRenderStyle = scrollContainer.renderStyle;

    if (childRenderStyle.left.isNotAuto) {
      // Sticky offset to scroll container must include padding and border
      double stickyLeft = childRenderStyle.left.computedValue +
        scrollContainerRenderStyle.paddingLeft.computedValue +
        scrollContainerRenderStyle.effectiveBorderLeftWidth.computedValue;
      isHorizontalFixed = offsetLeftToScrollContainer < stickyLeft;
      if (isHorizontalFixed) {
        offsetX += stickyLeft - offsetLeftToScrollContainer;
        // Sticky child can not exceed the left boundary of its parent container
        RenderBoxModel parentContainer = child.parent as RenderBoxModel;
        double maxOffsetX = parentContainer.boxSize!.width - childWidth;
        if (offsetX > maxOffsetX) {
          offsetX = maxOffsetX;
        }
      }
    } else if (childRenderStyle.left.isNotAuto) {
      // Sticky offset to scroll container must include padding and border
      double stickyRight = childRenderStyle.right.computedValue +
        scrollContainerRenderStyle.paddingRight.computedValue +
        scrollContainerRenderStyle.effectiveBorderRightWidth.computedValue;
      isHorizontalFixed = offsetRightToScrollContainer < stickyRight;
      if (isHorizontalFixed) {
        offsetX += offsetRightToScrollContainer - stickyRight;
        // Sticky element can not exceed the right boundary of its parent container
        double minOffsetX = 0;
        if (offsetX < minOffsetX) {
          offsetX = minOffsetX;
        }
      }
    }

    RenderLayoutParentData boxParentData = child.parentData as RenderLayoutParentData;
    boxParentData.offset = Offset(
      offsetX,
      boxParentData.offset.dy,
    );
    return isHorizontalFixed;
  }

  /// Set vertical offset of sticky element
  static bool _applyStickyChildVerticalOffset(
    RenderBoxModel scrollContainer,
    RenderBoxModel child,
    Offset childOriginalOffset,
    Offset childToScrollContainerOffset,
  ) {
    bool isVerticalFixed = false;
    double offsetY = childOriginalOffset.dy;
    double childHeight = child.boxSize!.height;
    double scrollContainerHeight = scrollContainer.boxSize!.height;
    // Dynamic offset to scroll container
    double offsetTopToScrollContainer = childToScrollContainerOffset.dy;
    double offsetBottomToScrollContainer = scrollContainerHeight - childHeight - offsetTopToScrollContainer;
    RenderStyle childRenderStyle = child.renderStyle;
    RenderStyle? scrollContainerRenderStyle = scrollContainer.renderStyle;

    if (childRenderStyle.top.isNotAuto) {
      // Sticky offset to scroll container must include padding and border
      double stickyTop = childRenderStyle.top.computedValue +
        scrollContainerRenderStyle.paddingTop.computedValue +
        scrollContainerRenderStyle.effectiveBorderTopWidth.computedValue;
      isVerticalFixed = offsetTopToScrollContainer < stickyTop;
      if (isVerticalFixed) {
        offsetY += stickyTop - offsetTopToScrollContainer;
        // Sticky child can not exceed the bottom boundary of its parent container
        RenderBoxModel parentContainer = child.parent as RenderBoxModel;
        double maxOffsetY = parentContainer.boxSize!.height - childHeight;
        if (offsetY > maxOffsetY) {
          offsetY = maxOffsetY;
        }
      }
    } else if (childRenderStyle.bottom.isNotAuto) {
      // Sticky offset to scroll container must include padding and border
      double stickyBottom = childRenderStyle.bottom.computedValue +
        scrollContainerRenderStyle.paddingBottom.computedValue +
        scrollContainerRenderStyle.effectiveBorderBottomWidth.computedValue;
      isVerticalFixed = offsetBottomToScrollContainer < stickyBottom;
      if (isVerticalFixed) {
        offsetY += offsetBottomToScrollContainer - stickyBottom;
        // Sticky child can not exceed the upper boundary of its parent container
        double minOffsetY = 0;
        if (offsetY < minOffsetY) {
          offsetY = minOffsetY;
        }
      }
    }

    RenderLayoutParentData boxParentData = child.parentData as RenderLayoutParentData;
    boxParentData.offset = Offset(
      boxParentData.offset.dx,
      offsetY,
    );
    return isVerticalFixed;
  }

  /// Set sticky child offset according to scroll offset and direction,
  /// when axisDirection param is null compute the both axis direction.
  /// Sticky positioning is similar to relative positioning except
  /// the offsets are automatically calculated in reference to the nearest scrollport.
  /// https://www.w3.org/TR/css-position-3/#stickypos-insets
  static void applyStickyChildOffset(RenderBoxModel scrollContainer, RenderBoxModel child) {
    RenderPositionPlaceholder childRenderPositionHolder = child.renderPositionPlaceholder!;
    RenderLayoutParentData childPlaceHolderParentData = childRenderPositionHolder.parentData as RenderLayoutParentData;
    // Original offset of sticky child in relative status
    Offset childOriginalOffset = childPlaceHolderParentData.offset;

    // Offset of sticky child to scroll container
    Offset childToScrollContainerOffset =
      childRenderPositionHolder.localToGlobal(Offset.zero, ancestor: scrollContainer);

    bool isVerticalFixed = false;
    bool isHorizontalFixed = false;
    RenderStyle childRenderStyle = child.renderStyle;

    if (childRenderStyle.left.isNotAuto || childRenderStyle.right.isNotAuto) {
      isHorizontalFixed = _applyStickyChildHorizontalOffset(
        scrollContainer, child, childOriginalOffset, childToScrollContainerOffset
      );
    }
    if (childRenderStyle.top.isNotAuto || childRenderStyle.bottom.isNotAuto) {
      isVerticalFixed = _applyStickyChildVerticalOffset(
        scrollContainer, child, childOriginalOffset, childToScrollContainerOffset
      );
    }

    if (isVerticalFixed || isHorizontalFixed) {
      // Change sticky status to fixed
      child.stickyStatus = StickyPositionType.fixed;
      child.markNeedsPaint();
    } else {
      // Change sticky status to relative
      if (child.stickyStatus == StickyPositionType.fixed) {
        child.stickyStatus = StickyPositionType.relative;
        // Reset child offset to its original offset
        child.markNeedsPaint();
      }
    }
  }

  static void layoutPositionedChild(
    RenderBoxModel parent,
    RenderBoxModel child,
    {bool needsRelayout = false}
  ) {
    BoxConstraints childConstraints = child.getConstraints();

    // Scrolling element has two repaint boundary box, positioned element is positioned
    // relative to the outer renderBox.
    RenderBoxModel containerBox = parent.isScrollingContentBox ? parent.parent as RenderBoxModel : parent;
    Size trySize = containerBox.constraints.biggest;
    Size parentSize = trySize.isInfinite ? containerBox.constraints.smallest : trySize;

    // Positioned element's size stretch start at the padding-box of its parent in cases like
    // `height: 0; top: 0; bottom: 0`.
    double borderLeft = parent.renderStyle.effectiveBorderLeftWidth.computedValue;
    double borderRight = parent.renderStyle.effectiveBorderRightWidth.computedValue;
    double borderTop = parent.renderStyle.effectiveBorderTopWidth.computedValue;
    double borderBottom = parent.renderStyle.effectiveBorderBottomWidth.computedValue;
    Size parentPaddingBoxSize = Size(
      parentSize.width - borderLeft - borderRight,
      parentSize.height - borderTop - borderBottom,
    );

    BoxSizeType? widthType = _getChildWidthSizeType(child);
    BoxSizeType? heightType = _getChildHeightSizeType(child);
    RenderStyle childRenderStyle = child.renderStyle;

    // If child has no width, calculate width by left and right.
    // Element with intrinsic size such as image will not stretch
    if (childRenderStyle.width.isAuto &&
        widthType != BoxSizeType.intrinsic &&
        childRenderStyle.left.isNotAuto &&
        childRenderStyle.right.isNotAuto) {
      double childMarginLeft = childRenderStyle.marginLeft.computedValue;
      double childMarginRight = childRenderStyle.marginRight.computedValue;
      // Child width calculation should subtract its horizontal margin.
      double constraintWidth = parentPaddingBoxSize.width -
        childRenderStyle.left.computedValue - childRenderStyle.right.computedValue -
        childMarginLeft - childMarginRight;
      double? maxWidth = childRenderStyle.maxWidth.isNone ? null : childRenderStyle.maxWidth.computedValue;
      double? minWidth = childRenderStyle.minWidth.isAuto ? null : childRenderStyle.minWidth.computedValue;
      // Constrain to min-width or max-width if width not exists
      if (maxWidth != null) {
        constraintWidth = constraintWidth > maxWidth ? maxWidth : constraintWidth;
      } else if (minWidth != null) {
        constraintWidth = constraintWidth < minWidth ? minWidth : constraintWidth;
      }
      childConstraints = childConstraints.tighten(width: constraintWidth);
    }
    // If child has not height, should be calculate height by top and bottom
    if (childRenderStyle.height.isAuto &&
        heightType != BoxSizeType.intrinsic &&
        childRenderStyle.top.isNotAuto &&
        childRenderStyle.bottom.isNotAuto) {
      double childMarginTop = childRenderStyle.marginTop.computedValue;
      double childMarginBottom = childRenderStyle.marginBottom.computedValue;
      // Child height calculation should subtract its vertical margin.
      double constraintHeight = parentPaddingBoxSize.height -
        childRenderStyle.top.computedValue - childRenderStyle.bottom.computedValue -
        childMarginTop - childMarginBottom;
      CSSLengthValue maxHeightLength = childRenderStyle.maxHeight;
      CSSLengthValue minHeightLength = childRenderStyle.minHeight;
      // Constrain to min-height or max-height if width not exists
      if (maxHeightLength.isNotNone) {
        double maxHeight = maxHeightLength.computedValue;
        constraintHeight = constraintHeight > maxHeight ? maxHeight : constraintHeight;
      } else if (minHeightLength.isNotAuto) {
        double minHeight = minHeightLength.computedValue;
        constraintHeight = constraintHeight < minHeight ? minHeight : constraintHeight;
      }
      childConstraints = childConstraints.tighten(height: constraintHeight);
    }

    // Whether child need to layout
    bool isChildNeedsLayout = true;
    if (child.hasSize &&
      !needsRelayout &&
      (childConstraints == child.constraints) &&
      ((child is RenderBoxModel && !child.needsLayout) ||
        (child is RenderTextBox && !child.needsLayout))
    ) {
      isChildNeedsLayout = false;
    }

    if (isChildNeedsLayout) {
      late DateTime childLayoutStartTime;
      if (kProfileMode) {
        childLayoutStartTime = DateTime.now();
      }

      // Should create relayoutBoundary for positioned child.
      child.layout(childConstraints, parentUsesSize: false);

      if (kProfileMode) {
        DateTime childLayoutEndTime = DateTime.now();
        parent.childLayoutDuration += (childLayoutEndTime.microsecondsSinceEpoch - childLayoutStartTime.microsecondsSinceEpoch);
      }
    }
  }

  static void applyPositionedChildOffset(
    RenderBoxModel parent,
    RenderBoxModel child,
  ) {
    final RenderLayoutParentData childParentData = child.parentData as RenderLayoutParentData;
    Size? parentSize = parent.boxSize;

    if (parent.isScrollingContentBox) {
      RenderLayoutBox overflowContainerBox = parent.parent as RenderLayoutBox;

      if(overflowContainerBox.widthSizeType == BoxSizeType.specified && overflowContainerBox.heightSizeType == BoxSizeType.specified) {
        parentSize = Size(
            overflowContainerBox.renderStyle.width.computedValue,
            overflowContainerBox.renderStyle.height.computedValue
        );
      } else {
        parentSize = parent.boxSize;
      }
    } else {
      parentSize = parent.boxSize;
    }

    // Calc x,y by parentData.
    double? x, y;

    double? childMarginTop = 0;
    double? childMarginBottom = 0;
    double? childMarginLeft = 0;
    double? childMarginRight = 0;

    RenderStyle childRenderStyle = child.renderStyle;
    childMarginTop = childRenderStyle.marginTop.computedValue;
    childMarginBottom = childRenderStyle.marginBottom.computedValue;
    childMarginLeft = childRenderStyle.marginLeft.computedValue;
    childMarginRight = childRenderStyle.marginRight.computedValue;

    // Offset to global coordinate system of base.
    if (childParentData.isPositioned) {
      EdgeInsets borderEdge = parent.renderStyle.border;
      double borderLeft = borderEdge.left;
      double borderRight = borderEdge.right;
      double borderTop = borderEdge.top;
      double borderBottom = borderEdge.bottom;
      RenderStyle childRenderStyle = child.renderStyle;
      Offset? placeholderOffset;

      double top;
      if (childRenderStyle.top.isNotAuto) {
        top = childRenderStyle.top.computedValue + borderTop + childMarginTop;

        if (parent.isScrollingContentBox) {
          RenderLayoutBox overflowContainingBox = parent.parent as RenderLayoutBox;
          top -= overflowContainingBox.renderStyle.paddingTop.computedValue;
        }
      } else if (childRenderStyle.bottom.isNotAuto) {
        top = parentSize!.height - child.boxSize!.height - borderBottom - childMarginBottom - childRenderStyle.bottom.computedValue;

        if (parent.isScrollingContentBox) {
          RenderLayoutBox overflowContainingBox = parent.parent as RenderLayoutBox;
          top -= (overflowContainingBox.renderStyle.effectiveBorderTopWidth.computedValue + overflowContainingBox.renderStyle.effectiveBorderBottomWidth.computedValue
              + overflowContainingBox.renderStyle.paddingTop.computedValue);
        }
      } else {
        placeholderOffset = _getPlaceholderToParentOffset(child.renderPositionPlaceholder!, parent);
        // Use original offset in normal flow if no top and bottom is set.
        top = placeholderOffset.dy;
      }

      double left;
      if (childRenderStyle.left.isNotAuto) {
        left = childRenderStyle.left.computedValue + borderLeft + childMarginLeft;

        if (parent.isScrollingContentBox) {
          RenderLayoutBox overflowContainingBox = parent.parent as RenderLayoutBox;
          left -= overflowContainingBox.renderStyle.paddingLeft.computedValue;
        }
      } else if (childRenderStyle.right.isNotAuto) {
        left = parentSize!.width - child.boxSize!.width - borderRight - childMarginRight - childRenderStyle.right.computedValue;

        if (parent.isScrollingContentBox) {
          RenderLayoutBox overflowContainingBox = parent.parent as RenderLayoutBox;
          left -= (overflowContainingBox.renderStyle.effectiveBorderLeftWidth.computedValue + overflowContainingBox.renderStyle.effectiveBorderRightWidth.computedValue
            + overflowContainingBox.renderStyle.paddingLeft.computedValue);
        }
      } else {
        placeholderOffset ??= _getPlaceholderToParentOffset(child.renderPositionPlaceholder!, parent);
        // Use original offset in normal flow if no left and right is set.
        left = placeholderOffset.dx;
      }

      x = left;
      y = top;
    }

    Offset offset = _getAutoMarginPositionedElementOffset(x, y, child, parentSize!);
    childParentData.offset = offset;
  }
}
