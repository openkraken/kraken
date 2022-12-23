/*
 * Copyright (C) 2019-present The Kraken authors. All rights reserved.
 */
import 'dart:core';
import 'dart:ffi';
import 'dart:typed_data';
import 'dart:ui';

import 'package:ffi/ffi.dart';
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

class CanvasRenderingContext2D extends BindingObject {
  CanvasRenderingContext2D(this.canvas) : _pointer = malloc.allocate<NativeCanvasRenderingContext2D>(
      sizeOf<NativeCanvasRenderingContext2D>()), super();

  final Pointer<NativeCanvasRenderingContext2D> _pointer;

  @override
  get pointer => _pointer;

  @override
  get contextId => canvas.contextId;

  Pointer<NativeCanvasRenderingContext2D> toNative() {
    return pointer;
  }

  @override
  invokeBindingMethod(String method, List args) {
    // @NOTE: Bridge not guarantee that input type number is double.
    switch (method) {
      case 'arc': return arc(
          castToType<num>(args[0]).toDouble(),
          castToType<num>(args[1]).toDouble(),
          castToType<num>(args[2]).toDouble(),
          castToType<num>(args[3]).toDouble(),
          castToType<num>(args[4]).toDouble(),
          anticlockwise : args[5] == 1 ? true : false);
      case 'arcTo':  return arcTo(
          castToType<num>(args[0]).toDouble(),
          castToType<num>(args[1]).toDouble(),
          castToType<num>(args[2]).toDouble(),
          castToType<num>(args[3]).toDouble(),
          castToType<num>(args[4]).toDouble()
      );
      case 'fillRect': return fillRect(
          castToType<num>(args[0]).toDouble(),
          castToType<num>(args[1]).toDouble(),
          castToType<num>(args[2]).toDouble(),
          castToType<num>(args[3]).toDouble()
      );
      case 'clearRect': return clearRect(
          castToType<num>(args[0]).toDouble(),
          castToType<num>(args[1]).toDouble(),
          castToType<num>(args[2]).toDouble(),
          castToType<num>(args[3]).toDouble());
      case 'strokeRect': return strokeRect(
          castToType<num>(args[0]).toDouble(),
          castToType<num>(args[1]).toDouble(),
          castToType<num>(args[2]).toDouble(),
          castToType<num>(args[3]).toDouble());
      case 'fillText':
        double maxWidth = castToType<num>(args[3]).toDouble();
        if (!maxWidth.isNaN) {
          return fillText(
              castToType<String>(args[0]),
              castToType<num>(args[1]).toDouble(),
              castToType<num>(args[2]).toDouble(),
              maxWidth: maxWidth);
        } else {
          return fillText(castToType<String>(args[0]),
            castToType<num>(args[1]).toDouble(),
            castToType<num>(args[2]).toDouble());
        }
      case 'strokeText':
        double maxWidth = castToType<num>(args[3]).toDouble();
      if (!maxWidth.isNaN) {
        return strokeText(castToType<String>(args[0]),
            castToType<num>(args[1]).toDouble(),
            castToType<num>(args[2]).toDouble(),
            maxWidth: maxWidth);
      } else {
        return strokeText(castToType<String>(args[0]),
            castToType<num>(args[1]).toDouble(),
            castToType<num>(args[2]).toDouble());
      }
      case 'save': return save();
      case 'restore': return restore();
      case 'beginPath': return beginPath();
      case 'bezierCurveTo': return bezierCurveTo(
          castToType<num>(args[0]).toDouble(),
          castToType<num>(args[1]).toDouble(),
          castToType<num>(args[2]).toDouble(),
          castToType<num>(args[3]).toDouble(),
          castToType<num>(args[4]).toDouble(),
          castToType<num>(args[5]).toDouble());
      case 'clip':
        PathFillType fillType = castToType<String>(args[0]) == EVENODD ? PathFillType.evenOdd : PathFillType.nonZero;
        return clip(fillType);
      case 'closePath': return closePath();
      case 'drawImage':
        BindingObject imageElement = BindingBridge.getBindingObject(args[0]);
        if (imageElement is ImageElement) {
          double sx = 0.0,
              sy = 0.0,
              sWidth = 0.0,
              sHeight = 0.0,
              dx = 0.0,
              dy = 0.0,
              dWidth = 0.0,
              dHeight = 0.0;

          if (args.length == 3) {
            dx = castToType<num>(args[1]).toDouble();
            dy = castToType<num>(args[2]).toDouble();
          } else if (args.length == 5) {
            dx = castToType<num>(args[1]).toDouble();
            dy = castToType<num>(args[2]).toDouble();
            dWidth = castToType<num>(args[3]).toDouble();
            dHeight = castToType<num>(args[4]).toDouble();
          } else if (args.length == 9) {
            sx = castToType<num>(args[1]).toDouble();
            sy = castToType<num>(args[2]).toDouble();
            sWidth = castToType<num>(args[3]).toDouble();
            sHeight = castToType<num>(args[4]).toDouble();
            dx = castToType<num>(args[5]).toDouble();
            dy = castToType<num>(args[6]).toDouble();
            dWidth = castToType<num>(args[7]).toDouble();
            dHeight = castToType<num>(args[8]).toDouble();
          }

          return drawImage(
              args.length,
              imageElement.image,
              sx,
              sy,
              sWidth,
              sHeight,
              dx,
              dy,
              dWidth,
              dHeight);
        }
        break;
      case 'ellipse':
        return ellipse(
            castToType<num>(args[0]).toDouble(),
            castToType<num>(args[1]).toDouble(),
            castToType<num>(args[2]).toDouble(),
            castToType<num>(args[3]).toDouble(),
            castToType<num>(args[4]).toDouble(),
            castToType<num>(args[5]).toDouble(),
            castToType<num>(args[6]).toDouble(),
            anticlockwise : args[7] == 1 ? true : false);
      case 'fill':
         PathFillType fillType = args[0] == EVENODD ? PathFillType.evenOdd : PathFillType.nonZero;
         return fill(fillType);
      case 'lineTo': return lineTo(
        castToType<num>(args[0]).toDouble(),
        castToType<num>(args[1]).toDouble());
      case 'moveTo': return moveTo(
        castToType<num>(args[0]).toDouble(),
        castToType<num>(args[1]).toDouble());
      case 'quadraticCurveTo': return quadraticCurveTo(
          castToType<num>(args[0]).toDouble(),
          castToType<num>(args[1]).toDouble(),
          castToType<num>(args[2]).toDouble(),
          castToType<num>(args[3]).toDouble());
      case 'rect': return rect(
          castToType<num>(args[0]).toDouble(),
          castToType<num>(args[1]).toDouble(),
          castToType<num>(args[2]).toDouble(),
          castToType<num>(args[3]).toDouble());
      case 'rotate': return rotate(castToType<num>(args[0]).toDouble());
      case 'resetTransform': return resetTransform();
      case 'scale': return scale(
          castToType<num>(args[0]).toDouble(),
          castToType<num>(args[1]).toDouble()
      );
      case 'stroke': return stroke();
      case 'setTransform': return setTransform(
          castToType<num>(args[0]).toDouble(),
          castToType<num>(args[1]).toDouble(),
          castToType<num>(args[2]).toDouble(),
          castToType<num>(args[3]).toDouble(),
          castToType<num>(args[4]).toDouble(),
          castToType<num>(args[5]).toDouble()
      );
      case 'transform': return transform(
          castToType<num>(args[0]).toDouble(),
          castToType<num>(args[1]).toDouble(),
          castToType<num>(args[2]).toDouble(),
          castToType<num>(args[3]).toDouble(),
          castToType<num>(args[4]).toDouble(),
          castToType<num>(args[5]).toDouble()
      );
      case 'translate': return translate(
        castToType<num>(args[0]).toDouble(),
        castToType<num>(args[1]).toDouble());
      default: return super.invokeBindingMethod(method, args);
    }
  }

