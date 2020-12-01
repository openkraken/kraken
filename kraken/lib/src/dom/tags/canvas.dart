/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'package:flutter/rendering.dart';
import 'package:kraken/dom.dart';
import 'package:kraken/rendering.dart';
import 'package:kraken/painting.dart';
import 'package:kraken/css.dart';

const String CANVAS = 'CANVAS';
const double ELEMENT_DEFAULT_WIDTH_IN_PIXEL = 300.0;
const double ELEMENT_DEFAULT_HEIGHT_IN_PIXEL = 150.0;

const Map<String, dynamic> _defaultStyle = {
  DISPLAY: INLINE_BLOCK,
};

class RenderCanvasPaint extends RenderCustomPaint {
  @override
  bool get isRepaintBoundary => true;

  RenderCanvasPaint({ CustomPainter painter, Size preferredSize }) : super(
    painter: painter,
    foregroundPainter: null, // Ignore foreground painter
    preferredSize: preferredSize,
  );
}

class CanvasElement extends Element {
  /// The painter that paints before the children.
  final CanvasPainter painter = CanvasPainter();

  // The custom paint render object.
  RenderCustomPaint renderCustomPaint;

  CanvasElement(int targetId, ElementManager elementManager)
      : super(
          targetId,
          elementManager,
          defaultStyle: _defaultStyle,
          isIntrinsicBox: true,
          repaintSelf: true,
          tagName: CANVAS,
        );

  @override
  void willAttachRenderer() {
    super.willAttachRenderer();
    renderCustomPaint = RenderCanvasPaint(
      painter: painter,
      preferredSize: size,
    );

    addChild(renderCustomPaint);
    style.addStyleChangeListener(_styleChangedListener);
  }


  @override
  void didDetachRenderer() {
    super.didDetachRenderer();
    style.removeStyleChangeListener(_styleChangedListener);
    painter.dispose();
    renderCustomPaint = null;
  }

