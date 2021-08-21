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
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:kraken/bridge.dart';
import 'package:kraken/css.dart';
import 'package:kraken/dom.dart';
import 'package:vector_math/vector_math_64.dart';
import 'canvas_context.dart';
import 'canvas_path_2d.dart';

final Pointer<NativeFunction<NativeRenderingContextSetProperty>> nativeSetDirection = Pointer.fromFunction(CanvasRenderingContext2D._setDirection);
final Pointer<NativeFunction<NativeRenderingContextSetProperty>> nativeSetFont = Pointer.fromFunction(CanvasRenderingContext2D._setFont);
final Pointer<NativeFunction<NativeRenderingContextSetProperty>> nativeSetFillStyle = Pointer.fromFunction(CanvasRenderingContext2D._setFillStyle);
final Pointer<NativeFunction<NativeRenderingContextSetProperty>> nativeSetStrokeStyle = Pointer.fromFunction(CanvasRenderingContext2D._setStrokeStyle);
final Pointer<NativeFunction<NativeRenderingContextSetProperty>> nativeSetLineCap = Pointer.fromFunction(CanvasRenderingContext2D._setLineCap);
final Pointer<NativeFunction<NativeRenderingContextSetProperty>> nativeSetLineDashOffset = Pointer.fromFunction(CanvasRenderingContext2D._setLineDashOffset);
final Pointer<NativeFunction<NativeRenderingContextSetProperty>> nativeSetLineJoin = Pointer.fromFunction(CanvasRenderingContext2D._setLineJoin);
final Pointer<NativeFunction<NativeRenderingContextSetProperty>> nativeSetLineWidth = Pointer.fromFunction(CanvasRenderingContext2D._setLineWidth);
final Pointer<NativeFunction<NativeRenderingContextSetProperty>> nativeSetMiterLimit = Pointer.fromFunction(CanvasRenderingContext2D._setMiterLimit);
final Pointer<NativeFunction<NativeRenderingContextSetProperty>> nativeSetTextAlign = Pointer.fromFunction(CanvasRenderingContext2D._setTextAlign);
final Pointer<NativeFunction<NativeRenderingContextSetProperty>> nativeSetTextBaseline = Pointer.fromFunction(CanvasRenderingContext2D._setTextBaseline);

