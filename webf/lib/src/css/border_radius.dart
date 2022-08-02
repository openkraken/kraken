/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
import 'dart:ui';

import 'package:webf/css.dart';

mixin CSSBorderRadiusMixin on RenderStyle {
  CSSBorderRadius? _borderTopLeftRadius;
  set borderTopLeftRadius(CSSBorderRadius? value) {
    if (value == _borderTopLeftRadius) return;
    _borderTopLeftRadius = value;
    renderBoxModel?.markNeedsPaint();
  }

  @override
  CSSBorderRadius get borderTopLeftRadius => _borderTopLeftRadius ?? CSSBorderRadius.zero;

  CSSBorderRadius? _borderTopRightRadius;
  set borderTopRightRadius(CSSBorderRadius? value) {
    if (value == _borderTopRightRadius) return;
    _borderTopRightRadius = value;
    renderBoxModel?.markNeedsPaint();
  }

  @override
  CSSBorderRadius get borderTopRightRadius => _borderTopRightRadius ?? CSSBorderRadius.zero;

  CSSBorderRadius? _borderBottomRightRadius;
  set borderBottomRightRadius(CSSBorderRadius? value) {
    if (value == _borderBottomRightRadius) return;
    _borderBottomRightRadius = value;
    renderBoxModel?.markNeedsPaint();
  }

  @override
  CSSBorderRadius get borderBottomRightRadius => _borderBottomRightRadius ?? CSSBorderRadius.zero;

  CSSBorderRadius? _borderBottomLeftRadius;
  set borderBottomLeftRadius(CSSBorderRadius? value) {
    if (value == _borderBottomLeftRadius) return;
    _borderBottomLeftRadius = value;
    renderBoxModel?.markNeedsPaint();
  }

  @override
  CSSBorderRadius get borderBottomLeftRadius => _borderBottomLeftRadius ?? CSSBorderRadius.zero;

  @override
  List<Radius>? get borderRadius {
    bool hasBorderRadius = borderTopLeftRadius != CSSBorderRadius.zero ||
        borderTopRightRadius != CSSBorderRadius.zero ||
        borderBottomRightRadius != CSSBorderRadius.zero ||
        borderBottomLeftRadius != CSSBorderRadius.zero;

    return hasBorderRadius
        ? [
            borderTopLeftRadius.computedRadius,
            borderTopRightRadius.computedRadius,
            borderBottomRightRadius.computedRadius,
            borderBottomLeftRadius.computedRadius
          ]
        : null;
  }
}
