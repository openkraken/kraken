/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'dart:core';
import 'dart:ui';
import 'package:flutter/painting.dart';
import 'package:kraken/css.dart';
import 'canvas_context.dart';

final RegExp _splitRegExp = RegExp(' ');

class CanvasRenderingContext2DSettings {
  bool alpha = true;
  bool desynchronized = false;
}

class CanvasRenderingContext2D extends _CanvasRenderingContext2D
    with CanvasFillStrokeStyles2D, CanvasPathDrawingStyles2D, CanvasRect2D, CanvasTextDrawingStyles2D, CanvasText2D {
  @override
  String type = 'CanvasRenderingContext2D';

  Canvas canvas;
  CanvasRenderingContext2D() {
    _settings = CanvasRenderingContext2DSettings();
  }

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
      textPainter.paint(canvas, Offset(x, y));
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
      textPainter.paint(canvas, Offset(x, y));
    });
  }

  TextMetrics measureText(String text) {
    // TextPainter textPainter = _getTextPainter(text, fillStyle);
    // TODO: transform textPainter layout info into TextMetrics.
    return null;
  }
}

class CanvasTextDrawingStyles2D implements CanvasTextDrawingStyles {
  double fontSize = 10.0;
  String fontFamily = 'sans-serif';

  @override
  String get font => '${fontSize}px $fontFamily';

  @override
  set font(String newValue) {
    List<String> splitVal = newValue.split(_splitRegExp);
    if (splitVal.length == 2) {
      fontSize = CSSLength.toDisplayPortValue(splitVal[0]) ?? 14.0;
      fontFamily = splitVal[1];
    }
  }

  @override
  CanvasDirection direction = CanvasDirection.inherit;

  @override
  CanvasTextAlign textAlign = CanvasTextAlign.start;

  @override
  CanvasTextBaseline textBaseline = CanvasTextBaseline.alphabetic;
}
