import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:kraken/rendering.dart';
import 'package:kraken/element.dart';
import 'package:kraken/css.dart';

class RenderFlexParentData extends RenderLayoutParentData {
  /// Flex grow
  int flexGrow;

  /// Flex shrink
  int flexShrink;

  /// Flex basis
  String flexBasis;

  // align-items
  CrossAxisAlignment crossAxisAlignment;

  @override
  String toString() => '${super.toString()}; flexGrow=$flexGrow; flexShrink=$flexShrink; flexBasis=$flexBasis';
}

bool isHorizontalFlexDirection(FlexDirection flexDirection) {
  return flexDirection == FlexDirection.row || flexDirection == FlexDirection.rowReverse;
}

bool isVerticalFlexDirection(FlexDirection flexDirection) {
  return flexDirection == FlexDirection.columnReverse || flexDirection == FlexDirection.column;
}

FlexDirection flipDirection(FlexDirection direction) {
  assert(direction != null);
  switch (direction) {
    case FlexDirection.row:
      return FlexDirection.column;
    case FlexDirection.column:
      return FlexDirection.row;
    case FlexDirection.rowReverse:
      return FlexDirection.columnReverse;
    case FlexDirection.columnReverse:
      return FlexDirection.rowReverse;
  }
  return null;
}

/// sets whether flex items are forced onto one line or can wrap onto multiple lines.
/// If wrapping is allowed, it sets the direction that lines are stacked.
enum FlexWrap {
  /// The flex items are laid out in a single line which may cause the flex container to overflow.
  /// The cross-start is either equivalent to start or before depending flex-direction value.
  /// This is the default value.
  nowrap,

  /// The flex items break into multiple lines.
  /// The cross-start is either equivalent to start or before depending flex-direction value and the cross-end is the opposite of the specified cross-start.
  wrap,

  /// Behaves the same as wrap but cross-start and cross-end are permuted.
  wrapReverse
}

/// sets how flex items are placed in the flex container defining the main axis and the direction (normal or reversed).
enum FlexDirection {
  /// The flex container's main-axis is defined to be the same as the text direction.
  /// The main-start and main-end points are the same as the content direction.
  row,

  /// Behaves the same as row but the main-start and main-end points are permuted.
  rowReverse,

  /// The flex container's main-axis is the same as the block-axis.
  /// The main-start and main-end points are the same as the before and after points of the writing-mode.
  column,

  /// Behaves the same as column but the main-start and main-end are permuted.
  columnReverse
}

/// Defines how the browser distributes space between and around content items along the main-axis of a flex container,
/// and the inline axis of a grid container.
enum JustifyContent {
  /// The items are packed flush to each other toward the start edge of the alignment container in the main axis.
  start,

  /// The items are packed flush to each other toward the end edge of the alignment container in the main axis.
  end,

  /// The items are packed flush to each other toward the edge of the alignment container depending on the flex container's main-start side.
  /// This only applies to flex layout items. For items that are not children of a flex container, this value is treated like start.
  flexStart,

  /// The items are packed flush to each other toward the edge of the alignment container depending on the flex container's main-end side.
  /// This only applies to flex layout items. For items that are not children of a flex container, this value is treated like end.
  flexEnd,

  /// The items are packed flush to each other toward the center of the alignment container along the main axis.
  center,

  /// Specifies participation in first- or last-baseline alignment:
  /// aligns the alignment baseline of the box’s first or last baseline set with the corresponding baseline in the shared first or last baseline set of all the boxes in its baseline-sharing group.
  /// The fallback alignment for first baseline is start, the one for last baseline is end.
  /// @TODO not supported
  baseline,

  /// The items are evenly distributed within the alignment container along the main axis.
  /// The spacing between each pair of adjacent items is the same.
  /// The first item is flush with the main-start edge, and the last item is flush with the main-end edge.
  spaceBetween,

  /// The items are evenly distributed within the alignment container along the main axis. The spacing between each pair of adjacent items is the same.
  /// The empty space before the first and after the last item equals half of the space between each pair of adjacent items.
  spaceAround,

  /// The items are evenly distributed within the alignment container along the main axis. The spacing between each pair of adjacent items,
  /// the main-start edge and the first item, and the main-end edge and the last item, are all exactly the same.
  spaceEvenly,
}

/// Sets the distribution of space between and around content items along a flexbox's cross-axis or a grid's block axis.
enum AlignContent {
  /// The items are packed in their default position as if no align-content value was set.
  normal,

  /// The items are packed flush to each other against the start edge of the alignment container in the cross axis.
  start,

  /// The items are packed flush to each other against the end edge of the alignment container in the cross axis.
  end,

  /// The items are packed flush to each other against the edge of the alignment container depending on the flex container's cross-start side.
  /// This only applies to flex layout items. For items that are not children of a flex container, this value is treated like start.
  flexStart,

  /// The items are packed flush to each other against the edge of the alignment container depending on the flex container's cross-end side.
  /// This only applies to flex layout items. For items that are not children of a flex container, this value is treated like end.
  flexEnd,

  /// The items are packed flush to each other in the center of the alignment container along the cross axis.
  center,

  /// The items are evenly distributed within the alignment container along the cross axis.
  /// The spacing between each pair of adjacent items is the same.
  /// The first item is flush with the start edge of the alignment container in the cross axis, and the last item is flush with the end edge of the alignment container in the cross axis.
  spaceBetween,

