/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'dart:collection';
import 'dart:core';
import 'dart:ffi';
import 'dart:typed_data';
import 'dart:ui';

import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:kraken/bridge.dart';
import 'package:kraken/foundation.dart';
import 'package:kraken/css.dart';
import 'package:kraken/dom.dart';
import 'package:vector_math/vector_math_64.dart';

import 'canvas_context.dart';
import 'canvas_path_2d.dart';

const String _DEFAULT_FONT = '10px sans-serif';
const String START = 'start';
const String END = 'end';
const String CENTER = 'center';
const String LTR = 'ltr';
const String RTL = 'rtl';
const String INHERIT = 'inherit';
const String HANGING = 'hanging';
const String MIDDLE = 'middle';
const String ALPHABETIC = 'alphabetic';
const String IDEOGRAPHIC = 'ideographic';
const String EVENODD = 'evenodd';
const String BUTT = 'butt';
const String ROUND = 'round';
const String SQUARE = 'square';
const String MITER = 'miter';
const String BEVEL = 'bevel';

class CanvasRenderingContext2DSettings {
  bool alpha = true;
  bool desynchronized = false;
}

typedef CanvasAction = void Function(Canvas, Size);

// void _callNativeMethods(Pointer<Void> nativePtr, Pointer<NativeValue> returnedValue, Pointer<NativeString> nativeMethod, int argc, Pointer<NativeValue> argv) {
//   String method = nativeStringToString(nativeMethod);
//   List<dynamic> values = List.generate(argc, (i) {
//     Pointer<NativeValue> nativeValue = argv.elementAt(i);
//     return fromNativeValue(nativeValue);
//   });
//
//   CanvasRenderingContext2D renderingContext2D = CanvasRenderingContext2D.getCanvasRenderContext2DOfNativePtr(nativePtr.cast<NativeCanvasRenderingContext2D>());
//   try {
//     dynamic result = renderingContext2D.handleJSCall(method, values);
//     toNativeValue(returnedValue, result);
//   } catch (e, stack) {
//     print('$e\n$stack');
//     toNativeValue(returnedValue, null);
//   }
// }

class CanvasRenderingContext2D extends BindingObject {
  final Pointer<NativeCanvasRenderingContext2D> nativeCanvasRenderingContext2D;

  CanvasRenderingContext2D()
      : nativeCanvasRenderingContext2D = malloc.allocate<NativeCanvasRenderingContext2D>(sizeOf<NativeCanvasRenderingContext2D>()) {
    _settings = CanvasRenderingContext2DSettings();

    // nativeCanvasRenderingContext2D.ref.callNativeMethods = Pointer.fromFunction(_callNativeMethods);
    // _nativeMap[nativeCanvasRenderingContext2D.address] = this;
  }

  static final SplayTreeMap<int, CanvasRenderingContext2D> _nativeMap = SplayTreeMap();

  static CanvasRenderingContext2D getCanvasRenderContext2DOfNativePtr(Pointer<NativeCanvasRenderingContext2D> nativePtr) {
    CanvasRenderingContext2D? renderingContext = _nativeMap[nativePtr.address];
    if (renderingContext == null) throw FlutterError('Can not get nativeRenderingContext2D from pointer: $nativePtr');
    return renderingContext;
  }

  @override
  void dispose() {
    super.dispose();
    _nativeMap.remove(nativeCanvasRenderingContext2D.address);
  }

  late CanvasRenderingContext2DSettings _settings;

  CanvasRenderingContext2DSettings getContextAttributes() => _settings;

  late CanvasElement canvas;
  // HACK: We need record the current matrix state because flutter canvas not export resetTransform now.
  // https://github.com/flutter/engine/pull/25449
  Matrix4 _matrix = Matrix4.identity();
  Matrix4 _lastMatrix = Matrix4.identity();

  int get actionCount => _actions.length;

  final List<CanvasAction> _actions = [];

  void addAction(CanvasAction action) {
    _actions.add(action);
    // Must trigger repaint after action
    canvas.repaintNotifier.notifyListeners(); // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
  }

