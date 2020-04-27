/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'package:flutter/rendering.dart';
import 'package:kraken/element.dart';
import 'package:kraken/css.dart';

mixin CSSOpacityMixin on Node {
  RenderOpacity renderOpacity;

  RenderObject initRenderOpacity(RenderObject renderObject, CSSStyleDeclaration style) {
    bool existsOpacity = style.contains('opacity');
    if (existsOpacity) {
      double opacity = _convertStringToDouble(style['opacity']);
      renderOpacity = RenderOpacity(
        opacity: opacity,
        child: renderObject
      );
      return renderOpacity;
    } else {
      return renderObject;
    }
  }

  double _convertStringToDouble(String str) {
    return isEmptyStyleValue(str) ? 1.0 : CSSLength.toDouble(str);
  }

  void updateRenderOpacity(String value, { RenderObjectWithChildMixin parentRenderObject }) {
    double opacity = _convertStringToDouble(value);
    if (renderOpacity != null) {
      renderOpacity.opacity = opacity;
    } else {
      RenderObject child = parentRenderObject.child;
      // Drop child by set null first.
      parentRenderObject.child = null;
      renderOpacity = RenderOpacity(
        opacity: opacity,
        child: child,
      );
      parentRenderObject.child = renderOpacity;
    }
  }
}