  /// The items are evenly distributed within the alignment container along the cross axis.
  /// The spacing between each pair of adjacent items is the same.
  /// The empty space before the first and after the last item equals half of the space between each pair of adjacent items.
  spaceAround,

  /// If the combined size of the items along the cross axis is less than the size of the alignment container,
  /// any auto-sized items have their size increased equally (not proportionally),
  /// while still respecting the constraints imposed by max-height/max-width (or equivalent functionality),
  /// so that the combined size exactly fills the alignment container along the cross axis.
  stretch
}

/// Set the space distributed between and around content items along the cross-axis of their container.
enum AlignItems {
  /// The items are packed flush to each other toward the start edge of the alignment container in the appropriate axis.
  start,

  /// The items are packed flush to each other toward the end edge of the alignment container in the appropriate axis.
  end,

  /// The cross-start margin edges of the flex items are flushed with the cross-start edge of the line.
  flexStart,

  /// The cross-end margin edges of the flex items are flushed with the cross-end edge of the line.
  flexEnd,

  /// The flex items' margin boxes are centered within the line on the cross-axis.
  /// If the cross-size of an item is larger than the flex container, it will overflow equally in both directions.
  center,

  /// Flex items are stretched such that the cross-size of the item's margin box is the same as the line while respecting width and height constraints.
  stretch,

  /// All flex items are aligned such that their flex container baselines align.
  /// The item with the largest distance between its cross-start margin edge and its baseline is flushed with the cross-start edge of the line.
  baseline
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

typedef _ChildSizingFunction = double Function(RenderBox child, double extent);

/// Displays its children in a one-dimensional array.
///
/// ## Layout algorithm
///
/// _This section describes how the framework causes [RenderFlexLayout] to position
/// its children._
/// _See [BoxConstraints] for an introduction to box layout models._
///
/// Layout for a [RenderFlexLayout] proceeds in six steps:
///
/// 1. Layout each child a null or zero flex factor with unbounded main axis
///    constraints and the incoming cross axis constraints. If the
///    [crossAxisAlignment] is [CrossAxisAlignment.stretch], instead use tight
///    cross axis constraints that match the incoming max extent in the cross
///    axis.
/// 2. Divide the remaining main axis space among the children with non-zero
///    flex factors according to their flex factor. For example, a child with a
///    flex factor of 2.0 will receive twice the amount of main axis space as a
///    child with a flex factor of 1.0.
/// 3. Layout each of the remaining children with the same cross axis
///    constraints as in step 1, but instead of using unbounded main axis
///    constraints, use max axis constraints based on the amount of space
///    allocated in step 2. Children with [Flexible.fit] properties that are
///    [FlexFit.tight] are given tight constraints (i.e., forced to fill the
///    allocated space), and children with [Flexible.fit] properties that are
///    [FlexFit.loose] are given loose constraints (i.e., not forced to fill the
///    allocated space).
/// 4. The cross axis extent of the [RenderFlexLayout] is the maximum cross axis
///    extent of the children (which will always satisfy the incoming
///    constraints).
/// 5. The main axis extent of the [RenderFlexLayout] is determined by the
///    [mainAxisSize] property. If the [mainAxisSize] property is
///    [MainAxisSize.max], then the main axis extent of the [RenderFlex] is the
///    max extent of the incoming main axis constraints. If the [mainAxisSize]
///    property is [MainAxisSize.min], then the main axis extent of the [Flex]
///    is the sum of the main axis extents of the children (subject to the
///    incoming constraints).
/// 6. Determine the position for each child according to the
///    [mainAxisAlignment] and the [crossAxisAlignment]. For example, if the
///    [mainAxisAlignment] is [MainAxisAlignment.spaceBetween], any main axis
///    space that has not been allocated to children is divided evenly and
///    placed between the children.
///
/// See also:
///
///  * [Flex], the widget equivalent.
///  * [Row] and [Column], direction-specific variants of [Flex].
class RenderFlexLayout extends RenderLayoutBox {
  /// Creates a flex render object.
  ///
  /// By default, the flex layout is horizontal and children are aligned to the
  /// start of the main axis and the center of the cross axis.
  RenderFlexLayout({
    List<RenderBox> children,
    FlexDirection flexDirection = FlexDirection.row,
    FlexWrap flexWrap = FlexWrap.nowrap,
    JustifyContent justifyContent = JustifyContent.start,
    AlignItems alignItems = AlignItems.stretch,
    int targetId,
    CSSStyleDeclaration style,
  })  : assert(flexDirection != null),
        assert(flexWrap != null),
        assert(justifyContent != null),
        assert(alignItems != null),
        _flexDirection = flexDirection,
        _flexWrap = flexWrap,
        _justifyContent = justifyContent,
        _alignItems = alignItems,
        super(targetId: targetId, style: style) {
    addAll(children);
  }

  /// The direction to use as the main axis.
  FlexDirection get flexDirection => _flexDirection;
  FlexDirection _flexDirection;

  set flexDirection(FlexDirection value) {
    assert(value != null);
    if (_flexDirection != value) {
      _flexDirection = value;
      markNeedsLayout();
    }
  }

  /// whether flex items are forced onto one line or can wrap onto multiple lines.
  FlexWrap get flexWrap => _flexWrap;
  FlexWrap _flexWrap;

  set flexWrap(FlexWrap value) {
    assert(value != null);
    if (_flexWrap != value) {
      _flexWrap = value;
      markNeedsLayout();
    }
  }

