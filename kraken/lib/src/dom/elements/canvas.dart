/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:collection';
import 'dart:ffi';
import 'package:flutter/rendering.dart';
import 'package:kraken/dom.dart';
import 'package:kraken/bridge.dart';
import 'package:kraken/rendering.dart';
import 'package:kraken/painting.dart';
import 'package:kraken/css.dart';

const String CANVAS = 'CANVAS';
const double ELEMENT_DEFAULT_WIDTH_IN_PIXEL = 300.0;
const double ELEMENT_DEFAULT_HEIGHT_IN_PIXEL = 150.0;

final Pointer<NativeFunction<Native_CanvasGetContext>> nativeGetContext =
    Pointer.fromFunction(CanvasElement._getContext);

const Map<String, dynamic> _defaultStyle = {
  DISPLAY: INLINE_BLOCK,
};

class RenderCanvasPaint extends RenderCustomPaint {
  @override
  bool get isRepaintBoundary => true;

  RenderCanvasPaint({CustomPainter painter, Size preferredSize})
      : super(
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

  static SplayTreeMap<int, Element> _nativeMap = SplayTreeMap();

  static CanvasElement getCanvasElementOfNativePtr(Pointer<NativeCanvasElement> nativeCanvasElement) {
    CanvasElement canvasElement = _nativeMap[nativeCanvasElement.address];
    assert(canvasElement != null, 'Can not get canvasElement from nativeElement: $nativeCanvasElement');
    return canvasElement;
  }

  static Pointer<NativeCanvasRenderingContext2D> _getContext(
      Pointer<NativeCanvasElement> nativeCanvasElement, Pointer<NativeString> contextId) {
    CanvasElement canvasElement = getCanvasElementOfNativePtr(nativeCanvasElement);
    canvasElement.getContext(nativeStringToString(contextId));
    return canvasElement.painter.context.nativeCanvasRenderingContext2D;
  }

  final Pointer<NativeCanvasElement> nativeCanvasElement;

  CanvasElement(int targetId, this.nativeCanvasElement, ElementManager elementManager)
      : super(
          targetId,
          nativeCanvasElement.ref.nativeElement,
          elementManager,
          defaultStyle: _defaultStyle,
          isIntrinsicBox: true,
          repaintSelf: true,
          tagName: CANVAS,
        ) {
    nativeCanvasElement.ref.getContext = nativeGetContext;

    // Keep reference so that we can search back with nativePtr from bridge.
    _nativeMap[nativeCanvasElement.address] = this;
  }

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
    double viewportWidth = elementManager.viewportWidth;
    double viewportHeight = elementManager.viewportHeight;
    Size viewportSize = Size(viewportWidth, viewportHeight);

    switch (contextId) {
      case '2d':
        if (painter.context == null) {
          CanvasRenderingContext2D.viewportSize = viewportSize;
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

    RenderStyle renderStyle = renderBoxModel.renderStyle;
    double styleWidth = renderStyle.width;
    double styleHeight = renderStyle.height;

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
      RenderStyle renderStyle = renderBoxModel.renderStyle;
      double styleWidth = renderStyle.width;
      double styleHeight = renderStyle.height;

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

  void _styleChangedListener(String key, String original, String present) {
    switch (key) {
      case 'width':
      case 'height':
        resize();
        break;
    }
  }

  @override
  void dispose() {
    super.dispose();
    _nativeMap.remove(nativeCanvasElement.address);
    painter.context.dispose();
  }

  @override
  void setProperty(String key, value) {
    super.setProperty(key, value);
    double viewportWidth = elementManager.viewportWidth;
    double viewportHeight = elementManager.viewportHeight;
    Size viewportSize = Size(viewportWidth, viewportHeight);

    switch (key) {
      case WIDTH:
        attrWidth = CSSLength.toDisplayPortValue('$value${CSSLength.PX}', viewportSize);
        break;
      case HEIGHT:
        attrHeight = CSSLength.toDisplayPortValue('$value${CSSLength.PX}', viewportSize);
        break;
    }
  }
}
