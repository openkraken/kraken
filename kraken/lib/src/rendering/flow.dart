/*
 * Copyright (C) 2020-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'dart:math' as math;
import 'package:kraken/css.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:kraken/rendering.dart';
import 'package:kraken/element.dart';

class _RunMetrics {
  _RunMetrics(this.mainAxisExtent, this.crossAxisExtent, this.baselineExtent, this.childCount);

  final double mainAxisExtent;
  final double crossAxisExtent;
  final double baselineExtent;
  final int childCount;
}

/// Impl flow layout algorithm.
class RenderFlowLayoutBox extends RenderLayoutBox {
  RenderFlowLayoutBox(
      {List<RenderBox> children,
      MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
      TextDirection textDirection = TextDirection.ltr,
      Axis direction = Axis.horizontal,
      double spacing = 0.0,
      MainAxisAlignment runAlignment = MainAxisAlignment.start,
      double runSpacing = 0.0,
      CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.end,
      VerticalDirection verticalDirection = VerticalDirection.down,
      CSSStyleDeclaration style,
      int targetId,
      ElementManager elementManager})
      : assert(direction != null),
        assert(mainAxisAlignment != null),
        assert(spacing != null),
        assert(runAlignment != null),
        assert(runSpacing != null),
        assert(crossAxisAlignment != null),
        _direction = direction,
        _mainAxisAlignment = mainAxisAlignment,
        _spacing = spacing,
        _runAlignment = runAlignment,
        _runSpacing = runSpacing,
        _crossAxisAlignment = crossAxisAlignment,
        _textDirection = textDirection,
        _verticalDirection = verticalDirection,
        super(targetId: targetId, style: style, elementManager: elementManager) {
    addAll(children);
  }

  /// The direction to use as the main axis.
  ///
  /// For example, if [direction] is [Axis.horizontal], the default, the
  /// children are placed adjacent to one another in a horizontal run until the
  /// available horizontal space is consumed, at which point a subsequent
  /// children are placed in a new run vertically adjacent to the previous run.
  Axis get direction => _direction;
  Axis _direction;
  set direction(Axis value) {
    assert(value != null);
    if (_direction == value) return;
    _direction = value;
    markNeedsLayout();
  }

  /// How the children within a run should be placed in the main axis.
  ///
  /// For example, if [mainAxisAlignment] is [MainAxisAlignment.center], the children in
  /// each run are grouped together in the center of their run in the main axis.
  ///
  /// Defaults to [MainAxisAlignment.start].
  ///
  /// See also:
  ///
  ///  * [runAlignment], which controls how the runs are placed relative to each
  ///    other in the cross axis.
  ///  * [crossAxisAlignment], which controls how the children within each run
  ///    are placed relative to each other in the cross axis.
  MainAxisAlignment get mainAxisAlignment => _mainAxisAlignment;
  MainAxisAlignment _mainAxisAlignment;
  set mainAxisAlignment(MainAxisAlignment value) {
    assert(value != null);
    if (_mainAxisAlignment == value) return;
    _mainAxisAlignment = value;
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
  /// [mainAxisAlignment].
  ///
  /// Defaults to 0.0.
  double get spacing => _spacing;
  double _spacing;
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
  /// See also:
  ///
  ///  * [mainAxisAlignment], which controls how the children within each run are placed
  ///    relative to each other in the main axis.
  ///  * [crossAxisAlignment], which controls how the children within each run
  ///    are placed relative to each other in the cross axis.
  MainAxisAlignment get runAlignment => _runAlignment;
  MainAxisAlignment _runAlignment;
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
  double _runSpacing;
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
  /// Defaults to [CrossAxisAlignment.start].
  ///
  /// See also:
  ///
  ///  * [mainAxisAlignment], which controls how the children within each run are placed
  ///    relative to each other in the main axis.
  ///  * [runAlignment], which controls how the runs are placed relative to each
  ///    other in the cross axis.
  CrossAxisAlignment get crossAxisAlignment => _crossAxisAlignment;
  CrossAxisAlignment _crossAxisAlignment;
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
  /// of the [mainAxisAlignment] property's [MainAxisAlignment.start] and
  /// [MainAxisAlignment.end] values.
  ///
  /// If the [direction] is [Axis.horizontal], and either the
  /// [mainAxisAlignment] is either [MainAxisAlignment.start] or [MainAxisAlignment.end], or
  /// there's more than one child, then the [textDirection] must not be null.
  ///
  /// If the [direction] is [Axis.vertical], this controls the order in
  /// which runs are positioned, the meaning of the [runAlignment] property's
  /// [MainAxisAlignment.start] and [MainAxisAlignment.end] values, as well as the
  /// [crossAxisAlignment] property's [CrossAxisAlignment.start] and
  /// [CrossAxisAlignment.end] values.
  ///
  /// If the [direction] is [Axis.vertical], and either the
  /// [runAlignment] is either [MainAxisAlignment.start] or [MainAxisAlignment.end], the
  /// [crossAxisAlignment] is either [CrossAxisAlignment.start] or
  /// [CrossAxisAlignment.end], or there's more than one child, then the
  /// [textDirection] must not be null.
  TextDirection get textDirection => _textDirection;
  TextDirection _textDirection;
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
  /// are painted in (down or up), the meaning of the [mainAxisAlignment] property's
  /// [MainAxisAlignment.start] and [MainAxisAlignment.end] values.
  ///
  /// If the [direction] is [Axis.vertical], and either the [mainAxisAlignment]
  /// is either [MainAxisAlignment.start] or [MainAxisAlignment.end], or there's
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
  VerticalDirection _verticalDirection;
  set verticalDirection(VerticalDirection value) {
    if (_verticalDirection != value) {
      _verticalDirection = value;
      markNeedsLayout();
    }
  }

  bool get _debugHasNecessaryDirections {
    assert(direction != null);
    assert(mainAxisAlignment != null);
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
    if (mainAxisAlignment == MainAxisAlignment.start || mainAxisAlignment == MainAxisAlignment.end) {
      switch (direction) {
        case Axis.horizontal:
          assert(textDirection != null,
              'Horizontal $runtimeType with mainAxisAlignment $mainAxisAlignment has a null textDirection, so the mainAxisAlignment cannot be resolved.');
          break;
        case Axis.vertical:
          assert(verticalDirection != null,
              'Vertical $runtimeType with mainAxisAlignment $mainAxisAlignment has a null verticalDirection, so the mainAxisAlignment cannot be resolved.');
          break;
      }
    }
    if (runAlignment == MainAxisAlignment.start || runAlignment == MainAxisAlignment.end) {
      switch (direction) {
        case Axis.horizontal:
          assert(verticalDirection != null,
              'Horizontal $runtimeType with runAlignment $runAlignment has a null verticalDirection, so the mainAxisAlignment cannot be resolved.');
          break;
        case Axis.vertical:
          assert(textDirection != null,
              'Vertical $runtimeType with runAlignment $runAlignment has a null textDirection, so the mainAxisAlignment cannot be resolved.');
          break;
      }
    }
    if (crossAxisAlignment == CrossAxisAlignment.start || crossAxisAlignment == CrossAxisAlignment.end) {
      switch (direction) {
        case Axis.horizontal:
          assert(verticalDirection != null,
              'Horizontal $runtimeType with crossAxisAlignment $crossAxisAlignment has a null verticalDirection, so the mainAxisAlignment cannot be resolved.');
          break;
        case Axis.vertical:
          assert(textDirection != null,
              'Vertical $runtimeType with crossAxisAlignment $crossAxisAlignment has a null textDirection, so the mainAxisAlignment cannot be resolved.');
          break;
      }
    }
    return true;
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! RenderLayoutParentData) {
      if (child is RenderElementBoundary) {
        child.parentData = getPositionParentDataFromStyle(child.style);
      } else {
        child.parentData = RenderLayoutParentData();
      }
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

  @override
  double computeDistanceToActualBaseline(TextBaseline baseline) {
    return computeDistanceToHighestActualBaseline(baseline);
  }

  double computeDistanceToHighestActualBaseline(TextBaseline baseline) {
    double result;
    RenderBox child = firstChild;
    while (child != null) {
      final RenderLayoutParentData childParentData = child.parentData;

      // Positioned element doesn't involve in baseline alignment
      if (childParentData.isPositioned) {
        child = childParentData.nextSibling;
        continue;
      }

      double candidate = child.getDistanceToActualBaseline(baseline);
      if (candidate != null) {
        candidate += childParentData.offset.dy;
        if (result != null)
          result = math.min(result, candidate);
        else
          result = candidate;
      }
      child = childParentData.nextSibling;
    }
    return result;
  }

  double _getMainAxisExtent(RenderBox child) {
    switch (direction) {
      case Axis.horizontal:
        return child.size.width;
      case Axis.vertical:
        return child.size.height;
    }
    return 0.0;
  }

  double _getCrossAxisExtent(RenderBox child) {
    CSSStyleDeclaration childStyle = _getChildStyle(child);
    double lineHeight = CSSText.getLineHeight(childStyle);
    double margin = 0;

    if (child is RenderElementBoundary) {
      int childNodeId = child.targetId;
      Element childEl = elementManager.getEventTargetByTargetId<Element>(childNodeId);
      margin = childEl.cropMarginHeight;
    }
    switch (direction) {
      case Axis.horizontal:
        return lineHeight != null ? math.max(lineHeight + margin, child.size.height) : child.size.height;
      case Axis.vertical:
        return child.size.width;
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

  // @override
  void performLayout() {
    beforeLayout();
    RenderBox child = firstChild;
    Element element = elementManager.getEventTargetByTargetId<Element>(targetId);
    // Layout positioned element
    while (child != null) {
      final RenderLayoutParentData childParentData = child.parentData;
      if (childParentData.isPositioned) {
        layoutPositionedChild(element, this, child);
      }
      child = childParentData.nextSibling;
    }

    // Layout non positioned element
    _layoutChildren();

    // Set offset of positioned element
    child = firstChild;
    while (child != null) {
      final RenderLayoutParentData childParentData = child.parentData;

      if (childParentData.isPositioned) {
        setPositionedChildOffset(this, child, size, borderEdge);
      }
      child = childParentData.nextSibling;
    }

    didLayout();
  }

  void _layoutChildren() {
    assert(_debugHasNecessaryDirections);
    RenderBox child = firstChild;

    final double contentWidth = getContentWidth();
    final double contentHeight = getContentHeight();

    // If no child exists, stop layout.
    if (childCount == 0) {
      size = Size(
        contentWidth ?? 0,
        contentHeight ?? 0,
      );
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
        if (contentWidth != null) {
          mainAxisLimit = contentWidth;
        } else {
          mainAxisLimit = CSSSizing.getElementComputedMaxWidth(targetId, elementManager);
        }
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
    final List<_RunMetrics> runMetrics = <_RunMetrics>[];
    double mainAxisExtent = 0.0;
    double crossAxisExtent = 0.0;
    double runMainAxisExtent = 0.0;
    double runCrossAxisExtent = 0.0;
    int _effectiveChildCount = 0;

    RenderBox preChild = null;

    double maxSizeAboveBaseline = 0;
    double maxSizeBelowBaseline = 0;

    while (child != null) {
      final RenderLayoutParentData childParentData = child.parentData;

      if (childParentData.isPositioned) {
        child = childParentData.nextSibling;
        continue;
      }
      child.layout(childConstraints, parentUsesSize: true);
      double childMainAxisExtent = _getMainAxisExtent(child);
      double childCrossAxisExtent = _getCrossAxisExtent(child);

      if (isPositionHolder(child)) {
        RenderPositionHolder positionHolder = child;
        RenderElementBoundary childElementBoundary = positionHolder.realDisplayedBox;
        if (childElementBoundary != null) {
          RenderLayoutParentData childParentData = childElementBoundary.parentData;
          if (childParentData.position != CSSPositionType.static &&
              childParentData.position != CSSPositionType.relative) childMainAxisExtent = childCrossAxisExtent = 0;
        }
      }

      if (_effectiveChildCount > 0 &&
          (_isBlockElement(child) ||
              _isBlockElement(preChild) ||
              (runMainAxisExtent + spacing + childMainAxisExtent > mainAxisLimit))) {
        mainAxisExtent = math.max(mainAxisExtent, runMainAxisExtent);
        crossAxisExtent += runCrossAxisExtent;
        if (runMetrics.isNotEmpty) crossAxisExtent += runSpacing;
        runMetrics.add(_RunMetrics(runMainAxisExtent, runCrossAxisExtent, maxSizeAboveBaseline, _effectiveChildCount));
        runMainAxisExtent = 0.0;
        runCrossAxisExtent = 0.0;
        maxSizeAboveBaseline = 0.0;
        maxSizeBelowBaseline = 0.0;
        _effectiveChildCount = 0;
      }
      runMainAxisExtent += childMainAxisExtent;
      if (_effectiveChildCount > 0) runMainAxisExtent += spacing;

      /// Caculate baseline extent of layout box
      CSSStyleDeclaration childStyle = _getChildStyle(child);
      VerticalAlign verticalAlign = getVerticalAlign(childStyle);
      bool isLineHeightValid = _isLineHeightValid(child);
      // Vertical align is only valid for inline box
      if (verticalAlign == VerticalAlign.baseline && isLineHeightValid) {
        // Distance from top to baseline of child
        double childAscent = child.getDistanceToBaseline(TextBaseline.alphabetic);
        CSSStyleDeclaration childStyle = _getChildStyle(child);
        double lineHeight = CSSText.getLineHeight(childStyle);
        // Leading space between content box and virtual box of child
        double childLeading = 0;
        if (lineHeight != null) {
          childLeading = lineHeight - child.size.height;
        }
        maxSizeAboveBaseline = math.max(
          childAscent + childLeading / 2,
          maxSizeAboveBaseline,
        );
        maxSizeBelowBaseline = math.max(
          child.size.height - childAscent + childLeading / 2,
          maxSizeBelowBaseline,
        );
        runCrossAxisExtent = maxSizeAboveBaseline + maxSizeBelowBaseline;
      } else {
        runCrossAxisExtent = math.max(runCrossAxisExtent, childCrossAxisExtent);
      }
      _effectiveChildCount += 1;
      childParentData.runIndex = runMetrics.length;
      preChild = child;
      child = childParentData.nextSibling;
    }

    if (_effectiveChildCount > 0) {
      mainAxisExtent = math.max(mainAxisExtent, runMainAxisExtent);
      crossAxisExtent += runCrossAxisExtent;
      if (runMetrics.isNotEmpty) crossAxisExtent += runSpacing;
      runMetrics.add(_RunMetrics(runMainAxisExtent, runCrossAxisExtent, maxSizeAboveBaseline, childCount));
    }

    final int runCount = runMetrics.length;

    assert(_effectiveChildCount > 0);

    double containerMainAxisExtent = 0.0;
    double containerCrossAxisExtent = 0.0;

    // Default to children's width
    double constraintWidth = mainAxisExtent;
    // Get max of element's width and children's width if element's width exists
    if (contentWidth != null) {
      constraintWidth = math.max(constraintWidth, contentWidth);
    }

    // Default to children's height
    double constraintHeight = crossAxisExtent;
    // Get max of element's height and children's height if element's height exists
    if (contentHeight != null) {
      constraintHeight = math.max(constraintHeight, contentHeight);
    }

    switch (direction) {
      case Axis.horizontal:
        size = Size(constraintWidth, constraintHeight);
        // AxisExtent should be size.
        containerMainAxisExtent = contentWidth ?? size.width;
        containerCrossAxisExtent = contentHeight ?? size.height;
        break;
      case Axis.vertical:
        size = Size(crossAxisExtent, mainAxisExtent);
        containerMainAxisExtent = contentHeight ?? size.height;
        containerCrossAxisExtent = contentWidth ?? size.width;
        break;
    }
    final double crossAxisFreeSpace = math.max(0.0, containerCrossAxisExtent - crossAxisExtent);
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
    double crossAxisOffset = flipCrossAxis ? containerCrossAxisExtent - runLeadingSpace : runLeadingSpace;

    child = firstChild;

    /// Set offset of children
    for (int i = 0; i < runCount; ++i) {
      final _RunMetrics metrics = runMetrics[i];
      final double runMainAxisExtent = metrics.mainAxisExtent;
      final double runCrossAxisExtent = metrics.crossAxisExtent;
      final double runBaselineExtent = metrics.baselineExtent;
      final int metricChildCount = metrics.childCount;

      final double mainAxisFreeSpace = math.max(0.0, containerMainAxisExtent - runMainAxisExtent);
      double childLeadingSpace = 0.0;
      double childBetweenSpace = 0.0;

      switch (mainAxisAlignment) {
        case MainAxisAlignment.start:
          break;
        case MainAxisAlignment.end:
          childLeadingSpace = mainAxisFreeSpace;
          break;
        case MainAxisAlignment.center:
          childLeadingSpace = mainAxisFreeSpace / 2.0;
          break;
        case MainAxisAlignment.spaceBetween:
          childBetweenSpace = metricChildCount > 1 ? mainAxisFreeSpace / (metricChildCount - 1) : 0.0;
          break;
        case MainAxisAlignment.spaceAround:
          childBetweenSpace = mainAxisFreeSpace / metricChildCount;
          childLeadingSpace = childBetweenSpace / 2.0;
          break;
        case MainAxisAlignment.spaceEvenly:
          childBetweenSpace = mainAxisFreeSpace / (metricChildCount + 1);
          childLeadingSpace = childBetweenSpace;
          break;
      }

      childBetweenSpace += spacing;
      double childMainPosition = flipMainAxis ? containerMainAxisExtent - childLeadingSpace : childLeadingSpace;

      if (flipCrossAxis) crossAxisOffset -= runCrossAxisExtent;

      // Leading between height of line box's content area and line height of line box
      double lineBoxLeading = 0;
      double lineBoxHeight = CSSText.getLineHeight(style);
      if (lineBoxHeight != null) {
        lineBoxLeading = lineBoxHeight - runCrossAxisExtent;
      }

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
        if (child is RenderElementBoundary) {
          String childRealDisplay = CSSSizing.getElementRealDisplayValue(child.targetId, elementManager);
          CSSStyleDeclaration childStyle = child.style;
          String marginLeft = childStyle[MARGIN_LEFT];
          String marginRight = childStyle[MARGIN_RIGHT];

          // 'margin-left' + 'border-left-width' + 'padding-left' + 'width' + 'padding-right' +
          // 'border-right-width' + 'margin-right' = width of containing block
          if (childRealDisplay == BLOCK || childRealDisplay == FLEX) {
            if (marginLeft == AUTO) {
              double remainingSpace = containerMainAxisExtent - childMainAxisExtent;
              if (marginRight == AUTO) {
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
        CSSStyleDeclaration childStyle = _getChildStyle(child);

        // Line height of child
        double childLineHeight = CSSText.getLineHeight(childStyle);
        // Leading space between content box and virtual box of child
        double childLeading = 0;
        if (childLineHeight != null) {
          childLeading = childLineHeight - child.size.height;
        }
        // Child line extent caculated according to vertical align
        double childLineExtent = childCrossAxisOffset;

        bool isLineHeightValid = _isLineHeightValid(child);
        if (isLineHeightValid) {
          // Distance from top to baseline of child
          double childAscent = child.getDistanceToBaseline(TextBaseline.alphabetic);
          VerticalAlign verticalAlign = getVerticalAlign(childStyle);

          switch (verticalAlign) {
            case VerticalAlign.baseline:
              childLineExtent = lineBoxLeading / 2 + (runBaselineExtent - childAscent);
              break;
            case VerticalAlign.top:
              childLineExtent = childLeading / 2;
              break;
            case VerticalAlign.bottom:
              childLineExtent =
                  (lineBoxHeight != null ? lineBoxHeight : runCrossAxisExtent) - child.size.height - childLeading / 2;
              break;
            // @TODO Vertical align middle needs to caculate the baseline of the parent box plus half the x-height of the parent from W3C spec,
            // currently flutter lack the api to caculate x-height of glyph
//            case VerticalAlign.middle:
//              break;
          }
        }

        Offset relativeOffset = _getOffset(
          childMainPosition + paddingLeft + borderLeft,
          crossAxisOffset + childLineExtent + paddingTop + borderTop
        );

        /// Apply position relative offset change.
        applyRelativeOffset(relativeOffset, child, childStyle);

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
  }

  bool _isLineHeightValid(RenderBox child) {
    if (child is RenderPositionHolder) {
      return false;
    } else if (child is RenderTextBox) {
      return true;
    } else {
      CSSStyleDeclaration childStyle = _getChildStyle(child);
      String childDisplay = childStyle['display'];
      return childDisplay.startsWith('inline');
    }
  }

  CSSStyleDeclaration _getChildStyle(RenderBox child) {
    CSSStyleDeclaration childStyle;
    int childNodeId;
    if (child is RenderTextBox) {
      childNodeId = targetId;
    } else if (child is RenderElementBoundary) {
      childNodeId = child.targetId;
    } else if (child is RenderPositionHolder) {
      childNodeId = child.realDisplayedBox?.targetId;
    }
    childStyle = elementManager.getEventTargetByTargetId<Element>(childNodeId)?.style;
    return childStyle;
  }

  String _getChildDisplayFromRenderBox(RenderBox child) {
    String display = 'inline'; // Default value.
    int targetId;
    if (child is RenderFlowLayoutBox) targetId = child.targetId;
    if (child is RenderElementBoundary) targetId = child.targetId;
    if (child is RenderPositionHolder) targetId = child.realDisplayedBox?.targetId;

    if (targetId != null) {
      // @TODO: need to remove this after RenderObject merge have completed.
      Element element = elementManager.getEventTargetByTargetId<Element>(targetId);
      if (element != null) {
        String elementDisplayDeclaration = element.style['display'];
        display = CSSStyleDeclaration.isNullOrEmptyValue(elementDisplayDeclaration)
            ? element.defaultDisplay
            : element.style['display'];

        // @HACK: Use inline to impl flexWrap in with flex layout.
        // @TODO: need to remove this after RenderObject merge have completed.
        Element currentElement = elementManager.getEventTargetByTargetId<Element>(this.targetId);
        String currentElementDisplay =
            CSSStyleDeclaration.isNullOrEmptyValue(style['display']) ? currentElement.defaultDisplay : style['display'];
        if (currentElementDisplay.endsWith('flex') && style['flexWrap'] == 'wrap') {
          display = 'inline';
        }
      }
    }

    return display;
  }

  bool _isBlockElement(RenderBox child) {
    List<String> blockTypes = [
      'block',
      'flex',
    ];
    return blockTypes.contains(_getChildDisplayFromRenderBox(child));
  }

  @override
  bool hitTest(BoxHitTestResult result, {@required Offset position}) {
    assert(() {
      if (!hasSize) {
        if (debugNeedsLayout) {
          throw FlutterError.fromParts(<DiagnosticsNode>[
            ErrorSummary('Cannot hit test a render box that has never been laid out.'),
            describeForError('The hitTest() method was called on this RenderBox'),
            ErrorDescription("Unfortunately, this object's geometry is not known at this time, "
                'probably because it has never been laid out. '
                'This means it cannot be accurately hit-tested.'),
            ErrorHint('If you are trying '
                'to perform a hit test during the layout phase itself, make sure '
                "you only hit test nodes that have completed layout (e.g. the node's "
                'children, after their layout() method has been called).'),
          ]);
        }
        throw FlutterError.fromParts(<DiagnosticsNode>[
          ErrorSummary('Cannot hit test a render box with no size.'),
          describeForError('The hitTest() method was called on this RenderBox'),
          ErrorDescription('Although this node is not marked as needing layout, '
              'its size is not set.'),
          ErrorHint('A RenderBox object must have an '
              'explicit size before it can be hit-tested. Make sure '
              'that the RenderBox in question sets its size during layout.'),
        ]);
      }
      return true;
    }());
    if (hitTestChildren(result, position: position) || hitTestSelf(position)) {
      result.add(BoxHitTestEntry(this, position));
      return true;
    }
    return false;
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    basePaint(context, offset, (context, offset) {
      List<RenderObject> children = getChildrenAsList();
      children.sort((RenderObject prev, RenderObject next) {
        RenderLayoutParentData prevParentData = prev.parentData;
        RenderLayoutParentData nextParentData = next.parentData;
        // Place positioned element after non positioned element
        if (prevParentData.position == CSSPositionType.static && nextParentData.position != CSSPositionType.static) {
          return -1;
        }
        if (prevParentData.position != CSSPositionType.static && nextParentData.position == CSSPositionType.static) {
          return 1;
        }
        // z-index applies to element when position is not static
        int prevZIndex = prevParentData.position != CSSPositionType.static ? prevParentData.zIndex : 0;
        int nextZIndex = nextParentData.position != CSSPositionType.static ? nextParentData.zIndex : 0;
        return prevZIndex - nextZIndex;
      });

      RenderObject child = firstChild;
      while (child != null) {
        if (child is! RenderPositionHolder) {
          final RenderLayoutParentData childParentData = child.parentData;
          context.paintChild(child, childParentData.offset + offset);
          child = childParentData.nextSibling;
        }
      }
    });
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<MainAxisAlignment>('runAlignment', runAlignment));
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
}
