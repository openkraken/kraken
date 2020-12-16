/*
 * Copyright (C) 2020-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'package:kraken/css.dart';
import 'package:flutter/rendering.dart';
import 'package:kraken/dom.dart';
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

  // Set clipX and clipY to true for background cannot overflow beyond the boundary of replaced element
  @override
  bool get clipX => true;

  @override
  bool get clipY => true;

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! RenderLayoutParentData) {
      if (child is RenderBoxModel) {
        RenderLayoutParentData parentData = RenderLayoutParentData();
        child.parentData = CSSPositionedLayout.getPositionParentData(child, parentData);;
      } else {
        child.parentData = RenderLayoutParentData();
      }
    }
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

      CSSDisplay realDisplay = CSSSizing.getElementRealDisplayValue(targetId, elementManager);
      bool isInlineLevel = realDisplay == CSSDisplay.inlineBlock || realDisplay == CSSDisplay.inlineFlex;

      double constraintWidth = child.size.width;
      double constraintHeight = child.size.height;

      // Constrain to min-width or max-width if width not exists
      if (isInlineLevel && maxWidth != null && width == null) {
        constraintWidth = constraintWidth > maxWidth ? maxWidth : constraintWidth;

        // max-height should respect intrinsic ratio with max-width
        if (intrinsicRatio != null && maxHeight == null) {
          constraintHeight = constraintWidth * intrinsicRatio;
        }
      } else if (isInlineLevel && minWidth != null && width == null) {
        constraintWidth = constraintWidth < minWidth ? minWidth : constraintWidth;

        // max-height should respect intrinsic ratio with max-width
        if (intrinsicRatio != null && minHeight == null) {
          constraintHeight = constraintWidth * intrinsicRatio;
        }
      }

      // Constrain to min-height or max-height if width not exists
      if (isInlineLevel && maxHeight != null && height == null) {
        constraintHeight = constraintHeight > maxHeight ? maxHeight : constraintHeight;

        // max-width should respect intrinsic ratio with max-height
        if (intrinsicRatio != null && maxWidth == null) {
          constraintWidth = constraintHeight / intrinsicRatio;
        }
      } else if (isInlineLevel && minHeight != null && height == null) {
        constraintHeight = constraintHeight < minHeight ? minHeight : constraintHeight;

        // max-width should respect intrinsic ratio with max-height
        if (intrinsicRatio != null && minWidth == null) {
          constraintWidth = constraintHeight / intrinsicRatio;
        }
      }

      Size contentSize = Size(constraintWidth, constraintHeight);
      size = getBoxSize(contentSize);

      autoMinWidth = size.width;
      autoMinHeight = size.height;

      didLayout();
    } else {
      super.performResize();
    }
  }

  /// This class mixin [RenderProxyBoxMixin], which has its' own paint method,
  /// override it to layout box model paint.
  @override
  void paint(PaintingContext context, Offset offset) {
    if (isCSSDisplayNone || isCSSVisibilityHidden) return;
    paintBoxModel(context, offset);
  }

  @override
  void performPaint(PaintingContext context, Offset offset) {
    if (padding != null) {
      offset += Offset(paddingLeft, paddingTop);
    }

    if (borderEdge != null) {
      offset += Offset(borderLeft, borderTop);
    }

    if (child != null) {
      context.paintChild(child, offset);
    }
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
  bool get isRepaintBoundary => true;

  RenderIntrinsic toParentRepaint() {
    RenderObject childRenderObject = child;
    child = null;
    RenderIntrinsic newChild = RenderIntrinsic(targetId, style, elementManager);
    newChild.child = childRenderObject;
    return copyWith(newChild);
  }
}
