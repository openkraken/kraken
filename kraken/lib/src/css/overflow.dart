/*
 * Copyright (C) 2021-present The Kraken authors. All rights reserved.
 */

import 'package:kraken/css.dart';

// CSS Overflow: https://drafts.csswg.org/css-overflow-3/

enum CSSOverflowType {
  auto,
  visible,
  hidden,
  scroll,
  clip
}

mixin CSSOverflowMixin on RenderStyle {
  @override
  CSSOverflowType get overflowX => _overflowX ?? CSSOverflowType.visible;
  CSSOverflowType? _overflowX;
  set overflowX(CSSOverflowType? value) {
    if (_overflowX == value) return;
    _overflowX = value;
  }

  @override
  CSSOverflowType get overflowY => _overflowY ?? CSSOverflowType.visible;
  CSSOverflowType? _overflowY;
  set overflowY(CSSOverflowType? value) {
    if (_overflowY == value) return;
    _overflowY = value;
  }

  // As specified, except with visible/clip computing to auto/hidden (respectively)
  // if one of overflow-x or overflow-y is neither visible nor clip.
  // https://www.w3.org/TR/css-overflow-3/#propdef-overflow-x
  @override
  CSSOverflowType get effectiveOverflowX {
    if (overflowX == CSSOverflowType.visible && overflowY != CSSOverflowType.visible) {
      return CSSOverflowType.auto;
    }
    if (overflowX == CSSOverflowType.clip && overflowY != CSSOverflowType.clip) {
      return CSSOverflowType.hidden;
    }
    return overflowX;
  }

  // As specified, except with visible/clip computing to auto/hidden (respectively)
  // if one of overflow-x or overflow-y is neither visible nor clip.
  // https://www.w3.org/TR/css-overflow-3/#propdef-overflow-y
  @override
  CSSOverflowType get effectiveOverflowY {
    if (overflowY == CSSOverflowType.visible && overflowX != CSSOverflowType.visible) {
      return CSSOverflowType.auto;
    }
    if (overflowY == CSSOverflowType.clip && overflowX != CSSOverflowType.clip) {
      return CSSOverflowType.hidden;
    }
    return overflowY;
  }

  static CSSOverflowType resolveOverflowType(String definition) {
    switch (definition) {
      case HIDDEN:
        return CSSOverflowType.hidden;
      case SCROLL:
        return CSSOverflowType.scroll;
      case AUTO:
        return CSSOverflowType.auto;
      case CLIP:
        return CSSOverflowType.clip;
      case VISIBLE:
      default:
        return CSSOverflowType.visible;
    }
  }
}

