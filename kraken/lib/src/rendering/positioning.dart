import 'dart:math' as math;

import 'package:flutter/rendering.dart';

class ZIndexParentData extends StackParentData {
  int zIndex;
  RenderBox hookRenderObject;
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
  void performLayout() {
    bool hasNonPositionedChildren = false;
    if (childCount == 0) {
      size = Size(0, 0);
      return;
    }

    double width = constraints.minWidth;
    double height = constraints.minHeight;

    BoxConstraints nonPositionedConstraints = constraints;

    RenderBox child = firstChild;
    while (child != null) {
      final StackParentData childParentData = child.parentData;

      if (!childParentData.isPositioned) {
        hasNonPositionedChildren = true;

        child.layout(nonPositionedConstraints, parentUsesSize: true);

        final Size childSize = child.size;
        width = math.max(width, childSize.width);
        height = math.max(height, childSize.height);
        childParentData.offset = Offset.zero;
      } else {
        RenderBox onlyChild = children[0];
        Size size = onlyChild.size;

        // Default to no constraints. (0 - infinite)
        BoxConstraints childConstraints = const BoxConstraints.tightFor();
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
        Offset parentOffset = this.localToGlobal(Offset.zero);
        // Access placeholder renderObject from the reference of parent data
        RenderBox renderBox =
            (childParentData as ZIndexParentData).hookRenderObject;

        // Offset to global coordinate system of original element in document flow
        Offset originalOffset = renderBox.localToGlobal(Offset.zero);

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
    paintStack(context, offset);
  }
}
