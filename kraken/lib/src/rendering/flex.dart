import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:kraken/module.dart';
import 'package:kraken/rendering.dart';
import 'package:kraken/dom.dart';
import 'package:kraken/css.dart';

/// Infos of each run (flex line) in flex layout
/// https://www.w3.org/TR/css-flexbox-1/#flex-lines
class _RunMetrics {
  _RunMetrics(
    this.mainAxisExtent,
    this.crossAxisExtent,
    double totalFlexGrow,
    double totalFlexShrink,
    this.baselineExtent,
    this.runChildren,
    double remainingFreeSpace,
  ) : _totalFlexGrow = totalFlexGrow,
    _totalFlexShrink = totalFlexShrink,
    _remainingFreeSpace = remainingFreeSpace;

  // Main size extent of the run
  final double mainAxisExtent;
  // Cross size extent of the run
  final double crossAxisExtent;

  // Total flex grow factor in the run
  double get totalFlexGrow => _totalFlexGrow;
  double _totalFlexGrow;
  set totalFlexGrow(double value) {
    assert(value != null);
    if (_totalFlexGrow != value) {
      _totalFlexGrow = value;
    }
  }

  // Total flex shrink factor in the run
  double get totalFlexShrink => _totalFlexShrink;
  double _totalFlexShrink;
  set totalFlexShrink(double value) {
    assert(value != null);
    if (_totalFlexShrink != value) {
      _totalFlexShrink = value;
    }
  }

  // Max extent above each flex items in the run
  final double baselineExtent;
  // All the children RenderBox of layout in the run
  final Map<int, _RunChild> runChildren;

  // Remaining free space in the run
  double get remainingFreeSpace => _remainingFreeSpace;
  double _remainingFreeSpace = 0;
  set remainingFreeSpace(double value) {
    assert(value != null);
    if (_remainingFreeSpace != value) {
      _remainingFreeSpace = value;
    }
  }
}

/// Infos about Flex item in the run
class _RunChild {
  _RunChild(
    RenderBox child,
    double originalMainSize,
    double adjustedMainSize,
    bool frozen,
  ) : _child = child,
      _originalMainSize = originalMainSize,
      _adjustedMainSize = adjustedMainSize,
      _frozen = frozen;

  /// Render object of flex item
  RenderBox get child => _child;
  RenderBox _child;
  set child(RenderBox value) {
    assert(value != null);
    if (_child != value) {
      _child = value;
    }
  }

  /// Original main size on first layout
  double get originalMainSize => _originalMainSize;
  double _originalMainSize;
  set originalMainSize(double value) {
    assert(value != null);
    if (_originalMainSize != value) {
      _originalMainSize = value;
    }
  }

  /// Adjusted main size after flexible length resolve algorithm
  double get adjustedMainSize => _adjustedMainSize;
  double _adjustedMainSize;
  set adjustedMainSize(double value) {
    assert(value != null);
    if (_adjustedMainSize != value) {
      _adjustedMainSize = value;
    }
  }

  /// Whether flex item should be frozen in flexible length resolve algorithm
  bool get frozen => _frozen;
  bool _frozen = false;
  set frozen(bool value) {
    assert(value != null);
    if (_frozen != value) {
      _frozen = value;
    }
  }
}

bool _startIsTopLeft(FlexDirection direction) {
  assert(direction != null);

  switch (direction) {
    case FlexDirection.column:
    case FlexDirection.row:
      return true;
    case FlexDirection.rowReverse:
    case FlexDirection.columnReverse:
      return false;
  }

  return null;
}

/// ## Layout algorithm
///
/// _This section describes how the framework causes [RenderFlexLayout] to position
/// its children._
///
/// Layout for a [RenderFlexLayout] proceeds in 5 steps:
///
/// 1. Layout placeholder child of positioned element(absolute/fixed) in new layer
/// 2. Layout no positioned children with no constraints, compare children width with flex container main axis extent
///    to caculate total flex lines
/// 3. Caculate horizontal constraints of each child according to availabe horizontal space in each flex line
///    and flex-grow and flex-shrink properties
/// 4. Caculate vertical constraints of each child accordint to availabe vertical space in flex container vertial
///    and align-content properties and set
/// 5. Layout children again with above cacluated constraints
/// 6. Caculate flex line leading space and between space and position children in each flex line
///
class RenderFlexLayout extends RenderLayoutBox {
  /// Creates a flex render object.
  ///
  /// By default, the flex layout is horizontal and children are aligned to the
  /// start of the main axis and the center of the cross axis.
  RenderFlexLayout({
    List<RenderBox> children,
    int targetId,
    ElementManager elementManager,
    CSSStyleDeclaration style,
  }) : super(targetId: targetId, style: style, elementManager: elementManager) {
    addAll(children);
  }

  // Set during layout if overflow occurred on the main axis.
  double _overflow;

