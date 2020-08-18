/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'package:flutter/rendering.dart';
import 'package:kraken/element.dart';
import 'package:kraken/css.dart';
import 'package:kraken/rendering.dart';

class ElementBoundaryParentData extends ContainerBoxParentData<RenderBox> {}

enum BoxSizeType {
  // Element which have intrinsic before layout. Such as <img /> and <video />
  intrinsic,

  // Element which have width or min-width properties defined.
  specified,

  // Element which neither have intrinsic or predefined size.
  automatic,
}

class RenderElementBoundary extends RenderProxyBox {
  RenderElementBoundary(
      {RenderBox child,
      this.style,
      this.targetId,
      this.elementManager,
      })
      : assert(child != null),
        super(child) {
      this.child = child;
  }

  // Positioned holder box ref.
  RenderPositionHolder positionedHolder;

  int targetId;

  // @TODO: need to remove this after RenderObject merge have completed.
  ElementManager elementManager;

  CSSStyleDeclaration style;

  BoxSizeType widthSizeType;
  BoxSizeType heightSizeType;

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! ElementBoundaryParentData) {
      child.parentData = ElementBoundaryParentData();
    }
  }
}
