/*
 * Copyright (C) 2020-present The Kraken authors. All rights reserved.
 */
import 'package:flutter/rendering.dart';
import 'package:kraken/gesture.dart';
import 'package:kraken/launcher.dart';
import 'package:kraken/rendering.dart';

class RenderViewportBox extends RenderProxyBox
    with RenderObjectWithControllerMixin, RenderEventListenerMixin {
  RenderViewportBox({
    required Size viewportSize,
    RenderBox? child,
    this.background,
    required KrakenController controller,
  }) : _viewportSize = viewportSize,
        super(child) {
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

    // Add pointer to gesture dispatcher.
    GestureDispatcher.instance.handlePointerEvent(event);

    if (event is PointerDownEvent) {
      // Set event path at begin stage and reset it at end stage on viewport render box.
      GestureDispatcher.instance.resetEventPath();
    }
  }

  @override
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
