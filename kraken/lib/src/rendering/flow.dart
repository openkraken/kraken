/*
 * Copyright (C) 2020-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:kraken/css.dart';
import 'package:kraken/module.dart';
import 'package:kraken/rendering.dart';

// Position and size of each run (line box) in flow layout.
// https://www.w3.org/TR/css-inline-3/#line-boxes
class _RunMetrics {
  _RunMetrics(
    this.mainAxisExtent,
    this.crossAxisExtent,
    this.baselineExtent,
    this.runChildren,
  );

  // Main size extent of the run.
  final double mainAxisExtent;

  // Cross size extent of the run.
  final double crossAxisExtent;

  // Max extent above each flex items in the run.
  final double baselineExtent;

  // All the children RenderBox of layout in the run.
  final Map<int?, RenderBox> runChildren;
}

/// ## Layout algorithm
///
/// _This section describes how the framework causes [RenderFlowLayout] to position
/// its children._
///
/// Layout for a [RenderFlowLayout] proceeds in 5 steps:
///
/// 1. Layout positioned (eg. absolute/fixed) child first cause the size of position placeholder renderObject which is
///    layouted later depends on the size of its original RenderBoxModel.
/// 2. Layout children (not including positioned child) with no constraints and compute information of line boxes.
/// 3. Set container size depends on children size and container size styles (eg. width/height).
/// 4. Set children offset based on flow container size and flow alignment styles (eg. text-align).
/// 5. Set positioned children offset based on flow container size and its offset styles (eg. top/right/bottom/right).
///
class RenderFlowLayout extends RenderLayoutBox {
  RenderFlowLayout({
    List<RenderBox>? children,
    required CSSRenderStyle renderStyle,
  }) : super(renderStyle: renderStyle) {
    addAll(children);
  }

  // Line boxes of flow layout.
  // https://www.w3.org/TR/css-inline-3/#line-boxes
  List<_RunMetrics> _lineBoxMetrics = <_RunMetrics>[];

  @override
  void dispose() {
    super.dispose();

    // Do not forget to clear reference variables, or it will cause memory leaks!
    _lineBoxMetrics.clear();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! RenderLayoutParentData) {
      child.parentData = RenderLayoutParentData();
    }
    if (child is RenderBoxModel) {
      child.parentData = CSSPositionedLayout.getPositionParentData(
          child, child.parentData as RenderLayoutParentData);
    }
  }

  double _getMainAxisExtent(RenderBox child) {
    double marginHorizontal = 0;

    if (child is RenderBoxModel) {
      marginHorizontal = child.renderStyle.marginLeft.computedValue +
          child.renderStyle.marginRight.computedValue;
    }

    Size childSize = _getChildSize(child) ?? Size.zero;

    return childSize.width + marginHorizontal;
  }

  double _getCrossAxisExtent(RenderBox child) {
    bool isLineHeightValid = _isLineHeightValid(child);
    double? lineHeight = isLineHeightValid ? _getLineHeight(child) : 0;
    double marginVertical = 0;

    if (child is RenderBoxModel) {
      marginVertical = _getChildMarginTop(child) + _getChildMarginBottom(child);
    }
    Size childSize = _getChildSize(child) ?? Size.zero;

    return lineHeight != null
      ? math.max(lineHeight, childSize.height) + marginVertical
      : childSize.height + marginVertical;
  }

  Offset _getOffset(double mainAxisOffset, double crossAxisOffset) {
    return Offset(mainAxisOffset, crossAxisOffset);
  }

  double _getChildCrossAxisOffset(
    double runCrossAxisExtent,
    double childCrossAxisExtent
  ) {
    return runCrossAxisExtent - childCrossAxisExtent;
  }

  double? _getLineHeight(RenderBox child) {
    CSSLengthValue? lineHeight;
    if (child is RenderTextBox) {
      lineHeight = renderStyle.lineHeight;
    } else if (child is RenderBoxModel) {
      lineHeight = child.renderStyle.lineHeight;
    } else if (child is RenderPositionPlaceholder) {
      lineHeight = child.positioned!.renderStyle.lineHeight;
    }

    if (lineHeight != null && lineHeight.type != CSSLengthType.NORMAL) {
      return lineHeight.computedValue;
    }
    return null;
  }

  @override
  void performLayout() {
    if (kProfileMode && PerformanceTiming.enabled()) {
      childLayoutDuration = 0;
      PerformanceTiming.instance()
        .mark(PERF_FLOW_LAYOUT_START, uniqueId: hashCode);
    }

    _doPerformLayout();

    if (needsRelayout) {
      _doPerformLayout();
      needsRelayout = false;
    }

    if (kProfileMode && PerformanceTiming.enabled()) {
      DateTime flowLayoutEndTime = DateTime.now();
      int amendEndTime =
        flowLayoutEndTime.microsecondsSinceEpoch - childLayoutDuration;
      PerformanceTiming.instance().mark(PERF_FLOW_LAYOUT_END,
        uniqueId: hashCode, startTime: amendEndTime);
    }
  }

  void _doPerformLayout() {
    beforeLayout();

    List<RenderBoxModel> _positionedChildren = [];
    List<RenderBox> _nonPositionedChildren = [];
    List<RenderBoxModel> _stickyChildren = [];

    // Prepare children of different type for layout.
    RenderBox? child = firstChild;
    while (child != null) {
      final RenderLayoutParentData childParentData = child.parentData as RenderLayoutParentData;
      if (child is RenderBoxModel && childParentData.isPositioned) {
        _positionedChildren.add(child);
      } else {
        _nonPositionedChildren.add(child);
        if (child is RenderBoxModel && CSSPositionedLayout.isSticky(child)) {
          _stickyChildren.add(child);
        }
      }
      child = childParentData.nextSibling;
    }

    // Need to layout out of flow positioned element before normal flow element
    // cause the size of RenderPositionPlaceholder in flex layout needs to use
    // the size of its original RenderBoxModel.
    for (RenderBoxModel child in _positionedChildren) {
      CSSPositionedLayout.layoutPositionedChild(this, child);
    }

    // Layout non positioned element (include element in flow and
    // placeholder of positioned element).
    _layoutChildren(_nonPositionedChildren);

    // Set offset of positioned element after flex box size is set.
    for (RenderBoxModel child in _positionedChildren) {
      CSSPositionedLayout.applyPositionedChildOffset(this, child);
      // Position of positioned element affect the scroll size of container.
      extendMaxScrollableSize(child);
      ensureBoxSizeLargerThanScrollableSize();
    }

    // Set offset of sticky element on each layout.
    for (RenderBoxModel child in _stickyChildren) {
      RenderBoxModel scrollContainer = child.findScrollContainer()!;
      // Sticky offset depends on the layout of scroll container, delay the calculation of
      // sticky offset to the layout stage of  scroll container if its not layouted yet
      // due to the layout order of Flutter renderObject tree is from down to up.
      if (scrollContainer.hasSize) {
        CSSPositionedLayout.applyStickyChildOffset(scrollContainer, child);
      }
    }

    bool isScrollContainer =
      renderStyle.effectiveOverflowX != CSSOverflowType.visible
      || renderStyle.effectiveOverflowY != CSSOverflowType.visible;

    if (isScrollContainer) {
      // Find all the sticky children when scroll container is layouted.
      stickyChildren = findStickyChildren();
      // Calculate the offset of its sticky children.
      for (RenderBoxModel stickyChild in stickyChildren) {
        CSSPositionedLayout.applyStickyChildOffset(this, stickyChild);
      }
    }

    didLayout();
  }


  // There are 3 steps for layout children.
  // 1. Layout children to generate line boxes metrics.
  // 2. Set flex container size according to children size and its own size styles.
  // 3. Align children according to alignment properties.
  void _layoutChildren(List<RenderBox> children) {
    // If no child exists, stop layout.
    if (children.isEmpty) {
      _setContainerSizeWithNoChild();
      return;
    }

    // Layout children to compute metrics of lines.
    List<_RunMetrics> _runMetrics = _computeRunMetrics(children);

    // Set container size.
    _setContainerSize(_runMetrics);

    // Set children offset based on alignment properties.
    _setChildrenOffset(_runMetrics);
  }

  // Layout children in normal flow order to calculate metrics of lines according to its constraints
  // and alignment properties.
  List<_RunMetrics> _computeRunMetrics(
    List<RenderBox> children,
    ) {
    List<_RunMetrics> _runMetrics = <_RunMetrics>[];
    double mainAxisLimit = renderStyle.contentMaxConstraintsWidth;

    double runMainAxisExtent = 0.0;
    double runCrossAxisExtent = 0.0;
    RenderBox? preChild;
    double maxSizeAboveBaseline = 0;
    double maxSizeBelowBaseline = 0;
    Map<int?, RenderBox> runChildren = {};

    WhiteSpace? whiteSpace = renderStyle.whiteSpace;

    for (RenderBox child in children) {
      final RenderLayoutParentData childParentData = child.parentData as RenderLayoutParentData;
      int childNodeId = child.hashCode;

      BoxConstraints childConstraints;
      if (child is RenderBoxModel) {
        childConstraints = child.getConstraints();
      } else if (child is RenderTextBox) {
        childConstraints = child.getConstraints();
      } else if (child is RenderPositionPlaceholder) {
        childConstraints = BoxConstraints();
      } else {
        // RenderObject of custom element need to inherit constraints from its parents
        // which adhere to flutter's rule.
        childConstraints = constraints;
      }

      // Whether child need to layout.
      bool isChildNeedsLayout = true;

      if (child.hasSize &&
        !needsRelayout &&
        (childConstraints == child.constraints) &&
        ((child is RenderBoxModel && !child.needsLayout) ||
          (child is RenderTextBox && !child.needsLayout))) {
        isChildNeedsLayout = false;
      }

      if (isChildNeedsLayout) {
        late DateTime childLayoutStart;
        if (kProfileMode && PerformanceTiming.enabled()) {
          childLayoutStart = DateTime.now();
        }

        // Inflate constraints of percentage renderBoxModel to force it layout after percentage resolved
        // cause Flutter will skip child layout if its constraints not changed between two layouts.
        if (child is RenderBoxModel && needsRelayout) {
          childConstraints = BoxConstraints(
            minWidth: childConstraints.maxWidth != double.infinity
              ? childConstraints.maxWidth
              : 0,
            maxWidth: double.infinity,
            minHeight: childConstraints.maxHeight != double.infinity
              ? childConstraints.maxHeight
              : 0,
            maxHeight: double.infinity,
          );
        }
        child.layout(childConstraints, parentUsesSize: true);

        if (kProfileMode && PerformanceTiming.enabled()) {
          DateTime childLayoutEnd = DateTime.now();
          childLayoutDuration += (childLayoutEnd.microsecondsSinceEpoch -
            childLayoutStart.microsecondsSinceEpoch);
        }
      }

      double childMainAxisExtent = _getMainAxisExtent(child);
      double childCrossAxisExtent = _getCrossAxisExtent(child);

      if (isPositionPlaceholder(child)) {
        RenderPositionPlaceholder positionHolder = child as RenderPositionPlaceholder;
        RenderBoxModel? childRenderBoxModel = positionHolder.positioned;
        if (childRenderBoxModel != null) {
          RenderLayoutParentData childParentData =
          childRenderBoxModel.parentData as RenderLayoutParentData;
          if (childParentData.isPositioned) {
            childMainAxisExtent = childCrossAxisExtent = 0;
          }
        }
      }
      if (runChildren.isNotEmpty &&
        // Current is block.
        (_isChildBlockLevel(child) ||
          // Previous is block.
          _isChildBlockLevel(preChild) ||
          // Line length is exceed container.
          // The white-space property not only specifies whether and how white space is collapsed
          // but only specifies whether lines may wrap at unforced soft wrap opportunities
          // https://www.w3.org/TR/css-text-3/#line-breaking
          (whiteSpace != WhiteSpace.nowrap && (runMainAxisExtent + childMainAxisExtent > mainAxisLimit)) ||
          // Previous is linebreak.
          preChild is RenderLineBreak)) {
        _runMetrics.add(_RunMetrics(
          runMainAxisExtent,
          runCrossAxisExtent,
          maxSizeAboveBaseline,
          runChildren,
        ));
        runChildren = {};
        runMainAxisExtent = 0.0;
        runCrossAxisExtent = 0.0;
        maxSizeAboveBaseline = 0.0;
        maxSizeBelowBaseline = 0.0;
      }
      runMainAxisExtent += childMainAxisExtent;

      // Calculate baseline extent of layout box.
      RenderStyle? childRenderStyle = _getChildRenderStyle(child);
      VerticalAlign verticalAlign = VerticalAlign.baseline;
      if (childRenderStyle != null) {
        verticalAlign = childRenderStyle.verticalAlign;
      }

      bool isLineHeightValid = _isLineHeightValid(child);

      // Vertical align is only valid for inline box.
      if (verticalAlign == VerticalAlign.baseline && isLineHeightValid) {
        double childMarginTop = 0;
        double childMarginBottom = 0;
        if (child is RenderBoxModel) {
          childMarginTop = _getChildMarginTop(child);
          childMarginBottom = _getChildMarginBottom(child);
        }

        Size childSize = _getChildSize(child)!;
        double? lineHeight = _getLineHeight(child);
        // Leading space between content box and virtual box of child.
        double childLeading = 0;
        if (child is! RenderTextBox && lineHeight != null) {
          childLeading = lineHeight - childSize.height;
        }

        // When baseline of children not found, use boundary of margin bottom as baseline.
        double childAscent = _getChildAscent(child);

        double extentAboveBaseline = childAscent + childLeading / 2;
        double extentBelowBaseline = childMarginTop +
          childSize.height +
          childMarginBottom -
          childAscent +
          childLeading / 2;

        maxSizeAboveBaseline = math.max(
          extentAboveBaseline,
          maxSizeAboveBaseline,
        );

        maxSizeBelowBaseline = math.max(
          extentBelowBaseline,
          maxSizeBelowBaseline,
        );
        runCrossAxisExtent = math.max(runCrossAxisExtent, maxSizeAboveBaseline + maxSizeBelowBaseline);
      } else {
        runCrossAxisExtent = math.max(runCrossAxisExtent, childCrossAxisExtent);
      }
      runChildren[childNodeId] = child;

      childParentData.runIndex = _runMetrics.length;
      preChild = child;
    }

    if (runChildren.isNotEmpty) {
      _runMetrics.add(_RunMetrics(
        runMainAxisExtent,
        runCrossAxisExtent,
        maxSizeAboveBaseline,
        runChildren,
      ));
    }

    _lineBoxMetrics = _runMetrics;

    return _runMetrics;
  }

  // Find the size in the cross axis of lines.
  // @TODO: add cache to avoid recalculate in one layout stage.
  double _getRunsCrossSize(
    List<_RunMetrics> _runMetrics,
    ) {
    double crossSize = 0;
    for (_RunMetrics run in _runMetrics) {
      crossSize += run.crossAxisExtent;
    }
    return crossSize;
  }

  // Find the max size in the main axis of lines.
  // @TODO: add cache to avoid recalculate in one layout stage.
  double _getRunsMaxMainSize(
    List<_RunMetrics> _runMetrics,
    ) {
    // Find the max size of lines.
    _RunMetrics maxMainSizeMetrics =
    _runMetrics.reduce((_RunMetrics curr, _RunMetrics next) {
      return curr.mainAxisExtent > next.mainAxisExtent ? curr : next;
    });
    return maxMainSizeMetrics.mainAxisExtent;
  }

  // Set flex container size according to children size.
  void _setContainerSize(
    List<_RunMetrics> _runMetrics,
    ) {
    if (_runMetrics.isEmpty) {
      _setContainerSizeWithNoChild();
      return;
    }

    double runMaxMainSize = _getRunsMaxMainSize(_runMetrics);
    double runCrossSize = _getRunsCrossSize(_runMetrics);

    Size layoutContentSize = getContentSize(
      contentWidth: runMaxMainSize,
      contentHeight: runCrossSize,
    );

    size = getBoxSize(layoutContentSize);

    _setMaxScrollableSizeForFlow(_runMetrics);

    autoMinWidth = _getMainAxisAutoSize(_runMetrics);
    autoMinHeight = _getCrossAxisAutoSize(_runMetrics);
  }

  // Set size when layout has no child.
  void _setContainerSizeWithNoChild() {
    Size layoutContentSize = getContentSize(
      contentWidth: 0,
      contentHeight: 0,
    );
    setMaxScrollableSize(layoutContentSize);
    size = getBoxSize(layoutContentSize);
  }

  // Set children offset based on alignment properties.
  void _setChildrenOffset(
    List<_RunMetrics> _runMetrics,
  ) {
    if (_runMetrics.isEmpty) return;

    double runLeadingSpace = 0;
    double runBetweenSpace = 0;
    // Cross axis offset of each flex line.
    double crossAxisOffset = runLeadingSpace;
    double mainAxisContentSize = contentSize.width;

    // Set offset of children in each line.
    for (int i = 0; i < _runMetrics.length; ++i) {
      final _RunMetrics metrics = _runMetrics[i];
      final double runMainAxisExtent = metrics.mainAxisExtent;
      final double runCrossAxisExtent = metrics.crossAxisExtent;
      final double runBaselineExtent = metrics.baselineExtent;
      final Map<int?, RenderBox> runChildren = metrics.runChildren;
      final List<RenderBox> runChildrenList = runChildren.values.toList();
      final int runChildrenCount = metrics.runChildren.length;
      final double mainAxisFreeSpace = math.max(0.0, mainAxisContentSize - runMainAxisExtent);

      double childLeadingSpace = 0.0;
      double childBetweenSpace = 0.0;

      // Whether inline level child exists in this run.
      bool runContainInlineChild = true;

      int? firstChildKey = runChildren.keys.elementAt(0);
      RenderBox? firstChild = runChildren[firstChildKey];
      // Block level and inline level child can not exists at the same run,
      // so only need to loop the first child.
      if (firstChild is RenderBoxModel) {
        CSSDisplay? childEffectiveDisplay = firstChild.renderStyle.effectiveDisplay;
        runContainInlineChild = childEffectiveDisplay != CSSDisplay.block && childEffectiveDisplay != CSSDisplay.flex;
      }

      // Text-align only works on inline level children.
      if (runContainInlineChild) {
        switch (renderStyle.textAlign) {
          case TextAlign.left:
          case TextAlign.start:
            break;
          case TextAlign.right:
          case TextAlign.end:
            childLeadingSpace = mainAxisFreeSpace;
            break;
          case TextAlign.center:
            childLeadingSpace = mainAxisFreeSpace / 2.0;
            break;
          case TextAlign.justify:
            childBetweenSpace = runChildrenCount > 1 ? mainAxisFreeSpace / (runChildrenCount - 1) : 0.0;
            break;
          default:
            break;
        }
      }

      double childMainPosition = childLeadingSpace;

      for (RenderBox child in runChildrenList) {
        final double childMainAxisExtent = _getMainAxisExtent(child);
        final double childCrossAxisExtent = _getCrossAxisExtent(child);

        // Calculate margin auto length according to CSS spec
        // https://www.w3.org/TR/CSS21/visudet.html#blockwidth
        // margin-left and margin-right auto takes up available space
        // between element and its containing block on block-level element
        // which is not positioned and computed to 0px in other cases.
        if (child is RenderBoxModel) {
          RenderStyle childRenderStyle = child.renderStyle;
          CSSDisplay? childEffectiveDisplay =
            childRenderStyle.effectiveDisplay;
          CSSLengthValue marginLeft = childRenderStyle.marginLeft;
          CSSLengthValue marginRight = childRenderStyle.marginRight;

          // 'margin-left' + 'border-left-width' + 'padding-left' + 'width' + 'padding-right' +
          // 'border-right-width' + 'margin-right' = width of containing block
          if (childEffectiveDisplay == CSSDisplay.block ||
            childEffectiveDisplay == CSSDisplay.flex) {
            if (marginLeft.isAuto) {
              double remainingSpace = mainAxisContentSize - childMainAxisExtent;
              if (marginRight.isAuto) {
                childMainPosition = remainingSpace / 2;
              } else {
                childMainPosition = remainingSpace;
              }
            }
          }
        }

        // Always align to the top of run when positioning positioned element placeholder
        // @HACK(kraken): Judge positioned holder to impl top align.
        final double childCrossAxisOffset = isPositionPlaceholder(child)
          ? 0
          : _getChildCrossAxisOffset(runCrossAxisExtent, childCrossAxisExtent);

        Size? childSize = _getChildSize(child);
        // Line height of child.
        double? childLineHeight = _getLineHeight(child);
        // Leading space between content box and virtual box of child.
        double childLeading = 0;
        if (childLineHeight != null) {
          childLeading = childLineHeight - childSize!.height;
        }
        // Child line extent calculated according to vertical align.
        double childLineExtent = childCrossAxisOffset;

        bool isLineHeightValid = _isLineHeightValid(child);
        if (isLineHeightValid) {
          // Distance from top to baseline of child.
          double childAscent = _getChildAscent(child);

          RenderStyle childRenderStyle = _getChildRenderStyle(child)!;
          VerticalAlign verticalAlign = childRenderStyle.verticalAlign;

          // Leading between height of line box's content area and line height of line box.
          double lineBoxLeading = 0;
          double? lineBoxHeight = _getLineHeight(this);
          if (child is! RenderTextBox && lineBoxHeight != null) {
            lineBoxLeading = lineBoxHeight - runCrossAxisExtent;
          }

          switch (verticalAlign) {
            case VerticalAlign.baseline:
              childLineExtent =
                lineBoxLeading / 2 + (runBaselineExtent - childAscent);
              break;
            case VerticalAlign.top:
              childLineExtent = childLeading / 2;
              break;
            case VerticalAlign.bottom:
              childLineExtent =
                (lineBoxHeight ?? runCrossAxisExtent) -
                  childSize!.height -
                  childLeading / 2;
              break;
          // @TODO: Vertical align middle needs to caculate the baseline of the parent box plus
          //  half the x-height of the parent from W3C spec currently flutter lack the api to calculate x-height of glyph.
          //  case VerticalAlign.middle:
          //  break;
          }
        }

        double? childMarginLeft = 0;
        double? childMarginTop = 0;

        RenderBoxModel? childRenderBoxModel;
        if (child is RenderBoxModel) {
          childRenderBoxModel = child;
        } else if (child is RenderPositionPlaceholder) {
          childRenderBoxModel = child.positioned;
        }

        if (childRenderBoxModel is RenderBoxModel) {
          childMarginLeft = childRenderBoxModel.renderStyle.marginLeft.computedValue;
          childMarginTop = _getChildMarginTop(childRenderBoxModel);
        }

        // No need to add padding and border for scrolling content box.
        Offset relativeOffset = _getOffset(
          childMainPosition +
            renderStyle.paddingLeft.computedValue +
            renderStyle.effectiveBorderLeftWidth.computedValue +
            childMarginLeft,
          crossAxisOffset +
            childLineExtent +
            renderStyle.paddingTop.computedValue +
            renderStyle.effectiveBorderTopWidth.computedValue +
            childMarginTop);
        // Apply position relative offset change.
        CSSPositionedLayout.applyRelativeOffset(relativeOffset, child);

        childMainPosition += childMainAxisExtent + childBetweenSpace;
      }

      crossAxisOffset += runCrossAxisExtent + runBetweenSpace;
    }
  }

  // Compute distance to baseline of flow layout.
  @override
  double? computeDistanceToBaseline() {
    double? lineDistance;
    CSSDisplay? effectiveDisplay = renderStyle.effectiveDisplay;
    bool isInline = effectiveDisplay == CSSDisplay.inline;
    // Margin does not work for inline element.
    double marginTop = !isInline ? renderStyle.marginTop.computedValue : 0;
    double marginBottom = !isInline ? renderStyle.marginBottom.computedValue : 0;
    bool isParentFlowLayout = parent is RenderFlowLayout;
    bool isDisplayInline = effectiveDisplay == CSSDisplay.inline ||
        effectiveDisplay == CSSDisplay.inlineBlock ||
        effectiveDisplay == CSSDisplay.inlineFlex;

    // Use margin bottom as baseline if layout has no children.
    if (_lineBoxMetrics.isEmpty) {
      if (isDisplayInline) {
        // Flex item baseline does not includes margin-bottom.
        lineDistance = isParentFlowLayout
            ? marginTop + boxSize!.height + marginBottom
            : marginTop + boxSize!.height;
        return lineDistance;
      } else {
        return null;
      }
    }

    // Use baseline of last line in flow layout and layout is inline-level
    // otherwise use baseline of first line.
    bool isLastLineBaseline = isParentFlowLayout && isDisplayInline;
    _RunMetrics lineMetrics = isLastLineBaseline
        ? _lineBoxMetrics[_lineBoxMetrics.length - 1]
        : _lineBoxMetrics[0];
    // Use the max baseline of the children as the baseline in flow layout.
    lineMetrics.runChildren.forEach((int? hashCode, RenderBox child) {
      double? childMarginTop =
          child is RenderBoxModel ? _getChildMarginTop(child) : 0;
      RenderLayoutParentData? childParentData =
          child.parentData as RenderLayoutParentData?;
      double? childBaseLineDistance;
      if (child is RenderBoxModel) {
        childBaseLineDistance = child.computeDistanceToBaseline();
      } else if (child is RenderTextBox) {
        // Text baseline not depends on its own parent but its grand parents.
        childBaseLineDistance = isLastLineBaseline
            ? child.computeDistanceToLastLineBaseline()
            : child.computeDistanceToFirstLineBaseline();
      }
      if (childBaseLineDistance != null && childParentData != null) {
        // Baseline of relative positioned element equals its original position
        // so it needs to subtract its vertical offset.
        Offset? relativeOffset;
        double childOffsetY = childParentData.offset.dy - childMarginTop;
        if (child is RenderBoxModel) {
          relativeOffset =
              CSSPositionedLayout.getRelativeOffset(child.renderStyle);
        }
        if (relativeOffset != null) {
          childOffsetY -= relativeOffset.dy;
        }
        // It needs to subtract margin-top cause offset already includes margin-top.
        childBaseLineDistance += childOffsetY;
        if (lineDistance != null)
          lineDistance = math.max(lineDistance!, childBaseLineDistance);
        else
          lineDistance = childBaseLineDistance;
      }
    });

    // If no inline child found, use margin-bottom as baseline.
    if (isDisplayInline && lineDistance != null) {
      lineDistance = lineDistance! + marginTop;
    }
    return lineDistance;
  }

  // Record the main size of all lines.
  void _recordRunsMainSize(_RunMetrics runMetrics, List<double> runMainSize) {
    Map<int?, RenderBox> runChildren = runMetrics.runChildren;
    double runMainExtent = 0;
    void iterateRunChildren(int? hashCode, RenderBox runChild) {
      double runChildMainSize = runChild.size.width;
      if (runChild is RenderTextBox) {
        runChildMainSize = runChild.autoMinWidth;
      }
      // Should add horizontal margin of child to the main axis auto size of parent.
      if (runChild is RenderBoxModel) {
        double childMarginLeft = runChild.renderStyle.marginLeft.computedValue;
        double childMarginRight = runChild.renderStyle.marginRight.computedValue;
        runChildMainSize += childMarginLeft + childMarginRight;
      }
      runMainExtent += runChildMainSize;
    }

    runChildren.forEach(iterateRunChildren);
    runMainSize.add(runMainExtent);
  }

  // Get auto min size in the main axis which equals the main axis size of its contents.
  // https://www.w3.org/TR/css-sizing-3/#automatic-minimum-size
  double _getMainAxisAutoSize(
    List<_RunMetrics> runMetrics,
  ) {
    double autoMinSize = 0;

    // Main size of each run.
    List<double> runMainSize = [];

    // Calculate the max main size of all runs.
    for (_RunMetrics runMetrics in runMetrics) {
      _recordRunsMainSize(runMetrics, runMainSize);
    }

    if (runMainSize.isNotEmpty) {
      autoMinSize = runMainSize.reduce((double curr, double next) {
        return curr > next ? curr : next;
      });
    }

    return autoMinSize;
  }

  // Record the cross size of all lines.
  void _recordRunsCrossSize(_RunMetrics runMetrics, List<double> runCrossSize) {
    Map<int?, RenderBox> runChildren = runMetrics.runChildren;
    double runCrossExtent = 0;
    List<double> runChildrenCrossSize = [];
    void iterateRunChildren(int? hashCode, RenderBox runChild) {
      double runChildCrossSize = runChild.size.height;
      if (runChild is RenderTextBox) {
        runChildCrossSize = runChild.autoMinHeight;
      }
      runChildrenCrossSize.add(runChildCrossSize);
    }

    runChildren.forEach(iterateRunChildren);
    runCrossExtent = runChildrenCrossSize.reduce((double curr, double next) {
      return curr > next ? curr : next;
    });

    runCrossSize.add(runCrossExtent);
  }

  // Get auto min size in the cross axis which equals the cross axis size of its contents.
  // https://www.w3.org/TR/css-sizing-3/#automatic-minimum-size
  double _getCrossAxisAutoSize(
    List<_RunMetrics> runMetrics,
  ) {
    double autoMinSize = 0;
    // Cross size of each run.
    List<double> runCrossSize = [];

    // Calculate the max cross size of all runs.
    for (_RunMetrics runMetrics in runMetrics) {
      _recordRunsCrossSize(runMetrics, runCrossSize);
    }

    // Get the sum of lines.
    for (double crossSize in runCrossSize) {
      autoMinSize += crossSize;
    }

    return autoMinSize;
  }

  // Set the size of scrollable overflow area for flow layout.
  // https://drafts.csswg.org/css-overflow-3/#scrollable
  void _setMaxScrollableSizeForFlow(List<_RunMetrics> runMetrics) {
    // Scrollable main size collection of each line.
    List<double> scrollableMainSizeOfLines = [];
    // Scrollable cross size collection of each line.
    List<double> scrollableCrossSizeOfLines = [];
    // Total cross size of previous lines.
    double preLinesCrossSize = 0;

    for (_RunMetrics runMetric in runMetrics) {
      Map<int?, RenderBox> runChildren = runMetric.runChildren;

      List<RenderBox> runChildrenList = [];
      // Scrollable main size collection of each child in the line.
      List<double> scrollableMainSizeOfChildren = [];
      // Scrollable cross size collection of each child in the line.
      List<double> scrollableCrossSizeOfChildren = [];

      void iterateRunChildren(int? hashCode, RenderBox child) {
        // Total main size of previous siblings.
        double preSiblingsMainSize = 0;
        for (RenderBox sibling in runChildrenList) {
          preSiblingsMainSize += sibling.size.width;
        }

        Size childScrollableSize = child.size;
        double? childMarginTop = 0;
        double? childMarginLeft = 0;
        if (child is RenderBoxModel) {
          RenderStyle childRenderStyle = child.renderStyle;
          CSSOverflowType overflowX = childRenderStyle.effectiveOverflowX;
          CSSOverflowType overflowY = childRenderStyle.effectiveOverflowY;
          // Only non scroll container need to use scrollable size, otherwise use its own size.
          if (overflowX == CSSOverflowType.visible &&
              overflowY == CSSOverflowType.visible) {
            childScrollableSize = child.scrollableSize;
          }
          childMarginTop = _getChildMarginTop(child);
          childMarginLeft = childRenderStyle.marginLeft.computedValue;
        }

        scrollableMainSizeOfChildren.add(
            preSiblingsMainSize + childScrollableSize.width + childMarginLeft);
        scrollableCrossSizeOfChildren
            .add(childScrollableSize.height + childMarginTop);
        runChildrenList.add(child);
      }

      runChildren.forEach(iterateRunChildren);

      // Max scrollable main size of all the children in the line.
      double maxScrollableMainSizeOfLine =
          scrollableMainSizeOfChildren.reduce((double curr, double next) {
        return curr > next ? curr : next;
      });

      // Max scrollable cross size of all the children in the line.
      double maxScrollableCrossSizeOfLine = preLinesCrossSize +
          scrollableCrossSizeOfChildren.reduce((double curr, double next) {
            return curr > next ? curr : next;
          });

      scrollableMainSizeOfLines.add(maxScrollableMainSizeOfLine);
      scrollableCrossSizeOfLines.add(maxScrollableCrossSizeOfLine);
      preLinesCrossSize += runMetric.crossAxisExtent;
    }

    // Max scrollable main size of all lines.
    double maxScrollableMainSizeOfLines =
        scrollableMainSizeOfLines.reduce((double curr, double next) {
      return curr > next ? curr : next;
    });

    RenderBoxModel container =
        isScrollingContentBox ? parent as RenderBoxModel : this;
    bool isScrollContainer =
        renderStyle.effectiveOverflowX != CSSOverflowType.visible ||
        renderStyle.effectiveOverflowY != CSSOverflowType.visible;

    // No need to add padding for scrolling content box.
    double maxScrollableMainSizeOfChildren = isScrollContainer
        ? maxScrollableMainSizeOfLines
        : container.renderStyle.paddingLeft.computedValue + maxScrollableMainSizeOfLines;

    // Max scrollable cross size of all lines.
    double maxScrollableCrossSizeOfLines =
        scrollableCrossSizeOfLines.reduce((double curr, double next) {
      return curr > next ? curr : next;
    });

    // No need to add padding for scrolling content box.
    double maxScrollableCrossSizeOfChildren = isScrollContainer
        ? maxScrollableCrossSizeOfLines
        : container.renderStyle.paddingTop.computedValue + maxScrollableCrossSizeOfLines;

    double maxScrollableMainSize = math.max(
        size.width -
            container.renderStyle.effectiveBorderLeftWidth.computedValue -
            container.renderStyle.effectiveBorderRightWidth.computedValue,
        maxScrollableMainSizeOfChildren);
    double maxScrollableCrossSize = math.max(
        size.height -
            container.renderStyle.effectiveBorderTopWidth.computedValue -
            container.renderStyle.effectiveBorderBottomWidth.computedValue,
        maxScrollableCrossSizeOfChildren);

    scrollableSize = Size(maxScrollableMainSize, maxScrollableCrossSize);
  }

  // Get distance from top to baseline of child including margin.
  double _getChildAscent(RenderBox child) {
    // Distance from top to baseline of child.
    double? childAscent =
        child.getDistanceToBaseline(TextBaseline.alphabetic, onlyReal: true);
    double? childMarginTop = 0;
    double? childMarginBottom = 0;
    if (child is RenderBoxModel) {
      childMarginTop = _getChildMarginTop(child);
      childMarginBottom = _getChildMarginBottom(child);
    }

    Size? childSize = _getChildSize(child);

    double baseline = parent is RenderFlowLayout
        ? childMarginTop + childSize!.height + childMarginBottom
        : childMarginTop + childSize!.height;
    // When baseline of children not found, use boundary of margin bottom as baseline.
    double extentAboveBaseline = childAscent ?? baseline;

    return extentAboveBaseline;
  }

  // Get child size through boxSize to avoid flutter error when parentUsesSize is set to false.
  Size? _getChildSize(RenderBox child) {
    if (child is RenderBoxModel) {
      return child.boxSize;
    } else if (child is RenderPositionPlaceholder) {
      return child.boxSize;
    } else if (child is RenderTextBox) {
      return child.boxSize;
    }
    return null;
  }

  bool _isLineHeightValid(RenderBox child) {
    if (child is RenderTextBox) {
      return true;
    } else if (child is RenderBoxModel) {
      CSSDisplay? childDisplay = child.renderStyle.display;
      return childDisplay == CSSDisplay.inline ||
        childDisplay == CSSDisplay.inlineBlock ||
        childDisplay == CSSDisplay.inlineFlex;
    }
    return false;
  }

  RenderStyle? _getChildRenderStyle(RenderBox child) {
    RenderStyle? childRenderStyle;
    if (child is RenderTextBox) {
      childRenderStyle = renderStyle;
    } else if (child is RenderBoxModel) {
      childRenderStyle = child.renderStyle;
    } else if (child is RenderPositionPlaceholder) {
      childRenderStyle = child.positioned!.renderStyle;
    }
    return childRenderStyle;
  }

  bool _isChildBlockLevel(RenderBox? child) {
    if (child is RenderBoxModel || child is RenderPositionPlaceholder) {
      RenderStyle? childRenderStyle = _getChildRenderStyle(child!);
      if (childRenderStyle != null) {
        CSSDisplay? childDisplay = childRenderStyle.display;
        return childDisplay == CSSDisplay.block ||
            childDisplay == CSSDisplay.flex;
      }
    }
    return false;
  }

  // Get the collapsed margin top with the margin-bottom of its previous sibling.
  double _getCollapsedMarginTopWithPreSibling(RenderBoxModel renderBoxModel, RenderObject preSibling, double marginTop) {
    if (preSibling is RenderBoxModel &&
      (preSibling.renderStyle.effectiveDisplay == CSSDisplay.block ||
      preSibling.renderStyle.effectiveDisplay == CSSDisplay.flex)
    ) {
      double preSiblingMarginBottom = _getChildMarginBottom(preSibling);
      if (marginTop > 0 && preSiblingMarginBottom > 0) {
        return math.max(marginTop - preSiblingMarginBottom, 0);
      }
    }
    return marginTop;
  }

  // Get the collapsed margin top with parent if it is the first child of its parent.
  double _getCollapsedMarginTopWithParent(RenderBoxModel renderBoxModel, double marginTop) {
    RenderLayoutBox parent = renderBoxModel.parent as RenderLayoutBox;
    // Use parent renderStyle if renderBoxModel is scrollingContentBox cause its style is not
    // the same with its parent.
    RenderStyle parentRenderStyle = parent.isScrollingContentBox ?
      (parent.parent as RenderBoxModel).renderStyle : parent.renderStyle;

    bool isParentOverflowVisible = parentRenderStyle.effectiveOverflowY == CSSOverflowType.visible;
    bool isParentOverflowClip = parentRenderStyle.effectiveOverflowY == CSSOverflowType.clip;
    // Margin top of first child with parent which is in flow layout collapse with parent
    // which makes the margin top of itself 0.
    // Margin collapse does not work on document root box.
    if (!parent.isDocumentRootBox &&
      parentRenderStyle.effectiveDisplay == CSSDisplay.block &&
      (isParentOverflowVisible || isParentOverflowClip) &&
      parentRenderStyle.paddingTop.computedValue == 0 &&
      parentRenderStyle.effectiveBorderTopWidth.computedValue == 0 &&
      parent.parent is RenderFlowLayout
    ) {
      return 0;
    }
    return marginTop;
  }

  // Get the collapsed margin top with its nested first child.
  double _getCollapsedMarginTopWithNestedFirstChild(RenderBoxModel renderBoxModel) {
    // Use parent renderStyle if renderBoxModel is scrollingContentBox cause its style is not
    // the same with its parent.
    RenderStyle renderStyle = renderBoxModel.isScrollingContentBox ?
      (renderBoxModel.parent as RenderBoxModel).renderStyle : renderBoxModel.renderStyle;
    double paddingTop = renderStyle.paddingTop.computedValue;
    double borderTop = renderStyle.effectiveBorderTopWidth.computedValue;

    // Use own renderStyle of margin-top cause scrollingContentBox has margin-top of 0
    // which is correct.
    double marginTop = renderBoxModel.renderStyle.marginTop.computedValue;

    bool isOverflowVisible = renderStyle.effectiveOverflowY == CSSOverflowType.visible;
    bool isOverflowClip = renderStyle.effectiveOverflowY == CSSOverflowType.clip;

    if (renderBoxModel is RenderLayoutBox &&
      renderStyle.effectiveDisplay == CSSDisplay.block &&
      (isOverflowVisible || isOverflowClip) &&
      paddingTop == 0 &&
      borderTop == 0
    ) {
      RenderObject? firstChild = renderBoxModel.firstChild != null ?
        renderBoxModel.firstChild as RenderObject : null;
      if (firstChild is RenderBoxModel &&
        (firstChild.renderStyle.effectiveDisplay == CSSDisplay.block ||
        firstChild.renderStyle.effectiveDisplay == CSSDisplay.flex)
      ) {
        double childMarginTop = firstChild is RenderFlowLayout ?
        _getCollapsedMarginTopWithNestedFirstChild(firstChild) : firstChild.renderStyle.marginTop.computedValue;
        if (marginTop < 0 && childMarginTop < 0) {
          return math.min(marginTop, childMarginTop);
        } else if ((marginTop < 0 && childMarginTop > 0) || (marginTop > 0 && childMarginTop < 0)) {
          return marginTop + childMarginTop;
        } else {
          return math.max(marginTop, childMarginTop);
        }
      }
    }
    return marginTop;
  }

  // Get the collapsed margin top of child due to the margin collapse rule.
  // https://www.w3.org/TR/CSS2/box.html#collapsing-margins
  double _getChildMarginTop(RenderBoxModel child) {
    CSSDisplay? childEffectiveDisplay = child.renderStyle.effectiveDisplay;
    // Margin is invalid for inline element.
    if (childEffectiveDisplay == CSSDisplay.inline) {
      return 0;
    }
    double originalMarginTop = child.renderStyle.marginTop.computedValue;
    // Margin collapse does not work on following case:
    // 1. Document root element(HTML)
    // 2. Inline level elements
    // 3. Inner renderBox of element with overflow auto/scroll
    if (child.isDocumentRootBox ||
      (childEffectiveDisplay != CSSDisplay.block &&
      childEffectiveDisplay != CSSDisplay.flex)
    ) {
      return originalMarginTop;
    }

    RenderLayoutParentData childParentData = child.parentData as RenderLayoutParentData;
    RenderObject? preSibling = childParentData.previousSibling != null ?
      childParentData.previousSibling as RenderObject : null;

    // Margin top collapse with its nested first child when meeting following cases at the same time:
    // 1. No padding, border is set.
    // 2. No block formatting context of itself (eg. overflow scroll and position absolute) is created.
    double marginTop = _getCollapsedMarginTopWithNestedFirstChild(child);
    bool isChildOverflowVisible = child.renderStyle.effectiveOverflowX == CSSOverflowType.visible &&
      child.renderStyle.effectiveOverflowY == CSSOverflowType.visible;
    bool isChildOverflowClip = child.renderStyle.effectiveOverflowX == CSSOverflowType.clip &&
      child.renderStyle.effectiveOverflowY == CSSOverflowType.clip;

    // Margin top and bottom of empty block collapse.
    // Make collapsed margin-top to the max of its top and bottom and margin-bottom as 0.
    if (child.boxSize!.height == 0 &&
      childEffectiveDisplay != CSSDisplay.flex &&
      (isChildOverflowVisible || isChildOverflowClip)
    ) {
      double marginBottom = child.renderStyle.marginBottom.computedValue;
      marginTop = math.max(marginTop, marginBottom);
    }
    if (preSibling == null) {
      // Margin top collapse with its parent if it is the first child of its parent and its value is 0.
      marginTop = _getCollapsedMarginTopWithParent(child, marginTop);
    } else {
      // Margin top collapse with margin-bottom of its previous sibling, get the difference between
      // the margin top of itself and the margin bottom of ite previous sibling. Set it to 0 if the
      // difference is negative.
      marginTop = _getCollapsedMarginTopWithPreSibling(child, preSibling, marginTop);
    }
    return marginTop;
  }

  // Get the collapsed margin bottom with parent if it is the last child of its parent.
  double _getCollapsedMarginBottomWithParent(RenderBoxModel renderBoxModel, double marginBottom) {
    RenderLayoutBox parent = renderBoxModel.parent as RenderLayoutBox;
    // Use parent renderStyle if renderBoxModel is scrollingContentBox cause its style is not
    // the same with its parent.
    RenderStyle parentRenderStyle = parent.isScrollingContentBox ?
      (parent.parent as RenderBoxModel).renderStyle : parent.renderStyle;

    bool isParentOverflowVisible = parentRenderStyle.effectiveOverflowY == CSSOverflowType.visible;
    bool isParentOverflowClip = parentRenderStyle.effectiveOverflowY == CSSOverflowType.clip;
    // Margin bottom of first child with parent which is in flow layout collapse with parent
    // which makes the margin top of itself 0.
    // Margin collapse does not work on document root box.
    if (!parent.isDocumentRootBox &&
      parentRenderStyle.effectiveDisplay == CSSDisplay.block &&
      (isParentOverflowVisible || isParentOverflowClip) &&
      parentRenderStyle.paddingBottom.computedValue == 0 &&
      parentRenderStyle.effectiveBorderBottomWidth.computedValue == 0 &&
      parent.parent is RenderFlowLayout
    ) {
      return 0;
    }
    return marginBottom;
  }

  // Get the collapsed margin bottom with its nested last child.
  double _getCollapsedMarginBottomWithNestedLastChild(RenderBoxModel renderBoxModel) {
    // Use parent renderStyle if renderBoxModel is scrollingContentBox cause its style is not
    // the same with its parent.
    RenderStyle renderStyle = renderBoxModel.isScrollingContentBox ?
      (renderBoxModel.parent as RenderBoxModel).renderStyle : renderBoxModel.renderStyle;
    double paddingBottom = renderStyle.paddingBottom.computedValue;
    double borderBottom = renderStyle.effectiveBorderBottomWidth.computedValue;
    bool isOverflowVisible = renderStyle.effectiveOverflowY == CSSOverflowType.visible;
    bool isOverflowClip = renderStyle.effectiveOverflowY == CSSOverflowType.clip;

    // Use own renderStyle of margin-top cause scrollingContentBox has margin-bottom of 0
    // which is correct.
    double marginBottom = renderBoxModel.renderStyle.marginBottom.computedValue;

    if (renderBoxModel is RenderLayoutBox &&
      renderStyle.height.isAuto &&
      renderStyle.minHeight.isAuto &&
      renderStyle.maxHeight.isNone &&
      renderStyle.effectiveDisplay == CSSDisplay.block &&
      (isOverflowVisible || isOverflowClip) &&
      paddingBottom == 0 &&
      borderBottom == 0
    ) {
      RenderObject? lastChild = renderBoxModel.lastChild != null ?
        renderBoxModel.lastChild as RenderObject : null;
      if (lastChild is RenderBoxModel &&
        lastChild.renderStyle.effectiveDisplay == CSSDisplay.block) {
        double childMarginBottom = lastChild is RenderLayoutBox ?
        _getCollapsedMarginBottomWithNestedLastChild(lastChild) : lastChild.renderStyle.marginBottom.computedValue;
        if (marginBottom < 0 && childMarginBottom < 0) {
          return math.min(marginBottom, childMarginBottom);
        } else if ((marginBottom < 0 && childMarginBottom > 0) || (marginBottom > 0 && childMarginBottom < 0)) {
          return marginBottom + childMarginBottom;
        } else {
          return math.max(marginBottom, childMarginBottom);
        }
      }
    }

    return marginBottom;
  }

  // Get the collapsed margin bottom of child due to the margin collapse rule.
  // https://www.w3.org/TR/CSS2/box.html#collapsing-margins
  double _getChildMarginBottom(RenderBoxModel child) {
    CSSDisplay? childEffectiveDisplay = child.renderStyle.effectiveDisplay;
    // Margin is invalid for inline element.
    if (childEffectiveDisplay == CSSDisplay.inline) {
      return 0;
    }
    double originalMarginBottom = child.renderStyle.marginBottom.computedValue;
    // Margin collapse does not work on following case:
    // 1. Document root element(HTML)
    // 2. Inline level elements
    // 3. Inner renderBox of element with overflow auto/scroll
    if (child.isDocumentRootBox ||
      (childEffectiveDisplay != CSSDisplay.block &&
      childEffectiveDisplay != CSSDisplay.flex)
    ) {
      return originalMarginBottom;
    }

    bool isChildOverflowVisible = child.renderStyle.effectiveOverflowX == CSSOverflowType.visible &&
      child.renderStyle.effectiveOverflowY == CSSOverflowType.visible;
    bool isChildOverflowClip = child.renderStyle.effectiveOverflowX == CSSOverflowType.clip &&
      child.renderStyle.effectiveOverflowY == CSSOverflowType.clip;

    // Margin top and bottom of empty block collapse.
    // Make collapsed marign-top to the max of its top and bottom and margin-bottom as 0.
    if (child.boxSize!.height == 0 &&
      childEffectiveDisplay != CSSDisplay.flex &&
      (isChildOverflowVisible || isChildOverflowClip)
    ) {
      return 0;
    }

    RenderLayoutParentData childParentData = child.parentData as RenderLayoutParentData;
    RenderObject? nextSibling = childParentData.nextSibling != null ?
      childParentData.nextSibling as RenderObject : null;

    // Margin bottom collapse with its nested last child when meeting following cases at the same time:
    // 1. No padding, border is set.
    // 2. No height, min-height, max-height is set.
    // 3. No block formatting context of itself (eg. overflow scroll and position absolute) is created.
    double marginBottom = _getCollapsedMarginBottomWithNestedLastChild(child);
    if (nextSibling == null) {
      // Margin bottom collapse with its parent if it is the last child of its parent and its value is 0.
      marginBottom = _getCollapsedMarginBottomWithParent(child, marginBottom);
    }

    return marginBottom;
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {Offset? position}) {
    return defaultHitTestChildren(result, position: position);
  }

  @override
  void performPaint(PaintingContext context, Offset offset) {
    for (int i = 0; i < paintingOrder.length; i++) {
      RenderObject child = paintingOrder[i];
      if (child is! RenderPositionPlaceholder) {
        late DateTime childPaintStart;
        if (kProfileMode && PerformanceTiming.enabled()) {
          childPaintStart = DateTime.now();
        }
        final RenderLayoutParentData childParentData =
            child.parentData as RenderLayoutParentData;
        context.paintChild(child, childParentData.offset + offset);
        if (kProfileMode && PerformanceTiming.enabled()) {
          DateTime childPaintEnd = DateTime.now();
          childPaintDuration += (childPaintEnd.microsecondsSinceEpoch -
              childPaintStart.microsecondsSinceEpoch);
        }
      }
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
  }
}

// Render flex layout with self repaint boundary.
class RenderRepaintBoundaryFlowLayout extends RenderFlowLayout {
  RenderRepaintBoundaryFlowLayout({
    List<RenderBox>? children,
    required CSSRenderStyle renderStyle,
  }) : super(
    children: children,
    renderStyle: renderStyle,
  );

  @override
  bool get isRepaintBoundary => true;
}
