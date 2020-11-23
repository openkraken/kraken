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

final Pointer<NativeFunction<Native_CanvasGetContext>> nativeGetContext =
    Pointer.fromFunction(CanvasElement._getContext);

const Map<String, dynamic> _defaultStyle = {
  DISPLAY: INLINE_BLOCK,
  WIDTH: ELEMENT_DEFAULT_WIDTH,
  HEIGHT: ELEMENT_DEFAULT_HEIGHT,
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
    style.addStyleChangeListener(_propertyChangedListener);
  }

  @override
  void didDetachRenderer() {
    super.didDetachRenderer();
    style.removeStyleChangeListener(_propertyChangedListener);
    renderCustomPaint = null;
  }

  /// The painter that paints before the children.
  final CanvasPainter painter = CanvasPainter();

  /// The size that this [CustomPaint] should aim for, given the layout
  /// constraints, if there is no child.
  ///
  /// If there's a child, this is ignored, and the size of the child is used
  /// instead.
  Size get size => Size(width, height);

  RenderCustomPaint renderCustomPaint;

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

  /// Element attribute width
  double _width = CSSLength.toDisplayPortValue(ELEMENT_DEFAULT_WIDTH);

  double get width => _width;

  set width(double value) {
    if (value == null) {
      return;
    }

    if (value != _width) {
      _width = value;
      if (renderCustomPaint != null) {
        renderCustomPaint.preferredSize = size;
      }
    }
  }

  /// Element attribute height
  double _height = CSSLength.toDisplayPortValue(ELEMENT_DEFAULT_HEIGHT);

  double get height => _height;

  set height(double value) {
    if (value == null) {
      return;
    }

    if (value != _height) {
      _height = value;
      if (renderCustomPaint != null) {
        renderCustomPaint.preferredSize = size;
      }
    }
  }

  void _propertyChangedListener(String key, String original, String present, bool inAnimation) {
    switch (key) {
      case 'width':
        // Trigger width setter to invoke rerender.
        width = CSSLength.toDisplayPortValue(present);
        break;
      case 'height':
        // Trigger height setter to invoke rerender.
        height = CSSLength.toDisplayPortValue(present);
        break;
    }
  }

  @override
  void dispose() {
    super.dispose();
    _nativeMap.remove(nativeCanvasElement.address);
    painter.context.dispose();
  }
}
