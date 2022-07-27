/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:flutter/rendering.dart';
import 'package:webf/css.dart';
import 'package:webf/rendering.dart';

const Offset _DEFAULT_TRANSFORM_OFFSET = Offset.zero;
const Alignment _DEFAULT_TRANSFORM_ALIGNMENT = Alignment.center;

// CSS Transforms: https://drafts.csswg.org/css-transforms/
mixin CSSTransformMixin on RenderStyle {
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

    // Mark the compositing state for this render object as dirty
    // cause it will create new layer when transform is valid.
    if (value != null) {
      renderBoxModel?.markNeedsCompositingBitsUpdate();
    }

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

  // Effective transform matrix after renderBoxModel has been layouted.
  // Copy from flutter [RenderTransform._effectiveTransform]
  Matrix4 get effectiveTransformMatrix {
    // Make sure it is used after renderBoxModel been created.
    assert(renderBoxModel != null);
    RenderBoxModel boxModel = renderBoxModel!;
    final Matrix4 result = Matrix4.identity();
    result.translate(transformOffset.dx, transformOffset.dy);
    late Offset translation;
    if (transformAlignment != Alignment.topLeft) {
      // Use boxSize instead of size to avoid Flutter cannot access size beyond parent access warning
      translation = boxModel.hasSize ? transformAlignment.alongSize(boxModel.boxSize!) : Offset.zero;
      result.translate(translation.dx, translation.dy);
    }

    if (transformMatrix != null) {
      result.multiply(transformMatrix!);
    }

    if (transformAlignment != Alignment.topLeft) result.translate(-translation.dx, -translation.dy);

    result.translate(-transformOffset.dx, -transformOffset.dy);

    return result;
  }

  // Effective transform offset after renderBoxModel has been layouted.
  Offset? get effectiveTransformOffset {
    // Make sure it is used after renderBoxModel been created.
    assert(renderBoxModel != null);
    Offset? offset = MatrixUtils.getAsTranslation(effectiveTransformMatrix);
    return offset;
  }

  Offset get transformOffset => _transformOffset;
  Offset _transformOffset = _DEFAULT_TRANSFORM_OFFSET;
  set transformOffset(Offset value) {
    if (_transformOffset == value) return;
    _transformOffset = value;
    renderBoxModel?.markNeedsPaint();
  }

  Alignment get transformAlignment => _transformAlignment;
  Alignment _transformAlignment = _DEFAULT_TRANSFORM_ALIGNMENT;
  set transformAlignment(Alignment value) {
    if (_transformAlignment == value) return;
    _transformAlignment = value;
    renderBoxModel?.markNeedsPaint();
  }

  CSSOrigin? _transformOrigin;
  CSSOrigin get transformOrigin =>
      _transformOrigin ?? const CSSOrigin(_DEFAULT_TRANSFORM_OFFSET, _DEFAULT_TRANSFORM_ALIGNMENT);
  set transformOrigin(CSSOrigin? value) {
    if (_transformOrigin == value) return;
    _transformOrigin = value;

    Offset oldOffset = transformOffset;
    Offset offset = transformOrigin.offset;
    // Transform origin transition by offset
    if (offset.dx != oldOffset.dx || offset.dy != oldOffset.dy) {
      transformOffset = offset;
    }

    Alignment alignment = transformOrigin.alignment;
    Alignment oldAlignment = transformAlignment;
    // Transform origin transition by alignment
    if (alignment.x != oldAlignment.x || alignment.y != oldAlignment.y) {
      transformAlignment = alignment;
    }
  }
}
