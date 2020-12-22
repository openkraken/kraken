import 'dart:ui' show ImageFilter;
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:kraken/module.dart';
import 'package:kraken/rendering.dart';

mixin RenderColorFilter on RenderBoxModelBase {
  ColorFilter _colorFilter;
  ColorFilter get colorFilter => _colorFilter;
  set colorFilter(ColorFilter value) {
    if (_colorFilter != value) {
      _colorFilter = value;
      markNeedsPaint();
    }
  }

  void paintColorFilter(PaintingContext context, Offset offset, PaintingContextCallback callback) {
    if (_colorFilter != null) {
      print('paint color filter');
      if (kProfileMode) {
        PerformanceTiming.instance(contextId).mark(PERF_PAINT_COLOR_FILTER_START, uniqueId: targetId);
      }

      context.pushColorFilter(offset, _colorFilter, (context, offset) {
        if (kProfileMode) {
          PerformanceTiming.instance(contextId).mark(PERF_PAINT_COLOR_FILTER_END, uniqueId: targetId);
        }

        callback(context, offset);
      });
    } else {
      callback(context, offset);
    }
  }
}

mixin RenderImageFilter on RenderBoxModelBase {
  ImageFilter _imageFilter;
  ImageFilter get imageFilter => _imageFilter;
  set imageFilter(ImageFilter value) {
    if (_imageFilter != value) {
      _imageFilter = value;
      markNeedsPaint();
    }
  }

  ImageFilterLayer _imageFilterLayer;

  void paintImageFilter(PaintingContext context, Offset offset, PaintingContextCallback callback) {
    if (_imageFilter != null) {
      print('print image filter');
      if (kProfileMode) {
        PerformanceTiming.instance(contextId).mark(PERF_PAINT_IMAGE_FILTER_START, uniqueId: targetId);
      }

      _imageFilterLayer ??= ImageFilterLayer();
      _imageFilterLayer.imageFilter = imageFilter;

      context.pushLayer(_imageFilterLayer, (context, offset) {
        if (kProfileMode) {
          PerformanceTiming.instance(contextId).mark(PERF_PAINT_IMAGE_FILTER_END, uniqueId: targetId);
        }
        callback(context, offset);
      }, offset);
    } else {
      callback(context, offset);
    }
  }
}
