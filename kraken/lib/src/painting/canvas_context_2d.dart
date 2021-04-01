/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'dart:core';
import 'dart:typed_data';
import 'dart:ui';
import 'dart:ffi';
import 'dart:collection';
import 'package:ffi/ffi.dart';
import 'package:flutter/painting.dart';
import 'package:kraken/bridge.dart';
import 'package:kraken/css.dart';
import 'package:vector_math/vector_math_64.dart';
import 'canvas_context.dart';
import 'canvas_path_2d.dart';

final RegExp _splitRegExp = RegExp(r'\s+');

class CanvasRenderingContext2DSettings {
  bool alpha = true;
  bool desynchronized = false;
}

final Pointer<NativeFunction<Native_RenderingContextSetFont>> nativeSetFont = Pointer.fromFunction(CanvasRenderingContext2D._setFont);
final Pointer<NativeFunction<Native_RenderingContextSetFillStyle>> nativeSetFillStyle = Pointer.fromFunction(CanvasRenderingContext2D._setFillStyle);
final Pointer<NativeFunction<Native_RenderingContextSetStrokeStyle>> nativeSetStrokeStyle = Pointer.fromFunction(CanvasRenderingContext2D._setStrokeStyle);

final Pointer<NativeFunction<Native_RenderingContextArc>> nativeArc= Pointer.fromFunction(CanvasRenderingContext2D._arc);
final Pointer<NativeFunction<Native_RenderingContextArcTo>> nativeArcTo = Pointer.fromFunction(CanvasRenderingContext2D._arcTo);

final Pointer<NativeFunction<Native_RenderingContextTranslate>> nativeTranslate = Pointer.fromFunction(CanvasRenderingContext2D._translate);
final Pointer<NativeFunction<Native_RenderingContextFillRect>> nativeFillRect = Pointer.fromFunction(CanvasRenderingContext2D._fillRect);
final Pointer<NativeFunction<Native_RenderingContextClearRect>> nativeClearRect = Pointer.fromFunction(CanvasRenderingContext2D._clearRect);
final Pointer<NativeFunction<Native_RenderingContextStrokeRect>> nativeStrokeRect = Pointer.fromFunction(CanvasRenderingContext2D._strokeRect);
final Pointer<NativeFunction<Native_RenderingContextFillText>> nativeFillText = Pointer.fromFunction(CanvasRenderingContext2D._fillText);
final Pointer<NativeFunction<Native_RenderingContextStrokeText>> nativeStrokeText = Pointer.fromFunction(CanvasRenderingContext2D._strokeText);
final Pointer<NativeFunction<Native_RenderingContextSave>> nativeSave = Pointer.fromFunction(CanvasRenderingContext2D._save);
final Pointer<NativeFunction<Native_RenderingContextRestore>> nativeRestore = Pointer.fromFunction(CanvasRenderingContext2D._restore);

class _CanvasRenderingContext2D extends CanvasRenderingContext {
  int get actionCount => _actions.length;

  List<CanvasAction> _actions = [];

  List<CanvasAction> takeActionRecords() => _actions;

  void clearActionRecords() {
    _actions.clear();
  }

  void action(CanvasAction action) {
    _actions.add(action);
  }
}

