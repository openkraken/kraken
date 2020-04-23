/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'package:flutter/rendering.dart';
import 'package:kraken/element.dart';
import 'package:kraken/rendering.dart';
import 'package:kraken/painting.dart';
import 'package:kraken/style.dart';

const String CANVAS = 'CANVAS';
final RegExp SpaceRegExp = RegExp(' ');

class CanvasElement extends Element {
  CanvasElement(int targetId, Map<String, dynamic> props, List<String> events)
      : super(
          targetId: targetId,
          defaultDisplay: 'inline-block',
          allowChildren: false,
          tagName: CANVAS,
          properties: props,
          events: events,
        ) {
    if (style.contains('width')) {
      _width = Length.toDisplayPortValue(style['width']);
    }
    if (style.contains('height')) {
      _height = Length.toDisplayPortValue(style['height']);
    }

    size = Size(_width, _height);
    painter = CanvasPainter();
    renderCustomPaint = getRenderObject();
    addChild(renderCustomPaint);
  }

  /// Default width to 300.0, default height to 150.0
  double _width = 300.0;
  double _height = 150.0;

  /// The painter that paints before the children.
  CanvasPainter painter;

  /// The size that this [CustomPaint] should aim for, given the layout
  /// constraints, if there is no child.
  ///
  /// If there's a child, this is ignored, and the size of the child is used
  /// instead.
  Size size;

  // RenderingContext? getContext(DOMString contextId, optional any options = null);
  CanvasRenderingContext getContext(String contextId,
      {dynamic options = null}) {
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

  void _applyContext2DMethod(List args) {
    // [String method, [...args]]
    _assertPainterExists();
    if (args == null) return;
    if (args.length < 1) return;
    String method = args[0];
    switch (method) {
      case 'fillRect':
        double x = Length.toDouble(args[1]);
        double y = Length.toDouble(args[2]);
        double w = Length.toDouble(args[3]);
        double h = Length.toDouble(args[4]);
        painter.context.fillRect(x, y, w, h);
        break;

      case 'clearRect':
        double x = Length.toDouble(args[1]);
        double y = Length.toDouble(args[2]);
        double w = Length.toDouble(args[3]);
        double h = Length.toDouble(args[4]);
        painter.context.clearRect(x, y, w, h);
        break;

      case 'strokeRect':
        double x = Length.toDouble(args[1]);
        double y = Length.toDouble(args[2]);
        double w = Length.toDouble(args[3]);
        double h = Length.toDouble(args[4]);
        painter.context.strokeRect(x, y, w, h);
        break;

      case 'fillText':
        String text = args[1];
        double x = Length.toDouble(args[2]);
        double y = Length.toDouble(args[3]);
        if (args.length == 5) {
          // optional maxWidth
          double maxWidth = Length.toDouble(args[4]);
          painter.context.fillText(text, x, y, maxWidth: maxWidth);
        } else {
          painter.context.fillText(text, x, y);
        }
        break;

      case 'strokeText':
        String text = args[1];
        double x = Length.toDouble(args[2]);
        double y = Length.toDouble(args[3]);
        if (args.length == 5) {
          // optional maxWidth
          double maxWidth = Length.toDouble(args[4]);
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
        painter.context.fillStyle = WebColor.generate(args[1]);
        break;
      case 'strokeStyle':
        painter.context.strokeStyle = WebColor.generate(args[1]);
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

  RenderCustomPaint renderCustomPaint;
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
