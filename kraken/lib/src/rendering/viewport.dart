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
    with RenderObjectWithControllerMixin {
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

  EventHandlers? getEventHandlers;

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
    double maxWidth = window.physicalSize.width / window.devicePixelRatio;
    double maxHeight = window.physicalSize.height / window.devicePixelRatio;
    size = constraints.constrain(Size(maxWidth, maxHeight));
    if (child != null) {
      double height = _viewportSize.height - _bottomInset;
      if (height.isNegative || height.isNaN) {
        height = _viewportSize.height;
      }
      child!.layout(BoxConstraints.tightFor(
        width: _viewportSize.width,
        height: height,
      ));
    }
  }

  @override
  void handleEvent(PointerEvent event, HitTestEntry entry) {
    super.handleEvent(event, entry as BoxHitTestEntry);
    if (event is PointerDownEvent) {
      // add viewport to hitTest list.
      GestureManager.instance().addTargetToList(this);
      _verticalDragGestureRecognizer.addPointer(event);
      // add down pointer to gestures then register the gesture recognizer to the arena.
      GestureManager.instance().addPointer(event);
    } else if (event is PointerUpEvent) {
      GestureManager.instance().clearTargetList();
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
        Paint()..color = background!,
      );
    }

    if (child != null) {
      context.paintChild(child!, offset);
    }
  }
}
