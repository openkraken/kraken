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

  ImageStream? _imageStream;
  ImageInfo? _image;

  void _handleImage(ImageInfo value, bool synchronousCall) {
    if (_image == value)
      return;
    _image = value;
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
//    _imagePainter.paint(canvas, rect, clipPath, configuration);
    _paint(canvas, rect, clipPath, configuration);
  }

  /// Draw the image onto the given canvas.
  ///
  /// The image is drawn at the position and size given by the `rect` argument.
  ///
  /// The image is clipped to the given `clipPath`, if any.
  ///
  /// The `configuration` object is used to resolve the image (e.g. to pick
  /// resolution-specific assets), and to implement the
  /// [DecorationImage.matchTextDirection] feature.
  ///
  /// If the image needs to be painted again, e.g. because it is animated or
  /// because it had not yet been loaded the first time this method was called,
  /// then the `onChanged` callback passed to [DecorationImage.createPainter]
  /// will be called.
  void _paint(Canvas canvas, Rect rect, Path? clipPath, ImageConfiguration configuration) {
    assert(canvas != null);
    assert(rect != null);
    assert(configuration != null);

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
      alignment: decorationImage.alignment.resolve(configuration.textDirection),
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
  ///
  /// The arguments have the following meanings:
  ///
  ///  * `canvas`: The canvas onto which the image will be painted.
  ///
  ///  * `rect`: The region of the canvas into which the image will be painted.
  ///    The image might not fill the entire rectangle (e.g., depending on the
  ///    `fit`). If `rect` is empty, nothing is painted.
  ///
  ///  * `image`: The image to paint onto the canvas.
  ///
  ///  * `scale`: The number of image pixels for each logical pixel.
  ///
  ///  * `colorFilter`: If non-null, the color filter to apply when painting the
  ///    image.
  ///
  ///  * `fit`: How the image should be inscribed into `rect`. If null, the
  ///    default behavior depends on `centerSlice`. If `centerSlice` is also null,
  ///    the default behavior is [BoxFit.scaleDown]. If `centerSlice` is
  ///    non-null, the default behavior is [BoxFit.fill]. See [BoxFit] for
  ///    details.
  ///
  ///  * `alignment`: How the destination rectangle defined by applying `fit` is
  ///    aligned within `rect`. For example, if `fit` is [BoxFit.contain] and
  ///    `alignment` is [Alignment.bottomRight], the image will be as large
  ///    as possible within `rect` and placed with its bottom right corner at the
  ///    bottom right corner of `rect`. Defaults to [Alignment.center].
  ///
  ///  * `centerSlice`: The image is drawn in nine portions described by splitting
  ///    the image by drawing two horizontal lines and two vertical lines, where
  ///    `centerSlice` describes the rectangle formed by the four points where
  ///    these four lines intersect each other. (This forms a 3-by-3 grid
  ///    of regions, the center region being described by `centerSlice`.)
  ///    The four regions in the corners are drawn, without scaling, in the four
  ///    corners of the destination rectangle defined by applying `fit`. The
  ///    remaining five regions are drawn by stretching them to fit such that they
  ///    exactly cover the destination rectangle while maintaining their relative
  ///    positions.
  ///
  ///  * `repeat`: If the image does not fill `rect`, whether and how the image
  ///    should be repeated to fill `rect`. By default, the image is not repeated.
  ///    See [ImageRepeat] for details.
  ///
  ///  * `flipHorizontally`: Whether to flip the image horizontally. This is
  ///    occasionally used with images in right-to-left environments, for images
  ///    that were designed for left-to-right locales (or vice versa). Be careful,
  ///    when using this, to not flip images with integral shadows, text, or other
  ///    effects that will look incorrect when flipped.
  ///
  ///  * `invertColors`: Inverting the colors of an image applies a new color
  ///    filter to the paint. If there is another specified color filter, the
  ///    invert will be applied after it. This is primarily used for implementing
  ///    smart invert on iOS.
  ///
  ///  * `filterQuality`: Use this to change the quality when scaling an image.
  ///     Use the [FilterQuality.low] quality setting to scale the image, which corresponds to
  ///     bilinear interpolation, rather than the default [FilterQuality.none] which corresponds
  ///     to nearest-neighbor.
  ///
  /// The `canvas`, `rect`, `image`, `scale`, `alignment`, `repeat`, `flipHorizontally` and `filterQuality`
  /// arguments must not be null.
  ///
  /// See also:
  ///
  ///  * [paintBorder], which paints a border around a rectangle on a canvas.
  ///  * [DecorationImage], which holds a configuration for calling this function.
  ///  * [BoxDecoration], which uses this function to paint a [DecorationImage].
  void _paintImage({
    required Canvas canvas,
    required Rect rect,
    required ui.Image image,
    String? debugImageLabel,
    double scale = 1.0,
    ColorFilter? colorFilter,
    BoxFit? fit,
    Alignment alignment = Alignment.center,
    Rect? centerSlice,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    bool flipHorizontally = false,
    bool invertColors = false,
    FilterQuality filterQuality = FilterQuality.low,
    bool isAntiAlias = false,
  }) {
    assert(canvas != null);
    assert(image != null);
    assert(alignment != null);
    assert(repeat != null);
    assert(flipHorizontally != null);
    assert(isAntiAlias != null);
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
    final double dx = halfWidthDelta + (flipHorizontally ? -alignment.x : alignment.x) * halfWidthDelta;
    final double dy = halfHeightDelta + alignment.y * halfHeightDelta;
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
    if (centerSlice == null) {
      final Rect sourceRect = alignment.inscribe(
        sourceSize, Offset.zero & inputSize,
      );
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
