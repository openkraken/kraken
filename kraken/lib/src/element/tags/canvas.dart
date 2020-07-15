/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'package:flutter/rendering.dart';
import 'package:kraken/element.dart';
import 'package:kraken/rendering.dart';
import 'package:kraken/painting.dart';
import 'package:kraken/css.dart';

const String CANVAS = 'CANVAS';

const Map<String, dynamic> _defaultStyle = {
  'display': 'inline-block',
  'width': ELEMENT_DEFAULT_WIDTH,
  'height': ELEMENT_DEFAULT_HEIGHT,
};

class CanvasElement extends Element {
  CanvasElement(int targetId, ElementManager elementManager)
      : super(
          targetId,
          elementManager,
          defaultStyle: _defaultStyle,
          isIntrinsicBox: true,
          tagName: CANVAS,
        ) {
    painter = CanvasPainter();
    _width = CSSLength(ELEMENT_DEFAULT_WIDTH).computedValue;
    _height = CSSLength(ELEMENT_DEFAULT_HEIGHT).computedValue;

    renderCustomPaint = RenderCustomPaint(
      painter: painter,
      foregroundPainter: null, // Ignore foreground painter
      preferredSize: Size(_width, _height), // Default size
    );

    style.addStyleChangeListener(_propertyChangedListener);
    addChild(renderCustomPaint);
  }

  /// The painter that paints before the children.
  CanvasPainter painter;

  /// The size that this [CustomPaint] should aim for, given the layout
  /// constraints, if there is no child.
  ///
  /// If there's a child, this is ignored, and the size of the child is used
  /// instead.
  Size size;

  RenderCustomPaint renderCustomPaint;

  // RenderingContext? getContext(DOMString contextId, optional any options = null);
  CanvasRenderingContext getContext(String contextId, {dynamic options = null}) {
    switch (contextId) {
      case '2d':
        if (painter.context == null) {
          painter.context = CanvasRenderingContext2D();
        }
        return painter.context;
      default:
        throw FlutterError('CanvasRenderingContext $contextId not supported!');
    }
  }

  /// Element attribute width
  double _width = 0;
  double get width => _width;
  set width(double newValue) {
    if (newValue != null) {
      _width = newValue;
      renderCustomPaint.preferredSize = Size(_width, _height);
    }
  }

  /// Element attribute height
  double _height = 0;
  double get height => _height;
  set height(double newValue) {
    if (newValue != null) {
      _height = newValue;
      renderCustomPaint.preferredSize = Size(_width, _height);
    }
  }

  void _propertyChangedListener(String key, String original, String present) {
    switch (key) {
      case 'width':
        // Trigger width setter to invoke rerender.
        width = CSSLength.toDisplayPortValue(present) ?? width;
        break;
      case 'height':
        // Trigger height setter to invoke rerender.
        height = CSSLength.toDisplayPortValue(present) ?? height;
        break;
      default:
    }
  }

  void _applyContext2DMethod(List args) {
    // [String method, [...args]]
    _assertPainterExists();
    if (args == null) return;
    if (args.length < 1) return;
    String method = args[0];
    switch (method) {
      case 'fillRect':
        double x = CSSLength.toDouble(args[1]);
        double y = CSSLength.toDouble(args[2]);
        double w = CSSLength.toDouble(args[3]);
        double h = CSSLength.toDouble(args[4]);
        painter.context.fillRect(x, y, w, h);
        break;

      case 'clearRect':
        double x = CSSLength.toDouble(args[1]);
        double y = CSSLength.toDouble(args[2]);
        double w = CSSLength.toDouble(args[3]);
        double h = CSSLength.toDouble(args[4]);
        painter.context.clearRect(x, y, w, h);
        break;

      case 'strokeRect':
        double x = CSSLength.toDouble(args[1]);
        double y = CSSLength.toDouble(args[2]);
        double w = CSSLength.toDouble(args[3]);
        double h = CSSLength.toDouble(args[4]);
        painter.context.strokeRect(x, y, w, h);
        break;

      case 'fillText':
        String text = args[1];
        double x = CSSLength.toDouble(args[2]);
        double y = CSSLength.toDouble(args[3]);
        if (args.length == 5) {
          // optional maxWidth
          double maxWidth = CSSLength.toDouble(args[4]);
          painter.context.fillText(text, x, y, maxWidth: maxWidth);
        } else {
          painter.context.fillText(text, x, y);
        }
        break;

      case 'strokeText':
        String text = args[1];
        double x = CSSLength.toDouble(args[2]);
        double y = CSSLength.toDouble(args[3]);
        if (args.length == 5) {
          // optional maxWidth
          double maxWidth = CSSLength.toDouble(args[4]);
          painter.context.strokeText(text, x, y, maxWidth: maxWidth);
        } else {
          painter.context.strokeText(text, x, y);
        }
        break;
    }

    renderCustomPaint.markNeedsPaint();
  }

  void _updateContext2DProperty(List args) {
    // [String method, [...args]]
    _assertPainterExists();
    if (args == null) return;
    if (args.length < 1) return;
    String property = args[0];
    switch (property) {
      case 'fillStyle':
        painter.context.fillStyle = CSSColor.generate(args[1]);
        break;
      case 'strokeStyle':
        painter.context.strokeStyle = CSSColor.generate(args[1]);
        break;
      case 'font':
        painter.context.font = args[1];
        break;
    }
  }

  void _assertPainterExists() {
    if (painter == null) {
      throw new FlutterError('Canvas painter not exists, get canvas context first.');
    }
  }

  RenderCustomPaint getRenderObject() {
    return RenderCustomPaint(
      painter: painter,
      foregroundPainter: null, // Ignore foreground painter
      preferredSize: size,
    );
  }

  @override
  method(String name, List args) {
    if (name == 'getContext') {
      return getContext(args[0]);
    } else if (name == 'applyContext2DMethod') {
      return _applyContext2DMethod(args);
    } else if (name == 'updateContext2DProperty') {
      return _updateContext2DProperty(args);
    } else {
      return super.method(name, args);
    }
  }
}
