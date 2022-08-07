/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:webf/css.dart';
import 'package:webf/dom.dart';
import 'package:webf/rendering.dart';

// CSS Positioned Layout: https://drafts.csswg.org/css-position/

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
Offset _getPlaceholderToParentOffset(RenderPositionPlaceholder? placeholder, RenderBoxModel parent) {
  if (placeholder == null || !placeholder.attached) {
    return Offset.zero;
  }
  Offset positionHolderScrollOffset = _getRenderPositionHolderScrollOffset(placeholder, parent) ?? Offset.zero;
  // Offset of positioned element should exclude scroll offset to its containing block.
  Offset toParentOffset = placeholder.getOffsetToAncestor(Offset.zero, parent, excludeScrollOffset: true);
  Offset placeholderOffset = positionHolderScrollOffset + toParentOffset;

  return placeholderOffset;
}

class CSSPositionedLayout {
  static RenderLayoutParentData getPositionParentData(
      RenderBoxModel renderBoxModel, RenderLayoutParentData parentData) {
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

  // Set horizontal offset of sticky element.
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

  // Set vertical offset of sticky element.
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

  // Set sticky child offset according to scroll offset and direction,
  // when axisDirection param is null compute the both axis direction.
  // Sticky positioning is similar to relative positioning except
  // the offsets are automatically calculated in reference to the nearest scrollport.
  // https://www.w3.org/TR/css-position-3/#stickypos-insets
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
      isHorizontalFixed =
          _applyStickyChildHorizontalOffset(scrollContainer, child, childOriginalOffset, childToScrollContainerOffset);
    }
    if (childRenderStyle.top.isNotAuto || childRenderStyle.bottom.isNotAuto) {
      isVerticalFixed =
          _applyStickyChildVerticalOffset(scrollContainer, child, childOriginalOffset, childToScrollContainerOffset);
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

  static void layoutPositionedChild(RenderBoxModel parent, RenderBoxModel child, {bool needsRelayout = false}) {
    BoxConstraints childConstraints = child.getConstraints();

    // Whether child need to layout
    bool isChildNeedsLayout = true;
    if (child.hasSize && !needsRelayout && (childConstraints == child.constraints) && (!child.needsLayout)) {
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
        parent.childLayoutDuration +=
            (childLayoutEndTime.microsecondsSinceEpoch - childLayoutStartTime.microsecondsSinceEpoch);
      }
    }
  }

  // Position of positioned element involves inset, size , margin and its containing block size.
  // https://www.w3.org/TR/css-position-3/#abs-non-replaced-width
  static void applyPositionedChildOffset(
    RenderBoxModel parent,
    RenderBoxModel child,
  ) {
    final RenderLayoutParentData childParentData = child.parentData as RenderLayoutParentData;
    Size size = child.boxSize!;
    Size parentSize = parent.boxSize!;
    RenderStyle parentRenderStyle = parent.renderStyle;

    // Calculate offset to overflow container box first, then subtract border and padding
    // to get the offset to scrolling content box.
    if (parent.isScrollingContentBox) {
      RenderLayoutBox overflowContainerBox = parent.parent as RenderLayoutBox;
      parentRenderStyle = overflowContainerBox.renderStyle;

      // Overflow scroll container has width and height specified surely.
      if (overflowContainerBox.widthSizeType == BoxSizeType.specified &&
          overflowContainerBox.heightSizeType == BoxSizeType.specified) {
        parentSize = Size(overflowContainerBox.renderStyle.width.computedValue,
            overflowContainerBox.renderStyle.height.computedValue);
      }
    }

    CSSLengthValue parentBorderLeftWidth = parentRenderStyle.effectiveBorderLeftWidth;
    CSSLengthValue parentBorderRightWidth = parentRenderStyle.effectiveBorderRightWidth;
    CSSLengthValue parentBorderTopWidth = parentRenderStyle.effectiveBorderTopWidth;
    CSSLengthValue parentBorderBottomWidth = parentRenderStyle.effectiveBorderBottomWidth;
    CSSLengthValue parentPaddingLeft = parentRenderStyle.paddingLeft;
    CSSLengthValue parentPaddingTop = parentRenderStyle.paddingTop;

    // The containing block of not an inline box is formed by the padding edge of the ancestor.
    // Thus the final offset of child need to add the border of parent.
    // https://www.w3.org/TR/css-position-3/#def-cb
    Size containingBlockSize = Size(
        parentSize.width - parentBorderLeftWidth.computedValue - parentBorderRightWidth.computedValue,
        parentSize.height - parentBorderTopWidth.computedValue - parentBorderBottomWidth.computedValue);

    RenderStyle childRenderStyle = child.renderStyle;
    CSSLengthValue left = childRenderStyle.left;
    CSSLengthValue right = childRenderStyle.right;
    CSSLengthValue top = childRenderStyle.top;
    CSSLengthValue bottom = childRenderStyle.bottom;
    CSSLengthValue marginLeft = childRenderStyle.marginLeft;
    CSSLengthValue marginRight = childRenderStyle.marginRight;
    CSSLengthValue marginTop = childRenderStyle.marginTop;
    CSSLengthValue marginBottom = childRenderStyle.marginBottom;

    // ScrollTop and scrollLeft will be added to offset of renderBox in the paint stage
    // for positioned fixed element.
    if (childRenderStyle.position == CSSPositionType.fixed) {
      Element rootElement = parentRenderStyle.target;
      child.scrollingOffsetX = rootElement.scrollLeft;
      child.scrollingOffsetY = rootElement.scrollTop;
    }

    // The static position of positioned element is its offset when its position property had been static
    // which equals to the position of its placeholder renderBox.
    // https://www.w3.org/TR/CSS2/visudet.html#static-position
    Offset staticPositionOffset = _getPlaceholderToParentOffset(child.renderPositionPlaceholder, parent);

    double x = _computePositionedOffset(
      Axis.horizontal,
      parent.isScrollingContentBox,
      parentBorderLeftWidth,
      parentPaddingLeft,
      containingBlockSize.width,
      size.width,
      staticPositionOffset.dx,
      left,
      right,
      marginLeft,
      marginRight,
    );

    double y = _computePositionedOffset(
      Axis.vertical,
      parent.isScrollingContentBox,
      parentBorderTopWidth,
      parentPaddingTop,
      containingBlockSize.height,
      size.height,
      staticPositionOffset.dy,
      top,
      bottom,
      marginTop,
      marginBottom,
    );

    childParentData.offset = Offset(x, y);
  }

