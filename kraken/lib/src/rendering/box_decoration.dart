/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'package:flutter/rendering.dart';
import 'package:kraken/css.dart';
import 'package:kraken/painting.dart';

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
    if (borderEdge != null) {
      return constraints.deflate(borderEdge);
    }
    return constraints;
  }

  /// Returns new box constraints that are bigger by the given edge dimensions.
  BoxConstraints inflateConstraints(BoxConstraints constraints, EdgeInsets edges) {
    final double horizontal = edges.horizontal;
    final double vertical = edges.vertical;
    return BoxConstraints(
      minWidth: constraints.minWidth,
      maxWidth: constraints.maxWidth + horizontal,
      minHeight: constraints.minHeight,
      maxHeight: constraints.maxHeight + vertical,
    );
  }

  double get borderTop {
    if (borderEdge == null) return 0;
    return borderEdge.top;
  }

  double get borderBottom {
    if (borderEdge == null) return 0;
    return borderEdge.bottom;
  }

  double get borderLeft {
    if (borderEdge == null) return 0;
    return borderEdge.left;
  }

  double get borderRight {
    if (borderEdge == null) return 0;
    return borderEdge.right;
  }

  Size wrapBorderSize(Size innerSize) {
    return Size(borderLeft + innerSize.width + borderRight,
      borderTop + innerSize.height + borderBottom);
  }
}
