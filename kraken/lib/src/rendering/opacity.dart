// @dart=2.9

/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

mixin RenderOpacityMixin on RenderBox {
  bool opacityAlwaysNeedsCompositing() => alpha != 0 && alpha != 255;

  int alpha = ui.Color.getAlphaFromOpacity(1.0);

  OpacityLayer _opacityLayer;

  void paintOpacity(PaintingContext context, Offset offset, PaintingContextCallback callback) {
    if (alpha == 0) {
      // No need to keep the layer. We'll create a new one if necessary.
      _opacityLayer = null;
      callback(context, offset);
      return;
    }
    if (alpha == 255) {
      _opacityLayer = null;
      // No need to keep the layer. We'll create a new one if necessary.
      callback(context, offset);
      return;
    }

    _opacityLayer = context.pushOpacity(offset, alpha, callback, oldLayer: _opacityLayer);
  }

  void debugOpacityProperties(DiagnosticPropertiesBuilder properties) {
    if (alpha != 0 && alpha != 255) properties.add(DiagnosticsProperty('alpha', alpha));;
  }
}

