/*
 * Copyright (C) 2020-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:kraken/css.dart';
import 'package:kraken/dom.dart';
import 'package:kraken/module.dart';
import 'package:kraken/rendering.dart';

class RenderIntrinsic extends RenderBoxModel
    with RenderObjectWithChildMixin<RenderBox>, RenderProxyBoxMixin<RenderBox> {
  RenderIntrinsic(CSSRenderStyle renderStyle) : super(renderStyle: renderStyle);

  @override
  BoxSizeType get widthSizeType {
    bool widthDefined = renderStyle.width.isNotAuto || renderStyle.minWidth.isNotAuto;
    return widthDefined ? BoxSizeType.specified : BoxSizeType.intrinsic;
  }

  @override
  BoxSizeType get heightSizeType {
    bool heightDefined = renderStyle.height.isNotAuto || renderStyle.minHeight.isNotAuto;
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
        child.parentData =
            CSSPositionedLayout.getPositionParentData(child, parentData);
      } else {
        child.parentData = RenderLayoutParentData();
      }
    }
  }

  @override
  void performLayout() {
    if (kProfileMode && PerformanceTiming.enabled()) {
      childLayoutDuration = 0;
      PerformanceTiming.instance()
          .mark(PERF_INTRINSIC_LAYOUT_START, uniqueId: hashCode);
    }

    beforeLayout();

    if (child != null) {
      late DateTime childLayoutStart;
      if (kProfileMode && PerformanceTiming.enabled()) {
        childLayoutStart = DateTime.now();
      }

      child!.layout(contentConstraints!, parentUsesSize: true);

      if (kProfileMode && PerformanceTiming.enabled()) {
        DateTime childLayoutEnd = DateTime.now();
        childLayoutDuration += (childLayoutEnd.microsecondsSinceEpoch) -
            childLayoutStart.microsecondsSinceEpoch;
      }

      Size childSize = child!.size;

      setMaxScrollableSize(childSize);
      size = getBoxSize(childSize);

      autoMinWidth = size.width;
      autoMinHeight = size.height;

      didLayout();
    } else {
      performResize();
    }

    if (kProfileMode && PerformanceTiming.enabled()) {
      PerformanceTiming.instance()
          .mark(PERF_INTRINSIC_LAYOUT_END, uniqueId: hashCode);
    }
  }

  @override
  void performResize() {
    double width = 0, height = 0;
    final Size attempingSize = constraints.biggest;
    if (attempingSize.width.isFinite) {
      width = attempingSize.width;
    }
    if (attempingSize.height.isFinite) {
      height = attempingSize.height;
    }

    size = Size(width, height);
    assert(size.isFinite);
  }

  @override
  double computeDistanceToActualBaseline(TextBaseline baseline) {
    return computeDistanceToBaseline();
  }

  /// Compute distance to baseline of replaced element
  @override
  double computeDistanceToBaseline() {
    double marginTop = renderStyle.marginTop.computedValue;
    double marginBottom = renderStyle.marginBottom.computedValue;

    // Use margin-bottom as baseline if layout has no children
    return marginTop + boxSize!.height + marginBottom;
  }

  /// This class mixin [RenderProxyBoxMixin], which has its' own paint method,
  /// override it to layout box model paint.
  @override
  void paint(PaintingContext context, Offset offset) {
    if (renderStyle.isVisibilityHidden) return;
    paintBoxModel(context, offset);
  }

  @override
  void performPaint(PaintingContext context, Offset offset) {

    offset += Offset(renderStyle.paddingLeft.computedValue, renderStyle.paddingTop.computedValue);

    offset += Offset(renderStyle.effectiveBorderLeftWidth.computedValue, renderStyle.effectiveBorderTopWidth.computedValue);

    if (child != null) {
      late DateTime childPaintStart;
      if (kProfileMode && PerformanceTiming.enabled()) {
        childPaintStart = DateTime.now();
      }
      context.paintChild(child!, offset);
      if (kProfileMode && PerformanceTiming.enabled()) {
        DateTime childPaintEnd = DateTime.now();
        childPaintDuration += (childPaintEnd.microsecondsSinceEpoch -
            childPaintStart.microsecondsSinceEpoch);
      }
    }
  }

  RenderRepaintBoundaryIntrinsic toRepaintBoundaryIntrinsic() {
    RenderObject? childRenderObject = child;
    child = null;
    RenderRepaintBoundaryIntrinsic newChild = RenderRepaintBoundaryIntrinsic(renderStyle);
    newChild.child = childRenderObject as RenderBox?;
    return copyWith(newChild);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {Offset? position}) {
    if (renderStyle.transformMatrix != null) {
      return hitTestIntrinsicChild(result, child, position!);
    }
    return super.hitTestChildren(result, position: position!);
  }
}

class RenderRepaintBoundaryIntrinsic extends RenderIntrinsic {
  RenderRepaintBoundaryIntrinsic(CSSRenderStyle renderStyle) : super(renderStyle);

  @override
  bool get isRepaintBoundary => true;

  RenderIntrinsic toIntrinsic() {
    RenderObject? childRenderObject = child;
    child = null;
    RenderIntrinsic newChild = RenderIntrinsic(renderStyle);
    newChild.child = childRenderObject as RenderBox?;
    return copyWith(newChild);
  }
}
