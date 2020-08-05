/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'package:flutter/rendering.dart';
import 'package:kraken/css.dart';
import 'package:kraken/painting.dart';
import 'package:kraken/foundation.dart';

mixin RenderBoxDecorationMixin on RenderBox {

  TransitionDecoration oldDecoration;
  DecorationPosition position = DecorationPosition.background;
  ImageConfiguration configuration = ImageConfiguration.empty;
  BoxPainter _painter;

  /// BorderSize to deflate.
  EdgeInsets _borderEdge;
  EdgeInsets get borderEdge => _borderEdge;
  set borderEdge(EdgeInsets newValue) {
    _borderEdge = newValue;
    if (_decoration != null && _decoration is BoxDecoration) {
      Gradient gradient = (_decoration as BoxDecoration).gradient;
      if (gradient is BorderGradientMixin) {
        gradient.borderEdge = newValue;
      }
    }
    markNeedsLayout();
  }

  /// What decoration to paint.
  ///
  /// Commonly a [BoxDecoration].
  Decoration get decoration => _decoration;
  Decoration _decoration;
  set decoration(Decoration value) {
    assert(value != null);
    if (value == _decoration) return;
    _painter?.dispose();
    _painter = null;
    _decoration = value;
    markNeedsPaint();
  }
  
  BoxConstraints deflateBorderConstraints(BoxConstraints constraints) {
    return constraints.deflate(borderEdge);
  }
}
