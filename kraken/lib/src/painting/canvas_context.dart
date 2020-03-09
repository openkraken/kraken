/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';
import 'package:meta/meta.dart';

typedef CanvasAction = void Function(Canvas, Size);

List<CanvasRenderingContext> canvasRenderingContexts = [];

enum CanvasFillRule {
  nonzero,
  evenodd,
}

enum ImageSmoothingQuality { low, medium, high }

enum CanvasLineCap { butt, round, square }

enum CanvasLineJoin { round, bevel, miter }

enum CanvasTextAlign { start, end, left, right, center }

enum CanvasTextBaseline {
  top,
  hanging,
  middle,
  alphabetic,
  ideographic,
  bottom
}

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

abstract class CanvasRenderingContext {
  String type = 'CanvasRenderingContext';
  List<String> methods = [];
  List<String> properties = [];
  int id;

  CanvasRenderingContext() {
    canvasRenderingContexts.add(this);
    id = canvasRenderingContexts.indexOf(this);
  }

  @override
  String toString() {
    Map<String, dynamic> descriptor = {
      'type': type,
      'id': id,
      'methods': methods,
      'properties': properties,
    };
    return jsonEncode(descriptor);
  }
}

abstract class CanvasState {
  // state
  void save(); // push state on state stack
  void restore(); // pop state stack and restore state
}

abstract class CanvasTransform {
  // transformations (default transform is the identity matrix)
  void scale(double x, double y);
  void rotate(double angle);
  void translate(double x, double y);
  void transform(double a, double b, double c, double d, double e, double f);

  // DOMMatrix getTransform();
  void setTransform(double a, double b, double c, double d, double e, double f);
  // void setTransform(DOMMatrix2DInit transform = {});
  void resetTransform();
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
  CanvasGradient createLinearGradient(
      double x0, double y0, double x1, double y1);
  CanvasGradient createRadialGradient(
      double x0, double y0, double r0, double x1, double y1, double r1);
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

abstract class CanvasRect {
  // rects
  void clearRect(double x, double y, double w, double h);
  void fillRect(double x, double y, double w, double h);
  void strokeRect(double x, double y, double w, double h);
}

abstract class CanvasDrawPath {
  // path API (see also CanvasPath)
  void beginPath();
  void fill(CanvasFillRule fillRule, {Path2D path});
  void stroke({Path2D path});
  void clip(CanvasFillRule fillRule, {Path2D path});
  bool isPointInPath(double x, double y, CanvasFillRule fillRule,
      {Path2D path});
  bool isPointInStroke(double x, double y, {Path2D path});
}

abstract class Path2D {
  Path2D(dynamic path);

  void addPath(Path2D path, {String transform});
}

abstract class CanvasUserInterface {
  void drawFocusIfNeeded({Path2D path});
  void scrollPathIntoView({Path2D path});
}

abstract class CanvasText {
  // text (see also the CanvasPathDrawingStyles and CanvasTextDrawingStyles

  void fillText(String text, double x, double y, {double maxWidth});

  void strokeText(String text, double x, double y, {double maxWidth});

  TextMetrics measureText(String text);
}

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

  void putImageData(ImageData imagedata, double dx, double dy,
      {double dirtyX, double dirtyY, double dirtyWidth, double dirtyHeight});
}

abstract class CanvasPathDrawingStyles {
  // line caps/joins
  double lineWidth; // (default 1)
  CanvasLineCap lineCap; // (default "butt")
  CanvasLineJoin lineJoin; // (default "miter")
  double miterLimit; // (default 10)

  // dashed lines
  void setLineDash(String segments); // default empty
  String getLineDash();

  double lineDashOffset;
}

abstract class CanvasTextDrawingStyles {
  // text
  String font; // (default 10px sans-serif)
  CanvasTextAlign textAlign; // (default: "start")
  CanvasTextBaseline textBaseline; // (default: "alphabetic")
  CanvasDirection direction; // (default: "inherit")
}

abstract class CanvasPath {
  // shared path API methods
  void closePath();

  void moveTo(double x, double y);

  void lineTo(double x, double y);

  void quadraticCurveTo(double cpx, double cpy, double x, double y);

  void bezierCurveTo(
      double cp1x, double cp1y, double cp2x, double cp2y, double x, double y);

  void arcTo(double x1, double y1, double x2, double y2, double radius);

  void rect(double x, double y, double w, double h);

  void arc(
      double x, double y, double radius, double startAngle, double endAngle,
      {bool anticlockwise = false});

  void ellipse(double x, double y, double radiusX, double radiusY,
      double rotation, double startAngle, double endAngle,
      {bool anticlockwise = false});
}

abstract class CanvasGradient {
  // opaque object
  void addColorStop(double offset, String color);
}

abstract class CanvasPattern {
  // opaque object
  void setTransform(String transform);
}