  // Check whether any meaningful overflow is present. Values below an epsilon
  // are treated as not overflowing.
  bool get _hasOverflow => _overflow > precisionErrorTolerance;

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! RenderLayoutParentData) {
      child.parentData = RenderLayoutParentData();
    }
    if (child is RenderBoxModel) {
      child.parentData = CSSPositionedLayout.getPositionParentData(child, child.parentData);
    }
  }

  double _getIntrinsicSize({
    FlexDirection sizingDirection,
    double extent, // the extent in the direction that isn't the sizing direction
    double Function(RenderBox child, double extent) childSize, // a method to find the size in the sizing direction
  }) {
    if (renderStyle.flexDirection == sizingDirection) {
      // INTRINSIC MAIN SIZE
      // Intrinsic main size is the smallest size the flex container can take
      // while maintaining the min/max-content contributions of its flex items.
      double totalFlexGrow = 0.0;
      double inflexibleSpace = 0.0;
      double maxFlexFractionSoFar = 0.0;
      RenderBox child = firstChild;
      while (child != null) {
        final double flex = _getFlexGrow(child);
        totalFlexGrow += flex;
        if (flex > 0) {
          final double flexFraction = childSize(child, extent) / _getFlexGrow(child);
          maxFlexFractionSoFar = math.max(maxFlexFractionSoFar, flexFraction);
        } else {
          inflexibleSpace += childSize(child, extent);
        }
        final RenderLayoutParentData childParentData = child.parentData;
        child = childParentData.nextSibling;
      }
      return maxFlexFractionSoFar * totalFlexGrow + inflexibleSpace;
    } else {
      // INTRINSIC CROSS SIZE
      // Intrinsic cross size is the max of the intrinsic cross sizes of the
      // children, after the flexible children are fit into the available space,
      // with the children sized using their max intrinsic dimensions.

      // Get inflexible space using the max intrinsic dimensions of fixed children in the main direction.
      final double availableMainSpace = extent;
      double totalFlexGrow = 0;
      double inflexibleSpace = 0.0;
      double maxCrossSize = 0.0;
      RenderBox child = firstChild;
      while (child != null) {
        final double flex = _getFlexGrow(child);
        totalFlexGrow += flex;
        double mainSize;
        double crossSize;
        if (flex == 0) {
          switch (renderStyle.flexDirection) {
            case FlexDirection.rowReverse:
            case FlexDirection.row:
              mainSize = child.getMaxIntrinsicWidth(double.infinity);
              crossSize = childSize(child, mainSize);
              break;
            case FlexDirection.column:
            case FlexDirection.columnReverse:
              mainSize = child.getMaxIntrinsicHeight(double.infinity);
              crossSize = childSize(child, mainSize);
              break;
          }
          inflexibleSpace += mainSize;
          maxCrossSize = math.max(maxCrossSize, crossSize);
        }
        final RenderLayoutParentData childParentData = child.parentData;
        child = childParentData.nextSibling;
      }

      // Determine the spacePerFlex by allocating the remaining available space.
      // When you're overconstrained spacePerFlex can be negative.
      final double spacePerFlex = math.max(0.0, (availableMainSpace - inflexibleSpace) / totalFlexGrow);

      // Size remaining (flexible) items, find the maximum cross size.
      child = firstChild;
      while (child != null) {
        final double flex = _getFlexGrow(child);
        if (flex > 0) maxCrossSize = math.max(maxCrossSize, childSize(child, spacePerFlex * flex));
        final RenderLayoutParentData childParentData = child.parentData;
        child = childParentData.nextSibling;
      }

      return maxCrossSize;
    }
  }

  /// Get start/end padding in the main axis according to flex direction
  double flowAwareMainAxisPadding({bool isEnd = false}) {
    if (CSSFlex.isHorizontalFlexDirection(renderStyle.flexDirection)) {
      return isEnd ? renderStyle.paddingRight : renderStyle.paddingLeft;
    } else {
      return isEnd ? renderStyle.paddingBottom : renderStyle.paddingTop;
    }
  }

  /// Get start/end padding in the cross axis according to flex direction
  double flowAwareCrossAxisPadding({bool isEnd = false}) {
    if (CSSFlex.isHorizontalFlexDirection(renderStyle.flexDirection)) {
      return isEnd ? renderStyle.paddingBottom : renderStyle.paddingTop;
    } else {
      return isEnd ? renderStyle.paddingRight : renderStyle.paddingLeft;
    }
  }

  /// Get start/end border in the main axis according to flex direction
  double flowAwareMainAxisBorder({bool isEnd = false}) {
    if (CSSFlex.isHorizontalFlexDirection(renderStyle.flexDirection)) {
      return isEnd ? renderStyle.borderRight : renderStyle.borderLeft;
    } else {
      return isEnd ? renderStyle.borderBottom : renderStyle.borderTop;
    }
  }

  /// Get start/end border in the cross axis according to flex direction
  double flowAwareCrossAxisBorder({bool isEnd = false}) {
    if (CSSFlex.isHorizontalFlexDirection(renderStyle.flexDirection)) {
      return isEnd ? renderStyle.borderBottom : renderStyle.borderTop;
    } else {
      return isEnd ? renderStyle.borderRight : renderStyle.borderLeft;
    }
  }

  /// Get start/end margin of child in the main axis according to flex direction
  double flowAwareChildMainAxisMargin(RenderBox child, {bool isEnd = false}) {
    RenderBoxModel childRenderBoxModel;
    if (child is RenderBoxModel) {
      childRenderBoxModel = _getChildRenderBoxModel(child);
    }
    if (childRenderBoxModel == null) {
      return 0;
    }

    if (CSSFlex.isHorizontalFlexDirection(renderStyle.flexDirection)) {
      return isEnd ? childRenderBoxModel.renderStyle.marginRight : childRenderBoxModel.renderStyle.marginLeft;
    } else {
      return isEnd ? childRenderBoxModel.renderStyle.marginBottom : childRenderBoxModel.renderStyle.marginTop;
    }
  }

  /// Get start/end margin of child in the cross axis according to flex direction
  double flowAwareChildCrossAxisMargin(RenderBox child, {bool isEnd = false}) {
    RenderBoxModel childRenderBoxModel;
    if (child is RenderBoxModel) {
      childRenderBoxModel = _getChildRenderBoxModel(child);
    }
    if (childRenderBoxModel == null) {
      return 0;
    }
    if (CSSFlex.isHorizontalFlexDirection(renderStyle.flexDirection)) {
      return isEnd ? childRenderBoxModel.renderStyle.marginBottom : childRenderBoxModel.renderStyle.marginTop;
    } else {
      return isEnd ? childRenderBoxModel.renderStyle.marginRight : childRenderBoxModel.renderStyle.marginLeft;
    }
  }

  RenderBoxModel _getChildRenderBoxModel(RenderBoxModel child) {
    Element childEl = elementManager.getEventTargetByTargetId<Element>(child.targetId);
    RenderBoxModel renderBoxModel = childEl.renderBoxModel;
    return renderBoxModel;
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    return _getIntrinsicSize(
      sizingDirection: FlexDirection.row,
      extent: height,
      childSize: (RenderBox child, double extent) => child.getMinIntrinsicWidth(extent),
    );
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    return _getIntrinsicSize(
      sizingDirection: FlexDirection.row,
      extent: height,
      childSize: (RenderBox child, double extent) => child.getMaxIntrinsicWidth(extent),
    );
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    return _getIntrinsicSize(
      sizingDirection: FlexDirection.column,
      extent: width,
      childSize: (RenderBox child, double extent) => child.getMinIntrinsicHeight(extent),
    );
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    return _getIntrinsicSize(
      sizingDirection: FlexDirection.column,
      extent: width,
      childSize: (RenderBox child, double extent) => child.getMaxIntrinsicHeight(extent),
    );
  }

  double _getFlexGrow(RenderBox child) {
    // Flex shrink has no effect on placeholder of positioned element
    if (child is RenderPositionHolder) {
      return 0;
    }
    return child is RenderBoxModel ? child.renderStyle.flexGrow : 0.0;
  }

  double _getFlexShrink(RenderBox child) {
    // Flex shrink has no effect on placeholder of positioned element
    if (child is RenderPositionHolder) {
      return 0;
    }
    return child is RenderBoxModel ? child.renderStyle.flexShrink : 0.0;
  }

  double _getFlexBasis(RenderBox child) {
    // Flex shrink has no effect on placeholder of positioned element
    if (child is RenderPositionHolder) {
      return null;
    }
    return child is RenderBoxModel ? child.renderStyle.flexBasis : null;
  }

  AlignSelf _getAlignSelf(RenderBox child) {
    // Flex shrink has no effect on placeholder of positioned element
    if (child is RenderPositionHolder) {
      return AlignSelf.auto;
    }
    return child is RenderBoxModel ? child.renderStyle.alignSelf : AlignSelf.auto;
  }

  double _getMaxMainAxisSize(RenderBox child) {
    double maxMainSize;
    if (child is RenderBoxModel) {
      maxMainSize = CSSFlex.isHorizontalFlexDirection(renderStyle.flexDirection) ?
        child.renderStyle.maxWidth : child.renderStyle.maxHeight;
    }
    return maxMainSize ?? double.infinity;
  }

  /// Calculate automatic minimum size of flex item
  /// Refer to https://www.w3.org/TR/css-flexbox-1/#min-size-auto for detail rules
  double _getMinMainAxisSize(RenderBoxModel child) {
    double minMainSize;

    double contentSize = 0;
    // Min width of flex item if min-width is not specified use auto min width instead
    double minWidth = 0;
    // Min height of flex item if min-height is not specified use auto min height instead
    double minHeight = 0;

    RenderStyle childRenderStyle = child.renderStyle;

    if (child is RenderBoxModel) {
      minWidth = childRenderStyle.minWidth != null ? childRenderStyle.minWidth : child.autoMinWidth;
      minHeight = childRenderStyle.minHeight != null ? childRenderStyle.minHeight : child.autoMinHeight;
    } else if (child is RenderTextBox) {
      minWidth =  child.autoMinWidth;
      minHeight =  child.autoMinHeight;
    }
    contentSize = CSSFlex.isHorizontalFlexDirection(renderStyle.flexDirection) ?
      minWidth : minHeight;

    if (child is RenderIntrinsic && child.intrinsicRatio != null &&
      CSSFlex.isHorizontalFlexDirection(renderStyle.flexDirection) && childRenderStyle.width == null
    ) {
      double transferredSize = childRenderStyle.height != null ?
       childRenderStyle.height * child.intrinsicRatio : child.intrinsicWidth;
      minMainSize = math.min(contentSize, transferredSize);
    } else if (child is RenderIntrinsic && child.intrinsicRatio != null &&
      CSSFlex.isVerticalFlexDirection(renderStyle.flexDirection) && childRenderStyle.height == null
    ) {
      double transferredSize = childRenderStyle.width != null ?
        childRenderStyle.width / child.intrinsicRatio : child.intrinsicHeight;
      minMainSize = math.min(contentSize, transferredSize);
    } else if (child is RenderBoxModel) {
      double specifiedMainSize = CSSFlex.isHorizontalFlexDirection(renderStyle.flexDirection) ?
        RenderBoxModel.getContentWidth(child) : RenderBoxModel.getContentHeight(child);
      minMainSize = specifiedMainSize != null ?
        math.min(contentSize, specifiedMainSize) : contentSize;
    } else if (child is RenderTextBox) {
      minMainSize = contentSize;
    }

    return minMainSize;
  }

  double _getShrinkConstraints(RenderBox child, Map<int, _RunChild> runChildren, double remainingFreeSpace) {
    double totalWeightedFlexShrink = 0;
    runChildren.forEach((int targetId, _RunChild runChild) {
      double childOriginalMainSize = runChild.originalMainSize;
      RenderBox child = runChild.child;
      if (!runChild.frozen) {
        double childFlexShrink = _getFlexShrink(child);
        totalWeightedFlexShrink += childOriginalMainSize * childFlexShrink;
      }
    });

    int childNodeId;
    if (child is RenderTextBox) {
      childNodeId = child.targetId;
    } else if (child is RenderBoxModel) {
      childNodeId = child.targetId;
    }

    _RunChild current = runChildren[childNodeId];
    double currentOriginalMainSize = current.originalMainSize;
    double currentFlexShrink = _getFlexShrink(current.child);
    double currentExtent = currentFlexShrink * currentOriginalMainSize;
    double minusConstraints = (currentExtent / totalWeightedFlexShrink) * remainingFreeSpace;

    return minusConstraints;
  }

  BoxSizeType _getChildWidthSizeType(RenderBox child) {
    if (child is RenderTextBox) {
      return child.widthSizeType;
    } else if (child is RenderBoxModel) {
      return child.widthSizeType;
    }
    return null;
  }

  BoxSizeType _getChildHeightSizeType(RenderBox child) {
    if (child is RenderTextBox) {
      return child.heightSizeType;
    } else if (child is RenderBoxModel) {
      return child.heightSizeType;
    }
    return null;
  }

  bool _isCrossAxisDefinedSize(RenderBox child) {
    BoxSizeType widthSizeType = _getChildWidthSizeType(child);
    BoxSizeType heightSizeType = _getChildHeightSizeType(child);

    if (style != null) {
      if (CSSFlex.isHorizontalFlexDirection(renderStyle.flexDirection)) {
        return heightSizeType != null && heightSizeType == BoxSizeType.specified;
      } else {
        return widthSizeType != null && widthSizeType == BoxSizeType.specified;
      }
    }

    return false;
  }

  double _getCrossAxisExtent(RenderBox child) {
    double marginHorizontal = 0;
    double marginVertical = 0;

    RenderBoxModel childRenderBoxModel;
    if (child is RenderBoxModel) {
      childRenderBoxModel = _getChildRenderBoxModel(child);
    } else if (child is RenderPositionHolder) {
      // Position placeholder of flex item need to layout as its original renderBox
      // so it needs to add margin to its extent
      childRenderBoxModel = child.realDisplayedBox;
    }

    if (childRenderBoxModel != null) {
      marginHorizontal = childRenderBoxModel.renderStyle.marginLeft + childRenderBoxModel.renderStyle.marginRight;
      marginVertical = childRenderBoxModel.renderStyle.marginTop + childRenderBoxModel.renderStyle.marginBottom;
    }

    Size childSize = _getChildSize(child);
    if (CSSFlex.isHorizontalFlexDirection(renderStyle.flexDirection)) {
      return childSize.height + marginVertical;
    } else {
      return childSize.width + marginHorizontal;
    }
  }

  bool _isChildMainAxisClip(RenderBoxModel renderBoxModel) {
    if (renderBoxModel is RenderIntrinsic) {
      return false;
    }
    if (CSSFlex.isHorizontalFlexDirection(renderStyle.flexDirection)) {
      return renderBoxModel.clipX;
    } else {
      return renderBoxModel.clipY;
    }
  }

  double _getMainAxisExtent(RenderBox child) {
    double marginHorizontal = 0;
    double marginVertical = 0;

    RenderBoxModel childRenderBoxModel;
    if (child is RenderBoxModel) {
      childRenderBoxModel = _getChildRenderBoxModel(child);
    } else if (child is RenderPositionHolder) {
      // Position placeholder of flex item need to layout as its original renderBox
      // so it needs to add margin to its extent
      childRenderBoxModel = child.realDisplayedBox;
    }

    if (childRenderBoxModel != null) {
      marginHorizontal = childRenderBoxModel.renderStyle.marginLeft + childRenderBoxModel.renderStyle.marginRight;
      marginVertical = childRenderBoxModel.renderStyle.marginTop + childRenderBoxModel.renderStyle.marginBottom;
    }

    double baseSize = _getMainSize(child);
    if (CSSFlex.isHorizontalFlexDirection(renderStyle.flexDirection)) {
      return baseSize + marginHorizontal;
    } else {
      return baseSize + marginVertical;
    }
  }

  /// Get constraints of flex item in the main axis
  BoxConstraints _getBaseConstraints(RenderBox child, bool needsRelayout) {
    double minWidth = 0;
    double maxWidth = double.infinity;
    double minHeight = 0;
    double maxHeight = double.infinity;

    /// Use old size as base size constraints if exists except replaced element
    /// cause its content size may differ from its initial size after content loaded
    if (child.hasSize && child is !RenderIntrinsic && child is RenderBoxModel) {
      double childOriginalWidth = child.size.width;
      double childOriginalHeight = child.size.height;
      return CSSFlex.isHorizontalFlexDirection(renderStyle.flexDirection) ?
        BoxConstraints.tightFor(width: childOriginalWidth) :
        BoxConstraints.tightFor(height: childOriginalHeight);
    }

    if (child is RenderBoxModel) {
      RenderStyle childRenderStyle = child.renderStyle;
      double flexBasis = _getFlexBasis(child);
      double baseSize;
      // @FIXME when flex-basis is smaller than content width, it will not take effects
      if (flexBasis != null) {
        baseSize = flexBasis ?? 0;
      }
      if (CSSFlex.isHorizontalFlexDirection(renderStyle.flexDirection)) {
        minWidth = childRenderStyle.minWidth != null ? childRenderStyle.minWidth : 0;
        maxWidth = childRenderStyle.maxWidth != null ? childRenderStyle.maxWidth : double.infinity;

        if (flexBasis == null) {
          baseSize = childRenderStyle.width;
        }
        if (baseSize != null) {
          if (childRenderStyle.minWidth != null && baseSize < childRenderStyle.minWidth) {
            baseSize = childRenderStyle.minWidth;
          } else if (childRenderStyle.maxWidth != null && baseSize > childRenderStyle.maxWidth) {
            baseSize = childRenderStyle.maxWidth;
          }
          minWidth = maxWidth = baseSize;
        }
      } else {
        minHeight = childRenderStyle.minHeight != null ? childRenderStyle.minHeight : 0;
        maxHeight = childRenderStyle.maxHeight != null ? childRenderStyle.maxHeight : double.infinity;

        if (flexBasis == null) {
          baseSize = childRenderStyle.height;
        }
        if (baseSize != null) {
          if (childRenderStyle.minHeight != null && baseSize < childRenderStyle.minHeight) {
            baseSize = childRenderStyle.minHeight;
          } else if (childRenderStyle.maxHeight != null && baseSize > childRenderStyle.maxHeight) {
            baseSize = childRenderStyle.maxHeight;
          }
          minHeight = maxHeight = baseSize;
        }
      }
    }

    if (CSSFlex.isHorizontalFlexDirection(renderStyle.flexDirection)) {
      return BoxConstraints(
        minWidth: minWidth,
        maxWidth: maxWidth,
      );
    } else {
      return BoxConstraints(
        minHeight: minHeight,
        maxHeight: maxHeight,
      );
    }
  }

  double _getBaseSize(RenderObject child) {
    // set default value
    double baseSize;
    if (child is RenderTextBox) {
      return baseSize;
    } else if (child is RenderBoxModel) {
      double flexBasis = _getFlexBasis(child);
      RenderStyle childRenderStyle = child.renderStyle;

      if (CSSFlex.isHorizontalFlexDirection(renderStyle.flexDirection)) {
        String width = child.style[WIDTH];
        if (flexBasis == null) {
          if (width != null) {
            baseSize = childRenderStyle.width ?? 0;
          }
        } else {
          baseSize = childRenderStyle.flexBasis ?? 0;
        }
      } else {
        String height = child.style[HEIGHT];
        if (flexBasis == null) {
          if (height != '') {
            baseSize = childRenderStyle.height ?? 0;
          }
        } else {
          baseSize = childRenderStyle.flexBasis ?? 0;
        }
      }
    }
    return baseSize;
  }

  double _getMainSize(RenderBox child) {
    Size childSize = _getChildSize(child);
    if (CSSFlex.isHorizontalFlexDirection(renderStyle.flexDirection)) {
      return childSize.width;
    } else {
      return childSize.height;
    }
  }

  @override
  void performLayout() {
    if (kProfileMode) {
      childLayoutDuration = 0;
      PerformanceTiming.instance(elementManager.contextId).mark(PERF_FLEX_LAYOUT_START, uniqueId: targetId);
    }

    if (display == CSSDisplay.none) {
      size = constraints.smallest;
      if (kProfileMode) {
        PerformanceTiming.instance(elementManager.contextId).mark(PERF_FLEX_LAYOUT_END, uniqueId: targetId);
      }
      return;
    }

    beforeLayout();

    RenderBox child = firstChild;
    // Layout positioned element
    while (child != null) {
      final RenderLayoutParentData childParentData = child.parentData;
      // Layout placeholder of positioned element(absolute/fixed) in new layer
      if (child is RenderBoxModel && childParentData.isPositioned) {
        CSSPositionedLayout.layoutPositionedChild(this, child);
      } else if (child is RenderPositionHolder && isPlaceholderPositioned(child)) {
        _layoutChildren(child);
      }

      child = childParentData.nextSibling;
    }
    // Layout non positioned element and its placeholder
    _layoutChildren(null);

    // Set offset of positioned element
    child = firstChild;
    while (child != null) {
      final RenderLayoutParentData childParentData = child.parentData;

      if (child is RenderBoxModel && childParentData.isPositioned) {
        CSSPositionedLayout.applyPositionedChildOffset(this, child);

        setMaximumScrollableSizeForPositionedChild(childParentData, child);
      }
      child = childParentData.nextSibling;
    }

    _relayoutPositionedChildren();

    didLayout();

    if (kProfileMode) {
      DateTime flexLayoutEndTime = DateTime.now();
      int amendEndTime = flexLayoutEndTime.microsecondsSinceEpoch - childLayoutDuration;
      PerformanceTiming.instance(elementManager.contextId).mark(PERF_FLEX_LAYOUT_END, uniqueId: targetId, startTime: amendEndTime);
    }
  }

  /// Relayout positioned child if percentage size exists
  void _relayoutPositionedChildren() {
    RenderBox child = firstChild;
    while (child != null) {
      final RenderLayoutParentData childParentData = child.parentData;

      if (child is RenderBoxModel && childParentData.isPositioned) {
        bool percentageFound = child.renderStyle.resolvePercentageSize();
        /// Relayout after percentage size is resolved
        if (percentageFound) {
          CSSPositionedLayout.layoutPositionedChild(this, child, needsRelayout: true);
          CSSPositionedLayout.applyPositionedChildOffset(this, child);
          setMaximumScrollableSizeForPositionedChild(childParentData, child);
        }
      }
      child = childParentData.nextSibling;
    }
  }

  bool _isChildDisplayNone(RenderObject child) {
    CSSStyleDeclaration style;
    if (child is RenderTextBox) {
      style = child.style;
    } else if (child is RenderBoxModel) {
      style = child.style;
    }

    if (style == null) return false;

    return style[DISPLAY] == NONE;
  }

  bool isPlaceholderPositioned(RenderObject child) {
    if (child is RenderPositionHolder) {
      RenderBoxModel realDisplayedBox = child.realDisplayedBox;
      RenderLayoutParentData parentData = realDisplayedBox.parentData;
      if (parentData.isPositioned) {
        return true;
      }
    }
    return false;
  }

  /// There are 4 stages when layouting children
  /// 1. Layout children in flow order to calculate flex lines according to its constaints and flex-wrap property
  /// 2. Relayout children according to flex-grow and flex-shrink factor
  /// 3. Set flex container size according to children size
  /// 4. Align children according to justify-content, align-items and align-self properties
  void _layoutChildren(RenderPositionHolder placeholderChild, {bool needsRelayout = false}) {
    final double contentWidth = RenderBoxModel.getContentWidth(this);
    final double contentHeight = RenderBoxModel.getContentHeight(this);

    CSSDisplay realDisplay = CSSSizing.getElementRealDisplayValue(targetId, elementManager);

    double width = renderStyle.width;
    double height = renderStyle.height;
    double minWidth = renderStyle.minWidth;
    double minHeight = renderStyle.minHeight;
    double maxWidth = renderStyle.maxWidth;
    double maxHeight = renderStyle.maxHeight;

    /// If no child exists, stop layout.
    if (childCount == 0) {
      double constraintWidth = contentWidth ?? 0;
      double constraintHeight = contentHeight ?? 0;

      bool isInline = realDisplay == CSSDisplay.inline;
      bool isInlineFlex = realDisplay == CSSDisplay.inlineFlex;

      if (!isInline) {
        // Base width when width no exists, inline-flex has width of 0
        double baseWidth = isInlineFlex ? 0 : constraintWidth;
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
    assert(contentConstraints != null);

    // Metrics of each flex line
    final List<_RunMetrics> runMetrics = <_RunMetrics>[];
    // Max size of scrollable area
    Map<int, double> maxScrollableWidthMap = Map();
    Map<int, double> maxScrollableHeightMap = Map();
    // Flex container size in main and cross direction
    Map<String, double> containerSizeMap = {
      'main': 0.0,
      'cross': 0.0,
    };

    /// Stage 1: Layout children in flow order to calculate flex lines
    _layoutByFlexLine(
      runMetrics,
      placeholderChild,
      containerSizeMap,
      contentWidth,
      contentHeight,
      maxScrollableWidthMap,
      maxScrollableHeightMap,
      needsRelayout,
    );

    /// If no non positioned child exists, stop layout
    if (runMetrics.length == 0) {
      Size preferredSize = Size(
        contentWidth ?? 0,
        contentHeight ?? 0,
      );
      setMaxScrollableSize(preferredSize.width, preferredSize.height);
      size = getBoxSize(preferredSize);
      return;
    }

    double containerCrossAxisExtent = 0.0;

    bool isVerticalDirection = CSSFlex.isVerticalFlexDirection(renderStyle.flexDirection);
    if (isVerticalDirection) {
      containerCrossAxisExtent = contentWidth ?? 0;
    } else {
      containerCrossAxisExtent = contentHeight ?? 0;
    }

    /// Calculate leading and between space between flex lines
    final double crossAxisFreeSpace = containerCrossAxisExtent - containerSizeMap['cross'];
    final int runCount = runMetrics.length;
    double runLeadingSpace = 0.0;
    double runBetweenSpace = 0.0;
    /// Align-content only works in when flex-wrap is no nowrap
    if (renderStyle.flexWrap == FlexWrap.wrap || renderStyle.flexWrap == FlexWrap.wrapReverse) {
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
            runBetweenSpace = runCount > 1 ? crossAxisFreeSpace / (runCount - 1) : 0.0;
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

    /// Stage 2: Layout flex item second time based on flex factor and actual size
    _relayoutByFlexFactor(
      runMetrics,
      runBetweenSpace,
      placeholderChild,
      contentWidth,
      contentHeight,
      containerSizeMap,
      maxScrollableWidthMap,
      maxScrollableHeightMap,
    );

    /// Stage 3: Set flex container size according to children size
    _setContainerSize(
      runMetrics,
      containerSizeMap,
      contentWidth,
      contentHeight,
      maxScrollableWidthMap,
      maxScrollableHeightMap,
    );

    /// Stage 4: Set children offset based on flex alignment properties
    _alignChildren(
      runMetrics,
      runBetweenSpace,
      runLeadingSpace,
      placeholderChild,
      containerSizeMap,
      maxScrollableWidthMap,
      maxScrollableHeightMap,
    );

    /// Resolve percentage size of child after parent size is calculated
    bool percentageFound = !needsRelayout ? _resolveChildPercentageSize(placeholderChild) : false;
    /// Relayout after percentage size is resolved
    if (percentageFound) {
      _layoutChildren(placeholderChild, needsRelayout: true);
    }
  }

  /// Resolve all percentage size of child based on size its containing block
  bool _resolveChildPercentageSize(
    RenderPositionHolder placeholderChild,
  ) {
    bool percentageFound = false;
    RenderBox child = firstChild;
    while (child != null) {
      final RenderLayoutParentData childParentData = child.parentData;
      // Exclude positioned placeholder renderObject when layout non placeholder object
      // and positioned renderObject
      if (placeholderChild == null && (isPlaceholderPositioned(child) || childParentData.isPositioned)) {
        child = childParentData.nextSibling;
        continue;
      }
      if (child is RenderBoxModel) {
        percentageFound = child.renderStyle.resolvePercentageSize();
      }
      child = childParentData.nextSibling;
    }
    return percentageFound;
  }

  /// 1. Layout children in flow order to calculate flex lines according to its constaints and flex-wrap property
  void _layoutByFlexLine(
    List<_RunMetrics> runMetrics,
    RenderPositionHolder placeholderChild,
    Map<String, double> containerSizeMap,
    double contentWidth,
    double contentHeight,
    Map<int, double> maxScrollableWidthMap,
    Map<int, double> maxScrollableHeightMap,
    bool needsRelayout,
  ) {
    double mainAxisExtent = 0.0;
    double crossAxisExtent = 0.0;
    double runMainAxisExtent = 0.0;
    double runCrossAxisExtent = 0.0;

    // Determine used flex factor, size inflexible items, calculate free space.
    double totalFlexGrow = 0;
    double totalFlexShrink = 0;

    double maxSizeAboveBaseline = 0;
    double maxSizeBelowBaseline = 0;

    // Max length of each flex line
    double flexLineLimit = 0.0;

    bool isAxisHorizontalDirection = CSSFlex.isHorizontalFlexDirection(renderStyle.flexDirection);
    if (isAxisHorizontalDirection) {
      double maxConstraintWidth = RenderBoxModel.getMaxConstraintWidth(this);
      flexLineLimit = contentWidth != null ? contentWidth : maxConstraintWidth;
    } else {
      // Children in vertical direction should not wrap if height no exists
      double maxContentHeight = double.infinity;
      flexLineLimit = contentHeight != null ? contentHeight : maxContentHeight;
    }

    RenderBox child = placeholderChild ?? firstChild;

    // Infos about each flex item in each flex line
    Map<int, _RunChild> runChildren = {};

    while (child != null) {
      final RenderLayoutParentData childParentData = child.parentData;
      // Exclude positioned placeholder renderObject when layout non placeholder object
      // and positioned renderObject
      if (placeholderChild == null && (isPlaceholderPositioned(child) || childParentData.isPositioned)) {
        child = childParentData.nextSibling;
        continue;
      }

      double baseSize = _getBaseSize(child);
      BoxConstraints innerConstraints;

      int childNodeId;
      if (child is RenderTextBox) {
        childNodeId = child.targetId;
      } else if (child is RenderBoxModel) {
        childNodeId = child.targetId;
      }

      CSSStyleDeclaration childStyle = _getChildStyle(child);
      BoxSizeType heightSizeType = _getChildHeightSizeType(child);
      BoxConstraints baseConstraints = _getBaseConstraints(child, needsRelayout);

      if (child is RenderPositionHolder) {
        RenderBoxModel realDisplayedBox = child.realDisplayedBox;
        // Flutter only allow access size of direct children, so cannot use realDisplayedBox.size
        Size realDisplayedBoxSize = realDisplayedBox.getBoxSize(realDisplayedBox.contentSize);
        double realDisplayedBoxWidth = realDisplayedBoxSize.width;
        double realDisplayedBoxHeight = realDisplayedBoxSize.height;
        innerConstraints = BoxConstraints(
          minWidth: realDisplayedBoxWidth,
          maxWidth: realDisplayedBoxWidth,
          minHeight: realDisplayedBoxHeight,
          maxHeight: realDisplayedBoxHeight,
        );
      } else if (CSSFlex.isHorizontalFlexDirection(renderStyle.flexDirection)) {
        double maxCrossAxisSize;
        // Calculate max height constraints
        if (heightSizeType == BoxSizeType.specified && child is RenderBoxModel && childStyle[HEIGHT] != '') {
          maxCrossAxisSize = child.renderStyle.height;
        } else {
          // Child in flex line expand automatic when height is not specified
          if (renderStyle.flexWrap == FlexWrap.wrap || renderStyle.flexWrap == FlexWrap.wrapReverse) {
            maxCrossAxisSize = double.infinity;
          } else if (child is RenderTextBox) {
            maxCrossAxisSize = double.infinity;
          } else {
            // Should substract margin when layout child
            double marginVertical = 0;
            if (child is RenderBoxModel) {
              RenderBoxModel childRenderBoxModel = _getChildRenderBoxModel(child);
              marginVertical = childRenderBoxModel.renderStyle.marginTop + childRenderBoxModel.renderStyle.marginBottom;
            }
            maxCrossAxisSize = contentHeight != null ? contentHeight - marginVertical : double.infinity;
          }
        }

        innerConstraints = BoxConstraints(
          minWidth: baseConstraints.minWidth,
          maxWidth: baseConstraints.maxWidth,
          maxHeight: maxCrossAxisSize,
        );
      } else {
        innerConstraints = BoxConstraints(
          minHeight: baseSize != null ? baseSize : 0
        );
      }

      BoxConstraints childConstraints = deflateOverflowConstraints(innerConstraints);

      // Whether child need to layout
      bool isChildNeedsLayout = true;
      if (child is RenderBoxModel && child.hasSize) {
        double childContentWidth = RenderBoxModel.getContentWidth(child);
        double childContentHeight = RenderBoxModel.getContentHeight(child);
        // Always layout child when parent is not laid out yet or child is marked as needsLayout
        if (!hasSize || child.needsLayout || needsRelayout) {
          isChildNeedsLayout = true;
        } else {
          Size childOldSize = _getChildSize(child);
          // Need to layout child when width and height of child are both specified and differ from its previous size
          isChildNeedsLayout = childContentWidth != null && childContentHeight != null &&
            (childOldSize.width != childContentWidth ||
              childOldSize.height != childContentHeight);
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

      Size childSize = _getChildSize(child);
      // update max scrollable size
      if (child is RenderBoxModel) {
        maxScrollableWidthMap[child.targetId] = math.max(child.maxScrollableSize.width, childSize.width);
        maxScrollableHeightMap[child.targetId] = math.max(child.maxScrollableSize.height, childSize.height);
      }

      bool isExceedFlexLineLimit = runMainAxisExtent + childMainAxisExtent > flexLineLimit;

      // calculate flex line
      if ((renderStyle.flexWrap == FlexWrap.wrap || renderStyle.flexWrap == FlexWrap.wrapReverse) &&
        runChildren.length > 0 && isExceedFlexLineLimit) {

        mainAxisExtent = math.max(mainAxisExtent, runMainAxisExtent);
        crossAxisExtent += runCrossAxisExtent;

        runMetrics.add(_RunMetrics(
          runMainAxisExtent,
          runCrossAxisExtent,
          totalFlexGrow,
          totalFlexShrink,
          maxSizeAboveBaseline,
          runChildren,
          0
        ));
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

      /// Calculate baseline extent of layout box
      AlignSelf alignSelf = _getAlignSelf(child);

      // Vertical align is only valid for inline box
      // Baseline alignment in column direction behave the same as flex-start
      if (CSSFlex.isHorizontalFlexDirection(renderStyle.flexDirection) &&
        (alignSelf == AlignSelf.baseline || renderStyle.alignItems == AlignItems.baseline)) {
        // Distance from top to baseline of child
        double childAscent = _getChildAscent(child);
        double lineHeight = _getLineHeight(child);

        Size childSize = _getChildSize(child);
        // Leading space between content box and virtual box of child
        double childLeading = 0;
        if (lineHeight != null) {
          childLeading = lineHeight - childSize.height;
        }

        double childMarginTop = 0;
        double childMarginBottom = 0;
        if (child is RenderBoxModel) {
          RenderBoxModel childRenderBoxModel = _getChildRenderBoxModel(child);
          childMarginTop = childRenderBoxModel.renderStyle.marginTop;
          childMarginBottom = childRenderBoxModel.renderStyle.marginBottom;
        }
        maxSizeAboveBaseline = math.max(
          childAscent + childLeading / 2,
          maxSizeAboveBaseline,
        );
        maxSizeBelowBaseline = math.max(
          childMarginTop + childMarginBottom + childSize.height - childAscent + childLeading / 2,
          maxSizeBelowBaseline,
        );
        runCrossAxisExtent = maxSizeAboveBaseline + maxSizeBelowBaseline;
      } else {
        runCrossAxisExtent = math.max(runCrossAxisExtent, childCrossAxisExtent);
      }

      runChildren[childNodeId] = _RunChild(
        child,
        _getMainSize(child),
        0,
        false,
      );

      childParentData.runIndex = runMetrics.length;

      assert(child.parentData == childParentData);

      final double flexGrow = _getFlexGrow(child);
      final double flexShrink = _getFlexShrink(child);
      if (flexGrow > 0) {
        totalFlexGrow += flexGrow;
      }
      if (flexShrink > 0) {
        totalFlexShrink += flexShrink;
      }
      // Only layout placeholder renderObject child
      child = placeholderChild == null ? childParentData.nextSibling : null;
    }

    if (runChildren.length > 0) {
      mainAxisExtent = math.max(mainAxisExtent, runMainAxisExtent);
      crossAxisExtent += runCrossAxisExtent;
      runMetrics.add(_RunMetrics(
        runMainAxisExtent,
        runCrossAxisExtent,
        totalFlexGrow,
        totalFlexShrink,
        maxSizeAboveBaseline,
        runChildren,
        0
      ));

      containerSizeMap['cross'] = crossAxisExtent;
    }
  }

  /// Resolve flex item length if flex-grow or flex-shrink exists
  /// https://www.w3.org/TR/css-flexbox-1/#resolve-flexible-lengths
  bool _resolveFlexibleLengths(
    _RunMetrics runMetric,
    double initialFreeSpace,
  ) {
    Map<int, _RunChild> runChildren = runMetric.runChildren;
    double totalFlexGrow = runMetric.totalFlexGrow;
    double totalFlexShrink = runMetric.totalFlexShrink;
    bool isFlexGrow = initialFreeSpace >= 0 && totalFlexGrow > 0;
    bool isFlexShrink = initialFreeSpace < 0 && totalFlexShrink > 0;

    double sumFlexFactors = isFlexGrow ? totalFlexGrow : totalFlexShrink;
    /// If the sum of the unfrozen flex items’ flex factors is less than one,
    /// multiply the initial free space by this sum as remaining free space
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

    /// Loop flex item to find min/max violations
    runChildren.forEach((int index, _RunChild runChild) {
      if (runChild.frozen) {
        return;
      }
      RenderBox child = runChild.child;
      final double mainSize = _getMainSize(child);

      double computedSize = mainSize; /// Computed size by flex factor
      double adjustedSize = mainSize; /// Adjusted size after min and max size clamp
      double flexGrow = _getFlexGrow(child);
      double flexShrink = _getFlexShrink(child);

      int childNodeId;
      if (child is RenderTextBox) {
        childNodeId = child.targetId;
      } else if (child is RenderBoxModel) {
        childNodeId = child.targetId;
      }

      double remainingFreeSpace = runMetric.remainingFreeSpace;
      if (isFlexGrow && flexGrow != null && flexGrow > 0) {
        final double spacePerFlex = totalFlexGrow > 0 ? (remainingFreeSpace / totalFlexGrow) : double.nan;
        final double flexGrow = _getFlexGrow(child);
        computedSize = mainSize + spacePerFlex * flexGrow;
      } else if (isFlexShrink && flexShrink != null && flexShrink > 0) {
        _RunChild current = runChildren[childNodeId];
        /// If child's mainAxis have clips, it will create a new format context in it's children's.
        /// so we do't need to care about child's size.
        if (child is RenderBoxModel && _isChildMainAxisClip(child)) {
          computedSize = current.originalMainSize + remainingFreeSpace;
        } else {
          double shrinkValue = _getShrinkConstraints(child, runChildren, remainingFreeSpace);
          computedSize = current.originalMainSize + shrinkValue;
        }
      }

      adjustedSize = computedSize;
      /// Find all the violations by comparing min and max size of flex items
      if (child is RenderBoxModel && !_isChildMainAxisClip(child)) {
        double minMainAxisSize = _getMinMainAxisSize(child);
        double maxMainAxisSize = _getMaxMainAxisSize(child);
        if (computedSize < minMainAxisSize) {
          adjustedSize = minMainAxisSize;
        } else if (computedSize > maxMainAxisSize) {
          adjustedSize = maxMainAxisSize;
        }
      }

      double violation = adjustedSize - computedSize;
      /// Collect all the flex items with violations
      if (violation > 0) {
        minViolations.add(runChild);
      } else if (violation < 0) {
        maxViolations.add(runChild);
      }
      runChild.adjustedMainSize = adjustedSize;
      totalViolation += violation;
    });

    /// Freeze over-flexed items
    if (totalViolation == 0) {
      /// If total violation is zero, freeze all the flex items and exit loop
      runChildren.forEach((int index, _RunChild runChild) {
        runChild.frozen = true;
      });
    } else {
      List<_RunChild> violations = totalViolation < 0 ? maxViolations : minViolations;
      /// Find all the violations, set main size and freeze all the flex items
      for (int i = 0; i < violations.length; i++) {
        _RunChild runChild = violations[i];
        runChild.frozen = true;
        RenderBox child = runChild.child;
        runMetric.remainingFreeSpace -= runChild.adjustedMainSize - runChild.originalMainSize;

        double flexGrow = _getFlexGrow(child);
        double flexShrink = _getFlexShrink(child);

        /// If total violation is positive, freeze all the items with min violations
        if (flexGrow > 0) {
          runMetric.totalFlexGrow -= flexGrow;
        /// If total violation is negative, freeze all the items with max violations
        } else if (flexShrink > 0) {
          runMetric.totalFlexShrink -= flexShrink;
        }
      }
    }

    return totalViolation != 0;
  }

  /// Stage 2: Set size of flex item based on flex factors and min and max constraints and relayout
  ///  https://www.w3.org/TR/css-flexbox-1/#resolve-flexible-lengths
  void _relayoutByFlexFactor(
    List<_RunMetrics> runMetrics,
    double runBetweenSpace,
    RenderPositionHolder placeholderChild,
    double contentWidth,
    double contentHeight,
    Map<String, double> containerSizeMap,
    Map<int, double> maxScrollableWidthMap,
    Map<int, double> maxScrollableHeightMap,
  ) {
    RenderBox child = placeholderChild != null ? placeholderChild : firstChild;

    // Container's width specified by style or inherited from parent
    double containerWidth = 0;
    if (contentWidth != null) {
      containerWidth = contentWidth;
    } else if (contentConstraints.hasTightWidth) {
      containerWidth = contentConstraints.maxWidth;
    }

    // Container's height specified by style or inherited from parent
    double containerHeight = 0;
    if (contentHeight != null) {
      containerHeight = contentHeight;
    } else if (contentConstraints.hasTightHeight) {
      containerHeight = contentConstraints.maxHeight;
    }

    double maxMainSize = CSSFlex.isHorizontalFlexDirection(renderStyle.flexDirection) ? containerWidth : containerHeight;
    final BoxSizeType mainSizeType = maxMainSize == 0.0 ? BoxSizeType.automatic : BoxSizeType.specified;

    // Find max size of flex lines
    _RunMetrics maxMainSizeMetrics = runMetrics.reduce((_RunMetrics curr, _RunMetrics next) {
      return curr.mainAxisExtent > next.mainAxisExtent ? curr : next;
    });
    // Actual main axis size of flex items
    double maxAllocatedMainSize = maxMainSizeMetrics.mainAxisExtent;
    // Main axis size of flex container
    containerSizeMap['main'] = mainSizeType != BoxSizeType.automatic ? maxMainSize : maxAllocatedMainSize;

    for (int i = 0; i < runMetrics.length; ++i) {
      final _RunMetrics metrics = runMetrics[i];
      final double runMainAxisExtent = metrics.mainAxisExtent;
      final double runCrossAxisExtent = metrics.crossAxisExtent;
      final double totalFlexGrow = metrics.totalFlexGrow;
      final double totalFlexShrink = metrics.totalFlexShrink;
      final bool canFlex = maxMainSize < double.infinity;

      // Distribute free space to flexible children, and determine baseline.
      final double initialFreeSpace = mainSizeType == BoxSizeType.automatic ?
        0 : (canFlex ? maxMainSize : 0.0) - runMainAxisExtent;

      bool isFlexGrow = initialFreeSpace >= 0 && totalFlexGrow > 0;
      bool isFlexShrink = initialFreeSpace < 0 && totalFlexShrink > 0;

      if (isFlexGrow || isFlexShrink) {
        /// remainingFreeSpace starts out at the same value as initialFreeSpace
        /// but as we place and lay out flex items we subtract from it.
        metrics.remainingFreeSpace = initialFreeSpace;
        /// Loop flex items to resolve flexible length of flex items with flex factor
        while(_resolveFlexibleLengths(metrics, initialFreeSpace));
      }

      while (child != null) {
        final RenderLayoutParentData childParentData = child.parentData;

        AlignSelf alignSelf = _getAlignSelf(child);

        // If size exists in align-items direction, stretch not works
        bool isStretchSelfValid = false;
        if (child is RenderBoxModel) {
          isStretchSelfValid = CSSFlex.isHorizontalFlexDirection(renderStyle.flexDirection) ?
            child.renderStyle.height == null : child.renderStyle.width == null;
        }

        // Whether child should be stretched
        bool isStretchSelf = placeholderChild == null && isStretchSelfValid &&
          (alignSelf != AlignSelf.auto ? alignSelf == AlignSelf.stretch : renderStyle.alignItems == AlignItems.stretch);

        // Whether child is positioned placeholder or positioned renderObject
        bool isChildPositioned = placeholderChild == null &&
          (isPlaceholderPositioned(child) || childParentData.isPositioned);
        // Whether child cross size should be changed based on cross axis alignment change
        bool isCrossSizeChanged = false;

        if (child is RenderBoxModel && child.hasSize) {
          Size childSize = _getChildSize(child);
          double childContentWidth = RenderBoxModel.getContentWidth(child);
          double childContentHeight = RenderBoxModel.getContentHeight(child);
          double paddingLeft = child.renderStyle.paddingLeft;
          double paddingRight = child.renderStyle.paddingRight;
          double paddingTop = child.renderStyle.paddingTop;
          double paddingBottom = child.renderStyle.paddingBottom;
          double borderLeft = child.renderStyle.borderLeft;
          double borderRight = child.renderStyle.borderRight;
          double borderTop = child.renderStyle.borderTop;
          double borderBottom = child.renderStyle.borderBottom;

          double childLogicalWidth = childContentWidth != null ?
            childContentWidth + borderLeft + borderRight + paddingLeft + paddingRight :
            null;
          double childLogicalHeight = childContentHeight != null ?
            childContentHeight + borderTop + borderBottom + paddingTop + paddingBottom :
            null;

          // Cross size calculated from style which not including padding and border
          double childCrossLogicalSize = CSSFlex.isHorizontalFlexDirection(renderStyle.flexDirection) ?
            childLogicalHeight : childLogicalWidth;
          // Cross size from first layout
          double childCrossSize = CSSFlex.isHorizontalFlexDirection(renderStyle.flexDirection) ?
          childSize.height : childSize.width;

          isCrossSizeChanged = childCrossSize != childCrossLogicalSize;
        }

        // Don't need to relayout child in following cases
        // 1. child is placeholder when in layout non placeholder stage
        // 2. child is positioned renderObject, it needs to layout in its special stage
        // 3. child's size don't need to recompute if no flex-grow、flex-shrink or cross size not changed
        if (isChildPositioned || (!isFlexGrow && !isFlexShrink && !isCrossSizeChanged)) {
          child = childParentData.nextSibling;
          continue;
        }

        if (childParentData.runIndex != i) break;

        // Whether child need to layout
        bool isChildNeedsLayout = true;
        if (child is RenderBoxModel && child.hasSize) {
          double childContentWidth = RenderBoxModel.getContentWidth(child);
          double childContentHeight = RenderBoxModel.getContentHeight(child);

          // Always layout child when parent is not laid out yet or child is marked as needsLayout
          if (!hasSize || child.needsLayout) {
            isChildNeedsLayout = true;
          } else {
            double flexGrow = _getFlexGrow(child);
            double flexShrink = _getFlexShrink(child);

            // Need to relayout child when flex factor exists
            if ((isFlexGrow && flexGrow > 0) ||
              (isFlexShrink) && flexShrink > 0) {
              isChildNeedsLayout = true;
            } else if (isStretchSelf) {
              Size childOldSize = _getChildSize(child);
              // Need to layout child when width and height of child are both specified and differ from its previous size
              isChildNeedsLayout = childContentWidth != null && childContentHeight != null &&
                (childOldSize.width != childContentWidth ||
                  childOldSize.height != childContentHeight);
            }
          }
        }

        if (!isChildNeedsLayout) {
          child = childParentData.nextSibling;
          continue;
        }

        double maxChildExtent;
        double minChildExtent;

        if (_isChildDisplayNone(child)) {
          // Skip No Grow and unsized child.
          child = childParentData.nextSibling;
          continue;
        }

        Size childSize = _getChildSize(child);

        int childNodeId;
        if (child is RenderTextBox) {
          childNodeId = child.targetId;
        } else if (child is RenderBoxModel) {
          childNodeId = child.targetId;
        }

        double mainSize = isFlexGrow || isFlexShrink ?
          metrics.runChildren[childNodeId].adjustedMainSize : _getMainSize(child);
        maxChildExtent = minChildExtent = mainSize;

        BoxConstraints innerConstraints;
        if (isStretchSelf) {
          switch (renderStyle.flexDirection) {
            case FlexDirection.row:
            case FlexDirection.rowReverse:
              double minMainAxisSize = minChildExtent ?? childSize.width;
              double maxMainAxisSize = maxChildExtent ?? double.infinity;
              double minCrossAxisSize;
              double maxCrossAxisSize;

              // if child have predefined size
              if (_isCrossAxisDefinedSize(child)) {
                BoxSizeType sizeType = _getChildHeightSizeType(child);

                // child have predefined height, use previous layout height.
                if (sizeType == BoxSizeType.specified) {
                  // for empty child width, maybe it's unloaded image, set constraints range.
                  if (childSize.isEmpty) {
                    minCrossAxisSize = 0.0;
                    maxCrossAxisSize = contentConstraints.maxHeight;
                  } else {
                    minCrossAxisSize = childSize.height;
                    maxCrossAxisSize = double.infinity;
                  }
                } else {
                  // expand child's height to contentConstraints.maxHeight;
                  minCrossAxisSize = contentConstraints.maxHeight;
                  maxCrossAxisSize = contentConstraints.maxHeight;
                }
              } else if (child is! RenderTextBox) {
                String marginTop;
                String marginBottom;
                if (child is RenderBoxModel) {
                  CSSStyleDeclaration childStyle = child.style;
                  marginTop = childStyle[MARGIN_TOP];
                  marginBottom = childStyle[MARGIN_BOTTOM];
                }
                // Margin auto alignment takes priority over align-items stretch,
                // it will not stretch child in vertical direction
                if (marginTop == AUTO || marginBottom == AUTO) {
                  minCrossAxisSize = childSize.height;
                  maxCrossAxisSize = double.infinity;
                } else {
                  double flexLineHeight = _getFlexLineHeight(runCrossAxisExtent, runBetweenSpace);
                  // Should substract margin when layout child
                  double marginVertical = 0;
                  if (child is RenderBoxModel) {
                    RenderBoxModel childRenderBoxModel = _getChildRenderBoxModel(child);
                    marginVertical = childRenderBoxModel.renderStyle.marginTop + childRenderBoxModel.renderStyle.marginBottom;
                  }
                  minCrossAxisSize = flexLineHeight - marginVertical;
                  maxCrossAxisSize = double.infinity;
                }
              } else {
                minCrossAxisSize = 0.0;
                maxCrossAxisSize = double.infinity;
              }
              innerConstraints = BoxConstraints(
                minWidth: minMainAxisSize,
                maxWidth: maxMainAxisSize,
                minHeight: minCrossAxisSize,
                maxHeight: maxCrossAxisSize);
              break;
            case FlexDirection.column:
            case FlexDirection.columnReverse:
              double mainAxisMinSize = minChildExtent ?? childSize.height;
              double mainAxisMaxSize = maxChildExtent ?? double.infinity;
              double minCrossAxisSize;
              double maxCrossAxisSize;

              // if child have predefined size
              if (_isCrossAxisDefinedSize(child)) {
                BoxSizeType sizeType = _getChildWidthSizeType(child);

                // child have predefined width, use previous layout width.
                if (sizeType == BoxSizeType.specified) {
                  // for empty child width, maybe it's unloaded image, set contentConstraints range.
                  if (childSize.isEmpty) {
                    minCrossAxisSize = 0.0;
                    maxCrossAxisSize = contentConstraints.maxWidth;
                  } else {
                    minCrossAxisSize = childSize.width;
                    maxCrossAxisSize = double.infinity;
                  }
                } else {
                  // expand child's height to contentConstraints.maxWidth;
                  minCrossAxisSize = contentConstraints.maxWidth;
                  maxCrossAxisSize = contentConstraints.maxWidth;
                }
              } else if (child is! RenderTextBox) {
                String marginLeft;
                String marginRight;
                if (child is RenderBoxModel) {
                  CSSStyleDeclaration childStyle = child.style;
                  marginLeft = childStyle[MARGIN_LEFT];
                  marginRight = childStyle[MARGIN_RIGHT];
                }
                // Margin auto alignment takes priority over align-items stretch,
                // it will not stretch child in horizontal direction
                if (marginLeft == AUTO || marginRight == AUTO) {
                  minCrossAxisSize = childSize.width;
                  maxCrossAxisSize = double.infinity;
                } else {
                  double flexLineHeight = _getFlexLineHeight(runCrossAxisExtent, runBetweenSpace);
                  // Should substract margin when layout child
                  double marginHorizontal = 0;
                  if (child is RenderBoxModel) {
                    RenderBoxModel childRenderBoxModel = _getChildRenderBoxModel(child);
                    marginHorizontal = childRenderBoxModel.renderStyle.marginLeft + childRenderBoxModel.renderStyle.marginRight;
                  }

                  minCrossAxisSize = flexLineHeight - marginHorizontal;
                  maxCrossAxisSize = double.infinity;
                }
              } else {
                // for RenderTextBox, there are no cross Axis contentConstraints.
                minCrossAxisSize = 0.0;
                maxCrossAxisSize = double.infinity;
              }
              innerConstraints = BoxConstraints(
                minHeight: mainAxisMinSize,
                maxHeight: mainAxisMaxSize,
                minWidth: minCrossAxisSize,
                maxWidth: maxCrossAxisSize);
              break;
          }
        } else {
          switch (renderStyle.flexDirection) {
            case FlexDirection.row:
            case FlexDirection.rowReverse:
              innerConstraints = BoxConstraints(
                minWidth: minChildExtent,
                maxWidth: maxChildExtent,
              );
              break;
            case FlexDirection.column:
            case FlexDirection.columnReverse:
              innerConstraints = BoxConstraints(
                minHeight: minChildExtent,
                maxHeight: maxChildExtent
              );
              break;
          }
        }

        DateTime childLayoutStart;
        if (kProfileMode) {
          childLayoutStart = DateTime.now();
        }

        child.layout(deflateOverflowConstraints(innerConstraints), parentUsesSize: true);

        if (kProfileMode) {
          DateTime childLayoutEnd = DateTime.now();
          childLayoutDuration += (childLayoutEnd.microsecondsSinceEpoch - childLayoutStart.microsecondsSinceEpoch);
        }

        // update max scrollable size
        if (child is RenderBoxModel) {
          maxScrollableWidthMap[child.targetId] = math.max(child.maxScrollableSize.width, childSize.width);
          maxScrollableHeightMap[child.targetId] = math.max(child.maxScrollableSize.height, childSize.height);
        }

        containerSizeMap['cross'] = math.max(containerSizeMap['cross'], _getCrossAxisExtent(child));

        // Only layout placeholder renderObject child
        child = childParentData.nextSibling;
      }

    }
  }

  /// Stage 3: Set flex container size according to children size
  void _setContainerSize(
    List<_RunMetrics> runMetrics,
    Map<String, double> containerSizeMap,
    double contentWidth,
    double contentHeight,
    Map<int, double> maxScrollableWidthMap,
    Map<int, double> maxScrollableHeightMap,
  ) {

    // Find max size of flex lines
    _RunMetrics maxMainSizeMetrics = runMetrics.reduce((_RunMetrics curr, _RunMetrics next) {
      return curr.mainAxisExtent > next.mainAxisExtent ? curr : next;
    });
    // Actual main axis size of flex items
    double maxAllocatedMainSize = maxMainSizeMetrics.mainAxisExtent;

    CSSDisplay realDisplay = CSSSizing.getElementRealDisplayValue(targetId, elementManager);
    // Get layout width from children's width by flex axis
    double constraintWidth = CSSFlex.isHorizontalFlexDirection(renderStyle.flexDirection) ? containerSizeMap['main'] : containerSizeMap['cross'];
    bool isInlineBlock = realDisplay == CSSDisplay.inlineBlock;

    double width = renderStyle.width;
    double height = renderStyle.height;
    double minWidth = renderStyle.minWidth;
    double minHeight = renderStyle.minHeight;
    double maxWidth = renderStyle.maxWidth;
    double maxHeight = renderStyle.maxHeight;

    // Constrain to min-width or max-width if width not exists
    double childrenWidth = CSSFlex.isHorizontalFlexDirection(renderStyle.flexDirection) ? maxAllocatedMainSize : containerSizeMap['cross'];
    if (isInlineBlock && maxWidth != null && width == null) {
      constraintWidth = childrenWidth > maxWidth ? maxWidth : childrenWidth;
    } else if (isInlineBlock && minWidth != null && width == null) {
      constraintWidth = childrenWidth < minWidth ? minWidth : childrenWidth;
    } else if (contentWidth != null) {
      constraintWidth = math.max(constraintWidth, contentWidth);
    }

    // Get layout height from children's height by flex axis
    double constraintHeight = CSSFlex.isHorizontalFlexDirection(renderStyle.flexDirection) ? containerSizeMap['cross'] : containerSizeMap['main'];
    bool isNotInline = realDisplay != CSSDisplay.inline;

    // Constrain to min-height or max-height if width not exists
    double childrenHeight = CSSFlex.isHorizontalFlexDirection(renderStyle.flexDirection) ? containerSizeMap['cross'] : maxAllocatedMainSize;
    if (isNotInline && maxHeight != null && height == null) {
      constraintHeight = childrenHeight > maxHeight ? maxHeight : childrenHeight;
    } else if (isNotInline && minHeight != null && height == null) {
      constraintHeight = constraintHeight < minHeight ? minHeight : constraintHeight;
    } else if (contentHeight != null) {
      constraintHeight = math.max(constraintHeight, contentHeight);
    }

    double maxScrollableWidth = 0.0;
    double maxScrollableHeight = 0.0;

    if (CSSFlex.isHorizontalFlexDirection(renderStyle.flexDirection)) {
      maxScrollableWidthMap.forEach((key, value) => maxScrollableWidth += value);
      maxScrollableHeightMap.forEach((key, value) => maxScrollableHeight = math.max(value, maxScrollableHeight));
    } else {
      maxScrollableWidthMap.forEach((key, value) => maxScrollableWidth = math.max(value, maxScrollableWidth));
      maxScrollableHeightMap.forEach((key, value) => maxScrollableHeight += value);
    }

    /// Stage 3: Set flex container size
    Size contentSize = Size(constraintWidth, constraintHeight);
    if (CSSFlex.isHorizontalFlexDirection(renderStyle.flexDirection)) {
      setMaxScrollableSize(math.max(contentSize.width, maxScrollableWidth), math.max(contentSize.height, maxScrollableHeight));
    } else {
      setMaxScrollableSize(math.max(contentSize.width, maxScrollableWidth), math.max(contentSize.height, maxScrollableHeight));
    }
    size = getBoxSize(contentSize);

    /// Set auto value of min-width and min-height based on size of flex items
    if (CSSFlex.isHorizontalFlexDirection(renderStyle.flexDirection)) {
      autoMinWidth = _getMainAxisAutoSize(runMetrics);
      autoMinHeight = _getCrossAxisAutoSize(runMetrics);
    } else {
      autoMinHeight = _getMainAxisAutoSize(runMetrics);
      autoMinWidth = _getCrossAxisAutoSize(runMetrics);
    }
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
      Map<int, _RunChild> runChildren = runMetrics.runChildren;
      double runMainExtent = 0;
      void iterateRunChildren(int targetId, _RunChild runChild) {
        double runChildMainSize = runChild.originalMainSize;
        RenderBox child = runChild.child;
        // Decendants with percentage main size should not include in auto main size
        if (child is RenderBoxModel) {
          String mainSize = CSSFlex.isHorizontalFlexDirection(renderStyle.flexDirection) ?
            child.style[WIDTH] : child.style[HEIGHT];
          String mainMinSize = CSSFlex.isHorizontalFlexDirection(renderStyle.flexDirection) ?
            child.style[MIN_WIDTH] : child.style[MIN_HEIGHT];
          if (CSSLength.isPercentage(mainSize) ||
            (mainSize.isEmpty && CSSLength.isPercentage(mainMinSize))
          ) {
            runChildMainSize = 0;
          }
        }
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
    // Get the sum size of flex lines
    for (_RunMetrics curr in runMetrics) {
      autoMinSize += curr.crossAxisExtent;
    }
    return autoMinSize;
  }

  /// Get flex line height according to flex-wrap style
  double _getFlexLineHeight(double runCrossAxisExtent, double runBetweenSpace) {
    // Flex line of align-content stretch should includes between space
    bool isMultiLineStretch = (renderStyle.flexWrap == FlexWrap.wrap || renderStyle.flexWrap == FlexWrap.wrapReverse) &&
      renderStyle.alignContent == AlignContent.stretch;
    // The height of flex line in single line equals to flex container's cross size
    bool isSingleLine = (renderStyle.flexWrap != FlexWrap.wrap && renderStyle.flexWrap != FlexWrap.wrapReverse);

    if (isSingleLine) {
      return hasSize ? _getContentCrossSize() : runCrossAxisExtent;
    } else if (isMultiLineStretch) {
      return runCrossAxisExtent + runBetweenSpace;
    } else {
      return runCrossAxisExtent;
    }
  }

  // Set flex item offset based on flex alignment properties
  void _alignChildren(
    List<_RunMetrics> runMetrics,
    double runBetweenSpace,
    double runLeadingSpace,
    RenderPositionHolder placeholderChild,
    Map<String, double> containerSizeMap,
    Map<int, double> maxScrollableWidthMap,
    Map<int, double> maxScrollableHeightMap,
    ) {
    RenderBox child = placeholderChild != null ? placeholderChild : firstChild;
    // Cross axis offset of each flex line
    double crossAxisOffset = runLeadingSpace;
    double mainAxisContentSize;
    double crossAxisContentSize;

    if (CSSFlex.isHorizontalFlexDirection(renderStyle.flexDirection)) {
      mainAxisContentSize = contentSize.width;
      crossAxisContentSize = contentSize.height;
    } else {
      mainAxisContentSize = contentSize.height;
      crossAxisContentSize = contentSize.width;
    }

    /// Set offset of children
    for (int i = 0; i < runMetrics.length; ++i) {
      final _RunMetrics metrics = runMetrics[i];
      final double runMainAxisExtent = metrics.mainAxisExtent;
      final double runCrossAxisExtent = metrics.crossAxisExtent;
      final double runBaselineExtent = metrics.baselineExtent;
      final double totalFlexGrow = metrics.totalFlexGrow;
      final double totalFlexShrink = metrics.totalFlexShrink;
      final Map<int, _RunChild> runChildren = metrics.runChildren;

      final double mainContentSizeDelta = mainAxisContentSize - runMainAxisExtent;
      bool isFlexGrow = mainContentSizeDelta >= 0 && totalFlexGrow > 0;
      bool isFlexShrink = mainContentSizeDelta < 0 && totalFlexShrink > 0;

      _overflow = math.max(0.0, - mainContentSizeDelta);
      // If flex grow or flex shrink exists, remaining space should be zero
      final double remainingSpace = (isFlexGrow || isFlexShrink) ? 0 : mainContentSizeDelta;
      double leadingSpace;
      double betweenSpace;

      final int runChildrenCount = runChildren.length;

      // flipMainAxis is used to decide whether to lay out left-to-right/top-to-bottom (false), or
      // right-to-left/bottom-to-top (true). The _startIsTopLeft will return null if there's only
      // one child and the relevant direction is null, in which case we arbitrarily decide not to
      // flip, but that doesn't have any detectable effect.
      final bool flipMainAxis = !(_startIsTopLeft(renderStyle.flexDirection) ?? true);
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
            betweenSpace = 0;
          } else {
            betweenSpace = runChildrenCount > 1 ? remainingSpace / (runChildrenCount - 1) : 0.0;
          }
          break;
        case JustifyContent.spaceAround:
          if (remainingSpace < 0) {
            leadingSpace = remainingSpace / 2.0;
            betweenSpace = 0;
          } else {
            betweenSpace = runChildrenCount > 0 ? remainingSpace / runChildrenCount : 0.0;
            leadingSpace = betweenSpace / 2.0;
          }
          break;
        case JustifyContent.spaceEvenly:
          if (remainingSpace < 0) {
            leadingSpace = remainingSpace / 2.0;
            betweenSpace = 0;
          } else {
            betweenSpace = runChildrenCount > 0 ? remainingSpace / (runChildrenCount + 1) : 0.0;
            leadingSpace = betweenSpace;
          }
          break;
        default:
      }

      // Calculate margin auto children in the main axis
      double mainAxisMarginAutoChildren = 0;
      RenderBox runChild = firstChild;
      while (runChild != null) {
        final RenderLayoutParentData childParentData = runChild.parentData;
        if (childParentData.runIndex != i) break;
        if (runChild is RenderBoxModel) {
          CSSStyleDeclaration childStyle = runChild.style;
          String marginLeft = childStyle[MARGIN_LEFT];
          String marginTop = childStyle[MARGIN_TOP];

          if ((CSSFlex.isHorizontalFlexDirection(renderStyle.flexDirection) && marginLeft == AUTO) ||
            (CSSFlex.isVerticalFlexDirection(renderStyle.flexDirection) && marginTop == AUTO)) {
            mainAxisMarginAutoChildren++;
          }
        }
        runChild = childParentData.nextSibling;
      }

      // Margin auto alignment takes priority over align-self alignment
      if (mainAxisMarginAutoChildren != 0) {
        leadingSpace = 0;
        betweenSpace = 0;
      }

      double mainAxisStartPadding = flowAwareMainAxisPadding();
      double crossAxisStartPadding = flowAwareCrossAxisPadding();

      double mainAxisStartBorder = flowAwareMainAxisBorder();
      double crossAxisStartBorder = flowAwareCrossAxisBorder();

      // Main axis position of child while layout
      double childMainPosition =
      flipMainAxis ? mainAxisStartPadding + mainAxisStartBorder + mainAxisContentSize - leadingSpace :
      leadingSpace + mainAxisStartPadding + mainAxisStartBorder;

      // Leading between height of line box's content area and line height of line box
      double lineBoxLeading = 0;
      double lineBoxHeight = _getLineHeight(this);
      if (lineBoxHeight != null) {
        lineBoxLeading = lineBoxHeight - runCrossAxisExtent;
      }

      while (child != null) {

        final RenderLayoutParentData childParentData = child.parentData;
        // Exclude positioned placeholder renderObject when layout non placeholder object
        // and positioned renderObject
        if (placeholderChild == null && (isPlaceholderPositioned(child) || childParentData.isPositioned)) {
          child = childParentData.nextSibling;
          continue;
        }
        if (childParentData.runIndex != i) break;

        double childMainAxisMargin = flowAwareChildMainAxisMargin(child);
        double childCrossAxisStartMargin = flowAwareChildCrossAxisMargin(child);

        // Add start margin of main axis when setting offset
        childMainPosition += childMainAxisMargin;

        double childCrossPosition;

        CSSStyleDeclaration childStyle = _getChildStyle(child);

        AlignSelf alignSelf = _getAlignSelf(child);
        double crossStartAddedOffset = crossAxisStartPadding + crossAxisStartBorder + childCrossAxisStartMargin;

        /// Align flex item by direction returned by align-items or align-self
        double alignFlexItem(String alignment) {
          double flexLineHeight = _getFlexLineHeight(runCrossAxisExtent, runBetweenSpace);

          switch (alignment) {
            case 'start':
              return crossStartAddedOffset;
            case 'end':
              // Length returned by _getCrossAxisExtent includes margin, so end alignment should add start margin
              return crossAxisStartPadding + crossAxisStartBorder + flexLineHeight -
                _getCrossAxisExtent(child) + childCrossAxisStartMargin;
            case 'center':
              return childCrossPosition = crossStartAddedOffset + (flexLineHeight - _getCrossAxisExtent(child)) / 2.0;
            case 'baseline':
              // Distance from top to baseline of child
              double childAscent = _getChildAscent(child);
              return crossStartAddedOffset + lineBoxLeading / 2 + (runBaselineExtent - childAscent);
            default:
              return null;
          }
        }

        if (alignSelf == AlignSelf.auto) {
          switch (renderStyle.alignItems) {
            case AlignItems.flexStart:
            case AlignItems.start:
            case AlignItems.stretch:
              childCrossPosition = renderStyle.flexWrap == FlexWrap.wrapReverse ? alignFlexItem('end') : alignFlexItem('start');
              break;
            case AlignItems.flexEnd:
            case AlignItems.end:
              childCrossPosition = renderStyle.flexWrap == FlexWrap.wrapReverse ? alignFlexItem('start') : alignFlexItem('end');
              break;
            case AlignItems.center:
              childCrossPosition = alignFlexItem('center');
              break;
            case AlignItems.baseline:
              // FIXME: baseline aligne in wrap-reverse flexWrap may display different from browser in some case
              if (CSSFlex.isHorizontalFlexDirection(renderStyle.flexDirection)) {
                childCrossPosition = alignFlexItem('baseline');
              } else if (renderStyle.flexWrap == FlexWrap.wrapReverse) {
                childCrossPosition = alignFlexItem('end');
              } else {
                childCrossPosition = alignFlexItem('start');
              }
              break;
            default:
              break;
          }
        } else {
          switch (alignSelf) {
            case AlignSelf.flexStart:
            case AlignSelf.start:
            case AlignSelf.stretch:
              childCrossPosition = renderStyle.flexWrap == FlexWrap.wrapReverse ? alignFlexItem('end') : alignFlexItem('start');
              break;
            case AlignSelf.flexEnd:
            case AlignSelf.end:
              childCrossPosition = renderStyle.flexWrap == FlexWrap.wrapReverse ? alignFlexItem('start') : alignFlexItem('end');
              break;
            case AlignSelf.center:
              childCrossPosition = alignFlexItem('center');
              break;
            case AlignSelf.baseline:
              childCrossPosition = alignFlexItem('baseline');
              break;
            default:
              break;
          }
        }

        // Calculate margin auto length according to CSS spec rules
        // https://www.w3.org/TR/css-flexbox-1/#auto-margins
        // margin auto takes up available space in the remaining space
        // between flex items and flex container
        if (child is RenderBoxModel) {
          CSSStyleDeclaration childStyle = child.style;
          String marginLeft = childStyle[MARGIN_LEFT];
          String marginRight = childStyle[MARGIN_RIGHT];
          String marginTop = childStyle[MARGIN_TOP];
          String marginBottom = childStyle[MARGIN_BOTTOM];

          double horizontalRemainingSpace;
          double verticalRemainingSpace;
          // Margin auto does not work with negative remaining space
          double mainAxisRemainingSpace = math.max(0, remainingSpace);
          double crossAxisRemainingSpace = math.max(0, crossAxisContentSize - _getCrossAxisExtent(child));

          if (CSSFlex.isHorizontalFlexDirection(renderStyle.flexDirection)) {
            horizontalRemainingSpace = mainAxisRemainingSpace;
            verticalRemainingSpace = crossAxisRemainingSpace;
            if (totalFlexGrow == 0 && marginLeft == AUTO) {
              if (marginRight == AUTO) {
                childMainPosition += (horizontalRemainingSpace / mainAxisMarginAutoChildren) / 2;
                betweenSpace = (horizontalRemainingSpace / mainAxisMarginAutoChildren) / 2;
              } else {
                childMainPosition += horizontalRemainingSpace / mainAxisMarginAutoChildren;
              }
            }

            if (marginTop == AUTO) {
              if (marginBottom == AUTO) {
                childCrossPosition += verticalRemainingSpace / 2;
              } else {
                childCrossPosition += verticalRemainingSpace;
              }
            }
          } else {
            horizontalRemainingSpace = crossAxisRemainingSpace;
            verticalRemainingSpace = mainAxisRemainingSpace;
            if (totalFlexGrow == 0 && marginTop == AUTO) {
              if (marginBottom == AUTO) {
                childMainPosition += (verticalRemainingSpace / mainAxisMarginAutoChildren) / 2;
                betweenSpace = (verticalRemainingSpace / mainAxisMarginAutoChildren) / 2;
              } else {
                childMainPosition += verticalRemainingSpace / mainAxisMarginAutoChildren;
              }
            }

            if (marginLeft == AUTO) {
              if (marginRight == AUTO) {
                childCrossPosition += horizontalRemainingSpace / 2;
              } else {
                childCrossPosition += horizontalRemainingSpace;
              }
            }
          }
        }

        if (flipMainAxis) childMainPosition -= _getMainAxisExtent(child);

        double crossOffset;
        if (renderStyle.flexWrap == FlexWrap.wrapReverse) {
          crossOffset = childCrossPosition + (crossAxisContentSize - crossAxisOffset - runCrossAxisExtent - runBetweenSpace);
        } else {
          crossOffset = childCrossPosition + crossAxisOffset;
        }
        Offset relativeOffset = _getOffset(
          childMainPosition,
          crossOffset
        );

        /// Apply position relative offset change
        CSSPositionedLayout.applyRelativeOffset(relativeOffset, child, childStyle);

        // Need to substract start margin of main axis when calculating next child's start position
        if (flipMainAxis) {
          childMainPosition -= betweenSpace + childMainAxisMargin;
        } else {
          childMainPosition += _getMainAxisExtent(child) - childMainAxisMargin + betweenSpace;
        }
        // Only layout placeholder renderObject child
        child = placeholderChild == null ? childParentData.nextSibling : null;
      }

      crossAxisOffset += runCrossAxisExtent + runBetweenSpace;
    }
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

  // Get distance from top to baseline of child incluing margin
  double _getChildAscent(RenderBox child) {
    // Distance from top to baseline of child
    double childAscent = child.getDistanceToBaseline(TextBaseline.alphabetic, onlyReal: true);

    double childMarginTop = 0;
    double childMarginBottom = 0;
    if (child is RenderBoxModel) {
      RenderBoxModel childRenderBoxModel = _getChildRenderBoxModel(child);
      childMarginTop = childRenderBoxModel.renderStyle.marginTop;
      childMarginBottom = childRenderBoxModel.renderStyle.marginBottom;
    }

    Size childSize = _getChildSize(child);
    // When baseline of children not found, use boundary of margin bottom as baseline
    double extentAboveBaseline = childAscent != null ?
    childMarginTop + childAscent :
    childMarginTop + childSize.height + childMarginBottom;

    return extentAboveBaseline;
  }

  CSSStyleDeclaration _getChildStyle(RenderBox child) {
    CSSStyleDeclaration childStyle;
    int childNodeId;
    if (child is RenderTextBox) {
      childNodeId = targetId;
    } else if (child is RenderBoxModel) {
      childNodeId = child.targetId;
    } else if (child is RenderPositionHolder) {
      childNodeId = child.realDisplayedBox?.targetId;
    }
    childStyle = elementManager.getEventTargetByTargetId<Element>(childNodeId)?.style;
    return childStyle;
  }

  Offset _getOffset(double mainAxisOffset, double crossAxisOffset) {
    bool isVerticalDirection = CSSFlex.isVerticalFlexDirection(renderStyle.flexDirection);
    if (isVerticalDirection) {
      return Offset(crossAxisOffset, mainAxisOffset);
    } else {
      return Offset(mainAxisOffset, crossAxisOffset);
    }
  }
  /// Get cross size of  content size
  double _getContentCrossSize() {
    if (CSSFlex.isHorizontalFlexDirection(renderStyle.flexDirection)) {
      return contentSize.height;
    }
    return contentSize.width;
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
  bool hitTestChildren(BoxHitTestResult result, {Offset position}) {
    if (renderStyle.transform != null) {
      return hitTestLayoutChildren(result, lastChild, position);
    }
    return defaultHitTestChildren(result, position: position);
  }

  Offset getChildScrollOffset(RenderObject child, Offset offset) {
    final RenderLayoutParentData childParentData = child.parentData;
    bool isChildFixed = child is RenderBoxModel ?
      child.renderStyle.position == CSSPositionType.fixed : false;
    // Fixed elements always paint original offset
    Offset scrollOffset = isChildFixed ?
    childParentData.offset : childParentData.offset + offset;
    return scrollOffset;
  }

  @override
  void performPaint(PaintingContext context, Offset offset) {
    if (needsSortChildren) {
      if (!isChildrenSorted) {
        sortChildrenByZIndex();
      }
      for (int i = 0; i < sortedChildren.length; i ++) {
        RenderObject child = sortedChildren[i];
        // Don't paint placeholder of positioned element
        if (child is! RenderPositionHolder) {
          DateTime childPaintStart;
          if (kProfileMode) {
            childPaintStart = DateTime.now();
          }
          context.paintChild(child, getChildScrollOffset(child, offset));
          if (kProfileMode) {
            DateTime childPaintEnd = DateTime.now();
            childPaintDuration += (childPaintEnd.microsecondsSinceEpoch - childPaintStart.microsecondsSinceEpoch);
          }
        }
      }
    } else {
      RenderObject child = firstChild;
      while (child != null) {
        final RenderLayoutParentData childParentData = child.parentData;
        // Don't paint placeholder of positioned element
        if (child is! RenderPositionHolder) {
          DateTime childPaintStart;
          if (kProfileMode) {
            childPaintStart = DateTime.now();
          }
          context.paintChild(child, getChildScrollOffset(child, offset));
          if (kProfileMode) {
            DateTime childPaintEnd = DateTime.now();
            childPaintDuration += (childPaintEnd.microsecondsSinceEpoch - childPaintStart.microsecondsSinceEpoch);
          }
        }
        child = childParentData.nextSibling;
      }
    }
  }

  @override
  Rect describeApproximatePaintClip(RenderObject child) => _hasOverflow ? Offset.zero & size : null;

  @override
  String toStringShort() {
    String header = super.toStringShort();
    if (_overflow is double && _hasOverflow) header += ' OVERFLOWING';
    return header;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<FlexDirection>('flexDirection', renderStyle.flexDirection));
    properties.add(DiagnosticsProperty<JustifyContent>('justifyContent', renderStyle.justifyContent));
    properties.add(DiagnosticsProperty<AlignItems>('alignItems', renderStyle.alignItems));
    properties.add(DiagnosticsProperty<FlexWrap>('flexWrap', renderStyle.flexWrap));
  }

  RenderRecyclerLayout toRenderRecyclerLayout() {
    List<RenderBox> children = getDetachedChildrenAsList();
    RenderRecyclerLayout renderRecyclerLayout = RenderRecyclerLayout(
        targetId: targetId,
        style: style,
        elementManager: elementManager
    );
    renderRecyclerLayout.addAll(children);
    return copyWith(renderRecyclerLayout);
  }

  /// Convert [RenderFlexLayout] to [RenderFlowLayout]
  RenderFlowLayout toFlowLayout() {
    List<RenderBox> children = getDetachedChildrenAsList();
    RenderFlowLayout flowLayout = RenderFlowLayout(
      children: children,
      targetId: targetId,
      style: style,
      elementManager: elementManager
    );
    return copyWith(flowLayout);
  }

  /// Convert [RenderFlexLayout] to [RenderSelfRepaintFlexLayout]
  RenderSelfRepaintFlexLayout toSelfRepaint() {
    List<RenderObject> children = getDetachedChildrenAsList();
    RenderSelfRepaintFlexLayout selfRepaintFlexLayout = RenderSelfRepaintFlexLayout(
      children: children,
      targetId: targetId,
      style: style,
      elementManager: elementManager
    );
    return copyWith(selfRepaintFlexLayout);
  }

  /// Convert [RenderFlexLayout] to [RenderSelfRepaintFlowLayout]
  RenderSelfRepaintFlowLayout toSelfRepaintFlowLayout() {
    List<RenderObject> children = getDetachedChildrenAsList();
    RenderSelfRepaintFlowLayout selfRepaintFlowLayout = RenderSelfRepaintFlowLayout(
      children: children,
      targetId: targetId,
      style: style,
      elementManager: elementManager
    );
    return copyWith(selfRepaintFlowLayout);
  }
}

// Render flex layout with self repaint boundary.
class RenderSelfRepaintFlexLayout extends RenderFlexLayout {
  RenderSelfRepaintFlexLayout({
    List<RenderBox> children,
    int targetId,
    ElementManager elementManager,
    CSSStyleDeclaration style,
  }) : super(children: children, targetId: targetId, elementManager: elementManager, style: style);

  @override
  bool get isRepaintBoundary => true;

  /// Convert [RenderSelfRepaintFlexLayout] to [RenderFlowLayout]
  RenderSelfRepaintFlowLayout toFlowLayout() {
    List<RenderObject> children = getDetachedChildrenAsList();
    RenderSelfRepaintFlowLayout selfRepaintFlowLayout = RenderSelfRepaintFlowLayout(
      children: children,
      targetId: targetId,
      style: style,
      elementManager: elementManager
    );
    return copyWith(selfRepaintFlowLayout);
  }

  /// Convert [RenderSelfRepaintFlexLayout] to [RenderFlexLayout]
  RenderFlexLayout toParentRepaint() {
    List<RenderObject> children = getDetachedChildrenAsList();
    RenderFlexLayout flexLayout = RenderFlexLayout(
      children: children,
      targetId: targetId,
      style: style,
      elementManager: elementManager
    );
    return copyWith(flexLayout);
  }

  /// Convert [RenderSelfRepaintFlexLayout] to [RenderFlowLayout]
  RenderFlowLayout toParentRepaintFlowLayout() {
    List<RenderObject> children = getDetachedChildrenAsList();
    RenderFlowLayout flowLayout = RenderFlowLayout(
      children: children,
      targetId: targetId,
      style: style,
      elementManager: elementManager
    );
    return copyWith(flowLayout);
  }
}
