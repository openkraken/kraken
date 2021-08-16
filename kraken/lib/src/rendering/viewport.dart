/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'package:flutter/rendering.dart';
import 'package:flutter/gestures.dart';
import 'package:kraken/launcher.dart';
import 'package:kraken/rendering.dart';
import 'package:kraken/gesture.dart';
import 'dart:ui';

class RenderViewportBox extends RenderProxyBox
    with RenderObjectWithControllerMixin, RenderPointerListenerMixin {
  RenderViewportBox({
    required Size viewportSize,
    RenderBox? child,
    gestureClient,
    this.background,
    required KrakenController controller,
  })  : _viewportSize = viewportSize,
        super(child) {
    if (gestureClient != null) {
      _verticalDragGestureRecognizer.onUpdate =
          _horizontalDragRecognizer.onUpdate = gestureClient.dragUpdateCallback;
      _verticalDragGestureRecognizer.onStart =
          _horizontalDragRecognizer.onStart = gestureClient.dragStartCallback;
      _verticalDragGestureRecognizer.onEnd =
          _horizontalDragRecognizer.onEnd = gestureClient.dragEndCallback;
    }
    this.controller = controller;
  }

  @override
  bool get isRepaintBoundary => true;

  Color? background;

  Size _viewportSize;

  Size get viewportSize => _viewportSize;

  set viewportSize(Size value) {
    if (value != _viewportSize) {
      _viewportSize = value;
      markNeedsLayout();
    }
  }

  double _bottomInset = 0.0;

  double get bottomInset => _bottomInset;

  set bottomInset(double value) {
    if (value != _bottomInset) {
      _bottomInset = value;
      markNeedsLayout();
    }
  }

  final VerticalDragGestureRecognizer _verticalDragGestureRecognizer =
      VerticalDragGestureRecognizer();
  final HorizontalDragGestureRecognizer _horizontalDragRecognizer =
      HorizontalDragGestureRecognizer();

  @override
  void performLayout() {
    double width = _viewportSize.width;
    double height = _viewportSize.height - _bottomInset;
    if (height.isNegative || height.isNaN) {
      height = _viewportSize.height;
    }
    size = constraints.constrain(Size(width, height));
    if (child != null) {
      child!.layout(BoxConstraints.tightFor(
        width: width,
        height: height,
      ));
    }
  }

  @override
  void handleEvent(PointerEvent event, HitTestEntry entry) {
    super.handleEvent(event, entry as BoxHitTestEntry);
    if (event is PointerDownEvent) {
      // Add viewport to hitTest list.
      GestureManager.instance().addTargetToList(this);
      _verticalDragGestureRecognizer.addPointer(event);
    }

    // Add pointer to GestureManager.
    GestureManager.instance().addPointer(event);
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
        Paint()..color = background!,
      );
    }

    if (child != null) {
      context.paintChild(child!, offset);
    }
  }
}