final Pointer<NativeFunction<NativeRenderingContextArc>> nativeArc= Pointer.fromFunction(CanvasRenderingContext2D._arc);
final Pointer<NativeFunction<NativeRenderingContextArcTo>> nativeArcTo = Pointer.fromFunction(CanvasRenderingContext2D._arcTo);
final Pointer<NativeFunction<NativeRenderingContextFillRect>> nativeFillRect = Pointer.fromFunction(CanvasRenderingContext2D._fillRect);
final Pointer<NativeFunction<NativeRenderingContextBeginPath>> nativeBeginPath = Pointer.fromFunction(CanvasRenderingContext2D._beginPath);
final Pointer<NativeFunction<NativeRenderingContextBezierCurveTo>> nativeBezierCurveTo = Pointer.fromFunction(CanvasRenderingContext2D._bezierCurveTo);
final Pointer<NativeFunction<NativeRenderingContextClip>> nativeClip = Pointer.fromFunction(CanvasRenderingContext2D._clip);
final Pointer<NativeFunction<NativeRenderingContextClearRect>> nativeClearRect = Pointer.fromFunction(CanvasRenderingContext2D._clearRect);
final Pointer<NativeFunction<NativeRenderingContextClosePath>> nativeClosePath = Pointer.fromFunction(CanvasRenderingContext2D._closePath);
final Pointer<NativeFunction<NativeRenderingContextDrawImage>> nativeDrawImage = Pointer.fromFunction(CanvasRenderingContext2D._drawImage);
final Pointer<NativeFunction<NativeRenderingContextEllipse>> nativeEllipse = Pointer.fromFunction(CanvasRenderingContext2D._ellipse);
final Pointer<NativeFunction<NativeRenderingContextFill>> nativeFill = Pointer.fromFunction(CanvasRenderingContext2D._fill);
final Pointer<NativeFunction<NativeRenderingContextFillText>> nativeFillText = Pointer.fromFunction(CanvasRenderingContext2D._fillText);
final Pointer<NativeFunction<NativeRenderingContextLineTo>> nativeLineTo = Pointer.fromFunction(CanvasRenderingContext2D._lineTo);
final Pointer<NativeFunction<NativeRenderingContextMoveTo>> nativeMoveTo = Pointer.fromFunction(CanvasRenderingContext2D._moveTo);
final Pointer<NativeFunction<NativeRenderingContextQuadraticCurveTo>> nativeQuadraticCurveTo = Pointer.fromFunction(CanvasRenderingContext2D._quadraticCurveTo);
final Pointer<NativeFunction<NativeRenderingContextRect>> nativeRect = Pointer.fromFunction(CanvasRenderingContext2D._rect);
final Pointer<NativeFunction<NativeRenderingContextRestore>> nativeRestore = Pointer.fromFunction(CanvasRenderingContext2D._restore);
final Pointer<NativeFunction<NativeRenderingContextRotate>> nativeRotate = Pointer.fromFunction(CanvasRenderingContext2D._rotate);
final Pointer<NativeFunction<NativeRenderingContextResetTransform>> nativeResetTransform = Pointer.fromFunction(CanvasRenderingContext2D._resetTransform);
final Pointer<NativeFunction<NativeRenderingContextSave>> nativeSave = Pointer.fromFunction(CanvasRenderingContext2D._save);
final Pointer<NativeFunction<NativeRenderingContextScale>> nativeScale = Pointer.fromFunction(CanvasRenderingContext2D._scale);
final Pointer<NativeFunction<NativeRenderingContextStroke>> nativeStroke = Pointer.fromFunction(CanvasRenderingContext2D._stroke);
final Pointer<NativeFunction<NativeRenderingContextStrokeText>> nativeStrokeText = Pointer.fromFunction(CanvasRenderingContext2D._strokeText);
final Pointer<NativeFunction<NativeRenderingContextStrokeRect>> nativeStrokeRect = Pointer.fromFunction(CanvasRenderingContext2D._strokeRect);
final Pointer<NativeFunction<NativeRenderingContextSetTransform>> nativeSetTransform = Pointer.fromFunction(CanvasRenderingContext2D._setTransform);
final Pointer<NativeFunction<NativeRenderingContextTransform>> nativeTransform = Pointer.fromFunction(CanvasRenderingContext2D._transform);
final Pointer<NativeFunction<NativeRenderingContextTranslate>> nativeTranslate = Pointer.fromFunction(CanvasRenderingContext2D._translate);

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

class CanvasRenderingContext2D {
  final Pointer<NativeCanvasRenderingContext2D> nativeCanvasRenderingContext2D;

  CanvasRenderingContext2D() : nativeCanvasRenderingContext2D = malloc.allocate<NativeCanvasRenderingContext2D>(sizeOf<NativeCanvasRenderingContext2D>()) {
    _settings = CanvasRenderingContext2DSettings();

    _nativeMap[nativeCanvasRenderingContext2D.address] = this;

    nativeCanvasRenderingContext2D.ref.setDirection = nativeSetDirection;
    nativeCanvasRenderingContext2D.ref.setFont = nativeSetFont;
    nativeCanvasRenderingContext2D.ref.setFillStyle = nativeSetFillStyle;
    nativeCanvasRenderingContext2D.ref.setStrokeStyle = nativeSetStrokeStyle;
    nativeCanvasRenderingContext2D.ref.setLineCap = nativeSetLineCap;
    nativeCanvasRenderingContext2D.ref.setLineDashOffset = nativeSetLineDashOffset;
    nativeCanvasRenderingContext2D.ref.setLineJoin = nativeSetLineJoin;
    nativeCanvasRenderingContext2D.ref.setLineWidth = nativeSetLineWidth;
    nativeCanvasRenderingContext2D.ref.setMiterLimit = nativeSetMiterLimit;
    nativeCanvasRenderingContext2D.ref.setTextAlign = nativeSetTextAlign;
    nativeCanvasRenderingContext2D.ref.setTextBaseline = nativeSetTextBaseline;

    nativeCanvasRenderingContext2D.ref.arc = nativeArc;
    nativeCanvasRenderingContext2D.ref.arcTo = nativeArcTo;
    nativeCanvasRenderingContext2D.ref.beginPath = nativeBeginPath;
    nativeCanvasRenderingContext2D.ref.bezierCurveTo = nativeBezierCurveTo;
    nativeCanvasRenderingContext2D.ref.clearRect = nativeClearRect;
    nativeCanvasRenderingContext2D.ref.clip = nativeClip;
    nativeCanvasRenderingContext2D.ref.closePath = nativeClosePath;
    nativeCanvasRenderingContext2D.ref.drawImage = nativeDrawImage;
    nativeCanvasRenderingContext2D.ref.ellipse = nativeEllipse;
    nativeCanvasRenderingContext2D.ref.fill = nativeFill;
    nativeCanvasRenderingContext2D.ref.fillRect = nativeFillRect;
    nativeCanvasRenderingContext2D.ref.fillText = nativeFillText;
    nativeCanvasRenderingContext2D.ref.lineTo = nativeLineTo;
    nativeCanvasRenderingContext2D.ref.moveTo = nativeMoveTo;
    nativeCanvasRenderingContext2D.ref.quadraticCurveTo = nativeQuadraticCurveTo;
    nativeCanvasRenderingContext2D.ref.rect = nativeRect;
    nativeCanvasRenderingContext2D.ref.rotate = nativeRotate;
    nativeCanvasRenderingContext2D.ref.restore = nativeRestore;
    nativeCanvasRenderingContext2D.ref.resetTransform = nativeResetTransform;
    nativeCanvasRenderingContext2D.ref.scale = nativeScale;
    nativeCanvasRenderingContext2D.ref.stroke = nativeStroke;
    nativeCanvasRenderingContext2D.ref.strokeText = nativeStrokeText;
    nativeCanvasRenderingContext2D.ref.strokeRect = nativeStrokeRect;
    nativeCanvasRenderingContext2D.ref.save = nativeSave;
    nativeCanvasRenderingContext2D.ref.setTransform = nativeSetTransform;
    nativeCanvasRenderingContext2D.ref.transform = nativeTransform;
    nativeCanvasRenderingContext2D.ref.translate = nativeTranslate;
  }

