import 'package:flutter/rendering.dart';
import 'package:kraken/rendering.dart';
import 'package:kraken/style.dart';

mixin RelativeStyleMixin on RenderBox {
  void applyRelativeOffset(
      Offset relativeOffset, RenderBox renderBox, CSSStyleDeclaration style) {
    BoxParentData boxParentData = renderBox?.parentData;
    if (boxParentData != null) {
      Offset styleOffset;
      // Text node does not have relative offset
      if (renderBox is! RenderTextBox) {
        styleOffset = getRelativeOffset(style);
      }
      boxParentData.offset = relativeOffset == null
          ? styleOffset
          : styleOffset == null
              ? relativeOffset
              : relativeOffset.translate(styleOffset.dx, styleOffset.dy);
    }
  }

  Offset getRelativeOffset(CSSStyleDeclaration style) {
    if (style['position'] == 'relative') {
      double dx;
      double dy;
      if (style.contains('left')) {
        dx = Length.toDisplayPortValue(style['left']);
      } else if (style.contains('right')) {
        dx = -Length.toDisplayPortValue(style['right']);
      }

      if (style.contains('top')) {
        dy = Length.toDisplayPortValue(style['top']);
      } else if (style.contains('bottom')) {
        dy = -Length.toDisplayPortValue(style['bottom']);
      }

      if (dx != null || dy != null) {
        return Offset(dx ?? 0, dy ?? 0);
      }
    }
    return null;
  }
}
