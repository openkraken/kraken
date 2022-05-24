/*
 * Copyright (C) 2019-present The Kraken authors. All rights reserved.
 */
import 'package:flutter/rendering.dart';
import 'package:kraken/rendering.dart';

mixin RenderOpacityMixin on RenderBoxModelBase {
  bool opacityAlwaysNeedsCompositing() {
    int alpha = renderStyle.alpha;
    return alpha != 0 && alpha != 255;
  }

  final LayerHandle<OpacityLayer> _opacityLayer = LayerHandle<OpacityLayer>();

  void disposeOpacityLayer() {
    _opacityLayer.layer = null;
  }

  void paintOpacity(PaintingContext context, Offset offset,
      PaintingContextCallback callback) {
    int alpha = renderStyle.alpha;

    if (alpha == 255) {
      _opacityLayer.layer = null;
      // No need to keep the layer. We'll create a new one if necessary.
      callback(context, offset);
      return;
    }

    _opacityLayer.layer =
        context.pushOpacity(offset, alpha, callback, oldLayer: _opacityLayer.layer);
  }

  void debugOpacityProperties(DiagnosticPropertiesBuilder properties) {
    int alpha = renderStyle.alpha;
    if (alpha != 0 && alpha != 255)
      properties.add(DiagnosticsProperty('alpha', alpha));
  }
}