  // Perform canvas drawing.
  void performActions(Canvas canvas, Size size) {
    // HACK: Must sync transform first because each paint will saveLayer and restore that make the transform not effect
    if (!_lastMatrix.isIdentity()) {
      canvas.transform(_lastMatrix.storage);
    }
    for (int i = 0; i < _actions.length; i++) {
      _actions[i](canvas, size);
    }
    if (_lastMatrix != _matrix) {
      _lastMatrix = _matrix.clone();
    }
    // Clear actions
    _actions.clear();
  }

  static TextAlign? parseTextAlign(String value) {
    switch (value) {
      case START:
        return TextAlign.start;
      case END:
        return TextAlign.end;
      case LEFT:
        return TextAlign.left;
      case RIGHT:
        return TextAlign.right;
      case CENTER:
        return TextAlign.center;
    }
    return null;
  }

  TextAlign _textAlign = TextAlign.start; // (default: "start")
  set textAlign(TextAlign? value) {
    if (value == null) return;
    addAction((Canvas canvas, Size size) {
      _textAlign = value;
    });
  }
  TextAlign get textAlign => _textAlign;

  static CanvasTextBaseline? parseTextBaseline(String value) {
    switch(value) {
      case TOP:
        return CanvasTextBaseline.top;
      case HANGING:
        return CanvasTextBaseline.hanging;
      case MIDDLE:
        return CanvasTextBaseline.middle;
      case ALPHABETIC:
        return CanvasTextBaseline.alphabetic;
      case IDEOGRAPHIC:
        return CanvasTextBaseline.ideographic;
      case BOTTOM:
        return CanvasTextBaseline.bottom;
    }
    return null;
  }

  CanvasTextBaseline _textBaseline = CanvasTextBaseline.alphabetic; // (default: "alphabetic")
  set textBaseline(CanvasTextBaseline? value) {
    if (value == null) return;
    addAction((Canvas canvas, Size size) {
      _textBaseline = value;
    });
  }

  CanvasTextBaseline get textBaseline => _textBaseline;
  static TextDirection? parseDirection(String value) {
    switch (value) {
      case LTR:
        return TextDirection.ltr;
      case RTL:
        return TextDirection.rtl;
      case INHERIT:
        return TextDirection.ltr;
    }
    return null;
  }
  // FIXME: The text direction is inherited from the <canvas> element or the Document as appropriate.
  TextDirection _direction = TextDirection.ltr; // (default: "inherit")
  set direction(TextDirection? value) {
    if (value == null) return;
    addAction((Canvas canvas, Size size) {
      _direction = value;
    });
  }
  TextDirection get direction => _direction;

  Map<String, String?> _fontProperties = {};
  double? _fontSize;
  bool _parseFont(String newValue) {
    Map<String, String?> properties = {};
    CSSStyleProperty.setShorthandFont(properties, newValue);
    if (properties.isEmpty) return false;
    _fontProperties = properties;

    // In canvas font property, the em and rem units do not update when font-size changed,
    // so computed the relative length immediately.
    String? fontSize = properties[FONT_SIZE];
    if (fontSize != null) {
      if (CSSPercentage.isPercentage(fontSize)) {
        double? percentage = CSSPercentage.parsePercentage(fontSize);
        if (percentage != null) {
          _fontSize = percentage * canvas.renderStyle.fontSize.computedValue;
        }
      } else {
        _fontSize = CSSLength.parseLength(properties[FONT_SIZE]!, canvas.renderStyle).computedValue;
      }
    }
    return true;
  }
  String _font = _DEFAULT_FONT; // (default 10px sans-serif)
  set font(String value) {
    addAction((Canvas canvas, Size size) {
      // Must lazy parse in action because it has side-effect with _fontProperties.
      if (_parseFont(value)) {
        _font = value;
      }
    });
  }
  String get font => _font;