class CanvasRenderingContext2D extends _CanvasRenderingContext2D
    with CanvasFillStrokeStyles2D, CanvasPathDrawingStyles2D, CanvasPath2D, CanvasState2D, CanvasTransform2D, CanvasRect2D, CanvasTextDrawingStyles2D, CanvasText2D {
  @override
  String type = 'CanvasRenderingContext2D';

  static SplayTreeMap<int, CanvasRenderingContext2D> _nativeMap = SplayTreeMap();

  static CanvasRenderingContext2D getCanvasRenderContext2dOfNativePtr(Pointer<NativeCanvasRenderingContext2D> nativePtr) {
    CanvasRenderingContext2D renderingContext = _nativeMap[nativePtr.address];
    assert(renderingContext != null, 'Can not get nativeRenderingContext2D from pointer: $nativePtr');
    return renderingContext;
  }

  static void _setFont(Pointer<NativeCanvasRenderingContext2D> nativePtr, Pointer<NativeString> font) {
    CanvasRenderingContext2D canvasRenderingContext2D = getCanvasRenderContext2dOfNativePtr(nativePtr);

    List<String> splitVal = nativeStringToString(font).split(_splitRegExp);
    if (splitVal.length == 2) {
      canvasRenderingContext2D.fontSize = CSSLength.toDisplayPortValue(splitVal[0], viewportSize) ?? 14.0;
      canvasRenderingContext2D.fontFamily = splitVal[1];
    }
  }

  static void _setFillStyle(Pointer<NativeCanvasRenderingContext2D> nativePtr, Pointer<NativeString> fillStyle) {
    CanvasRenderingContext2D canvasRenderingContext2D = getCanvasRenderContext2dOfNativePtr(nativePtr);
    canvasRenderingContext2D.fillStyle = CSSColor.parseColor(nativeStringToString(fillStyle));
  }

  static void _setStrokeStyle(Pointer<NativeCanvasRenderingContext2D> nativePtr, Pointer<NativeString> strokeStyle) {
    CanvasRenderingContext2D canvasRenderingContext2D = getCanvasRenderContext2dOfNativePtr(nativePtr);
    canvasRenderingContext2D.strokeStyle = CSSColor.parseColor(nativeStringToString(strokeStyle));
  }

  static void _arc(Pointer<NativeCanvasRenderingContext2D> nativePtr, double x, double y, double radius, double startAngle, double endAngle, double counterclockwise) {
    CanvasRenderingContext2D canvasRenderingContext2D = getCanvasRenderContext2dOfNativePtr(nativePtr);
    canvasRenderingContext2D.arc(x, y, radius, startAngle, endAngle, anticlockwise : counterclockwise == 1 ? true : false);
  }

  static void _arcTo(Pointer<NativeCanvasRenderingContext2D> nativePtr, double x1, double y1, double x2, double y2, double radius) {
    CanvasRenderingContext2D canvasRenderingContext2D = getCanvasRenderContext2dOfNativePtr(nativePtr);
    canvasRenderingContext2D.arcTo(x1, y1, x2, y2, radius);
  }

  static void _translate(Pointer<NativeCanvasRenderingContext2D> nativePtr, double x, double y) {
    CanvasRenderingContext2D canvasRenderingContext2D = getCanvasRenderContext2dOfNativePtr(nativePtr);
    canvasRenderingContext2D.translate(x, y);
  }

  static void _fillRect(Pointer<NativeCanvasRenderingContext2D> nativePtr, double x, double y, double width, double height) {
    CanvasRenderingContext2D canvasRenderingContext2D = getCanvasRenderContext2dOfNativePtr(nativePtr);
    canvasRenderingContext2D.fillRect(x, y, width, height);
  }

  static void _clearRect(Pointer<NativeCanvasRenderingContext2D> nativePtr, double x, double y, double width, double height) {
    CanvasRenderingContext2D canvasRenderingContext2D = getCanvasRenderContext2dOfNativePtr(nativePtr);
    canvasRenderingContext2D.clearRect(x, y, width, height);
  }

  static void _strokeRect(Pointer<NativeCanvasRenderingContext2D> nativePtr, double x, double y, double width, double height) {
    CanvasRenderingContext2D canvasRenderingContext2D = getCanvasRenderContext2dOfNativePtr(nativePtr);
    canvasRenderingContext2D.strokeRect(x, y, width, height);
  }

  static void _fillText(Pointer<NativeCanvasRenderingContext2D> nativePtr, Pointer<NativeString> text, double x, double y, double maxWidth) {
    CanvasRenderingContext2D canvasRenderingContext2D = getCanvasRenderContext2dOfNativePtr(nativePtr);
    if (maxWidth != double.nan) {
      canvasRenderingContext2D.fillText(nativeStringToString(text), x, y, maxWidth: maxWidth);
    } else {
      canvasRenderingContext2D.fillText(nativeStringToString(text), x, y);
    }
  }

  static void _strokeText(Pointer<NativeCanvasRenderingContext2D> nativePtr, Pointer<NativeString> text, double x, double y, double maxWidth) {
    CanvasRenderingContext2D canvasRenderingContext2D = getCanvasRenderContext2dOfNativePtr(nativePtr);
    if (maxWidth != double.nan) {
      canvasRenderingContext2D.strokeText(nativeStringToString(text), x, y, maxWidth: maxWidth);
    } else {
      canvasRenderingContext2D.strokeText(nativeStringToString(text), x, y);
    }
  }

  static void _save(Pointer<NativeCanvasRenderingContext2D> nativePtr) {
    CanvasRenderingContext2D canvasRenderingContext2D = getCanvasRenderContext2dOfNativePtr(nativePtr);
    canvasRenderingContext2D.save();
  }

  static void _restore(Pointer<NativeCanvasRenderingContext2D> nativePtr) {
    CanvasRenderingContext2D canvasRenderingContext2D = getCanvasRenderContext2dOfNativePtr(nativePtr);
    canvasRenderingContext2D.restore();
  }

  final Pointer<NativeCanvasRenderingContext2D> nativeCanvasRenderingContext2D;

  CanvasRenderingContext2D() : nativeCanvasRenderingContext2D = allocate<NativeCanvasRenderingContext2D>() {
    _settings = CanvasRenderingContext2DSettings();

    _nativeMap[nativeCanvasRenderingContext2D.address] = this;

    nativeCanvasRenderingContext2D.ref.setFont = nativeSetFont;
    nativeCanvasRenderingContext2D.ref.setFillStyle = nativeSetFillStyle;
    nativeCanvasRenderingContext2D.ref.setStrokeStyle = nativeSetStrokeStyle;
    nativeCanvasRenderingContext2D.ref.translate = nativeTranslate;
    nativeCanvasRenderingContext2D.ref.fillRect = nativeFillRect;
    nativeCanvasRenderingContext2D.ref.clearRect = nativeClearRect;
    nativeCanvasRenderingContext2D.ref.strokeRect = nativeStrokeRect;
    nativeCanvasRenderingContext2D.ref.fillText = nativeFillText;
    nativeCanvasRenderingContext2D.ref.strokeText = nativeStrokeText;
    nativeCanvasRenderingContext2D.ref.save = nativeSave;
    nativeCanvasRenderingContext2D.ref.restore = nativeRestore;
  }

  static Size viewportSize;

  /// Perform canvas drawing.
  void performAction(Canvas _canvas, Size _size) {
    List<CanvasAction> actions = takeActionRecords();
    for (int i = 0; i < actions.length; i++) {
      actions[i](_canvas, _size);
    }
  }

  CanvasRenderingContext2DSettings _settings;

  CanvasRenderingContext2DSettings getContextAttributes() => _settings;

  void dispose() {
    _nativeMap.remove(nativeCanvasRenderingContext2D.address);
  }
}

