/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:ui' as ui show Image;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:kraken/css.dart';
import 'package:kraken/rendering.dart';

enum _BorderDirection {
  top,
  bottom,
  left,
  right
}

/// An object that paints a [BoxDecoration] into a canvas.
class BoxDecorationPainter extends BoxPainter {
  BoxDecorationPainter(
    this.padding, this.renderStyle, VoidCallback onChanged)
    : super(onChanged);

  EdgeInsets? padding;
  CSSRenderStyle renderStyle;
  CSSBoxDecoration get _decoration => renderStyle.decoration!;

  Paint? _cachedBackgroundPaint;
  Rect? _rectForCachedBackgroundPaint;

  Paint? _getBackgroundPaint(Rect rect, TextDirection? textDirection) {
    assert(
    _decoration.gradient != null || _rectForCachedBackgroundPaint == null);

    if (_cachedBackgroundPaint == null ||
      _decoration.color !=  null ||
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
    for (final KrakenBoxShadow boxShadow in _decoration.boxShadow!) {
      if (boxShadow.inset) {
        _paintInsetBoxShadow(canvas, rect, textDirection, boxShadow);
      } else {
        _paintBoxShadow(canvas, rect, textDirection, boxShadow);
      }
    }
  }

  /// An outer box-shadow casts a shadow as if the border-box of the element were opaque.
  /// It is clipped inside the border-box of the element.
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
    final Path clippedPath =
    Path.combine(PathOperation.difference, shadowBlurPath, borderPath);
    canvas.save();
    canvas.clipPath(clippedPath);
    canvas.drawPath(shadowPath, paint);
    canvas.restore();
  }

  /// An inner box-shadow casts a shadow as if everything outside the padding edge were opaque.
  /// It is clipped outside the padding box of the element.
  void _paintInsetBoxShadow(Canvas canvas, Rect rect, TextDirection? textDirection,
    BoxShadow boxShadow) {
    final Paint paint = Paint()
      ..color = boxShadow.color
    // Following W3C spec, blur sigma is exactly half the blur radius
    // which is different from the value of Flutter:
    // https://www.w3.org/TR/css-backgrounds-3/#shadow-blur
    // https://html.spec.whatwg.org/C/#when-shadows-are-drawn
      ..maskFilter =
      MaskFilter.blur(BlurStyle.normal, boxShadow.blurRadius / 2);

    // The normal box-shadow is drawn outside the border box edge while
    // the inset box-shadow is drawn inside the padding box edge.
    // https://drafts.csswg.org/css-backgrounds-3/#shadow-shape
    Rect paddingBoxRect = Rect.fromLTRB(
      rect.left + renderStyle.effectiveBorderLeftWidth.computedValue,
      rect.top + renderStyle.effectiveBorderTopWidth.computedValue,
      rect.right - renderStyle.effectiveBorderRightWidth.computedValue,
      rect.bottom - renderStyle.effectiveBorderBottomWidth.computedValue
    );

    Path paddingBoxPath;
    if (_decoration.borderRadius == null) {
      paddingBoxPath = Path()..addRect(paddingBoxRect);
    } else {
      RRect borderBoxRRect = _decoration.borderRadius!.resolve(textDirection).toRRect(rect);
      // A borderRadius can only be given for a uniform Border in Flutter.
      // https://github.com/flutter/flutter/issues/12583
      double uniformBorderWidth = renderStyle.effectiveBorderTopWidth.computedValue;
      RRect paddingBoxRRect = borderBoxRRect.deflate(uniformBorderWidth);
      paddingBoxPath = Path()..addRRect(paddingBoxRRect);
    }

    // 1. Create a shadow rect shifted by boxShadow and spread radius and get the
    // difference path subtracted from the padding box path.
    Rect shadowOffsetRect = paddingBoxRect
      .shift(Offset(boxShadow.offset.dx, boxShadow.offset.dy))
      .deflate(boxShadow.spreadRadius);
    Path shadowOffsetPath = _decoration.borderRadius == null ?
      (Path()..addRect(shadowOffsetRect)) :
      (Path()..addRRect(_decoration.borderRadius!.resolve(textDirection).toRRect(shadowOffsetRect)));
    Path innerShadowPath = Path.combine(PathOperation.difference, paddingBoxPath, shadowOffsetPath);

    // 2. Create shadow rect in four directions and get the difference path
    // subtracted from the padding box path.
    Path topRectPath = _getOuterPaddingBoxPathByDirection(
      paddingBoxPath,
      paddingBoxRect,
      textDirection,
      boxShadow,
      _BorderDirection.top
    );
    Path bottomRectPath = _getOuterPaddingBoxPathByDirection(
      paddingBoxPath,
      paddingBoxRect,
      textDirection,
      boxShadow,
      _BorderDirection.bottom
    );
    Path leftRectPath = _getOuterPaddingBoxPathByDirection(
      paddingBoxPath,
      paddingBoxRect,
      textDirection,
      boxShadow,
      _BorderDirection.left
    );
    Path rightRectPath = _getOuterPaddingBoxPathByDirection(
      paddingBoxPath,
      paddingBoxRect,
      textDirection,
      boxShadow,
      _BorderDirection.right
    );

    // 3. Combine all the paths in step 1 and step 2 as the final shadow path.
    List<Path> paintPaths = [
      innerShadowPath,
      topRectPath,
      bottomRectPath,
      leftRectPath,
      rightRectPath,
    ];
    Path? shadowPath = _combinePaths(paintPaths);

    // 4. Restrict the shadow painted in padding box and paint the shadow path with blur radius.
    canvas.save();
    canvas.clipPath(paddingBoxPath);
    canvas.drawPath(shadowPath!, paint);
    canvas.restore();
  }

