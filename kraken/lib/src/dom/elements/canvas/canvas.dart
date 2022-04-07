/*
 * Copyright (C) 2019-present The Kraken authors. All rights reserved.
 */

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:kraken/css.dart';
import 'package:kraken/dom.dart';
import 'package:kraken/rendering.dart';
import 'package:kraken/foundation.dart';

const String CANVAS = 'CANVAS';
const int _ELEMENT_DEFAULT_WIDTH_IN_PIXEL = 300;
const int _ELEMENT_DEFAULT_HEIGHT_IN_PIXEL = 150;

const Map<String, dynamic> _defaultStyle = {
  DISPLAY: INLINE_BLOCK,
};

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

  CanvasElement([BindingContext? context])
      : super(
          context,
          isReplacedElement: true,
          isDefaultRepaintBoundary: true,
          defaultStyle: _defaultStyle,
        ) {
    painter = CanvasPainter(repaint: repaintNotifier);
  }

  // Currently only 2d rendering context for canvas is supported.
  CanvasRenderingContext2D? context2d;

  // Bindings.
  @override
  getBindingProperty(String key) {
    switch (key) {
      case 'width': return width;
      case 'height': return height;
      default: return super.getBindingProperty(key);
    }
  }

  @override
  void setBindingProperty(String key, value) {
    switch (key) {
      case 'width': width = castToType<int>(value); break;
      case 'height': height = castToType<int>(value); break;
      default: super.setBindingProperty(key, value);
    }
  }

  @override
  invokeBindingMethod(String method, List args) {
    switch (method) {
      case 'getContext': return getContext(castToType<String>(args[0])).toNative();
      default: return super.invokeBindingMethod(method, args);
    }
  }

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
  void didDetachRenderer() {
    super.didDetachRenderer();
    style.removeStyleChangeListener(_styleChangedListener);
    painter.dispose();
    renderCustomPaint = null;
  }

  CanvasRenderingContext2D getContext(String type, { options }) {
    switch (type) {
      case '2d':
        if (painter.context == null) {
          context2d ??= CanvasRenderingContext2D(this);
          painter.context = context2d;
        }
        return painter.context!;
      default:
        throw FlutterError('CanvasRenderingContext $type not supported!');
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

    // [width/height] has default value, should not be null.
    if (height == null && width == null) {
      width = this.width.toDouble();
      height = this.height.toDouble();
    } else if (width == null && height != null) {
      width = this.height / height * this.width;
    } else if (width != null && height == null) {
      height = this.width / width * this.height;
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
        scaleX = paintingBounding.width / width;
      }
      if (styleHeight != null) {
        scaleY = paintingBounding.height / height;
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

  /// Element property width.
  int get width {
    String? attrWidth = getAttribute(WIDTH);
    if (attrWidth != null) {
      return attributeToProperty<int>(attrWidth);
    } else {
      return _ELEMENT_DEFAULT_WIDTH_IN_PIXEL;
    }
  }
  set width(int value) {
    _setDimensions(value, null);
  }

  /// Element property height.
  int get height {
    String? attrHeight = getAttribute(HEIGHT);
    if (attrHeight != null) {
      return attributeToProperty<int>(attrHeight);
    } else {
      return _ELEMENT_DEFAULT_HEIGHT_IN_PIXEL;
    }
  }
  set height(int value) {
    _setDimensions(null, value);
  }

  void _setDimensions(num? width, num? height) {
    // When the user agent is to set bitmap dimensions to width and height, it must run these steps:
    // 1. Reset the rendering context to its default state.
    context2d?.dispose();
    context2d = null;
    // 2. Resize the output bitmap to the new width and height and clear it to transparent black.
    resize();
    // 3. Let canvas be the canvas element to which the rendering context's canvas attribute was initialized.
    context2d = CanvasRenderingContext2D(this);
    // 4. If the numeric value of canvas's width content attribute differs from width,
    // then set canvas's width content attribute to the shortest possible string representing width as
    // a valid non-negative integer.
    if (width != null && width.toString() != getAttribute(WIDTH)) {
      if (width < 0) width = 0;
      internalSetAttribute(WIDTH, width.toString());
    }
    // 5. If the numeric value of canvas's height content attribute differs from height,
    // then set canvas's height content attribute to the shortest possible string representing height as
    // a valid non-negative integer.
    if (height != null && height.toString() != getAttribute(HEIGHT)) {
      if (height < 0) height = 0;
      internalSetAttribute(HEIGHT, height.toString());
    }
  }

  void _styleChangedListener(String key, String? original, String present) {
    switch (key) {
      case WIDTH:
      case HEIGHT:
        resize();
        break;
    }
  }

  @override
  void setAttribute(String qualifiedName, String value) {
    super.setAttribute(qualifiedName, value);
    switch (qualifiedName) {
      case 'width': width = attributeToProperty<int>(value); break;
      case 'height': height = attributeToProperty<int>(value); break;
    }
  }

  @override
  void dispose() {
    super.dispose();
    // If not getContext and element is disposed that context is not existed.
    if (painter.context != null) {
      painter.context!.dispose();
    }
  }
}
