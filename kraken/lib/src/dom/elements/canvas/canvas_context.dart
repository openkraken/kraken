/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'dart:typed_data';
import 'dart:ui';
import 'package:meta/meta.dart';

enum ImageSmoothingQuality { low, medium, high }

enum CanvasLineCap { butt, round, square }

enum CanvasLineJoin { round, bevel, miter }

enum CanvasTextAlign { start, end, left, right, center }

enum CanvasTextBaseline { top, hanging, middle, alphabetic, ideographic, bottom }

enum CanvasDirection { ltr, rtl, inherit }

class ImageData {
  ImageData(
    double sw,
    double sh, {
    Uint8List data,
  });

  double width;
  double height;
  Uint8List data;
}

@immutable
class TextMetrics {
  TextMetrics(
    this.width,
    this.actualBoundingBoxLeft,
    this.actualBoundingBoxRight,
    this.fontBoundingBoxAscent,
    this.fontBoundingBoxDescent,
    this.actualBoundingBoxAscent,
    this.actualBoundingBoxDescent,
    this.emHeightAscent,
    this.emHeightDescent,
    this.hangingBaseline,
    this.alphabeticBaseline,
    this.ideographicBaseline,
  );

  // x-direction
  final double width;
  final double actualBoundingBoxLeft;
  final double actualBoundingBoxRight;

  // y-direction
  final double fontBoundingBoxAscent;
  final double fontBoundingBoxDescent;
  final double actualBoundingBoxAscent;
  final double actualBoundingBoxDescent;
  final double emHeightAscent;
  final double emHeightDescent;
  final double hangingBaseline;
  final double alphabeticBaseline;
  final double ideographicBaseline;
}

abstract class CanvasCompositing {
  double globalAlpha; // (default 1.0)
  String globalCompositeOperation; // (default source-over)
}

abstract class CanvasImageSmoothing {
  // image smoothing
  bool imageSmoothingEnabled; // (default true)
  ImageSmoothingQuality imageSmoothingQuality; // (default low)
}

abstract class CanvasImageSource {
  String imageSource;
}

abstract class CanvasFillStrokeStyles {
  // colors and styles (see also the CanvasPathDrawingStyles and CanvasTextDrawingStyles
  Color strokeStyle; // (default black)
  Color fillStyle; // (default black)
  CanvasGradient createLinearGradient(double x0, double y0, double x1, double y1);

  CanvasGradient createRadialGradient(double x0, double y0, double r0, double x1, double y1, double r1);

  CanvasPattern createPattern(CanvasImageSource image, String repetition);
}

abstract class CanvasShadowStyles {
  // shadows
  double shadowOffsetX; // (default 0)
  double shadowOffsetY; // (default 0)
  double shadowBlur; // (default 0)
  Color shadowColor; // (default transparent black)
}

abstract class CanvasFilters {
  // filters
  String filter; // (default "none")
}

// ignore: one_member_abstracts
abstract class CanvasDrawImage {
  // drawing images
  void drawImage(
    CanvasImageSource image,
    double dx,
    double dy, {
    double dw,
    double dh,
    double sx,
    double sy,
    double sw,
    double sh,
  });
}

abstract class CanvasImageData {
  // pixel manipulation
  ImageData createImageData({double sw, double sh, ImageData imagedata});

  ImageData getImageData(double sx, double sy, double sw, double sh);

  void putImageData(ImageData imagedata, double dx, double dy, {double dirtyX, double dirtyY, double dirtyWidth, double dirtyHeight});
}

// ignore: one_member_abstracts
abstract class CanvasGradient {
  // opaque object
  void addColorStop(double offset, String color);
}

// ignore: one_member_abstracts
abstract class CanvasPattern {
  // opaque object
  void setTransform(String transform);
}
