

/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'dart:ui' as ui;
import 'package:kraken/css.dart';

mixin CSSOpacityMixin on RenderStyleBase {

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
  double get opacity => _opacity;
  double _opacity = 1.0;
  set opacity(double? value) {
    if (value == null) return;
    assert(value >= 0.0 && value <= 1.0);
    if (_opacity == value)
      return;
    _opacity = value;
    int alpha = ui.Color.getAlphaFromOpacity(_opacity);
    renderBoxModel!.alpha = alpha;
    if (alpha != 0 && alpha != 255)
      renderBoxModel!.markNeedsCompositingBitsUpdate();
    renderBoxModel!.markNeedsPaint();
  }

  void updateOpacity(String value) {
    double? opacityValue = CSSStyleDeclaration.isNullOrEmptyValue(value) ? 1.0 : CSSLength.toDouble(value);
    opacity = opacityValue;
  }
}