  final List _states = [];
  // push state on state stack
  void restore() {
    addAction((Canvas canvas, Size size) {
      var state = _states.last;
      _states.removeLast();
      _strokeStyle = state[0];
      _fillStyle = state[1];
      _lineWidth = state[2];
      _lineCap = state[3];
      _lineJoin = state[4];
      _lineDashOffset = state[5];
      _miterLimit = state[6];
      _font = state[7];
      _textAlign = state[8];
      _direction = state[9];

      canvas.restore();
    });
  }

  // pop state stack and restore state
  void save() {
    addAction((Canvas canvas, Size size) {
      _states.add([strokeStyle, fillStyle, lineWidth, lineCap, lineJoin, lineDashOffset, miterLimit, font, textAlign, direction]);
      canvas.save();
    });
  }

  Path2D path2d = Path2D();

  void beginPath() {
    addAction((Canvas canvas, Size size) {
      path2d = Path2D();
    });
  }

  void clip(PathFillType fillType) {
    addAction((Canvas canvas, Size size) {
      path2d.path.fillType = fillType;
      canvas.clipPath(path2d.path);
    });
  }

  void fill(PathFillType fillType) {
    addAction((Canvas canvas, Size size) {
      path2d.path.fillType = fillType;
      Paint paint = Paint()
        ..color = fillStyle
        ..style = PaintingStyle.fill;
      canvas.drawPath(path2d.path, paint);
    });
  }

  void stroke() {
    addAction((Canvas canvas, Size size) {
      Paint paint = Paint()
        ..color = strokeStyle
        ..strokeJoin = lineJoin
        ..strokeCap = lineCap
        ..strokeWidth = lineWidth
        ..strokeMiterLimit = miterLimit
        ..style = PaintingStyle.stroke;
      canvas.drawPath(path2d.path, paint);
    });
  }

  bool isPointInPath(double x, double y, PathFillType fillRule) {
    return path2d.path.contains(Offset(x, y));
  }

  bool isPointInStroke(double x, double y) {
    return path2d.path.contains(Offset(x, y));
  }

  void arc(num x, num y, num radius, num startAngle, num endAngle, {bool anticlockwise = false}) {
    addAction((Canvas canvas, Size size) {
      path2d.arc(x.toDouble(), y.toDouble(), radius.toDouble(), startAngle.toDouble(), endAngle.toDouble(), anticlockwise: anticlockwise);
    });
  }

  void arcTo(num x1, num y1, num x2, num y2, num radius) {
    addAction((Canvas canvas, Size size) {
      path2d.arcTo(x1.toDouble(), y1.toDouble(), x2.toDouble(), y2.toDouble(), radius.toDouble());
    });
  }

  void bezierCurveTo(num cp1x, num cp1y, num cp2x, num cp2y, num x, num y) {
    addAction((Canvas canvas, Size size) {
      path2d.bezierCurveTo(cp1x.toDouble(), cp1y.toDouble(), cp2x.toDouble(), cp2y.toDouble(), x.toDouble(), y.toDouble());
    });
  }

  void closePath() {
    addAction((Canvas canvas, Size size) {
      path2d.closePath();
    });
  }

  void drawImage(int argumentCount, Image? img, num sx, num sy, num sWidth, num sHeight, num dx, num dy, num dWidth, num dHeight) {
    if (img == null) return;

    addAction((Canvas canvas, Size size) {
      // ctx.drawImage(image, dx, dy);
      if (argumentCount == 3) {
        canvas.drawImage(img, Offset(dx.toDouble(), dy.toDouble()), Paint());
      } else {
        if (argumentCount == 5) {
          // ctx.drawImage(image, dx, dy, dWidth, dHeight);
          sx = 0;
          sy = 0;
          sWidth = img.width.toDouble();
          sHeight = img.height.toDouble();
        }

        canvas.drawImageRect(img,
            Rect.fromLTWH(sx.toDouble(), sy.toDouble(), sWidth.toDouble(), sHeight.toDouble()),
            Rect.fromLTWH(dx.toDouble(), dy.toDouble(), dWidth.toDouble(), dHeight.toDouble()),
            Paint());
      }
    });
  }

