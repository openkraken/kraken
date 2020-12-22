/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:kraken/module.dart';
import 'package:kraken/rendering.dart';

mixin RenderOpacityMixin on RenderBoxModelBase {
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
  set opacity(double value) {
    if (value == null) return;
    assert(value >= 0.0 && value <= 1.0);
    if (_opacity == value)
      return;
    _opacity = value;
    _alpha = ui.Color.getAlphaFromOpacity(_opacity);
    if (_alpha != 0 && _alpha != 255)
      markNeedsCompositingBitsUpdate();
    markNeedsPaint();
  }

  bool opacityAlwaysNeedsCompositing() => _alpha != 0 && _alpha != 255;

  int _alpha = ui.Color.getAlphaFromOpacity(1.0);

  OpacityLayer _opacityLayer;

  void paintOpacity(PaintingContext context, Offset offset, PaintingContextCallback callback) {
    if (_alpha == 0) {
      // No need to keep the layer. We'll create a new one if necessary.
      _opacityLayer = null;
      callback(context, offset);
      return;
    }
    if (_alpha == 255) {
      _opacityLayer = null;
      // No need to keep the layer. We'll create a new one if necessary.
      callback(context, offset);
      return;
    }

    if (kProfileMode) {
      PerformanceTiming.instance(contextId).mark(PERF_PAINT_OPACITY_START, uniqueId: targetId);
    }

    _opacityLayer = context.pushOpacity(offset, _alpha, (context, offset) {
      if (kProfileMode) {
        PerformanceTiming.instance(contextId).mark(PERF_PAINT_OPACITY_END, uniqueId: targetId);
      }
      callback(context, offset);
    }, oldLayer: _opacityLayer);
  }

  void debugOpacityProperties(DiagnosticPropertiesBuilder properties) {
    if (_alpha != 0 && _alpha != 255) properties.add(DiagnosticsProperty('alpha', _alpha));;
  }
}

