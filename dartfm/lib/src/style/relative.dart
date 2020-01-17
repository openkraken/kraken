import 'package:flutter/rendering.dart';
import 'package:kraken/element.dart';
import 'package:kraken/style.dart';

mixin RelativeStyleMixin on RenderBox {
  void applyRelativeOffset(Offset relativeOffset, RenderBox renderBox, int nodeId) {
    BoxParentData boxParentData = renderBox?.parentData;
    if (boxParentData != null) {
      Offset styleOffset;
      Element el = nodeMap[nodeId];
      Style style = el.style;
      styleOffset = getRelativeOffset(style);
      boxParentData.offset = relativeOffset == null
          ? styleOffset
          : styleOffset == null
              ? relativeOffset
              : relativeOffset.translate(styleOffset.dx, styleOffset.dy);
    }
  }

  Offset getRelativeOffset(Style style) {
    if (style?.position == 'relative') {
      double dx;
      double dy;
      if (style.left != null) {
        dx = style.left;
      } else if (style.right != null) {
        dx = -style.right;
      }

      if (style.top != null) {
        dy = style.top;
      } else if (style.bottom != null) {
        dy = -style.bottom;
      }

      if (dx != null || dy != null) {
        return Offset(dx ?? 0, dy ?? 0);
      }
    }
    return null;
  }
}