  void ellipse(num x, num y, num radiusX, num radiusY, num rotation, num startAngle, num endAngle, {bool anticlockwise = false}) {
    addAction((Canvas canvas, Size size) {
      path2d.ellipse(x.toDouble(), y.toDouble(), radiusX.toDouble(), radiusY.toDouble(), rotation.toDouble(), startAngle.toDouble(), endAngle.toDouble(), anticlockwise: anticlockwise);
    });
  }

  void lineTo(num x, num y) {
    addAction((Canvas canvas, Size size) {
      path2d.lineTo(x.toDouble(), y.toDouble());
    });
  }

  void moveTo(num x, num y) {
    addAction((Canvas canvas, Size size) {
      path2d.moveTo(x.toDouble(), y.toDouble());
    });
  }

  void quadraticCurveTo(num cpx, num cpy, num x, num y) {
    addAction((Canvas canvas, Size size) {
      path2d.quadraticCurveTo(cpx.toDouble(), cpy.toDouble(), x.toDouble(), y.toDouble());
    });
  }

  void rect(num x, num y, num w, num h) {
    addAction((Canvas canvas, Size size) {
      path2d.rect(x.toDouble(), y.toDouble(), w.toDouble(), h.toDouble());
    });
  }

  // butt, round, square
  static StrokeCap? parseLineCap(String value) {
    switch(value) {
      case BUTT:
        return StrokeCap.butt;
      case ROUND:
        return StrokeCap.round;
      case SQUARE:
        return StrokeCap.square;
    }
    return null;
  }

  StrokeCap _lineCap = StrokeCap.butt; // (default "butt")
  set lineCap(StrokeCap? value) {
    if (value == null) return;
    addAction((Canvas canvas, Size size) {
      _lineCap = value;
    });
  }
  StrokeCap get lineCap => _lineCap;

  double _lineDashOffset = 0.0;
  set lineDashOffset(double? value) {
    if (value == null) return;
    addAction((Canvas canvas, Size size) {
      _lineDashOffset = value;
    });
  }
  double get lineDashOffset => _lineDashOffset;

  static StrokeJoin? parseLineJoin(String value) {
    // round, bevel, miter
    switch (value) {
      case ROUND:
        return StrokeJoin.round;
      case BEVEL:
        return StrokeJoin.bevel;
      case MITER:
        return StrokeJoin.miter;
    }
    return null;
  }
  // The lineJoin can effect the stroke(), strokeRect(), and strokeText() methods.
  StrokeJoin _lineJoin = StrokeJoin.miter;
  set lineJoin(StrokeJoin? value) {
    if (value == null) return;
    addAction((Canvas canvas, Size size) {
      _lineJoin = value;
    });
  }
  StrokeJoin get lineJoin => _lineJoin;

  double _lineWidth = 1.0; // (default 1)
  set lineWidth(num? value) {
    if (value == null) return;
    addAction((Canvas canvas, Size size) {
      _lineWidth = value.toDouble();
    });
  }
  double get lineWidth => _lineWidth;

  double _miterLimit = 10.0; // (default 10)
  set miterLimit(num? value) {
    if (value == null) return;
    addAction((Canvas canvas, Size size) {
      _miterLimit = value.toDouble();
    });
  }
  double get miterLimit => _miterLimit;

  String _lineDash = 'empty'; // default empty

  String getLineDash() {
    return _lineDash;
  }

  void setLineDash(String segments) {
    _lineDash = segments;
  }

  void translate(num x, num y) {
    _matrix.translate(x.toDouble(), y.toDouble());
    addAction((Canvas canvas, Size size) {
      canvas.translate(x.toDouble(), y.toDouble());
    });
  }

  void rotate(num angle) {
    _matrix.setRotationZ(angle.toDouble());
    addAction((Canvas canvas, Size size) {
      canvas.rotate(angle.toDouble());
    });
  }

