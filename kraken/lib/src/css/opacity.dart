/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'package:flutter/rendering.dart';
import 'package:kraken/element.dart';
import 'package:kraken/rendering.dart';
import 'package:kraken/css.dart';

mixin CSSOpacityMixin on Node {
  KrakenRenderOpacity renderOpacity;

  RenderObject initRenderOpacity(RenderObject renderObject, CSSStyleDeclaration style) {
    bool existsOpacity = style.contains(OPACITY);
    if (existsOpacity) {
      double opacity = _convertStringToDouble(style[OPACITY]);
      renderOpacity = KrakenRenderOpacity(opacity: opacity, child: renderObject);
      return renderOpacity;
    } else {
      return renderObject;
    }
  }

  double _convertStringToDouble(String str) {
    return CSSStyleDeclaration.isNullOrEmptyValue(str) ? 1.0 : CSSLength.toDouble(str);
  }

  void updateRenderOpacity(String value, {RenderObjectWithChildMixin parentRenderObject}) {
    double opacity = _convertStringToDouble(value);
    if (renderOpacity != null) {
      renderOpacity.opacity = opacity;
    } else {
      RenderObject child = parentRenderObject.child;
      // Drop child by set null first.
      parentRenderObject.child = null;
      renderOpacity = KrakenRenderOpacity(
        opacity: opacity,
        child: child,
      );
      parentRenderObject.child = renderOpacity;
    }
  }
}
