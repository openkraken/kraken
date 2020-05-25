/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'package:flutter/rendering.dart';
import 'package:kraken/css.dart';
import 'package:kraken/rendering.dart';

class ElementBoundaryParentData extends ContainerBoxParentData<RenderBox> {}

class RenderElementBoundary extends RenderMargin
    with
        ContainerRenderObjectMixin<RenderBox, ElementBoundaryParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, ElementBoundaryParentData> {
  RenderElementBoundary(
      {this.child, this.style, EdgeInsetsGeometry margin, this.targetId, bool shouldRender})
      : assert(child != null),
        _shouldRender = shouldRender,
        _margin = margin,
        super(child: child, margin: margin) {
    add(child);
  }

  RenderBox child;

  // EdgeInsetsGeometry margin;

  EdgeInsetsGeometry _margin;
  EdgeInsetsGeometry get margin => _margin;
  set margin(EdgeInsetsGeometry value) {
    assert(value != null);
    if (_margin != value) {
      super.margin = value;
      _margin = value;
      markNeedsLayout();
    }
  }

  int targetId;

  // Positioned holder box ref.
  RenderPositionHolder positionedHolder;

  CSSStyleDeclaration style;

  Size layoutSize;

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
      size = layoutSize = child.size;
    } else {
      performResize();
    }
    super.performLayout();

    if (positionedHolder != null) {
      // Make position holder preferred size equal to current element boundary size.
      positionedHolder.preferredSize = Size.copy(size);
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    void painter(PaintingContext context, Offset offset) {}

    if (!shouldRender) {
      context.pushClipRect(needsCompositing, offset, Offset.zero & size, painter);
    } else {
      super.paint(context, offset);
    }
  }
}