  // transformations (default transform is the identity matrix)
  void scale(num x, num y) {
    _matrix.scale(x.toDouble(), y.toDouble());
    addAction((Canvas canvas, Size size) {
      canvas.scale(x.toDouble(), y.toDouble());
    });
  }

  Matrix4 getTransform() {
    return _matrix;
  }

  // https://github.com/WebKit/WebKit/blob/a77a158d4e2086fbe712e488ed147e8a54d44d3c/Source/WebCore/html/canvas/CanvasRenderingContext2DBase.cpp#L843
  void setTransform(num a, num b, num c, num d, num e, num f) {
    resetTransform();
    transform(a, b, c, d, e, f);
  }

  // Resets the current transform to the identity matrix.
  void resetTransform() {
    Matrix4 m4 = Matrix4.inverted(_matrix);
    _matrix = Matrix4.identity();
    addAction((Canvas canvas, Size size) {
      canvas.transform(m4.storage);
    });
  }

  void transform(num a, num b, num c, num d, num e, num f) {
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
    m4storage[0] = a.toDouble();
    m4storage[1] = b.toDouble();
    m4storage[2] = 0.0;
    m4storage[3] = 0.0;
    m4storage[4] = c.toDouble();
    m4storage[5] = d.toDouble();
    m4storage[6] = 0.0;
    m4storage[7] = 0.0;
    m4storage[8] = e.toDouble();
    m4storage[9] = f.toDouble();
    m4storage[10] = 1.0;
    m4storage[11] = 0.0;
    m4storage[12] = 0.0;
    m4storage[13] = 0.0;
    m4storage[14] = 0.0;
    m4storage[15] = 1.0;

    _matrix = Matrix4.fromFloat64List(m4storage)..multiply(_matrix);
    addAction((Canvas canvas, Size size) {
      canvas.transform(m4storage);
    });
  }


  Color _strokeStyle = CSSColor.initial; // default black
  set strokeStyle(Color? newValue) {
    if (newValue == null) return;
    addAction((Canvas canvas, Size size) {
      _strokeStyle = newValue;
    });
  }
  Color get strokeStyle => _strokeStyle;

  Color _fillStyle = CSSColor.initial; // default black
  set fillStyle(Color? newValue) {
    if (newValue == null) return;
    addAction((Canvas canvas, Size size) {
      _fillStyle = newValue;
    });
  }
  Color get fillStyle => _fillStyle;

  CanvasGradient createLinearGradient(double x0, double y0, double x1, double y1) {
    // TODO: implement createLinearGradient
    throw UnimplementedError();
  }

  CanvasPattern createPattern(CanvasImageSource image, String repetition) {
    // TODO: implement createPattern
    throw UnimplementedError();
  }

  CanvasGradient createRadialGradient(double x0, double y0, double r0, double x1, double y1, double r1) {
    // TODO: implement createRadialGradient
    throw UnimplementedError();
  }

  void clearRect(num x, num y, num w, num h) {
    Rect rect = Rect.fromLTWH(x.toDouble(), y.toDouble(), w.toDouble(), h.toDouble());
    addAction((Canvas canvas, Size size) {
      // Must saveLayer before clear avoid there is a "black" background
      Paint paint = Paint()
        ..style = PaintingStyle.fill
        ..blendMode = BlendMode.clear;
      canvas.drawRect(rect, paint);
    });
  }

  void fillRect(num x, num y, num w, num h) {
    Rect rect = Rect.fromLTWH(x.toDouble(), y.toDouble(), w.toDouble(), h.toDouble());
    addAction((Canvas canvas, Size size) {
      Paint paint = Paint()..color = fillStyle;
      canvas.drawRect(rect, paint);
    });
  }

  void strokeRect(num x, num y, num w, num h) {
    Rect rect = Rect.fromLTWH(x.toDouble(), y.toDouble(), w.toDouble(), h.toDouble());
    addAction((Canvas canvas, Size size) {
      Paint paint = Paint()
        ..color = strokeStyle
        ..strokeJoin = lineJoin
        ..strokeCap = lineCap
        ..strokeWidth = lineWidth
        ..strokeMiterLimit = miterLimit
        ..style = PaintingStyle.stroke;
      canvas.drawRect(rect, paint);
    });
  }

