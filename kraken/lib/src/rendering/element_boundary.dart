/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'package:flutter/rendering.dart';
import 'package:kraken/style.dart';

class ElementBoundaryParentData extends ContainerBoxParentData<RenderBox> {}

class RenderElementBoundary extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, ElementBoundaryParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, ElementBoundaryParentData> {
  RenderElementBoundary({
    this.child,
    Style style,
    this.nodeId,
  }) : assert(child != null) {
    _style = style;
    add(child);
  }

  RenderBox child;
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
      String display = style.get('display');
      if (display == 'none') {
        size = constraints.constrain(Size(0, 0));
      }
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child != null) {
      context.paintChild(child, offset);
    }
  }
}
