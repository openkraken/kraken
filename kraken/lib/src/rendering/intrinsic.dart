// @dart=2.9

/*
 * Copyright (C) 2020-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'package:flutter/foundation.dart';
import 'package:kraken/css.dart';
import 'package:flutter/rendering.dart';
import 'package:kraken/dom.dart';
import 'package:kraken/module.dart';
import 'package:kraken/rendering.dart';

class RenderIntrinsic extends RenderBoxModel
    with RenderObjectWithChildMixin<RenderBox>, RenderProxyBoxMixin<RenderBox> {
  RenderIntrinsic(int targetId, RenderStyle renderStyle, ElementManager elementManager)
      : super(targetId: targetId, renderStyle: renderStyle, elementManager: elementManager);

  BoxSizeType get widthSizeType {
    bool widthDefined = renderStyle.width != null || (renderStyle.minWidth != null);
    return widthDefined ? BoxSizeType.specified : BoxSizeType.intrinsic;
  }
  BoxSizeType get heightSizeType {
    bool heightDefined = renderStyle.height != null || (renderStyle.minHeight != null);
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
    if (kProfileMode) {
      childLayoutDuration = 0;
      PerformanceTiming.instance().mark(PERF_INTRINSIC_LAYOUT_START, uniqueId: targetId);
    }

    CSSDisplay display = renderStyle.display;
    if (display == CSSDisplay.none) {
      size = constraints.smallest;
      if (kProfileMode) {
        PerformanceTiming.instance().mark(PERF_INTRINSIC_LAYOUT_END, uniqueId: targetId);
      }
      return;
    }

    beforeLayout();

    double width = renderStyle.width;
    double height = renderStyle.height;
    double minWidth = renderStyle.minWidth;
    double minHeight = renderStyle.minHeight;
    double maxWidth = renderStyle.maxWidth;
    double maxHeight = renderStyle.maxHeight;

    if (child != null) {
      DateTime childLayoutStart;
      if (kProfileMode) {
        childLayoutStart = DateTime.now();
      }

      child.layout(contentConstraints, parentUsesSize: true);

      if (kProfileMode) {
        DateTime childLayoutEnd = DateTime.now();
        childLayoutDuration += (childLayoutEnd.microsecondsSinceEpoch) - childLayoutStart.microsecondsSinceEpoch;
      }

      setMaxScrollableSize(child.size.width, child.size.height);

      CSSDisplay transformedDisplay = renderStyle.transformedDisplay;
      bool isInlineLevel = transformedDisplay == CSSDisplay.inlineBlock || transformedDisplay == CSSDisplay.inlineFlex;

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
      performResize();
    }

    if (kProfileMode) {
      PerformanceTiming.instance().mark(PERF_INTRINSIC_LAYOUT_END, uniqueId: targetId);
    }
  }

  @override
  void performResize() {
    double width = 0, height = 0;
    if (constraints != null) {
      final Size attempingSize = constraints.biggest;
      if (attempingSize.width.isFinite) {
        width = attempingSize.width;
      }
      if (attempingSize.height.isFinite) {
        height = attempingSize.height;
      }
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
    double marginTop = renderStyle.marginTop.length ?? 0;
    double marginBottom = renderStyle.marginBottom.length ?? 0;

    // Use margin-bottom as baseline if layout has no children
    return marginTop + boxSize.height + marginBottom;
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
    if (renderStyle.padding != null) {
      offset += Offset(renderStyle.paddingLeft, renderStyle.paddingTop);
    }

    if (renderStyle.borderEdge != null) {
      offset += Offset(renderStyle.borderLeft, renderStyle.borderTop);
    }

    if (child != null) {
      DateTime childPaintStart;
      if (kProfileMode) {
        childPaintStart = DateTime.now();
      }
      context.paintChild(child, offset);
      if (kProfileMode) {
        DateTime childPaintEnd = DateTime.now();
        childPaintDuration += (childPaintEnd.microsecondsSinceEpoch - childPaintStart.microsecondsSinceEpoch);
      }
    }
  }

  RenderSelfRepaintIntrinsic toSelfRepaint() {
    RenderObject childRenderObject = child;
    child = null;
    RenderSelfRepaintIntrinsic newChild = RenderSelfRepaintIntrinsic(targetId, renderStyle, elementManager);
    newChild.child = childRenderObject;
    return copyWith(newChild);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {Offset position}) {
    if (renderStyle.transform != null) {
      return hitTestIntrinsicChild(result, child, position);
    }
    return super.hitTestChildren(result, position: position);
  }
}

class RenderSelfRepaintIntrinsic extends RenderIntrinsic {
  RenderSelfRepaintIntrinsic(int targetId, RenderStyle renderStyle, ElementManager elementManager):
        super(targetId, renderStyle, elementManager);

  @override
  bool get isRepaintBoundary => true;

  RenderIntrinsic toParentRepaint() {
    RenderObject childRenderObject = child;
    child = null;
    RenderIntrinsic newChild = RenderIntrinsic(targetId, renderStyle, elementManager);
    newChild.child = childRenderObject;
    return copyWith(newChild);
  }
}
