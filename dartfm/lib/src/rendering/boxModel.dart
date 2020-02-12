/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'package:flutter/rendering.dart';
import 'package:kraken/style.dart';

class RenderBoxModel extends RenderTransform {
  RenderBoxModel({
    RenderBox child,
    Matrix4 transform,
    Offset origin,
    this.nodeId,
    Style style,
  }) :
    _style = style,
    super(
          child: child,
          transform: transform,
          origin: origin,
        );
  int nodeId;

  Style _style;
  Style get style => _style;
  set style(Style value) {
    if (_style == value) {
      return;
    }
    _style = value;
  }

  @override
  void performLayout() {
    if (child != null) {
      child.layout(constraints, parentUsesSize: true);
      size = child.size;
    } else {
      performResize();
    }

    if (style != null) {
      String display = style.get('display');
      if (display == 'none') {
        size = constraints.constrain(Size(0, 0));
      }
    }
  }
}