  // Compute the offset of positioned element in one axis.
  static double _computePositionedOffset(
    Axis axis,
    bool isParentScrollingContentBox,
    CSSLengthValue parentBorderBeforeWidth,
    CSSLengthValue parentPaddingBefore,
    double containingBlockLength,
    double length,
    double staticPosition,
    CSSLengthValue insetBefore,
    CSSLengthValue insetAfter,
    CSSLengthValue marginBefore,
    CSSLengthValue marginAfter,
  ) {
    // Offset of positioned element in one axis.
    double offset;

    // Take horizontal axis for example.
    // left + margin-left + width + margin-right + right = width of containing block
    // Refer to the table of `Summary of rules for dir=ltr in horizontal writing modes` in following spec.
    // https://www.w3.org/TR/css-position-3/#abs-non-replaced-width
    if (insetBefore.isAuto && insetAfter.isAuto) {
      // If all three of left, width, and right are auto: First set any auto values for margin-left
      // and margin-right to 0. Then, if the direction property of the element establishing the
      // static-position containing block is ltr set left to the static position.
      offset = staticPosition;
    } else {
      if (insetBefore.isNotAuto && insetAfter.isNotAuto) {
        double freeSpace = containingBlockLength - length - insetBefore.computedValue - insetAfter.computedValue;
        double marginBeforeValue;

        if (marginBefore.isAuto && marginAfter.isAuto) {
          // Note: There is difference for auto margin resolve rule of horizontal and vertical axis.
          // margin-left is resolved as 0 only in horizontal axis and resolved as equal values of free space
          // in vertical axis, refer to following doc in the spec:
          //
          // If both margin-left and margin-right are auto, solve the equation under the extra constraint
          // that the two margins get equal values, unless this would make them negative, in which case
          // when direction of the containing block is ltr (rtl), set margin-left (margin-right) to 0
          // and solve for margin-right (margin-left).
          // https://www.w3.org/TR/css-position-3/#abs-non-replaced-width
          //
          // If both margin-top and margin-bottom are auto, solve the equation under the extra constraint
          // that the two margins get equal values.
          // https://www.w3.org/TR/css-position-3/#abs-non-replaced-height
          if (freeSpace < 0 && axis == Axis.horizontal) {
            // margin-left → '0', solve the above equation for margin-right
            marginBeforeValue = 0;
          } else {
            // margins split positive free space
            marginBeforeValue = freeSpace / 2;
          }
        } else if (marginBefore.isAuto && marginAfter.isNotAuto) {
          // If one of margin-left or margin-right is auto, solve the equation for that value.
          // Solve for margin-left in this case.
          marginBeforeValue = freeSpace - marginAfter.computedValue;
        } else {
          // If one of margin-left or margin-right is auto, solve the equation for that value.
          // Use specified margin-left in this case.
          marginBeforeValue = marginBefore.computedValue;
        }
        offset = parentBorderBeforeWidth.computedValue + insetBefore.computedValue + marginBeforeValue;
      } else if (insetBefore.isAuto && insetAfter.isNotAuto) {
        // If left is auto, width and right are not auto, then solve for left.
        double insetBeforeValue = containingBlockLength -
            length -
            insetAfter.computedValue -
            marginBefore.computedValue -
            marginAfter.computedValue;
        offset = parentBorderBeforeWidth.computedValue + insetBeforeValue + marginBefore.computedValue;
      } else {
        // If right is auto, left and width are not auto, then solve for right.
        offset = parentBorderBeforeWidth.computedValue + insetBefore.computedValue + marginBefore.computedValue;
      }

      // Convert position relative to scrolling content box.
      // Scrolling content box positions relative to the content edge of its parent.
      if (isParentScrollingContentBox) {
        offset = offset - parentBorderBeforeWidth.computedValue - parentPaddingBefore.computedValue;
      }
    }

    return offset;
  }
}
