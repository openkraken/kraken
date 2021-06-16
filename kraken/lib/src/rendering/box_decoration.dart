/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:developer' as developer;
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui show Image;
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
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
    _paint(canvas, rect, clipPath, configuration);
  }

  /// Draw the image onto the given canvas.
  /// Forked from flutter with parameter customization of _paintImage method:
  /// https://github.com/flutter/flutter/blob/master/packages/flutter/lib/src/painting/decoration_image.dart#L231
  void _paint(Canvas canvas, Rect rect, Path? clipPath, ImageConfiguration configuration) {
    DecorationImage decorationImage = _decoration.image!;
    bool flipHorizontally = false;
    if (decorationImage.matchTextDirection) {
      assert(() {
        // We check this first so that the assert will fire immediately, not just
        // when the image is ready.
        if (configuration.textDirection == null) {
          throw FlutterError.fromParts(<DiagnosticsNode>[
            ErrorSummary('DecorationImage.matchTextDirection can only be used when a TextDirection is available.'),
            ErrorDescription(
              'When DecorationImagePainter.paint() was called, there was no text direction provided '
                'in the ImageConfiguration object to match.',
            ),
            DiagnosticsProperty<DecorationImage>('The DecorationImage was', decorationImage, style: DiagnosticsTreeStyle.errorProperty),
            DiagnosticsProperty<ImageConfiguration>('The ImageConfiguration was', configuration, style: DiagnosticsTreeStyle.errorProperty),
          ]);
        }
        return true;
      }());
      if (configuration.textDirection == TextDirection.rtl)
        flipHorizontally = true;
    }

    final ImageStream newImageStream = decorationImage.image.resolve(configuration);
    if (newImageStream.key != _imageStream?.key) {
      final ImageStreamListener listener = ImageStreamListener(
        _handleImage,
        onError: decorationImage.onError,
      );
      _imageStream?.removeListener(listener);
      _imageStream = newImageStream;
      _imageStream!.addListener(listener);
    }
    if (_image == null)
      return;

    if (clipPath != null) {
      canvas.save();
      canvas.clipPath(clipPath);
    }
    _paintImage(
      canvas: canvas,
      rect: rect,
      image: _image!.image,
      debugImageLabel: _image!.debugLabel,
      scale: decorationImage.scale * _image!.scale,
      colorFilter: decorationImage.colorFilter,
      fit: decorationImage.fit,
      positionX: renderStyle.backgroundPositionX,
      positionY: renderStyle.backgroundPositionY,
      centerSlice: decorationImage.centerSlice,
      repeat: decorationImage.repeat,
      flipHorizontally: flipHorizontally,
      filterQuality: FilterQuality.low,
    );

    if (clipPath != null)
      canvas.restore();
  }


  ImageStream? _imageStream;
  ImageInfo? _image;

  void _handleImage(ImageInfo value, bool synchronousCall) {
    if (_image == value)
      return;
    _image = value;
    assert(onChanged != null);
    if (!synchronousCall)
      onChanged!();
  }

  /// Used by [paintImage] to report image sizes drawn at the end of the frame.
  Map<String, ImageSizeInfo> _pendingImageSizeInfo = <String, ImageSizeInfo>{};

  /// [ImageSizeInfo]s that were reported on the last frame.
  ///
  /// Used to prevent duplicative reports from frame to frame.
  Set<ImageSizeInfo> _lastFrameImageSizeInfo = <ImageSizeInfo>{};

  /// Flushes inter-frame tracking of image size information from [paintImage].
  ///
  /// Has no effect if asserts are disabled.
  @visibleForTesting
  void debugFlushLastFrameImageSizeInfo() {
    assert(() {
      _lastFrameImageSizeInfo = <ImageSizeInfo>{};
      return true;
    }());
  }

  /// Paints an image into the given rectangle on the canvas.
  /// Forked from flutter with parameter customization of _paintImage method:
  /// https://github.com/flutter/flutter/blob/master/packages/flutter/lib/src/painting/decoration_image.dart#L419
  /// Add positionX and positionY parameter to add the ability to specify absolute position of background image.
  void _paintImage({
    required Canvas canvas,
    required Rect rect,
    required ui.Image image,
    String? debugImageLabel,
    double scale = 1.0,
    ColorFilter? colorFilter,
    BoxFit? fit,
    required CSSBackgroundPosition positionX,
    required CSSBackgroundPosition positionY,
    Rect? centerSlice,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    bool flipHorizontally = false,
    bool invertColors = false,
    FilterQuality filterQuality = FilterQuality.low,
    bool isAntiAlias = false,
  }) {
    assert(
    image.debugGetOpenHandleStackTraces()?.isNotEmpty ?? true,
    'Cannot paint an image that is disposed.\n'
      'The caller of paintImage is expected to wait to dispose the image until '
      'after painting has completed.',
    );
    if (rect.isEmpty)
      return;
    Size outputSize = rect.size;
    Size inputSize = Size(image.width.toDouble(), image.height.toDouble());
    Offset? sliceBorder;
    if (centerSlice != null) {
      sliceBorder = inputSize / scale - centerSlice.size as Offset;
      outputSize = outputSize - sliceBorder as Size;
      inputSize = inputSize - sliceBorder * scale as Size;
    }
    fit ??= centerSlice == null ? BoxFit.scaleDown : BoxFit.fill;
    assert(centerSlice == null || (fit != BoxFit.none && fit != BoxFit.cover));
    final FittedSizes fittedSizes = applyBoxFit(fit, inputSize / scale, outputSize);
    final Size sourceSize = fittedSizes.source * scale;
    Size destinationSize = fittedSizes.destination;
    if (centerSlice != null) {
      outputSize += sliceBorder!;
      destinationSize += sliceBorder;
      // We don't have the ability to draw a subset of the image at the same time
      // as we apply a nine-patch stretch.
      assert(sourceSize == inputSize, 'centerSlice was used with a BoxFit that does not guarantee that the image is fully visible.');
    }

    if (repeat != ImageRepeat.noRepeat && destinationSize == outputSize) {
      // There's no need to repeat the image because we're exactly filling the
      // output rect with the image.
      repeat = ImageRepeat.noRepeat;
    }
    final Paint paint = Paint()..isAntiAlias = isAntiAlias;
    if (colorFilter != null)
      paint.colorFilter = colorFilter;
    paint.filterQuality = filterQuality;
    paint.invertColors = invertColors;
    final double halfWidthDelta = (outputSize.width - destinationSize.width) / 2.0;
    final double halfHeightDelta = (outputSize.height - destinationSize.height) / 2.0;

    // Use position as length type if specified in positionX/ positionY, otherwise use as percentage type.
    final double dx = positionX.length != null ? positionX.length! :
        halfWidthDelta + (flipHorizontally ? -positionX.percentage! : positionX.percentage!) * halfWidthDelta;
    final double dy = positionY.length != null ? positionY.length! :
        halfHeightDelta + positionY.percentage! * halfHeightDelta;

    final Offset destinationPosition = rect.topLeft.translate(dx, dy);
    final Rect destinationRect = destinationPosition & destinationSize;

    // Set to true if we added a saveLayer to the canvas to invert/flip the image.
    bool invertedCanvas = false;
    // Output size and destination rect are fully calculated.
    if (!kReleaseMode) {
      final ImageSizeInfo sizeInfo = ImageSizeInfo(
        // Some ImageProvider implementations may not have given this.
        source: debugImageLabel ?? '<Unknown Image(${image.width}×${image.height})>',
        imageSize: Size(image.width.toDouble(), image.height.toDouble()),
        displaySize: outputSize,
      );
      assert(() {
        if (debugInvertOversizedImages &&
          sizeInfo.decodedSizeInBytes > sizeInfo.displaySizeInBytes + debugImageOverheadAllowance) {
          final int overheadInKilobytes = (sizeInfo.decodedSizeInBytes - sizeInfo.displaySizeInBytes) ~/ 1024;
          final int outputWidth = outputSize.width.toInt();
          final int outputHeight = outputSize.height.toInt();
          FlutterError.reportError(FlutterErrorDetails(
            exception: 'Image $debugImageLabel has a display size of '
              '$outputWidth×$outputHeight but a decode size of '
              '${image.width}×${image.height}, which uses an additional '
              '${overheadInKilobytes}KB.\n\n'
              'Consider resizing the asset ahead of time, supplying a cacheWidth '
              'parameter of $outputWidth, a cacheHeight parameter of '
              '$outputHeight, or using a ResizeImage.',
            library: 'painting library',
            context: ErrorDescription('while painting an image'),
          ));
          // Invert the colors of the canvas.
          canvas.saveLayer(
            destinationRect,
            Paint()..colorFilter = const ColorFilter.matrix(<double>[
              -1,  0,  0, 0, 255,
              0, -1,  0, 0, 255,
              0,  0, -1, 0, 255,
              0,  0,  0, 1,   0,
            ]),
          );
          // Flip the canvas vertically.
          final double dy = -(rect.top + rect.height / 2.0);
          canvas.translate(0.0, -dy);
          canvas.scale(1.0, -1.0);
          canvas.translate(0.0, dy);
          invertedCanvas = true;
        }
        return true;
      }());
      // Avoid emitting events that are the same as those emitted in the last frame.
      if (!_lastFrameImageSizeInfo.contains(sizeInfo)) {
        final ImageSizeInfo? existingSizeInfo = _pendingImageSizeInfo[sizeInfo.source];
        if (existingSizeInfo == null || existingSizeInfo.displaySizeInBytes < sizeInfo.displaySizeInBytes) {
          _pendingImageSizeInfo[sizeInfo.source!] = sizeInfo;
        }
        debugOnPaintImage?.call(sizeInfo);
        SchedulerBinding.instance!.addPostFrameCallback((Duration timeStamp) {
          _lastFrameImageSizeInfo = _pendingImageSizeInfo.values.toSet();
          if (_pendingImageSizeInfo.isEmpty) {
            return;
          }
          developer.postEvent(
            'Flutter.ImageSizesForFrame',
            <String, Object>{
              for (ImageSizeInfo imageSizeInfo in _pendingImageSizeInfo.values)
                imageSizeInfo.source!: imageSizeInfo.toJson(),
            },
          );
          _pendingImageSizeInfo = <String, ImageSizeInfo>{};
        });
      }
    }

    final bool needSave = centerSlice != null || repeat != ImageRepeat.noRepeat || flipHorizontally;
    if (needSave)
      canvas.save();
    if (repeat != ImageRepeat.noRepeat)
      canvas.clipRect(rect);
    if (flipHorizontally) {
      final double dx = -(rect.left + rect.width / 2.0);
      canvas.translate(-dx, 0.0);
      canvas.scale(-1.0, 1.0);
      canvas.translate(dx, 0.0);
    }

    final Rect outputRect = Offset.zero & outputSize;
    // Restrict background image to container rect.
    canvas.clipRect(outputRect);

    if (centerSlice == null) {
      final Rect sourceRect = Offset.zero & sourceSize;
      if (repeat == ImageRepeat.noRepeat) {
        canvas.drawImageRect(image, sourceRect, destinationRect, paint);
      } else {
        for (final Rect tileRect in _generateImageTileRects(rect, destinationRect, repeat))
          canvas.drawImageRect(image, sourceRect, tileRect, paint);
      }
    } else {
      canvas.scale(1 / scale);
      if (repeat == ImageRepeat.noRepeat) {
        canvas.drawImageNine(image, _scaleRect(centerSlice, scale), _scaleRect(destinationRect, scale), paint);
      } else {
        for (final Rect tileRect in _generateImageTileRects(rect, destinationRect, repeat))
          canvas.drawImageNine(image, _scaleRect(centerSlice, scale), _scaleRect(tileRect, scale), paint);
      }
    }
    if (needSave)
      canvas.restore();

    if (invertedCanvas) {
      canvas.restore();
    }
  }

  /// Forked from flutter with no modification:
  /// https://github.com/flutter/flutter/blob/master/packages/flutter/lib/src/painting/decoration_image.dart#L621
  Rect _scaleRect(Rect rect, double scale) => Rect.fromLTRB(rect.left * scale, rect.top * scale, rect.right * scale, rect.bottom * scale);

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

/// Forked from flutter with no modification:
/// https://github.com/flutter/flutter/blob/master/packages/flutter/lib/src/painting/decoration_image.dart#L597
Iterable<Rect> _generateImageTileRects(Rect outputRect, Rect fundamentalRect, ImageRepeat repeat) sync* {
  int startX = 0;
  int startY = 0;
  int stopX = 0;
  int stopY = 0;
  final double strideX = fundamentalRect.width;
  final double strideY = fundamentalRect.height;

  if (repeat == ImageRepeat.repeat || repeat == ImageRepeat.repeatX) {
    startX = ((outputRect.left - fundamentalRect.left) / strideX).floor();
    stopX = ((outputRect.right - fundamentalRect.right) / strideX).ceil();
  }

  if (repeat == ImageRepeat.repeat || repeat == ImageRepeat.repeatY) {
    startY = ((outputRect.top - fundamentalRect.top) / strideY).floor();
    stopY = ((outputRect.bottom - fundamentalRect.bottom) / strideY).ceil();
  }

  for (int i = startX; i <= stopX; ++i) {
    for (int j = startY; j <= stopY; ++j)
      yield fundamentalRect.shift(Offset(i * strideX, j * strideY));
  }
}
