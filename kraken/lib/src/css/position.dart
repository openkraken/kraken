import 'package:flutter/rendering.dart';
import 'package:kraken/element.dart';
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

/// Sets vertical alignment of an inline, inline-block
enum VerticalAlign {
  /// Aligns the baseline of the element with the baseline of its parent.
  baseline,

  /// Aligns the top of the element and its descendants with the top of the entire line.
  top,

  /// Aligns the bottom of the element and its descendants with the bottom of the entire line.
  bottom,

  /// Aligns the middle of the element with the baseline plus half the x-height of the parent.
  /// @TODO not supported
  ///  middle,
}

CSSPositionType resolvePositionFromStyle(CSSStyleDeclaration style) {
  return resolveCSSPosition(style['position']);
}

CSSPositionType resolveCSSPosition(String input) {
  switch (input) {
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

void applyRelativeOffset(Offset relativeOffset, RenderBox renderBox, CSSStyleDeclaration style) {
  RenderLayoutParentData boxParentData = renderBox?.parentData;

  // Don't set offset if it was already set
  if (boxParentData.isOffsetSet) {
    return;
  }

  if (boxParentData != null) {
    Offset styleOffset;
    // Text node does not have relative offset
    if (renderBox is! RenderTextBox && style != null) {
      styleOffset = getRelativeOffset(style);
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

Offset getRelativeOffset(CSSStyleDeclaration style) {
  CSSPositionType position = resolvePositionFromStyle(style);
  if (position == CSSPositionType.relative) {
    double dx;
    double dy;

    // @TODO support auto value
    if (style.contains('left') && style['left'] != 'auto') {
      dx = CSSLength.toDisplayPortValue(style['left']);
    } else if (style.contains('right') && style['right'] != 'auto') {
      var _dx = CSSLength.toDisplayPortValue(style['right']);
      if (_dx != null) dx = -_dx;
    }

    if (style.contains('top') && style['top'] != 'auto') {
      dy = CSSLength.toDisplayPortValue(style['top']);
    } else if (style.contains('bottom') && style['bottom'] != 'auto') {
      var _dy = CSSLength.toDisplayPortValue(style['bottom']);
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
  } else if (child is RenderElementBoundary) {
    return child.widthSizeType;
  }
  return null;
}

BoxSizeType _getChildHeightSizeType(RenderBox child) {
  if (child is RenderTextBox) {
    return child.heightSizeType;
  } else if (child is RenderElementBoundary) {
    return child.heightSizeType;
  }
  return null;
}

void layoutPositionedChild(Element parentElement, RenderBox parent, RenderBox child) {
  BoxConstraints parentConstraints = parentElement.renderDecoratedBox.constraints;

  final RenderLayoutParentData childParentData = child.parentData;

  // Default to no constraints. (0 - infinite)
  BoxConstraints childConstraints = const BoxConstraints();

  Size trySize = parentConstraints.biggest;
  Size parentSize = trySize.isInfinite ? parentConstraints.smallest : trySize;

  BoxSizeType widthType = _getChildWidthSizeType(child);
  BoxSizeType heightType = _getChildHeightSizeType(child);

  // If child has no width, calculate width by left and right.
  // Element with intrinsic size such as image will not stretch
  if (childParentData.width == 0.0 &&
      widthType != BoxSizeType.intrinsic &&
      childParentData.left != null &&
      childParentData.right != null) {
    childConstraints = childConstraints.tighten(width: parentSize.width - childParentData.left - childParentData.right);
  }
  // If child has not height, should be calculate height by top and bottom
  if (childParentData.height == 0.0 &&
      heightType != BoxSizeType.intrinsic &&
      childParentData.top != null &&
      childParentData.bottom != null) {
    childConstraints =
        childConstraints.tighten(height: parentSize.height - childParentData.top - childParentData.bottom);
  }

  child.layout(childConstraints, parentUsesSize: true);
}

void setPositionedChildOffset(RenderBoxModel parent, RenderBox child, Size parentSize) {
  double width = parentSize.width;
  double height = parentSize.height;

  final RenderLayoutParentData childParentData = child.parentData;
  // Calc x,y by parentData.
  double x, y;

  // Offset to global coordinate system of base
  if (childParentData.position == CSSPositionType.absolute || childParentData.position == CSSPositionType.fixed) {
    Offset baseOffset =
        childParentData.renderPositionHolder.localToGlobal(Offset.zero) - parent.localToGlobal(Offset.zero);
    // Positioned element is positioned relative to the edge of
    // padding box of containing block
    // https://www.w3.org/TR/CSS2/visudet.html#containing-block-details
    double top = childParentData.top != null ? (childParentData.top) : baseOffset.dy;
    if (childParentData.top == null && childParentData.bottom != null) {
      top = height - child.size.height - ((childParentData.bottom) ?? 0);
    }

    double left = childParentData.left != null ? (childParentData.left) : baseOffset.dx;
    if (childParentData.left == null && childParentData.right != null) {
      left = width - child.size.width - ((childParentData.right) ?? 0);
    }

    x = left;
    y = top;
  }

  childParentData.offset = Offset(x ?? 0, y ?? 0);
}

double getFontSize(CSSStyleDeclaration style) {
  if (style.contains(FONT_SIZE)) {
    return CSSLength.toDisplayPortValue(style[FONT_SIZE]) ?? DEFAULT_FONT_SIZE;
  } else {
    return DEFAULT_FONT_SIZE;
  }
}

double getLineHeight(CSSStyleDeclaration style) {
  String lineHeightStr = style[LINE_HEIGHT];
  double lineHeight;
  if (lineHeightStr != '') {
    if (lineHeightStr.endsWith('px') ||
      lineHeightStr.endsWith('rpx')
    ) {
      lineHeight = CSSLength.toDisplayPortValue(style[LINE_HEIGHT]);
    } else {
      lineHeight = getFontSize(style) * double.parse(lineHeightStr);
    }
  }
  return lineHeight;
}

VerticalAlign getVerticalAlign(CSSStyleDeclaration style) {
  String verticalAlign = style[VERTICAL_ALIGN];

  switch (verticalAlign) {
    case 'top':
      return VerticalAlign.top;
    case 'bottom':
      return VerticalAlign.bottom;
    case 'text-top':
      return VerticalAlign.textTop;
    case 'text-bottom':
      return VerticalAlign.textBottom;
    case 'middle':
      return VerticalAlign.middle;
  }
  return VerticalAlign.baseline;
}