mixin CanvasState2D on _CanvasRenderingContext2D implements CanvasState {
  @override
  void restore() {
    action((Canvas canvas, Size size) {
      canvas.restore();
    });
  }

  @override
  void save() {
    action((Canvas canvas, Size size) {
      canvas.save();
    });
  }
}

mixin CanvasPath2D on _CanvasRenderingContext2D, CanvasFillStrokeStyles2D, CanvasPathDrawingStyles2D {
  Paint _getPathPainter() {
    Paint paint = Paint()
      ..color = strokeStyle
      ..strokeWidth = lineWidth;
    return paint;
  }

  Path2D path2d = Path2D();

  void beginPath() {
    path2d = Path2D();
  }

  void clip(PathFillType fillType) {
    action((Canvas canvas, Size size) {
      path2d.path.fillType = fillType;
      canvas.clipPath(path2d.path);
    });
  }

  void fill(PathFillType fillType) {
    action((Canvas canvas, Size size) {
      path2d.path.fillType = fillType;
      Paint paint = _getPathPainter()..style = PaintingStyle.fill;
      canvas.drawPath(path2d.path, paint);
    });
  }

  void stroke() {
    action((Canvas canvas, Size size) {
      Paint paint = _getPathPainter()..style = PaintingStyle.stroke;
      canvas.drawPath(path2d.path, paint);
    });
  }

  bool isPointInPath(double x, double y, PathFillType fillRule) {
    return path2d.path.contains(Offset(x, y));
  }

  bool isPointInStroke(double x, double y) {
    return path2d.path.contains(Offset(x, y));
  }

  void arc(double x, double y, double radius, double startAngle, double endAngle, {bool anticlockwise = false}) {
    path2d.arc(x, y, radius, startAngle, endAngle, anticlockwise: anticlockwise);
  }

  void arcTo(double x1, double y1, double x2, double y2, double radius) {
    path2d.arcTo(x1, y1, x2, y2, radius);
  }

  void bezierCurveTo(double cp1x, double cp1y, double cp2x, double cp2y, double x, double y) {
    path2d.bezierCurveTo(cp1x, cp1y, cp2x, cp2y, x, y);
  }

  void closePath() {
    path2d.closePath();
  }

  void ellipse(double x, double y, double radiusX, double radiusY, double rotation, double startAngle, double endAngle, {bool anticlockwise = false}) {
    path2d.ellipse(x, y, radiusX, radiusY, rotation, startAngle, endAngle, anticlockwise: anticlockwise);
  }

  void lineTo(double x, double y) {
    path2d.lineTo(x, y);
  }

  void moveTo(double x, double y) {
    path2d.moveTo(x, y);
  }

  void quadraticCurveTo(double cpx, double cpy, double x, double y) {
    path2d.quadraticCurveTo(cpx, cpy, x, y);
  }

  void rect(double x, double y, double w, double h) {
    path2d.quadraticCurveTo(x, y, w, h);
  }
}

