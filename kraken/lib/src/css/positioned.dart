import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:kraken/dom.dart';
import 'package:kraken/rendering.dart';
import 'package:kraken/css.dart';

// CSS Positioned Layout: https://drafts.csswg.org/css-position/

BoxSizeType _getChildWidthSizeType(RenderBox child) {
  if (child is RenderTextBox) {
    return child.widthSizeType;
  } else if (child is RenderBoxModel) {
    return child.widthSizeType;
  }
  return null;
}

BoxSizeType _getChildHeightSizeType(RenderBox child) {
  if (child is RenderTextBox) {
    return child.heightSizeType;
  } else if (child is RenderBoxModel) {
    return child.heightSizeType;
  }
  return null;
}

// RenderPositionHolder may be affected by overflow: scroller offset.
// We need to reset these offset to keep positioned elements render at their original position.
Offset _getRenderPositionHolderScrollOffset(RenderPositionHolder holder, RenderObject root) {
  RenderBoxModel parent = holder.parent;
  while (parent != null && parent != root) {
    if (parent.clipX || parent.clipY) {
      return Offset(parent.scrollLeft, parent.scrollTop);
    }
    parent = parent.parent;
  }
  return null;
}

// Margin auto has special rules for positioned element
// which will override the default position rule
// https://www.w3.org/TR/CSS21/visudet.html#abs-non-replaced-width
Offset _getAutoMarginPositionedElementOffset(double x, double y, RenderBoxModel child, Size parentSize) {
  RenderStyle childRenderStyle = child.renderStyle;

  CSSMargin marginLeft = childRenderStyle.marginLeft;
  CSSMargin marginRight = childRenderStyle.marginRight;
  CSSMargin marginTop = childRenderStyle.marginTop;
  CSSMargin marginBottom = childRenderStyle.marginBottom;
  double width = childRenderStyle.width;
  double height = childRenderStyle.height;
  CSSOffset left = childRenderStyle.left;
  CSSOffset right = childRenderStyle.right;
  CSSOffset top = childRenderStyle.top;
  CSSOffset bottom = childRenderStyle.bottom;

  // 'left' + 'margin-left' + 'border-left-width' + 'padding-left' + 'width' + 'padding-right'
  // + 'border-right-width' + 'margin-right' + 'right' = width of containing block
  if ((left != null && !left.isAuto) &&
    (right != null && !right.isAuto) &&
    (child is! RenderIntrinsic || width != null)) {
    if (marginLeft.isAuto) {
      double leftValue = left.length ?? 0.0;
      double rightValue = right.length ?? 0.0;
      double remainingSpace = parentSize.width - child.boxSize.width - leftValue - rightValue;

      if (marginRight.isAuto) {
        x = leftValue + remainingSpace / 2;
      } else {
        x = leftValue + remainingSpace;
      }
    }
  }

  if ((top != null && !top.isAuto) &&
    (bottom != null && !bottom.isAuto) &&
    (child is! RenderIntrinsic || height != null)) {
    if (marginTop.isAuto) {
      double topValue = top.length ?? 0.0;
      double bottomValue = bottom.length ?? 0.0;
      double remainingSpace = parentSize.height - child.boxSize.height - topValue - bottomValue;

      if (marginBottom.isAuto) {
        y = topValue + remainingSpace / 2;
      } else {
        y = topValue + remainingSpace;
      }
    }
  }
  return Offset(x ?? 0, y ?? 0);
}

// Get parent renderBoxModel which is not scrolling content box
RenderBoxModel _getParentRenderBoxModel(RenderBoxModel renderBoxModel) {
  RenderBoxModel parentRenderBoxModel = renderBoxModel.parent;
  if (parentRenderBoxModel.isScrollingContentBox) {
    return parentRenderBoxModel.parent;
  }
  return parentRenderBoxModel;
}

class CSSPositionedLayout {
  static RenderLayoutParentData getPositionParentData(RenderBoxModel renderBoxModel, RenderLayoutParentData parentData) {
    CSSPositionType positionType = renderBoxModel.renderStyle.position;
    parentData.isPositioned = positionType == CSSPositionType.absolute || positionType == CSSPositionType.fixed;
    return parentData;
  }