  JustifyContent get justifyContent => _justifyContent;
  JustifyContent _justifyContent;

  set justifyContent(JustifyContent value) {
    assert(value != null);
    if (_justifyContent != value) {
      _justifyContent = value;
      markNeedsLayout();
    }
  }

  AlignItems get alignItems => _alignItems;
  AlignItems _alignItems;

  set alignItems(AlignItems value) {
    assert(value != null);
    if (_alignItems != value) {
      _alignItems = value;
      markNeedsLayout();
    }
  }

  // Set during layout if overflow occurred on the main axis.
  double _overflow;

  // Check whether any meaningful overflow is present. Values below an epsilon
  // are treated as not overflowing.
  bool get _hasOverflow => _overflow > precisionErrorTolerance;

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! RenderFlexParentData) {
      if (child is RenderElementBoundary) {
        child.parentData = getPositionParentDataFromStyle(child.style);
      } else {
        child.parentData = RenderFlexParentData();
      }
    }
  }

  double _getIntrinsicSize({
    FlexDirection sizingDirection,
    double extent, // the extent in the direction that isn't the sizing direction
    _ChildSizingFunction childSize, // a method to find the size in the sizing direction
  }) {
    if (_flexDirection == sizingDirection) {
      // INTRINSIC MAIN SIZE
      // Intrinsic main size is the smallest size the flex container can take
      // while maintaining the min/max-content contributions of its flex items.
      double totalFlexGrow = 0.0;
      double inflexibleSpace = 0.0;
      double maxFlexFractionSoFar = 0.0;
      RenderBox child = firstChild;
      while (child != null) {
        final int flex = _getFlexGrow(child);
        totalFlexGrow += flex;
        if (flex > 0) {
          final double flexFraction = childSize(child, extent) / _getFlexGrow(child);
          maxFlexFractionSoFar = math.max(maxFlexFractionSoFar, flexFraction);
        } else {
          inflexibleSpace += childSize(child, extent);
        }
        final RenderFlexParentData childParentData = child.parentData;
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
      int totalFlexGrow = 0;
      double inflexibleSpace = 0.0;
      double maxCrossSize = 0.0;
      RenderBox child = firstChild;
      while (child != null) {
        final int flex = _getFlexGrow(child);
        totalFlexGrow += flex;
        double mainSize;
        double crossSize;
        if (flex == 0) {
          switch (_flexDirection) {
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
        final RenderFlexParentData childParentData = child.parentData;
        child = childParentData.nextSibling;
      }

      // Determine the spacePerFlex by allocating the remaining available space.
      // When you're overconstrained spacePerFlex can be negative.
      final double spacePerFlex = math.max(0.0, (availableMainSpace - inflexibleSpace) / totalFlexGrow);

      // Size remaining (flexible) items, find the maximum cross size.
      child = firstChild;
      while (child != null) {
        final int flex = _getFlexGrow(child);
        if (flex > 0) maxCrossSize = math.max(maxCrossSize, childSize(child, spacePerFlex * flex));
        final RenderFlexParentData childParentData = child.parentData;
        child = childParentData.nextSibling;
      }

      return maxCrossSize;
    }
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

  @override
  double computeDistanceToActualBaseline(TextBaseline baseline) {
    if (_flexDirection == FlexDirection.row) return defaultComputeDistanceToHighestActualBaseline(baseline);
    return defaultComputeDistanceToFirstActualBaseline(baseline);
  }

  int _getFlexGrow(RenderBox child) {
    final RenderFlexParentData childParentData = child.parentData;
    return childParentData.flexGrow ?? 0;
  }

  int _getFlexShrink(RenderBox child) {
    final RenderFlexParentData childParentData = child.parentData;
    return childParentData.flexShrink ?? 1;
  }

  String _getFlexBasis(RenderBox child) {
    final RenderFlexParentData childParentData = child.parentData;
    return childParentData.flexBasis ?? 'auto';
  }

  double _getShrinkConstraints(RenderBox child, Map<int, dynamic> childSizeMap, double freeSpace) {
    double totalExtent = 0;
    childSizeMap.forEach((targetId, item) {
      totalExtent += item['flexShrink'] * item['size'];
    });

    int childNodeId;
    if (child is RenderTextBox) {
      childNodeId = child.targetId;
    } else if (child is RenderElementBoundary) {
      childNodeId = child.targetId;
    }
    dynamic current = childSizeMap[childNodeId];
    double currentExtent = current['flexShrink'] * current['size'];

    double minusConstraints = (currentExtent / totalExtent) * freeSpace;
    return minusConstraints;
  }

  BoxSizeType _getChildWidthSizeType(RenderBox child) {
    if (child is RenderTextBox) {
      return child.widthSizeType;
    } else if (child is RenderElementBoundary) {
      return child.widthSizeType;
    }
    return null;
  }

  BoxSizeType _getChildHeightSizeType(RenderBox child) {
    if (child is RenderTextBox) {
      return child.heightSizeType;
    } else if (child is RenderElementBoundary) {
      return child.heightSizeType;
    }
    return null;
  }

  bool _isCrossAxisDefinedSize(RenderBox child) {
    BoxSizeType widthSizeType = _getChildWidthSizeType(child);
    BoxSizeType heightSizeType = _getChildHeightSizeType(child);

    if (style != null) {
      switch (_flexDirection) {
        case FlexDirection.row:
        case FlexDirection.rowReverse:
          return heightSizeType != null && heightSizeType != BoxSizeType.automatic;
        case FlexDirection.column:
        case FlexDirection.columnReverse:
          return widthSizeType != null && widthSizeType != BoxSizeType.automatic;
      }
    }

    return false;
  }

  double _getBaseConstraints(RenderObject child) {
    // set default value
    double minConstraints = 0;
    if (child is RenderTextBox) {
      return minConstraints;
    } else if (child is RenderElementBoundary) {
      String flexBasis = _getFlexBasis(child);

      if (_flexDirection == FlexDirection.row) {
        String width = child.style['width'];
        if (flexBasis == 'auto') {
          if (width != null) {
            minConstraints = CSSLength.toDisplayPortValue(width) ?? 0;
          } else {
            minConstraints = 0;
          }
        } else {
          minConstraints = CSSLength.toDisplayPortValue(flexBasis) ?? 0;
        }
      } else {
        String height = child.style['height'];
        if (flexBasis == 'auto') {
          if (height != null) {
            minConstraints = CSSLength.toDisplayPortValue(height) ?? 0;
          } else {
            minConstraints = 0;
          }
        } else {
          minConstraints = CSSLength.toDisplayPortValue(flexBasis) ?? 0;
        }
      }
    }
    return minConstraints;
  }

  double _getCrossSize(RenderBox child) {
    switch (_flexDirection) {
      case FlexDirection.row:
      case FlexDirection.rowReverse:
        return child.size.height;
      case FlexDirection.columnReverse:
      case FlexDirection.column:
        return child.size.width;
    }
    return null;
  }

  double _getMainSize(RenderBox child) {
    switch (_flexDirection) {
      case FlexDirection.row:
      case FlexDirection.rowReverse:
        return child.size.width;
      case FlexDirection.column:
      case FlexDirection.columnReverse:
        return child.size.height;
    }
    return null;
  }

  // detect should use content size suggestion instead of content-based minimum size
  double getContentBasedMinimumSize(RenderBox child, double maxMainSize) {
    if (child is RenderElementBoundary) {
      CSSStyleDeclaration style = child.style;

      switch (_flexDirection) {
        case FlexDirection.column:
        case FlexDirection.columnReverse:
          if (style.contains('minHeight')) {
            double minHeight = CSSLength.toDisplayPortValue(style['minHeight']);
            return minHeight < maxMainSize ? maxMainSize : minHeight;
          }
          return child.size.height > maxMainSize ? child.size.height : maxMainSize;
        case FlexDirection.row:
        case FlexDirection.rowReverse:
          if (style.contains('minWidth')) {
            double minWidth = CSSLength.toDisplayPortValue(style['minWidth']);
            return minWidth < maxMainSize ? maxMainSize : minWidth;
          }
          return child.size.width > maxMainSize ? child.size.width : maxMainSize;
      }
    }
    return maxMainSize;
  }

  // There are four steps for Flex Container to layout.
  // Step 1: layout positioned child earlyer.
  // Step 2: layout flex-items with No constraints, this step is aiming to collect original box size of every flex-items.
  // Step 3: apply flex-grow, flex-shrink and align-items: stretch to flex-items, this steps will layout twice in order to change flex-items box size.
  // Step 4: apply justify-content, and other flexbox properties, this steps will update flex-items offset and put them into right position.
  @override
  void performLayout() {
    RenderBox child = firstChild;
    Element element = getEventTargetByTargetId<Element>(targetId);
    // Layout positioned element
    while (child != null) {
      final RenderFlexParentData childParentData = child.parentData;
      // Layout placeholder of positioned element(absolute/fixed) in new layer
      if (childParentData.isPositioned) {
        layoutPositionedChild(element, this, child);
      } else if (child is RenderPositionHolder && isPlaceholderPositioned(child)) {
        _layoutChildren(child);
      }

      child = childParentData.nextSibling;
    }
    // Layout non positioned element and its placeholder
    _layoutChildren(null);

    // Set offset of positioned elemen
    child = firstChild;
    while (child != null) {
      final RenderLayoutParentData childParentData = child.parentData;

      if (childParentData.isPositioned) {
        setPositionedChildOffset(this, child, size);
      }
      child = childParentData.nextSibling;
    }
  }

  bool _isChildDisplayNone(RenderObject child) {
    CSSStyleDeclaration style;
    if (child is RenderTextBox) {
      style = child.style;
    } else if (child is RenderElementBoundary) {
      style = child.style;
    }

    if (style == null) return false;

    return style['display'] == 'none';
  }

  bool isPlaceholderPositioned(RenderObject child) {
    if (child is RenderPositionHolder) {
      RenderElementBoundary realDisplayedBox = child.realDisplayedBox;
      CSSPositionType positionType = resolvePositionFromStyle(realDisplayedBox.style);
      if (positionType == CSSPositionType.absolute || positionType == CSSPositionType.fixed) {
        return true;
      }
    }
    return false;
  }

  void _layoutChildren(RenderPositionHolder placeholderChild) {
    double elementWidth = getElementComputedWidth(targetId);
    double elementHeight = getElementComputedHeight(targetId);

    // If no child exists, stop layout.
    if (childCount == 0) {
      Size preferredSize = Size(
        elementWidth ?? 0,
        elementHeight ?? 0,
      );
      contentSize = preferredSize;
      computeBoxSize(contentSize);
      size = constraints.constrain(preferredSize);
      return;
    }

    // Determine used flex factor, size inflexible items, calculate free space.
    int totalFlexGrow = 0;
    bool hasFlexShrink = false;
    int totalChildren = 0;
    assert(constraints != null);

    double maxWidth = 0;
    if (elementWidth != null) {
      maxWidth = elementWidth;
    }

    double maxHeight = 0;
    if (elementHeight != null) {
      maxHeight = elementHeight;
    }

    // maxMainSize still can be updated by content size suggestion and transferred size suggestion
    // https://www.w3.org/TR/css-flexbox-1/#specified-size-suggestion
    // https://www.w3.org/TR/css-flexbox-1/#content-size-suggestion
    double maxMainSize = isHorizontalFlexDirection(_flexDirection) ? maxWidth : maxHeight;
    double maxCrossSize = isHorizontalFlexDirection(_flexDirection) ? maxHeight : maxWidth;
    final bool canFlex = maxMainSize < double.infinity;
    final BoxSizeType mainSizeType = maxMainSize == 0.0 ? BoxSizeType.automatic : BoxSizeType.specified;

    double crossSize = 0.0;
    double allocatedMainSize = 0.0; // Sum of the sizes of the children.
    RenderBox child = placeholderChild ?? firstChild;
    Map<int, dynamic> childSizeMap = {};
    while (child != null) {
      final RenderFlexParentData childParentData = child.parentData;
      // Exclude positioned placeholder renderObject when layout non placeholder object
      // and positioned renderObject
      if (placeholderChild == null && (isPlaceholderPositioned(child) || childParentData.isPositioned)) {
        child = childParentData.nextSibling;
        continue;
      }

      totalChildren++;
      final int flexGrow = _getFlexGrow(child);
      final int flexShrink = _getFlexShrink(child);
      if (flexShrink != 0) {
        hasFlexShrink = true;
      }

      if (flexGrow > 0) {
        assert(() {
          final String identity = isHorizontalFlexDirection(_flexDirection) ? 'row' : 'column';
          final String axis = isHorizontalFlexDirection(_flexDirection) ? 'horizontal' : 'vertical';
          final String dimension = isHorizontalFlexDirection(_flexDirection) ? 'width' : 'height';
          DiagnosticsNode error, message;
          final List<DiagnosticsNode> addendum = <DiagnosticsNode>[];
          if (!canFlex) {
            error = ErrorSummary(
                'RenderFlex children have non-zero flex but incoming $dimension constraints are unbounded.');
            message = ErrorDescription(
                'When a $identity is in a parent that does not provide a finite $dimension constraint, for example '
                'if it is in a $axis scrollable, it will try to shrink-wrap its children along the $axis '
                'axis. Setting a flex on a child (e.g. using Expanded) indicates that the child is to '
                'expand to fill the remaining space in the $axis direction.');
            RenderBox node = this;
            switch (_flexDirection) {
              case FlexDirection.row:
              case FlexDirection.rowReverse:
                while (!node.constraints.hasBoundedWidth && node.parent is RenderBox) node = node.parent;
                if (!node.constraints.hasBoundedWidth) node = null;
                break;
              case FlexDirection.column:
              case FlexDirection.columnReverse:
                while (!node.constraints.hasBoundedHeight && node.parent is RenderBox) node = node.parent;
                if (!node.constraints.hasBoundedHeight) node = null;
                break;
            }
            if (node != null) {
              addendum.add(node.describeForError('The nearest ancestor providing an unbounded width constraint is'));
            }
            addendum.add(ErrorHint('See also: https://flutter.dev/layout/'));
          } else {
            return true;
          }
          throw FlutterError.fromParts(<DiagnosticsNode>[
            error,
            message,
            ErrorDescription(
                'These two directives are mutually exclusive. If a parent is to shrink-wrap its child, the child '
                'cannot simultaneously expand to fit its parent.'),
            ErrorHint('Consider setting mainAxisSize to MainAxisSize.min and using FlexFit.loose fits for the flexible '
                'children (using Flexible rather than Expanded). This will allow the flexible children '
                'to size themselves to less than the infinite remaining space they would otherwise be '
                'forced to take, and then will cause the RenderFlex to shrink-wrap the children '
                'rather than expanding to fit the maximum constraints provided by the parent.'),
            ErrorDescription(
                'If this message did not help you determine the problem, consider using debugDumpRenderTree():\n'
                '  https://flutter.dev/debugging/#rendering-layer\n'
                '  http://api.flutter.dev/flutter/rendering/debugDumpRenderTree.html'),
            describeForError('The affected RenderFlex is', style: DiagnosticsTreeStyle.errorProperty),
            DiagnosticsProperty<dynamic>('The creator information is set to', debugCreator,
                style: DiagnosticsTreeStyle.errorProperty)
          ]
            ..addAll(addendum)
            ..add(ErrorDescription(
                'If none of the above helps enough to fix this problem, please don\'t hesitate to file a bug:\n'
                '  https://github.com/flutter/flutter/issues/new?template=BUG.md')));
        }());
        totalFlexGrow += childParentData.flexGrow;
      }

      double baseConstraints = _getBaseConstraints(child);
      BoxConstraints innerConstraints;

      if (isHorizontalFlexDirection(_flexDirection)) {
        innerConstraints = BoxConstraints(minWidth: baseConstraints);
      } else {
        innerConstraints = BoxConstraints(minHeight: baseConstraints);
      }

      child.layout(innerConstraints, parentUsesSize: true);
      double childMainSize = _getMainSize(child);

      // get minimum content based size
      // https://www.w3.org/TR/css-flexbox-1/#min-size-auto
      maxMainSize = getContentBasedMinimumSize(child, maxMainSize);

      allocatedMainSize += childMainSize;
      crossSize = math.max(crossSize, _getCrossSize(child));

      int childNodeId;
      if (child is RenderTextBox) {
        childNodeId = child.targetId;
      } else if (child is RenderElementBoundary) {
        childNodeId = child.targetId;
      }

      childSizeMap[childNodeId] = {
        'size': _getMainSize(child),
        'flexShrink': _getFlexShrink(child),
      };

      assert(child.parentData == childParentData);

      // Only layout placeholder renderObject child
      child = placeholderChild == null ? childParentData.nextSibling : null;
    }

    // Distribute free space to flexible children, and determine baseline.
    final double freeMainAxisSpace =
        mainSizeType == BoxSizeType.automatic ? 0 : (canFlex ? maxMainSize : 0.0) - allocatedMainSize;
    bool isFlexGrow = freeMainAxisSpace >= 0 && totalFlexGrow > 0;
    bool isFlexShrink = freeMainAxisSpace < 0 && hasFlexShrink;
    if (isFlexGrow || isFlexShrink || alignItems == AlignItems.stretch && placeholderChild == null) {
      // Reset total children size to zero if need to shrink or grow
      allocatedMainSize = 0;
      final double spacePerFlex = canFlex && totalFlexGrow > 0 ? (freeMainAxisSpace / totalFlexGrow) : double.nan;
      child = placeholderChild != null ? placeholderChild : firstChild;
      while (child != null) {
        final RenderFlexParentData childParentData = child.parentData;
        // Exclude positioned placeholder renderObject when layout non placeholder object
        // and positioned renderObject
        if (placeholderChild == null && (isPlaceholderPositioned(child) || childParentData.isPositioned)) {
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

        if (isFlexGrow && freeMainAxisSpace >= 0) {
          final int flexGrow = _getFlexGrow(child);
          final double mainSize = _getMainSize(child);
          maxChildExtent = canFlex ? mainSize + spacePerFlex * flexGrow : double.infinity;

          double baseConstraints = _getBaseConstraints(child);
          // get the maximum child size between baseConstraints and maxChildExtent.
          maxChildExtent = math.max(baseConstraints, maxChildExtent);
          minChildExtent = maxChildExtent;
        } else if (isFlexShrink) {
          int childNodeId;
          if (child is RenderTextBox) {
            childNodeId = child.targetId;
          } else if (child is RenderElementBoundary) {
            childNodeId = child.targetId;
          }

          // Skip RenderPlaceHolder child
          if (childNodeId == null) {
            child = childParentData.nextSibling;
            continue;
          }

          double shrinkValue = _getShrinkConstraints(child, childSizeMap, freeMainAxisSpace);

          dynamic current = childSizeMap[childNodeId];
          double computedSize = current['size'] + shrinkValue;

          // if shrink size is lower than child's min-content, should reset to min-content size
          // @TODO no proper way to get real min-content of child element.
          if (mainSizeType == BoxSizeType.automatic) {
            if (isHorizontalFlexDirection(flexDirection) &&
                computedSize < child.size.width &&
                _getChildWidthSizeType(child) == BoxSizeType.automatic) {
              computedSize = child.size.width;
            } else if (isVerticalFlexDirection(flexDirection) &&
                computedSize < child.size.height &&
                _getChildHeightSizeType(child) == BoxSizeType.automatic) {
              computedSize = child.size.height;
            }
          }

          maxChildExtent = minChildExtent = computedSize;
        } else {
          maxChildExtent = minChildExtent = _getMainSize(child);
        }

        BoxConstraints innerConstraints;
        // @TODO: minChildExtent.isNegative
        if (alignItems == AlignItems.stretch) {
          switch (_flexDirection) {
            case FlexDirection.row:
            case FlexDirection.rowReverse:
              double minMainAxisSize = minChildExtent ?? child.size.width;
              double maxMainAxisSize = maxChildExtent ?? double.infinity;
              double minCrossAxisSize;
              double maxCrossAxisSize;

              // if child have predefined size
              if (_isCrossAxisDefinedSize(child)) {
                if (child.hasSize) {
                  BoxSizeType sizeType = _getChildHeightSizeType(child);

                  // child have predefined height, use previous layout height.
                  if (sizeType == BoxSizeType.specified) {
                    // for empty child width, maybe it's unloaded image, set constraints range.
                    if (child.size.isEmpty) {
                      minCrossAxisSize = 0.0;
                      maxCrossAxisSize = constraints.maxHeight;
                    } else {
                      minCrossAxisSize = child.size.height;
                      maxCrossAxisSize = child.size.height;
                    }
                  } else {
                    // expand child's height to constraints.maxHeight;
                    minCrossAxisSize = constraints.maxHeight;
                    maxCrossAxisSize = constraints.maxHeight;
                  }
                } else {
                  // child is't layout, so set minHeight
                  minCrossAxisSize = maxCrossSize;
                  maxCrossSize = double.infinity;
                }
              } else if (child is! RenderTextBox) {
                minCrossAxisSize = maxCrossSize;
                maxCrossAxisSize = math.max(maxCrossSize, constraints.maxHeight);
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
              double mainAxisMinSize = minChildExtent ?? child.size.height;
              double mainAxisMaxSize = maxChildExtent ?? double.infinity;
              double minCrossAxisSize;
              double maxCrossAxisSize;

              // if child have predefined size
              if (_isCrossAxisDefinedSize(child)) {
                if (child.hasSize) {
                  BoxSizeType sizeType = _getChildWidthSizeType(child);

                  // child have predefined width, use previous layout width.
                  if (sizeType == BoxSizeType.specified) {
                    // for empty child width, maybe it's unloaded image, set constraints range.
                    if (child.size.isEmpty) {
                      minCrossAxisSize = 0.0;
                      maxCrossAxisSize = constraints.maxWidth;
                    } else {
                      minCrossAxisSize = child.size.width;
                      maxCrossAxisSize = child.size.width;
                    }
                  } else {
                    // expand child's height to constraints.maxWidth;
                    minCrossAxisSize = constraints.maxWidth;
                    maxCrossAxisSize = constraints.maxWidth;
                  }
                } else {
                  // child is't layout, so set minHeight
                  minCrossAxisSize = maxCrossSize;
                  maxCrossSize = double.infinity;
                }
              } else if (child is! RenderTextBox) {
                // only scretch ElementBox, not TextBox.
                minCrossAxisSize = maxCrossSize;
                maxCrossAxisSize = math.max(maxCrossSize, constraints.maxWidth);
              } else {
                // for RenderTextBox, there are no cross Axis constraints.
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
          switch (_flexDirection) {
            case FlexDirection.row:
            case FlexDirection.rowReverse:
              innerConstraints =
                  BoxConstraints(minWidth: minChildExtent, maxWidth: maxChildExtent, maxHeight: constraints.maxHeight);
              break;
            case FlexDirection.column:
            case FlexDirection.columnReverse:
              innerConstraints =
                  BoxConstraints(maxWidth: constraints.maxWidth, minHeight: minChildExtent, maxHeight: maxChildExtent);
              break;
          }
        }
        child.layout(innerConstraints, parentUsesSize: true);
        final double childSize = _getMainSize(child);
        allocatedMainSize += childSize;
        crossSize = math.max(crossSize, _getCrossSize(child));
        // Only layout placeholder renderObject child
        child = childParentData.nextSibling;
      }
    }

    // Align items along the main axis.
    final double idealMainSize = mainSizeType != BoxSizeType.automatic ? maxMainSize : allocatedMainSize;

    // final double idealMainSize = mainAxisSize;
    double actualSize;
    double actualSizeDelta;

    // Get layout width from children's width by flex axis
    double constraintWidth = isHorizontalFlexDirection(_flexDirection) ? idealMainSize : crossSize;
    // Get max of element's width and children's width if element's width exists
    if (elementWidth != null) {
      constraintWidth = math.max(constraintWidth, elementWidth);
    }

    // Get layout height from children's height by flex axis
    double constraintHeight = isHorizontalFlexDirection(_flexDirection) ? crossSize : idealMainSize;
    // Get max of element's height and children's height if element's height exists
    if (elementHeight != null) {
      constraintHeight = math.max(constraintHeight, elementHeight);
    }

    switch (_flexDirection) {
      case FlexDirection.row:
      case FlexDirection.rowReverse:
        contentSize = constraints
            .constrain(Size(math.max(constraintWidth, idealMainSize), constraints.constrainHeight(constraintHeight)));
        computeBoxSize(contentSize);
        actualSize = size.width;
        crossSize = size.height;
        break;
      case FlexDirection.column:
      case FlexDirection.columnReverse:
        contentSize = constraints
            .constrain(Size(math.max(constraintWidth, crossSize), constraints.constrainHeight(constraintHeight)));
        computeBoxSize(contentSize);
        actualSize = size.height;
        crossSize = size.width;
        break;
    }
    actualSizeDelta = actualSize - allocatedMainSize;
    _overflow = math.max(0.0, -actualSizeDelta);
    final double remainingSpace = math.max(0.0, actualSizeDelta);
    double leadingSpace;
    double betweenSpace;

    // flipMainAxis is used to decide whether to lay out left-to-right/top-to-bottom (false), or
    // right-to-left/bottom-to-top (true). The _startIsTopLeft will return null if there's only
    // one child and the relevant direction is null, in which case we arbitrarily decide not to
    // flip, but that doesn't have any detectable effect.
    final bool flipMainAxis = !(_startIsTopLeft(flexDirection) ?? true);
    switch (justifyContent) {
      case JustifyContent.flexStart:
      case JustifyContent.start:
        leadingSpace = 0.0;
        betweenSpace = 0.0;
        break;
      case JustifyContent.end:
      case JustifyContent.flexEnd:
        leadingSpace = remainingSpace;
        betweenSpace = 0.0;
        break;
      case JustifyContent.center:
        leadingSpace = remainingSpace / 2.0;
        betweenSpace = 0.0;
        break;
      case JustifyContent.spaceBetween:
        leadingSpace = 0.0;
        betweenSpace = totalChildren > 1 ? remainingSpace / (totalChildren - 1) : 0.0;
        break;
      case JustifyContent.spaceAround:
        betweenSpace = totalChildren > 0 ? remainingSpace / totalChildren : 0.0;
        leadingSpace = betweenSpace / 2.0;
        break;
      case JustifyContent.spaceEvenly:
        betweenSpace = totalChildren > 0 ? remainingSpace / (totalChildren + 1) : 0.0;
        leadingSpace = betweenSpace;
        break;
      default:
    }

    // Position elements
    double childMainPosition = flipMainAxis ? actualSize - leadingSpace : leadingSpace;
    child = placeholderChild != null ? placeholderChild : firstChild;
    while (child != null) {
      final RenderFlexParentData childParentData = child.parentData;
      // Exclude positioned placeholder renderObject when layout non placeholder object
      // and positioned renderObject
      if (placeholderChild == null && (isPlaceholderPositioned(child) || childParentData.isPositioned)) {
        child = childParentData.nextSibling;
        continue;
      }
      double childCrossPosition;
      switch (alignItems) {
        case AlignItems.start:
        case AlignItems.flexStart:
        case AlignItems.flexEnd:
        case AlignItems.end:
          childCrossPosition = _startIsTopLeft(flipDirection(flexDirection)) ==
                  (alignItems == AlignItems.start || alignItems == AlignItems.flexStart)
              ? 0.0
              : crossSize - _getCrossSize(child);
          break;
        case AlignItems.center:
          childCrossPosition = crossSize / 2.0 - _getCrossSize(child) / 2.0;
          break;
        case AlignItems.stretch:
          childCrossPosition = 0.0;
          break;
        case AlignItems.baseline:
          childCrossPosition = 0.0;
          break;
//        temporary not support baseline
//        case AlignItems.baseline:
//          childCrossPosition = 0.0;
//          if (_flexDirection == FlexDirection.row) {
//            assert(textBaseline != null);
//            final double distance = child.getDistanceToBaseline(textBaseline, onlyReal: true);
//            if (distance != null) childCrossPosition = maxBaselineDistance - distance;
//          }
//          break;
        default:
          break;
      }
      if (flipMainAxis) childMainPosition -= _getMainSize(child);
      Offset relativeOffset;
      switch (_flexDirection) {
        case FlexDirection.rowReverse:
        case FlexDirection.row:
          relativeOffset = Offset(childMainPosition, childCrossPosition);
          break;
        case FlexDirection.columnReverse:
        case FlexDirection.column:
          relativeOffset = Offset(childCrossPosition, childMainPosition);
          break;
      }

      CSSStyleDeclaration childStyle;
      if (child is RenderTextBox) {
        childStyle = getEventTargetByTargetId<Element>(targetId)?.style;
      } else if (child is RenderElementBoundary) {
        int childNodeId = child.targetId;
        childStyle = getEventTargetByTargetId<Element>(childNodeId)?.style;
      }

      /// Apply position relative offset change
      applyRelativeOffset(relativeOffset, child, childStyle);

      if (flipMainAxis) {
        childMainPosition -= betweenSpace;
      } else {
        childMainPosition += _getMainSize(child) + betweenSpace;
      }
      // Only layout placeholder renderObject child
      child = placeholderChild == null ? childParentData.nextSibling : null;
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (padding != null) {
      offset += getPaddingOffset();
    }

    List<RenderObject> children = getChildrenAsList();
    children.sort((RenderObject prev, RenderObject next) {
      RenderFlexParentData prevParentData = prev.parentData;
      RenderFlexParentData nextParentData = next.parentData;
      // Place positioned element after non positioned element
      if (prevParentData.position == CSSPositionType.static && nextParentData.position != CSSPositionType.static) {
        return -1;
      }
      if (prevParentData.position != CSSPositionType.static && nextParentData.position == CSSPositionType.static) {
        return 1;
      }
      // z-index applies to flex-item ignoring position property
      int prevZIndex = prevParentData.zIndex ?? 0;
      int nextZIndex = nextParentData.zIndex ?? 0;
      return prevZIndex - nextZIndex;
    });

    for (var child in children) {
      // Don't paint placeholder of positioned element
      if (child is! RenderPositionHolder) {
        final RenderFlexParentData childParentData = child.parentData;
        context.paintChild(child, childParentData.offset + offset);
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
    properties.add(DiagnosticsProperty<FlexDirection>('flexDirection', flexDirection));
    properties.add(DiagnosticsProperty<JustifyContent>('justifyContent', justifyContent));
    properties.add(DiagnosticsProperty<AlignItems>('alignItems', alignItems));
    properties.add(DiagnosticsProperty<FlexWrap>('flexWrap', flexWrap));
    properties.add(DiagnosticsProperty('padding', padding));
  }

  RenderFlexParentData getPositionParentDataFromStyle(CSSStyleDeclaration style) {
    RenderFlexParentData parentData = RenderFlexParentData();
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
    parentData.zIndex = CSSLength.toInt(style['zIndex']);

    parentData.isPositioned = positionType == CSSPositionType.absolute || positionType == CSSPositionType.fixed;

    return parentData;
  }
}

class RenderFlexItem extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, RenderFlexParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, RenderFlexParentData>,
        DebugOverflowIndicatorMixin {
  RenderFlexItem({RenderBox child}) {
    add(child);
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! RenderFlexParentData) {
      RenderFlexParentData flexParentData = RenderFlexParentData();
      child.parentData = flexParentData;
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }

  @override
  void performLayout() {
    RenderBox child = firstChild;
    if (child != null) {
      BoxConstraints innerConstraint = constraints;
      child.layout(innerConstraint, parentUsesSize: true);
      size = child.size;
    } else {
      size = Size.zero;
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }
}