mixin CanvasPathDrawingStyles2D implements CanvasPathDrawingStyles {
  @override
  CanvasLineCap lineCap = CanvasLineCap.butt;

  @override
  double lineDashOffset = 0.0;

  @override
  CanvasLineJoin lineJoin = CanvasLineJoin.miter;

  @override
  double lineWidth = 1.0;

  @override
  double miterLimit = 10.0;

  String _lineDash = 'empty';

  resetPathDrawingStyles() {
    lineCap = CanvasLineCap.butt;
    lineDashOffset = 0.0;
    lineJoin = CanvasLineJoin.miter;
    lineWidth = 1.0;
    miterLimit = 10.0;
    _lineDash = 'empty';
  }

  @override
  String getLineDash() {
    return _lineDash;
  }

  @override
  void setLineDash(String segments) {
    _lineDash = segments;
  }
}

mixin CanvasTransform2D on _CanvasRenderingContext2D implements CanvasTransform {
  @override
  void translate(double x, double y) {
    action((Canvas canvas, Size size) {
      canvas.translate(x, y);
    });
  }

  @override
  void rotate(double angle) {
    action((Canvas canvas, Size size) {
      canvas.rotate(angle);
    });
  }

  @override
  void scale(double x, double y) {
    action((Canvas canvas, Size size) {
      canvas.scale(x, y);
    });
  }

  // https://github.com/WebKit/WebKit/blob/a77a158d4e2086fbe712e488ed147e8a54d44d3c/Source/WebCore/html/canvas/CanvasRenderingContext2DBase.cpp#L843
  @override
  void setTransform(double a, double b, double c, double d, double e, double f) {
    resetTransform();
    transform(a, b, c, d, e, f);
  }

  @override
  void resetTransform() {
    action((Canvas canvas, Size size) {
      canvas.transform(Matrix4.identity().storage);
    });
  }

  @override
  void transform(double a, double b, double c, double d, double e, double f) {
    action((Canvas canvas, Size size) {
      // Matrix3
      // [ a c e
      //   b d f
      //   0 0 1 ]
      //
      // Matrix4
      // [ a, b, 0, 0,
      //   c, d, 0, 0,
      //   e, f, 1, 0,
      //   0, 0, 0, 1 ]
      final Float64List m4storage = Float64List(16);
      m4storage[0] = a;
      m4storage[1] = b;
      m4storage[2] = 0.0;
      m4storage[3] = 0.0;
      m4storage[4] = c;
      m4storage[5] = d;
      m4storage[6] = 0.0;
      m4storage[7] = 0.0;
      m4storage[8] = e;
      m4storage[9] = f;
      m4storage[10] = 1.0;
      m4storage[11] = 0.0;
      m4storage[12] = 0.0;
      m4storage[13] = 0.0;
      m4storage[14] = 0.0;
      m4storage[15] = 1.0;
      canvas.transform(m4storage);
    });
  }
}

mixin CanvasFillStrokeStyles2D implements CanvasFillStrokeStyles {
  @override
  Color strokeStyle = CSSColor.initial;

  @override
  Color fillStyle = CSSColor.initial;

  void resetFillStrokeStyles() {
    strokeStyle = CSSColor.initial;
    fillStyle = CSSColor.initial;
  }

  @override
  CanvasGradient createLinearGradient(double x0, double y0, double x1, double y1) {
    // TODO: implement createLinearGradient
    throw UnimplementedError();
  }

  @override
  CanvasPattern createPattern(CanvasImageSource image, String repetition) {
    // TODO: implement createPattern
    throw UnimplementedError();
  }

  @override
  CanvasGradient createRadialGradient(double x0, double y0, double r0, double x1, double y1, double r1) {
    // TODO: implement createRadialGradient
    throw UnimplementedError();
  }
}