  static final SplayTreeMap<int, CanvasRenderingContext2D> _nativeMap = SplayTreeMap();

  static CanvasRenderingContext2D getCanvasRenderContext2DOfNativePtr(Pointer<NativeCanvasRenderingContext2D> nativePtr) {
    CanvasRenderingContext2D? renderingContext = _nativeMap[nativePtr.address];
    if (renderingContext == null) throw FlutterError('Can not get nativeRenderingContext2D from pointer: $nativePtr');
    return renderingContext;
  }

  void dispose() {
    _nativeMap.remove(nativeCanvasRenderingContext2D.address);
  }

  static void _setDirection(Pointer<NativeCanvasRenderingContext2D> nativePtr, Pointer<NativeString> value) {
    CanvasRenderingContext2D canvasRenderingContext2D = getCanvasRenderContext2DOfNativePtr(nativePtr);
    canvasRenderingContext2D.direction = parseDirection(nativeStringToString(value));
  }

  static void _setFont(Pointer<NativeCanvasRenderingContext2D> nativePtr, Pointer<NativeString> value) {
    CanvasRenderingContext2D canvasRenderingContext2D = getCanvasRenderContext2DOfNativePtr(nativePtr);
    canvasRenderingContext2D.font = nativeStringToString(value);
  }

  static void _setFillStyle(Pointer<NativeCanvasRenderingContext2D> nativePtr, Pointer<NativeString> value) {
    CanvasRenderingContext2D canvasRenderingContext2D = getCanvasRenderContext2DOfNativePtr(nativePtr);
    Color? color = CSSColor.parseColor(nativeStringToString(value));
    if (color != null) canvasRenderingContext2D.fillStyle = color;
  }

  static void _setStrokeStyle(Pointer<NativeCanvasRenderingContext2D> nativePtr, Pointer<NativeString> value) {
    CanvasRenderingContext2D canvasRenderingContext2D = getCanvasRenderContext2DOfNativePtr(nativePtr);
    Color? color = CSSColor.parseColor(nativeStringToString(value));
    if (color != null) canvasRenderingContext2D.strokeStyle = color;
  }

  static void _setLineCap(Pointer<NativeCanvasRenderingContext2D> nativePtr, Pointer<NativeString> value) {
    CanvasRenderingContext2D canvasRenderingContext2D = getCanvasRenderContext2DOfNativePtr(nativePtr);
    canvasRenderingContext2D.lineCap = parseLineCap(nativeStringToString(value));
  }

  static void _setLineDashOffset(Pointer<NativeCanvasRenderingContext2D> nativePtr, Pointer<NativeString> value) {
    CanvasRenderingContext2D canvasRenderingContext2D = getCanvasRenderContext2DOfNativePtr(nativePtr);
    double? _v = double.tryParse(nativeStringToString(value));
    if (_v != null) canvasRenderingContext2D.lineDashOffset = _v;
  }

