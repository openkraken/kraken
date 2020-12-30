/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'package:flutter/rendering.dart';
import 'package:flutter/gestures.dart';
import 'package:kraken/launcher.dart';
import 'dart:ui';
import 'package:meta/meta.dart';
import 'package:kraken/rendering.dart';

class RenderViewportBox extends RenderProxyBox
    with RenderObjectWithControllerMixin {
  RenderViewportBox({
    @required Size viewportSize,
    RenderBox child,
    gestureClient,
    this.background,
  }) : _viewportSize = viewportSize, super(child) {
    if (gestureClient != null) {
      _verticalDragGestureRecognizer.onUpdate = gestureClient.overflowByUpdate;
      _horizontalDragRecognizer.onUpdate = gestureClient.overflowByUpdate;
      _verticalDragGestureRecognizer.onStart = gestureClient.overflowByStart;
      _horizontalDragRecognizer.onStart = gestureClient.overflowByStart;
      _verticalDragGestureRecognizer.onEnd = gestureClient.overflowByEnd;
      _horizontalDragRecognizer.onEnd = gestureClient.overflowByEnd;
    }
  }

  Color background;

  Size _viewportSize;
  Size get viewportSize => _viewportSize;
  set viewportSize(Size value) {
    if (value != null && value != _viewportSize) {
      _viewportSize = value;
      markNeedsLayout();
    }
  }

  double _bottomInset = 0.0;
  double get bottomInset => _bottomInset;
  set bottomInset(double value) {
    if (value != null && value != _bottomInset) {
      _bottomInset = value;
      markNeedsLayout();
    }
  }

  final VerticalDragGestureRecognizer _verticalDragGestureRecognizer = VerticalDragGestureRecognizer();
  final HorizontalDragGestureRecognizer _horizontalDragRecognizer = HorizontalDragGestureRecognizer();

  @override
  void performLayout() {
    assert(_viewportSize != null);
    double maxWidth = window.physicalSize.width / window.devicePixelRatio;
    double maxHeight = window.physicalSize.height / window.devicePixelRatio;
    size = constraints.constrain(Size(maxWidth, maxHeight));
    if (child != null) {
      double height = _viewportSize.height - _bottomInset;
      if (height.isNegative || height.isNaN) {
        height = _viewportSize.height;
      }
      child.layout(BoxConstraints.tightFor(
        width: _viewportSize.width,
        height: height,
      ));
    }
  }

  @override
  void handleEvent(PointerEvent event, HitTestEntry entry) {
    super.handleEvent(event, entry);
    if (event is PointerDownEvent) {
      _verticalDragGestureRecognizer.addPointer(event);
    }
  }

  void paint(PaintingContext context, Offset offset) {
    if (background != null) {
      Rect rect = Rect.fromLTWH(
        offset.dx,
        offset.dy,
        size.width,
        size.height,
      );
      context.canvas.drawRect(
        rect,
        Paint()..color = background,
      );
    }

    if (child != null) {
      context.paintChild(child, offset);
    }
  }
}
