/*
 * Copyright (C) 2020-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'package:kraken/css.dart';
import 'package:flutter/rendering.dart';
import 'package:kraken/element.dart';
import 'package:kraken/rendering.dart';

class RenderIntrinsicBox extends RenderBoxModel
    with RenderObjectWithChildMixin<RenderBox>, RenderProxyBoxMixin<RenderBox> {
  RenderIntrinsicBox(int targetId, CSSStyleDeclaration style, ElementManager elementManager)
      : super(targetId: targetId, style: style, elementManager: elementManager);

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

      if (borderEdge != null) {
        offset += Offset(borderLeft, borderTop);
      }

      if (child != null) context.paintChild(child, offset);
    });
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {Offset position}) {
    if (transform != null) {
      return hitTestIntrinsicChild(result, child, position);
    }
    return super.hitTestChildren(result, position: position);
  }
}
