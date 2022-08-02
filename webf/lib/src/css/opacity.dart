/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'dart:ui' as ui;

import 'package:webf/css.dart';
import 'package:webf/rendering.dart';

mixin CSSOpacityMixin on RenderStyle {
  /// The fraction to scale the child's alpha value.
  ///
  /// An opacity of 1.0 is fully opaque. An opacity of 0.0 is fully transparent
  /// (i.e., invisible).
  ///
  /// The opacity must not be null.
  ///
  /// Values 1.0 and 0.0 are painted with a fast path. Other values
  /// require painting the child into an intermediate buffer, which is
  /// expensive.
  @override
  double get opacity => _opacity ?? 1.0;
  double? _opacity;
  set opacity(double? value) {
    if (_opacity == value) return;

    _opacity = value;
    int alpha = ui.Color.getAlphaFromOpacity(opacity);
    renderBoxModel!.alpha = alpha;

    // Mark the compositing state for this render object as dirty
    // cause it will create new layer when opacity is valid.
    if (alpha != 0 && alpha != 255) {
      renderBoxModel?.markNeedsCompositingBitsUpdate();
    }
    // Opacity effect the stacking context.
    RenderBoxModel? parentRenderer = parent?.renderBoxModel;
    if (parentRenderer is RenderLayoutBox) {
      parentRenderer.markChildrenNeedsSort();
    }

    renderBoxModel?.markNeedsPaint();
  }

  static double? resolveOpacity(String value) {
    return CSSStyleDeclaration.isNullOrEmptyValue(value) ? 1.0 : CSSLength.toDouble(value);
  }
}
