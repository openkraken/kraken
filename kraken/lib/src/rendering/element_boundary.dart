/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'package:flutter/rendering.dart';
import 'package:kraken/style.dart';

class ElementBoundaryParentData extends ContainerBoxParentData<RenderBox> {}

class RenderElementBoundary extends RenderTransform
    with
        ContainerRenderObjectMixin<RenderBox, ElementBoundaryParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, ElementBoundaryParentData> {
  RenderElementBoundary({
    this.child,
    this.style,
    Matrix4 transform,
    Offset origin,
    this.nodeId,
  }) : assert(child != null),
    super(
      child: child,
      transform: transform,
      origin: origin,
  ) {
    add(child);
  }

  RenderBox child;
  int nodeId;

  CSSStyleDeclaration style;

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! ElementBoundaryParentData) {
      child.parentData = ElementBoundaryParentData();
    }
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
      String display = style['display'];
      if (display == 'none') {
        size = constraints.constrain(Size(0, 0));
      }
    }
    // default transform origin center
    if (origin == null) {
      origin = Offset(size.width / 2, size.height / 2);
    }
  }
}