  /// Get the shadow path outside padding box in each direction.
  Path _getOuterPaddingBoxPathByDirection(
    Path paddingBoxPath,
    Rect paddingBoxRect,
    TextDirection? textDirection,
    BoxShadow boxShadow,
    _BorderDirection direction,
    ) {
    Rect offsetRect;
    Size paddingBoxSize = paddingBoxRect.size;

    if (direction == _BorderDirection.left) {
      offsetRect = paddingBoxRect
        .shift(Offset(-paddingBoxSize.width + boxShadow.offset.dx + boxShadow.spreadRadius, boxShadow.offset.dy));
    } else if (direction == _BorderDirection.right) {
      offsetRect = paddingBoxRect
        .shift(Offset(paddingBoxSize.width + boxShadow.offset.dx - boxShadow.spreadRadius, boxShadow.offset.dy));
    } else if (direction == _BorderDirection.top) {
      offsetRect = paddingBoxRect
        .shift(Offset(boxShadow.offset.dx, -paddingBoxSize.height + boxShadow.offset.dy + boxShadow.spreadRadius));
    } else {
      offsetRect = paddingBoxRect
        .shift(Offset(boxShadow.offset.dx, paddingBoxSize.height + boxShadow.offset.dy - boxShadow.spreadRadius));
    }
    Path offsetRectPath = _decoration.borderRadius == null ?
      (Path()..addRect(offsetRect)) :
      (Path()..addRRect(_decoration.borderRadius!.resolve(textDirection).toRRect(offsetRect)));

    Path outerBorderPath = Path.combine(PathOperation.difference, offsetRectPath, paddingBoxPath);
    return outerBorderPath;
  }

  /// Combine multiple non overlapped path into one path.
  Path? _combinePaths(List<Path> paths) {
    Path? finalPath;
    for (Path path in paths) {
      if (finalPath != null) {
        finalPath = Path.combine(PathOperation.xor, finalPath, path);
      } else {
        finalPath = path;
      }
    }
    return finalPath;
  }

  void _paintBackgroundColor(
    Canvas canvas, Rect rect, TextDirection? textDirection) {
    if (_decoration.color != null || _decoration.gradient != null)
      _paintBox(canvas, rect, _getBackgroundPaint(rect, textDirection),
        textDirection);
  }

  BoxDecorationImagePainter? _imagePainter;

