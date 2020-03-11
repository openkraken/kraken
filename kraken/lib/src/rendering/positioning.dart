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
  }) : super( children: children,
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
        var onlyChild = children[0];
        Size size = onlyChild.size;

        BoxConstraints childConstraints = const BoxConstraints();

        if (childParentData.width != null)
          childConstraints =
              childConstraints.tighten(width: childParentData.width);
        else if (childParentData.left != null && childParentData.right != null)
          childConstraints = childConstraints.tighten(
              width: size.width - childParentData.right - childParentData.left);

        if (childParentData.height != null)
          childConstraints =
              childConstraints.tighten(height: childParentData.height);
        else if (childParentData.top != null && childParentData.bottom != null)
          childConstraints = childConstraints.tighten(
              height:
                  size.height - childParentData.bottom - childParentData.top);

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
        } else if (x != null) {
          y = 0;
        }
        if (x != null ||
          y != null
        ) {
          if (x == null) {
            x = 0;
          }
          if (y == null) {
            y = 0;
          }
          childParentData.offset = Offset(x, y);
        } else if (x == null &&
            y == null &&
            childParentData is ZIndexParentData &&
            childParentData.hookRenderObject != null) {
          RenderBox renderBox = childParentData.hookRenderObject;
          ParentData parentData = renderBox.parentData;
          if (parentData is BoxParentData) {
            childParentData.offset = parentData.offset;
          }
        }
        if (childParentData.offset == null) {
          childParentData.offset = Offset.zero;
        }
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
