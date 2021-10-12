/*
 * Copyright (C) 2020-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'dart:math' as math;
import 'package:kraken/css.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:kraken/rendering.dart';
import 'package:kraken/dom.dart';
import 'package:kraken/module.dart';

/// Infos of each run (line box) in flow layout
/// https://www.w3.org/TR/css-inline-3/#line-boxes
class _RunMetrics {
  _RunMetrics(
    this.mainAxisExtent,
    this.crossAxisExtent,
    this.baselineExtent,
    this.runChildren,
  );

  // Main size extent of the run
  final double mainAxisExtent;

  // Cross size extent of the run
  final double crossAxisExtent;

  // Max extent above each flex items in the run
  final double baselineExtent;

  // All the children RenderBox of layout in the run
  final Map<int?, RenderBox> runChildren;
}

/// Impl flow layout algorithm.
class RenderFlowLayout extends RenderLayoutBox {
  RenderFlowLayout({
    List<RenderBox>? children,
    required RenderStyle renderStyle,
    required ElementDelegate elementDelegate
  }) : super(
    renderStyle: renderStyle,
    elementDelegate: elementDelegate
  ) {
    addAll(children);
  }

  /// The direction to use as the main axis.
  ///
  /// For example, if [direction] is [Axis.horizontal], the default, the
  /// children are placed adjacent to one another in a horizontal run until the
  /// available horizontal space is consumed, at which point a subsequent
  /// children are placed in a new run vertically adjacent to the previous run.
  Axis get direction => _direction;
  Axis _direction = Axis.horizontal;

  set direction(Axis value) {
    if (_direction == value) return;
    _direction = value;
    markNeedsLayout();
  }

  /// How the runs themselves should be placed in the cross axis.
  ///
  /// For example, if [runAlignment] is [MainAxisAlignment.center], the runs are
  /// grouped together in the center of the overall [RenderWrap] in the cross
  /// axis.
  ///
  /// Defaults to [MainAxisAlignment.start].
  ///
  MainAxisAlignment get runAlignment => _runAlignment;
  MainAxisAlignment _runAlignment = MainAxisAlignment.start;

  set runAlignment(MainAxisAlignment value) {
    if (_runAlignment == value) return;
    _runAlignment = value;
    markNeedsLayout();
  }

  /// If there is additional free space in the overall [RenderWrap] (e.g.,
  /// The distance by which the child's top edge is inset from the top of the stack.
  double? top;

  /// The distance by which the child's right edge is inset from the right of the stack.
  double? right;

  /// The distance by which the child's bottom edge is inset from the bottom of the stack.
  double? bottom;

  /// The distance by which the child's left edge is inset from the left of the stack.
  double? left;

  /// How the children within a run should be aligned relative to each other in
  /// the cross axis.
  ///
  /// For example, if this is set to [CrossAxisAlignment.end], and the
  /// [direction] is [Axis.horizontal], then the children within each
  /// run will have their bottom edges aligned to the bottom edge of the run.
  ///
  /// Defaults to [CrossAxisAlignment.end].
  ///
  CrossAxisAlignment get crossAxisAlignment => _crossAxisAlignment;
  CrossAxisAlignment _crossAxisAlignment = CrossAxisAlignment.end;

  set crossAxisAlignment(CrossAxisAlignment value) {
    if (_crossAxisAlignment == value) return;
    _crossAxisAlignment = value;
    markNeedsLayout();
  }

  /// Determines the order to lay children out horizontally and how to interpret
  /// `start` and `end` in the horizontal direction.
  ///
  /// If the [direction] is [Axis.horizontal], this controls the order in which
  /// children are positioned (left-to-right or right-to-left), and the meaning
  /// of the textAlign style's [TextAlign.start] and
  /// [TextAlign.end] values.
  ///
  /// If the [direction] is [Axis.horizontal], and either the
  /// textAlign style is either [TextAlign.start] or [TextAlign.end], or
  /// there's more than one child, then the [textDirection] must not be null.
  ///
  /// If the [direction] is [Axis.vertical], this controls the order in
  /// which runs are positioned, the meaning of the [runAlignment] property's
  /// [TextAlign.start] and [TextAlign.end] values, as well as the
  /// [crossAxisAlignment] property's [CrossAxisAlignment.start] and
  /// [CrossAxisAlignment.end] values.
  ///
  /// If the [direction] is [Axis.vertical], and either the
  /// [runAlignment] is either [MainAxisAlignment.start] or [MainAxisAlignment.end], the
  /// [crossAxisAlignment] is either [CrossAxisAlignment.start] or
  /// [CrossAxisAlignment.end], or there's more than one child, then the
  /// [textDirection] must not be null.
  TextDirection get textDirection => _textDirection;
  TextDirection _textDirection = TextDirection.ltr;

  set textDirection(TextDirection value) {
    if (_textDirection != value) {
      _textDirection = value;
      markNeedsLayout();
    }
  }

  /// Determines the order to lay children out vertically and how to interpret
  /// `start` and `end` in the vertical direction.
  ///
  /// If the [direction] is [Axis.vertical], this controls which order children
  /// are painted in (down or up), the meaning of the textAlign style's
  /// [TextAlign.start] and [TextAlign.end] values.
  ///
  /// If the [direction] is [Axis.vertical], and either the textAlign
  /// is either [TextAlign.start] or [TextAlign.end], or there's
  /// more than one child, then the [verticalDirection] must not be null.
  ///
  /// If the [direction] is [Axis.horizontal], this controls the order in which
  /// runs are positioned, the meaning of the [runAlignment] property's
  /// [MainAxisAlignment.start] and [MainAxisAlignment.end] values, as well as the
  /// [crossAxisAlignment] property's [CrossAxisAlignment.start] and
  /// [CrossAxisAlignment.end] values.
  ///
  /// If the [direction] is [Axis.horizontal], and either the
  /// [runAlignment] is either [MainAxisAlignment.start] or [MainAxisAlignment.end], the
  /// [crossAxisAlignment] is either [CrossAxisAlignment.start] or
  /// [CrossAxisAlignment.end], or there's more than one child, then the
  /// [verticalDirection] must not be null.
  VerticalDirection get verticalDirection => _verticalDirection;
  VerticalDirection _verticalDirection = VerticalDirection.down;

  set verticalDirection(VerticalDirection value) {
    if (_verticalDirection != value) {
      _verticalDirection = value;
      markNeedsLayout();
    }
  }

  /// Line boxes of flow layout
  List<_RunMetrics> lineBoxMetrics = <_RunMetrics>[];

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

  double _computeIntrinsicHeightForWidth(double width) {
    assert(direction == Axis.horizontal);
    double height = 0.0;
    double runWidth = 0.0;
    double runHeight = 0.0;
    int childCount = 0;
    RenderBox? child = firstChild;
    while (child != null) {
      final double childWidth = child.getMaxIntrinsicWidth(double.infinity);
      final double childHeight = child.getMaxIntrinsicHeight(childWidth);
      if (runWidth + childWidth > width) {
        height += runHeight;
        runWidth = 0.0;
        runHeight = 0.0;
        childCount = 0;
      }
      runWidth += childWidth;
      runHeight = math.max(runHeight, childHeight);
      childCount += 1;
      child = childAfter(child);
    }
    if (childCount > 0) height += runHeight;
    return height;
  }

  double _computeIntrinsicWidthForHeight(double height) {
    assert(direction == Axis.vertical);
    double width = 0.0;
    double runHeight = 0.0;
    double runWidth = 0.0;
    int childCount = 0;
    RenderBox? child = firstChild;
    while (child != null) {
      final double childHeight = child.getMaxIntrinsicHeight(double.infinity);
      final double childWidth = child.getMaxIntrinsicWidth(childHeight);
      if (runHeight + childHeight > height) {
        width += runWidth;
        runHeight = 0.0;
        runWidth = 0.0;
        childCount = 0;
      }
      runHeight += childHeight;
      runWidth = math.max(runWidth, childWidth);
      childCount += 1;
      child = childAfter(child);
    }
    if (childCount > 0) width += runWidth;
    return width;
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    switch (direction) {
      case Axis.horizontal:
        double width = 0.0;
        RenderBox? child = firstChild;
        while (child != null) {
          width = math.max(width, child.getMinIntrinsicWidth(double.infinity));
          child = childAfter(child);
        }
        return width;
      case Axis.vertical:
        return _computeIntrinsicWidthForHeight(height);
    }
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    switch (direction) {
      case Axis.horizontal:
        double width = 0.0;
        RenderBox? child = firstChild;
        while (child != null) {
          width += child.getMaxIntrinsicWidth(double.infinity);
          child = childAfter(child);
        }
        return width;
      case Axis.vertical:
        return _computeIntrinsicWidthForHeight(height);
    }
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    switch (direction) {
      case Axis.horizontal:
        return _computeIntrinsicHeightForWidth(width);
      case Axis.vertical:
        double height = 0.0;
        RenderBox? child = firstChild;
        while (child != null) {
          height =
              math.max(height, child.getMinIntrinsicHeight(double.infinity));
          child = childAfter(child);
        }
        return height;
    }
  }

  /// Get current offset.
  Offset get offset => (parentData as BoxParentData).offset;

  @override
  double computeMaxIntrinsicHeight(double width) {
    switch (direction) {
      case Axis.horizontal:
        return _computeIntrinsicHeightForWidth(width);
      case Axis.vertical:
        double height = 0.0;
        RenderBox? child = firstChild;
        while (child != null) {
          height += child.getMaxIntrinsicHeight(double.infinity);
          child = childAfter(child);
        }
        return height;
    }
  }

  double _getMainAxisExtent(RenderBox child) {
    double marginHorizontal = 0;
    double marginVertical = 0;

    if (child is RenderBoxModel) {
      marginHorizontal = child.renderStyle.marginLeft.length! +
          child.renderStyle.marginRight.length!;
      marginVertical = _getChildMarginTop(child) + _getChildMarginBottom(child);
    }

    Size childSize = _getChildSize(child) ?? Size.zero;
    switch (direction) {
      case Axis.horizontal:
        return childSize.width + marginHorizontal;
      case Axis.vertical:
        return childSize.height + marginVertical;
    }
  }

  double _getCrossAxisExtent(RenderBox child) {
    bool isLineHeightValid = _isLineHeightValid(child);
    double? lineHeight = isLineHeightValid ? _getLineHeight(child) : 0;
    double marginVertical = 0;
    double marginHorizontal = 0;

    if (child is RenderBoxModel) {
      marginHorizontal = child.renderStyle.marginLeft.length! +
          child.renderStyle.marginRight.length!;
      marginVertical = _getChildMarginTop(child) + _getChildMarginBottom(child);
    }
    Size childSize = _getChildSize(child) ?? Size.zero;
    switch (direction) {
      case Axis.horizontal:
        return lineHeight != null
            ? math.max(lineHeight, childSize.height) + marginVertical
            : childSize.height + marginVertical;
      case Axis.vertical:
        return childSize.width + marginHorizontal;
    }
  }

  Offset _getOffset(double mainAxisOffset, double crossAxisOffset) {
    switch (direction) {
      case Axis.horizontal:
        return Offset(mainAxisOffset, crossAxisOffset);
      case Axis.vertical:
        return Offset(crossAxisOffset, mainAxisOffset);
    }
  }

  double _getChildCrossAxisOffset(bool flipCrossAxis, double runCrossAxisExtent,
      double childCrossAxisExtent) {
    final double freeSpace = runCrossAxisExtent - childCrossAxisExtent;
    switch (crossAxisAlignment) {
      case CrossAxisAlignment.start:
        return flipCrossAxis ? freeSpace : 0.0;
      case CrossAxisAlignment.end:
        return flipCrossAxis ? 0.0 : freeSpace;
      case CrossAxisAlignment.center:
        return freeSpace / 2.0;
      case CrossAxisAlignment.baseline:
        return 0.0;
      case CrossAxisAlignment.stretch:
        return 0.0;
    }
  }

  double? _getLineHeight(RenderBox child) {
    double? lineHeight;
    if (child is RenderTextBox) {
      lineHeight = renderStyle.lineHeight;
    } else if (child is RenderBoxModel) {
      lineHeight = child.renderStyle.lineHeight;
    } else if (child is RenderPositionHolder) {
      lineHeight = child.realDisplayedBox!.renderStyle.lineHeight;
    }
    return lineHeight;
  }

  @override
  void performLayout() {
    if (kProfileMode) {
      childLayoutDuration = 0;
      PerformanceTiming.instance()
          .mark(PERF_FLOW_LAYOUT_START, uniqueId: hashCode);
    }

    beforeLayout();

    RenderBox? child = firstChild;

    // Layout positioned element
    while (child != null) {
      final RenderLayoutParentData childParentData =
          child.parentData as RenderLayoutParentData;
      if (childParentData.isPositioned) {
        CSSPositionedLayout.layoutPositionedChild(
            this, child as RenderBoxModel);
      }
      child = childParentData.nextSibling;
    }

    // Layout non positioned element
    _layoutChildren();

    // Set offset of positioned and sticky element
    child = firstChild;
    while (child != null) {
      final RenderLayoutParentData childParentData =
          child.parentData as RenderLayoutParentData;

      if (child is RenderBoxModel && childParentData.isPositioned) {
        CSSPositionedLayout.applyPositionedChildOffset(this, child);
        extendMaxScrollableSize(child);
        // For scrolling box, the minimum width and height should not less than scrollableSize
        if (isScrollingContentBox) {
          ensureBoxSizeLargerThanScrollableSize();
        }
      } else if (child is RenderBoxModel &&
          CSSPositionedLayout.isSticky(child)) {
        RenderBoxModel scrollContainer = child.findScrollContainer()!;
        // Sticky offset depends on the layout of scroll container, delay the calculation of
        // sticky offset to the layout stage of  scroll container if its not layouted yet
        // due to the layout order of Flutter renderObject tree is from down to up.
        if (scrollContainer.hasSize) {
          CSSPositionedLayout.applyStickyChildOffset(scrollContainer, child);
        }
      }
      child = childParentData.nextSibling;
    }

    bool isScrollContainer =
        renderStyle.overflowX != CSSOverflowType.visible ||
            renderStyle.overflowY != CSSOverflowType.visible;
    if (isScrollContainer) {
      // Find all the sticky children when scroll container is layouted
      stickyChildren = findStickyChildren();
      // Calculate the offset of its sticky children
      for (RenderBoxModel stickyChild in stickyChildren) {
        CSSPositionedLayout.applyStickyChildOffset(this, stickyChild);
      }
    }

    _relayoutPositionedChildren();

    didLayout();

    if (kProfileMode) {
      DateTime flowLayoutEndTime = DateTime.now();
      int amendEndTime =
          flowLayoutEndTime.microsecondsSinceEpoch - childLayoutDuration;
      PerformanceTiming.instance().mark(PERF_FLOW_LAYOUT_END,
          uniqueId: hashCode, startTime: amendEndTime);
    }
  }

  /// Relayout positioned child if percentage size exists
  void _relayoutPositionedChildren() {
    RenderBox? child = firstChild;
    while (child != null) {
      final RenderLayoutParentData childParentData =
          child.parentData as RenderLayoutParentData;

      if (child is RenderBoxModel && childParentData.isPositioned) {
        bool percentageOfSizingFound = child.renderStyle.isPercentageOfSizingExist(this);
        bool percentageToOwnFound = child.renderStyle.isPercentageToOwnExist();
        bool percentageToContainingBlockFound = child.renderStyle.resolvePercentageToContainingBlock(this);

        /// When percentage exists in sizing styles(width/height) and styles relies on its own size,
        /// it needs to relayout twice cause the latter relies on the size calculated in the first relayout
        if (percentageOfSizingFound == true && percentageToOwnFound == true) {
          /// Relayout first time to calculate percentage styles such as width/height
          _layoutPositionedChild(child);
          child.renderStyle.resolvePercentageToOwn();

          /// Relayout second time to calculate percentage styles such as transform: translate/border-radius
          _layoutPositionedChild(child);
        } else if (percentageToContainingBlockFound == true ||
            percentageToOwnFound == true) {
          _layoutPositionedChild(child);
        }
        extendMaxScrollableSize(child);
      }
      child = childParentData.nextSibling;
    }
  }

  void _layoutPositionedChild(RenderBoxModel child) {
    CSSPositionedLayout.layoutPositionedChild(this, child, needsRelayout: true);
    CSSPositionedLayout.applyPositionedChildOffset(this, child);
  }

  void _layoutChildren({bool needsRelayout = false}) {
    RenderBox? child = firstChild;

    // If no child exists, stop layout.
    if (childCount == 0) {
      Size layoutSize = getLayoutSize(
        logicalContentWidth: logicalContentWidth,
        logicalContentHeight: logicalContentHeight,
        contentWidth: 0,
        contentHeight: 0,
      );
      double constraintWidth = layoutSize.width;
      double constraintHeight = layoutSize.height;

      setMaxScrollableSize(constraintWidth, constraintHeight);
      size = getBoxSize(Size(
        constraintWidth,
        constraintHeight,
      ));
      return;
    }

    double mainAxisLimit = 0.0;
    bool flipMainAxis = false;
    bool flipCrossAxis = false;

    // Use scrolling container to calculate flex line limit for scrolling content box
    RenderBoxModel? containerBox =
        isScrollingContentBox ? parent as RenderBoxModel? : this;
    switch (direction) {
      case Axis.horizontal:
        mainAxisLimit = containerBox!.contentConstraints!.maxWidth;
        if (mainAxisLimit == double.infinity) {
          mainAxisLimit = RenderBoxModel.getMaxConstraintWidth(containerBox);
        }
        if (textDirection == TextDirection.rtl) flipMainAxis = true;
        if (verticalDirection == VerticalDirection.up) flipCrossAxis = true;
        break;
      case Axis.vertical:
        mainAxisLimit = containerBox!.contentConstraints!.maxHeight;
        if (verticalDirection == VerticalDirection.up) flipMainAxis = true;
        if (textDirection == TextDirection.rtl) flipCrossAxis = true;
        break;
    }
    List<_RunMetrics> runMetrics = <_RunMetrics>[];
    double mainAxisExtent = 0.0;
    double crossAxisExtent = 0.0;
    double runMainAxisExtent = 0.0;
    double runCrossAxisExtent = 0.0;
    RenderBox? preChild;
    double maxSizeAboveBaseline = 0;
    double maxSizeBelowBaseline = 0;
    Map<int?, RenderBox> runChildren = {};

    lineBoxMetrics = runMetrics;

    WhiteSpace? whiteSpace = renderStyle.whiteSpace;

    while (child != null) {
      final RenderLayoutParentData childParentData =
          child.parentData as RenderLayoutParentData;

      if (childParentData.isPositioned) {
        child = childParentData.nextSibling;
        continue;
      }

      int? childNodeId;
      if (child is RenderTextBox) {
        childNodeId = child.hashCode;
      } else if (child is RenderBoxModel) {
        childNodeId = child.hashCode;
      }

      BoxConstraints childConstraints;
      if (child is RenderBoxModel) {
        childConstraints = child.getConstraints();
      } else if (child is RenderTextBox) {
        childConstraints = child.getConstraints();
      } else {
        childConstraints = BoxConstraints();
      }

      // Whether child need to layout
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
        if (kProfileMode) {
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

        if (kProfileMode) {
          DateTime childLayoutEnd = DateTime.now();
          childLayoutDuration += (childLayoutEnd.microsecondsSinceEpoch -
              childLayoutStart.microsecondsSinceEpoch);
        }
      }

      double childMainAxisExtent = _getMainAxisExtent(child);
      double childCrossAxisExtent = _getCrossAxisExtent(child);

      if (isPositionHolder(child)) {
        RenderPositionHolder positionHolder = child as RenderPositionHolder;
        RenderBoxModel? childRenderBoxModel = positionHolder.realDisplayedBox;
        if (childRenderBoxModel != null) {
          RenderLayoutParentData childParentData =
              childRenderBoxModel.parentData as RenderLayoutParentData;
          if (childParentData.isPositioned) {
            childMainAxisExtent = childCrossAxisExtent = 0;
          }
        }
      }

      // white-space property not only specifies whether and how white space is collapsed
      // but only specifies whether lines may wrap at unforced soft wrap opportunities
      // https://www.w3.org/TR/css-text-3/#line-breaking
      bool isChildBlockLevel = _isChildBlockLevel(child);
      bool isPreChildBlockLevel = _isChildBlockLevel(preChild);
      bool isLineLengthExeedContainter = whiteSpace != WhiteSpace.nowrap &&
          (runMainAxisExtent + childMainAxisExtent > mainAxisLimit);

      if (runChildren.isNotEmpty &&
          (isChildBlockLevel ||
              isPreChildBlockLevel ||
              isLineLengthExeedContainter)) {
        mainAxisExtent = math.max(mainAxisExtent, runMainAxisExtent);
        crossAxisExtent += runCrossAxisExtent;
        runMetrics.add(_RunMetrics(
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

      /// Calculate baseline extent of layout box
      RenderStyle childRenderStyle = _getChildRenderStyle(child)!;
      VerticalAlign verticalAlign = childRenderStyle.verticalAlign;

      bool isLineHeightValid = _isLineHeightValid(child);

      // Vertical align is only valid for inline box
      if (verticalAlign == VerticalAlign.baseline && isLineHeightValid) {
        double childMarginTop = 0;
        double childMarginBottom = 0;
        if (child is RenderBoxModel) {
          childMarginTop = _getChildMarginTop(child);
          childMarginBottom = _getChildMarginBottom(child);
        }

        Size childSize = _getChildSize(child)!;
        double? lineHeight = _getLineHeight(child);
        // Leading space between content box and virtual box of child
        double childLeading = 0;
        if (child is! RenderTextBox && lineHeight != null) {
          childLeading = lineHeight - childSize.height;
        }

        // When baseline of children not found, use boundary of margin bottom as baseline
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
        runCrossAxisExtent = maxSizeAboveBaseline + maxSizeBelowBaseline;
      } else {
        runCrossAxisExtent = math.max(runCrossAxisExtent, childCrossAxisExtent);
      }
      runChildren[childNodeId] = child;

      childParentData.runIndex = runMetrics.length;
      preChild = child;
      child = childParentData.nextSibling;
    }

    if (runChildren.isNotEmpty) {
      mainAxisExtent = math.max(mainAxisExtent, runMainAxisExtent);
      crossAxisExtent += runCrossAxisExtent;
      runMetrics.add(_RunMetrics(
        runMainAxisExtent,
        runCrossAxisExtent,
        maxSizeAboveBaseline,
        runChildren,
      ));
    }

    final int runCount = runMetrics.length;

    Size layoutSize = getLayoutSize(
      logicalContentWidth: logicalContentWidth,
      logicalContentHeight: logicalContentHeight,
      contentWidth: mainAxisExtent,
      contentHeight: crossAxisExtent,
    );
    double constraintWidth = layoutSize.width;
    double constraintHeight = layoutSize.height;

    // Main and cross content size of flow layout
    double mainAxisContentSize = 0.0;
    double crossAxisContentSize = 0.0;

    switch (direction) {
      case Axis.horizontal:
        Size logicalSize = Size(constraintWidth, constraintHeight);
        size = getBoxSize(logicalSize);
        mainAxisContentSize = contentSize.width;
        crossAxisContentSize = contentSize.height;
        break;
      case Axis.vertical:
        Size logicalSize = Size(crossAxisExtent, mainAxisExtent);
        size = getBoxSize(logicalSize);

        mainAxisContentSize = contentSize.height;
        crossAxisContentSize = contentSize.width;
        break;
    }

    _setMaxScrollableSizeForFlow(runMetrics);

    autoMinWidth = _getMainAxisAutoSize(runMetrics);
    autoMinHeight = _getCrossAxisAutoSize(runMetrics);

    final double crossAxisFreeSpace =
        math.max(0.0, crossAxisContentSize - crossAxisExtent);
    double runLeadingSpace = 0.0;
    double runBetweenSpace = 0.0;
    switch (runAlignment) {
      case MainAxisAlignment.start:
        break;
      case MainAxisAlignment.end:
        runLeadingSpace = crossAxisFreeSpace;
        break;
      case MainAxisAlignment.center:
        runLeadingSpace = crossAxisFreeSpace / 2.0;
        break;
      case MainAxisAlignment.spaceBetween:
        runBetweenSpace =
            runCount > 1 ? crossAxisFreeSpace / (runCount - 1) : 0.0;
        break;
      case MainAxisAlignment.spaceAround:
        runBetweenSpace = crossAxisFreeSpace / runCount;
        runLeadingSpace = runBetweenSpace / 2.0;
        break;
      case MainAxisAlignment.spaceEvenly:
        runBetweenSpace = crossAxisFreeSpace / (runCount + 1);
        runLeadingSpace = runBetweenSpace;
        break;
    }

    double crossAxisOffset = flipCrossAxis
        ? crossAxisContentSize - runLeadingSpace
        : runLeadingSpace;
    child = firstChild;

    /// Set offset of children
    for (int i = 0; i < runCount; ++i) {
      final _RunMetrics metrics = runMetrics[i];
      final double runMainAxisExtent = metrics.mainAxisExtent;
      final double runCrossAxisExtent = metrics.crossAxisExtent;
      final double runBaselineExtent = metrics.baselineExtent;
      final Map<int?, RenderBox> runChildren = metrics.runChildren;
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
        CSSDisplay? childDisplay = firstChild.renderStyle.transformedDisplay;
        runContainInlineChild = childDisplay != CSSDisplay.block && childDisplay != CSSDisplay.flex;
      }

      // Text-align only works on inline level children
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

      double childMainPosition = flipMainAxis
        ? mainAxisContentSize - childLeadingSpace
        : childLeadingSpace;

      if (flipCrossAxis) crossAxisOffset -= runCrossAxisExtent;

      while (child != null) {
        final RenderLayoutParentData childParentData =
            child.parentData as RenderLayoutParentData;

        if (childParentData.isPositioned) {
          child = childParentData.nextSibling;
          continue;
        }
        if (childParentData.runIndex != i) break;
        final double childMainAxisExtent = _getMainAxisExtent(child);
        final double childCrossAxisExtent = _getCrossAxisExtent(child);

        // Calculate margin auto length according to CSS spec
        // https://www.w3.org/TR/CSS21/visudet.html#blockwidth
        // margin-left and margin-right auto takes up available space
        // between element and its containing block on block-level element
        // which is not positioned and computed to 0px in other cases
        if (child is RenderBoxModel) {
          RenderStyle childRenderStyle = child.renderStyle;
          CSSDisplay? childTransformedDisplay =
              childRenderStyle.transformedDisplay;
          CSSMargin marginLeft = childRenderStyle.marginLeft;
          CSSMargin marginRight = childRenderStyle.marginRight;

          // 'margin-left' + 'border-left-width' + 'padding-left' + 'width' + 'padding-right' +
          // 'border-right-width' + 'margin-right' = width of containing block
          if (childTransformedDisplay == CSSDisplay.block ||
              childTransformedDisplay == CSSDisplay.flex) {
            if (marginLeft.isAuto!) {
              double remainingSpace = mainAxisContentSize - childMainAxisExtent;
              if (marginRight.isAuto!) {
                childMainPosition = remainingSpace / 2;
              } else {
                childMainPosition = remainingSpace;
              }
            }
          }
        }

        // Always align to the top of run when positioning positioned element placeholder
        // @HACK(kraken): Judge positioned holder to impl top align.
        final double childCrossAxisOffset = isPositionHolder(child)
            ? 0
            : _getChildCrossAxisOffset(
                flipCrossAxis, runCrossAxisExtent, childCrossAxisExtent);
        if (flipMainAxis) childMainPosition -= childMainAxisExtent;

        Size? childSize = _getChildSize(child);
        // Line height of child
        double? childLineHeight = _getLineHeight(child);
        // Leading space between content box and virtual box of child
        double childLeading = 0;
        if (childLineHeight != null) {
          childLeading = childLineHeight - childSize!.height;
        }
        // Child line extent caculated according to vertical align
        double childLineExtent = childCrossAxisOffset;

        bool isLineHeightValid = _isLineHeightValid(child);
        if (isLineHeightValid) {
          // Distance from top to baseline of child
          double childAscent = _getChildAscent(child);

          RenderStyle childRenderStyle = _getChildRenderStyle(child)!;
          VerticalAlign verticalAlign = childRenderStyle.verticalAlign;

          // Leading between height of line box's content area and line height of line box
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
            // @TODO Vertical align middle needs to caculate the baseline of the parent box plus half the x-height of the parent from W3C spec,
            // currently flutter lack the api to caculate x-height of glyph
            //  case VerticalAlign.middle:
            //  break;
          }
        }

        double? childMarginLeft = 0;
        double? childMarginTop = 0;
        if (child is RenderBoxModel) {
          childMarginLeft = child.renderStyle.marginLeft.length;
          childMarginTop = _getChildMarginTop(child);
        }

        Offset relativeOffset = _getOffset(
            childMainPosition +
                renderStyle.paddingLeft +
                renderStyle.borderLeft +
                childMarginLeft!,
            crossAxisOffset +
                childLineExtent +
                renderStyle.paddingTop +
                renderStyle.borderTop +
                childMarginTop);
        // Apply position relative offset change.
        CSSPositionedLayout.applyRelativeOffset(relativeOffset, child);

        if (flipMainAxis)
          childMainPosition -= childBetweenSpace;
        else
          childMainPosition += childMainAxisExtent + childBetweenSpace;

        child = childParentData.nextSibling;
      }

      if (flipCrossAxis)
        crossAxisOffset -= runBetweenSpace;
      else
        crossAxisOffset += runCrossAxisExtent + runBetweenSpace;
    }

    /// Make sure it will not trigger relayout again when in relayout stage
    if (!needsRelayout) {
      bool percentageOfSizingFound = _isChildrenPercentageOfSizingExist();
      bool percentageToOwnFound = _isChildrenPercentageToOwnExist();
      bool percentageToContainingBlockFound =
          _resolveChildrenPercentageToContainingBlock();

      /// When percentage exists in sizing styles(width/height) and styles relies on its own size,
      /// it needs to relayout twice cause the latter relies on the size calculated in the first relayout
      if (percentageOfSizingFound == true && percentageToOwnFound == true) {
        /// Relayout first time to calculate percentage styles such as width/height
        _layoutChildren(needsRelayout: true);
        _resolveChildrenPercentageToOwn();

        /// Relayout second time to calculate percentage styles such as transform: translate/border-radius
        _layoutChildren(needsRelayout: true);
      } else if (percentageToContainingBlockFound == true ||
          percentageToOwnFound == true) {
        _layoutChildren(needsRelayout: true);
      }
    }
  }

  /// Compute distance to baseline of flow layout
  @override
  double? computeDistanceToBaseline() {
    double? lineDistance;
    bool isInline = renderStyle.transformedDisplay == CSSDisplay.inline;
    // Margin does not work for inline element.
    double marginTop = !isInline ? renderStyle.marginTop.length! : 0;
    double marginBottom = !isInline ? renderStyle.marginBottom.length! : 0;
    bool isParentFlowLayout = parent is RenderFlowLayout;
    CSSDisplay? transformedDisplay = renderStyle.transformedDisplay;
    bool isDisplayInline = transformedDisplay != CSSDisplay.block &&
        transformedDisplay != CSSDisplay.flex;

    // Use margin bottom as baseline if layout has no children
    if (lineBoxMetrics.isEmpty) {
      if (isDisplayInline) {
        // Flex item baseline does not includes margin-bottom
        lineDistance = isParentFlowLayout
            ? marginTop + boxSize!.height + marginBottom
            : marginTop + boxSize!.height;
        return lineDistance;
      } else {
        return null;
      }
    }

    // Use baseline of last line in flow layout and layout is inline-level
    // otherwise use baseline of first line
    bool isLastLineBaseline = isParentFlowLayout && isDisplayInline;
    _RunMetrics lineMetrics = isLastLineBaseline
        ? lineBoxMetrics[lineBoxMetrics.length - 1]
        : lineBoxMetrics[0];
    // Use the max baseline of the children as the baseline in flow layout
    lineMetrics.runChildren.forEach((int? hashCode, RenderBox child) {
      double? childMarginTop =
          child is RenderBoxModel ? _getChildMarginTop(child) : 0;
      RenderLayoutParentData? childParentData =
          child.parentData as RenderLayoutParentData?;
      double? childBaseLineDistance;
      if (child is RenderBoxModel) {
        childBaseLineDistance = child.computeDistanceToBaseline();
      } else if (child is RenderTextBox) {
        // Text baseline not depends on its own parent but its grand parents
        childBaseLineDistance = isLastLineBaseline
            ? child.computeDistanceToLastLineBaseline()
            : child.computeDistanceToFirstLineBaseline();
      }
      if (childBaseLineDistance != null) {
        // Baseline of relative positioned element equals its original position
        // so it needs to subtract its vertical offset
        Offset? relativeOffset;
        double childOffsetY = childParentData!.offset.dy - childMarginTop;
        if (child is RenderBoxModel) {
          relativeOffset =
              CSSPositionedLayout.getRelativeOffset(child.renderStyle);
        }
        if (relativeOffset != null) {
          childOffsetY -= relativeOffset.dy;
        }
        // It needs to subtract margin-top cause offset already includes margin-top
        childBaseLineDistance += childOffsetY;
        if (lineDistance != null)
          lineDistance = math.max(lineDistance!, childBaseLineDistance);
        else
          lineDistance = childBaseLineDistance;
      }
    });

    // If no inline child found, use margin-bottom as baseline
    if (isDisplayInline && lineDistance != null) {
      lineDistance = lineDistance! + marginTop;
    }
    return lineDistance;
  }

  /// Resolve all percentage size of child based on size its containing block
  bool _resolveChildrenPercentageToContainingBlock() {
    bool percentageFound = false;
    RenderBox? child = firstChild;
    while (child != null) {
      final RenderLayoutParentData childParentData =
          child.parentData as RenderLayoutParentData;
      // Exclude positioned child
      if (childParentData.isPositioned) {
        child = childParentData.nextSibling;
        continue;
      }
      if (child is RenderBoxModel) {
        bool percentageExist = child.renderStyle.resolvePercentageToContainingBlock(this);
        if (percentageExist) {
          percentageFound = true;
        }
      }
      child = childParentData.nextSibling;
    }
    return percentageFound;
  }

  /// Resolve all percentage size of child based on size its own
  bool _resolveChildrenPercentageToOwn() {
    bool percentageFound = false;
    RenderBox? child = firstChild;
    while (child != null) {
      final RenderLayoutParentData childParentData =
          child.parentData as RenderLayoutParentData;
      // Exclude positioned child
      if (childParentData.isPositioned) {
        child = childParentData.nextSibling;
        continue;
      }
      if (child is RenderBoxModel) {
        percentageFound = child.renderStyle.resolvePercentageToOwn();
      }
      child = childParentData.nextSibling;
    }
    return percentageFound;
  }

  /// Check whether percentage sizing styles of child exists
  bool _isChildrenPercentageOfSizingExist() {
    bool percentageFound = false;
    RenderBox? child = firstChild;
    while (child != null) {
      final RenderLayoutParentData childParentData =
          child.parentData as RenderLayoutParentData;
      // Exclude positioned child
      if (childParentData.isPositioned) {
        child = childParentData.nextSibling;
        continue;
      }
      if (child is RenderBoxModel) {
        bool percentageExist = child.renderStyle.isPercentageOfSizingExist(this);
        if (percentageExist) {
          percentageFound = true;
          break;
        }
      }
      child = childParentData.nextSibling;
    }
    return percentageFound;
  }

  /// Check whether percentage size of child based on size its own exist
  bool _isChildrenPercentageToOwnExist() {
    bool percentageFound = false;
    RenderBox? child = firstChild;
    while (child != null) {
      final RenderLayoutParentData childParentData =
          child.parentData as RenderLayoutParentData;
      // Exclude positioned child
      if (childParentData.isPositioned) {
        child = childParentData.nextSibling;
        continue;
      }
      if (child is RenderBoxModel) {
        bool percentageExist = child.renderStyle.isPercentageToOwnExist();
        if (percentageExist) {
          percentageFound = true;
          break;
        }
      }
      child = childParentData.nextSibling;
    }
    return percentageFound;
  }

  /// Record the main size of all lines
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
        double childMarginLeft = runChild.renderStyle.marginLeft.length!;
        double childMarginRight = runChild.renderStyle.marginRight.length!;
        runChildMainSize += childMarginLeft + childMarginRight;
      }
      runMainExtent += runChildMainSize;
    }

    runChildren.forEach(iterateRunChildren);
    runMainSize.add(runMainExtent);
  }

  /// Get auto min size in the main axis which equals the main axis size of its contents
  /// https://www.w3.org/TR/css-sizing-3/#automatic-minimum-size
  double _getMainAxisAutoSize(
    List<_RunMetrics> runMetrics,
  ) {
    double autoMinSize = 0;

    // Main size of each run
    List<double> runMainSize = [];

    // Calculate the max main size of all runs
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

  /// Record the cross size of all lines
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

  /// Get auto min size in the cross axis which equals the cross axis size of its contents
  /// https://www.w3.org/TR/css-sizing-3/#automatic-minimum-size
  double _getCrossAxisAutoSize(
    List<_RunMetrics> runMetrics,
  ) {
    double autoMinSize = 0;
    // Cross size of each run
    List<double> runCrossSize = [];

    // Calculate the max cross size of all runs
    for (_RunMetrics runMetrics in runMetrics) {
      _recordRunsCrossSize(runMetrics, runCrossSize);
    }

    // Get the sum of lines
    for (double crossSize in runCrossSize) {
      autoMinSize += crossSize;
    }

    return autoMinSize;
  }

  /// Set the size of scrollable overflow area for flow layout
  /// https://drafts.csswg.org/css-overflow-3/#scrollable
  void _setMaxScrollableSizeForFlow(List<_RunMetrics> runMetrics) {
    // Scrollable main size collection of each line
    List<double> scrollableMainSizeOfLines = [];
    // Scrollable cross size collection of each line
    List<double> scrollableCrossSizeOfLines = [];
    // Total cross size of previous lines
    double preLinesCrossSize = 0;

    for (_RunMetrics runMetric in runMetrics) {
      Map<int?, RenderBox> runChildren = runMetric.runChildren;

      List<RenderBox> runChildrenList = [];
      // Scrollable main size collection of each child in the line
      List<double> scrollableMainSizeOfChildren = [];
      // Scrollable cross size collection of each child in the line
      List<double> scrollableCrossSizeOfChildren = [];

      void iterateRunChildren(int? hashCode, RenderBox child) {
        // Total main size of previous siblings
        double preSiblingsMainSize = 0;
        for (RenderBox sibling in runChildrenList) {
          preSiblingsMainSize += sibling.size.width;
        }

        Size childScrollableSize = child.size;
        double? childMarginTop = 0;
        double? childMarginLeft = 0;
        if (child is RenderBoxModel) {
          RenderStyle childRenderStyle = child.renderStyle;
          CSSOverflowType overflowX = childRenderStyle.overflowX;
          CSSOverflowType overflowY = childRenderStyle.overflowY;
          // Only non scroll container need to use scrollable size, otherwise use its own size
          if (overflowX == CSSOverflowType.visible &&
              overflowY == CSSOverflowType.visible) {
            childScrollableSize = child.scrollableSize;
          }
          childMarginTop = _getChildMarginTop(child);
          childMarginLeft = childRenderStyle.marginLeft.length;
        }

        scrollableMainSizeOfChildren.add(
            preSiblingsMainSize + childScrollableSize.width + childMarginLeft!);
        scrollableCrossSizeOfChildren
            .add(childScrollableSize.height + childMarginTop);
        runChildrenList.add(child);
      }

      runChildren.forEach(iterateRunChildren);

      // Max scrollable main size of all the children in the line
      double maxScrollableMainSizeOfLine =
          scrollableMainSizeOfChildren.reduce((double curr, double next) {
        return curr > next ? curr : next;
      });

      // Max scrollable cross size of all the children in the line
      double maxScrollableCrossSizeOfLine = preLinesCrossSize +
          scrollableCrossSizeOfChildren.reduce((double curr, double next) {
            return curr > next ? curr : next;
          });

      scrollableMainSizeOfLines.add(maxScrollableMainSizeOfLine);
      scrollableCrossSizeOfLines.add(maxScrollableCrossSizeOfLine);
      preLinesCrossSize += runMetric.crossAxisExtent;
    }

    // Max scrollable main size of all lines
    double maxScrollableMainSizeOfLines =
        scrollableMainSizeOfLines.reduce((double curr, double next) {
      return curr > next ? curr : next;
    });

    RenderBoxModel container =
        isScrollingContentBox ? parent as RenderBoxModel : this;
    bool isScrollContainer =
        renderStyle.overflowX != CSSOverflowType.visible ||
            renderStyle.overflowY != CSSOverflowType.visible;

    // No need to add padding for scrolling content box
    double maxScrollableMainSizeOfChildren = isScrollContainer
        ? maxScrollableMainSizeOfLines
        : container.renderStyle.paddingLeft + maxScrollableMainSizeOfLines;

    // Max scrollable cross size of all lines
    double maxScrollableCrossSizeOfLines =
        scrollableCrossSizeOfLines.reduce((double curr, double next) {
      return curr > next ? curr : next;
    });
    // No need to add padding for scrolling content box
    double maxScrollableCrossSizeOfChildren = isScrollContainer
        ? maxScrollableCrossSizeOfLines
        : container.renderStyle.paddingTop + maxScrollableCrossSizeOfLines;

    double maxScrollableMainSize = math.max(
        size.width -
            container.renderStyle.borderLeft -
            container.renderStyle.borderRight,
        maxScrollableMainSizeOfChildren);
    double maxScrollableCrossSize = math.max(
        size.height -
            container.renderStyle.borderTop -
            container.renderStyle.borderBottom,
        maxScrollableCrossSizeOfChildren);

    scrollableSize = Size(maxScrollableMainSize, maxScrollableCrossSize);
  }

  // Get distance from top to baseline of child incluing margin
  double _getChildAscent(RenderBox child) {
    // Distance from top to baseline of child
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
    // When baseline of children not found, use boundary of margin bottom as baseline
    double extentAboveBaseline = childAscent ?? baseline;

    return extentAboveBaseline;
  }

  /// Get child size through boxSize to avoid flutter error when parentUsesSize is set to false
  Size? _getChildSize(RenderBox child) {
    if (child is RenderBoxModel) {
      return child.boxSize;
    } else if (child is RenderPositionHolder) {
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
    } else if (child is RenderPositionHolder) {
      childRenderStyle = child.realDisplayedBox!.renderStyle;
    }
    return childRenderStyle;
  }

  bool _isChildBlockLevel(RenderBox? child) {
    if (child != null && child is! RenderTextBox) {
      RenderStyle? childRenderStyle = _getChildRenderStyle(child);
      if (childRenderStyle != null) {
        CSSDisplay? childDisplay = childRenderStyle.display;
        return childDisplay == CSSDisplay.block ||
            childDisplay == CSSDisplay.flex;
      }
    }
    return false;
  }

  /// Get the collapsed margin top with the margin-bottom of its previous sibling
  double _getCollapsedMarginTopWithPreSibling(RenderBoxModel renderBoxModel, RenderObject preSibling, double marginTop) {
    if (preSibling is RenderBoxModel &&
      (preSibling.renderStyle.transformedDisplay == CSSDisplay.block ||
      preSibling.renderStyle.transformedDisplay == CSSDisplay.flex)
    ) {
      double preSiblingMarginBottom = _getChildMarginBottom(preSibling);
      if (marginTop > 0 && preSiblingMarginBottom > 0) {
        return math.max(marginTop - preSiblingMarginBottom, 0);
      }
    }
    return marginTop;
  }

  /// Get the collapsed margin top with parent if it is the first child of its parent
  double _getCollapsedMarginTopWithParent(RenderBoxModel renderBoxModel, double marginTop) {
    // Get the outer box of overflow scroll/auto element as parent
    RenderLayoutBox parent = (renderBoxModel.parent as RenderLayoutBox).isScrollingContentBox ?
    (renderBoxModel.parent!.parent! as RenderLayoutBox) : (renderBoxModel.parent as RenderLayoutBox);
    bool isParentOverflowVisible = parent.renderStyle.overflowX == CSSOverflowType.visible &&
        parent.renderStyle.overflowY == CSSOverflowType.visible;
    bool isParentOverflowClip = parent.renderStyle.overflowX == CSSOverflowType.clip &&
      parent.renderStyle.overflowY == CSSOverflowType.clip;
    // Margin top of first child with parent which is in flow layout collapse with parent
    // which makes the margin top of itself 0.
    // Margin collapse does not work on document root box.
    if (!parent.isDocumentRootBox &&
      parent.renderStyle.transformedDisplay == CSSDisplay.block &&
      (isParentOverflowVisible || isParentOverflowClip) &&
      parent.renderStyle.paddingTop == 0 &&
      parent.renderStyle.borderTop == 0 &&
      parent.parent is RenderFlowLayout
    ) {
      return 0;
    }
    return marginTop;
  }

  /// Get the collapsed margin top with its nested first child
  double _getCollapsedMarginTopWithNestedFirstChild(RenderBoxModel renderBoxModel) {
    double paddingTop = renderBoxModel.renderStyle.paddingTop;
    double borderTop = renderBoxModel.renderStyle.borderTop;
    double marginTop = renderBoxModel.renderStyle.marginTop.length!;
    bool isOverflowVisible = renderBoxModel.renderStyle.overflowX == CSSOverflowType.visible &&
      renderBoxModel.renderStyle.overflowY == CSSOverflowType.visible;
    bool isOverflowClip = renderBoxModel.renderStyle.overflowX == CSSOverflowType.clip &&
      renderBoxModel.renderStyle.overflowY == CSSOverflowType.clip;

    if (renderBoxModel is RenderLayoutBox &&
      renderBoxModel.renderStyle.transformedDisplay == CSSDisplay.block &&
      (isOverflowVisible || isOverflowClip) &&
      paddingTop == 0 &&
      borderTop == 0
    ) {
      RenderObject? firstChild = renderBoxModel.firstChild != null ?
        renderBoxModel.firstChild as RenderObject : null;
      if (firstChild is RenderBoxModel &&
        (firstChild.renderStyle.transformedDisplay == CSSDisplay.block ||
        firstChild.renderStyle.transformedDisplay == CSSDisplay.flex)
      ) {
        double childMarginTop = firstChild is RenderFlowLayout ?
        _getCollapsedMarginTopWithNestedFirstChild(firstChild) : firstChild.renderStyle.marginTop.length!;
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

  /// Get the collapsed margin top of child due to the margin collapse rule.
  /// https://www.w3.org/TR/CSS2/box.html#collapsing-margins
  double _getChildMarginTop(RenderBoxModel child) {
    CSSDisplay? childTransformedDisplay = child.renderStyle.transformedDisplay;
    // Margin is invalid for inline element.
    if (childTransformedDisplay == CSSDisplay.inline) {
      return 0;
    }
    double originalMarginTop = child.renderStyle.marginTop.length!;
    // Margin collapse does not work on following case:
    // 1. Document root element(HTML)
    // 2. Inline level elements
    // 3. Inner renderBox of element with overflow auto/scroll
    if (child.isDocumentRootBox ||
      child.isScrollingContentBox ||
      (childTransformedDisplay != CSSDisplay.block &&
      childTransformedDisplay != CSSDisplay.flex)
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
    bool isChildOverflowVisible = child.renderStyle.overflowX == CSSOverflowType.visible &&
      child.renderStyle.overflowY == CSSOverflowType.visible;
    bool isChildOverflowClip = child.renderStyle.overflowX == CSSOverflowType.clip &&
      child.renderStyle.overflowY == CSSOverflowType.clip;

    // Margin top and bottom of empty block collapse.
    // Make collapsed marign-top to the max of its top and bottom and margin-bottom as 0.
    if (child.boxSize!.height == 0 &&
      childTransformedDisplay != CSSDisplay.flex &&
      (isChildOverflowVisible || isChildOverflowClip)
    ) {
      double marginBottom = child.renderStyle.marginBottom.length!;
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

  /// Get the collapsed margin bottom with parent if it is the last child of its parent
  double _getCollapsedMarginBottomWithParent(RenderBoxModel renderBoxModel, double marginBottom) {
    // Get the outer box of overflow scroll/auto element as parent
    RenderLayoutBox parent = (renderBoxModel.parent as RenderLayoutBox).isScrollingContentBox ?
      (renderBoxModel.parent!.parent! as RenderLayoutBox) : (renderBoxModel.parent as RenderLayoutBox);
    bool isParentOverflowVisible = parent.renderStyle.overflowX == CSSOverflowType.visible &&
      parent.renderStyle.overflowY == CSSOverflowType.visible;
    bool isParentOverflowClip = parent.renderStyle.overflowX == CSSOverflowType.clip &&
      parent.renderStyle.overflowY == CSSOverflowType.clip;
    // Margin bottom of first child with parent which is in flow layout collapse with parent
    // which makes the margin top of itself 0.
    // Margin collapse does not work on document root box.
    if (!parent.isDocumentRootBox &&
      parent.renderStyle.transformedDisplay == CSSDisplay.block &&
      (isParentOverflowVisible || isParentOverflowClip) &&
      parent.renderStyle.paddingBottom == 0 &&
      parent.renderStyle.borderBottom == 0 &&
      parent.parent is RenderFlowLayout
    ) {
      return 0;
    }
    return marginBottom;
  }

  /// Get the collapsed margin bottom with its nested last child
  double _getCollapsedMarginBottomWithNestedLastChild(RenderBoxModel renderBoxModel) {
    double paddingBottom = renderBoxModel.renderStyle.paddingBottom;
    double borderBottom = renderBoxModel.renderStyle.borderBottom;
    double marginBottom = renderBoxModel.renderStyle.marginBottom.length!;
    bool isOverflowVisible = renderBoxModel.renderStyle.overflowX == CSSOverflowType.visible &&
      renderBoxModel.renderStyle.overflowY == CSSOverflowType.visible;
    bool isOverflowClip = renderBoxModel.renderStyle.overflowX == CSSOverflowType.clip &&
      renderBoxModel.renderStyle.overflowY == CSSOverflowType.clip;

    if (renderBoxModel is RenderLayoutBox &&
      renderBoxModel.renderStyle.height == null &&
      renderBoxModel.renderStyle.minHeight == null &&
      renderBoxModel.renderStyle.maxHeight == null &&
      renderBoxModel.renderStyle.transformedDisplay == CSSDisplay.block &&
      (isOverflowVisible || isOverflowClip) &&
      paddingBottom == 0 &&
      borderBottom == 0
    ) {
      RenderObject? lastChild = renderBoxModel.lastChild != null ?
        renderBoxModel.lastChild as RenderObject : null;
      if (lastChild is RenderBoxModel &&
        lastChild.renderStyle.transformedDisplay == CSSDisplay.block) {
        double childMarginBottom = lastChild is RenderLayoutBox ?
        _getCollapsedMarginBottomWithNestedLastChild(lastChild) : lastChild.renderStyle.marginBottom.length!;
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

  /// Get the collapsed margin bottom of child due to the margin collapse rule.
  /// https://www.w3.org/TR/CSS2/box.html#collapsing-margins
  double _getChildMarginBottom(RenderBoxModel child) {
    CSSDisplay? childTransformedDisplay = child.renderStyle.transformedDisplay;
    // Margin is invalid for inline element.
    if (childTransformedDisplay == CSSDisplay.inline) {
      return 0;
    }
    double originalMarginBottom = child.renderStyle.marginBottom.length!;
    // Margin collapse does not work on following case:
    // 1. Document root element(HTML)
    // 2. Inline level elements
    // 3. Inner renderBox of element with overflow auto/scroll
    if (child.isDocumentRootBox ||
      child.isScrollingContentBox ||
      (childTransformedDisplay != CSSDisplay.block &&
      childTransformedDisplay != CSSDisplay.flex)
    ) {
      return originalMarginBottom;
    }

    bool isChildOverflowVisible = child.renderStyle.overflowX == CSSOverflowType.visible &&
      child.renderStyle.overflowY == CSSOverflowType.visible;
    bool isChildOverflowClip = child.renderStyle.overflowX == CSSOverflowType.clip &&
      child.renderStyle.overflowY == CSSOverflowType.clip;

    // Margin top and bottom of empty block collapse.
    // Make collapsed marign-top to the max of its top and bottom and margin-bottom as 0.
    if (child.boxSize!.height == 0 &&
      childTransformedDisplay != CSSDisplay.flex &&
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
  int sortSiblingsByZIndex(RenderObject prev, RenderObject next) {
    CSSPositionType prevPosition = prev is RenderBoxModel
      ? prev.renderStyle.position
      : CSSPositionType.static;
    CSSPositionType nextPosition = next is RenderBoxModel
      ? next.renderStyle.position
      : CSSPositionType.static;
    // Place positioned element after non positioned element
    if (prevPosition == CSSPositionType.static &&
      nextPosition != CSSPositionType.static) {
      return -1;
    }
    if (prevPosition != CSSPositionType.static &&
      nextPosition == CSSPositionType.static) {
      return 1;
    }
    int prevZIndex =
      prev is RenderBoxModel ? (prev.renderStyle.zIndex ?? 0) : 0;
    int nextZIndex =
      next is RenderBoxModel ? (next.renderStyle.zIndex ?? 0) : 0;
    return prevZIndex - nextZIndex;
  }

  @override
  void performPaint(PaintingContext context, Offset offset) {
    for (int i = 0; i < sortedChildren.length; i++) {
      RenderObject child = sortedChildren[i];
      if (child is! RenderPositionHolder) {
        late DateTime childPaintStart;
        if (kProfileMode) {
          childPaintStart = DateTime.now();
        }
        final RenderLayoutParentData childParentData =
            child.parentData as RenderLayoutParentData;
        context.paintChild(child, childParentData.offset + offset);
        if (kProfileMode) {
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

  /// Convert [RenderFlowLayout] to [RenderRecyclerLayout]
  RenderRecyclerLayout toRenderRecyclerLayout() {
    List<RenderObject?> children = getDetachedChildrenAsList();
    RenderRecyclerLayout layout = RenderRecyclerLayout(
      renderStyle: renderStyle,
      elementDelegate: elementDelegate,
    );
    layout.addAll(children as List<RenderBox>?);
    return copyWith(layout);
  }

  /// Convert [RenderFlowLayout] to [RenderFlexLayout]
  RenderFlexLayout toFlexLayout() {
    List<RenderObject?> children = getDetachedChildrenAsList();
    RenderFlexLayout flexLayout = RenderFlexLayout(
      children: children as List<RenderBox>,
      renderStyle: renderStyle,
      elementDelegate: elementDelegate,
    );
    return copyWith(flexLayout);
  }

  /// Convert [RenderFlowLayout] to [RenderSelfRepaintFlowLayout]
  RenderSelfRepaintFlowLayout toSelfRepaint() {
    List<RenderObject?> children = getDetachedChildrenAsList();
    RenderSelfRepaintFlowLayout selfRepaintFlowLayout = RenderSelfRepaintFlowLayout(
      children: children as List<RenderBox>?,
      renderStyle: renderStyle,
      elementDelegate: elementDelegate,
    );
    selfRepaintFlowLayout.sortedChildren = sortedChildren;
    return copyWith(selfRepaintFlowLayout);
  }

  /// Convert [RenderFlowLayout] to [RenderSelfRepaintFlexLayout]
  RenderSelfRepaintFlexLayout toSelfRepaintFlexLayout() {
    List<RenderObject?> children = getDetachedChildrenAsList();
    RenderSelfRepaintFlexLayout selfRepaintFlexLayout = RenderSelfRepaintFlexLayout(
      children: children as List<RenderBox>,
      renderStyle: renderStyle,
      elementDelegate: elementDelegate,
    );
    return copyWith(selfRepaintFlexLayout);
  }
}

// Render flex layout with self repaint boundary.
class RenderSelfRepaintFlowLayout extends RenderFlowLayout {
  RenderSelfRepaintFlowLayout({
    List<RenderBox>? children,
    required RenderStyle renderStyle,
    required ElementDelegate elementDelegate
  }) : super(
    children: children,
    renderStyle: renderStyle,
    elementDelegate: elementDelegate
  );

  @override
  bool get isRepaintBoundary => true;

  /// Convert [RenderSelfRepaintFlowLayout] to [RenderSelfRepaintFlexLayout]
  @override
  RenderSelfRepaintFlexLayout toFlexLayout() {
    List<RenderObject?> children = getDetachedChildrenAsList();
    RenderSelfRepaintFlexLayout selfRepaintFlexLayout = RenderSelfRepaintFlexLayout(
      children: children as List<RenderBox>,
      renderStyle: renderStyle,
      elementDelegate: elementDelegate,
    );
    return copyWith(selfRepaintFlexLayout);
  }

  /// Convert [RenderSelfRepaintFlowLayout] to [RenderFlowLayout]
  RenderFlowLayout toParentRepaint() {
    List<RenderObject?> children = getDetachedChildrenAsList();
    RenderFlowLayout renderFlowLayout = RenderFlowLayout(
      children: children as List<RenderBox>,
      renderStyle: renderStyle,
      elementDelegate: elementDelegate,
    );
    return copyWith(renderFlowLayout);
  }

  /// Convert [RenderSelfRepaintFlowLayout] to [RenderFlowLayout]
  RenderFlexLayout toParentRepaintFlexLayout() {
    List<RenderObject?> children = getDetachedChildrenAsList();
    RenderFlexLayout renderFlexLayout = RenderFlexLayout(
      children: children as List<RenderBox>,
      renderStyle: renderStyle,
      elementDelegate: elementDelegate,
    );
    return copyWith(renderFlexLayout);
  }
}
