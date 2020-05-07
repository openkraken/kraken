import 'package:flutter/rendering.dart';
import 'package:kraken/rendering.dart';
import 'package:kraken/css.dart';

// CSS Positioned Layout: https://drafts.csswg.org/css-position/

enum CSSPositionType {
  static,
  relative,
  absolute,
  fixed,
  sticky,
}

CSSPositionType getPositionFromStyle(CSSStyleDeclaration style) {
  switch (style['position']) {
    case 'relative':
      return CSSPositionType.relative;
    case 'absolute':
      return CSSPositionType.absolute;
    case 'fixed':
      return CSSPositionType.fixed;
    case 'sticky':
      return CSSPositionType.sticky;
  }
  return CSSPositionType.static;
}

mixin CSSPositionMixin on RenderBox {
  void applyRelativeOffset(
      Offset relativeOffset, RenderBox renderBox, CSSStyleDeclaration style) {
    BoxParentData boxParentData = renderBox?.parentData;
    if (boxParentData != null) {
      Offset styleOffset;
      // Text node does not have relative offset
      if (renderBox is! RenderTextBox && style != null) {
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
    CSSPositionType position = getPositionFromStyle(style);
    if (position == CSSPositionType.relative) {
      double dx;
      double dy;
      if (style.contains('left')) {
        dx = CSSLength.toDisplayPortValue(style['left']);
      } else if (style.contains('right')) {
        dx = -CSSLength.toDisplayPortValue(style['right']);
      }

      if (style.contains('top')) {
        dy = CSSLength.toDisplayPortValue(style['top']);
      } else if (style.contains('bottom')) {
        dy = -CSSLength.toDisplayPortValue(style['bottom']);
      }

      if (dx != null || dy != null) {
        return Offset(dx ?? 0, dy ?? 0);
      }
    }
    return null;
  }
}
