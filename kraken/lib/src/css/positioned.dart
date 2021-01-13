import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:kraken/dom.dart';
import 'package:kraken/rendering.dart';
import 'package:kraken/css.dart';

// CSS Positioned Layout: https://drafts.csswg.org/css-position/

Offset _getRelativeOffset(RenderStyle renderStyle) {
  CSSStyleDeclaration style = renderStyle.style;
  if (renderStyle.position == CSSPositionType.relative) {
    double dx;
    double dy;

    if (style.contains(LEFT) && style[LEFT] != AUTO) {
      dx = renderStyle.left;
    } else if (style.contains(RIGHT) && style[RIGHT] != AUTO) {
      double _dx = renderStyle.right;
      if (_dx != null) dx = -_dx;
    }

    if (style.contains(TOP) && style[TOP] != AUTO) {
      dy = renderStyle.top;
    } else if (style.contains(BOTTOM) && style[BOTTOM] != AUTO) {
      double _dy = renderStyle.bottom;
      if (_dy != null) dy = -_dy;
    }

    if (dx != null || dy != null) {
      return Offset(dx ?? 0, dy ?? 0);
    }
  }
  return null;
}

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

/// Get child size through boxSize to avoid flutter error when parentUsesSize is set to false
Size _getChildSize(RenderBox child) {
  if (child is RenderBoxModel) {
    return child.boxSize;
  } else if (child is RenderPositionHolder) {
    return child.boxSize;
  } else if (child is RenderTextBox) {
    return child.boxSize;
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
  CSSStyleDeclaration childStyle = child.style;
  String marginLeft = childStyle[MARGIN_LEFT];
  String marginRight = childStyle[MARGIN_RIGHT];
  String marginTop = childStyle[MARGIN_TOP];
  String marginBottom = childStyle[MARGIN_BOTTOM];
  String width = childStyle[WIDTH];
  String height = childStyle[HEIGHT];
  String left = childStyle[LEFT];
  String right = childStyle[RIGHT];
  String top = childStyle[TOP];
  String bottom = childStyle[BOTTOM];

  // 'left' + 'margin-left' + 'border-left-width' + 'padding-left' + 'width' + 'padding-right'
  // + 'border-right-width' + 'margin-right' + 'right' = width of containing block
  if ((left.isNotEmpty && left != AUTO) &&
      (right.isNotEmpty && right != AUTO) &&
      width.isNotEmpty) {
    if (marginLeft == AUTO) {
      double leftValue = childRenderStyle.left ?? 0.0;
      double rightValue = childRenderStyle.right ?? 0.0;
      double remainingSpace = parentSize.width - child.boxSize.width - leftValue - rightValue;

      if (marginRight == AUTO) {
        x = leftValue + remainingSpace / 2;
      } else {
        x = leftValue + remainingSpace;
      }
    }
  }

  if ((top.isNotEmpty && top != AUTO) &&
      (bottom.isNotEmpty && bottom != AUTO) &&
      height.isNotEmpty) {
    if (marginTop == AUTO) {
      double topValue = childRenderStyle.top ?? 0.0;
      double bottomValue = childRenderStyle.bottom ?? 0.0;
      double remainingSpace = parentSize.height - child.boxSize.height - topValue - bottomValue;

      if (marginBottom == AUTO) {
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

  static void applyRelativeOffset(Offset relativeOffset, RenderBox renderBox, CSSStyleDeclaration style) {
    RenderLayoutParentData boxParentData = renderBox?.parentData;

    // Don't set offset if it was already set
    if (boxParentData.isOffsetSet) {
      return;
    }

    if (boxParentData != null) {
      Offset styleOffset;
      // Text node does not have relative offset
      if (renderBox is RenderBoxModel && style != null) {
        styleOffset = _getRelativeOffset(renderBox.renderStyle);
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

  static void layoutPositionedChild(
    RenderBoxModel parent,
    RenderBoxModel child,
    {bool needsRelayout = false}
  ) {
    // Default to no constraints. (0 - infinite)
    BoxConstraints childConstraints = const BoxConstraints();
    Size trySize = parent.contentConstraints.biggest;
    Size parentSize = trySize.isInfinite ? parent.contentConstraints.smallest : trySize;

    BoxSizeType widthType = _getChildWidthSizeType(child);
    BoxSizeType heightType = _getChildHeightSizeType(child);
    RenderStyle childRenderStyle = child.renderStyle;

    // If child has no width, calculate width by left and right.
    // Element with intrinsic size such as image will not stretch
    if (childRenderStyle.width == null &&
        widthType != BoxSizeType.intrinsic &&
        childRenderStyle.left != null &&
        childRenderStyle.right != null) {
      double constraintWidth = parentSize.width - childRenderStyle.left - childRenderStyle.right;
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
        childRenderStyle.top != null &&
        childRenderStyle.bottom != null) {
      double constraintHeight = parentSize.height - childRenderStyle.top - childRenderStyle.bottom;
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
    if (child is RenderBoxModel && child.hasSize) {
      double childContentWidth = RenderBoxModel.getContentWidth(child);
      double childContentHeight = RenderBoxModel.getContentHeight(child);
      // Always layout child when parent is not laid out yet or child is marked as needsLayout
      if (!parent.hasSize || child.needsLayout || needsRelayout) {
        isChildNeedsLayout = true;
      } else {
        Size childOldSize = _getChildSize(child);
        // Need to layout child when width and height of child are both specified and differ from its previous size
        isChildNeedsLayout = childContentWidth != null && childContentHeight != null &&
          (childOldSize.width != childContentWidth ||
            childOldSize.height != childContentHeight);
      }
    }

    if (isChildNeedsLayout) {
      DateTime childLayoutStartTime;
      if (kProfileMode) {
        childLayoutStartTime = DateTime.now();
      }

      // Relayout child after percentage size is resolved
      if (needsRelayout) {
        childConstraints = child.renderStyle.getConstraints();
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
    // Calc x,y by parentData.
    double x, y;

    double childMarginTop = 0;
    double childMarginBottom = 0;
    double childMarginLeft = 0;
    double childMarginRight = 0;

    Element childEl = parent.elementManager.getEventTargetByTargetId<Element>(child.targetId);
    RenderBoxModel childRenderBoxModel = childEl.renderBoxModel;
    RenderStyle childRenderStyle = child.renderStyle;
    childMarginTop = childRenderStyle.marginTop;
    childMarginBottom = childRenderStyle.marginBottom;
    childMarginLeft = childRenderStyle.marginLeft;
    childMarginRight = childRenderStyle.marginRight;

    // Offset to global coordinate system of base.
    if (childParentData.isPositioned) {
      RenderObject root = parent.elementManager.getRootRenderObject();
      Offset positionHolderScrollOffset = _getRenderPositionHolderScrollOffset(childRenderBoxModel.renderPositionHolder, parent) ?? Offset.zero;

      Offset baseOffset = (childRenderBoxModel.renderPositionHolder.localToGlobal(positionHolderScrollOffset, ancestor: root) -
        parent.localToGlobal(Offset(parent.scrollLeft, parent.scrollTop), ancestor: root));

      EdgeInsets borderEdge = parent.renderStyle.borderEdge;
      double borderLeft = borderEdge != null ? borderEdge.left : 0;
      double borderRight = borderEdge != null ? borderEdge.right : 0;
      double borderTop = borderEdge != null ? borderEdge.top : 0;
      double borderBottom = borderEdge != null ? borderEdge.bottom : 0;
      RenderStyle childRenderStyle = child.renderStyle;
      double top = childRenderStyle.top != null ?
        childRenderStyle.top + borderTop + childMarginTop : baseOffset.dy + childMarginTop;
      if (childRenderStyle.top == null && childRenderStyle.bottom != null) {
        top = parentSize.height - child.boxSize.height - borderBottom - childMarginBottom -
          ((childRenderStyle.bottom) ?? 0);
      }

      double left = childRenderStyle.left != null ?
        childRenderStyle.left + borderLeft + childMarginLeft : baseOffset.dx + childMarginLeft;
      if (childRenderStyle.left == null && childRenderStyle.right != null) {
        left = parentSize.width - child.boxSize.width - borderRight - childMarginRight -
          ((childRenderStyle.right) ?? 0);
      }

      x = left;
      y = top;
    }

    Offset offset = _getAutoMarginPositionedElementOffset(x, y, child, parentSize);
    childParentData.offset = offset;
  }
}
