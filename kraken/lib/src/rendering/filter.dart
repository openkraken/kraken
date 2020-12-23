import 'dart:ui' show ImageFilter;
import 'package:flutter/rendering.dart';

mixin RenderColorFilter on RenderBox {
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
      context.pushColorFilter(offset, _colorFilter, callback);
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

  void paintImageFilter(PaintingContext context, Offset offset, PaintingContextCallback callback) {
    if (_imageFilter != null) {
      _imageFilterLayer ??= ImageFilterLayer();
      _imageFilterLayer.imageFilter = imageFilter;

      context.pushLayer(_imageFilterLayer, callback, offset);
    } else {
      callback(context, offset);
    }
  }
}