  static Offset getRelativeOffset(RenderStyle renderStyle) {
      CSSOffset left = renderStyle.left;
      CSSOffset right = renderStyle.right;
      CSSOffset top = renderStyle.top;
      CSSOffset bottom = renderStyle.bottom;
      if (renderStyle.position == CSSPositionType.relative) {
        double dx;
        double dy;

        if (left != null && !left.isAuto) {
          dx = renderStyle.left.length;
        } else if (right != null && !right.isAuto) {
          double _dx = renderStyle.right.length;
          if (_dx != null) dx = -_dx;
        }

        if (top != null && !top.isAuto) {
          dy = renderStyle.top.length;
        } else if (bottom != null && !bottom.isAuto) {
          double _dy = renderStyle.bottom.length;
          if (_dy != null) dy = -_dy;
        }

        if (dx != null || dy != null) {
          return Offset(dx ?? 0, dy ?? 0);
        }
      }
      return null;
    }

  static void applyRelativeOffset(Offset relativeOffset, RenderBox renderBox) {
    RenderLayoutParentData boxParentData = renderBox?.parentData;

    // Don't set offset if it was already calculated.
    if (boxParentData.isOffsetCalculated) {
      return;
    }

    if (boxParentData != null) {
      Offset styleOffset;
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
        boxParentData.offset = styleOffset;
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

  static void layoutStickyChild(RenderBoxModel parent, RenderBoxModel child) {
    // TODO
  }

  // Set sticky child offset according to scroll offset and direction,
  // when axisDirection param is null compute the both axis direction.
  void layoutStickyChild(RenderBoxModel child) {
    // https://www.w3.org/TR/css-position-3/#stickypos-insets
    // Sticky positioning is similar to relative positioning except
    // the offsets are automatically calculated in reference to the nearest scrollport.
    bool isVerticalFixed = false;
    bool isHorizontalFixed = false;
    RenderStyle childRenderStyle = child.renderStyle;
    RenderBoxModel scrollContainer = findScrollContainer(child);

    if (child.originalScrollContainerOffset == null) {
      RenderObject rootRenderObject = child.elementManager.getRootRenderObject();
      Offset horizontalScrollContainerOffset =
        child.localToGlobal(Offset.zero, ancestor: rootRenderObject) -
          scrollContainer.localToGlobal(Offset.zero, ancestor: rootRenderObject);
      Offset verticalScrollContainerOffset =
        child.localToGlobal(Offset.zero, ancestor: rootRenderObject) -
          scrollContainer.localToGlobal(Offset.zero, ancestor: rootRenderObject);

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
    EdgeInsetsGeometry padding = scrollContainer.renderStyle.padding;
    EdgeInsets resolvedPadding = EdgeInsets.all(0);
    if (padding != null) {
      resolvedPadding = padding.resolve(TextDirection.ltr);
    }

    RenderLayoutParentData boxParentData = child?.parentData;

    if (child.originalOffset == null) {
      child.originalOffset = boxParentData.offset;
    }

    double offsetY = child.originalOffset.dy;
    double offsetX = child.originalOffset.dx;

    double childHeight = child?.size?.height;
    double childWidth = child?.size?.width;
    // Sticky element cannot exceed the boundary of its parent element container
    RenderBox parentContainer = child.parent;
    double minOffsetY = 0;
    double maxOffsetY = parentContainer.size.height - childHeight;
    double minOffsetX = 0;
    double maxOffsetX = parentContainer.size.width - childWidth;

    if (axisDirection == AxisDirection.down) {
      double offsetTop = child.originalScrollContainerOffset.dy - scrollOffset;
      double viewPortHeight = scrollContainer?.size?.height;
      double offsetBottom = viewPortHeight - childHeight - offsetTop;

      if (childRenderStyle.top != null) {
        double top = childRenderStyle.top.length + resolvedPadding.top;
        isVerticalFixed = offsetTop < top;
        if (isVerticalFixed) {
          offsetY += top - offsetTop;
          if (offsetY > maxOffsetY) {
            offsetY = maxOffsetY;
          }
        }
      } else if (childRenderStyle.bottom != null) {
        double bottom = childRenderStyle.bottom.length + resolvedPadding.bottom;
        isVerticalFixed = offsetBottom < bottom;
        if (isVerticalFixed) {
          offsetY += offsetBottom - bottom;
          if (offsetY < minOffsetY) {
            offsetY = minOffsetY;
          }
        }
      }

      if (isVerticalFixed) {
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
    }

    if (axisDirection == AxisDirection.right) {
      double offsetLeft = child.originalScrollContainerOffset.dx - scrollOffset;
      double viewPortWidth = scrollContainer?.size?.width;
      double offsetRight = viewPortWidth - childWidth - offsetLeft;

      if (childRenderStyle.left != null) {
        double left = childRenderStyle.left.length + resolvedPadding.left;
        isHorizontalFixed = offsetLeft < left;
        if (isHorizontalFixed) {
          offsetX += left - offsetLeft;
          if (offsetX > maxOffsetX) {
            offsetX = maxOffsetX;
          }
        }
      } else if (childRenderStyle.left != null) {
        double right = childRenderStyle.right.length + resolvedPadding.right;
        isHorizontalFixed = offsetRight < right;
        if (isHorizontalFixed) {
          offsetX += offsetRight - right;
          if (offsetX < minOffsetX) {
            offsetX = minOffsetX;
          }
        }
      }

      if (isHorizontalFixed) {
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

    if (isVerticalFixed || isHorizontalFixed) {
      // Change sticky status to fixed
      child.stickyStatus = StickyPositionType.fixed;
      boxParentData.isOffsetCalculated = true;
      child.markNeedsPaint();
    } else {
      // Change sticky status to relative
      if (child.stickyStatus == StickyPositionType.fixed) {
        child.stickyStatus = StickyPositionType.relative;
        boxParentData.isOffsetCalculated = false;
        // Reset child offset to its original offset
        child.markNeedsPaint();
      }
    }
  }

  static RenderBoxModel findScrollContainer(RenderBoxModel renderBoxModel) {
    RenderBoxModel childRenderBoxModel = renderBoxModel;
    RenderBoxModel parentRenderBoxModel = childRenderBoxModel.parent;

    while (parentRenderBoxModel != null) {
      RenderStyle parentRenderStyle = parentRenderBoxModel.renderStyle;
      CSSOverflowType overflowX = parentRenderStyle.overflowX;
      CSSOverflowType overflowY = parentRenderStyle.overflowY;

      if (overflowX != CSSOverflowType.visible ||
        overflowY != CSSOverflowType.visible ||
        parentRenderBoxModel is RenderViewportBox) {
        break;
      }
      childRenderBoxModel = parentRenderBoxModel;
      parentRenderBoxModel = childRenderBoxModel.parent;
    }

    // Get HTML node as scroll container
    if (parentRenderBoxModel is RenderViewportBox) {
      parentRenderBoxModel = childRenderBoxModel;
    }
    return parentRenderBoxModel;
  }

  static void layoutPositionedChild(
    RenderBoxModel parent,
    RenderBoxModel child,
    {bool needsRelayout = false}
  ) {
    BoxConstraints childConstraints = child.getConstraints();

    // Scrolling element has two repaint boundary box, the inner box has constraints of inifinity
    // so it needs to find the upper box for querying content constraints
    RenderBoxModel containerBox = parent.isScrollingContentBox ? parent.parent : parent;
    Size trySize = containerBox.contentConstraints.biggest;
    Size parentSize = trySize.isInfinite ? containerBox.contentConstraints.smallest : trySize;
    BoxSizeType widthType = _getChildWidthSizeType(child);
    BoxSizeType heightType = _getChildHeightSizeType(child);
    RenderStyle childRenderStyle = child.renderStyle;

    // If child has no width, calculate width by left and right.
    // Element with intrinsic size such as image will not stretch
    if (childRenderStyle.width == null &&
        widthType != BoxSizeType.intrinsic &&
        childRenderStyle.left != null && childRenderStyle.left.length != null &&
        childRenderStyle.right != null && childRenderStyle.right.length != null) {
      double constraintWidth = parentSize.width - childRenderStyle.left.length - childRenderStyle.right.length;
      double maxWidth = childRenderStyle.maxWidth;
      double minWidth = childRenderStyle.minWidth;
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
        childRenderStyle.top != null && childRenderStyle.top.length != null &&
        childRenderStyle.bottom != null && childRenderStyle.bottom.length != null) {
      double constraintHeight = parentSize.height - childRenderStyle.top.length - childRenderStyle.bottom.length;
      double maxHeight = childRenderStyle.maxHeight;
      double minHeight = childRenderStyle.minHeight;
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
      DateTime childLayoutStartTime;
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
    final RenderLayoutParentData childParentData = child.parentData;
    Size parentSize = parent.boxSize;

    if (parent.isScrollingContentBox) {
      RenderLayoutBox overflowContainerBox = parent.parent;

      if(overflowContainerBox.widthSizeType == BoxSizeType.specified && overflowContainerBox.heightSizeType == BoxSizeType.specified) {
        parentSize = Size(
            overflowContainerBox.renderStyle.width,
            overflowContainerBox.renderStyle.height
        );
      } else {
        parentSize = parent.boxSize;
      }
    } else {
      parentSize = parent.boxSize;
    }

    // Calc x,y by parentData.
    double x, y;

    double childMarginTop = 0;
    double childMarginBottom = 0;
    double childMarginLeft = 0;
    double childMarginRight = 0;

    RenderStyle childRenderStyle = child.renderStyle;
    childMarginTop = childRenderStyle.marginTop.length;
    childMarginBottom = childRenderStyle.marginBottom.length;
    childMarginLeft = childRenderStyle.marginLeft.length;
    childMarginRight = childRenderStyle.marginRight.length;

    // Offset to global coordinate system of base.
    if (childParentData.isPositioned) {
      RenderObject root = parent.elementManager.getRootRenderObject();
      Offset positionHolderScrollOffset = _getRenderPositionHolderScrollOffset(child.renderPositionHolder, parent) ?? Offset.zero;

      Offset baseOffset = (child.renderPositionHolder.localToGlobal(positionHolderScrollOffset, ancestor: root) -
        parent.localToGlobal(Offset(parent.scrollLeft, parent.scrollTop), ancestor: root));

      EdgeInsets borderEdge = parent.renderStyle.borderEdge;
      double borderLeft = borderEdge != null ? borderEdge.left : 0;
      double borderRight = borderEdge != null ? borderEdge.right : 0;
      double borderTop = borderEdge != null ? borderEdge.top : 0;
      double borderBottom = borderEdge != null ? borderEdge.bottom : 0;
      RenderStyle childRenderStyle = child.renderStyle;
      double top = childRenderStyle.top != null && !childRenderStyle.top.isAuto ?
        childRenderStyle.top.length + borderTop + childMarginTop : baseOffset.dy + childMarginTop;
      if ((childRenderStyle.top == null || childRenderStyle.top.length == null) &&
        (childRenderStyle.bottom != null && childRenderStyle.bottom.length != null)) {
        top = parentSize.height - child.boxSize.height - borderBottom - childMarginBottom -
          ((childRenderStyle.bottom.length) ?? 0);

        if (parent.isScrollingContentBox) {
          RenderLayoutBox overflowContainingBox = parent.parent;
          top -= (overflowContainingBox.renderStyle.borderTop + overflowContainingBox.renderStyle.borderBottom
              + overflowContainingBox.renderStyle.paddingTop);
        }
      }

      double left = childRenderStyle.left != null && !childRenderStyle.left.isAuto ?
        childRenderStyle.left.length + borderLeft + childMarginLeft : baseOffset.dx + childMarginLeft;
      if ((childRenderStyle.left == null || childRenderStyle.left.length == null) &&
        (childRenderStyle.right != null && childRenderStyle.right.length != null)) {
        left = parentSize.width - child.boxSize.width - borderRight - childMarginRight -
          ((childRenderStyle.right.length) ?? 0);

        if (parent.isScrollingContentBox) {
          RenderLayoutBox overflowContainingBox = parent.parent;
          left -= (overflowContainingBox.renderStyle.borderLeft + overflowContainingBox.renderStyle.borderRight
              + overflowContainingBox.renderStyle.paddingLeft);
        }
      }

      x = left;
      y = top;
    }

    Offset offset = _getAutoMarginPositionedElementOffset(x, y, child, parentSize);
    childParentData.offset = offset;
  }
}
