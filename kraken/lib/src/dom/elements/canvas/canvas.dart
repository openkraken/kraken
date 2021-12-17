/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:ffi';

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:kraken/bridge.dart';
import 'package:kraken/css.dart';
import 'package:kraken/dom.dart';
import 'package:kraken/rendering.dart';

import 'canvas_context_2d.dart';

const String CANVAS = 'CANVAS';
const double ELEMENT_DEFAULT_WIDTH_IN_PIXEL = 300.0;
const double ELEMENT_DEFAULT_HEIGHT_IN_PIXEL = 150.0;

const Map<String, dynamic> _defaultStyle = {
  DISPLAY: INLINE_BLOCK,
};

final Pointer<NativeFunction<NativeCanvasGetContext>> nativeGetContext =
    Pointer.fromFunction(CanvasElement._getContext);

class RenderCanvasPaint extends RenderCustomPaint {
  @override
  bool get isRepaintBoundary => true;

  RenderCanvasPaint({required CustomPainter painter, required Size preferredSize})
      : super(
          painter: painter,
          foregroundPainter: null, // Ignore foreground painter
          preferredSize: preferredSize,
        );
}

class CanvasElement extends Element {
  final ChangeNotifier repaintNotifier = ChangeNotifier();
  /// The painter that paints before the children.
  late CanvasPainter painter;

  // The custom paint render object.
  RenderCustomPaint? renderCustomPaint;

  static Pointer<NativeCanvasRenderingContext2D> _getContext(
      Pointer<NativeEventTarget> nativeCanvasElement, Pointer<NativeString> contextId) {
    CanvasElement canvasElement = EventTarget.getEventTargetByPointer(nativeCanvasElement) as CanvasElement;
    canvasElement.getContext(nativeStringToString(contextId));
    return canvasElement.painter.context!.nativeCanvasRenderingContext2D;
  }

  CanvasElement(EventTargetContext? context)
      : super(
          context,
          isIntrinsicBox: true,
          isDefaultRepaintBoundary: true,
          defaultStyle: _defaultStyle,
        ) {
    painter = CanvasPainter(repaint: repaintNotifier);
  }

  // Currently only 2d rendering context for canvas is supported.
  CanvasRenderingContext2D? context2d;

  @override
  void willAttachRenderer() {
    super.willAttachRenderer();
    renderCustomPaint = RenderCanvasPaint(
      painter: painter,
      preferredSize: size,
    );

    addChild(renderCustomPaint!);
    style.addStyleChangeListener(_styleChangedListener);
  }

  @override
  void didAttachRenderer() {
    super.didAttachRenderer();
    context2d ??= CanvasRenderingContext2D();
  }

  @override
  void didDetachRenderer() {
    super.didDetachRenderer();
    style.removeStyleChangeListener(_styleChangedListener);
    painter.dispose();
    renderCustomPaint = null;
  }

  // RenderingContext? getContext(DOMString contextId, optional any options = null);
  CanvasRenderingContext2D getContext(String contextId, {dynamic options}) {
    switch (contextId) {
      case '2d':
        if (painter.context == null) {
          context2d ??= CanvasRenderingContext2D();
          context2d!.canvas = this;
          painter.context = context2d;
        }
        return painter.context!;
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
    double? width;
    double? height;

    RenderStyle renderStyle = renderBoxModel!.renderStyle;
    double? styleWidth = renderStyle.width.isAuto ? null : renderStyle.width.computedValue;
    double? styleHeight = renderStyle.height.isAuto ? null : renderStyle.height.computedValue;

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

    return Size(width!, height!);
  }

  void resize() {
    if (renderCustomPaint != null) {
      // https://html.spec.whatwg.org/multipage/canvas.html#concept-canvas-set-bitmap-dimensions
      final Size paintingBounding = size;
      renderCustomPaint!.preferredSize = paintingBounding;

      // The intrinsic dimensions of the canvas element when it represents embedded content are
      // equal to the dimensions of the element’s bitmap.
      // A canvas element can be sized arbitrarily by a style sheet, its bitmap is then subject
      // to the object-fit CSS property.
      // @TODO: CSS object-fit for canvas.
      // To fill (default value of object-fit) the bitmap content, use scale to get the same performed.
      RenderStyle renderStyle = renderBoxModel!.renderStyle;
      double? styleWidth = renderStyle.width.isAuto ? null : renderStyle.width.computedValue;
      double? styleHeight = renderStyle.height.isAuto ? null : renderStyle.height.computedValue;

      double? scaleX;
      double? scaleY;
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
          renderCustomPaint!.markNeedsPaint();
        }
      }
    }
  }

  /// Element attribute width
  double _attrWidth = ELEMENT_DEFAULT_WIDTH_IN_PIXEL;
  double get attrWidth => _attrWidth;
  set attrWidth(double? value) {
    if (value != null && value != _attrWidth) {
      _attrWidth = value;
      resize();
    }
  }

  /// Element attribute height
  double _attrHeight = ELEMENT_DEFAULT_HEIGHT_IN_PIXEL;
  double get attrHeight => _attrHeight;
  set attrHeight(double? value) {
    if (value != null && value != _attrHeight) {
      _attrHeight = value;
      resize();
    }
  }

  void _styleChangedListener(String key, String? original, String present) {
    switch (key) {
      case 'width':
      case 'height':
        resize();
        break;
    }
  }

  @override
  getProperty(String key) {
    switch(key) {
      case 'width':
        return attrWidth;
      case 'height':
        return attrHeight;
    }

    return super.getProperty(key);
  }

  @override
  dynamic handleJSCall(String method, List argv) {
    switch(method) {
      case 'getContext':
        return getContext(argv[0]).nativeCanvasRenderingContext2D;
    }

    return super.handleJSCall(method, argv);
  }

  @override
  void dispose() {
    super.dispose();
    // If not getContext and element is disposed that context is not existed.
    if (painter.context != null) {
      painter.context!.dispose();
    }
  }

  @override
  void setProperty(String key, value) {
    super.setProperty(key, value);
    // TODO:
    // When the user agent is to set bitmap dimensions to width and height, it must run these steps:
    //
    // 1. Reset the rendering context to its default state.
    //
    // 2. Resize the output bitmap to the new width and height and clear it to transparent black.
    //
    // 3. Let canvas be the canvas element to which the rendering context's canvas attribute was initialized.
    //
    // 4. If the numeric value of canvas's width content attribute differs from width,
    // then set canvas's width content attribute to the shortest possible string representing width as
    // a valid non-negative integer.
    //
    // 5. If the numeric value of canvas's height content attribute differs from height,
    // then set canvas's height content attribute to the shortest possible string representing height as
    // a valid non-negative integer.
    switch (key) {
      case WIDTH:
        // The width of the coordinate space in CSS pixels. Defaults to 300.
        attrWidth = double.tryParse(value);
        break;
      case HEIGHT:
        // The height of the coordinate space in CSS pixels. Defaults to 150.
        attrHeight = double.tryParse(value);
        break;
    }
  }
}