  // RenderingContext? getContext(DOMString contextId, optional any options = null);
  CanvasRenderingContext getContext(String contextId, {dynamic options}) {
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

  /// The size that this [CustomPaint] should aim for, given the layout
  /// constraints, if there is no child.
  ///
  /// If there's a child, this is ignored, and the size of the child is used
  /// instead.
  Size get size {
    double width;
    double height;

    double styleWidth = renderBoxModel.width;
    double styleHeight = renderBoxModel.height;

    if (styleWidth != null) {
      width = styleWidth;
    }

    if (styleHeight != null) {
      height = styleHeight;
    }

    // [_attrWidth/_attrHeight] has default value, should not be null.
    if (height == null && width == null) {
      width = _attrWidth;
      height = _attrHeight;
    } else if (width == null && height != null) {
      width = _attrHeight / height * _attrWidth;
    } else if (width != null && height == null) {
      height = _attrWidth / width * _attrHeight;
    }

    return Size(width, height);
  }

  void resize() {
    if (renderCustomPaint != null) {
      // https://html.spec.whatwg.org/multipage/canvas.html#concept-canvas-set-bitmap-dimensions
      final Size paintingBounding = size;
      renderCustomPaint.preferredSize = paintingBounding;

      // The intrinsic dimensions of the canvas element when it represents embedded content are
      // equal to the dimensions of the element’s bitmap.
      // A canvas element can be sized arbitrarily by a style sheet, its bitmap is then subject
      // to the object-fit CSS property.
      // @TODO: CSS object-fit for canvas.
      // To fill (default value of object-fit) the bitmap content, use scale to get the same performed.
      double styleWidth = renderBoxModel.width;
      double styleHeight = renderBoxModel.height;

      double scaleX;
      double scaleY;
      if (styleWidth != null) {
        scaleX = paintingBounding.width / _attrWidth;
      }
      if (styleHeight != null) {
        scaleY = paintingBounding.height / _attrHeight;
      }
      if (painter.scaleX != scaleX || painter.scaleY != scaleY) {
        painter
          ..scaleX = scaleX
          ..scaleY = scaleY;
        if (painter.shouldRepaint(painter)) {
          renderCustomPaint.markNeedsPaint();
        }
      }
    }
  }

  /// Element attribute width
  double _attrWidth = ELEMENT_DEFAULT_WIDTH_IN_PIXEL;
  double get attrWidth => _attrWidth;
  set attrWidth(double value) {
    if (value != null && value != _attrWidth) {
      _attrWidth = value;
      resize();
    }
  }

  /// Element attribute height
  double _attrHeight = ELEMENT_DEFAULT_HEIGHT_IN_PIXEL;
  double get attrHeight => _attrHeight;
  set attrHeight(double value) {
    if (value != null && value != _attrHeight) {
      _attrHeight = value;
      resize();
    }
  }

  void _styleChangedListener(String key, String original, String present, bool inAnimation) {
    switch (key) {
      case 'width':
      case 'height':
        resize();
        break;
    }
  }

  void _applyContext2DMethod(List args) {
    // [String method, [...args]]
    if (args == null) return;
    if (args.length < 1) return;
    String method = args[0];
    switch (method) {
      case 'fillRect':
        double x = CSSLength.toDouble(args[1]) ?? 0.0;
        double y = CSSLength.toDouble(args[2]) ?? 0.0;
        double w = CSSLength.toDouble(args[3]) ?? 0.0;
        double h = CSSLength.toDouble(args[4]) ?? 0.0;
        painter.context.fillRect(x, y, w, h);
        break;

      case 'clearRect':
        double x = CSSLength.toDouble(args[1]) ?? 0.0;
        double y = CSSLength.toDouble(args[2]) ?? 0.0;
        double w = CSSLength.toDouble(args[3]) ?? 0.0;
        double h = CSSLength.toDouble(args[4]) ?? 0.0;
        painter.context.clearRect(x, y, w, h);
        break;

      case 'strokeRect':
        double x = CSSLength.toDouble(args[1]) ?? 0.0;
        double y = CSSLength.toDouble(args[2]) ?? 0.0;
        double w = CSSLength.toDouble(args[3]) ?? 0.0;
        double h = CSSLength.toDouble(args[4]) ?? 0.0;
        painter.context.strokeRect(x, y, w, h);
        break;

      case 'fillText':
        String text = args[1];
        double x = CSSLength.toDouble(args[2]) ?? 0.0;
        double y = CSSLength.toDouble(args[3]) ?? 0.0;
        if (args.length == 5) {
          // optional maxWidth
          double maxWidth = CSSLength.toDouble(args[4]) ?? 0.0;
          painter.context.fillText(text, x, y, maxWidth: maxWidth);
        } else {
          painter.context.fillText(text, x, y);
        }
        break;

      case 'strokeText':
        String text = args[1];
        double x = CSSLength.toDouble(args[2]) ?? 0.0;
        double y = CSSLength.toDouble(args[3]) ?? 0.0;
        if (args.length == 5) {
          // optional maxWidth
          double maxWidth = CSSLength.toDouble(args[4]) ?? 0.0;
          painter.context.strokeText(text, x, y, maxWidth: maxWidth);
        } else {
          painter.context.strokeText(text, x, y);
        }
        break;
    }

    if (renderCustomPaint != null) {
      renderCustomPaint.markNeedsPaint();
    }
  }

  void _updateContext2DProperty(List args) {
    // [String method, [...args]]
    if (args == null) return;
    if (args.length < 1) return;
    String property = args[0];
    switch (property) {
      case 'fillStyle':
        painter.context.fillStyle = CSSColor.parseColor(args[1]);
        break;
      case 'strokeStyle':
        painter.context.strokeStyle = CSSColor.parseColor(args[1]);
        break;
      case 'font':
        painter.context.font = args[1];
        break;
    }
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

  @override
  void setProperty(String key, value) {
    super.setProperty(key, value);
    switch (key) {
      case WIDTH:
        attrWidth = CSSLength.toDisplayPortValue('$value${CSSLength.PX}');
        break;
      case HEIGHT:
        attrHeight = CSSLength.toDisplayPortValue('$value${CSSLength.PX}');
        break;
    }
  }
}