  void _paintBackgroundImage(
    Canvas canvas, Rect rect, ImageConfiguration configuration) {
    if (_decoration.image == null) return;
    _imagePainter ??= BoxDecorationImagePainter._(
      _decoration.image!,
      renderStyle,
      onChanged!
    );
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

  bool _hasLocalBackgroundImage() {
    return renderStyle.backgroundImage != null &&
      renderStyle.backgroundAttachment == CSSBackgroundAttachmentType.local;
  }

  void paintBackground(
    Canvas canvas, Offset offset, ImageConfiguration configuration) {
    assert(configuration.size != null);
    Offset baseOffset = Offset(0, 0);

    final TextDirection? textDirection = configuration.textDirection;
    bool hasLocalAttachment = _hasLocalBackgroundImage();

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

    EdgeInsets borderEdge = renderStyle.border;
    double borderTop = borderEdge.top;
    double borderLeft = borderEdge.left;

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
    EdgeInsets borderEdge = renderStyle.border;
    double borderTop = borderEdge.top;
    double borderBottom = borderEdge.bottom;
    double borderLeft = borderEdge.left;
    double borderRight = borderEdge.right;

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

    bool hasLocalAttachment = _hasLocalBackgroundImage();
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

/// Forked from flutter of [DecorationImagePainter] Class.
/// https://github.com/flutter/flutter/blob/master/packages/flutter/lib/src/painting/decoration_image.dart#L208
class BoxDecorationImagePainter {
  BoxDecorationImagePainter._(
    this._details,
    this._renderStyle,
    this._onChanged
  );

  final CSSRenderStyle _renderStyle;
  final DecorationImage _details;
  CSSBackgroundPosition get _backgroundPositionX {
    return _renderStyle.backgroundPositionX;
  }
  CSSBackgroundPosition get _backgroundPositionY {
    return _renderStyle.backgroundPositionY;
  }
  CSSBackgroundSize get _backgroundSize {
    return _renderStyle.backgroundSize;
  }
  final VoidCallback _onChanged;

  ImageStream? _imageStream;
  ImageInfo? _image;

  /// Forked from flutter with parameter customization of _paintImage method:
  /// https://github.com/flutter/flutter/blob/master/packages/flutter/lib/src/painting/decoration_image.dart#L231
  void paint(Canvas canvas, Rect rect, Path? clipPath, ImageConfiguration configuration) {
    bool flipHorizontally = false;
    if (_details.matchTextDirection) {
      assert(() {
        // We check this first so that the assert will fire immediately, not just
        // when the image is ready.
        if (configuration.textDirection == null) {
          throw FlutterError.fromParts(<DiagnosticsNode>[
            ErrorSummary('DecorationImage.matchTextDirection can only be used when a TextDirection is available.'),
            ErrorDescription(
              'When BoxDecorationImagePainter.paint() was called, there was no text direction provided '
                'in the ImageConfiguration object to match.',
            ),
            DiagnosticsProperty<DecorationImage>('The DecorationImage was', _details, style: DiagnosticsTreeStyle.errorProperty),
            DiagnosticsProperty<ImageConfiguration>('The ImageConfiguration was', configuration, style: DiagnosticsTreeStyle.errorProperty),
          ]);
        }
        return true;
      }());
      if (configuration.textDirection == TextDirection.rtl)
        flipHorizontally = true;
    }

    final ImageStream newImageStream = _details.image.resolve(configuration);
    if (newImageStream.key != _imageStream?.key) {
      final ImageStreamListener listener = ImageStreamListener(
        _handleImage,
        onError: _details.onError,
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
      scale: _details.scale * _image!.scale,
      colorFilter: _details.colorFilter,
      positionX: _backgroundPositionX,
      positionY: _backgroundPositionY,
      backgroundSize: _backgroundSize,
      centerSlice: _details.centerSlice,
      repeat: _details.repeat,
      flipHorizontally: flipHorizontally,
      filterQuality: FilterQuality.low,
    );

    if (clipPath != null)
      canvas.restore();
  }

  void _handleImage(ImageInfo value, bool synchronousCall) {
    if (_image == value)
      return;
    if (_image != null && _image!.isCloneOf(value)) {
      value.dispose();
      return;
    }
    _image?.dispose();
    _image = value;
    if (!synchronousCall)
      _onChanged();
  }

  /// Releases the resources used by this painter.
  ///
  /// This should be called whenever the painter is no longer needed.
  ///
  /// After this method has been called, the object is no longer usable.
  @mustCallSuper
  void dispose() {
    _imageStream?.removeListener(ImageStreamListener(
      _handleImage,
      onError: _details.onError,
    ));
    _image?.dispose();
    _image = null;
  }

  @override
  String toString() {
    return '${objectRuntimeType(this, 'BoxDecorationImagePainter')}(stream: $_imageStream, image: $_image) for $_details';
  }
}

// Used by [paintImage] to report image sizes drawn at the end of the frame.
Map<String, ImageSizeInfo> _pendingImageSizeInfo = <String, ImageSizeInfo>{};

// [ImageSizeInfo]s that were reported on the last frame.
//
// Used to prevent duplicative reports from frame to frame.
Set<ImageSizeInfo> _lastFrameImageSizeInfo = <ImageSizeInfo>{};

// Paints an image into the given rectangle on the canvas.
// Forked from flutter with parameter customization of _paintImage method:
// https://github.com/flutter/flutter/blob/master/packages/flutter/lib/src/painting/decoration_image.dart#L419
// Add positionX and positionY parameter to add the ability to specify absolute position of background image.
void _paintImage({
  required Canvas canvas,
  required Rect rect,
  required ui.Image image,
  String? debugImageLabel,
  double scale = 1.0,
  ColorFilter? colorFilter,
  required CSSBackgroundPosition positionX,
  required CSSBackgroundPosition positionY,
  required CSSBackgroundSize backgroundSize,
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
  double imageWidth = image.width.toDouble();
  double imageHeight = image.height.toDouble();
  Size inputSize = Size(imageWidth, imageHeight);
  double aspectRatio = imageWidth / imageHeight;
  Offset? sliceBorder;
  if (centerSlice != null) {
    sliceBorder = inputSize / scale - centerSlice.size as Offset;
    outputSize = outputSize - sliceBorder as Size;
    inputSize = inputSize - sliceBorder * scale as Size;
  }
  BoxFit? fit = backgroundSize.fit;

  Size sourceSize = inputSize;
  Size destinationSize = outputSize;

  CSSLengthValue? backgroundWidth = backgroundSize.width;
  CSSLengthValue? backgroundHeight = backgroundSize.height;

  // Only background width is set, eg `100px`, `100px auto`.
  if (backgroundWidth != null && !backgroundWidth.isAuto && backgroundWidth.computedValue > 0 &&
    (backgroundHeight == null || backgroundHeight.isAuto)
  ) {
    double width = backgroundWidth.computedValue;
    double height = width / aspectRatio;
    destinationSize = Size(width, height);

  // Only background height is set, eg `auto 100px`.
  } else if (backgroundWidth != null && backgroundWidth.isAuto &&
    backgroundHeight != null && !backgroundHeight.isAuto && backgroundHeight.computedValue > 0
  ) {
    double height = backgroundHeight.computedValue;
    double width = height * aspectRatio;
    destinationSize = Size(width, height);

  // Both background width and height are set, eg `100px 100px`.
  } else if (backgroundWidth != null && !backgroundWidth.isAuto && backgroundWidth.computedValue > 0 &&
    backgroundHeight != null && !backgroundHeight.isAuto && backgroundHeight.computedValue > 0
  ) {
    double width = backgroundWidth.computedValue;
    double height = backgroundHeight.computedValue;
    destinationSize = Size(width, height);

  // Keyword values are set(contain|cover|auto), eg `contain`, `auto auto`.
  } else {
    final FittedSizes fittedSizes = applyBoxFit(fit, inputSize / scale, outputSize);
    sourceSize = fittedSizes.source * scale;
    destinationSize = fittedSizes.destination;
  }

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
  final double dx = positionX.length != null ? positionX.length!.computedValue :
  halfWidthDelta + (flipHorizontally ? -positionX.percentage! : positionX.percentage!) * halfWidthDelta;
  final double dy = positionY.length != null ? positionY.length!.computedValue :
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
        _pendingImageSizeInfo = <String, ImageSizeInfo>{};
      });
    }
  }

  canvas.save();

  // Background image should never exceeds the boundary of its container.
  canvas.clipRect(rect);

  if (flipHorizontally) {
    final double dx = -(rect.left + rect.width / 2.0);
    canvas.translate(-dx, 0.0);
    canvas.scale(-1.0, 1.0);
    canvas.translate(dx, 0.0);
  }

  if (centerSlice == null) {
    final double halfWidthDelta = (inputSize.width - sourceSize.width) / 2.0;
    final double halfHeightDelta = (inputSize.height - sourceSize.height) / 2.0;
    // Always to draw image on 0 when position length type is specified.
    final Rect sourceRect = Rect.fromLTWH(
      positionX.length != null ? 0 : halfWidthDelta + positionX.percentage! * halfWidthDelta,
      positionY.length != null ? 0 : halfHeightDelta + positionY.percentage! * halfHeightDelta,
      sourceSize.width,
      sourceSize.height,
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

  canvas.restore();

  if (invertedCanvas) {
    canvas.restore();
  }
}

// Forked from flutter with no modification:
// https://github.com/flutter/flutter/blob/master/packages/flutter/lib/src/painting/decoration_image.dart#L597
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

// Forked from flutter with no modification:
// https://github.com/flutter/flutter/blob/master/packages/flutter/lib/src/painting/decoration_image.dart#L621
Rect _scaleRect(Rect rect, double scale) => Rect.fromLTRB(rect.left * scale, rect.top * scale, rect.right * scale, rect.bottom * scale);

