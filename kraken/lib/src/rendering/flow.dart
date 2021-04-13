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
  final Map<int, RenderBox> runChildren;
}

/// Impl flow layout algorithm.
class RenderFlowLayout extends RenderLayoutBox {
  RenderFlowLayout(
      {List<RenderBox> children,
      RenderStyle renderStyle,
      int targetId,
      ElementManager elementManager})
      : super(targetId: targetId, renderStyle: renderStyle, elementManager: elementManager) {
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
    assert(value != null);
    if (_direction == value) return;
    _direction = value;
    markNeedsLayout();
  }

  /// How much space to place between children in a run in the main axis.
  ///
  /// For example, if [spacing] is 10.0, the children will be spaced at least
  /// 10.0 logical pixels apart in the main axis.
  ///
  /// If there is additional free space in a run (e.g., because the wrap has a
  /// minimum size that is not filled or because some runs are longer than
  /// others), the additional free space will be allocated according to the
  /// textAlign style.
  ///
  /// Defaults to 0.0.
  double get spacing => _spacing;
  double _spacing = 0.0;
  set spacing(double value) {
    assert(value != null);
    if (_spacing == value) return;
    _spacing = value;
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
    assert(value != null);
    if (_runAlignment == value) return;
    _runAlignment = value;
    markNeedsLayout();
  }

  /// How much space to place between the runs themselves in the cross axis.
  ///
  /// For example, if [runSpacing] is 10.0, the runs will be spaced at least
  /// 10.0 logical pixels apart in the cross axis.
  ///
  /// If there is additional free space in the overall [RenderWrap] (e.g.,
  /// The distance by which the child's top edge is inset from the top of the stack.
  double top;

  /// The distance by which the child's right edge is inset from the right of the stack.
  double right;

  /// The distance by which the child's bottom edge is inset from the bottom of the stack.
  double bottom;

  /// The distance by which the child's left edge is inset from the left of the stack.
  double left;

  /// because the wrap has a minimum size that is not filled), the additional
  /// free space will be allocated according to the [runAlignment].
  ///
  /// Defaults to 0.0.
  double get runSpacing => _runSpacing;
  double _runSpacing = 0.0;
  set runSpacing(double value) {
    assert(value != null);
    if (_runSpacing == value) return;
    _runSpacing = value;
    markNeedsLayout();
  }

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
    assert(value != null);
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

  bool get _debugHasNecessaryDirections {
    assert(direction != null);
    assert(runAlignment != null);
    assert(crossAxisAlignment != null);
    if (firstChild != null && lastChild != firstChild) {
      // i.e. there's more than one child
      switch (direction) {
        case Axis.horizontal:
          assert(textDirection != null,
              'Horizontal $runtimeType with multiple children has a null textDirection, so the layout order is undefined.');
          break;
        case Axis.vertical:
          assert(verticalDirection != null,
              'Vertical $runtimeType with multiple children has a null verticalDirection, so the layout order is undefined.');
          break;
      }
    }

    TextAlign textAlign = renderStyle.textAlign;

    if (textAlign == TextAlign.start || textAlign == TextAlign.end) {
      switch (direction) {
        case Axis.horizontal:
          assert(textDirection != null,
              'Horizontal $runtimeType with textAlign $textAlign has a null textDirection, so the textAlign cannot be resolved.');
          break;
        case Axis.vertical:
          assert(verticalDirection != null,
              'Vertical $runtimeType with textAlign $textAlign has a null verticalDirection, so the textAlign cannot be resolved.');
          break;
      }
    }
    if (runAlignment == MainAxisAlignment.start || runAlignment == MainAxisAlignment.end) {
      switch (direction) {
        case Axis.horizontal:
          assert(verticalDirection != null,
              'Horizontal $runtimeType with runAlignment $runAlignment has a null verticalDirection, so the textAlign cannot be resolved.');
          break;
        case Axis.vertical:
          assert(textDirection != null,
              'Vertical $runtimeType with runAlignment $runAlignment has a null textDirection, so the textAlign cannot be resolved.');
          break;
      }
    }
    if (crossAxisAlignment == CrossAxisAlignment.start || crossAxisAlignment == CrossAxisAlignment.end) {
      switch (direction) {
        case Axis.horizontal:
          assert(verticalDirection != null,
              'Horizontal $runtimeType with crossAxisAlignment $crossAxisAlignment has a null verticalDirection, so the textAlign cannot be resolved.');
          break;
        case Axis.vertical:
          assert(textDirection != null,
              'Vertical $runtimeType with crossAxisAlignment $crossAxisAlignment has a null textDirection, so the textAlign cannot be resolved.');
          break;
      }
    }
    return true;
  }

