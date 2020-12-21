import 'dart:ui' show ImageFilter;
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:kraken/module.dart';

mixin RenderColorFilter on RenderBox {
  ColorFilter _colorFilter;
  ColorFilter get colorFilter => _colorFilter;
  set colorFilter(ColorFilter value) {
    if (_colorFilter != value) {
      _colorFilter = value;
      markNeedsPaint();
    }
  }

  void paintColorFilter(PaintingContext context, Offset offset, int contextId, PaintingContextCallback callback) {
    if (_colorFilter != null) {
      if (kProfileMode) {
        PerformanceTiming.instance(contextId).mark(PERF_PAINT_COLOR_FILTER_START);
      }

      context.pushColorFilter(offset, _colorFilter, (context, offset) {
        if (kProfileMode) {
          PerformanceTiming.instance(contextId).mark(PERF_PAINT_COLOR_FILTER_END);
        }

        callback(context, offset);
      });
    } else {
      callback(context, offset);
    }
  }
}

mixin RenderImageFilter on RenderBox {
  ImageFilter _imageFilter;
  ImageFilter get imageFilter => _imageFilter;
  set imageFilter(ImageFilter value) {
    if (_imageFilter != value) {
      _imageFilter = value;
      markNeedsPaint();
    }
  }

  ImageFilterLayer _imageFilterLayer;

  void paintImageFilter(PaintingContext context, Offset offset, int contextId, PaintingContextCallback callback) {
    if (_imageFilter != null) {
      if (kProfileMode) {
        PerformanceTiming.instance(contextId).mark(PERF_PAINT_IMAGE_FILTER_START);
      }

      _imageFilterLayer ??= ImageFilterLayer();
      _imageFilterLayer.imageFilter = imageFilter;

      context.pushLayer(_imageFilterLayer, (context, offset) {
        if (kProfileMode) {
          PerformanceTiming.instance(contextId).mark(PERF_PAINT_IMAGE_FILTER_END);
        }
        callback(context, offset);
      }, offset);
    } else {
      callback(context, offset);
    }
  }
}
