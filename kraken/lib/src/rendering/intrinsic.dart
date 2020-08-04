/*
 * Copyright (C) 2020-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'package:kraken/css.dart';
import 'package:flutter/rendering.dart';
import 'package:kraken/rendering.dart';

class RenderIntrinsicBox extends RenderBoxModel
    with RenderObjectWithChildMixin<RenderBox>, RenderProxyBoxMixin<RenderBox> {
  RenderIntrinsicBox(int targetId, CSSStyleDeclaration style) : super(targetId: targetId, style: style);

  @override
  void performLayout() {
    beforeLayout();
    if (child != null) {
      child.layout(contentConstraints, parentUsesSize: true);
      size = child.size;
    }
    didLayout();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    basePaint(context, offset, (PaintingContext context, Offset offset) {
      if (padding != null) {
        offset += Offset(paddingLeft, paddingTop);
      }

      if (child != null) context.paintChild(child, offset);
    });
  }
}
