/*
 * Copyright (C) 2021-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:kraken/module.dart';
import 'package:kraken/rendering.dart';
import 'package:kraken/dom.dart';
import 'package:kraken/css.dart';

// Position and size info of each run (flex line) in flex layout.
// https://www.w3.org/TR/css-flexbox-1/#flex-lines
class _RunMetrics {
  _RunMetrics(
    this.mainAxisExtent,
    this.crossAxisExtent,
    double totalFlexGrow,
    double totalFlexShrink,
    this.baselineExtent,
    this.runChildren,
    double remainingFreeSpace,
  )   : _totalFlexGrow = totalFlexGrow,
        _totalFlexShrink = totalFlexShrink,
        _remainingFreeSpace = remainingFreeSpace;

  // Main size extent of the run.
  final double mainAxisExtent;

  // Cross size extent of the run.
  final double crossAxisExtent;

  // Total flex grow factor in the run.
  double get totalFlexGrow => _totalFlexGrow;
  double _totalFlexGrow;

  set totalFlexGrow(double value) {
    if (_totalFlexGrow != value) {
      _totalFlexGrow = value;
    }
  }

  // Total flex shrink factor in the run.
  double get totalFlexShrink => _totalFlexShrink;
  double _totalFlexShrink;

  set totalFlexShrink(double value) {
    if (_totalFlexShrink != value) {
      _totalFlexShrink = value;
    }
  }

  // Max extent above each flex items in the run.
  final double baselineExtent;

  // All the children RenderBox of layout in the run.
  final Map<int?, _RunChild> runChildren;

  // Remaining free space in the run.
  double get remainingFreeSpace => _remainingFreeSpace;
  double _remainingFreeSpace = 0;

  set remainingFreeSpace(double value) {
    if (_remainingFreeSpace != value) {
      _remainingFreeSpace = value;
    }
  }
}

// Infos about flex item in the run.
class _RunChild {
  _RunChild(
    RenderBox child,
    double originalMainSize,
    double adjustedMainSize,
    bool frozen,
  )   : _child = child,
        _originalMainSize = originalMainSize,
        _adjustedMainSize = adjustedMainSize,
        _frozen = frozen;

  // Render object of flex item.
  RenderBox get child => _child;
  RenderBox _child;

  set child(RenderBox value) {
    if (_child != value) {
      _child = value;
    }
  }

  // Original main size on first layout.
  double get originalMainSize => _originalMainSize;
  double _originalMainSize;

  set originalMainSize(double value) {
    if (_originalMainSize != value) {
      _originalMainSize = value;
    }
  }

  // Adjusted main size after flexible length resolve algorithm.
  double get adjustedMainSize => _adjustedMainSize;
  double _adjustedMainSize;

  set adjustedMainSize(double value) {
    if (_adjustedMainSize != value) {
      _adjustedMainSize = value;
    }
  }

  // Whether flex item should be frozen in flexible length resolve algorithm.
  bool get frozen => _frozen;
  bool _frozen = false;

  set frozen(bool value) {
    if (_frozen != value) {
      _frozen = value;
    }
  }
}

/// ## Layout algorithm
///
/// _This section describes how the framework causes [RenderFlowLayout] to position
/// its children._
///
/// Layout for a [RenderFlowLayout] proceeds in 7 steps:
///
/// 1. Layout positioned (eg. absolute/fixed) child first cause the size of position placeholder renderObject which is
///    layouted later depends on the size of its original RenderBoxModel.
/// 2. Layout flex items (not including position child and its position placeholder renderObject)
///    with no constraints and compute information of flex lines.
/// 3. Relayout children if flex factor styles (eg. flex-grow/flex-shrink) or cross axis stretch style (eg. align-items) exist.
/// 4. Set flex container depends on children size and container size styles.
/// 5. Set children offset based on flex container size and flex alignment styles (eg. justify-content).
/// 6. Layout and set offset of all the positioned placeholder renderObjects based on flex container size and
///    flex alignment styles cause positioned placeholder renderObject layout in a separated layer which is different
///    from flow layout algorithm.
/// 7. Set positioned child offset based on flex container size and its offset styles (eg. top/right/bottom/left).
///
class RenderFlexLayout extends RenderLayoutBox {
  RenderFlexLayout({
    List<RenderBox>? children,
    required CSSRenderStyle renderStyle,
  }) : super(renderStyle: renderStyle) {
    addAll(children);
  }

  // Flex line boxes of flex layout.
  // https://www.w3.org/TR/css-flexbox-1/#flex-lines
  List<_RunMetrics> _flexLineBoxMetrics = <_RunMetrics>[];

  // Cache the intrinsic size of children before flex-grow/flex-shrink
  // to avoid relayout when style of flex items changes.
  final Map<int, double> _childrenIntrinsicMainSizes = {};

  // Cache original constraints of children on the first layout.
  final Map<int, BoxConstraints> _childrenOldConstraints = {};

  @override
  void dispose() {
    super.dispose();

    // Do not forget to clear reference variables, or it will cause memory leaks!
    _flexLineBoxMetrics.clear();
    _childrenIntrinsicMainSizes.clear();
    _childrenOldConstraints.clear();
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

  bool get _isHorizontalFlexDirection {
    return CSSFlex.isHorizontalFlexDirection(renderStyle.flexDirection);
  }

  // Get start/end padding in the main axis according to flex direction.
  double flowAwareMainAxisPadding({bool isEnd = false}) {
    if (_isHorizontalFlexDirection) {
      return isEnd ? renderStyle.paddingRight.computedValue : renderStyle.paddingLeft.computedValue;
    } else {
      return isEnd ? renderStyle.paddingBottom.computedValue : renderStyle.paddingTop.computedValue;
    }
  }

  // Get start/end padding in the cross axis according to flex direction.
  double flowAwareCrossAxisPadding({bool isEnd = false}) {
    if (_isHorizontalFlexDirection) {
      return isEnd ? renderStyle.paddingBottom.computedValue : renderStyle.paddingTop.computedValue;
    } else {
      return isEnd ? renderStyle.paddingRight.computedValue : renderStyle.paddingLeft.computedValue;
    }
  }

  // Get start/end border in the main axis according to flex direction.
  double flowAwareMainAxisBorder({bool isEnd = false}) {
    if (_isHorizontalFlexDirection) {
      return isEnd ? renderStyle.effectiveBorderRightWidth.computedValue : renderStyle.effectiveBorderLeftWidth.computedValue;
    } else {
      return isEnd ? renderStyle.effectiveBorderBottomWidth.computedValue : renderStyle.effectiveBorderTopWidth.computedValue;
    }
  }

  // Get start/end border in the cross axis according to flex direction.
  double flowAwareCrossAxisBorder({bool isEnd = false}) {
    if (_isHorizontalFlexDirection) {
      return isEnd ? renderStyle.effectiveBorderBottomWidth.computedValue : renderStyle.effectiveBorderTopWidth.computedValue;
    } else {
      return isEnd ? renderStyle.effectiveBorderRightWidth.computedValue : renderStyle.effectiveBorderLeftWidth.computedValue;
    }
  }

  // Get start/end margin of child in the main axis according to flex direction.
  double? flowAwareChildMainAxisMargin(RenderBox child, {bool isEnd = false}) {
    RenderBoxModel? childRenderBoxModel;
    if (child is RenderBoxModel) {
      childRenderBoxModel = child;
    } else if (child is RenderPositionPlaceholder) {
      childRenderBoxModel = child.positioned;
    }
    if (childRenderBoxModel == null) {
      return 0;
    }

    if (_isHorizontalFlexDirection) {
      return isEnd
          ? childRenderBoxModel.renderStyle.marginRight.computedValue
          : childRenderBoxModel.renderStyle.marginLeft.computedValue;
    } else {
      return isEnd
          ? childRenderBoxModel.renderStyle.marginBottom.computedValue
          : childRenderBoxModel.renderStyle.marginTop.computedValue;
    }
  }

  // Get start/end margin of child in the cross axis according to flex direction.
  double? flowAwareChildCrossAxisMargin(RenderBox child, {bool isEnd = false}) {
    RenderBoxModel? childRenderBoxModel;
    if (child is RenderBoxModel) {
      childRenderBoxModel = child;
    } else if (child is RenderPositionPlaceholder) {
      childRenderBoxModel = child.positioned;
    }

    if (childRenderBoxModel == null) {
      return 0;
    }
    if (_isHorizontalFlexDirection) {
      return isEnd
          ? childRenderBoxModel.renderStyle.marginBottom.computedValue
          : childRenderBoxModel.renderStyle.marginTop.computedValue;
    } else {
      return isEnd
          ? childRenderBoxModel.renderStyle.marginRight.computedValue
          : childRenderBoxModel.renderStyle.marginLeft.computedValue;
    }
  }

  double _getFlexGrow(RenderBox child) {
    // Flex shrink has no effect on placeholder of positioned element.
    if (child is RenderPositionPlaceholder) {
      return 0;
    }
    return child is RenderBoxModel ? child.renderStyle.flexGrow : 0.0;
  }

  double _getFlexShrink(RenderBox child) {
    // Flex shrink has no effect on placeholder of positioned element.
    if (child is RenderPositionPlaceholder) {
      return 0;
    }
    return child is RenderBoxModel ? child.renderStyle.flexShrink : 0.0;
  }

  double? _getFlexBasis(RenderBox child) {
    if (child is RenderBoxModel && child.renderStyle.flexBasis != CSSLengthValue.auto) {
      return child.renderStyle.flexBasis?.computedValue;
    }
    return null;
  }

  AlignSelf _getAlignSelf(RenderBox child) {
    // Flex shrink has no effect on placeholder of positioned element.
    if (child is RenderPositionPlaceholder) {
      return AlignSelf.auto;
    }
    return child is RenderBoxModel
        ? child.renderStyle.alignSelf
        : AlignSelf.auto;
  }

  double _getMaxMainAxisSize(RenderBox child) {
    double? maxMainSize;
    if (child is RenderBoxModel) {
      double? maxWidth = child.renderStyle.maxWidth.isNone ?
        null : child.renderStyle.maxWidth.computedValue;
      double? maxHeight = child.renderStyle.maxHeight.isNone ?
        null : child.renderStyle.maxHeight.computedValue;
      maxMainSize = _isHorizontalFlexDirection
              ? maxWidth : maxHeight;
    }
    return maxMainSize ?? double.infinity;
  }

  // Calculate automatic minimum size of flex item.
  // Refer to https://www.w3.org/TR/css-flexbox-1/#min-size-auto for detail rules
  double? _getMinMainAxisSize(RenderBoxModel child) {
    double? minMainSize;

    double? contentSize = 0;
    // Min width of flex item if min-width is not specified use auto min width instead.
    double? minWidth = 0;
    // Min height of flex item if min-height is not specified use auto min height instead.
    double? minHeight = 0;

    RenderStyle? childRenderStyle = child.renderStyle;

    if (child is RenderBoxModel) {
      minWidth = childRenderStyle.minWidth.isAuto
          ? child.autoMinWidth
          : childRenderStyle.minWidth.computedValue;
      minHeight = childRenderStyle.minHeight.isAuto
          ? child.autoMinHeight
          : childRenderStyle.minHeight.computedValue;
    } else if (child is RenderTextBox) {
      minWidth = child.autoMinWidth;
      minHeight = child.autoMinHeight;
    }

    contentSize = _isHorizontalFlexDirection
        ? minWidth
        : minHeight;

    if (child is RenderIntrinsic &&
        childRenderStyle.intrinsicRatio != null &&
        _isHorizontalFlexDirection &&
        childRenderStyle.width.isAuto) {
      double transferredSize = childRenderStyle.height.isNotAuto
          ? childRenderStyle.height.computedValue * childRenderStyle.intrinsicRatio!
          : childRenderStyle.intrinsicWidth!;
      minMainSize = math.min(contentSize, transferredSize);
    } else if (child is RenderIntrinsic &&
        childRenderStyle.intrinsicRatio != null &&
        !_isHorizontalFlexDirection &&
        childRenderStyle.height.isAuto) {
      double transferredSize = childRenderStyle.width.isNotAuto
          ? childRenderStyle.width.computedValue / childRenderStyle.intrinsicRatio!
          : childRenderStyle.intrinsicHeight!;
      minMainSize = math.min(contentSize, transferredSize);
    } else if (child is RenderBoxModel) {
      double? specifiedMainSize = _isHorizontalFlexDirection
          ? child.renderStyle.contentBoxLogicalWidth
          : child.renderStyle.contentBoxLogicalHeight;
      minMainSize = specifiedMainSize != null
          ? math.min(contentSize, specifiedMainSize)
          : contentSize;
    } else if (child is RenderTextBox) {
      minMainSize = contentSize;
    }

    return minMainSize;
  }

  double _getShrinkConstraints(RenderBox child,
      Map<int?, _RunChild> runChildren, double remainingFreeSpace) {
    double totalWeightedFlexShrink = 0;
    runChildren.forEach((int? hashCode, _RunChild runChild) {
      double childOriginalMainSize = runChild.originalMainSize;
      RenderBox child = runChild.child;
      if (!runChild.frozen) {
        double childFlexShrink = _getFlexShrink(child);
        totalWeightedFlexShrink += childOriginalMainSize * childFlexShrink;
      }
    });
    if (totalWeightedFlexShrink == 0) {
      return 0;
    }

    int? childNodeId;
    if (child is RenderTextBox) {
      childNodeId = child.hashCode;
    } else if (child is RenderBoxModel) {
      childNodeId = child.hashCode;
    }

    _RunChild current = runChildren[childNodeId]!;
    double currentOriginalMainSize = current.originalMainSize;
    double currentFlexShrink = _getFlexShrink(current.child);
    double currentExtent = currentFlexShrink * currentOriginalMainSize;
    double minusConstraints =
        (currentExtent / totalWeightedFlexShrink) * remainingFreeSpace;

    return minusConstraints;
  }

  double _getCrossAxisExtent(RenderBox? child) {
    double marginHorizontal = 0;
    double marginVertical = 0;

    RenderBoxModel? childRenderBoxModel;
    if (child is RenderBoxModel) {
      childRenderBoxModel = child;
    } else if (child is RenderPositionPlaceholder) {
      // Position placeholder of flex item need to layout as its original renderBox
      // so it needs to add margin to its extent.
      childRenderBoxModel = child.positioned;
    }

    if (childRenderBoxModel != null) {
      marginHorizontal = childRenderBoxModel.renderStyle.marginLeft.computedValue +
          childRenderBoxModel.renderStyle.marginRight.computedValue;
      marginVertical = childRenderBoxModel.renderStyle.marginTop.computedValue +
          childRenderBoxModel.renderStyle.marginBottom.computedValue;
    }

    Size? childSize = _getChildSize(child);
    if (_isHorizontalFlexDirection) {
      return childSize!.height + marginVertical;
    } else {
      return childSize!.width + marginHorizontal;
    }
  }

  bool _isChildMainAxisClip(RenderBoxModel renderBoxModel) {
    if (renderBoxModel is RenderIntrinsic) {
      return false;
    }
    if (_isHorizontalFlexDirection) {
      return renderBoxModel.clipX;
    } else {
      return renderBoxModel.clipY;
    }
  }

  double _getMainAxisExtent(RenderBox child,
      {bool shouldUseIntrinsicMainSize = false}) {
    double marginHorizontal = 0;
    double marginVertical = 0;

    RenderBoxModel? childRenderBoxModel;
    if (child is RenderBoxModel) {
      childRenderBoxModel = child;
    } else if (child is RenderPositionPlaceholder) {
      // Position placeholder of flex item need to layout as its original renderBox
      // so it needs to add margin to its extent.
      childRenderBoxModel = child.positioned;
    }

    if (childRenderBoxModel != null) {
      marginHorizontal = childRenderBoxModel.renderStyle.marginLeft.computedValue +
          childRenderBoxModel.renderStyle.marginRight.computedValue;
      marginVertical = childRenderBoxModel.renderStyle.marginTop.computedValue +
          childRenderBoxModel.renderStyle.marginBottom.computedValue;
    }

    double baseSize = _getMainSize(child,
        shouldUseIntrinsicMainSize: shouldUseIntrinsicMainSize);
    if (_isHorizontalFlexDirection) {
      return baseSize + marginHorizontal;
    } else {
      return baseSize + marginVertical;
    }
  }

  double _getMainSize(RenderBox child,
      {bool shouldUseIntrinsicMainSize = false}) {
    Size? childSize = _getChildSize(child,
        shouldUseIntrinsicMainSize: shouldUseIntrinsicMainSize);
    if (_isHorizontalFlexDirection) {
      return childSize!.width;
    } else {
      return childSize!.height;
    }
  }

  @override
  void performLayout() {
    if (kProfileMode && PerformanceTiming.enabled()) {
      childLayoutDuration = 0;
      PerformanceTiming.instance()
          .mark(PERF_FLEX_LAYOUT_START, uniqueId: hashCode);
    }

    _doPerformLayout();

    if (needsRelayout) {
      _doPerformLayout();
      needsRelayout = false;
    }

    if (kProfileMode && PerformanceTiming.enabled()) {
      DateTime flexLayoutEndTime = DateTime.now();
      int amendEndTime =
          flexLayoutEndTime.microsecondsSinceEpoch - childLayoutDuration;
      PerformanceTiming.instance().mark(PERF_FLEX_LAYOUT_END,
          uniqueId: hashCode, startTime: amendEndTime);
    }
  }

  void _doPerformLayout() {
    beforeLayout();

    List<RenderBoxModel> _positionedChildren = [];
    List<RenderPositionPlaceholder> _positionPlaceholderChildren = [];
    List<RenderBox> _flexItemChildren = [];
    List<RenderBoxModel> _stickyChildren = [];

    // Prepare children of different type for layout.
    RenderBox? child = firstChild;
    while (child != null) {
      final RenderLayoutParentData childParentData = child.parentData as RenderLayoutParentData;
      if (child is RenderBoxModel && childParentData.isPositioned) {
        _positionedChildren.add(child);
      } else if (child is RenderPositionPlaceholder && _isPlaceholderPositioned(child)) {
        _positionPlaceholderChildren.add(child);
      } else {
        _flexItemChildren.add(child);
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

    // Layout non positioned element (include element in normal flow and
    // placeholder of positioned element).
    _layoutFlexItems(_flexItemChildren);

    // Every placeholder of positioned element should be layouted in a separated layer in flex layout
    // which is different from the placeholder in flow layout which layout in the same flow as
    // other elements in normal flow.
    for (RenderPositionPlaceholder child in _positionPlaceholderChildren) {
      _layoutPositionPlaceholder(child);
    }

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

  // There are 4 steps for layout flex items.
  // 1. Layout children to generate flex line boxes metrics.
  // 2. Relayout children according to flex factor properties and alignment properties in cross axis.
  // 3. Set flex container size according to children size and its own size styles.
  // 4. Align children according to alignment properties.
  void _layoutFlexItems(List<RenderBox> children) {
    // If no child exists, stop layout.
    if (children.isEmpty) {
      _setContainerSizeWithNoChild();
      return;
    }

    // Layout children to compute metrics of flex lines.
    List<_RunMetrics> _runMetrics = _computeRunMetrics(children);

    // Compute spacing before and between each flex line.
    Map<String, double> _runSpacingMap = _computeRunSpacing(_runMetrics);

    // Adjust children size based on flex properties which may affect children size.
    _adjustChildrenSize(_runMetrics, _runSpacingMap);

    // Set flex container size.
    _setContainerSize(_runMetrics);

    // Set children offset based on flex alignment properties.
    _setChildrenOffset(_runMetrics, _runSpacingMap);
  }

  // Layout position placeholder.
  void _layoutPositionPlaceholder(RenderPositionPlaceholder child) {
    List<RenderBox> _positionPlaceholderChildren = [child];

    // Layout children to compute metrics of flex lines.
    List<_RunMetrics> _runMetrics = _computeRunMetrics(_positionPlaceholderChildren);

    // Compute spacing before and between each flex line.
    Map<String, double> _runSpacingMap = _computeRunSpacing(_runMetrics);

    // Set children offset based on flex alignment properties.
    _setChildrenOffset(_runMetrics, _runSpacingMap);
  }

  // Layout children in normal flow order to calculate metrics of flex lines according to its constraints
  // and flex-wrap property.
  List<_RunMetrics> _computeRunMetrics(
    List<RenderBox> children,
  ) {
    List<_RunMetrics> _runMetrics = <_RunMetrics>[];

    if (children.isEmpty) return _runMetrics;

    double runMainAxisExtent = 0.0;
    double runCrossAxisExtent = 0.0;

    // Determine used flex factor, size inflexible items, calculate free space.
    double totalFlexGrow = 0;
    double totalFlexShrink = 0;

    double maxSizeAboveBaseline = 0;
    double maxSizeBelowBaseline = 0;

    // Max length of each flex line
    double flexLineLimit = 0.0;

    // Use scrolling container to calculate flex line limit for scrolling content box
    RenderBoxModel? containerBox =
      isScrollingContentBox ? parent as RenderBoxModel? : this;
    if (_isHorizontalFlexDirection) {
      flexLineLimit = renderStyle.contentMaxConstraintsWidth;
    } else {
      flexLineLimit = containerBox!.contentConstraints!.maxHeight;
    }

    // Info about each flex item in each flex line
    Map<int?, _RunChild> runChildren = {};

    for (RenderBox child in children) {
      final RenderLayoutParentData? childParentData = child.parentData as RenderLayoutParentData?;
      BoxConstraints childConstraints;
      int childNodeId = child.hashCode;

      if (_isPlaceholderPositioned(child)) {
        RenderBoxModel positionedBox = (child as RenderPositionPlaceholder).positioned!;
        if (positionedBox.hasSize) {
          // Flutter only allow access size of direct children, so cannot use realDisplayedBox.size
          Size realDisplayedBoxSize = positionedBox.getBoxSize(positionedBox.contentSize);
          double realDisplayedBoxWidth = realDisplayedBoxSize.width;
          double realDisplayedBoxHeight = realDisplayedBoxSize.height;
          childConstraints = BoxConstraints(
            minWidth: realDisplayedBoxWidth,
            maxWidth: realDisplayedBoxWidth,
            minHeight: realDisplayedBoxHeight,
            maxHeight: realDisplayedBoxHeight,
          );
        } else {
          childConstraints = BoxConstraints();
        }
      } else if (child is RenderBoxModel) {
        childConstraints = child.getConstraints();
      } else if (child is RenderTextBox) {
        childConstraints = child.getConstraints();
      } else {
        childConstraints = BoxConstraints();
      }

      // Whether child need to layout.
      bool isChildNeedsLayout = true;
      if (child.hasSize &&
        !needsRelayout &&
        (childConstraints == _childrenOldConstraints[child.hashCode]) &&
        ((child is RenderBoxModel && !child.needsLayout) ||
          (child is RenderTextBox && !child.needsLayout))) {
        isChildNeedsLayout = false;
      }

      if (isChildNeedsLayout) {
        late DateTime childLayoutStart;
        if (kProfileMode && PerformanceTiming.enabled()) {
          childLayoutStart = DateTime.now();
        }
        _childrenOldConstraints[child.hashCode] = childConstraints;

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
        Size? childSize = _getChildSize(child);
        _childrenIntrinsicMainSizes[child.hashCode] =
        _isHorizontalFlexDirection
          ? childSize!.width
          : childSize!.height;
      }

      Size? childSize = _getChildSize(child, shouldUseIntrinsicMainSize: true);

      double childMainAxisExtent =
      _getMainAxisExtent(child, shouldUseIntrinsicMainSize: true);
      double childCrossAxisExtent = _getCrossAxisExtent(child);
      bool isExceedFlexLineLimit =
        runMainAxisExtent + childMainAxisExtent > flexLineLimit;
      // calculate flex line
      if ((renderStyle.flexWrap == FlexWrap.wrap ||
        renderStyle.flexWrap == FlexWrap.wrapReverse) &&
        runChildren.isNotEmpty &&
        isExceedFlexLineLimit) {

        _runMetrics.add(_RunMetrics(
          runMainAxisExtent,
          runCrossAxisExtent,
          totalFlexGrow,
          totalFlexShrink,
          maxSizeAboveBaseline,
          runChildren,
          0));
        runChildren = {};
        runMainAxisExtent = 0.0;
        runCrossAxisExtent = 0.0;
        maxSizeAboveBaseline = 0.0;
        maxSizeBelowBaseline = 0.0;

        totalFlexGrow = 0;
        totalFlexShrink = 0;
      }
      runMainAxisExtent += childMainAxisExtent;
      runCrossAxisExtent = math.max(runCrossAxisExtent, childCrossAxisExtent);

      // Calculate baseline extent of layout box.
      AlignSelf alignSelf = _getAlignSelf(child);

      // Vertical align is only valid for inline box.
      // Baseline alignment in column direction behave the same as flex-start.
      if (_isHorizontalFlexDirection && (alignSelf == AlignSelf.baseline ||
        renderStyle.alignItems == AlignItems.baseline)) {
        // Distance from top to baseline of child
        double childAscent = _getChildAscent(child);
        double? lineHeight = _getLineHeight(child);

        // Leading space between content box and virtual box of child.
        double childLeading = 0;
        if (lineHeight != null) {
          childLeading = lineHeight - childSize!.height;
        }

        double? childMarginTop = 0;
        double? childMarginBottom = 0;
        if (child is RenderBoxModel) {
          childMarginTop = child.renderStyle.marginTop.computedValue;
          childMarginBottom = child.renderStyle.marginBottom.computedValue;
        }
        maxSizeAboveBaseline = math.max(
          childAscent + childLeading / 2,
          maxSizeAboveBaseline,
        );
        maxSizeBelowBaseline = math.max(
          childMarginTop +
            childMarginBottom +
            childSize!.height -
            childAscent +
            childLeading / 2,
          maxSizeBelowBaseline,
        );
        runCrossAxisExtent = maxSizeAboveBaseline + maxSizeBelowBaseline;
      } else {
        runCrossAxisExtent = math.max(runCrossAxisExtent, childCrossAxisExtent);
      }

      runChildren[childNodeId] = _RunChild(
        child,
        _getMainSize(child, shouldUseIntrinsicMainSize: true),
        0,
        false,
      );

      childParentData!.runIndex = _runMetrics.length;

      assert(child.parentData == childParentData);

      final double flexGrow = _getFlexGrow(child);
      final double flexShrink = _getFlexShrink(child);
      if (flexGrow > 0) {
        totalFlexGrow += flexGrow;
      }
      if (flexShrink > 0) {
        totalFlexShrink += flexShrink;
      }
    }

    if (runChildren.isNotEmpty) {
      _runMetrics.add(_RunMetrics(
        runMainAxisExtent,
        runCrossAxisExtent,
        totalFlexGrow,
        totalFlexShrink,
        maxSizeAboveBaseline,
        runChildren,
        0));
    }

    _flexLineBoxMetrics = _runMetrics;

    return _runMetrics;
  }

  // Compute the leading and between spacing of each flex line.
  Map<String, double> _computeRunSpacing(
    List<_RunMetrics> _runMetrics,
    ) {
    double? contentBoxLogicalWidth = renderStyle.contentBoxLogicalWidth;
    double? contentBoxLogicalHeight = renderStyle.contentBoxLogicalHeight;
    double containerCrossAxisExtent = 0.0;

    if (!_isHorizontalFlexDirection) {
      containerCrossAxisExtent = contentBoxLogicalWidth ?? 0;
    } else {
      containerCrossAxisExtent = contentBoxLogicalHeight ?? 0;
    }

    double runCrossSize = _getRunsCrossSize(_runMetrics);

    // Calculate leading and between space between flex lines.
    final double crossAxisFreeSpace = containerCrossAxisExtent - runCrossSize;
    final int runCount = _runMetrics.length;
    double runLeadingSpace = 0.0;
    double runBetweenSpace = 0.0;

    // Align-content only works in when flex-wrap is no nowrap.
    if (renderStyle.flexWrap == FlexWrap.wrap ||
      renderStyle.flexWrap == FlexWrap.wrapReverse) {
      switch (renderStyle.alignContent) {
        case AlignContent.flexStart:
        case AlignContent.start:
          break;
        case AlignContent.flexEnd:
        case AlignContent.end:
          runLeadingSpace = crossAxisFreeSpace;
          break;
        case AlignContent.center:
          runLeadingSpace = crossAxisFreeSpace / 2.0;
          break;
        case AlignContent.spaceBetween:
          if (crossAxisFreeSpace < 0) {
            runBetweenSpace = 0;
          } else {
            runBetweenSpace =
            runCount > 1 ? crossAxisFreeSpace / (runCount - 1) : 0.0;
          }
          break;
        case AlignContent.spaceAround:
          if (crossAxisFreeSpace < 0) {
            runLeadingSpace = crossAxisFreeSpace / 2.0;
            runBetweenSpace = 0;
          } else {
            runBetweenSpace = crossAxisFreeSpace / runCount;
            runLeadingSpace = runBetweenSpace / 2.0;
          }
          break;
        case AlignContent.spaceEvenly:
          if (crossAxisFreeSpace < 0) {
            runLeadingSpace = crossAxisFreeSpace / 2.0;
            runBetweenSpace = 0;
          } else {
            runBetweenSpace = crossAxisFreeSpace / (runCount + 1);
            runLeadingSpace = runBetweenSpace;
          }
          break;
        case AlignContent.stretch:
          runBetweenSpace = crossAxisFreeSpace / runCount;
          if (runBetweenSpace < 0) {
            runBetweenSpace = 0;
          }
          break;
      }
    }
    Map<String, double> _runSpacingMap = {
      'leading': runLeadingSpace,
      'between': runBetweenSpace
    };
    return _runSpacingMap;
  }

  // Find the size in the cross axis of flex lines.
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

  // Find the max size in the main axis of flex lines.
  // @TODO: add cache to avoid recalculate in one layout stage.
  double _getRunsMaxMainSize(
    List<_RunMetrics> _runMetrics,
  ) {
    // Find the max size of flex lines.
    _RunMetrics maxMainSizeMetrics =
      _runMetrics.reduce((_RunMetrics curr, _RunMetrics next) {
        return curr.mainAxisExtent > next.mainAxisExtent ? curr : next;
      });
    return maxMainSizeMetrics.mainAxisExtent;
  }

  // Resolve flex item length if flex-grow or flex-shrink exists.
  // https://www.w3.org/TR/css-flexbox-1/#resolve-flexible-lengths
  bool _resolveFlexibleLengths(
    _RunMetrics runMetric,
    double initialFreeSpace,
  ) {
    Map<int?, _RunChild> runChildren = runMetric.runChildren;
    double totalFlexGrow = runMetric.totalFlexGrow;
    double totalFlexShrink = runMetric.totalFlexShrink;
    bool isFlexGrow = initialFreeSpace > 0 && totalFlexGrow > 0;
    bool isFlexShrink = initialFreeSpace < 0 && totalFlexShrink > 0;

    double sumFlexFactors = isFlexGrow ? totalFlexGrow : totalFlexShrink;

    // If the sum of the unfrozen flex items’ flex factors is less than one,
    // multiply the initial free space by this sum as remaining free space.
    if (sumFlexFactors > 0 && sumFlexFactors < 1) {
      double remainingFreeSpace = initialFreeSpace;
      double fractional = initialFreeSpace * sumFlexFactors;
      if (fractional.abs() < remainingFreeSpace.abs()) {
        remainingFreeSpace = fractional;
      }
      runMetric.remainingFreeSpace = remainingFreeSpace;
    }

    List<_RunChild> minViolations = [];
    List<_RunChild> maxViolations = [];
    double totalViolation = 0;

    // Loop flex item to find min/max violations.
    runChildren.forEach((int? index, _RunChild runChild) {
      if (runChild.frozen) {
        return;
      }
      RenderBox child = runChild.child;
      int childNodeId = child.hashCode;

      _RunChild? current = runChildren[childNodeId];

      double? flexBasis = _getFlexBasis(child);
      double originalMainSize =
          flexBasis ?? current!.originalMainSize;

      double computedSize = originalMainSize;

      // Computed size by flex factor.
      double adjustedSize = originalMainSize;

      // Adjusted size after min and max size clamp.
      double flexGrow = _getFlexGrow(child);
      double flexShrink = _getFlexShrink(child);

      double remainingFreeSpace = runMetric.remainingFreeSpace;
      if (isFlexGrow && flexGrow > 0) {
        final double spacePerFlex = totalFlexGrow > 0
            ? (remainingFreeSpace / totalFlexGrow)
            : double.nan;
        final double flexGrow = _getFlexGrow(child);
        computedSize = originalMainSize + spacePerFlex * flexGrow;
      } else if (isFlexShrink && flexShrink > 0) {
        // If child's mainAxis have clips, it will create a new format context in it's children's.
        // so we do't need to care about child's size.
        if (child is RenderBoxModel && _isChildMainAxisClip(child)) {
          computedSize = originalMainSize + remainingFreeSpace > 0 ?
            originalMainSize + remainingFreeSpace : 0;
        } else {
          double shrinkValue =
              _getShrinkConstraints(child, runChildren, remainingFreeSpace);
          computedSize = originalMainSize + shrinkValue;
        }
      }

      adjustedSize = computedSize;

      // Find all the violations by comparing min and max size of flex items.
      if (child is RenderBoxModel && !_isChildMainAxisClip(child)) {
        double minMainAxisSize = _getMinMainAxisSize(child)!;
        double maxMainAxisSize = _getMaxMainAxisSize(child);
        if (computedSize < minMainAxisSize) {
          adjustedSize = minMainAxisSize;
        } else if (computedSize > maxMainAxisSize) {
          adjustedSize = maxMainAxisSize;
        }
      }

      double violation = adjustedSize - computedSize;

      // Collect all the flex items with violations.
      if (violation > 0) {
        minViolations.add(runChild);
      } else if (violation < 0) {
        maxViolations.add(runChild);
      }
      runChild.adjustedMainSize = adjustedSize;
      totalViolation += violation;
    });

    // Freeze over-flexed items.
    if (totalViolation == 0) {
      // If total violation is zero, freeze all the flex items and exit loop.
      runChildren.forEach((int? index, _RunChild runChild) {
        runChild.frozen = true;
      });
    } else {
      List<_RunChild> violations =
          totalViolation < 0 ? maxViolations : minViolations;

      // Find all the violations, set main size and freeze all the flex items.
      for (int i = 0; i < violations.length; i++) {
        _RunChild runChild = violations[i];
        runChild.frozen = true;
        RenderBox child = runChild.child;
        runMetric.remainingFreeSpace -=
            runChild.adjustedMainSize - runChild.originalMainSize;

        double flexGrow = _getFlexGrow(child);
        double flexShrink = _getFlexShrink(child);

        // If total violation is positive, freeze all the items with min violations.
        if (flexGrow > 0) {
          runMetric.totalFlexGrow -= flexGrow;

          // If total violation is negative, freeze all the items with max violations.
        } else if (flexShrink > 0) {
          runMetric.totalFlexShrink -= flexShrink;
        }
      }
    }

    return totalViolation != 0;
  }

  // Adjust children size (not include position placeholder) based on
  // flex factors (flex-grow/flex-shrink) and alignment in cross axis (align-items).
  //  https://www.w3.org/TR/css-flexbox-1/#resolve-flexible-lengths
  void _adjustChildrenSize(
    List<_RunMetrics> _runMetrics,
    Map<String, double> _runSpacingMap,
  ) {
    if (_runMetrics.isEmpty) return;

    double runBetweenSpace = _runSpacingMap['between']!;
    double? contentBoxLogicalWidth = renderStyle.contentBoxLogicalWidth;
    double? contentBoxLogicalHeight = renderStyle.contentBoxLogicalHeight;

    // Container's width specified by style or inherited from parent.
    double? containerWidth = 0;
    if (contentBoxLogicalWidth != null) {
      containerWidth = contentBoxLogicalWidth;
    } else if (contentConstraints!.hasTightWidth) {
      containerWidth = contentConstraints!.maxWidth;
    }

    // Container's height specified by style or inherited from parent.
    double? containerHeight = 0;
    if (contentBoxLogicalHeight != null) {
      containerHeight = contentBoxLogicalHeight;
    } else if (contentConstraints!.hasTightHeight) {
      containerHeight = contentConstraints!.maxHeight;
    }

    double? maxMainSize = _isHorizontalFlexDirection ? containerWidth : containerHeight;
    final BoxSizeType mainSizeType =
        maxMainSize == 0.0 ? BoxSizeType.automatic : BoxSizeType.specified;

    for (int i = 0; i < _runMetrics.length; ++i) {
      final _RunMetrics metrics = _runMetrics[i];
      final double totalFlexGrow = metrics.totalFlexGrow;
      final double totalFlexShrink = metrics.totalFlexShrink;
      final Map<int?, _RunChild> runChildren = metrics.runChildren;
      final List<_RunChild> runChildrenList = runChildren.values.toList();

      double totalSpace = 0;
      // Flex factor calculation depends on flex-basis if exists.
      void calTotalSpace(int? hashCode, _RunChild runChild) {
        double childSpace = runChild.originalMainSize;
        RenderBox child = runChild.child;
        double marginHorizontal = 0;
        double marginVertical = 0;
        if (child is RenderBoxModel) {
          double? flexBasis = _getFlexBasis(child);
          marginHorizontal = child.renderStyle.marginLeft.computedValue +
              child.renderStyle.marginRight.computedValue;
          marginVertical = child.renderStyle.marginTop.computedValue +
              child.renderStyle.marginBottom.computedValue;
          if (flexBasis != null) {
            childSpace = flexBasis;
          }
        }
        double mainAxisMargin = _isHorizontalFlexDirection ? marginHorizontal : marginVertical;
        totalSpace += childSpace + mainAxisMargin;
      }

      runChildren.forEach(calTotalSpace);

      // Flexbox with no size on main axis should adapt the main axis size with children.
      double initialFreeSpace = mainSizeType != BoxSizeType.automatic ?
        maxMainSize - totalSpace : 0;

      bool isFlexGrow = initialFreeSpace > 0 && totalFlexGrow > 0;
      bool isFlexShrink = initialFreeSpace < 0 && totalFlexShrink > 0;

      if (isFlexGrow || isFlexShrink) {
        // remainingFreeSpace starts out at the same value as initialFreeSpace
        // but as we place and lay out flex items we subtract from it.
        metrics.remainingFreeSpace = initialFreeSpace;

        // Loop flex items to resolve flexible length of flex items with flex factor.
        while (_resolveFlexibleLengths(metrics, initialFreeSpace)) {}
      }

      for (_RunChild runChild in runChildrenList) {
        RenderBox child = runChild.child;

        // Whether child needs to be stretched in the cross axis.
        bool isStretchSelf = needToStretchChildCrossSize(child);
        // Whether child cross size should be changed based on cross axis alignment change.
        bool isCrossSizeChanged = false;

        if (child is RenderBoxModel && child.hasSize) {
          Size? childSize = _getChildSize(child);
          double? childContentWidth = child.renderStyle.contentBoxLogicalWidth;
          double? childContentHeight = child.renderStyle.contentBoxLogicalHeight;
          double paddingLeft = child.renderStyle.paddingLeft.computedValue;
          double paddingRight = child.renderStyle.paddingRight.computedValue;
          double paddingTop = child.renderStyle.paddingTop.computedValue;
          double paddingBottom = child.renderStyle.paddingBottom.computedValue;
          double borderLeft = child.renderStyle.effectiveBorderLeftWidth.computedValue;
          double borderRight = child.renderStyle.effectiveBorderRightWidth.computedValue;
          double borderTop = child.renderStyle.effectiveBorderTopWidth.computedValue;
          double borderBottom = child.renderStyle.effectiveBorderBottomWidth.computedValue;

          double? childLogicalWidth = childContentWidth != null
            ? childContentWidth +
            borderLeft +
            borderRight +
            paddingLeft +
            paddingRight
            : null;
          double? childLogicalHeight = childContentHeight != null
            ? childContentHeight +
            borderTop +
            borderBottom +
            paddingTop +
            paddingBottom
            : null;

          // Cross size calculated from style which not including padding and border.
          double? childCrossLogicalSize =
          _isHorizontalFlexDirection
            ? childLogicalHeight
            : childLogicalWidth;
          // Cross size from first layout.
          double childCrossSize =
          _isHorizontalFlexDirection
            ? childSize!.height
            : childSize!.width;

          isCrossSizeChanged = childCrossSize != childCrossLogicalSize;
        }

        // Child's size don't need to recompute if no flex-grow、flex-shrink or cross size not changed.
        if (!isFlexGrow && !isFlexShrink && !isCrossSizeChanged) {
          continue;
        }

        // Skip scrolling content box.
        if (child is RenderBoxModel && child.isScrollingContentBox) {
          continue;
        }

        double flexGrow = _getFlexGrow(child);
        double flexShrink = _getFlexShrink(child);
        // Whether child need to layout.
        bool isChildNeedsLayout = (isFlexGrow && flexGrow > 0) ||
          (isFlexShrink && flexShrink > 0) ||
          isStretchSelf;

        if (!isChildNeedsLayout) {
          continue;
        }

        late DateTime childLayoutStart;
        if (kProfileMode && PerformanceTiming.enabled()) {
          childLayoutStart = DateTime.now();
        }

        BoxConstraints childConstraints = getChildConstraints(
          child,
          metrics,
          runBetweenSpace,
          isFlexGrow: isFlexGrow,
          isFlexShrink: isFlexShrink,
          isStretchSelf: isStretchSelf
        );
        child.layout(childConstraints, parentUsesSize: true);

        if (kProfileMode && PerformanceTiming.enabled()) {
          DateTime childLayoutEnd = DateTime.now();
          childLayoutDuration += (childLayoutEnd.microsecondsSinceEpoch -
            childLayoutStart.microsecondsSinceEpoch);
        }
      }
    }
  }

  // Get constraints of flex items which needs to change size due to
  // flex-grow/flex-shrink or align-items stretch.
  BoxConstraints getChildConstraints(
    RenderBox child,
    _RunMetrics metrics,
    double runBetweenSpace, {
    bool isFlexGrow = false,
    bool isFlexShrink = false,
    bool isStretchSelf = false,
  }) {
    BoxConstraints oldConstraints = child.constraints;
    double minConstraintWidth = oldConstraints.minWidth;
    double maxConstraintWidth = oldConstraints.maxWidth;
    double minConstraintHeight = oldConstraints.minHeight;
    double maxConstraintHeight = oldConstraints.maxHeight;

    if (child is RenderBoxModel) {
      RenderStyle? childRenderStyle = child.renderStyle;
      Size? childSize = _getChildSize(child);
      double flexGrow = _getFlexGrow(child);
      double flexShrink = _getFlexShrink(child);
      // Change main axis constraints
      if ((isFlexGrow && flexGrow > 0) || (isFlexShrink && flexShrink > 0)) {
        double mainSize = metrics.runChildren[child.hashCode]!.adjustedMainSize;
        if (_isHorizontalFlexDirection) {
          minConstraintWidth = maxConstraintWidth = mainSize;
        } else {
          minConstraintHeight = maxConstraintHeight = mainSize;
        }
      }
      // Change cross axis constraints.
      if (isStretchSelf) {
        bool isFlexWrap = renderStyle.flexWrap == FlexWrap.wrap ||
            renderStyle.flexWrap == FlexWrap.wrapReverse;
        final double runCrossAxisExtent = metrics.crossAxisExtent;
        if (_isHorizontalFlexDirection) {
          CSSLengthValue marginTop = childRenderStyle.marginTop;
          CSSLengthValue marginBottom = childRenderStyle.marginBottom;
          bool hasMaxConstraints = constraints.maxHeight != double.infinity;

          // Margin auto alignment takes priority over align-items stretch,
          // it will not stretch child in vertical direction.
          if (marginTop.isAuto || marginBottom.isAuto) {
            minConstraintHeight = maxConstraintHeight = childSize!.height;
          } else {
            double flexLineHeight =
                _getFlexLineHeight(runCrossAxisExtent, runBetweenSpace);
            // Should subtract margin when layout child.
            double marginVertical = marginTop.computedValue + marginBottom.computedValue;
            double childCrossSize = flexLineHeight - marginVertical;
            double stretchedHeight;
            // Flex line height should not exceed container's cross size if specified when flex-wrap is nowrap.
            if (!isFlexWrap && hasMaxConstraints) {
              double verticalBorderLength = renderStyle.border.vertical;
              double verticalPaddingLength = renderStyle.padding.vertical;
              stretchedHeight = math.min(
                constraints.maxHeight -
                  verticalBorderLength -
                  verticalPaddingLength,
                childCrossSize);
            } else {
              stretchedHeight = childCrossSize;
            }
            minConstraintHeight = maxConstraintHeight = stretchedHeight;
          }

          // Replaced element in flexbox with no size in cross axis should stretch according the intrinsic ratio.
          if (child is RenderIntrinsic &&
            child.renderStyle.width.isAuto &&
            child.renderStyle.minWidth.isAuto &&
            child.renderStyle.intrinsicRatio != null
          ) {
            minConstraintWidth = maxConstraintWidth = minConstraintHeight / child.renderStyle.intrinsicRatio!;
          }
        } else {
          CSSLengthValue marginLeft = childRenderStyle.marginLeft;
          CSSLengthValue marginRight = childRenderStyle.marginRight;
          bool hasMaxConstraints = constraints.maxHeight != double.infinity;
          // Margin auto alignment takes priority over align-items stretch,
          // it will not stretch child in horizontal direction.
          if (marginLeft.isAuto || marginRight.isAuto) {
            minConstraintWidth = maxConstraintWidth = childSize!.width;
          } else {
            double flexLineHeight =
                _getFlexLineHeight(runCrossAxisExtent, runBetweenSpace);
            // Should subtract margin when layout child.
            double marginHorizontal = marginLeft.computedValue + marginRight.computedValue;
            double childCrossSize = flexLineHeight - marginHorizontal;
            double stretchedWidth;
            // Flex line height should not exceed container's cross size if specified when flex-wrap is nowrap.
            if (!isFlexWrap && hasMaxConstraints) {
              double horizontalBorderLength = renderStyle.border.horizontal;
              double horizontalPaddingLength = renderStyle.padding.horizontal;
              stretchedWidth = math.min(
                constraints.maxWidth -
                  horizontalBorderLength -
                  horizontalPaddingLength,
                childCrossSize);
            } else {
              stretchedWidth = childCrossSize;
            }
            minConstraintWidth = maxConstraintWidth = stretchedWidth;
          }

          // Replaced element in flexbox with no size in cross axis should stretch according the intrinsic ratio.
          if (child is RenderIntrinsic &&
            child.renderStyle.height.isAuto &&
            child.renderStyle.minHeight.isAuto &&
            child.renderStyle.intrinsicRatio != null
          ) {
            minConstraintHeight = maxConstraintHeight = minConstraintWidth * child.renderStyle.intrinsicRatio!;
          }
        }
      }
    }

    BoxConstraints childConstraints = BoxConstraints(
      minWidth: minConstraintWidth,
      maxWidth: maxConstraintWidth,
      minHeight: minConstraintHeight,
      maxHeight: maxConstraintHeight,
    );

    return childConstraints;
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

    double contentWidth = _isHorizontalFlexDirection
      ? runMaxMainSize
      : runCrossSize;
    double contentHeight = _isHorizontalFlexDirection
      ? runCrossSize
      : runMaxMainSize;

    // Set flex container size.
    Size layoutContentSize = getContentSize(
      contentWidth: contentWidth,
      contentHeight: contentHeight,
    );
    size = getBoxSize(layoutContentSize);

    _setMaxScrollableSizeForFlex(_runMetrics);

    // Set auto value of min-width and min-height based on size of flex items.
    if (_isHorizontalFlexDirection) {
      autoMinWidth = _getMainAxisAutoSize(_runMetrics);
      autoMinHeight = _getCrossAxisAutoSize(_runMetrics);
    } else {
      autoMinHeight = _getMainAxisAutoSize(_runMetrics);
      autoMinWidth = _getCrossAxisAutoSize(_runMetrics);
    }
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

  // Record the main size of all lines.
  void _recordRunsMainSize(_RunMetrics _runMetrics, List<double> runMainSize) {
    Map<int?, _RunChild> runChildren = _runMetrics.runChildren;
    double runMainExtent = 0;
    void iterateRunChildren(int? hashCode, _RunChild runChild) {
      RenderBox child = runChild.child;
      double runChildMainSize =
          _isHorizontalFlexDirection ? child.size.width : child.size.height;
      if (child is RenderTextBox) {
        runChildMainSize = _isHorizontalFlexDirection
            ? child.autoMinWidth
            : child.autoMinHeight;
      }
      // Should add main axis margin of child to the main axis auto size of parent.
      if (child is RenderBoxModel) {
        double childMarginTop = child.renderStyle.marginTop.computedValue;
        double childMarginBottom = child.renderStyle.marginBottom.computedValue;
        double childMarginLeft = child.renderStyle.marginLeft.computedValue;
        double childMarginRight = child.renderStyle.marginRight.computedValue;
        runChildMainSize += _isHorizontalFlexDirection ?
          childMarginLeft + childMarginRight :
          childMarginTop + childMarginBottom;
      }
      runMainExtent += runChildMainSize;
    }

    runChildren.forEach(iterateRunChildren);
    runMainSize.add(runMainExtent);
  }

  // Get auto min size in the main axis which equals the main axis size of its contents.
  // https://www.w3.org/TR/css-sizing-3/#automatic-minimum-size
  double _getMainAxisAutoSize(
    List<_RunMetrics> _runMetrics,
  ) {
    double autoMinSize = 0;

    // Main size of each run.
    List<double> runMainSize = [];

    // Calculate the max main size of all runs.
    for (_RunMetrics _runMetrics in _runMetrics) {
      _recordRunsMainSize(_runMetrics, runMainSize);
    }

    autoMinSize = runMainSize.reduce((double curr, double next) {
      return curr > next ? curr : next;
    });
    return autoMinSize;
  }

  // Record the cross size of all lines.
  void _recordRunsCrossSize(_RunMetrics _runMetrics, List<double> runCrossSize) {
    Map<int?, _RunChild> runChildren = _runMetrics.runChildren;
    double runCrossExtent = 0;
    List<double> runChildrenCrossSize = [];
    void iterateRunChildren(int? hashCode, _RunChild runChild) {
      RenderBox child = runChild.child;
      double runChildCrossSize =
          _isHorizontalFlexDirection ? child.size.height : child.size.width;
      if (child is RenderTextBox) {
        runChildCrossSize = _isHorizontalFlexDirection
            ? child.autoMinHeight
            : child.autoMinWidth;
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
    List<_RunMetrics> _runMetrics,
  ) {
    double autoMinSize = 0;

    // Cross size of each run.
    List<double> runCrossSize = [];

    // Calculate the max cross size of all runs.
    for (_RunMetrics _runMetrics in _runMetrics) {
      _recordRunsCrossSize(_runMetrics, runCrossSize);
    }

    // Get the sum of lines
    for (double crossSize in runCrossSize) {
      autoMinSize += crossSize;
    }

    return autoMinSize;
  }

  // Set the size of scrollable overflow area for flex layout.
  // https://drafts.csswg.org/css-overflow-3/#scrollable
  void _setMaxScrollableSizeForFlex(List<_RunMetrics> _runMetrics) {
    // Scrollable main size collection of each line.
    List<double> scrollableMainSizeOfLines = [];
    // Scrollable cross size collection of each line.
    List<double> scrollableCrossSizeOfLines = [];
    // Total cross size of previous lines.
    double preLinesCrossSize = 0;

    for (_RunMetrics runMetric in _runMetrics) {
      Map<int?, _RunChild> runChildren = runMetric.runChildren;

      List<RenderBox> runChildrenList = [];
      // Scrollable main size collection of each child in the line.
      List<double> scrollableMainSizeOfChildren = [];
      // Scrollable cross size collection of each child in the line.
      List<double> scrollableCrossSizeOfChildren = [];

      void iterateRunChildren(int? hashCode, _RunChild runChild) {
        RenderBox child = runChild.child;
        // Total main size of previous siblings.
        double preSiblingsMainSize = 0;
        for (RenderBox sibling in runChildrenList) {
          preSiblingsMainSize +=
              _isHorizontalFlexDirection ? sibling.size.width : sibling.size.height;
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
          childMarginTop = childRenderStyle.marginTop.computedValue;
          childMarginLeft = childRenderStyle.marginLeft.computedValue;
        }

        scrollableMainSizeOfChildren.add(preSiblingsMainSize +
            (_isHorizontalFlexDirection
                ? childScrollableSize.width + childMarginLeft
                : childScrollableSize.height + childMarginTop));
        scrollableCrossSizeOfChildren.add(_isHorizontalFlexDirection
            ? childScrollableSize.height + childMarginTop
            : childScrollableSize.width + childMarginLeft);
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
        : (_isHorizontalFlexDirection
            ? container.renderStyle.paddingLeft.computedValue
            : container.renderStyle.paddingTop.computedValue) +
        maxScrollableMainSizeOfLines;

    // Max scrollable cross size of all lines.
    double maxScrollableCrossSizeOfLines =
        scrollableCrossSizeOfLines.reduce((double curr, double next) {
      return curr > next ? curr : next;
    });

    // No need to add padding for scrolling content box.
    double maxScrollableCrossSizeOfChildren = isScrollContainer
        ? maxScrollableCrossSizeOfLines
        : (_isHorizontalFlexDirection
            ? container.renderStyle.paddingTop.computedValue
            : container.renderStyle.paddingLeft.computedValue) +
        maxScrollableCrossSizeOfLines;

    double containerContentWidth = size.width -
        container.renderStyle.effectiveBorderLeftWidth.computedValue -
        container.renderStyle.effectiveBorderRightWidth.computedValue;
    double containerContentHeight = size.height -
        container.renderStyle.effectiveBorderTopWidth.computedValue -
        container.renderStyle.effectiveBorderBottomWidth.computedValue;
    double maxScrollableMainSize = math.max(
        _isHorizontalFlexDirection ? containerContentWidth : containerContentHeight,
        maxScrollableMainSizeOfChildren);
    double maxScrollableCrossSize = math.max(
        _isHorizontalFlexDirection ? containerContentHeight : containerContentWidth,
        maxScrollableCrossSizeOfChildren);

    scrollableSize = _isHorizontalFlexDirection
        ? Size(maxScrollableMainSize, maxScrollableCrossSize)
        : Size(maxScrollableCrossSize, maxScrollableMainSize);
  }

  // Get flex line height according to flex-wrap style.
  double _getFlexLineHeight(
    double runCrossAxisExtent,
    double runBetweenSpace,
    { bool beforeSetSize = true }
  ) {
    // Flex line of align-content stretch should includes between space.
    bool isMultiLineStretch = (renderStyle.flexWrap == FlexWrap.wrap ||
            renderStyle.flexWrap == FlexWrap.wrapReverse) &&
        renderStyle.alignContent == AlignContent.stretch;
    // The height of flex line in single line equals to flex container's cross size.
    bool isSingleLine = (renderStyle.flexWrap != FlexWrap.wrap &&
        renderStyle.flexWrap != FlexWrap.wrapReverse);

    if (isSingleLine) {
      // Use content size if container size is not set yet.
      return beforeSetSize ? runCrossAxisExtent : _getContentCrossSize();
    } else if (isMultiLineStretch) {
      return runCrossAxisExtent + runBetweenSpace;
    } else {
      return runCrossAxisExtent;
    }
  }

  // Set children offset based on alignment properties.
  void _setChildrenOffset(
    List<_RunMetrics> _runMetrics,
    Map<String, double> _runSpacingMap,
  ) {
    if (_runMetrics.isEmpty) return;

    double runLeadingSpace = _runSpacingMap['leading']!;
    double runBetweenSpace = _runSpacingMap['between']!;
    // Cross axis offset of each flex line.
    double crossAxisOffset = runLeadingSpace;
    double mainAxisContentSize;
    double crossAxisContentSize;

    if (_isHorizontalFlexDirection) {
      mainAxisContentSize = contentSize.width;
      crossAxisContentSize = contentSize.height;
    } else {
      mainAxisContentSize = contentSize.height;
      crossAxisContentSize = contentSize.width;
    }

    // Set offset of children in each flex line.
    for (int i = 0; i < _runMetrics.length; ++i) {
      final _RunMetrics metrics = _runMetrics[i];
      final double runMainAxisExtent = metrics.mainAxisExtent;
      final double runCrossAxisExtent = metrics.crossAxisExtent;
      final double runBaselineExtent = metrics.baselineExtent;
      final double totalFlexGrow = metrics.totalFlexGrow;
      final double totalFlexShrink = metrics.totalFlexShrink;
      final Map<int?, _RunChild> runChildren = metrics.runChildren;
      final List<_RunChild> runChildrenList = runChildren.values.toList();

      final double mainContentSizeDelta =
          mainAxisContentSize - runMainAxisExtent;
      bool isFlexGrow = mainContentSizeDelta > 0 && totalFlexGrow > 0;
      bool isFlexShrink = mainContentSizeDelta < 0 && totalFlexShrink > 0;

      // If flex grow or flex shrink exists, remaining space should be zero.
      final double remainingSpace =
          (isFlexGrow || isFlexShrink) ? 0 : mainContentSizeDelta;
      late double leadingSpace;
      late double betweenSpace;

      final int runChildrenCount = runChildren.length;

      // flipMainAxis is used to decide whether to lay out left-to-right/top-to-bottom (false), or
      // right-to-left/bottom-to-top (true). The _startIsTopLeft will return null if there's only
      // one child and the relevant direction is null, in which case we arbitrarily decide not to
      // flip, but that doesn't have any detectable effect.
      final bool flipMainAxis =
          !(_startIsTopLeft(renderStyle.flexDirection) ?? true);
      switch (renderStyle.justifyContent) {
        case JustifyContent.flexStart:
        case JustifyContent.start:
          leadingSpace = 0.0;
          betweenSpace = 0.0;
          break;
        case JustifyContent.flexEnd:
        case JustifyContent.end:
          leadingSpace = remainingSpace;
          betweenSpace = 0.0;
          break;
        case JustifyContent.center:
          leadingSpace = remainingSpace / 2.0;
          betweenSpace = 0.0;
          break;
        case JustifyContent.spaceBetween:
          leadingSpace = 0.0;
          if (remainingSpace < 0) {
            betweenSpace = 0.0;
          } else {
            betweenSpace = runChildrenCount > 1
                ? remainingSpace / (runChildrenCount - 1)
                : 0.0;
          }
          break;
        case JustifyContent.spaceAround:
          if (remainingSpace < 0) {
            leadingSpace = remainingSpace / 2.0;
            betweenSpace = 0.0;
          } else {
            betweenSpace =
                runChildrenCount > 0 ? remainingSpace / runChildrenCount : 0.0;
            leadingSpace = betweenSpace / 2.0;
          }
          break;
        case JustifyContent.spaceEvenly:
          if (remainingSpace < 0) {
            leadingSpace = remainingSpace / 2.0;
            betweenSpace = 0.0;
          } else {
            betweenSpace = runChildrenCount > 0
                ? remainingSpace / (runChildrenCount + 1)
                : 0.0;
            leadingSpace = betweenSpace;
          }
          break;
        default:
      }

      // Calculate margin auto children in the main axis.
      double mainAxisMarginAutoChildrenCount = 0;

      for (_RunChild runChild in runChildrenList) {
        RenderBox child = runChild.child;
        if (isChildMainAxisMarginAutoExist(child)) {
          mainAxisMarginAutoChildrenCount++;
        }
      }

      // Justify-content has no effect if auto margin of child exists in the main axis.
      if (mainAxisMarginAutoChildrenCount != 0) {
        leadingSpace = 0.0;
        betweenSpace = 0.0;
      }

      double mainAxisStartPadding = flowAwareMainAxisPadding();
      double crossAxisStartPadding = flowAwareCrossAxisPadding();

      double mainAxisStartBorder = flowAwareMainAxisBorder();
      double crossAxisStartBorder = flowAwareCrossAxisBorder();

      // Main axis position of child on layout.
      double childMainPosition = flipMainAxis
          ? mainAxisStartPadding +
              mainAxisStartBorder +
              mainAxisContentSize -
              leadingSpace
          : leadingSpace + mainAxisStartPadding + mainAxisStartBorder;

      for (_RunChild runChild in runChildrenList) {
        RenderBox child = runChild.child;
        double childMainAxisMargin = flowAwareChildMainAxisMargin(child)!;
        // Add start margin of main axis when setting offset.
        childMainPosition += childMainAxisMargin;
        double? childCrossPosition;
        AlignSelf alignSelf = _getAlignSelf(child);

        String? alignment;

        switch (alignSelf) {
          case AlignSelf.flexStart:
          case AlignSelf.start:
          case AlignSelf.stretch:
            alignment = renderStyle.flexWrap == FlexWrap.wrapReverse ? 'end' : 'start';
            break;
          case AlignSelf.flexEnd:
          case AlignSelf.end:
            alignment = renderStyle.flexWrap == FlexWrap.wrapReverse ? 'start' : 'end';
            break;
          case AlignSelf.center:
            alignment = 'center';
            break;
          case AlignSelf.baseline:
            alignment = 'baseline';
            break;
          case AlignSelf.auto:
            switch (renderStyle.effectiveAlignItems) {
              case AlignItems.flexStart:
              case AlignItems.start:
              case AlignItems.stretch:
                alignment = renderStyle.flexWrap == FlexWrap.wrapReverse ? 'end' : 'start';
                break;
              case AlignItems.flexEnd:
              case AlignItems.end:
                alignment = renderStyle.flexWrap == FlexWrap.wrapReverse ? 'start' : 'end';
                break;
              case AlignItems.center:
                alignment = 'center';
                break;
              case AlignItems.baseline:
                // FIXME: baseline alignment in wrap-reverse flexWrap may display different from browser in some case
                if (_isHorizontalFlexDirection) {
                  alignment = 'baseline';
                } else if (renderStyle.flexWrap == FlexWrap.wrapReverse) {
                  alignment = 'end';
                } else {
                  alignment = 'start';
                }
                break;
            }
            break;
        }

        childCrossPosition = _getChildCrossAxisOffset(
          alignment,
          child,
          childCrossPosition,
          runBaselineExtent,
          runCrossAxisExtent,
          runBetweenSpace,
          crossAxisStartPadding,
          crossAxisStartBorder,
        );

        // Calculate margin auto length according to CSS spec rules
        // https://www.w3.org/TR/css-flexbox-1/#auto-margins
        // margin auto takes up available space in the remaining space
        // between flex items and flex container.
        if (child is RenderBoxModel) {
          RenderStyle childRenderStyle = child.renderStyle;
          CSSLengthValue marginLeft = childRenderStyle.marginLeft;
          CSSLengthValue marginRight = childRenderStyle.marginRight;
          CSSLengthValue marginTop = childRenderStyle.marginTop;
          CSSLengthValue marginBottom = childRenderStyle.marginBottom;

          double horizontalRemainingSpace;
          double verticalRemainingSpace;
          // Margin auto does not work with negative remaining space.
          double mainAxisRemainingSpace = math.max(0, remainingSpace);
          double crossAxisRemainingSpace =
          math.max(0, crossAxisContentSize - _getCrossAxisExtent(child));

          if (_isHorizontalFlexDirection) {
            horizontalRemainingSpace = mainAxisRemainingSpace;
            verticalRemainingSpace = crossAxisRemainingSpace;
            if (totalFlexGrow == 0 && marginLeft.isAuto) {
              if (marginRight.isAuto) {
                childMainPosition +=
                  (horizontalRemainingSpace / mainAxisMarginAutoChildrenCount) / 2;
                betweenSpace =
                  (horizontalRemainingSpace / mainAxisMarginAutoChildrenCount) / 2;
              } else {
                childMainPosition +=
                  horizontalRemainingSpace / mainAxisMarginAutoChildrenCount;
              }
            }

            if (marginTop.isAuto) {
              if (marginBottom.isAuto) {
                childCrossPosition = childCrossPosition! + verticalRemainingSpace / 2;
              } else {
                childCrossPosition = childCrossPosition! + verticalRemainingSpace;
              }
            }
          } else {
            horizontalRemainingSpace = crossAxisRemainingSpace;
            verticalRemainingSpace = mainAxisRemainingSpace;
            if (totalFlexGrow == 0 && marginTop.isAuto) {
              if (marginBottom.isAuto) {
                childMainPosition +=
                  (verticalRemainingSpace / mainAxisMarginAutoChildrenCount) / 2;
                betweenSpace =
                  (verticalRemainingSpace / mainAxisMarginAutoChildrenCount) / 2;
              } else {
                childMainPosition +=
                  verticalRemainingSpace / mainAxisMarginAutoChildrenCount;
              }
            }

            if (marginLeft.isAuto) {
              if (marginRight.isAuto) {
                childCrossPosition = childCrossPosition! + horizontalRemainingSpace / 2;
              } else {
                childCrossPosition = childCrossPosition! + horizontalRemainingSpace;
              }
            }
          }
        }

        if (flipMainAxis) childMainPosition -= _getMainAxisExtent(child);

        double crossOffset;
        if (renderStyle.flexWrap == FlexWrap.wrapReverse) {
          crossOffset = childCrossPosition! +
            (crossAxisContentSize -
              crossAxisOffset -
              runCrossAxisExtent -
              runBetweenSpace);
        } else {
          crossOffset = childCrossPosition! + crossAxisOffset;
        }
        Offset relativeOffset = _getOffset(childMainPosition, crossOffset);

        // Apply position relative offset change.
        CSSPositionedLayout.applyRelativeOffset(relativeOffset, child);

        // Need to subtract start margin of main axis when calculating next child's start position.
        if (flipMainAxis) {
          childMainPosition -= betweenSpace + childMainAxisMargin;
        } else {
          childMainPosition +=
            _getMainAxisExtent(child) - childMainAxisMargin + betweenSpace;
        }
      }

      crossAxisOffset += runCrossAxisExtent + runBetweenSpace;
    }
  }

  // Whether need to stretch child in the cross axis according to alignment property and child cross length.
  bool needToStretchChildCrossSize(RenderBox child) {
    // Position placeholder and BR element has size of zero, so they can not be stretched.
    if (child is RenderPositionPlaceholder || child is RenderLineBreak) return false;

    AlignSelf alignSelf = _getAlignSelf(child);
    bool isChildAlignmentStretch = alignSelf != AlignSelf.auto
      ? alignSelf == AlignSelf.stretch
      : renderStyle.effectiveAlignItems == AlignItems.stretch;

    if (!isChildAlignmentStretch) return false;

    // If child length is auto in cross axis, stretch does not work.
    if (child is RenderBoxModel) {
      bool isLengthAuto = _isHorizontalFlexDirection
        ? child.renderStyle.height.isAuto
        : child.renderStyle.width.isAuto;
      return isLengthAuto;
    }
    return false;
  }

  // Whether margin auto of child is set in the main axis.
  bool isChildMainAxisMarginAutoExist(RenderBox child) {
    if (child is RenderBoxModel) {
      RenderStyle childRenderStyle = child.renderStyle;
      CSSLengthValue marginLeft = childRenderStyle.marginLeft;
      CSSLengthValue marginRight = childRenderStyle.marginRight;
      CSSLengthValue marginTop = childRenderStyle.marginTop;
      CSSLengthValue marginBottom = childRenderStyle.marginBottom;
      if (_isHorizontalFlexDirection && (marginLeft.isAuto || marginRight.isAuto) ||
        !_isHorizontalFlexDirection && (marginTop.isAuto || marginBottom.isAuto)
      ) {
        return true;
      }
    }
    return false;
  }

  // Whether margin auto of child is set in the cross axis.
  bool isChildCrossAxisMarginAutoExist(RenderBox child) {
    if (child is RenderBoxModel) {
      RenderStyle childRenderStyle = child.renderStyle;
      CSSLengthValue marginLeft = childRenderStyle.marginLeft;
      CSSLengthValue marginRight = childRenderStyle.marginRight;
      CSSLengthValue marginTop = childRenderStyle.marginTop;
      CSSLengthValue marginBottom = childRenderStyle.marginBottom;
      if (_isHorizontalFlexDirection && (marginTop.isAuto || marginBottom.isAuto) ||
        !_isHorizontalFlexDirection && (marginLeft.isAuto || marginRight.isAuto)
      ) {
        return true;
      }
    }
    return false;
  }

  // Get flex item cross axis offset by align-items/align-self.
  double? _getChildCrossAxisOffset(
    String alignment,
    RenderBox child,
    double? childCrossPosition,
    double runBaselineExtent,
    double runCrossAxisExtent,
    double runBetweenSpace,
    double crossAxisStartPadding,
    double crossAxisStartBorder,
  ) {
    // Leading between height of line box's content area and line height of line box.
    double lineBoxLeading = 0;
    double? lineBoxHeight = _getLineHeight(this);
    if (lineBoxHeight != null) {
      lineBoxLeading = lineBoxHeight - runCrossAxisExtent;
    }

    double flexLineHeight = _getFlexLineHeight(
      runCrossAxisExtent,
      runBetweenSpace,
      beforeSetSize: false
    );
    double childCrossAxisStartMargin = flowAwareChildCrossAxisMargin(child)!;
    double crossStartAddedOffset = crossAxisStartPadding +
      crossAxisStartBorder +
      childCrossAxisStartMargin;

    // Align-items and align-self have no effect if auto margin of child exists in the cross axis.
    if (isChildCrossAxisMarginAutoExist(child)) {
      return crossStartAddedOffset;
    }

    switch (alignment) {
      case 'start':
        return crossStartAddedOffset;
      case 'end':
        // Length returned by _getCrossAxisExtent includes margin, so end alignment should add start margin.
        return crossAxisStartPadding +
          crossAxisStartBorder +
          flexLineHeight -
          _getCrossAxisExtent(child) +
          childCrossAxisStartMargin;
      case 'center':
        return childCrossPosition = crossStartAddedOffset +
          (flexLineHeight - _getCrossAxisExtent(child)) / 2.0;
      case 'baseline':
        // Distance from top to baseline of child.
        double childAscent = _getChildAscent(child);
        return crossStartAddedOffset +
          lineBoxLeading / 2 +
          (runBaselineExtent - childAscent);
      default:
        return null;
    }
  }

  // Compute distance to baseline of flex layout.
  @override
  double? computeDistanceToBaseline() {
    double lineDistance = 0;
    double marginTop = renderStyle.marginTop.computedValue;
    double marginBottom = renderStyle.marginBottom.computedValue;
    bool isParentFlowLayout = parent is RenderFlowLayout;
    CSSDisplay? effectiveDisplay = renderStyle.effectiveDisplay;
    bool isDisplayInline = effectiveDisplay != CSSDisplay.block &&
        effectiveDisplay != CSSDisplay.flex;
    // Use margin bottom as baseline if layout has no children
    if (_flexLineBoxMetrics.isEmpty) {
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

    // Always use the baseline of the first child as the baseline in flex layout.
    _RunMetrics firstLineMetrics = _flexLineBoxMetrics[0];
    List<_RunChild> firstRunChildren =
        firstLineMetrics.runChildren.values.toList();
    _RunChild firstRunChild = firstRunChildren[0];
    RenderBox child = firstRunChild.child;

    double childMarginTop =
        child is RenderBoxModel ? child.renderStyle.marginTop.computedValue : 0;
    RenderLayoutParentData childParentData =
        child.parentData as RenderLayoutParentData;
    double? childBaseLineDistance = 0;
    if (child is RenderBoxModel) {
      childBaseLineDistance = child.computeDistanceToBaseline();
    } else if (child is RenderTextBox) {
      childBaseLineDistance = child.computeDistanceToFirstLineBaseline();
    }

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
    lineDistance = (childBaseLineDistance ?? 0) + childOffsetY;
    lineDistance += marginTop;
    return lineDistance;
  }

  // Get child size through boxSize to avoid flutter error when parentUsesSize is set to false.
  Size? _getChildSize(RenderBox? child,
      {bool shouldUseIntrinsicMainSize = false}) {
    Size? childSize;
    if (child is RenderBoxModel) {
      childSize = child.boxSize;
    } else if (child is RenderPositionPlaceholder) {
      childSize = child.boxSize;
    } else if (child is RenderTextBox) {
      childSize = child.boxSize;
    }
    if (shouldUseIntrinsicMainSize) {
      double? childIntrinsicMainSize =
          _childrenIntrinsicMainSizes[child.hashCode];
      if (_isHorizontalFlexDirection) {
        childSize = Size(childIntrinsicMainSize!, childSize!.height);
      } else {
        childSize = Size(childSize!.width, childIntrinsicMainSize!);
      }
    }
    return childSize;
  }

  // Get distance from top to baseline of child including margin.
  double _getChildAscent(RenderBox child) {
    // Distance from top to baseline of child.
    double? childAscent =
        child.getDistanceToBaseline(TextBaseline.alphabetic, onlyReal: true);
    double? childMarginTop = 0;
    double? childMarginBottom = 0;
    if (child is RenderBoxModel) {
      childMarginTop = child.renderStyle.marginTop.computedValue;
      childMarginBottom = child.renderStyle.marginBottom.computedValue;
    }

    Size? childSize = _getChildSize(child);

    double baseline = parent is RenderFlowLayout
        ? childMarginTop + childSize!.height + childMarginBottom
        : childMarginTop + childSize!.height;
    // When baseline of children not found, use boundary of margin bottom as baseline.
    double extentAboveBaseline = childAscent ?? baseline;

    return extentAboveBaseline;
  }

  Offset _getOffset(double mainAxisOffset, double crossAxisOffset) {
    if (!_isHorizontalFlexDirection) {
      return Offset(crossAxisOffset, mainAxisOffset);
    } else {
      return Offset(mainAxisOffset, crossAxisOffset);
    }
  }

  // Get cross size of content size.
  double _getContentCrossSize() {
    if (_isHorizontalFlexDirection) {
      return contentSize.height;
    } else {
      return contentSize.width;
    }
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
  bool hitTestChildren(BoxHitTestResult result, {Offset? position}) {
    return defaultHitTestChildren(result, position: position);
  }

  @override
  void performPaint(PaintingContext context, Offset offset) {
    for (int i = 0; i < paintingOrder.length; i++) {
      RenderObject child = paintingOrder[i];
      // Don't paint placeholder of positioned element.
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
    properties.add(DiagnosticsProperty<FlexDirection>(
        'flexDirection', renderStyle.flexDirection));
    properties.add(DiagnosticsProperty<JustifyContent>(
        'justifyContent', renderStyle.justifyContent));
    properties.add(
        DiagnosticsProperty<AlignItems>('alignItems', renderStyle.alignItems));
    properties
        .add(DiagnosticsProperty<FlexWrap>('flexWrap', renderStyle.flexWrap));
  }

  static bool _isPlaceholderPositioned(RenderObject child) {
    if (child is RenderPositionPlaceholder) {
      RenderBoxModel realDisplayedBox = child.positioned!;
      RenderLayoutParentData parentData = realDisplayedBox.parentData as RenderLayoutParentData;
      if (parentData.isPositioned) {
        return true;
      }
    }
    return false;
  }

  static bool? _startIsTopLeft(FlexDirection direction) {
    switch (direction) {
      case FlexDirection.column:
      case FlexDirection.row:
        return true;
      case FlexDirection.rowReverse:
      case FlexDirection.columnReverse:
        return false;
    }
  }
}

// Render flex layout with self repaint boundary.
class RenderRepaintBoundaryFlexLayout extends RenderFlexLayout {
  RenderRepaintBoundaryFlexLayout({
    List<RenderBox>? children,
    required CSSRenderStyle renderStyle,
  }) : super(
    children: children,
    renderStyle: renderStyle,
  );

  @override
  bool get isRepaintBoundary => true;
}