  /// Line boxes of flow layout
  List<_RunMetrics> lineBoxMetrics = <_RunMetrics>[];

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! RenderLayoutParentData) {
      child.parentData = RenderLayoutParentData();
    }
    if (child is RenderBoxModel) {
      child.parentData = CSSPositionedLayout.getPositionParentData(child, child.parentData);
    }
  }

  double _computeIntrinsicHeightForWidth(double width) {
    assert(direction == Axis.horizontal);
    int runCount = 0;
    double height = 0.0;
    double runWidth = 0.0;
    double runHeight = 0.0;
    int childCount = 0;
    RenderBox child = firstChild;
    while (child != null) {
      final double childWidth = child.getMaxIntrinsicWidth(double.infinity);
      final double childHeight = child.getMaxIntrinsicHeight(childWidth);
      if (runWidth + childWidth > width) {
        height += runHeight;
        if (runCount > 0) height += runSpacing;
        runCount += 1;
        runWidth = 0.0;
        runHeight = 0.0;
        childCount = 0;
      }
      runWidth += childWidth;
      runHeight = math.max(runHeight, childHeight);
      if (childCount > 0) runWidth += spacing;
      childCount += 1;
      child = childAfter(child);
    }
    if (childCount > 0) height += runHeight + runSpacing;
    return height;
  }

  double _computeIntrinsicWidthForHeight(double height) {
    assert(direction == Axis.vertical);
    int runCount = 0;
    double width = 0.0;
    double runHeight = 0.0;
    double runWidth = 0.0;
    int childCount = 0;
    RenderBox child = firstChild;
    while (child != null) {
      final double childHeight = child.getMaxIntrinsicHeight(double.infinity);
      final double childWidth = child.getMaxIntrinsicWidth(childHeight);
      if (runHeight + childHeight > height) {
        width += runWidth;
        if (runCount > 0) width += runSpacing;
        runCount += 1;
        runHeight = 0.0;
        runWidth = 0.0;
        childCount = 0;
      }
      runHeight += childHeight;
      runWidth = math.max(runWidth, childWidth);
      if (childCount > 0) runHeight += spacing;
      childCount += 1;
      child = childAfter(child);
    }
    if (childCount > 0) width += runWidth + runSpacing;
    return width;
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    switch (direction) {
      case Axis.horizontal:
        double width = 0.0;
        RenderBox child = firstChild;
        while (child != null) {
          width = math.max(width, child.getMinIntrinsicWidth(double.infinity));
          child = childAfter(child);
        }
        return width;
      case Axis.vertical:
        return _computeIntrinsicWidthForHeight(height);
    }
    return null;
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    switch (direction) {
      case Axis.horizontal:
        double width = 0.0;
        RenderBox child = firstChild;
        while (child != null) {
          width += child.getMaxIntrinsicWidth(double.infinity);
          child = childAfter(child);
        }
        return width;
      case Axis.vertical:
        return _computeIntrinsicWidthForHeight(height);
    }
    return null;
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    switch (direction) {
      case Axis.horizontal:
        return _computeIntrinsicHeightForWidth(width);
      case Axis.vertical:
        double height = 0.0;
        RenderBox child = firstChild;
        while (child != null) {
          height = math.max(height, child.getMinIntrinsicHeight(double.infinity));
          child = childAfter(child);
        }
        return height;
    }
    return null;
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
        RenderBox child = firstChild;
        while (child != null) {
          height += child.getMaxIntrinsicHeight(double.infinity);
          child = childAfter(child);
        }
        return height;
    }
    return null;
  }

  double _getMainAxisExtent(RenderBox child) {
    double marginHorizontal = 0;
    double marginVertical = 0;

    if (child is RenderBoxModel) {
      marginHorizontal = child.renderStyle.marginLeft.length + child.renderStyle.marginRight.length;
      marginVertical = child.renderStyle.marginTop.length + child.renderStyle.marginBottom.length;
    }

    Size childSize = _getChildSize(child) ?? Size.zero;
    switch (direction) {
      case Axis.horizontal:
        return childSize.width + marginHorizontal;
      case Axis.vertical:
        return childSize.height + marginVertical;
    }
    return 0.0;
  }

  double _getCrossAxisExtent(RenderBox child) {
    double lineHeight = _getLineHeight(child);
    double marginVertical = 0;
    double marginHorizontal = 0;

    if (child is RenderBoxModel) {
      marginHorizontal = child.renderStyle.marginLeft.length + child.renderStyle.marginRight.length;
      marginVertical = child.renderStyle.marginTop.length + child.renderStyle.marginBottom.length;
    }
    Size childSize = _getChildSize(child) ?? Size.zero;
    switch (direction) {
      case Axis.horizontal:
        return lineHeight != null ?
          math.max(lineHeight, childSize.height) + marginVertical :
          childSize.height + marginVertical;
      case Axis.vertical:
        return childSize.width + marginHorizontal;
    }
    return 0.0;
  }

  Offset _getOffset(double mainAxisOffset, double crossAxisOffset) {
    switch (direction) {
      case Axis.horizontal:
        return Offset(mainAxisOffset, crossAxisOffset);
      case Axis.vertical:
        return Offset(crossAxisOffset, mainAxisOffset);
    }
    return Offset.zero;
  }

  double _getChildCrossAxisOffset(bool flipCrossAxis, double runCrossAxisExtent, double childCrossAxisExtent) {
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
    return 0.0;
  }

  double _getLineHeight(RenderBox child) {
    double lineHeight;
    if (child is RenderTextBox) {
      lineHeight = renderStyle.lineHeight;
    } else if (child is RenderBoxModel) {
      lineHeight = child.renderStyle.lineHeight;
    } else if (child is RenderPositionHolder) {
      lineHeight = child.realDisplayedBox.renderStyle.lineHeight;
    }
    return lineHeight;
  }


  @override
  void performLayout() {
    if (kProfileMode) {
      childLayoutDuration = 0;
      PerformanceTiming.instance(elementManager.contextId).mark(PERF_FLOW_LAYOUT_START, uniqueId: targetId);
    }

    CSSDisplay display = renderStyle.display;
    if (display == CSSDisplay.none) {
      size = constraints.smallest;
      if (kProfileMode) {
        PerformanceTiming.instance(elementManager.contextId).mark(PERF_FLOW_LAYOUT_END, uniqueId: targetId);
      }
      return;
    }

    beforeLayout();

    RenderBox child = firstChild;

    // Layout positioned element
    while (child != null) {
      final RenderLayoutParentData childParentData = child.parentData;
      if (childParentData.isPositioned) {
        CSSPositionedLayout.layoutPositionedChild(this, child);
      }
      child = childParentData.nextSibling;
    }

    // Layout non positioned element
    _layoutChildren();

    // Set offset of positioned element
    child = firstChild;
    while (child != null) {
      final RenderLayoutParentData childParentData = child.parentData;

      if (child is RenderBoxModel && childParentData.isPositioned) {
        CSSPositionedLayout.applyPositionedChildOffset(this, child);

        setScrollableSize(childParentData, child);

        // For scrolling box, the minimum width and height should not less than scrollableSize
        if (isScrollingContentBox) {
          ensureBoxSizeLargerThanScrollableSize();
        }
      }
      child = childParentData.nextSibling;
    }

    _relayoutPositionedChildren();

    didLayout();

    if (kProfileMode) {
      DateTime flowLayoutEndTime = DateTime.now();
      int amendEndTime = flowLayoutEndTime.microsecondsSinceEpoch - childLayoutDuration;
      PerformanceTiming.instance(elementManager.contextId)
          .mark(PERF_FLOW_LAYOUT_END, uniqueId: targetId, startTime: amendEndTime);
    }
  }

  /// Relayout positioned child if percentage size exists
  void _relayoutPositionedChildren() {
    RenderBox child = firstChild;
    while (child != null) {
      final RenderLayoutParentData childParentData = child.parentData;

      if (child is RenderBoxModel && childParentData.isPositioned) {
        bool percentageOfSizingFound = child.renderStyle.isPercentageOfSizingExist(logicalContentWidth, logicalContentHeight);
        bool percentageToOwnFound = child.renderStyle.isPercentageToOwnExist();
        bool percentageToContainingBlockFound = child.renderStyle.resolvePercentageToContainingBlock(logicalContentWidth, logicalContentHeight);

        /// When percentage exists in sizing styles(width/height) and styles relies on its own size,
        /// it needs to relayout twice cause the latter relies on the size calculated in the first relayout
        if (percentageOfSizingFound == true && percentageToOwnFound == true) {
          /// Relayout first time to calculate percentage styles such as width/height
          _layoutPositionedChild(child);
          child.renderStyle.resolvePercentageToOwn();
          /// Relayout second time to calculate percentage styles such as transform: translate/border-radius
          _layoutPositionedChild(child);
        } else if (percentageToContainingBlockFound == true || percentageToOwnFound == true ) {
          _layoutPositionedChild(child);
        }
        setScrollableSize(childParentData, child);
      }
      child = childParentData.nextSibling;
    }
  }

  void _layoutPositionedChild(RenderBoxModel child) {
    CSSPositionedLayout.layoutPositionedChild(this, child, needsRelayout: true);
    CSSPositionedLayout.applyPositionedChildOffset(this, child);
  }

  void _layoutChildren({bool needsRelayout = false}) {
    assert(_debugHasNecessaryDirections);
    RenderBox child = firstChild;

    CSSDisplay transformedDisplay = renderStyle.transformedDisplay;

    double width = renderStyle.width;
    double height = renderStyle.height;
    double minWidth = renderStyle.minWidth;
    double minHeight = renderStyle.minHeight;
    double maxWidth = renderStyle.maxWidth;
    double maxHeight = renderStyle.maxHeight;

    // If no child exists, stop layout.
    if (childCount == 0) {
      double constraintWidth = logicalContentWidth ?? 0;
      double constraintHeight = logicalContentHeight ?? 0;
      bool isInline = transformedDisplay == CSSDisplay.inline;
      bool isInlineBlock = transformedDisplay == CSSDisplay.inlineBlock;

      if (!isInline) {
        // Base width when width no exists, inline-block has width of 0
        double baseWidth = isInlineBlock ? 0 : constraintWidth;
        if (maxWidth != null && width == null) {
          constraintWidth = baseWidth > maxWidth ? maxWidth : baseWidth;
        } else if (minWidth != null && width == null) {
          constraintWidth = baseWidth < minWidth ? minWidth : baseWidth;
        }

        // Base height always equals to 0 no matter
        double baseHeight = 0;
        if (maxHeight != null && height == null) {
          constraintHeight = baseHeight > maxHeight ? maxHeight : baseHeight;
        } else if (minHeight != null && height == null) {
          constraintHeight = baseHeight < minHeight ? minHeight : baseHeight;
        }
      }

      setMaxScrollableSize(constraintWidth, constraintHeight);

      size = getBoxSize(Size(
        constraintWidth,
        constraintHeight,
      ));
      return;
    }

    // @NOTE: Child size could be larger than parent's content, give
    // an infinite box constraint to flow layout children.
    BoxConstraints childConstraints = BoxConstraints();
    double mainAxisLimit = 0.0;
    bool flipMainAxis = false;
    bool flipCrossAxis = false;
    switch (direction) {
      case Axis.horizontal:
        double maxConstraintWidth = RenderBoxModel.getMaxConstraintWidth(this);
        mainAxisLimit = logicalContentWidth != null ? logicalContentWidth : maxConstraintWidth;
        if (textDirection == TextDirection.rtl) flipMainAxis = true;
        if (verticalDirection == VerticalDirection.up) flipCrossAxis = true;
        break;
      case Axis.vertical:
        mainAxisLimit = contentConstraints.maxHeight;
        if (verticalDirection == VerticalDirection.up) flipMainAxis = true;
        if (textDirection == TextDirection.rtl) flipCrossAxis = true;
        break;
    }
    assert(childConstraints != null);
    assert(mainAxisLimit != null);
    final double spacing = this.spacing;
    final double runSpacing = this.runSpacing;
    List<_RunMetrics> runMetrics = <_RunMetrics>[];
    double mainAxisExtent = 0.0;
    double crossAxisExtent = 0.0;
    double runMainAxisExtent = 0.0;
    double runCrossAxisExtent = 0.0;
    RenderBox preChild;
    double maxSizeAboveBaseline = 0;
    double maxSizeBelowBaseline = 0;
    Map<int, RenderBox> runChildren = {};

    lineBoxMetrics = runMetrics;

    WhiteSpace whiteSpace = renderStyle.whiteSpace;

    while (child != null) {
      final RenderLayoutParentData childParentData = child.parentData;

      if (childParentData.isPositioned) {
        child = childParentData.nextSibling;
        continue;
      }

      int childNodeId;
      if (child is RenderTextBox) {
        childNodeId = child.targetId;
      } else if (child is RenderBoxModel) {
        childNodeId = child.targetId;
      }

      // Whether child need to layout
      bool isChildNeedsLayout = true;
      if (child is RenderBoxModel && child.hasSize) {
        double childContentWidth = RenderBoxModel.getLogicalContentWidth(child);
        double childContentHeight = RenderBoxModel.getLogicalContentHeight(child);
        // Always layout child when parent is not laid out yet or child is marked as needsLayout
        if (!hasSize || child.needsLayout || needsRelayout) {
          isChildNeedsLayout = true;
        } else {
          Size childOldSize = _getChildSize(child);
          /// No need to layout child when both width and height of child can be calculated from style
          /// and be the same as old size, in other cases always relayout.
          bool childSizeCalculatedSame = childContentWidth != null && childContentHeight != null &&
            (childOldSize.width == childContentWidth ||
              childOldSize.height == childContentHeight);
          isChildNeedsLayout = !childSizeCalculatedSame;
        }
      }

      if (isChildNeedsLayout) {
        DateTime childLayoutStart;
        if (kProfileMode) {
          childLayoutStart = DateTime.now();
        }
        // Relayout child after percentage size is resolved
        if (needsRelayout && child is RenderBoxModel) {
          childConstraints = child.renderStyle.getConstraints();
        }
        child.layout(childConstraints, parentUsesSize: true);
        if (kProfileMode) {
          DateTime childLayoutEnd = DateTime.now();
          childLayoutDuration += (childLayoutEnd.microsecondsSinceEpoch - childLayoutStart.microsecondsSinceEpoch);
        }
      }

      double childMainAxisExtent = _getMainAxisExtent(child);
      double childCrossAxisExtent = _getCrossAxisExtent(child);

      if (isPositionHolder(child)) {
        RenderPositionHolder positionHolder = child;
        RenderBoxModel childRenderBoxModel = positionHolder.realDisplayedBox;
        if (childRenderBoxModel != null) {
          RenderLayoutParentData childParentData = childRenderBoxModel.parentData;
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
          (runMainAxisExtent + spacing + childMainAxisExtent > mainAxisLimit);

      if (runChildren.length > 0  &&
        (isChildBlockLevel || isPreChildBlockLevel || isLineLengthExeedContainter)
      ) {
        mainAxisExtent = math.max(mainAxisExtent, runMainAxisExtent);
        crossAxisExtent += runCrossAxisExtent;
        if (runMetrics.isNotEmpty) crossAxisExtent += runSpacing;
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
      if (runChildren.length > 0) {
        runMainAxisExtent += spacing;
      }
      /// Calculate baseline extent of layout box
      RenderStyle childRenderStyle = _getChildRenderStyle(child);
      VerticalAlign verticalAlign = childRenderStyle.verticalAlign;

      bool isLineHeightValid = _isLineHeightValid(child);

      // Vertical align is only valid for inline box
      if (verticalAlign == VerticalAlign.baseline && isLineHeightValid) {
        double childMarginTop = 0;
        double childMarginBottom = 0;
        if (child is RenderBoxModel) {
          childMarginTop = child.renderStyle.marginTop.length;
          childMarginBottom = child.renderStyle.marginBottom.length;
        }

        Size childSize = _getChildSize(child);
        double lineHeight = _getLineHeight(child);
        // Leading space between content box and virtual box of child
        double childLeading = 0;
        if (child is! RenderTextBox && lineHeight != null) {
          childLeading = lineHeight - childSize.height;
        }

        // When baseline of children not found, use boundary of margin bottom as baseline
        double childAscent = _getChildAscent(child);

        double extentAboveBaseline = childAscent + childLeading / 2;
        double extentBelowBaseline = childMarginTop + childSize.height + childMarginBottom
         - childAscent + childLeading / 2;

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


    if (runChildren.length > 0) {
      mainAxisExtent = math.max(mainAxisExtent, runMainAxisExtent);
      crossAxisExtent += runCrossAxisExtent;
      if (runMetrics.isNotEmpty) crossAxisExtent += runSpacing;
      runMetrics.add(_RunMetrics(
        runMainAxisExtent,
        runCrossAxisExtent,
        maxSizeAboveBaseline,
        runChildren,
      ));
    }

    final int runCount = runMetrics.length;

    // Default to children's width
    double constraintWidth = mainAxisExtent;
    bool isInlineBlock = transformedDisplay == CSSDisplay.inlineBlock;

    // Constrain to min-width or max-width if width not exists
    if (isInlineBlock && maxWidth != null && width == null) {
      constraintWidth = constraintWidth > maxWidth ? maxWidth : constraintWidth;
    } else if (isInlineBlock && minWidth != null && width == null) {
      constraintWidth = constraintWidth < minWidth ? minWidth : constraintWidth;
    } else if (logicalContentWidth != null) {
      constraintWidth = math.max(constraintWidth, logicalContentWidth);
    }

    // Default to children's height
    double constraintHeight = crossAxisExtent;
    bool isNotInline = transformedDisplay != CSSDisplay.inline;

    // Constrain to min-height or max-height if width not exists
    if (isNotInline && maxHeight != null && height == null) {
      constraintHeight = constraintHeight > maxHeight ? maxHeight : constraintHeight;
    } else if (isNotInline && minHeight != null && height == null) {
      constraintHeight = constraintHeight < minHeight ? minHeight : constraintHeight;
    } else if (logicalContentHeight != null) {
      constraintHeight = math.max(constraintHeight, logicalContentHeight);
    }

    // Main and cross content size of flow layout
    double mainAxisContentSize = 0.0;
    double crossAxisContentSize = 0.0;

    switch (direction) {
      case Axis.horizontal:
        Size logicalSize = Size(constraintWidth, constraintHeight);
        setMaxScrollableSize(logicalSize.width, logicalSize.height);
        size = getBoxSize(logicalSize);

        mainAxisContentSize = contentSize.width;
        crossAxisContentSize = contentSize.height;
        break;
      case Axis.vertical:
        Size logicalSize = Size(crossAxisExtent, mainAxisExtent);
        setMaxScrollableSize(logicalSize.width, logicalSize.height);
        size = getBoxSize(logicalSize);

        mainAxisContentSize = contentSize.height;
        crossAxisContentSize = contentSize.width;
        break;
    }

    autoMinWidth = _getMainAxisAutoSize(runMetrics);
    autoMinHeight = _getCrossAxisAutoSize(runMetrics);

    final double crossAxisFreeSpace = math.max(0.0, crossAxisContentSize - crossAxisExtent);
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
        runBetweenSpace = runCount > 1 ? crossAxisFreeSpace / (runCount - 1) : 0.0;
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

    runBetweenSpace += runSpacing;
    double crossAxisOffset = flipCrossAxis ? crossAxisContentSize - runLeadingSpace : runLeadingSpace;
    child = firstChild;

    /// Set offset of children
    for (int i = 0; i < runCount; ++i) {
      final _RunMetrics metrics = runMetrics[i];
      final double runMainAxisExtent = metrics.mainAxisExtent;
      final double runCrossAxisExtent = metrics.crossAxisExtent;
      final double runBaselineExtent = metrics.baselineExtent;
      final double mainAxisFreeSpace = math.max(0.0, mainAxisContentSize - runMainAxisExtent);
      final int runChildrenCount = metrics.runChildren.length;

      double childLeadingSpace = 0.0;
      double childBetweenSpace = 0.0;

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
      }

      childBetweenSpace += spacing;
      double childMainPosition = flipMainAxis ? mainAxisContentSize - childLeadingSpace : childLeadingSpace;

      if (flipCrossAxis) crossAxisOffset -= runCrossAxisExtent;

      while (child != null) {
        final RenderLayoutParentData childParentData = child.parentData;

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
          CSSDisplay childTransformedDisplay = childRenderStyle.transformedDisplay;
          CSSMargin marginLeft = childRenderStyle.marginLeft;
          CSSMargin marginRight = childRenderStyle.marginRight;

          // 'margin-left' + 'border-left-width' + 'padding-left' + 'width' + 'padding-right' +
          // 'border-right-width' + 'margin-right' = width of containing block
          if (childTransformedDisplay == CSSDisplay.block || childTransformedDisplay == CSSDisplay.flex) {
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
        final double childCrossAxisOffset = isPositionHolder(child)
            ? 0
            : _getChildCrossAxisOffset(flipCrossAxis, runCrossAxisExtent, childCrossAxisExtent);
        if (flipMainAxis) childMainPosition -= childMainAxisExtent;

        Size childSize = _getChildSize(child);
        // Line height of child
        double childLineHeight = _getLineHeight(child);
        // Leading space between content box and virtual box of child
        double childLeading = 0;
        if (childLineHeight != null) {
          childLeading = childLineHeight - childSize.height;
        }
        // Child line extent caculated according to vertical align
        double childLineExtent = childCrossAxisOffset;

        bool isLineHeightValid = _isLineHeightValid(child);
        if (isLineHeightValid) {
          // Distance from top to baseline of child
          double childAscent = _getChildAscent(child);

          RenderStyle childRenderStyle = _getChildRenderStyle(child);
          VerticalAlign verticalAlign = childRenderStyle.verticalAlign;

          // Leading between height of line box's content area and line height of line box
          double lineBoxLeading = 0;
          double lineBoxHeight = _getLineHeight(this);
          if (child is! RenderTextBox && lineBoxHeight != null) {
            lineBoxLeading = lineBoxHeight - runCrossAxisExtent;
          }

          switch (verticalAlign) {
            case VerticalAlign.baseline:
              childLineExtent = lineBoxLeading / 2 + (runBaselineExtent - childAscent);
              break;
            case VerticalAlign.top:
              childLineExtent = childLeading / 2;
              break;
            case VerticalAlign.bottom:
              childLineExtent =
                  (lineBoxHeight != null ? lineBoxHeight : runCrossAxisExtent) - childSize.height - childLeading / 2;
              break;
            // @TODO Vertical align middle needs to caculate the baseline of the parent box plus half the x-height of the parent from W3C spec,
            // currently flutter lack the api to caculate x-height of glyph
            //  case VerticalAlign.middle:
            //  break;
          }
        }

        double childMarginLeft = 0;
        double childMarginTop = 0;
        if (child is RenderBoxModel) {
          childMarginLeft = child.renderStyle.marginLeft.length;
          childMarginTop = child.renderStyle.marginTop.length;
        }

        Offset relativeOffset = _getOffset(
          childMainPosition + renderStyle.paddingLeft + renderStyle.borderLeft + childMarginLeft,
          crossAxisOffset + childLineExtent + renderStyle.paddingTop + renderStyle.borderTop + childMarginTop
        );
        /// Apply position relative offset change.
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
      bool percentageToContainingBlockFound = _resolveChildrenPercentageToContainingBlock();

      /// When percentage exists in sizing styles(width/height) and styles relies on its own size,
      /// it needs to relayout twice cause the latter relies on the size calculated in the first relayout
      if (percentageOfSizingFound == true && percentageToOwnFound == true) {
        /// Relayout first time to calculate percentage styles such as width/height
        _layoutChildren(needsRelayout: true);
        _resolveChildrenPercentageToOwn();
        /// Relayout second time to calculate percentage styles such as transform: translate/border-radius
        _layoutChildren(needsRelayout: true);
      } else if (percentageToContainingBlockFound == true || percentageToOwnFound == true ) {
        _layoutChildren(needsRelayout: true);
      }
    }
  }

  /// Compute distance to baseline of flow layout
  @override
  double computeDistanceToBaseline() {
    double lineDistance;
    double marginTop = renderStyle.marginTop.length ?? 0;
    double marginBottom = renderStyle.marginBottom.length ?? 0;
    bool isParentFlowLayout = parent is RenderFlowLayout;
    CSSDisplay transformedDisplay = renderStyle.transformedDisplay;
    bool isDisplayInline = transformedDisplay != CSSDisplay.block && transformedDisplay != CSSDisplay.flex;

    // Use margin bottom as baseline if layout has no children
    if (lineBoxMetrics.length == 0) {
      if (isDisplayInline) {
        // Flex item baseline does not includes margin-bottom
        lineDistance = isParentFlowLayout ?
        marginTop + boxSize.height + marginBottom :
        marginTop + boxSize.height;
        return lineDistance;
      } else {
        return null;
      }
    }

    // Use baseline of last line in flow layout and layout is inline-level
    // otherwise use baseline of first line
    bool isLastLineBaseline = isParentFlowLayout && isDisplayInline;
    _RunMetrics lineMetrics = isLastLineBaseline ?
      lineBoxMetrics[lineBoxMetrics.length - 1] : lineBoxMetrics[0];
    // Use the max baseline of the children as the baseline in flow layout
    lineMetrics.runChildren.forEach((int targetId, RenderBox child) {
      double childMarginTop = child is RenderBoxModel ? child.renderStyle.marginTop.length : 0;
      RenderLayoutParentData childParentData = child.parentData;
      double childBaseLineDistance;
      if (child is RenderBoxModel) {
        childBaseLineDistance = child.computeDistanceToBaseline();
      } else if (child is RenderTextBox) {
        // Text baseline not depends on its own parent but its grand parents
        childBaseLineDistance = isLastLineBaseline ?
          child.computeDistanceToLastLineBaseline() :
          child.computeDistanceToFirstLineBaseline();
      }
      if (childBaseLineDistance != null) {
        // Baseline of relative positioned element equals its originial position
        // so it needs to subtract its vertical offset
        Offset relativeOffset;
        double childOffsetY = childParentData.offset.dy - childMarginTop;
        if (child is RenderBoxModel) {
          relativeOffset = CSSPositionedLayout.getRelativeOffset(child.renderStyle);
        }
        if (relativeOffset != null) {
          childOffsetY -= relativeOffset.dy;
        }
        // It needs to subtract margin-top cause offset already includes margin-top
        childBaseLineDistance += childOffsetY;
        if (lineDistance != null)
          lineDistance = math.max(lineDistance, childBaseLineDistance);
        else
          lineDistance = childBaseLineDistance;
      }
    });

    // If no inline child found, use margin-bottom as baseline
    if (isDisplayInline && lineDistance != null) {
      lineDistance += marginTop;
    }
    return lineDistance;
  }

  /// Resolve all percentage size of child based on size its containing block
  bool _resolveChildrenPercentageToContainingBlock() {
    bool percentageFound = false;
    RenderBox child = firstChild;
    while (child != null) {
      final RenderLayoutParentData childParentData = child.parentData;
      // Exclude positioned child
      if (childParentData.isPositioned) {
        child = childParentData.nextSibling;
        continue;
      }
      if (child is RenderBoxModel) {
        bool percentageExist = child.renderStyle.resolvePercentageToContainingBlock(logicalContentWidth, logicalContentHeight);
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
    RenderBox child = firstChild;
    while (child != null) {
      final RenderLayoutParentData childParentData = child.parentData;
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
    RenderBox child = firstChild;
    while (child != null) {
      final RenderLayoutParentData childParentData = child.parentData;
      // Exclude positioned child
      if (childParentData.isPositioned) {
        child = childParentData.nextSibling;
        continue;
      }
      if (child is RenderBoxModel) {
        bool percentageExist = child.renderStyle.isPercentageOfSizingExist(logicalContentWidth, logicalContentHeight);
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
    RenderBox child = firstChild;
    while (child != null) {
      final RenderLayoutParentData childParentData = child.parentData;
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

  /// Get auto min size in the main axis which equals the main axis size of its contents
  /// https://www.w3.org/TR/css-sizing-3/#automatic-minimum-size
  double _getMainAxisAutoSize(
    List<_RunMetrics> runMetrics,
    ) {
    double autoMinSize = 0;

    // Main size of each run
    List<double> runMainSize = [];

    void iterateRunMetrics(_RunMetrics runMetrics) {
      Map<int, RenderBox> runChildren = runMetrics.runChildren;
      double runMainExtent = 0;
      void iterateRunChildren(int targetId, RenderBox runChild) {
        double runChildMainSize = runChild.size.width;
        runMainExtent += runChildMainSize;
      }
      runChildren.forEach(iterateRunChildren);
      runMainSize.add(runMainExtent);
    }

    // Calculate the max main size of all runs
    runMetrics.forEach(iterateRunMetrics);

    autoMinSize = runMainSize.reduce((double curr, double next) {
      return curr > next ? curr : next;
    });

    return autoMinSize;
  }

  /// Get auto min size in the cross axis which equals the cross axis size of its contents
  /// https://www.w3.org/TR/css-sizing-3/#automatic-minimum-size
  double _getCrossAxisAutoSize(
    List<_RunMetrics> runMetrics,
    ) {
    double autoMinSize = 0;
    // Get the sum of lines
    for (_RunMetrics curr in runMetrics) {
      autoMinSize += curr.crossAxisExtent;
    }
    return autoMinSize;
  }

  // Get distance from top to baseline of child incluing margin
  double _getChildAscent(RenderBox child) {
    // Distance from top to baseline of child
    double childAscent = child.getDistanceToBaseline(TextBaseline.alphabetic, onlyReal: true);
    double childMarginTop = 0;
    double childMarginBottom = 0;
    if (child is RenderBoxModel) {
      childMarginTop = child.renderStyle.marginTop.length;
      childMarginBottom = child.renderStyle.marginBottom.length;
    }

    Size childSize = _getChildSize(child);

    double baseline = parent is RenderFlowLayout ? childMarginTop + childSize.height + childMarginBottom :
      childMarginTop + childSize.height;
    // When baseline of children not found, use boundary of margin bottom as baseline
    double extentAboveBaseline = childAscent != null ? childAscent : baseline;

    return extentAboveBaseline;
  }

  /// Get child size through boxSize to avoid flutter error when parentUsesSize is set to false
  Size _getChildSize(RenderBox child) {
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
      CSSDisplay childDisplay = child.renderStyle.display;
      return childDisplay == CSSDisplay.inline ||
        childDisplay == CSSDisplay.inlineBlock ||
        childDisplay == CSSDisplay.inlineFlex;
    }
    return false;
  }

  RenderStyle _getChildRenderStyle(RenderBox child) {
    RenderStyle childRenderStyle;
    if (child is RenderTextBox) {
      childRenderStyle = renderStyle;
    } else if (child is RenderBoxModel) {
      childRenderStyle = child.renderStyle;
    } else if (child is RenderPositionHolder) {
      childRenderStyle = child.realDisplayedBox.renderStyle;
    }
    return childRenderStyle;
  }

  bool _isChildBlockLevel(RenderBox child) {
    if (child != null && child is! RenderTextBox) {
      RenderStyle childRenderStyle = _getChildRenderStyle(child);
      if (childRenderStyle != null) {
        CSSDisplay childDisplay = childRenderStyle.display;
        return childDisplay == CSSDisplay.block ||
            childDisplay == CSSDisplay.flex;
      }
    }
    return false;
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }

  void sortChildrenByZIndex() {
    List<RenderObject> children = getChildrenAsList();
    children.sort((RenderObject prev, RenderObject next) {
      CSSPositionType prevPosition = prev is RenderBoxModel ? prev.renderStyle.position : CSSPositionType.static;
      CSSPositionType nextPosition = next is RenderBoxModel ? next.renderStyle.position : CSSPositionType.static;
      // Place positioned element after non positioned element
      if (prevPosition == CSSPositionType.static && nextPosition != CSSPositionType.static) {
        return -1;
      }
      if (prevPosition != CSSPositionType.static && nextPosition == CSSPositionType.static) {
        return 1;
      }
      int prevZIndex = prev is RenderBoxModel ? (prev.renderStyle.zIndex ?? 0) : 0;
      int nextZIndex = next is RenderBoxModel ? (next.renderStyle.zIndex ?? 0) : 0;
      return prevZIndex - nextZIndex;
    });
    sortedChildren = children;
  }

  @override
  void performPaint(PaintingContext context, Offset offset) {
    if (!isChildrenSorted) {
      sortChildrenByZIndex();
    }
    for (int i = 0; i < sortedChildren.length; i ++) {
      RenderObject child = sortedChildren[i];
      if (child is! RenderPositionHolder) {
        DateTime childPaintStart;
        if (kProfileMode) {
          childPaintStart = DateTime.now();
        }
        final RenderLayoutParentData childParentData = child.parentData;
        context.paintChild(child, childParentData.offset + offset);
        if (kProfileMode) {
          DateTime childPaintEnd = DateTime.now();
          childPaintDuration += (childPaintEnd.microsecondsSinceEpoch - childPaintStart.microsecondsSinceEpoch);
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
    List<RenderObject> children = getDetachedChildrenAsList();
    RenderRecyclerLayout layout = RenderRecyclerLayout(
        targetId: targetId,
        renderStyle: renderStyle,
        elementManager: elementManager
    );
    layout.addAll(children);
    return copyWith(layout);
  }

  /// Convert [RenderFlowLayout] to [RenderFlexLayout]
  RenderFlexLayout toFlexLayout() {
    List<RenderObject> children = getDetachedChildrenAsList();
    RenderFlexLayout flexLayout = RenderFlexLayout(
      children: children,
      targetId: targetId,
      renderStyle: renderStyle,
      elementManager: elementManager
    );
    return copyWith(flexLayout);
  }

  /// Convert [RenderFlowLayout] to [RenderSelfRepaintFlowLayout]
  RenderSelfRepaintFlowLayout toSelfRepaint() {
    List<RenderObject> children = getDetachedChildrenAsList();
    RenderSelfRepaintFlowLayout selfRepaintFlowLayout = RenderSelfRepaintFlowLayout(
      children: children,
      targetId: targetId,
      renderStyle: renderStyle,
      elementManager: elementManager
    );
    return copyWith(selfRepaintFlowLayout);
  }

  /// Convert [RenderFlowLayout] to [RenderSelfRepaintFlexLayout]
  RenderSelfRepaintFlexLayout toSelfRepaintFlexLayout() {
    List<RenderObject> children = getDetachedChildrenAsList();
    RenderSelfRepaintFlexLayout selfRepaintFlexLayout = RenderSelfRepaintFlexLayout(
      children: children,
      targetId: targetId,
      renderStyle: renderStyle,
      elementManager: elementManager
    );
    return copyWith(selfRepaintFlexLayout);
  }
}

// Render flex layout with self repaint boundary.
class RenderSelfRepaintFlowLayout extends RenderFlowLayout {
  RenderSelfRepaintFlowLayout({
    List<RenderBox> children,
    int targetId,
    ElementManager elementManager,
    RenderStyle renderStyle,
  }): super(children: children, targetId: targetId, elementManager: elementManager, renderStyle: renderStyle);

  @override
  bool get isRepaintBoundary => true;

  /// Convert [RenderSelfRepaintFlowLayout] to [RenderSelfRepaintFlexLayout]
  RenderSelfRepaintFlexLayout toFlexLayout() {
    List<RenderObject> children = getDetachedChildrenAsList();
    RenderSelfRepaintFlexLayout selfRepaintFlexLayout = RenderSelfRepaintFlexLayout(
      children: children,
      targetId: targetId,
      renderStyle: renderStyle,
      elementManager: elementManager
    );
    return copyWith(selfRepaintFlexLayout);
  }

  /// Convert [RenderSelfRepaintFlowLayout] to [RenderFlowLayout]
  RenderFlowLayout toParentRepaint() {
    List<RenderObject> children = getDetachedChildrenAsList();
    RenderFlowLayout renderFlowLayout = RenderFlowLayout(
      children: children,
      targetId: targetId,
      renderStyle: renderStyle,
      elementManager: elementManager
    );
    return copyWith(renderFlowLayout);
  }

  /// Convert [RenderSelfRepaintFlowLayout] to [RenderFlowLayout]
  RenderFlexLayout toParentRepaintFlexLayout() {
    List<RenderObject> children = getDetachedChildrenAsList();
    RenderFlexLayout renderFlexLayout = RenderFlexLayout(
      children: children,
      targetId: targetId,
      renderStyle: renderStyle,
      elementManager: elementManager
    );
    return copyWith(renderFlexLayout);
  }
}
