/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:kraken/css.dart';
import 'package:kraken/rendering.dart';

enum CSSPositionType {
  static,
  relative,
  absolute,
  fixed,
  sticky,
}

mixin CSSPositionMixin on RenderStyle {

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
  @override
  CSSLengthValue get top => _top ?? CSSLengthValue.auto;
  CSSLengthValue? _top;
  set top(CSSLengthValue? value) {
    if (_top == value) {
      return;
    }
    _top = value;
    _markParentNeedsLayout();
  }

  @override
  CSSLengthValue get bottom => _bottom ?? CSSLengthValue.auto;
  CSSLengthValue? _bottom;
  set bottom(CSSLengthValue? value) {
    if (_bottom == value) {
      return;
    }
    _bottom = value;
    _markParentNeedsLayout();
  }

  @override
  CSSLengthValue get left => _left ?? CSSLengthValue.auto;
  CSSLengthValue? _left;
  set left(CSSLengthValue? value) {
    if (_left == value) {
      return;
    }
    _left = value;
    _markParentNeedsLayout();
  }

  @override
  CSSLengthValue get right => _right ?? CSSLengthValue.auto;
  CSSLengthValue? _right;
  set right(CSSLengthValue? value) {
    if (_right == value) {
      return;
    }
    _right = value;
    _markParentNeedsLayout();
  }
  // The z-index property specifies the stack order of an element.
  // Only works on positioned elements(position: absolute/relative/fixed).
  int? _zIndex;

  @override
  int? get zIndex => _zIndex;

  set zIndex(int? value) {
    if (_zIndex == value) return;
    _zIndex = value;
    _markNeedsSort();
    _markParentNeedsPaint();
  }

  CSSPositionType _position = DEFAULT_POSITION_TYPE;

  @override
  CSSPositionType get position => _position;

  set position(CSSPositionType value) {
    if (_position == value) return;
    _position = value;

    // Position effect the stacking context.
    _markNeedsSort();
    _markParentNeedsLayout();
    // Position change may affect transformed display
    // https://www.w3.org/TR/css-display-3/#transformations

    // The position changes of the node may affect the whitespace of the nextSibling and previousSibling text node so prev and next node require layout.
    renderBoxModel?.markAdjacentRenderParagraphNeedsLayout();
  }

  void _markNeedsSort() {
    if (renderBoxModel?.parentData is RenderLayoutParentData) {
      AbstractNode? parent = renderBoxModel!.parent;
      if (parent is RenderLayoutBox) {
        parent.markChildrenNeedsSort();
      }
    }
  }

  void _markParentNeedsLayout() {
    // Should mark positioned element's containing block needs layout directly
    // cause RelayoutBoundary of positioned element will prevent the needsLayout flag
    // to bubble up in the RenderObject tree.
    if (renderBoxModel?.parentData is RenderLayoutParentData) {
      RenderStyle renderStyle = renderBoxModel!.renderStyle;
      if (renderStyle.position != DEFAULT_POSITION_TYPE) {
        AbstractNode? parent = renderBoxModel!.parent;
        if (parent is RenderObject) {
          parent.markNeedsLayout();
        }
      }
    }
  }

  void _markParentNeedsPaint() {
    // Should mark positioned element's containing block needs layout directly
    // cause RepaintBoundary of positioned element will prevent the needsLayout flag
    // to bubble up in the RenderObject tree.
    if (renderBoxModel!.parentData is RenderLayoutParentData) {
      RenderStyle renderStyle = renderBoxModel!.renderStyle;
      RenderStyle? parentRenderStyle = renderStyle.parent;
      // The z-index CSS property sets the z-order of a positioned element and its descendants or flex items.
      if (renderStyle.position != DEFAULT_POSITION_TYPE ||
        parentRenderStyle?.effectiveDisplay == CSSDisplay.flex ||
        parentRenderStyle?.effectiveDisplay == CSSDisplay.inlineFlex) {

        AbstractNode? parent = renderBoxModel!.parent;
        if (parent is RenderObject) {
          parent.markNeedsPaint();
        }
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
