/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'package:flutter/rendering.dart';
import 'package:kraken/painting.dart' show CanvasRenderingContext2D;

class CanvasPainter extends CustomPainter {
  CanvasRenderingContext2D context;

  @override
  void paint(Canvas canvas, Size size) {
    if (context != null) {
      context.performAction(canvas, size);
    }
  }

  @override
  bool shouldRepaint(CanvasPainter oldDelegate) => false;
}