  static void _setLineJoin(Pointer<NativeCanvasRenderingContext2D> nativePtr, Pointer<NativeString> value) {
    CanvasRenderingContext2D canvasRenderingContext2D = getCanvasRenderContext2DOfNativePtr(nativePtr);
    canvasRenderingContext2D.lineJoin = parseLineJoin(nativeStringToString(value));
  }

  static void _setLineWidth(Pointer<NativeCanvasRenderingContext2D> nativePtr, Pointer<NativeString> value) {
    CanvasRenderingContext2D canvasRenderingContext2D = getCanvasRenderContext2DOfNativePtr(nativePtr);
    double? _v = double.tryParse(nativeStringToString(value));
    if (_v != null) canvasRenderingContext2D.lineWidth = _v;
  }

  static void _setMiterLimit(Pointer<NativeCanvasRenderingContext2D> nativePtr, Pointer<NativeString> value) {
    CanvasRenderingContext2D canvasRenderingContext2D = getCanvasRenderContext2DOfNativePtr(nativePtr);
    double? _v = double.tryParse(nativeStringToString(value));
    if (_v != null) canvasRenderingContext2D.miterLimit = _v;
  }

  static void _setTextAlign(Pointer<NativeCanvasRenderingContext2D> nativePtr, Pointer<NativeString> value) {
    CanvasRenderingContext2D canvasRenderingContext2D = getCanvasRenderContext2DOfNativePtr(nativePtr);
    canvasRenderingContext2D.textAlign = parseTextAlign(nativeStringToString(value));
  }

  static void _setTextBaseline(Pointer<NativeCanvasRenderingContext2D> nativePtr, Pointer<NativeString> value) {
    CanvasRenderingContext2D canvasRenderingContext2D = getCanvasRenderContext2DOfNativePtr(nativePtr);
    canvasRenderingContext2D.textBaseline = parseTextBaseline(nativeStringToString(value));
  }

  static void _arc(Pointer<NativeCanvasRenderingContext2D> nativePtr, double x, double y, double radius, double startAngle, double endAngle, double counterclockwise) {
    CanvasRenderingContext2D canvasRenderingContext2D = getCanvasRenderContext2DOfNativePtr(nativePtr);
    canvasRenderingContext2D.arc(x, y, radius, startAngle, endAngle, anticlockwise : counterclockwise == 1 ? true : false);
  }

  static void _arcTo(Pointer<NativeCanvasRenderingContext2D> nativePtr, double x1, double y1, double x2, double y2, double radius) {
    CanvasRenderingContext2D canvasRenderingContext2D = getCanvasRenderContext2DOfNativePtr(nativePtr);
    canvasRenderingContext2D.arcTo(x1, y1, x2, y2, radius);
  }

  static void _fillRect(Pointer<NativeCanvasRenderingContext2D> nativePtr, double x, double y, double width, double height) {
    CanvasRenderingContext2D canvasRenderingContext2D = getCanvasRenderContext2DOfNativePtr(nativePtr);
    canvasRenderingContext2D.fillRect(x, y, width, height);
  }

  static void _clearRect(Pointer<NativeCanvasRenderingContext2D> nativePtr, double x, double y, double width, double height) {
    CanvasRenderingContext2D canvasRenderingContext2D = getCanvasRenderContext2DOfNativePtr(nativePtr);
    canvasRenderingContext2D.clearRect(x, y, width, height);
  }

  static void _strokeRect(Pointer<NativeCanvasRenderingContext2D> nativePtr, double x, double y, double width, double height) {
    CanvasRenderingContext2D canvasRenderingContext2D = getCanvasRenderContext2DOfNativePtr(nativePtr);
    canvasRenderingContext2D.strokeRect(x, y, width, height);
  }

  static void _fillText(Pointer<NativeCanvasRenderingContext2D> nativePtr, Pointer<NativeString> text, double x, double y, double maxWidth) {
    CanvasRenderingContext2D canvasRenderingContext2D = getCanvasRenderContext2DOfNativePtr(nativePtr);
    if (!maxWidth.isNaN) {
      canvasRenderingContext2D.fillText(nativeStringToString(text), x, y, maxWidth: maxWidth);
    } else {
      canvasRenderingContext2D.fillText(nativeStringToString(text), x, y);
    }
  }