mixin CanvasRect2D on _CanvasRenderingContext2D, CanvasFillStrokeStyles2D, CanvasPathDrawingStyles2D implements CanvasRect {
  @override
  void clearRect(double x, double y, double w, double h) {
    Rect rect = Rect.fromLTWH(x, y, w, h);

    action((Canvas canvas, Size size) {
      Paint paint = Paint()..blendMode = BlendMode.src;
      canvas.drawRect(rect, paint);
    });
  }

  @override
  void fillRect(double x, double y, double w, double h) {
    Rect rect = Rect.fromLTWH(x, y, w, h);
    Paint paint = Paint()..color = fillStyle;

    action((Canvas canvas, Size size) {
      canvas.drawRect(rect, paint);
    });
  }

  @override
  void strokeRect(double x, double y, double w, double h) {
    Rect rect = Rect.fromLTWH(x, y, w, h);
    Paint paint = Paint()
      ..color = strokeStyle
      ..strokeWidth = lineWidth
      ..style = PaintingStyle.stroke;

    action((Canvas canvas, Size size) {
      canvas.drawRect(rect, paint);
    });
  }
}

mixin CanvasText2D on _CanvasRenderingContext2D, CanvasTextDrawingStyles2D, CanvasFillStrokeStyles2D implements CanvasText {
  TextStyle _getTextStyle(Color color) {
    return TextStyle(
      color: color,
      fontSize: fontSize,
      fontFamily: fontFamily,
    );
  }

  TextPainter _getTextPainter(String text, Color color) {
    TextStyle textStyle = _getTextStyle(color);
    TextSpan span = TextSpan(text: text, style: textStyle);
    TextAlign _textAlign;
    switch (textAlign) {
      case CanvasTextAlign.start:
        _textAlign = TextAlign.start;
        break;
      case CanvasTextAlign.end:
        _textAlign = TextAlign.end;
        break;
      case CanvasTextAlign.left:
        _textAlign = TextAlign.left;
        break;
      case CanvasTextAlign.right:
        _textAlign = TextAlign.right;
        break;
      case CanvasTextAlign.center:
        _textAlign = TextAlign.center;
        break;
    }

    TextDirection _textDirection;
    switch (direction) {
      case CanvasDirection.ltr:
        _textDirection = TextDirection.ltr;
        break;
      case CanvasDirection.rtl:
        _textDirection = TextDirection.rtl;
        break;
      case CanvasDirection.inherit:
        _textDirection = TextDirection.ltr;
        break;
    }

    TextPainter textPainter = TextPainter(
      text: span,
      textAlign: _textAlign,
      textDirection: _textDirection,
    );

    return textPainter;
  }

  void fillText(String text, double x, double y, {double maxWidth}) {
    TextPainter textPainter = _getTextPainter(text, fillStyle);
    action((Canvas canvas, Size size) {
      if (maxWidth != null) {
        textPainter.layout(maxWidth: maxWidth);
      } else {
        textPainter.layout();
      }

      double offsetToBaseline = textPainter.computeDistanceToActualBaseline(TextBaseline.alphabetic);
      // Paint text start with baseline.
      textPainter.paint(canvas, Offset(x, y - offsetToBaseline));
    });
  }

  void strokeText(String text, double x, double y, {double maxWidth}) {
    TextPainter textPainter = _getTextPainter(text, strokeStyle);
    action((Canvas canvas, Size size) {
      if (maxWidth != null) {
        textPainter.layout(maxWidth: maxWidth);
      } else {
        textPainter.layout();
      }

      double offsetToBaseline = textPainter.computeDistanceToActualBaseline(TextBaseline.alphabetic);
      // Paint text start with baseline.
      textPainter.paint(canvas, Offset(x, y - offsetToBaseline));
    });
  }

  TextMetrics measureText(String text) {
    // TextPainter textPainter = _getTextPainter(text, fillStyle);
    // TODO: transform textPainter layout info into TextMetrics.
    return null;
  }
}

mixin CanvasTextDrawingStyles2D implements CanvasTextDrawingStyles {
  double _fontSize = 10.0;

  double get fontSize => _fontSize;

  set fontSize(double value) {
    assert(value != null);
    if (_fontSize != value) {
      _fontSize = value;
    }
  }

  String _fontFamily = 'sans-serif';

  String get fontFamily => _fontFamily;

  set fontFamily(String value) {
    assert(value != null);
    if (_fontFamily != value) {
      _fontFamily = value;
    }
  }

  @override
  set font(String newValue) {}

  @override
  String get font => '${fontSize}px $fontFamily';

  @override
  CanvasDirection direction = CanvasDirection.inherit;

  @override
  CanvasTextAlign textAlign = CanvasTextAlign.start;

  @override
  CanvasTextBaseline textBaseline = CanvasTextBaseline.alphabetic;
}
