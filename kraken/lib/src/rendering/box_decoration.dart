/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'package:flutter/rendering.dart';
import 'package:flutter/foundation.dart';
import 'package:kraken/css.dart';
import 'package:kraken/painting.dart';

mixin RenderBoxDecorationMixin on RenderBox {
  CSSBoxDecoration cssBoxDecoration;
  DecorationPosition position = DecorationPosition.background;
  ImageConfiguration configuration = ImageConfiguration.empty;

  BoxPainter _painter;
  BoxPainter get boxPainter => _painter;
  set boxPainter(BoxPainter painter) {
    _painter = painter;
  }

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
    if (value == null) return;
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

  double get borderTop {
    if (borderEdge == null) return 0.0;
    return borderEdge.top;
  }

  double get borderBottom {
    if (borderEdge == null) return 0.0;
    return borderEdge.bottom;
  }

  double get borderLeft {
    if (borderEdge == null) return 0.0;
    return borderEdge.left;
  }

  double get borderRight {
    if (borderEdge == null) return 0.0;
    return borderEdge.right;
  }

  Size wrapBorderSize(Size innerSize) {
    return Size(borderLeft + innerSize.width + borderRight,
      borderTop + innerSize.height + borderBottom);
  }

  void disposePainter() {
    _painter?.dispose();
    _painter = null;
    // Since we're disposing of our painter, we won't receive change
    // notifications. We mark ourselves as needing paint so that we will
    // resubscribe to change notifications. If we didn't do this, then, for
    // example, animated GIFs would stop animating when a DecoratedBox gets
    // moved around the tree due to GlobalKey reparenting.
    markNeedsPaint();
  }

  void paintDecoration(PaintingContext context, Offset offset) {
    if (decoration == null) return;

    _painter ??= decoration.createBoxPainter(markNeedsPaint);
    final ImageConfiguration filledConfiguration = configuration.copyWith(size: size);
    if (position == DecorationPosition.background) {
      int debugSaveCount;
      assert(() {
        debugSaveCount = context.canvas.getSaveCount();
        return true;
      }());
      _painter.paint(context.canvas, offset, filledConfiguration);
      assert(() {
        if (debugSaveCount != context.canvas.getSaveCount()) {
          throw FlutterError.fromParts(<DiagnosticsNode>[
            ErrorSummary('${decoration.runtimeType} painter had mismatching save and restore calls.'),
            ErrorDescription('Before painting the decoration, the canvas save count was $debugSaveCount. '
              'After painting it, the canvas save count was ${context.canvas.getSaveCount()}. '
              'Every call to save() or saveLayer() must be matched by a call to restore().'),
            DiagnosticsProperty<Decoration>('The decoration was', decoration,
              style: DiagnosticsTreeStyle.errorProperty),
            DiagnosticsProperty<BoxPainter>('The painter was', _painter, style: DiagnosticsTreeStyle.errorProperty),
          ]);
        }
        return true;
      }());
      if (decoration.isComplex) context.setIsComplexHint();
    }
    Offset contentOffset;
    if (borderEdge == null) {
      contentOffset = Offset(0, 0);
    } else {
      contentOffset = offset.translate(borderEdge.left, borderEdge.top);
    }
    super.paint(context, contentOffset);
    if (position == DecorationPosition.foreground) {
      _painter.paint(context.canvas, offset, filledConfiguration);
      if (decoration.isComplex) context.setIsComplexHint();
    }
  }
}
