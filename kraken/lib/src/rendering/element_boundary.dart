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
    bool shouldRender,
  }) : assert(child != null),
    _shouldRender = shouldRender,
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

  bool _shouldRender;
  bool get shouldRender => _shouldRender;
  set shouldRender(bool value) {
    assert(value != null);
    if (_shouldRender != value) {
      markNeedsLayout();
     _shouldRender = value;
    }
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
      BoxConstraints additionalConstraints = constraints;
      if (!shouldRender) {
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
    void painter(PaintingContext context, Offset offset) {}

    if (!shouldRender) {
      context.pushClipRect(
          needsCompositing, offset, Offset.zero & size, painter);
    } else {
      super.paint(context, offset);
    }
  }
}