  @override
  void setBindingProperty(String key, value) {
    switch (key) {
      case 'fillStyle':
        Color? color = CSSColor.parseColor(castToType<String>(value));
        if (color != null) fillStyle = color;
        break;
      case 'direction': direction = parseDirection(castToType<String>(value)); break;
      case 'font': font = castToType<String>(value); break;
      case 'strokeStyle':
        Color? color = CSSColor.parseColor(castToType<String>(value));
        if (color != null) strokeStyle = color;
        break;
      case 'lineCap': lineCap = parseLineCap(castToType<String>(value)); break;
      // @TODO: Binding should guarantee that input value is determined type, like double or int.
      case 'lineDashOffset': lineDashOffset = castToType<num>(value).toDouble(); break;
      case 'lineJoin': lineJoin = parseLineJoin(castToType<String>(value)); break;
      case 'lineWidth': lineWidth = castToType<num>(value).toDouble(); break;
      case 'miterLimit': miterLimit = castToType<num>(value).toDouble(); break;
      case 'textAlign': textAlign = parseTextAlign(castToType<String>(value)); break;
      case 'textBaseline': textBaseline = parseTextBaseline(castToType<String>(value)); break;
      default: super.setBindingProperty(key, value);
    }
  }

  @override
  getBindingProperty(String key) {
    switch (key) {
      case 'fillStyle': return CSSColor.convertToHex(fillStyle);
      case 'direction': return _textDirectionInString;
      case 'font': return font;
      case 'strokeStyle': return CSSColor.convertToHex(strokeStyle);
      case 'lineCap': return lineCap;
      case 'lineDashOffset': return lineDashOffset;
      case 'lineJoin': return lineJoin;
      case 'lineWidth': return lineWidth;
      case 'miterLimit': return miterLimit;
      case 'textAlign': return textAlign.toString();
      case 'textBaseline': return textBaseline.toString();
      default: return super.getBindingProperty(key);
    }
  }

