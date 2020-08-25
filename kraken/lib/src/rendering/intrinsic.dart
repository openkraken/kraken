/*
 * Copyright (C) 2020-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'package:kraken/css.dart';
import 'package:flutter/rendering.dart';
import 'package:kraken/element.dart';
import 'package:kraken/rendering.dart';

class RenderIntrinsic extends RenderBoxModel
    with RenderObjectWithChildMixin<RenderBox>, RenderProxyBoxMixin<RenderBox> {
  RenderIntrinsic(int targetId, CSSStyleDeclaration style, ElementManager elementManager)
      : super(targetId: targetId, style: style, elementManager: elementManager);

  @override
  void performLayout() {
    beforeLayout();
    if (child != null) {
      child.layout(contentConstraints, parentUsesSize: true);
      size = child.size;
      didLayout();
    } else {
      super.performResize();
    }
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

  RenderSelfRepaintIntrinsic toSelfRepaint() {
    RenderObject childRenderObject = child;
    child = null;
    RenderSelfRepaintIntrinsic newChild = RenderSelfRepaintIntrinsic(targetId, style, elementManager);
    newChild.child = childRenderObject;
    return copyWith(newChild);
  }
}

class RenderSelfRepaintIntrinsic extends RenderIntrinsic {
  RenderSelfRepaintIntrinsic(int targetId, CSSStyleDeclaration style, ElementManager elementManager):
        super(targetId, style, elementManager);

  @override
  get isRepaintBoundary => true;

  RenderIntrinsic toParentRepaint() {
    RenderObject childRenderObject = child;
    child = null;
    RenderIntrinsic newChild = RenderIntrinsic(targetId, style, elementManager);
    newChild.child = childRenderObject;
    return copyWith(newChild);
  }
}