  static void _strokeText(Pointer<NativeCanvasRenderingContext2D> nativePtr, Pointer<NativeString> text,
                          double x, double y, double maxWidth) {
    CanvasRenderingContext2D canvasRenderingContext2D = getCanvasRenderContext2DOfNativePtr(nativePtr);
    if (!maxWidth.isNaN) {
      canvasRenderingContext2D.strokeText(nativeStringToString(text), x, y, maxWidth: maxWidth);
    } else {
      canvasRenderingContext2D.strokeText(nativeStringToString(text), x, y);
    }
  }

  static void _save(Pointer<NativeCanvasRenderingContext2D> nativePtr) {
    CanvasRenderingContext2D canvasRenderingContext2D = getCanvasRenderContext2DOfNativePtr(nativePtr);
    canvasRenderingContext2D.save();
  }

  static void _restore(Pointer<NativeCanvasRenderingContext2D> nativePtr) {
    CanvasRenderingContext2D canvasRenderingContext2D = getCanvasRenderContext2DOfNativePtr(nativePtr);
    canvasRenderingContext2D.restore();
  }

  static void _beginPath(Pointer<NativeCanvasRenderingContext2D> nativePtr) {
    CanvasRenderingContext2D canvasRenderingContext2D = getCanvasRenderContext2DOfNativePtr(nativePtr);
    canvasRenderingContext2D.beginPath();
  }

  static void _bezierCurveTo(Pointer<NativeCanvasRenderingContext2D> nativePtr, double x1, double y1,
                            double x2, double y2, double x, double y) {
    CanvasRenderingContext2D canvasRenderingContext2D = getCanvasRenderContext2DOfNativePtr(nativePtr);
    canvasRenderingContext2D.bezierCurveTo(x1, y1, x2, y2, x, y);
  }

  static void _clip(Pointer<NativeCanvasRenderingContext2D> nativePtr, Pointer<NativeString> fillRule) {
    CanvasRenderingContext2D canvasRenderingContext2D = getCanvasRenderContext2DOfNativePtr(nativePtr);

    PathFillType fillType = nativeStringToString(fillRule) == EVENODD ? PathFillType.evenOdd : PathFillType.nonZero;
    canvasRenderingContext2D.clip(fillType);
  }

  static void _closePath(Pointer<NativeCanvasRenderingContext2D> nativePtr) {
    CanvasRenderingContext2D canvasRenderingContext2D = getCanvasRenderContext2DOfNativePtr(nativePtr);
    canvasRenderingContext2D.closePath();
  }

  // https://developer.mozilla.org/en-US/docs/Web/API/CanvasRenderingContext2D/drawImage
  static void _drawImage(Pointer<NativeCanvasRenderingContext2D> nativePtr, int argumentCount, Pointer<NativeImgElement> imagePtr,
      double sx, double sy, double sWidth, double sHeight, double dx, double dy, double dWidth, double dHeight) {
    ImageElement imageElement = ImageElement.getImageElementOfNativePtr(imagePtr);
    CanvasRenderingContext2D canvasRenderingContext2D = getCanvasRenderContext2DOfNativePtr(nativePtr);
    canvasRenderingContext2D.drawImage(argumentCount, imageElement.image, sx, sy, sWidth, sHeight, dx, dy, dWidth, dHeight);
  }

  static void _ellipse(Pointer<NativeCanvasRenderingContext2D> nativePtr, double x, double y,
                      double radiusX, double radiusY, double rotation, double startAngle, double endAngle,
                      double counterclockwise) {
    CanvasRenderingContext2D canvasRenderingContext2D = getCanvasRenderContext2DOfNativePtr(nativePtr);
    canvasRenderingContext2D.ellipse(x, y, radiusX, radiusY, rotation, startAngle, endAngle, anticlockwise : counterclockwise == 1 ? true : false);
  }

  static void _fill(Pointer<NativeCanvasRenderingContext2D> nativePtr, Pointer<NativeString> fillRule) {
    CanvasRenderingContext2D canvasRenderingContext2D = getCanvasRenderContext2DOfNativePtr(nativePtr);
    PathFillType fillType = nativeStringToString(fillRule) == EVENODD ? PathFillType.evenOdd : PathFillType.nonZero;

    canvasRenderingContext2D.fill(fillType);
  }

  static void _lineTo(Pointer<NativeCanvasRenderingContext2D> nativePtr, double x, double y) {
    CanvasRenderingContext2D canvasRenderingContext2D = getCanvasRenderContext2DOfNativePtr(nativePtr);
    canvasRenderingContext2D.lineTo(x, y);
  }