  final CanvasRenderingContext2DSettings _settings = CanvasRenderingContext2DSettings();

  CanvasRenderingContext2DSettings getContextAttributes() => _settings;

  CanvasElement canvas;
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
  String get _textDirectionInString {
    switch (_direction) {
      case TextDirection.ltr: return 'ltr';
      case TextDirection.rtl: return 'rtl';
    }
  }

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

  void arc(double x, double y, double radius, double startAngle, double endAngle, {bool anticlockwise = false}) {
    addAction((Canvas canvas, Size size) {
      path2d.arc(x, y, radius, startAngle, endAngle, anticlockwise: anticlockwise);
    });
  }

  void arcTo(double x1, double y1, double x2, double y2, double radius) {
    addAction((Canvas canvas, Size size) {
      path2d.arcTo(x1, y1, x2, y2, radius);
    });
  }

  void bezierCurveTo(double cp1x, double cp1y, double cp2x, double cp2y, double x, double y) {
    addAction((Canvas canvas, Size size) {
      path2d.bezierCurveTo(cp1x, cp1y, cp2x, cp2y, x, y);
    });
  }

  void closePath() {
    addAction((Canvas canvas, Size size) {
      path2d.closePath();
    });
  }

  void drawImage(int argumentCount, Image? img, double sx, double sy, double sWidth, double sHeight, double dx, double dy, double dWidth, double dHeight) {
    if (img == null) return;

    addAction((Canvas canvas, Size size) {
      // ctx.drawImage(image, dx, dy);
      if (argumentCount == 3) {
        canvas.drawImage(img, Offset(dx, dy), Paint());
      } else {
        if (argumentCount == 5) {
          // ctx.drawImage(image, dx, dy, dWidth, dHeight);
          sx = 0;
          sy = 0;
          sWidth = img.width.toDouble();
          sHeight = img.height.toDouble();
        }

        canvas.drawImageRect(img,
            Rect.fromLTWH(sx, sy, sWidth, sHeight),
            Rect.fromLTWH(dx, dy, dWidth, dHeight),
            Paint());
      }
    });
  }

  void ellipse(double x, double y, double radiusX, double radiusY, double rotation, double startAngle, double endAngle, {bool anticlockwise = false}) {
    addAction((Canvas canvas, Size size) {
      path2d.ellipse(x, y, radiusX, radiusY, rotation, startAngle, endAngle, anticlockwise: anticlockwise);
    });
  }

  void lineTo(double x, double y) {
    addAction((Canvas canvas, Size size) {
      path2d.lineTo(x, y);
    });
  }

