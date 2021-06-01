/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'package:flutter/rendering.dart';
import 'package:flutter/foundation.dart';
import 'package:kraken/css.dart';
import 'package:kraken/rendering.dart';

enum BackgroundBoundary {
  borderBox,
  paddingBox,
  contentBox,
}

mixin RenderBoxDecorationMixin on RenderBoxModelBase {
  BoxDecorationPainter? _painter;

  BoxDecorationPainter? get boxPainter => _painter;

  set boxPainter(BoxDecorationPainter? painter) {
    _painter = painter;
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

  void paintBackground(
      PaintingContext context, Offset offset, EdgeInsets? padding) {
    BoxDecoration? decoration = renderStyle.decoration;
    DecorationPosition decorationPosition = renderStyle.decorationPosition;
    ImageConfiguration imageConfiguration = renderStyle.imageConfiguration;

    if (decoration == null) return;
    if (_painter == null) {
      _painter ??= BoxDecorationPainter(
          decoration, padding, renderStyle, markNeedsPaint);
    }

    final ImageConfiguration filledConfiguration =
        imageConfiguration.copyWith(size: size);
    if (decorationPosition == DecorationPosition.background) {
      int? debugSaveCount;
      assert(() {
        debugSaveCount = context.canvas.getSaveCount();
        return true;
      }());
      _painter!.paintBackground(context.canvas, offset, filledConfiguration);
      assert(() {
        if (debugSaveCount != context.canvas.getSaveCount()) {
          throw FlutterError.fromParts(<DiagnosticsNode>[
            ErrorSummary(
                '${decoration.runtimeType} painter had mismatching save and restore calls.'),
            ErrorDescription(
                'Before painting the decoration, the canvas save count was $debugSaveCount. '
                'After painting it, the canvas save count was ${context.canvas.getSaveCount()}. '
                'Every call to save() or saveLayer() must be matched by a call to restore().'),
            DiagnosticsProperty<Decoration>('The decoration was', decoration,
                style: DiagnosticsTreeStyle.errorProperty),
            DiagnosticsProperty<BoxPainter>('The painter was', _painter,
                style: DiagnosticsTreeStyle.errorProperty),
          ]);
        }
        return true;
      }());
      if (decoration.isComplex) context.setIsComplexHint();
    }

    if (decorationPosition == DecorationPosition.foreground) {
      _painter!.paint(context.canvas, offset, filledConfiguration);
      if (decoration.isComplex) context.setIsComplexHint();
    }
  }

  void paintDecoration(
      PaintingContext context, Offset offset, EdgeInsets? padding) {
    BoxDecoration? decoration = renderStyle.decoration;
    DecorationPosition decorationPosition = renderStyle.decorationPosition;
    ImageConfiguration imageConfiguration = renderStyle.imageConfiguration;
    if (decoration == null) return;
    _painter ??=
        BoxDecorationPainter(decoration, padding, renderStyle, markNeedsPaint);

    final ImageConfiguration filledConfiguration =
        imageConfiguration.copyWith(size: size);
    if (decorationPosition == DecorationPosition.background) {
      int? debugSaveCount;
      assert(() {
        debugSaveCount = context.canvas.getSaveCount();
        return true;
      }());

      _painter!.paint(context.canvas, offset, filledConfiguration);
      assert(() {
        if (debugSaveCount != context.canvas.getSaveCount()) {
          throw FlutterError.fromParts(<DiagnosticsNode>[
            ErrorSummary(
                '${decoration.runtimeType} painter had mismatching save and restore calls.'),
            ErrorDescription(
                'Before painting the decoration, the canvas save count was $debugSaveCount. '
                'After painting it, the canvas save count was ${context.canvas.getSaveCount()}. '
                'Every call to save() or saveLayer() must be matched by a call to restore().'),
            DiagnosticsProperty<Decoration>('The decoration was', decoration,
                style: DiagnosticsTreeStyle.errorProperty),
            DiagnosticsProperty<BoxPainter>('The painter was', _painter,
                style: DiagnosticsTreeStyle.errorProperty),
          ]);
        }
        return true;
      }());
      if (decoration.isComplex) context.setIsComplexHint();
    }
    Offset contentOffset;
    EdgeInsets? borderEdge = renderStyle.borderEdge;
    if (borderEdge == null) {
      contentOffset = Offset(0, 0);
    } else {
      contentOffset = offset.translate(borderEdge.left, borderEdge.top);
    }
    super.paint(context, contentOffset);
    if (decorationPosition == DecorationPosition.foreground) {
      _painter!.paint(context.canvas, offset, filledConfiguration);
      if (decoration.isComplex) context.setIsComplexHint();
    }
  }

  void debugBoxDecorationProperties(DiagnosticPropertiesBuilder properties) {
    if (renderStyle.borderEdge != null)
      properties
          .add(DiagnosticsProperty('borderEdge', renderStyle.borderEdge));
    if (renderStyle.backgroundClip != null)
      properties.add(
          DiagnosticsProperty('backgroundClip', renderStyle.backgroundClip));
    if (renderStyle.backgroundOrigin != null)
      properties.add(DiagnosticsProperty(
          'backgroundOrigin', renderStyle.backgroundOrigin));
    BoxDecoration? _decoration = renderStyle.decoration;
    if (_decoration != null && _decoration.borderRadius != null)
      properties
          .add(DiagnosticsProperty('borderRadius', _decoration.borderRadius));
    if (_decoration != null && _decoration.image != null)
      properties.add(DiagnosticsProperty('backgroundImage', _decoration.image));
    if (_decoration != null && _decoration.boxShadow != null)
      properties.add(DiagnosticsProperty('boxShadow', _decoration.boxShadow));
    if (_decoration != null && _decoration.gradient != null)
      properties.add(DiagnosticsProperty('gradient', _decoration.gradient));
  }
}

/// An object that paints a [BoxDecoration] into a canvas.
class BoxDecorationPainter extends BoxPainter {
  BoxDecorationPainter(
      this._decoration, this.padding, this.renderStyle, VoidCallback onChanged)
      : super(onChanged);

  EdgeInsets? padding;
  RenderStyle renderStyle;
  final BoxDecoration _decoration;

  Paint? _cachedBackgroundPaint;
  Rect? _rectForCachedBackgroundPaint;

  Paint? _getBackgroundPaint(Rect rect, TextDirection? textDirection) {
    assert(
        _decoration.gradient != null || _rectForCachedBackgroundPaint == null);

    if (_cachedBackgroundPaint == null ||
        (_decoration.gradient != null &&
            _rectForCachedBackgroundPaint != rect)) {
      final Paint paint = Paint();
      if (_decoration.backgroundBlendMode != null)
        paint.blendMode = _decoration.backgroundBlendMode!;
      if (_decoration.color != null) paint.color = _decoration.color!;
      if (_decoration.gradient != null) {
        paint.shader = _decoration.gradient!
            .createShader(rect, textDirection: textDirection);
        _rectForCachedBackgroundPaint = rect;
      }
      _cachedBackgroundPaint = paint;
    }

    return _cachedBackgroundPaint;
  }

  void _paintBox(
      Canvas canvas, Rect rect, Paint? paint, TextDirection? textDirection) {
    switch (_decoration.shape) {
      case BoxShape.circle:
        assert(_decoration.borderRadius == null);
        final Offset center = rect.center;
        final double radius = rect.shortestSide / 2.0;
        canvas.drawCircle(center, radius, paint!);
        break;
      case BoxShape.rectangle:
        if (_decoration.borderRadius == null) {
          canvas.drawRect(rect, paint!);
        } else {
          canvas.drawRRect(
              _decoration.borderRadius!.resolve(textDirection).toRRect(rect),
              paint!);
        }
        break;
    }
  }

  void _paintShadows(Canvas canvas, Rect rect, TextDirection? textDirection) {
    if (_decoration.boxShadow == null) return;
    for (final BoxShadow boxShadow in _decoration.boxShadow!) {
      _paintBoxShadow(canvas, rect, textDirection, boxShadow);
    }
  }

  void _paintBoxShadow(Canvas canvas, Rect rect, TextDirection? textDirection,
      BoxShadow boxShadow) {
    final Paint paint = Paint()
      ..color = boxShadow.color
      // Following W3C spec, blur sigma is exactly half the blur radius
      // which is different from the value of Flutter:
      // https://www.w3.org/TR/css-backgrounds-3/#shadow-blur
      // https://html.spec.whatwg.org/C/#when-shadows-are-drawn
      ..maskFilter =
          MaskFilter.blur(BlurStyle.normal, boxShadow.blurRadius / 2);

    // Rect of box shadow not including blur radius
    final Rect shadowRect =
        rect.shift(boxShadow.offset).inflate(boxShadow.spreadRadius);
    // Rect of box shadow including blur radius, add 1 pixel to avoid the fill bleed in (due to antialiasing)
    final Rect shadowBlurRect = rect
        .shift(boxShadow.offset)
        .inflate(boxShadow.spreadRadius + boxShadow.blurRadius + 1);
    // Path of border rect
    Path borderPath;
    // Path of box shadow rect
    Path shadowPath;
    // Path of box shadow including blur rect
    Path shadowBlurPath;

    if (_decoration.borderRadius == null) {
      borderPath = Path()..addRect(rect);
      shadowPath = Path()..addRect(shadowRect);
      shadowBlurPath = Path()..addRect(shadowBlurRect);
    } else {
      borderPath = Path()
        ..addRRect(
            _decoration.borderRadius!.resolve(textDirection).toRRect(rect));
      shadowPath = Path()
        ..addRRect(_decoration.borderRadius!
            .resolve(textDirection)
            .toRRect(shadowRect));
      shadowBlurPath = Path()
        ..addRRect(_decoration.borderRadius!
            .resolve(textDirection)
            .toRRect(shadowBlurRect));
    }

    // Path of shadow blur rect subtract border rect of which the box shadow should paint
    final Path clipedPath =
        Path.combine(PathOperation.difference, shadowBlurPath, borderPath);
    canvas.save();
    canvas.clipPath(clipedPath);
    canvas.drawPath(shadowPath, paint);
    canvas.restore();
  }

  void _paintBackgroundColor(
      Canvas canvas, Rect rect, TextDirection? textDirection) {
    if (_decoration.color != null || _decoration.gradient != null)
      _paintBox(canvas, rect, _getBackgroundPaint(rect, textDirection),
          textDirection);
  }

  DecorationImagePainter? _imagePainter;

  void _paintBackgroundImage(
      Canvas canvas, Rect rect, ImageConfiguration configuration) {
    if (_decoration.image == null) return;
    _imagePainter ??= _decoration.image!.createPainter(onChanged!);
    Path? clipPath;
    switch (_decoration.shape) {
      case BoxShape.circle:
        clipPath = Path()..addOval(rect);
        break;
      case BoxShape.rectangle:
        if (_decoration.borderRadius != null)
          clipPath = Path()
            ..addRRect(_decoration.borderRadius!
                .resolve(configuration.textDirection)
                .toRRect(rect));
        break;
    }
    _imagePainter!.paint(canvas, rect, clipPath, configuration);
  }

  @override
  void dispose() {
    _imagePainter?.dispose();
    super.dispose();
  }

  bool hasLocalBackgroundImage(RenderStyle renderStyle) {
    return renderStyle.backgroundImage != null &&
        renderStyle.backgroundAttachment == LOCAL;
  }

  void paintBackground(
      Canvas canvas, Offset offset, ImageConfiguration configuration) {
    assert(configuration.size != null);
    Offset baseOffset = Offset(0, 0);

    final TextDirection? textDirection = configuration.textDirection;
    bool hasLocalAttachment = hasLocalBackgroundImage(renderStyle);

    // Rect of background color
    Rect backgroundColorRect =
        _getBackgroundClipRect(baseOffset, configuration);
    _paintBackgroundColor(canvas, backgroundColorRect, textDirection);

    // Background image of background-attachment local scroll with content
    Offset backgrundImageOffset = hasLocalAttachment ? offset : baseOffset;
    // Rect of background image
    Rect backgroundClipRect =
        _getBackgroundClipRect(backgrundImageOffset, configuration);
    Rect backgroundOriginRect =
        _getBackgroundOriginRect(backgrundImageOffset, configuration);
    Rect backgroundImageRect =
        backgroundClipRect.intersect(backgroundOriginRect);
    _paintBackgroundImage(canvas, backgroundImageRect, configuration);
  }

  Rect _getBackgroundOriginRect(
      Offset offset, ImageConfiguration configuration) {
    Size? size = configuration.size;

    EdgeInsets? borderEdge = renderStyle.borderEdge;
    double borderTop = 0;
    double borderLeft = 0;
    if (borderEdge != null) {
      borderTop = borderEdge.top;
      borderLeft = borderEdge.left;
    }

    double paddingTop = 0;
    double paddingLeft = 0;
    if (padding != null) {
      paddingTop = padding!.top;
      paddingLeft = padding!.left;
    }
    // Background origin moves background image from specified origin
    Rect backgroundOriginRect;
    BackgroundBoundary? backgroundOrigin = renderStyle.backgroundOrigin;
    switch (backgroundOrigin) {
      case BackgroundBoundary.borderBox:
        backgroundOriginRect = offset & size!;
        break;
      case BackgroundBoundary.contentBox:
        backgroundOriginRect =
            offset.translate(borderLeft + paddingLeft, borderTop + paddingTop) &
                size!;
        break;
      default:
        backgroundOriginRect = offset.translate(borderLeft, borderTop) & size!;
        break;
    }
    return backgroundOriginRect;
  }

  Rect _getBackgroundClipRect(Offset offset, ImageConfiguration configuration) {
    Size? size = configuration.size;
    double borderTop = 0;
    double borderBottom = 0;
    double borderLeft = 0;
    double borderRight = 0;
    EdgeInsets? borderEdge = renderStyle.borderEdge;
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
      paddingTop = padding!.top;
      paddingBottom = padding!.bottom;
      paddingLeft = padding!.left;
      paddingRight = padding!.right;
    }
    Rect backgroundClipRect;
    BackgroundBoundary? backgroundClip = renderStyle.backgroundClip;
    switch (backgroundClip) {
      case BackgroundBoundary.paddingBox:
        backgroundClipRect = offset.translate(borderLeft, borderTop) &
            Size(
              size!.width - borderRight - borderLeft,
              size.height - borderBottom - borderTop,
            );
        break;
      case BackgroundBoundary.contentBox:
        backgroundClipRect =
            offset.translate(borderLeft + paddingLeft, borderTop + paddingTop) &
                Size(
                  size!.width -
                      borderRight -
                      borderLeft -
                      paddingRight -
                      paddingLeft,
                  size.height -
                      borderBottom -
                      borderTop -
                      paddingBottom -
                      paddingTop,
                );
        break;
      default:
        backgroundClipRect = offset & size!;
        break;
    }
    return backgroundClipRect;
  }

  /// Paint the box decoration into the given location on the given canvas
  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    assert(configuration.size != null);

    final Rect rect = offset & configuration.size!;
    final TextDirection? textDirection = configuration.textDirection;

    bool hasLocalAttachment = hasLocalBackgroundImage(renderStyle);
    if (!hasLocalAttachment) {
      Rect backgroundClipRect = _getBackgroundClipRect(offset, configuration);
      _paintBackgroundColor(canvas, backgroundClipRect, textDirection);

      Rect backgroundOriginRect =
          _getBackgroundOriginRect(offset, configuration);
      Rect backgroundImageRect =
          backgroundClipRect.intersect(backgroundOriginRect);
      _paintBackgroundImage(canvas, backgroundImageRect, configuration);
    }

    _decoration.border?.paint(
      canvas,
      rect,
      shape: _decoration.shape,
      borderRadius: _decoration.borderRadius as BorderRadius?,
      textDirection: configuration.textDirection,
    );

    _paintShadows(canvas, rect, textDirection);
  }

  @override
  String toString() {
    return 'BoxPainter for $_decoration';
  }
}
