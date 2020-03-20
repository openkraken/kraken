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

  StyleDeclaration style;

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! ElementBoundaryParentData) {
      child.parentData = ElementBoundaryParentData();
    }
  }

  @override
  void performLayout() {
    String display = style['display'];
    if (child != null) {
      BoxConstraints additionalConstraints = constraints;
      if (display == 'none') {
        additionalConstraints = BoxConstraints(
          minWidth: 0,
          maxWidth: 0,
          minHeight: 0,
          maxHeight: 0,
        );
      }
      child.layout(additionalConstraints, parentUsesSize: true);
      size = child.size;
    } else {
      performResize();
    }

    // default transform origin center
    if (origin == null) {
      origin = Offset(size.width / 2, size.height / 2);
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    String display = style['display'];
    void painter(PaintingContext context, Offset offset) {}

    // Donnot paint when display none
    if (display == 'none') {
      context.pushClipRect(
          needsCompositing, offset, Offset.zero & size, painter);
    } else {
      super.paint(context, offset);
    }
  }
}