  void moveTo(double x, double y) {
    addAction((Canvas canvas, Size size) {
      path2d.moveTo(x, y);
    });
  }

  void quadraticCurveTo(double cpx, double cpy, double x, double y) {
    addAction((Canvas canvas, Size size) {
      path2d.quadraticCurveTo(cpx, cpy, x, y);
    });
  }

  void rect(double x, double y, double w, double h) {
    addAction((Canvas canvas, Size size) {
      path2d.rect(x, y, w, h);
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
  set lineWidth(double? value) {
    if (value == null) return;
    addAction((Canvas canvas, Size size) {
      _lineWidth = value;
    });
  }
  double get lineWidth => _lineWidth;

  double _miterLimit = 10.0; // (default 10)
  set miterLimit(double? value) {
    if (value == null) return;
    addAction((Canvas canvas, Size size) {
      _miterLimit = value;
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

  void translate(double x, double y) {
    _matrix.translate(x, y);
    addAction((Canvas canvas, Size size) {
      canvas.translate(x, y);
    });
  }

  void rotate(double angle) {
    _matrix.setRotationZ(angle);
    addAction((Canvas canvas, Size size) {
      canvas.rotate(angle);
    });
  }

  // transformations (default transform is the identity matrix)
  void scale(double x, double y) {
    _matrix.scale(x, y);
    addAction((Canvas canvas, Size size) {
      canvas.scale(x, y);
    });
  }

  Matrix4 getTransform() {
    return _matrix;
  }

  // https://github.com/WebKit/WebKit/blob/a77a158d4e2086fbe712e488ed147e8a54d44d3c/Source/WebCore/html/canvas/CanvasRenderingContext2DBase.cpp#L843
  void setTransform(double a, double b, double c, double d, double e, double f) {
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

  void transform(double a, double b, double c, double d, double e, double f) {
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

  void clearRect(double x, double y, double w, double h) {
    Rect rect = Rect.fromLTWH(x, y, w, h);
    addAction((Canvas canvas, Size size) {
      // Must saveLayer before clear avoid there is a "black" background
      Paint paint = Paint()
        ..style = PaintingStyle.fill
        ..blendMode = BlendMode.clear;
      canvas.drawRect(rect, paint);
    });
  }

  void fillRect(double x, double y, double w, double h) {
    Rect rect = Rect.fromLTWH(x, y, w, h);
    addAction((Canvas canvas, Size size) {
      Paint paint = Paint()..color = fillStyle;
      canvas.drawRect(rect, paint);
    });
  }

  void strokeRect(double x, double y, double w, double h) {
    Rect rect = Rect.fromLTWH(x, y, w, h);
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

  void fillText(String text, double x, double y, {double? maxWidth}) {
    addAction((Canvas canvas, Size size) {
      TextPainter textPainter = _getTextPainter(text, fillStyle);
      if (maxWidth != null) {
        // FIXME: should scale down to a smaller font size in order to fit the text in the specified width.
        textPainter.layout(maxWidth: maxWidth);
      } else {
        textPainter.layout();
      }
      // Paint text start with baseline.
      double offsetToBaseline = textPainter.computeDistanceToActualBaseline(TextBaseline.alphabetic);
      textPainter.paint(canvas, Offset(x, y - offsetToBaseline) - _getAlignOffset(textPainter.width));
    });
  }


  void strokeText(String text, double x, double y, {double? maxWidth}) {
    addAction((Canvas canvas, Size size) {
      TextPainter textPainter = _getTextPainter(text, strokeStyle, shouldStrokeText: true);
      if (maxWidth != null) {
        // FIXME: should scale down to a smaller font size in order to fit the text in the specified width.
        textPainter.layout(maxWidth: maxWidth);
      } else {
        textPainter.layout();
      }

      double offsetToBaseline = textPainter.computeDistanceToActualBaseline(TextBaseline.alphabetic);
      // Paint text start with baseline.
      textPainter.paint(canvas, Offset(x, y - offsetToBaseline) - _getAlignOffset(textPainter.width));
    });
  }

  TextMetrics? measureText(String text) {
    // TextPainter textPainter = _getTextPainter(text, fillStyle);
    // TODO: transform textPainter layout info into TextMetrics.
    return null;
  }
}
