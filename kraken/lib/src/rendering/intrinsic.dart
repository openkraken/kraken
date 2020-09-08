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

  BoxSizeType get widthSizeType {
    bool widthDefined = width != null || (minWidth != null);
    return widthDefined ? BoxSizeType.specified : BoxSizeType.intrinsic;
  }
  BoxSizeType get heightSizeType {
    bool heightDefined = height != null || (minHeight != null);
    return heightDefined ? BoxSizeType.specified : BoxSizeType.intrinsic;
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! RenderLayoutParentData) {
      if (child is RenderBoxModel) {
        child.parentData = getPositionParentDataFromStyle(child.style);
      } else {
        child.parentData = RenderLayoutParentData();
      }
    }
  }

  RenderLayoutParentData getPositionParentDataFromStyle(CSSStyleDeclaration style) {
    RenderLayoutParentData parentData = RenderLayoutParentData();
    CSSPositionType positionType = resolvePositionFromStyle(style);
    parentData.position = positionType;

    if (style.contains('top')) {
      parentData.top = CSSLength.toDisplayPortValue(style['top']);
    }
    if (style.contains('left')) {
      parentData.left = CSSLength.toDisplayPortValue(style['left']);
    }
    if (style.contains('bottom')) {
      parentData.bottom = CSSLength.toDisplayPortValue(style['bottom']);
    }
    if (style.contains('right')) {
      parentData.right = CSSLength.toDisplayPortValue(style['right']);
    }
    parentData.width = CSSLength.toDisplayPortValue(style['width']) ?? 0;
    parentData.height = CSSLength.toDisplayPortValue(style['height']) ?? 0;
    parentData.zIndex = CSSLength.toInt(style['zIndex']) ?? 0;

    parentData.isPositioned = positionType == CSSPositionType.absolute || positionType == CSSPositionType.fixed;

    return parentData;
  }

  @override
  void performLayout() {
    if (display == CSSDisplay.none) {
      size = constraints.smallest;
      return;
    }

    beforeLayout();
    if (child != null) {
      child.layout(contentConstraints, parentUsesSize: true);
      setMaxScrollableSize(child.size.width, child.size.height);
      size = getBoxSize(child.size);
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

  @override
  bool hitTestChildren(BoxHitTestResult result, {Offset position}) {
    if (transform != null) {
      return hitTestIntrinsicChild(result, child, position);
    }
    return super.hitTestChildren(result, position: position);
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
