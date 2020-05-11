import 'dart:math' as math;

import 'package:flutter/rendering.dart';

class PositionParentData extends StackParentData {
  RenderBox originalRenderBoxRef;
  int zIndex = 0;

  /// Get element original position offset to global should be.
  Offset get stackedChildOriginalOffset {
    if (originalRenderBoxRef == null) return Offset.zero;
    return (originalRenderBoxRef.parentData as BoxParentData).offset;
  }

  @override
  bool get isPositioned => top != null
      || right != null
      || bottom != null
      || left != null;

  @override
  String toString() {
    return 'zIndex=$zIndex; ${super.toString()}';
  }
}

class RenderPosition extends RenderStack {
  RenderPosition({
    this.children,
    AlignmentGeometry alignment = AlignmentDirectional.topStart,
    TextDirection textDirection = TextDirection.ltr,
    StackFit fit = StackFit.passthrough,
    Overflow overflow = Overflow.visible,
  }) : super(
            children: children,
            alignment: alignment,
            textDirection: textDirection,
            fit: fit,
            overflow: overflow);

  List<RenderBox> children;

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! PositionParentData)
      child.parentData = PositionParentData();
  }

  @override
  void performLayout() {
    if (childCount == 0) {
      size = Size.zero;
      return;
    }

    bool hasNonPositionedChildren = false;
    double width = constraints.minWidth;
    double height = constraints.minHeight;

    RenderBox child = firstChild;
    while (child != null) {
      final PositionParentData childParentData = child.parentData as PositionParentData;

      if (!childParentData.isPositioned) {
        // Should be in it's original position.
        hasNonPositionedChildren = true;

        child.layout(constraints, parentUsesSize: true);

        final Size childSize = child.size;
        width = math.max(width, childSize.width);
        height = math.max(height, childSize.height);
        childParentData.offset = childParentData.stackedChildOriginalOffset;
      } else {
        RenderBox onlyChild = children[0];
        Size size = onlyChild.size;

        // Default to no constraints. (0 - infinite)
        BoxConstraints childConstraints = const BoxConstraints.tightFor();
        // if child has not width, should be calculate width by left and right
        if (childParentData.width == 0.0 && childParentData.left != null &&
          childParentData.right != null) {
          childConstraints = childConstraints.tighten(
            width: size.width - childParentData.left - childParentData.right);
        }
        // if child has not height, should be calculate height by top and bottom
        if (childParentData.height == 0.0 && childParentData.top != null &&
          childParentData.bottom != null) {
          childConstraints = childConstraints.tighten(
            height: size.height - childParentData.top - childParentData.bottom);
        }
        child.layout(childConstraints, parentUsesSize: true);

        double x;
        if (childParentData.left != null) {
          x = childParentData.left;
        } else if (childParentData.right != null) {
          x = size.width - childParentData.right - child.size.width;
        }

        double y;
        if (childParentData.top != null) {
          y = childParentData.top;
        } else if (childParentData.bottom != null) {
          y = size.height - childParentData.bottom - child.size.height;
        }

        // Offset to global coordinate system of parent
        Offset parentOffset = localToGlobal(Offset.zero);

        // Offset to global coordinate system of original element in document flow
        Offset originalOffset = childParentData.stackedChildOriginalOffset;

        // Following web standard, if top or left of positioned element do not exists,
        // use the original position before moved away from document flow
        if (x == null) {
          x = originalOffset.dx - parentOffset.dx;
        }
        if (y == null) {
          y = originalOffset.dy - parentOffset.dy;
        }

        childParentData.offset = Offset(x, y);
      }

      child = childParentData.nextSibling;
    }

    if (hasNonPositionedChildren) {
      size = Size(width, height);
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    List<RenderObject> children =  getChildrenAsList();
    children.sort((RenderObject prev, RenderObject next) {
      PositionParentData prevParentData = prev.parentData as PositionParentData;
      PositionParentData nextParentData = next.parentData as PositionParentData;
      int prevZIndex = prevParentData.zIndex ?? 0;
      int nextZIndex = nextParentData.zIndex ?? 0;
      return prevZIndex - nextZIndex;
    });

    for (var child in children) {
      final PositionParentData childParentData = child.parentData as PositionParentData;
      context.paintChild(child, childParentData.offset + offset);
      child = childParentData.nextSibling;
    }
  }
}