  TextStyle _getTextStyle(Color color, bool shouldStrokeText) {
    if (_fontProperties.isEmpty) {
      _parseFont(_DEFAULT_FONT);
    }
    var fontFamilyFallback = CSSText.resolveFontFamilyFallback(_fontProperties[FONT_FAMILY]);
    FontWeight fontWeight = CSSText.resolveFontWeight(_fontProperties[FONT_WEIGHT]);
    if (shouldStrokeText) {
      return TextStyle(
          fontSize: _fontSize ?? 10,
          fontFamilyFallback: fontFamilyFallback,
          foreground: Paint()
            ..strokeJoin = lineJoin
            ..strokeCap = lineCap
            ..strokeWidth = lineWidth
            ..strokeMiterLimit = miterLimit
            ..style = PaintingStyle.stroke
            ..color = color
      );

    } else {
      return TextStyle(
        color: color,
        fontSize: _fontSize,
        fontFamilyFallback: fontFamilyFallback,
        fontWeight: fontWeight,
      );
    }
  }

  TextPainter _getTextPainter(String text, Color color, { bool shouldStrokeText = false }) {
    TextStyle textStyle = _getTextStyle(color, shouldStrokeText);
    TextSpan span = TextSpan(text: text, style: textStyle);
    TextPainter textPainter = TextPainter(
      text: span,
      // FIXME: Current must passed but not work in canvas text painter
      textDirection: direction,
      textAlign: textAlign,
    );

    return textPainter;
  }

  Offset _getAlignOffset(double width) {
    switch (textAlign) {
      case TextAlign.left:
        return Offset.zero;
      case TextAlign.right:
        return Offset(width, 0.0);
      case TextAlign.justify:
      case TextAlign.center:
      // The alignment is relative to the x value of the fillText() method.
      // For example, if textAlign is "center", then the text's left edge will be at x - (textWidth / 2).
        return Offset(width / 2.0, 0.0);
      case TextAlign.start:
        return direction == TextDirection.rtl ? Offset(width, 0.0): Offset.zero;
      case TextAlign.end:
        return direction == TextDirection.rtl ? Offset.zero: Offset(width, 0.0);
    }
  }

  void fillText(String text, num x, num y, {num? maxWidth}) {
    addAction((Canvas canvas, Size size) {
      TextPainter textPainter = _getTextPainter(text, fillStyle);
      if (maxWidth != null) {
        // FIXME: should scale down to a smaller font size in order to fit the text in the specified width.
        textPainter.layout(maxWidth: maxWidth.toDouble());
      } else {
        textPainter.layout();
      }
      // Paint text start with baseline.
      double offsetToBaseline = textPainter.computeDistanceToActualBaseline(TextBaseline.alphabetic);
      textPainter.paint(canvas, Offset(x.toDouble(), y - offsetToBaseline) - _getAlignOffset(textPainter.width));
    });
  }


  void strokeText(String text, num x, num y, {num? maxWidth}) {
    addAction((Canvas canvas, Size size) {
      TextPainter textPainter = _getTextPainter(text, strokeStyle, shouldStrokeText: true);
      if (maxWidth != null) {
        // FIXME: should scale down to a smaller font size in order to fit the text in the specified width.
        textPainter.layout(maxWidth: maxWidth.toDouble());
      } else {
        textPainter.layout();
      }

      double offsetToBaseline = textPainter.computeDistanceToActualBaseline(TextBaseline.alphabetic);
      // Paint text start with baseline.
      textPainter.paint(canvas, Offset(x.toDouble(), y - offsetToBaseline) - _getAlignOffset(textPainter.width));
    });
  }

  TextMetrics? measureText(String text) {
    // TextPainter textPainter = _getTextPainter(text, fillStyle);
    // TODO: transform textPainter layout info into TextMetrics.
    return null;
  }
}
