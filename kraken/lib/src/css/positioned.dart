

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:kraken/dom.dart';
import 'package:kraken/rendering.dart';
import 'package:kraken/css.dart';

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
Offset? _getRenderPositionHolderScrollOffset(RenderPositionHolder holder, RenderObject root) {
  RenderBoxModel? parent = holder.parent as RenderBoxModel?;
  while (parent != null && parent != root) {
    if (parent.clipX || parent.clipY) {
      return Offset(parent.scrollLeft, parent.scrollTop);
    }
    parent = parent.parent as RenderBoxModel?;
  }
  return null;
}

// Get the offset of the RenderPlaceholder of positioned element to its parent RenderBoxModel.
Offset _getPlaceholderToParentOffset(RenderPositionHolder placeholder, RenderBoxModel parent) {
  Offset positionHolderScrollOffset = _getRenderPositionHolderScrollOffset(placeholder, parent) ?? Offset.zero;
  Offset placeholderOffset = placeholder.localToGlobal(positionHolderScrollOffset, ancestor: parent);
  return placeholderOffset;
}


// Margin auto has special rules for positioned element
// which will override the default position rule
// https://www.w3.org/TR/CSS21/visudet.html#abs-non-replaced-width
Offset _getAutoMarginPositionedElementOffset(double? x, double? y, RenderBoxModel child, Size parentSize) {
  RenderStyle childRenderStyle = child.renderStyle;

  CSSMargin marginLeft = childRenderStyle.marginLeft;
  CSSMargin marginRight = childRenderStyle.marginRight;
  CSSMargin marginTop = childRenderStyle.marginTop;
  CSSMargin marginBottom = childRenderStyle.marginBottom;
  double? width = childRenderStyle.width;
  double? height = childRenderStyle.height;
  CSSOffset? left = childRenderStyle.left;
  CSSOffset? right = childRenderStyle.right;
  CSSOffset? top = childRenderStyle.top;
  CSSOffset? bottom = childRenderStyle.bottom;

  // 'left' + 'margin-left' + 'border-left-width' + 'padding-left' + 'width' + 'padding-right'
  // + 'border-right-width' + 'margin-right' + 'right' = width of containing block
  if ((left != null && !left.isAuto!) &&
    (right != null && !right.isAuto!) &&
    (child is! RenderIntrinsic || width != null)) {
    if (marginLeft.isAuto!) {
      double leftValue = left.length ?? 0.0;
      double rightValue = right.length ?? 0.0;
      double remainingSpace = parentSize.width - child.boxSize!.width - leftValue - rightValue;

      if (marginRight.isAuto!) {
        x = leftValue + remainingSpace / 2;
      } else {
        x = leftValue + remainingSpace;
      }
    }
  }

  if ((top != null && !top.isAuto!) &&
    (bottom != null && !bottom.isAuto!) &&
    (child is! RenderIntrinsic || height != null)) {
    if (marginTop.isAuto!) {
      double topValue = top.length ?? 0.0;
      double bottomValue = bottom.length ?? 0.0;
      double remainingSpace = parentSize.height - child.boxSize!.height - topValue - bottomValue;

      if (marginBottom.isAuto!) {
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
      CSSOffset? left = renderStyle.left;
      CSSOffset? right = renderStyle.right;
      CSSOffset? top = renderStyle.top;
      CSSOffset? bottom = renderStyle.bottom;
      if (renderStyle.position == CSSPositionType.relative) {
        double? dx;
        double? dy;

        if (left != null && !left.isAuto!) {
          dx = renderStyle.left!.length;
        } else if (right != null && !right.isAuto!) {
          double? _dx = renderStyle.right!.length;
          if (_dx != null) dx = -_dx;
        }

        if (top != null && !top.isAuto!) {
          dy = renderStyle.top!.length;
        } else if (bottom != null && !bottom.isAuto!) {
          double? _dy = renderStyle.bottom!.length;
          if (_dy != null) dy = -_dy;
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
        (renderStyle.top != null ||
        renderStyle.left != null ||
        renderStyle.bottom != null ||
        renderStyle.right != null);
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

    if (childRenderStyle.left != null) {
      // Sticky offset to scroll container must include padding and border
      double stickyLeft = childRenderStyle.left!.length! +
        scrollContainerRenderStyle.paddingLeft +
        scrollContainerRenderStyle.borderLeft;
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
    } else if (childRenderStyle.left != null) {
      // Sticky offset to scroll container must include padding and border
      double stickyRight = childRenderStyle.right!.length! +
        scrollContainerRenderStyle.paddingRight +
        scrollContainerRenderStyle.borderRight;
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

    if (childRenderStyle.top != null) {
      // Sticky offset to scroll container must include padding and border
      double stickyTop = childRenderStyle.top!.length! +
        scrollContainerRenderStyle.paddingTop +
        scrollContainerRenderStyle.borderTop;
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
    } else if (childRenderStyle.bottom != null) {
      // Sticky offset to scroll container must include padding and border
      double stickyBottom = childRenderStyle.bottom!.length! +
        scrollContainerRenderStyle.paddingBottom +
        scrollContainerRenderStyle.borderBottom;
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
    RenderPositionHolder childRenderPositionHolder = child.renderPositionHolder!;
    RenderLayoutParentData childPlaceHolderParentData = childRenderPositionHolder.parentData as RenderLayoutParentData;
    // Original offset of sticky child in relative status
    Offset childOriginalOffset = childPlaceHolderParentData.offset;

    // Offset of sticky child to scroll container
    Offset childToScrollContainerOffset =
      childRenderPositionHolder.localToGlobal(Offset.zero, ancestor: scrollContainer);

    bool isVerticalFixed = false;
    bool isHorizontalFixed = false;
    RenderStyle childRenderStyle = child.renderStyle;

    if (childRenderStyle.left != null || childRenderStyle.right != null) {
      isHorizontalFixed = _applyStickyChildHorizontalOffset(
        scrollContainer, child, childOriginalOffset, childToScrollContainerOffset
      );
    }
    if (childRenderStyle.top != null || childRenderStyle.bottom != null) {
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

    // Scrolling element has two repaint boundary box, the inner box has constraints of inifinity
    // so it needs to find the upper box for querying content constraints
    RenderBoxModel containerBox = parent.isScrollingContentBox ? parent.parent as RenderBoxModel : parent;
    Size trySize = containerBox.constraints.biggest;
    Size parentSize = trySize.isInfinite ? containerBox.constraints.smallest : trySize;

    // Positioned element's size stretch start at the padding-box of its parent in cases like
    // `height: 0; top: 0; bottom: 0`.
    double borderLeft = parent.renderStyle.borderLeft;
    double borderRight = parent.renderStyle.borderRight;
    double borderTop = parent.renderStyle.borderTop;
    double borderBottom = parent.renderStyle.borderBottom;
    Size parentPaddingBoxSize = Size(
      parentSize.width - borderLeft - borderRight,
      parentSize.height - borderTop - borderBottom,
    );

    BoxSizeType? widthType = _getChildWidthSizeType(child);
    BoxSizeType? heightType = _getChildHeightSizeType(child);
    RenderStyle childRenderStyle = child.renderStyle;

    // If child has no width, calculate width by left and right.
    // Element with intrinsic size such as image will not stretch
    if (childRenderStyle.width == null &&
        widthType != BoxSizeType.intrinsic &&
        childRenderStyle.left != null && childRenderStyle.left!.length != null &&
        childRenderStyle.right != null && childRenderStyle.right!.length != null) {
      double childMarginLeft = childRenderStyle.marginLeft.length ?? 0;
      double childMarginRight = childRenderStyle.marginRight.length ?? 0;
      // Child width calculation should subtract its horizontal margin.
      double constraintWidth = parentPaddingBoxSize.width -
        childRenderStyle.left!.length! - childRenderStyle.right!.length! -
        childMarginLeft - childMarginRight;
      double? maxWidth = childRenderStyle.maxWidth;
      double? minWidth = childRenderStyle.minWidth;
      // Constrain to min-width or max-width if width not exists
      if (maxWidth != null) {
        constraintWidth = constraintWidth > maxWidth ? maxWidth : constraintWidth;
      } else if (minWidth != null) {
        constraintWidth = constraintWidth < minWidth ? minWidth : constraintWidth;
      }
      childConstraints = childConstraints.tighten(width: constraintWidth);
    }
    // If child has not height, should be calculate height by top and bottom
    if (childRenderStyle.height == null &&
        heightType != BoxSizeType.intrinsic &&
        childRenderStyle.top != null && childRenderStyle.top!.length != null &&
        childRenderStyle.bottom != null && childRenderStyle.bottom!.length != null) {
      double childMarginTop = childRenderStyle.marginTop.length ?? 0;
      double childMarginBottom = childRenderStyle.marginBottom.length ?? 0;
      // Child height calculation should subtract its vertical margin.
      double constraintHeight = parentPaddingBoxSize.height -
        childRenderStyle.top!.length! - childRenderStyle.bottom!.length! -
        childMarginTop - childMarginBottom;
      double? maxHeight = childRenderStyle.maxHeight;
      double? minHeight = childRenderStyle.minHeight;
      // Constrain to min-height or max-height if width not exists
      if (maxHeight != null) {
        constraintHeight = constraintHeight > maxHeight ? maxHeight : constraintHeight;
      } else if (minHeight != null) {
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
            overflowContainerBox.renderStyle.width!,
            overflowContainerBox.renderStyle.height!
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
    childMarginTop = childRenderStyle.marginTop.length;
    childMarginBottom = childRenderStyle.marginBottom.length;
    childMarginLeft = childRenderStyle.marginLeft.length;
    childMarginRight = childRenderStyle.marginRight.length;

    // Offset to global coordinate system of base.
    if (childParentData.isPositioned) {
      EdgeInsets? borderEdge = parent.renderStyle.borderEdge;
      double borderLeft = borderEdge != null ? borderEdge.left : 0;
      double borderRight = borderEdge != null ? borderEdge.right : 0;
      double borderTop = borderEdge != null ? borderEdge.top : 0;
      double borderBottom = borderEdge != null ? borderEdge.bottom : 0;
      RenderStyle childRenderStyle = child.renderStyle;
      Offset? placeholderOffset;

      double top;
      if (childRenderStyle.top != null && childRenderStyle.top!.length != null) {
        top = childRenderStyle.top!.length! + borderTop + childMarginTop!;

        if (parent.isScrollingContentBox) {
          RenderLayoutBox overflowContainingBox = parent.parent as RenderLayoutBox;
          top -= overflowContainingBox.renderStyle.paddingTop;
        }
      } else if (childRenderStyle.bottom != null && childRenderStyle.bottom!.length != null) {
        top = parentSize!.height - child.boxSize!.height - borderBottom - childMarginBottom! -
          ((childRenderStyle.bottom!.length) ?? 0);

        if (parent.isScrollingContentBox) {
          RenderLayoutBox overflowContainingBox = parent.parent as RenderLayoutBox;
          top -= (overflowContainingBox.renderStyle.borderTop + overflowContainingBox.renderStyle.borderBottom
              + overflowContainingBox.renderStyle.paddingTop);
        }
      } else {
        placeholderOffset = _getPlaceholderToParentOffset(child.renderPositionHolder!, parent);
        // Use original offset in normal flow if no top and bottom is set.
        top = placeholderOffset.dy + childMarginTop!;
      }

      double left;
      if (childRenderStyle.left != null && childRenderStyle.left!.length != null) {
        left = childRenderStyle.left!.length! + borderLeft + childMarginLeft!;

        if (parent.isScrollingContentBox) {
          RenderLayoutBox overflowContainingBox = parent.parent as RenderLayoutBox;
          left -= overflowContainingBox.renderStyle.paddingLeft;
        }
      } else if (childRenderStyle.right != null && childRenderStyle.right!.length != null) {
        left = parentSize!.width - child.boxSize!.width - borderRight - childMarginRight! -
          ((childRenderStyle.right!.length) ?? 0);

        if (parent.isScrollingContentBox) {
          RenderLayoutBox overflowContainingBox = parent.parent as RenderLayoutBox;
          left -= (overflowContainingBox.renderStyle.borderLeft + overflowContainingBox.renderStyle.borderRight
            + overflowContainingBox.renderStyle.paddingLeft);
        }
      } else {
        placeholderOffset ??= _getPlaceholderToParentOffset(child.renderPositionHolder!, parent);
        // Use original offset in normal flow if no left and right is set.
        left = placeholderOffset.dx + childMarginLeft!;
      }

      x = left;
      y = top;
    }

    Offset offset = _getAutoMarginPositionedElementOffset(x, y, child, parentSize!);
    childParentData.offset = offset;
  }
}
