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

  void updateRenderOpacity(String value, {RenderObjectWithChildMixin parentRenderObject}) {
    double opacity = CSSStyleDeclaration.isNullOrEmptyValue(value) ? 1.0 : CSSLength.toDouble(value);
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
