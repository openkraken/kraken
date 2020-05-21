import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:kraken/css.dart';
import 'package:kraken/rendering.dart';

class PositionParentData extends StackParentData {
  RenderBox originalRenderBoxRef;
  int zIndex = 0;
  CSSPositionType position = CSSPositionType.static;

  /// Get element original position offset to parent(layoutBox) should be.
  Offset get stackedChildOriginalRelativeOffset {
    if (originalRenderBoxRef == null) return Offset.zero;
    return (originalRenderBoxRef.parentData as BoxParentData).offset;
  }

  @override
  bool get isPositioned => top != null || right != null || bottom != null || left != null;

  @override
  String toString() {
    return 'zIndex=$zIndex; position=$position; originalRenderBoxRef=$originalRenderBoxRef; ${super.toString()}';
  }
}

class RenderPosition extends RenderStack {
  RenderPosition({
    this.children,
    AlignmentGeometry alignment = AlignmentDirectional.topStart,
    TextDirection textDirection = TextDirection.ltr,
    StackFit fit = StackFit.passthrough,
    Overflow overflow = Overflow.visible,
  }) : super(children: children, alignment: alignment, textDirection: textDirection, fit: fit, overflow: overflow);

  List<RenderBox> children;

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! PositionParentData) {
      var childParentData = child.parentData = PositionParentData();
      if (child is RenderElementBoundary) {
        childParentData.position = resolvePositionFromStyle(child.style);
      }
    }
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
        child.layout(constraints.loosen(), parentUsesSize: true);

        final Size childSize = child.size;
        width = math.max(width, childSize.width);
        height = math.max(height, childSize.height);

        if (childParentData.position == CSSPositionType.fixed) {
          if (childParentData.originalRenderBoxRef != null)
            childParentData.offset = childParentData.originalRenderBoxRef.localToGlobal(Offset.zero);
        } else {
          if (childParentData.originalRenderBoxRef != null) {
            childParentData.offset = childParentData.originalRenderBoxRef.localToGlobal(Offset.zero) -
                this.localToGlobal(Offset.zero);
          }
        }
      } else {
        // Default to no constraints. (0 - infinite)
        BoxConstraints childConstraints = const BoxConstraints();

        Size trySize = constraints.biggest;
        size = trySize.isInfinite ? constraints.smallest : trySize;

        // if child has no width, calculate width by left and right.
        if (childParentData.width == 0.0 && childParentData.left != null && childParentData.right != null) {
          childConstraints = childConstraints.tighten(width: size.width - childParentData.left - childParentData.right);
        }
        // if child has not height, should be calculate height by top and bottom
        if (childParentData.height == 0.0 && childParentData.top != null && childParentData.bottom != null) {
          childConstraints =
              childConstraints.tighten(height: size.height - childParentData.top - childParentData.bottom);
        }

        child.layout(childConstraints, parentUsesSize: true);

        // Calc x,y by parentData.
        double x, y;

        // Offset to global coordinate system of base
        if (childParentData.position == CSSPositionType.absolute || childParentData.position == CSSPositionType.fixed) {
          Offset baseOffset =
              childParentData.originalRenderBoxRef.localToGlobal(Offset.zero) - localToGlobal(Offset.zero);

          double top = childParentData.top ?? baseOffset.dy;
          if (childParentData.top == null && childParentData.bottom != null)
            top = height - child.size.height - (childParentData.bottom ?? 0);
          double left = childParentData.left ?? baseOffset.dx;
          if (childParentData.left == null && childParentData.right != null) {
            left = width - child.size.width - (childParentData.right ?? 0);
          }

          x = left;
          y = top;
        } else if (childParentData.position == CSSPositionType.relative) {
          Offset baseOffset = childParentData.stackedChildOriginalRelativeOffset;
          double top = childParentData.top ?? -(childParentData.bottom ?? 0);
          double left = childParentData.left ?? -(childParentData.right ?? 0);

          RenderBox renderLayoutBox = childParentData.originalRenderBoxRef.parent as RenderBox;
          RenderBox renderPadding = childParentData.originalRenderBoxRef.parent.parent as RenderBox;
          Offset paddingOffset = renderLayoutBox.localToGlobal(Offset.zero) - renderPadding.localToGlobal(Offset.zero);
          x = baseOffset.dx + paddingOffset.dx + left;
          y = baseOffset.dy + paddingOffset.dy + top;
        }

        childParentData.offset = Offset(x ?? 0, y ?? 0);
      }

      child = childParentData.nextSibling;
    }

    if (hasNonPositionedChildren) {
      size = Size(width, height);
    }
  }

  /// Paint and order with z-index.
  @override
  void paint(PaintingContext context, Offset offset) {
    List<RenderObject> children = getChildrenAsList();
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
