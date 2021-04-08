/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'dart:core';
import 'dart:ui';
import 'dart:ffi';
import 'dart:collection';
import 'package:ffi/ffi.dart';
import 'package:flutter/painting.dart';
import 'package:kraken/bridge.dart';
import 'package:kraken/css.dart';
import 'canvas_context.dart';

final RegExp _splitRegExp = RegExp(' ');

class CanvasRenderingContext2DSettings {
  bool alpha = true;
  bool desynchronized = false;
}

final Pointer<NativeFunction<Native_RenderingContextSetFont>> nativeSetFont = Pointer.fromFunction(CanvasRenderingContext2D._setFont);
final Pointer<NativeFunction<Native_RenderingContextSetFillStyle>> nativeSetFillStyle = Pointer.fromFunction(CanvasRenderingContext2D._setFillStyle);
final Pointer<NativeFunction<Native_RenderingContextSetStrokeStyle>> nativeSetStrokeStyle = Pointer.fromFunction(CanvasRenderingContext2D._setStrokeStyle);
final Pointer<NativeFunction<Native_RenderingContextFillRect>> nativeFillRect = Pointer.fromFunction(CanvasRenderingContext2D._fillRect);
final Pointer<NativeFunction<Native_RenderingContextClearRect>> nativeClearRect = Pointer.fromFunction(CanvasRenderingContext2D._clearRect);
final Pointer<NativeFunction<Native_RenderingContextStrokeRect>> nativeStrokeRect = Pointer.fromFunction(CanvasRenderingContext2D._strokeRect);
final Pointer<NativeFunction<Native_RenderingContextFillText>> nativeFillText = Pointer.fromFunction(CanvasRenderingContext2D._fillText);
final Pointer<NativeFunction<Native_RenderingContextStrokeText>> nativeStrokeText = Pointer.fromFunction(CanvasRenderingContext2D._strokeText);
final Pointer<NativeFunction<Native_RenderingContextSave>> nativeSave = Pointer.fromFunction(CanvasRenderingContext2D._save);
final Pointer<NativeFunction<Native_RenderingContextRestore>> nativeRestore = Pointer.fromFunction(CanvasRenderingContext2D._restore);

class CanvasRenderingContext2D extends _CanvasRenderingContext2D
    with CanvasFillStrokeStyles2D, CanvasPathDrawingStyles2D, CanvasRect2D, CanvasTextDrawingStyles2D, CanvasText2D {
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
      canvasRenderingContext2D.fontSize = CSSLength.toDisplayPortValue(splitVal[0], viewportSize) ?? 10.0;
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

  Canvas canvas;

  CanvasRenderingContext2D() : nativeCanvasRenderingContext2D = allocate<NativeCanvasRenderingContext2D>() {
    _settings = CanvasRenderingContext2DSettings();

    _nativeMap[nativeCanvasRenderingContext2D.address] = this;

    nativeCanvasRenderingContext2D.ref.setFont = nativeSetFont;
    nativeCanvasRenderingContext2D.ref.setFillStyle = nativeSetFillStyle;
    nativeCanvasRenderingContext2D.ref.setStrokeStyle = nativeSetStrokeStyle;
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
    canvas = _canvas;
    List<CanvasAction> actions = takeActionRecords();
    for (int i = 0; i < actions.length; i++) {
      actions[i](_canvas, _size);
    }
    canvas = null;
  }

  CanvasRenderingContext2DSettings _settings;

  CanvasRenderingContext2DSettings getContextAttributes() => _settings;

  void save() {
    canvas.save();
  }

  void restore() {
    canvas.restore();
  }

  void dispose() {
    _nativeMap.remove(nativeCanvasRenderingContext2D.address);
  }
}

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

class CanvasPathDrawingStyles2D implements CanvasPathDrawingStyles {
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

  @override
  String getLineDash() {
    return _lineDash;
  }

  @override
  void setLineDash(String segments) {
    _lineDash = segments;
  }
}

class CanvasFillStrokeStyles2D implements CanvasFillStrokeStyles {
  @override
  Color strokeStyle = CSSColor.initial;

  @override
  Color fillStyle = CSSColor.initial;

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

mixin CanvasRect2D
on _CanvasRenderingContext2D, CanvasFillStrokeStyles2D, CanvasPathDrawingStyles2D
implements CanvasRect {
  @override
  void clearRect(double x, double y, double w, double h) {
    Rect rect = Rect.fromLTWH(x, y, w, h);

    action((Canvas canvas, Size size) {
      Paint paint = Paint()
        ..blendMode = BlendMode.src;
      canvas.drawRect(rect, paint);
    });
  }

  @override
  void fillRect(double x, double y, double w, double h) {
    Rect rect = Rect.fromLTWH(x, y, w, h);
    Paint paint = Paint()
      ..color = fillStyle;

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

mixin CanvasText2D
on _CanvasRenderingContext2D, CanvasTextDrawingStyles2D, CanvasFillStrokeStyles2D
implements CanvasText {
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

class CanvasTextDrawingStyles2D implements CanvasTextDrawingStyles {
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
  set font(String newValue) {
  }

  @override
  String get font => '${fontSize}px $fontFamily';

  @override
  CanvasDirection direction = CanvasDirection.inherit;

  @override
  CanvasTextAlign textAlign = CanvasTextAlign.start;

  @override
  CanvasTextBaseline textBaseline = CanvasTextBaseline.alphabetic;
}
