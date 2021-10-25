/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'package:kraken/rendering.dart';
import 'package:kraken/css.dart';

enum CSSPositionType {
  static,
  relative,
  absolute,
  fixed,
  sticky,
}

mixin CSSPositionMixin on RenderStyleBase {

  static const CSSPositionType DEFAULT_POSITION_TYPE = CSSPositionType.static;

  // https://drafts.csswg.org/css-position/#insets
  // Name: top, right, bottom, left
  // Value: auto | <length-percentage>
  // Initial: auto
  // Applies to: positioned elements
  // Inherited: no
  // Percentages: refer to size of containing block; see prose
  // Computed value: the keyword auto or a computed <length-percentage> value
  // Canonical order: per grammar
  // Animation type: by computed value type
  CSSLengthValue? _top;
  CSSLengthValue get top {
    return _top ?? CSSLengthValue.auto;
  }
  set top(CSSLengthValue? value) {
    if (_top == value) {
      return;
    }
    _top = value;
    _markParentNeedsLayout();
  }

  CSSLengthValue? _bottom;
  CSSLengthValue get bottom {
    return _bottom ?? CSSLengthValue.auto;
  }
  set bottom(CSSLengthValue? value) {
    if (_bottom == value) {
      return;
    }
    _bottom = value;
    _markParentNeedsLayout();
  }

  CSSLengthValue? _left;
  CSSLengthValue get left {
    return _left ?? CSSLengthValue.auto;
  }
  set left(CSSLengthValue? value) {
    if (_left == value) {
      return;
    }
    _left = value;
    _markParentNeedsLayout();
  }

  CSSLengthValue? _right;
  CSSLengthValue get right {
    return _right ?? CSSLengthValue.auto;
  }
  set right(CSSLengthValue? value) {
    if (_right == value) {
      return;
    }
    _right = value;
    _markParentNeedsLayout();
  }

  int? _zIndex;
  int? get zIndex {
    return _zIndex;
  }
  set zIndex(int? value) {
    if (_zIndex == value) return;
    _zIndex = value;
    _markParentNeedsLayout();
  }

  CSSPositionType _position = DEFAULT_POSITION_TYPE;
  CSSPositionType get position {
    return _position;
  }
  set position(CSSPositionType value) {
    if (_position == value) return;
    _position = value;
    _markParentNeedsLayout();
    // Position change may affect transformed display
    // https://www.w3.org/TR/css-display-3/#transformations
  }

  void _markParentNeedsLayout() {
    // Should mark positioned element's containing block needs layout directly
    // cause RelayoutBoundary of positioned element will prevent the needsLayout flag
    // to bubble up in the RenderObject tree.
    if (renderBoxModel!.parentData is RenderLayoutParentData) {
      RenderStyle renderStyle = renderBoxModel!.renderStyle;
      RenderStyle? parentRenderStyle = renderStyle.parent;
      // The z-index CSS property sets the z-order of a positioned element and its descendants or flex items.
      if (renderStyle.position != DEFAULT_POSITION_TYPE ||
        parentRenderStyle?.effectiveDisplay == CSSDisplay.flex ||
        parentRenderStyle?.effectiveDisplay == CSSDisplay.inlineFlex) {
        RenderBoxModel parent = renderBoxModel!.parent as RenderBoxModel;
        parent.markNeedsPaint();
      }
    }
  }

  static CSSPositionType resolvePositionType(String? input) {
    switch (input) {
      case RELATIVE:
        return CSSPositionType.relative;
      case ABSOLUTE:
        return CSSPositionType.absolute;
      case FIXED:
        return CSSPositionType.fixed;
      case STICKY:
        return CSSPositionType.sticky;
      default:
        return CSSPositionType.static;
    }
  }

}
