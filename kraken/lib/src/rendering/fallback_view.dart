/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:ui';
import 'package:flutter/rendering.dart' hide Gradient;

const Color _black = Color(0xBF000000);
const Color _yellow = Color(0xBFFFFF00);

class RenderFallbackViewBox extends RenderBox with RenderObjectWithChildMixin<RenderBox> {
  RenderFallbackViewBox({RenderBox child}) : assert(child != null) {
    this.child = child;
  }

  static final Paint _linePaint = Paint()
    ..shader = Gradient.linear(
      const Offset(0.0, 0.0),
      const Offset(10.0, 10.0),
      <Color>[_black, _yellow, _yellow, _black],
      <double>[0.25, 0.25, 0.75, 0.75],
      TileMode.repeated,
    );

  @override
  void paint(PaintingContext context, Offset offset) {
    context.canvas.drawRect(Rect.fromLTWH(offset.dx, offset.dy, size.width, size.height), _linePaint);
    if (child != null) {
      // Add some offset to show borders.
      child.paint(context, offset + Offset(5.0, 5.0));
    }
  }

  @override
  void performLayout() {
    size = constraints.biggest;
    if (child != null) {
      child.layout(constraints);
    }
  }
}
