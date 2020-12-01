/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'package:flutter/rendering.dart';
import 'package:flutter/foundation.dart';
import 'package:kraken/css.dart';
import 'package:kraken/painting.dart';

enum BackgroundBoundary {
  borderBox,
  paddingBox,
  contentBox,
}

mixin RenderBoxDecorationMixin on RenderBox {
  CSSBoxDecoration cssBoxDecoration;
  DecorationPosition position = DecorationPosition.background;
  ImageConfiguration configuration = ImageConfiguration.empty;

  _BoxDecorationPainter _painter;
  _BoxDecorationPainter get boxPainter => _painter;
  set boxPainter(_BoxDecorationPainter painter) {
    _painter = painter;
  }

  /// Background-clip
  BackgroundBoundary get backgroundClip => _backgroundClip;
  BackgroundBoundary _backgroundClip;
  set backgroundClip(BackgroundBoundary value) {
    if (value == null) return;
    if (value == _backgroundClip) return;
    _backgroundClip = value;
    markNeedsPaint();
  }

  /// Background-origin
  BackgroundBoundary get backgroundOrigin => _backgroundOrigin;
  BackgroundBoundary _backgroundOrigin;
  set backgroundOrigin(BackgroundBoundary value) {
    if (value == null) return;
    if (value == _backgroundOrigin) return;
    _backgroundOrigin = value;
    markNeedsPaint();
  }

  /// BorderSize to deflate.
  EdgeInsets _borderEdge;
  EdgeInsets get borderEdge => _borderEdge;
  set borderEdge(EdgeInsets newValue) {
    _borderEdge = newValue;
    if (_decoration != null && _decoration is BoxDecoration) {
      Gradient gradient = _decoration.gradient;
      if (gradient is BorderGradientMixin) {
        gradient.borderEdge = newValue;
      }
    }
    markNeedsLayout();
  }

  /// What decoration to paint.
  ///
  /// Commonly a [BoxDecoration].
  BoxDecoration get decoration => _decoration;
  BoxDecoration _decoration;
  set decoration(BoxDecoration value) {
    if (value == null) return;
    if (value == _decoration) return;
    _painter?.dispose();
    _painter = null;
    _decoration = value;

    // If has border, render padding should subtracting the edge of the border
    if (value.border != null) {
      Border border = value.border;
      borderEdge = EdgeInsets.fromLTRB(
        border.left.width,
        border.top.width,
        border.right.width,
        border.bottom.width
      );
    }

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

  void paintBackground(PaintingContext context, Offset offset, EdgeInsets padding, CSSStyleDeclaration style) {
    if (decoration == null) return;
    if (_painter == null) {
      _painter ??= _BoxDecorationPainter(
        decoration,
        borderEdge,
        backgroundClip,
        backgroundOrigin,
        padding,
        style,
        markNeedsPaint
      );
    }

    final ImageConfiguration filledConfiguration = configuration.copyWith(size: size);
    if (position == DecorationPosition.background) {
      int debugSaveCount;
      assert(() {
        debugSaveCount = context.canvas.getSaveCount();
        return true;
      }());
      _painter.paintBackground(context.canvas, offset, filledConfiguration);
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

    if (position == DecorationPosition.foreground) {
      _painter.paint(context.canvas, offset, filledConfiguration);
      if (decoration.isComplex) context.setIsComplexHint();
    }
  }

  void paintDecoration(PaintingContext context, Offset offset, EdgeInsets padding, CSSStyleDeclaration style) {
    if (decoration == null) return;
    _painter ??= _BoxDecorationPainter(
      decoration,
      borderEdge,
      backgroundClip,
      backgroundOrigin,
      padding,
      style,
      markNeedsPaint
    );

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

  void debugBoxDecorationProperties(DiagnosticPropertiesBuilder properties) {
    if (borderEdge != null) properties.add(DiagnosticsProperty('borderEdge', borderEdge));
    if (backgroundClip != null) properties.add(DiagnosticsProperty('backgroundClip', backgroundClip));
    if (backgroundOrigin != null) properties.add(DiagnosticsProperty('backgroundOrigin', backgroundOrigin));
    if (_decoration != null && _decoration.borderRadius != null) properties.add(DiagnosticsProperty('borderRadius', _decoration.borderRadius));
    if (_decoration != null && _decoration.image != null) properties.add(DiagnosticsProperty('backgroundImage', _decoration.image));
    if (_decoration != null && _decoration.boxShadow != null) properties.add(DiagnosticsProperty('boxShadow', _decoration.boxShadow));
    if (_decoration != null && _decoration.gradient != null) properties.add(DiagnosticsProperty('gradient', _decoration.gradient));
  }
}

/// An object that paints a [BoxDecoration] into a canvas.
class _BoxDecorationPainter extends BoxPainter {
  _BoxDecorationPainter(
    this._decoration,
    this.borderEdge,
    this.backgroundClip,
    this.backgroundOrigin,
    this.padding,
    this.style,
    VoidCallback onChanged
  ) : assert(_decoration != null),
      super(onChanged);

  BackgroundBoundary backgroundClip;
  BackgroundBoundary backgroundOrigin;
  EdgeInsets borderEdge;
  EdgeInsets padding;
  CSSStyleDeclaration style;
  final BoxDecoration _decoration;

  Paint _cachedBackgroundPaint;
  Rect _rectForCachedBackgroundPaint;
  Paint _getBackgroundPaint(Rect rect, TextDirection textDirection) {
    assert(rect != null);
    assert(_decoration.gradient != null || _rectForCachedBackgroundPaint == null);

    if (_cachedBackgroundPaint == null ||
      (_decoration.gradient != null && _rectForCachedBackgroundPaint != rect)) {
      final Paint paint = Paint();
      if (_decoration.backgroundBlendMode != null)
        paint.blendMode = _decoration.backgroundBlendMode;
      if (_decoration.color != null)
        paint.color = _decoration.color;
      if (_decoration.gradient != null) {
        paint.shader = _decoration.gradient.createShader(rect, textDirection: textDirection);
        _rectForCachedBackgroundPaint = rect;
      }
      _cachedBackgroundPaint = paint;
    }

    return _cachedBackgroundPaint;
  }

  void _paintBox(Canvas canvas, Rect rect, Paint paint, TextDirection textDirection) {
    switch (_decoration.shape) {
      case BoxShape.circle:
        assert(_decoration.borderRadius == null);
        final Offset center = rect.center;
        final double radius = rect.shortestSide / 2.0;
        canvas.drawCircle(center, radius, paint);
        break;
      case BoxShape.rectangle:
        if (_decoration.borderRadius == null) {
          canvas.drawRect(rect, paint);
        } else {
          canvas.drawRRect(_decoration.borderRadius.resolve(textDirection).toRRect(rect), paint);
        }
        break;
    }
  }

  void _paintShadows(Canvas canvas, Rect rect, TextDirection textDirection) {
    if (_decoration.boxShadow == null)
      return;
    for (final BoxShadow boxShadow in _decoration.boxShadow) {
      final Paint paint = boxShadow.toPaint();
      final Rect bounds = rect.shift(boxShadow.offset).inflate(boxShadow.spreadRadius);
      _paintBox(canvas, bounds, paint, textDirection);
    }
  }

  void _paintBackgroundColor(Canvas canvas, Rect rect, TextDirection textDirection) {
    if (_decoration.color != null || _decoration.gradient != null)
      _paintBox(canvas, rect, _getBackgroundPaint(rect, textDirection), textDirection);
  }

  DecorationImagePainter _imagePainter;
  void _paintBackgroundImage(Canvas canvas, Rect rect, ImageConfiguration configuration) {
    if (_decoration.image == null)
      return;
    _imagePainter ??= _decoration.image.createPainter(onChanged);
    Path clipPath;
    switch (_decoration.shape) {
      case BoxShape.circle:
        clipPath = Path()..addOval(rect);
        break;
      case BoxShape.rectangle:
        if (_decoration.borderRadius != null)
          clipPath = Path()..addRRect(_decoration.borderRadius.resolve(configuration.textDirection).toRRect(rect));
        break;
    }
    _imagePainter.paint(canvas, rect, clipPath, configuration);
  }

  @override
  void dispose() {
    _imagePainter?.dispose();
    super.dispose();
  }

  void paintBackground(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    assert(configuration.size != null);
    Offset baseOffset = Offset(0, 0);

    final TextDirection textDirection = configuration.textDirection;
    bool hasLocalAttachment = CSSBackground.hasLocalBackgroundImage(style);

    // Rect of background color
    Rect backgroundColorRect = _getBackgroundClipRect(baseOffset, configuration);
    _paintBackgroundColor(canvas, backgroundColorRect, textDirection);

    // Background image of background-attachment local scroll with content
    Offset backgrundImageOffset = hasLocalAttachment ? offset : baseOffset;
    // Rect of background image
    Rect backgroundClipRect = _getBackgroundClipRect(backgrundImageOffset, configuration);
    Rect backgroundOriginRect = _getBackgroundOriginRect(backgrundImageOffset, configuration);
    Rect backgroundImageRect = backgroundClipRect.intersect(backgroundOriginRect);
    _paintBackgroundImage(canvas, backgroundImageRect, configuration);
  }

  Rect _getBackgroundOriginRect(Offset offset, ImageConfiguration configuration) {
    Size size = configuration.size;
    double borderTop = 0;
    double borderLeft = 0;
    if (borderEdge != null) {
      borderTop = borderEdge.top;
      borderLeft = borderEdge.left;
    }

    double paddingTop = 0;
    double paddingLeft = 0;
    if (padding != null) {
      paddingTop = padding.top;
      paddingLeft = padding.left;
    }
    // Background origin moves background image from specified origin
    Rect backgroundOriginRect;
    switch(backgroundOrigin) {
      case BackgroundBoundary.borderBox:
        backgroundOriginRect = offset & size;
        break;
      case BackgroundBoundary.contentBox:
        backgroundOriginRect = offset.translate(borderLeft + paddingLeft, borderTop + paddingTop) & size;
        break;
      default:
        backgroundOriginRect = offset.translate(borderLeft, borderTop) & size;
        break;
    }
    return backgroundOriginRect;
  }

  Rect _getBackgroundClipRect(Offset offset, ImageConfiguration configuration) {
    Size size = configuration.size;
    double borderTop = 0;
    double borderBottom = 0;
    double borderLeft = 0;
    double borderRight = 0;
    if (borderEdge != null) {
      borderTop = borderEdge.top;
      borderBottom = borderEdge.bottom;
      borderLeft = borderEdge.left;
      borderRight = borderEdge.right;
    }

    double paddingTop = 0;
    double paddingBottom = 0;
    double paddingLeft = 0;
    double paddingRight = 0;
    if (padding != null) {
      paddingTop = padding.top;
      paddingBottom = padding.bottom;
      paddingLeft = padding.left;
      paddingRight = padding.right;
    }
    Rect backgroundClipRect;
    switch(backgroundClip) {
      case BackgroundBoundary.paddingBox:
        backgroundClipRect = offset.translate(borderLeft, borderTop) & Size(
          size.width - borderRight - borderLeft,
          size.height - borderBottom - borderTop,
        );
        break;
      case BackgroundBoundary.contentBox:
        backgroundClipRect = offset.translate(borderLeft + paddingLeft, borderTop + paddingTop) & Size(
          size.width - borderRight - borderLeft - paddingRight -  paddingLeft,
          size.height - borderBottom - borderTop - paddingBottom - paddingTop,
        );
        break;
      default:
        backgroundClipRect = offset & size;
        break;
    }
    return backgroundClipRect;
  }

  /// Paint the box decoration into the given location on the given canvas
  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    assert(configuration != null);
    assert(configuration.size != null);

    final Rect rect = offset & configuration.size;
    final TextDirection textDirection = configuration.textDirection;

    _paintShadows(canvas, rect, textDirection);


    bool hasLocalAttachment = CSSBackground.hasLocalBackgroundImage(style);
    if (!hasLocalAttachment) {
      Rect backgroundClipRect = _getBackgroundClipRect(offset, configuration);
      _paintBackgroundColor(canvas, backgroundClipRect, textDirection);

      Rect backgroundOriginRect = _getBackgroundOriginRect(offset, configuration);
      Rect backgroundImageRect = backgroundClipRect.intersect(backgroundOriginRect);
      _paintBackgroundImage(canvas, backgroundImageRect, configuration);
    }

    _decoration.border?.paint(
      canvas,
      rect,
      shape: _decoration.shape,
      borderRadius: _decoration.borderRadius as BorderRadius,
      textDirection: configuration.textDirection,
    );
  }

  @override
  String toString() {
    return 'BoxPainter for $_decoration';
  }
}