  static void _moveTo(Pointer<NativeCanvasRenderingContext2D> nativePtr, double x, double y) {
    CanvasRenderingContext2D canvasRenderingContext2D = getCanvasRenderContext2DOfNativePtr(nativePtr);
    canvasRenderingContext2D.moveTo(x, y);
  }

  static void _quadraticCurveTo(Pointer<NativeCanvasRenderingContext2D> nativePtr, double cpx, double cpy,
                                double x, double y) {
    CanvasRenderingContext2D canvasRenderingContext2D = getCanvasRenderContext2DOfNativePtr(nativePtr);
    canvasRenderingContext2D.quadraticCurveTo(cpx, cpy, x, y);
  }

  static void _rect(Pointer<NativeCanvasRenderingContext2D> nativePtr, double x, double y,
                    double width, double height) {
    CanvasRenderingContext2D canvasRenderingContext2D = getCanvasRenderContext2DOfNativePtr(nativePtr);
    canvasRenderingContext2D.rect(x, y, width, height);
  }

  static void _rotate(Pointer<NativeCanvasRenderingContext2D> nativePtr, double angle) {
    CanvasRenderingContext2D canvasRenderingContext2D = getCanvasRenderContext2DOfNativePtr(nativePtr);
    canvasRenderingContext2D.rotate(angle);
  }

  static void _resetTransform(Pointer<NativeCanvasRenderingContext2D> nativePtr) {
    CanvasRenderingContext2D canvasRenderingContext2D = getCanvasRenderContext2DOfNativePtr(nativePtr);
    canvasRenderingContext2D.resetTransform();
  }

  static void _scale(Pointer<NativeCanvasRenderingContext2D> nativePtr, double x, double y) {
    CanvasRenderingContext2D canvasRenderingContext2D = getCanvasRenderContext2DOfNativePtr(nativePtr);
    canvasRenderingContext2D.scale(x, y);
  }

  static void _stroke(Pointer<NativeCanvasRenderingContext2D> nativePtr) {
    CanvasRenderingContext2D canvasRenderingContext2D = getCanvasRenderContext2DOfNativePtr(nativePtr);
    canvasRenderingContext2D.stroke();
  }

  static void _setTransform(Pointer<NativeCanvasRenderingContext2D> nativePtr, double a, double b, double c, double d, double e, double f) {
    CanvasRenderingContext2D canvasRenderingContext2D = getCanvasRenderContext2DOfNativePtr(nativePtr);
    canvasRenderingContext2D.setTransform(a, b, c, d, e, f);
  }

  static void _transform(Pointer<NativeCanvasRenderingContext2D> nativePtr, double a, double b, double c, double d, double e, double f) {
    CanvasRenderingContext2D canvasRenderingContext2D = getCanvasRenderContext2DOfNativePtr(nativePtr);
    canvasRenderingContext2D.transform(a, b, c, d, e, f);
  }

  static void _translate(Pointer<NativeCanvasRenderingContext2D> nativePtr, double x, double y) {
    CanvasRenderingContext2D canvasRenderingContext2D = getCanvasRenderContext2DOfNativePtr(nativePtr);
    canvasRenderingContext2D.translate(x, y);
  }

  late CanvasRenderingContext2DSettings _settings;

  CanvasRenderingContext2DSettings getContextAttributes() => _settings;

  late Size viewportSize;
  late double? fontSize;
  late double? rootFontSize;
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
  void performActions(Canvas _canvas, Size _size) {
    // HACK: Must sync transform first because each paint will saveLayer and restore that make the transform not effect
    if (!_lastMatrix.isIdentity()) {
      _canvas.transform(_lastMatrix.storage);
    }
    for (int i = 0; i < _actions.length; i++) {
      _actions[i](_canvas, _size);
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
  bool _parseFont(String newValue) {
    Map<String, String?> properties = {};
    CSSStyleProperty.setShorthandFont(properties, newValue);
    if (properties.isEmpty) return false;
    _fontProperties = properties;
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
    double? _fontSize = CSSLength.toDisplayPortValue(
      _fontProperties[FONT_SIZE] ?? '10px',
      viewportSize: viewportSize,
      rootFontSize: rootFontSize,
      fontSize: fontSize
    );
    var fontFamilyFallback = CSSText.parseFontFamilyFallback(_fontProperties[FONT_FAMILY] ?? 'sans-serif');
    FontWeight fontWeight = CSSText.parseFontWeight(_fontProperties[FONT_WEIGHT]);
    if (shouldStrokeText) {
      return TextStyle(
          fontSize: _fontSize,
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
