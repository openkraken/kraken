/*
 * Copyright (C) 2021-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'package:flutter/rendering.dart';
import 'package:kraken/css.dart';
import 'package:kraken/rendering.dart';
import 'package:vector_math/vector_math_64.dart';

// CSS Transforms: https://drafts.csswg.org/css-transforms/
mixin CSSTransformMixin on RenderStyle {

  static Offset DEFAULT_TRANSFORM_OFFSET = Offset(0, 0);
  static Alignment DEFAULT_TRANSFORM_ALIGNMENT = Alignment.center;

  // https://drafts.csswg.org/css-transforms-1/#propdef-transform
  // Name: transform
  // Value: none | <transform-list>
  // Initial: none
  // Applies to: transformable elements
  // Inherited: no
  // Percentages: refer to the size of reference box
  // Computed value: as specified, but with lengths made absolute
  // Canonical order: per grammar
  // Animation type: transform list, see interpolation rules
  List<CSSFunctionalNotation>? _transform;
  List<CSSFunctionalNotation>? get transform => _transform;
  set transform(List<CSSFunctionalNotation>? value) {
    // Transform should converted to matrix4 value to compare cause case such as
    // `translate3d(750rpx, 0rpx, 0rpx)` and `translate3d(100vw, 0vw, 0vw)` should considered to be equal.
    // Note this comparison cannot be done in style listener cause prevValue cannot be get in animation case.
    if (_transform == value) return;
    _transform = value;
    _transformMatrix = null;

    // Transform effect the stacking context.
    RenderBoxModel? parentRenderer = parent?.renderBoxModel;
    if (parentRenderer is RenderLayoutBox) {
      parentRenderer.markChildrenNeedsSort();
    }

    // Transform stage are applied at paint stage, should avoid re-layout.
    renderBoxModel?.markNeedsPaint();
  }

  static List<CSSFunctionalNotation>? resolveTransform(String present) {
    if (present == 'none') return null;
    return CSSFunction.parseFunction(present);
  }

  Matrix4? _transformMatrix;
  Matrix4? get transformMatrix {
    if (_transformMatrix == null && _transform != null) {
      // Illegal transform syntax will return null.
      _transformMatrix = CSSMatrix.computeTransformMatrix(_transform!, this);
    }
    return _transformMatrix;
  }
  // Transform animation drived by transformMatrix.
  set transformMatrix(Matrix4? value) {
    if (value == null || _transformMatrix == value) return;
    _transformMatrix = value;
    renderBoxModel?.markNeedsPaint();
  }

  Offset get transformOffset => _transformOffset;
  Offset _transformOffset = DEFAULT_TRANSFORM_OFFSET;
  set transformOffset(Offset value) {
    if (_transformOffset == value) return;
    _transformOffset = value;
    renderBoxModel?.markNeedsPaint();
  }

  Alignment get transformAlignment => _transformAlignment;
  Alignment _transformAlignment = DEFAULT_TRANSFORM_ALIGNMENT;
  set transformAlignment(Alignment value) {
    if (_transformAlignment == value) return;
    _transformAlignment = value;
    renderBoxModel?.markNeedsPaint();
  }

  CSSOrigin? _transformOrigin;
  CSSOrigin? get transformOrigin => _transformOrigin;
  set transformOrigin(CSSOrigin? value) {

    if (_transformOrigin == value) return;
    _transformOrigin = value;

    if (value == null) return;
    Offset oldOffset = transformOffset;
    Offset offset = value.offset;
    // Transform origin transition by offset
    if (offset.dx != oldOffset.dx || offset.dy != oldOffset.dy) {
      transformOffset = offset;
    }

    Alignment alignment = value.alignment;
    Alignment oldAlignment = transformAlignment;
    // Transform origin transition by alignment
    if (alignment.x != oldAlignment.x || alignment.y != oldAlignment.y) {
      transformAlignment = alignment;
    }
  }
}

