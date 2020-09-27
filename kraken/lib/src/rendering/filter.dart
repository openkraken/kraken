import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

mixin RenderColorFilter on RenderBox {
  ColorFilter _colorFilter;
  get colorFilter => _colorFilter;
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
