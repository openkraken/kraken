import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:kraken/rendering.dart';
import 'package:kraken/element.dart';
import 'package:kraken/css.dart';

class _RunMetrics {
  _RunMetrics(
    this.mainAxisExtent,
    this.crossAxisExtent,
    this.childCount,
    this.totalFlexGrow,
    this.totalFlexShrink,
    this.baselineExtent,
  );

  final double mainAxisExtent;
  final double crossAxisExtent;
  final int childCount;
  final double totalFlexGrow;
  final double totalFlexShrink;
  final double baselineExtent;
}

class RenderFlexParentData extends RenderLayoutParentData {
  /// Flex grow
  double flexGrow;

  /// Flex shrink
  double flexShrink;

  /// Flex basis
  String flexBasis;

  /// Align self
  AlignSelf alignSelf = AlignSelf.auto;

  @override
  String toString() =>
      '${super.toString()}; flexGrow=$flexGrow; flexShrink=$flexShrink; flexBasis=$flexBasis; alignSelf=$alignSelf';
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
    FlexDirection flexDirection = FlexDirection.row,
    FlexWrap flexWrap = FlexWrap.nowrap,
    JustifyContent justifyContent = JustifyContent.flexStart,
    AlignItems alignItems = AlignItems.stretch,
    AlignContent alignContent = AlignContent.stretch,
    int targetId,
    ElementManager elementManager,
    CSSStyleDeclaration style,
  })  : assert(flexDirection != null),
        assert(flexWrap != null),
        assert(justifyContent != null),
        assert(alignItems != null),
        assert(alignContent != null),
        _flexDirection = flexDirection,
        _flexWrap = flexWrap,
        _justifyContent = justifyContent,
        _alignContent = alignContent,
        _alignItems = alignItems,
        super(targetId: targetId, style: style, elementManager: elementManager) {
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

  AlignContent get alignContent => _alignContent;
  AlignContent _alignContent;
  set alignContent(AlignContent value) {
    assert(value != null);
    if (_alignContent == value) return;
    _alignContent = value;
    markNeedsLayout();
  }

  // Set during layout if overflow occurred on the main axis.
  double _overflow;

  // Check whether any meaningful overflow is present. Values below an epsilon
  // are treated as not overflowing.
  bool get _hasOverflow => _overflow > precisionErrorTolerance;

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! RenderFlexParentData) {
      child.parentData = RenderFlexParentData();
    }
    if (child is RenderBoxModel) {
      child.parentData = CSSPositionedLayout.getPositionParentData(child.style, child.parentData);
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
        final double flex = _getFlexGrow(child);
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
        final double flex = _getFlexGrow(child);
        if (flex > 0) maxCrossSize = math.max(maxCrossSize, childSize(child, spacePerFlex * flex));
        final RenderFlexParentData childParentData = child.parentData;
        child = childParentData.nextSibling;
      }

      return maxCrossSize;
    }
  }

  /// Get start/end padding in the main axis according to flex direction
  double flowAwareMainAxisPadding({bool isEnd = false}) {
    if (CSSFlex.isHorizontalFlexDirection(flexDirection)) {
      if (_startIsTopLeft(flexDirection)) {
        return isEnd ? paddingRight : paddingLeft;
      } else {
        return isEnd ? paddingLeft : paddingRight;
      }
    } else {
      if (_startIsTopLeft(flexDirection)) {
        return isEnd ? paddingBottom : paddingTop;
      } else {
        return isEnd ? paddingTop : paddingBottom;
      }
    }
  }

  /// Get start/end padding in the cross axis according to flex direction
  double flowAwareCrossAxisPadding({bool isEnd = false}) {
    if (CSSFlex.isHorizontalFlexDirection(flexDirection)) {
      if (_startIsTopLeft(flexDirection)) {
        return isEnd ? paddingBottom : paddingTop;
      } else {
        return isEnd ? paddingTop : paddingBottom;
      }
    } else {
      if (_startIsTopLeft(flexDirection)) {
        return isEnd ? paddingRight : paddingLeft;
      } else {
        return isEnd ? paddingLeft : paddingRight;
      }
    }
  }

  /// Get start/end border in the main axis according to flex direction
  double flowAwareMainAxisBorder({bool isEnd = false}) {
    if (CSSFlex.isHorizontalFlexDirection(flexDirection)) {
      if (_startIsTopLeft(flexDirection)) {
        return isEnd ? borderRight : borderLeft;
      } else {
        return isEnd ? borderLeft : borderRight;
      }
    } else {
      if (_startIsTopLeft(flexDirection)) {
        return isEnd ? borderBottom : borderTop;
      } else {
        return isEnd ? borderTop : borderBottom;
      }
    }
  }

  /// Get start/end border in the cross axis according to flex direction
  double flowAwareCrossAxisBorder({bool isEnd = false}) {
    if (CSSFlex.isHorizontalFlexDirection(flexDirection)) {
      if (_startIsTopLeft(flexDirection)) {
        return isEnd ? borderBottom : borderTop;
      } else {
        return isEnd ? borderTop : borderBottom;
      }
    } else {
      if (_startIsTopLeft(flexDirection)) {
        return isEnd ? borderRight : borderLeft;
      } else {
        return isEnd ? borderLeft : borderRight;
      }
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

    if (CSSFlex.isHorizontalFlexDirection(flexDirection)) {
      if (_startIsTopLeft(flexDirection)) {
        return isEnd ? childRenderBoxModel.marginRight : childRenderBoxModel.marginLeft;
      } else {
        return isEnd ? childRenderBoxModel.marginLeft : childRenderBoxModel.marginRight;
      }
    } else {
      if (_startIsTopLeft(flexDirection)) {
        return isEnd ? childRenderBoxModel.marginBottom : childRenderBoxModel.marginTop;
      } else {
        return isEnd ? childRenderBoxModel.marginTop : childRenderBoxModel.marginBottom;
      }
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
    if (CSSFlex.isHorizontalFlexDirection(flexDirection)) {
      if (_startIsTopLeft(flexDirection)) {
        return isEnd ? childRenderBoxModel.marginBottom : childRenderBoxModel.marginTop;
      } else {
        return isEnd ? childRenderBoxModel.marginTop : childRenderBoxModel.marginBottom;
      }
    } else {
      if (_startIsTopLeft(flexDirection)) {
        return isEnd ? childRenderBoxModel.marginRight : childRenderBoxModel.marginLeft;
      } else {
        return isEnd ? childRenderBoxModel.marginLeft : childRenderBoxModel.marginRight;
      }
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
    // Flex grow has no effect on placeholder of positioned element
    if (child is RenderPositionHolder) {
      return 0;
    }
    final RenderFlexParentData childParentData = child.parentData;
    return childParentData.flexGrow ?? 0;
  }

  double _getFlexShrink(RenderBox child) {
    // Flex shrink has no effect on placeholder of positioned element
    if (child is RenderPositionHolder) {
      return 0;
    }
    final RenderFlexParentData childParentData = child.parentData;
    return childParentData.flexShrink ?? 1;
  }

  String _getFlexBasis(RenderBox child) {
    // Flex basis has no effect on placeholder of positioned element
    if (child is RenderPositionHolder) {
      return AUTO;
    }
    final RenderFlexParentData childParentData = child.parentData;
    return childParentData.flexBasis ?? AUTO;
  }

  double _getShrinkConstraints(RenderBox child, Map<int, dynamic> childSizeMap, double freeSpace) {
    double totalExtent = 0;
    childSizeMap.forEach((targetId, item) {
      totalExtent += item['flexShrink'] * item['size'];
    });

    int childNodeId;
    if (child is RenderTextBox) {
      childNodeId = child.targetId;
    } else if (child is RenderBoxModel) {
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
      if (CSSFlex.isHorizontalFlexDirection(flexDirection)) {
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
      marginHorizontal = childRenderBoxModel.marginLeft + childRenderBoxModel.marginRight;
      marginVertical = childRenderBoxModel.marginTop + childRenderBoxModel.marginBottom;
    }

    Size childSize = _getChildSize(child);
    if (CSSFlex.isHorizontalFlexDirection(flexDirection)) {
      return childSize.height + marginVertical;
    } else {
      return childSize.width + marginHorizontal;
    }
  }

  bool _isChildMainAxisClip(RenderBoxModel renderBoxModel) {
    if (CSSFlex.isHorizontalFlexDirection(flexDirection)) {
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
      marginHorizontal = childRenderBoxModel.marginLeft + childRenderBoxModel.marginRight;
      marginVertical = childRenderBoxModel.marginTop + childRenderBoxModel.marginBottom;
    }

    double baseSize = _getMainSize(child);
    if (CSSFlex.isHorizontalFlexDirection(flexDirection)) {
      return baseSize + marginHorizontal;
    } else {
      return baseSize + marginVertical;
    }
  }

  BoxConstraints _getBaseConstraints(RenderObject child) {
    double minWidth = 0;
    double maxWidth = double.infinity;
    double minHeight = 0;
    double maxHeight = double.infinity;

    if (child is RenderBoxModel) {

      String flexBasis = _getFlexBasis(child);
      double baseSize;
      // @FIXME when flex-basis is smaller than content width, it will not take effects
      if (flexBasis != AUTO) {
        baseSize = CSSLength.toDisplayPortValue(flexBasis) ?? 0;
      }
      if (CSSFlex.isHorizontalFlexDirection(flexDirection)) {
        minWidth = child.minWidth != null ? child.minWidth : 0;
        maxWidth = child.maxWidth != null ? child.maxWidth : double.infinity;

        if (flexBasis == AUTO) {
          baseSize = child.width;
        }
        if (baseSize != null) {
          if (child.minWidth != null && baseSize < child.minWidth) {
            baseSize = child.minWidth;
          } else if (child.maxWidth != null && baseSize > child.maxWidth) {
            baseSize = child.maxWidth;
          }
          minWidth = maxWidth = baseSize;
        }
      } else {
        minHeight = child.minHeight != null ? child.minHeight : 0;
        maxHeight = child.maxHeight != null ? child.maxHeight : double.infinity;

        if (flexBasis == AUTO) {
          baseSize = child.height;
        }
        if (baseSize != null) {
          if (child.minHeight != null && baseSize < child.minHeight) {
            baseSize = child.minHeight;
          } else if (child.maxHeight != null && baseSize > child.maxHeight) {
            baseSize = child.maxHeight;
          }
          minHeight = maxHeight = baseSize;
        }
      }
    }

    if (CSSFlex.isHorizontalFlexDirection(flexDirection)) {
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
    double baseSize = null;
    if (child is RenderTextBox) {
      return baseSize;
    } else if (child is RenderBoxModel) {
      String flexBasis = _getFlexBasis(child);

      if (CSSFlex.isHorizontalFlexDirection(flexDirection)) {
        String width = child.style[WIDTH];
        if (flexBasis == AUTO) {
          if (width != null) {
            baseSize = CSSLength.toDisplayPortValue(width) ?? 0;
          }
        } else {
          baseSize = CSSLength.toDisplayPortValue(flexBasis) ?? 0;
        }
      } else {
        String height = child.style[HEIGHT];
        if (flexBasis == AUTO) {
          if (height != '') {
            baseSize = CSSLength.toDisplayPortValue(height) ?? 0;
          }
        } else {
          baseSize = CSSLength.toDisplayPortValue(flexBasis) ?? 0;
        }
      }
    }
    return baseSize;
  }

  double _getMainSize(RenderBox child) {
    Size childSize = _getChildSize(child);
    if (CSSFlex.isHorizontalFlexDirection(flexDirection)) {
      return childSize.width;
    } else {
      return childSize.height;
    }
  }

  double _getCrossSize(RenderBox child) {
    Size childSize = _getChildSize(child);
    if (CSSFlex.isHorizontalFlexDirection(flexDirection)) {
      return childSize.height;
    } else {
      return childSize.width;
    }
  }

  @override
  void performLayout() {
    print('layout flex =============== $targetId ${style['backgroundColor']}');

    if (display == CSSDisplay.none) {
      size = constraints.smallest;
      return;
    }

    beforeLayout();
    RenderBox child = firstChild;
    Element element = elementManager.getEventTargetByTargetId<Element>(targetId);
    // Layout positioned element
    while (child != null) {
      final RenderFlexParentData childParentData = child.parentData;
      // Layout placeholder of positioned element(absolute/fixed) in new layer
      if (childParentData.isPositioned) {
        CSSPositionedLayout.layoutPositionedChild(element, this, child);
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
        CSSPositionedLayout.applyPositionedChildOffset(this, child, size, borderEdge);

        setMaximumScrollableSizeForPositionedChild(childParentData, child.boxSize);
      }
      child = childParentData.nextSibling;
    }

    didLayout();
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
      CSSPositionType positionType = CSSPositionedLayout.parsePositionType(realDisplayedBox.style[POSITION]);
      if (positionType == CSSPositionType.absolute || positionType == CSSPositionType.fixed) {
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
  void _layoutChildren(RenderPositionHolder placeholderChild) {
    final double logicalWidth = RenderBoxModel.getLogicalWidth(this);
    final double logicalHeight = RenderBoxModel.getLogicalHeight(this);

    CSSDisplay realDisplay = CSSSizing.getElementRealDisplayValue(targetId, elementManager);

    /// If no child exists, stop layout.
    if (childCount == 0) {
      double constraintWidth = logicalWidth ?? 0;
      double constraintHeight = logicalHeight ?? 0;

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
    // Flex item size map
    Map<int, dynamic> childSizeMap = {};

    /// Stage 1: Layout children in flow order to calculate flex lines
    _layoutByFlexLine(
      runMetrics,
      placeholderChild,
      childSizeMap,
      containerSizeMap,
      logicalWidth,
      logicalHeight,
      maxScrollableWidthMap,
      maxScrollableHeightMap,
    );

    /// If no non positioned child exists, stop layout
    if (runMetrics.length == 0) {
      Size preferredSize = Size(
        logicalWidth ?? 0,
        logicalHeight ?? 0,
      );
      setMaxScrollableSize(preferredSize.width, preferredSize.height);
      size = getBoxSize(preferredSize);
      return;
    }

    double containerCrossAxisExtent = 0.0;

    bool isVerticalDirection = CSSFlex.isVerticalFlexDirection(_flexDirection);
    if (isVerticalDirection) {
      containerCrossAxisExtent = logicalWidth ?? 0;
    } else {
      containerCrossAxisExtent = logicalHeight ?? 0;
    }

    /// Calculate leading and between space between flex lines
    final double crossAxisFreeSpace = math.max(0.0, containerCrossAxisExtent - containerSizeMap['cross']);
    final int runCount = runMetrics.length;
    double runLeadingSpace = 0.0;
    double runBetweenSpace = 0.0;
    switch (alignContent) {
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
        runBetweenSpace = runCount > 1 ? crossAxisFreeSpace / (runCount - 1) : 0.0;
        break;
      case AlignContent.spaceAround:
        runBetweenSpace = crossAxisFreeSpace / runCount;
        runLeadingSpace = runBetweenSpace / 2.0;
        break;
      case AlignContent.spaceEvenly:
        runBetweenSpace = crossAxisFreeSpace / (runCount + 1);
        runLeadingSpace = runBetweenSpace;
        break;
      case AlignContent.stretch:
        runBetweenSpace = crossAxisFreeSpace / runCount;
        break;
    }

    /// Stage 2: Layout flex item second time based on flex factor and actual size
    _relayoutByFlexFactor(
      runMetrics,
      runBetweenSpace,
      placeholderChild,
      logicalWidth,
      logicalHeight,
      childSizeMap,
      containerSizeMap,
      maxScrollableWidthMap,
      maxScrollableHeightMap,
    );

    /// Stage 3: Set flex container size according to children size
    _setContainerSize(
      runMetrics,
      containerSizeMap,
      logicalWidth,
      logicalHeight,
      maxScrollableWidthMap,
      maxScrollableHeightMap,
    );

    /// Stage 4: Set children offset based on flex alignment properties
    _alignChildren(
      runMetrics,
      runBetweenSpace,
      runLeadingSpace,
      placeholderChild,
      childSizeMap,
      containerSizeMap,
      contentSize,
      maxScrollableWidthMap,
      maxScrollableHeightMap,
    );
  }

  /// 1. Layout children in flow order to calculate flex lines according to its constaints and flex-wrap property
  void _layoutByFlexLine(
    List<_RunMetrics> runMetrics,
    RenderPositionHolder placeholderChild,
    Map<int, dynamic> childSizeMap,
    Map<String, double> containerSizeMap,
    double logicalWidth,
    double logicalHeight,
    Map<int, double> maxScrollableWidthMap,
    Map<int, double> maxScrollableHeightMap,
  ) {
    double mainAxisExtent = 0.0;
    double crossAxisExtent = 0.0;
    double runMainAxisExtent = 0.0;
    double runCrossAxisExtent = 0.0;
    int runChildCount = 0;

    // Determine used flex factor, size inflexible items, calculate free space.
    double totalFlexGrow = 0;
    double totalFlexShrink = 0;

    double maxSizeAboveBaseline = 0;
    double maxSizeBelowBaseline = 0;

    double heightLimit = logicalHeight != null ? logicalHeight : 0;
    // Max length of each flex line
    double flexLineLimit = 0.0;
    if (logicalWidth != null) {
      flexLineLimit = logicalWidth;
    } else {
      flexLineLimit = CSSSizing.getElementComputedMaxWidth(this, targetId, elementManager);
    }

    RenderBox child = placeholderChild ?? firstChild;

    while (child != null) {
      final RenderFlexParentData childParentData = child.parentData;
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
      BoxConstraints baseConstraints = _getBaseConstraints(child);

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
      } else if (CSSFlex.isHorizontalFlexDirection(_flexDirection)) {
        double maxCrossAxisSize;
        // Calculate max height constraints
        if (heightSizeType == BoxSizeType.specified && childStyle[HEIGHT] != '') {
          maxCrossAxisSize = CSSLength.toDisplayPortValue(childStyle[HEIGHT]);
        } else {
          // Child in flex line expand automatic when height is not specified
          if (flexWrap == FlexWrap.wrap || flexWrap == FlexWrap.wrapReverse) {
            maxCrossAxisSize = double.infinity;
          } else if (child is RenderTextBox) {
            maxCrossAxisSize = double.infinity;
          } else {
            // Should substract margin when layout child
            double marginVertical = 0;
            if (child is RenderBoxModel) {
              RenderBoxModel childRenderBoxModel = _getChildRenderBoxModel(child);
              marginVertical = childRenderBoxModel.marginTop + childRenderBoxModel.marginBottom;
            }
            maxCrossAxisSize = logicalHeight != null ? logicalHeight - marginVertical : double.infinity;
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

      // No need to layout child if size is the same as logical size calculated by style
      bool isChildNeedsLayout = true;
      if (child is RenderBoxModel && child.hasSize) {
        double childLogicalWidth = RenderBoxModel.getLogicalWidth(child);
        double childLogicalHeight = RenderBoxModel.getLogicalHeight(child);
        // Always layout child when parent is not laid out yet or child is marked as needsLayout
        if (!hasSize || child.needsLayout) {
          isChildNeedsLayout = true;
        } else {
          Size childOldSize = _getChildSize(child);
          if (childLogicalWidth != null && childLogicalHeight != null &&
            (childOldSize.width != childLogicalWidth ||
            childOldSize.height != childLogicalHeight)) {
            isChildNeedsLayout = true;
          } else {
            isChildNeedsLayout = false;
          }
        }
      }
      if (isChildNeedsLayout) {
        // If width and height can be calculated from style, then its repaintBoundary equals self
        bool parentUsesSize = logicalWidth == null || logicalHeight == null;
        child.layout(childConstraints, parentUsesSize: parentUsesSize);
      }

      double childMainAxisExtent = _getMainAxisExtent(child);
      double childCrossAxisExtent = _getCrossAxisExtent(child);

      Size childSize = _getChildSize(child);
      // update max scrollable size
      if (child is RenderBoxModel) {
        maxScrollableWidthMap[child.targetId] = math.max(child.maxScrollableSize.width, childSize.width);
        maxScrollableHeightMap[child.targetId] = math.max(child.maxScrollableSize.height, childSize.height);
      }

      childSizeMap[childNodeId] = {
        'size': _getMainSize(child),
        'flexShrink': _getFlexShrink(child),
      };
      bool isAxisHorizontalDirection = CSSFlex.isHorizontalFlexDirection(flexDirection);
      double lineLimit = isAxisHorizontalDirection ? flexLineLimit : heightLimit;
      bool isExceedFlexLineLimit = runMainAxisExtent + childMainAxisExtent > lineLimit;

      // calculate flex line
      if ((flexWrap == FlexWrap.wrap || flexWrap == FlexWrap.wrapReverse) &&
        runChildCount > 0 && isExceedFlexLineLimit) {

        mainAxisExtent = math.max(mainAxisExtent, runMainAxisExtent);
        crossAxisExtent += runCrossAxisExtent;

        runMetrics.add(_RunMetrics(
          runMainAxisExtent,
          runCrossAxisExtent,
          runChildCount,
          totalFlexGrow,
          totalFlexShrink,
          maxSizeAboveBaseline,
        ));
        runMainAxisExtent = 0.0;
        runCrossAxisExtent = 0.0;
        maxSizeAboveBaseline = 0.0;
        maxSizeBelowBaseline = 0.0;
        runChildCount = 0;

        totalFlexGrow = 0;
        totalFlexShrink = 0;
      }
      runMainAxisExtent += childMainAxisExtent;
      runCrossAxisExtent = math.max(runCrossAxisExtent, childCrossAxisExtent);

      /// Calculate baseline extent of layout box
      AlignSelf alignSelf = childParentData.alignSelf;
      // Vertical align is only valid for inline box
      if ((alignSelf == AlignSelf.baseline || alignItems == AlignItems.baseline)) {
        // Distance from top to baseline of child
        double childAscent = _getChildAscent(child);
        CSSStyleDeclaration childStyle = _getChildStyle(child);
        double lineHeight = CSSText.getLineHeight(childStyle);

        Size childSize = _getChildSize(child);
        // Leading space between content box and virtual box of child
        double childLeading = 0;
        if (lineHeight != null) {
          childLeading = lineHeight - childSize.height;
        }

        double childMarginTop = 0;
        if (child is RenderBoxModel) {
          RenderBoxModel childRenderBoxModel = _getChildRenderBoxModel(child);
          childMarginTop = childRenderBoxModel.marginTop;
        }
        maxSizeAboveBaseline = math.max(
          childAscent + childLeading / 2,
          maxSizeAboveBaseline,
        );
        maxSizeBelowBaseline = math.max(
          childMarginTop + childSize.height - childAscent + childLeading / 2,
          maxSizeBelowBaseline,
        );
        runCrossAxisExtent = maxSizeAboveBaseline + maxSizeBelowBaseline;
      } else {
        runCrossAxisExtent = math.max(runCrossAxisExtent, childCrossAxisExtent);
      }
      runChildCount += 1;

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

    if (runChildCount > 0) {
      mainAxisExtent = math.max(mainAxisExtent, runMainAxisExtent);
      crossAxisExtent += runCrossAxisExtent;
      runMetrics.add(_RunMetrics(
        runMainAxisExtent,
        runCrossAxisExtent,
        runChildCount,
        totalFlexGrow,
        totalFlexShrink,
        maxSizeAboveBaseline,
      ));

      containerSizeMap['cross'] = crossAxisExtent;
    }
  }

  /// Stage 2: Set size of flex item based on flex factors and min and max constraints and relayout
  ///  https://www.w3.org/TR/css-flexbox-1/#resolve-flexible-lengths
  void _relayoutByFlexFactor(
    List<_RunMetrics> runMetrics,
    double runBetweenSpace,
    RenderPositionHolder placeholderChild,
    double logicalWidth,
    double logicalHeight,
    Map<int, dynamic> childSizeMap,
    Map<String, double> containerSizeMap,
    Map<int, double> maxScrollableWidthMap,
    Map<int, double> maxScrollableHeightMap,
  ) {
    RenderBox child = placeholderChild != null ? placeholderChild : firstChild;

    double widthLimit = logicalWidth != null ? logicalWidth : 0;
    double heightLimit = logicalHeight != null ? logicalHeight : 0;
    double maxMainSize = CSSFlex.isHorizontalFlexDirection(_flexDirection) ? widthLimit : heightLimit;
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
      final BoxSizeType mainSizeType = maxMainSize == 0.0 ? BoxSizeType.automatic : BoxSizeType.specified;

      // Distribute free space to flexible children, and determine baseline.
      final double freeMainAxisSpace = mainSizeType == BoxSizeType.automatic ?
        0 : (canFlex ? maxMainSize : 0.0) - runMainAxisExtent;
      bool isFlexGrow = freeMainAxisSpace >= 0 && totalFlexGrow > 0;
      bool isFlexShrink = freeMainAxisSpace < 0 && totalFlexShrink > 0;

      final double spacePerFlex = canFlex && totalFlexGrow > 0 ? (freeMainAxisSpace / totalFlexGrow) : double.nan;
      while (child != null) {
        final RenderFlexParentData childParentData = child.parentData;

        AlignSelf alignSelf = childParentData.alignSelf;

        // If size exists in align-items direction, stretch not works
        bool isStretchSelfValid = false;
        if (child is RenderBoxModel) {
          isStretchSelfValid = CSSFlex.isHorizontalFlexDirection(flexDirection) ?
            child.height == null : child.width == null;
        }

        // Whether child should be stretched
        bool isStretchSelf = placeholderChild == null && isStretchSelfValid &&
          (alignSelf != AlignSelf.auto ? alignSelf == AlignSelf.stretch : alignItems == AlignItems.stretch);

        // Whether child is positioned placeholder or positioned renderObject
        bool isChildPositioned = placeholderChild == null &&
          (isPlaceholderPositioned(child) || childParentData.isPositioned);

        // Don't need to relayout child in following cases
        // 1. child is placeholder when in layout non placeholder stage
        // 2. child is positioned renderObject, it needs to layout in its special stage
        // 3. child's size don't need to recompute if no flex-grow、flex-shrink or stretch exists
        if (isChildPositioned || (!isFlexGrow && !isFlexShrink && !isStretchSelf)) {
          child = childParentData.nextSibling;
          continue;
        }

        if (childParentData.runIndex != i) break;

        // Whether child should be layout depending on size whether changed
        bool isChildNeedsLayout = true;
        if (child is RenderBoxModel && child.hasSize) {
          double childLogicalWidth = RenderBoxModel.getLogicalWidth(child);
          double childLogicalHeight = RenderBoxModel.getLogicalHeight(child);
          RenderFlexParentData childParentData = child.parentData;

          // Always layout child when parent is not laid out yet or child is marked as needsLayout
          if (!hasSize || child.needsLayout) {
            isChildNeedsLayout = true;
          } else {
            if ((isFlexGrow && childParentData.flexGrow > 0) ||
              (isFlexShrink) && childParentData.flexShrink > 0) {
              isChildNeedsLayout = true;
            } else if (isStretchSelf) {
              Size childOldSize = _getChildSize(child);
              if (childLogicalWidth != null && childLogicalHeight != null &&
                (childOldSize.width != childLogicalWidth ||
                  childOldSize.height != childLogicalHeight)) {
                isChildNeedsLayout = true;
              } else {
                isChildNeedsLayout = false;
              }
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

        if (isFlexGrow && freeMainAxisSpace >= 0) {
          final double flexGrow = _getFlexGrow(child);
          final double mainSize = _getMainSize(child);
          maxChildExtent = canFlex ? mainSize + spacePerFlex * flexGrow
            : double.infinity;

          double baseSize = _getBaseSize(child) ?? 0;
          // get the maximum child size between base size and maxChildExtent.
          minChildExtent = math.max(baseSize, maxChildExtent);
          maxChildExtent = minChildExtent;
        } else if (isFlexShrink) {
          int childNodeId;
          if (child is RenderTextBox) {
            childNodeId = child.targetId;
          } else if (child is RenderBoxModel) {
            childNodeId = child.targetId;
          }

          // Skip RenderPlaceHolder child
          if (childNodeId == null) {
            child = childParentData.nextSibling;
            continue;
          }

          double computedSize;
          dynamic current = childSizeMap[childNodeId];

          // If child's mainAxis have clips, it will create a new format context in it's children's.
          // so we do't need to care about child's size.
          if (child is RenderBoxModel && _isChildMainAxisClip(child)) {
            computedSize = current['size'] + freeMainAxisSpace;
          } else {
            double shrinkValue = _getShrinkConstraints(child, childSizeMap, freeMainAxisSpace);
            computedSize = current['size'] + shrinkValue;

            // if shrink size is lower than child's min-content, should reset to min-content size
            // @TODO no proper way to get real min-content of child element.
            if (CSSFlex.isHorizontalFlexDirection(flexDirection) &&
              computedSize < childSize.width &&
              _getChildWidthSizeType(child) == BoxSizeType.automatic) {
              computedSize = childSize.width;
            } else if (CSSFlex.isVerticalFlexDirection(flexDirection) &&
              computedSize < childSize.height &&
              _getChildHeightSizeType(child) == BoxSizeType.automatic) {
              computedSize = childSize.height;
            }
          }

          maxChildExtent = minChildExtent = computedSize;
        } else {
          maxChildExtent = minChildExtent = _getMainSize(child);
        }

        BoxConstraints innerConstraints;
        if (isStretchSelf) {
          switch (_flexDirection) {
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
                  // Stretch child height to flex line' height
                  double flexLineHeight = runCrossAxisExtent + runBetweenSpace;
                  // Should substract margin when layout child
                  double marginVertical = 0;
                  if (child is RenderBoxModel) {
                    RenderBoxModel childRenderBoxModel = _getChildRenderBoxModel(child);
                    marginVertical = childRenderBoxModel.marginTop + childRenderBoxModel.marginBottom;
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
                  // Should substract margin when layout child
                  double marginHorizontal = 0;
                  if (child is RenderBoxModel) {
                    RenderBoxModel childRenderBoxModel = _getChildRenderBoxModel(child);
                    marginHorizontal = childRenderBoxModel.marginLeft + childRenderBoxModel.marginRight;
                  }
                  minCrossAxisSize = (contentConstraints.maxWidth != double.infinity ?
                    contentConstraints.maxWidth : runCrossAxisExtent) - marginHorizontal;
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
          switch (_flexDirection) {
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

        // If width and height can be calculated from style, then its repaintBoundary equals self
        bool parentUsesSize = logicalWidth == null || logicalHeight == null;
        child.layout(deflateOverflowConstraints(innerConstraints), parentUsesSize: parentUsesSize);

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
    double logicalWidth,
    double logicalHeight,
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
    double constraintWidth = CSSFlex.isHorizontalFlexDirection(_flexDirection) ? containerSizeMap['main'] : containerSizeMap['cross'];
    bool isInlineBlock = realDisplay == CSSDisplay.inlineBlock;

    // Constrain to min-width or max-width if width not exists
    double childrenWidth = CSSFlex.isHorizontalFlexDirection(_flexDirection) ? maxAllocatedMainSize : containerSizeMap['cross'];
    if (isInlineBlock && maxWidth != null && width == null) {
      constraintWidth = childrenWidth > maxWidth ? maxWidth : childrenWidth;
    } else if (isInlineBlock && minWidth != null && width == null) {
      constraintWidth = childrenWidth < minWidth ? minWidth : childrenWidth;
    } else if (logicalWidth != null) {
      constraintWidth = math.max(constraintWidth, logicalWidth);
    }

    // Get layout height from children's height by flex axis
    double constraintHeight = CSSFlex.isHorizontalFlexDirection(_flexDirection) ? containerSizeMap['cross'] : containerSizeMap['main'];
    bool isNotInline = realDisplay != CSSDisplay.inline;

    // Constrain to min-height or max-height if width not exists
    double childrenHeight = CSSFlex.isHorizontalFlexDirection(_flexDirection) ? containerSizeMap['cross'] : maxAllocatedMainSize;
    if (isNotInline && maxHeight != null && height == null) {
      constraintHeight = childrenHeight > maxHeight ? maxHeight : childrenHeight;
    } else if (isNotInline && minHeight != null && height == null) {
      constraintHeight = constraintHeight < minHeight ? minHeight : constraintHeight;
    } else if (logicalHeight != null) {
      constraintHeight = math.max(constraintHeight, logicalHeight);
    }

    double maxScrollableWidth = 0.0;
    double maxScrollableHeight = 0.0;

    if (CSSFlex.isHorizontalFlexDirection(flexDirection)) {
      maxScrollableWidthMap.forEach((key, value) => maxScrollableWidth += value);
      maxScrollableHeightMap.forEach((key, value) => maxScrollableHeight = math.max(value, maxScrollableHeight));
    } else {
      maxScrollableWidthMap.forEach((key, value) => maxScrollableWidth = math.max(value, maxScrollableWidth));
      maxScrollableHeightMap.forEach((key, value) => maxScrollableHeight += value);
    }

    /// Stage 3: Set flex container size
    Size contentSize = Size(constraintWidth, constraintHeight);
    if (CSSFlex.isHorizontalFlexDirection(flexDirection)) {
      setMaxScrollableSize(math.max(contentSize.width, maxScrollableWidth), math.max(contentSize.height, maxScrollableHeight));
    } else {
      setMaxScrollableSize(math.max(contentSize.width, maxScrollableWidth), math.max(contentSize.height, maxScrollableHeight));
    }
    size = getBoxSize(contentSize);
  }

  // Set flex item offset based on flex alignment properties
  void _alignChildren(
    List<_RunMetrics> runMetrics,
    double runBetweenSpace,
    double runLeadingSpace,
    RenderPositionHolder placeholderChild,
    Map<int, dynamic> childSizeMap,
    Map<String, double> containerSizeMap,
    Size contentSize,
    Map<int, double> maxScrollableWidthMap,
    Map<int, double> maxScrollableHeightMap,
    ) {
    RenderBox child = placeholderChild != null ? placeholderChild : firstChild;
    double crossAxisOffset = runLeadingSpace;
    double mainAxisContentSize;
    double crossAxisContentSize;

    if (CSSFlex.isHorizontalFlexDirection(flexDirection)) {
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
      final double mainContentSizeDelta = mainAxisContentSize - runMainAxisExtent;
      _overflow = math.max(0.0, - mainContentSizeDelta);
      final double remainingSpace = math.max(0.0, mainContentSizeDelta);
      double leadingSpace;
      double betweenSpace;

      int totalChildren = childSizeMap.length;

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

      // Calculate margin auto children in the main axis
      double mainAxisMarginAutoChildren = 0;
      RenderBox runChild = firstChild;
      while (runChild != null) {
        final RenderFlexParentData childParentData = runChild.parentData;
        if (childParentData.runIndex != i) break;
        if (runChild is RenderBoxModel) {
          CSSStyleDeclaration childStyle = runChild.style;
          String marginLeft = childStyle[MARGIN_LEFT];
          String marginTop = childStyle[MARGIN_TOP];

          if ((CSSFlex.isHorizontalFlexDirection(flexDirection) && marginLeft == AUTO) ||
            (CSSFlex.isVerticalFlexDirection(flexDirection) && marginTop == AUTO)) {
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
      double lineBoxHeight = CSSText.getLineHeight(style);
      if (lineBoxHeight != null) {
        lineBoxLeading = lineBoxHeight - runCrossAxisExtent;
      }

      while (child != null) {

        final RenderFlexParentData childParentData = child.parentData;
        // Exclude positioned placeholder renderObject when layout non placeholder object
        // and positioned renderObject
        if (placeholderChild == null && (isPlaceholderPositioned(child) || childParentData.isPositioned)) {
          child = childParentData.nextSibling;
          continue;
        }
        if (childParentData.runIndex != i) break;

        double childMainAxisMargin = flowAwareChildMainAxisMargin(child);
        double childCrossAxisStartMargin = flowAwareChildCrossAxisMargin(child);
        double childCrossAxisEndMargin = flowAwareChildCrossAxisMargin(child, isEnd: true);

        // Add start margin of main axis when setting offset
        childMainPosition += childMainAxisMargin;

        double childCrossPosition;

        CSSStyleDeclaration childStyle = _getChildStyle(child);

        AlignSelf alignSelf = childParentData.alignSelf;
        double crossStartAddedOffset = crossAxisStartPadding + crossAxisStartBorder + childCrossAxisStartMargin;
        double contentCrossSize = _getContentCrossSize();

        if (alignSelf == AlignSelf.auto) {
          switch (alignItems) {
            case AlignItems.flexStart:
            case AlignItems.start:
              childCrossPosition = crossStartAddedOffset;
              break;
            case AlignItems.flexEnd:
            case AlignItems.end:
              childCrossPosition = crossAxisStartPadding + crossAxisStartBorder + contentCrossSize -
                _getCrossAxisExtent(child) - childCrossAxisEndMargin;
              break;
            case AlignItems.center:
              childCrossPosition = crossStartAddedOffset + (contentCrossSize - _getCrossAxisExtent(child)) / 2.0;
              break;
            case AlignItems.baseline:
            // Distance from top to baseline of child
              double childAscent = _getChildAscent(child);
              childCrossPosition = crossStartAddedOffset + lineBoxLeading / 2 + (runBaselineExtent - childAscent);
              break;
            case AlignItems.stretch:
              childCrossPosition = crossStartAddedOffset;
              break;
            default:
              break;
          }
        } else {
          switch (alignSelf) {
            case AlignSelf.flexStart:
            case AlignSelf.start:
              childCrossPosition = crossStartAddedOffset;
              break;
            case AlignSelf.flexEnd:
            case AlignSelf.end:
              childCrossPosition = crossAxisStartPadding + crossAxisStartBorder + contentCrossSize -
                _getCrossAxisExtent(child) - childCrossAxisEndMargin;
              break;
            case AlignSelf.center:
              childCrossPosition = crossStartAddedOffset + (contentCrossSize - _getCrossAxisExtent(child)) / 2.0;
              break;
            case AlignSelf.baseline:
            // Distance from top to baseline of child
              double childAscent = _getChildAscent(child);
              childCrossPosition = crossStartAddedOffset + lineBoxLeading / 2 + (runBaselineExtent - childAscent);
              break;
            case AlignSelf.stretch:
              childCrossPosition = crossStartAddedOffset;
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
          double mainAxisRemainingSpace = remainingSpace;
          double crossAxisRemainingSpace = crossAxisContentSize - _getCrossAxisExtent(child);

          if (CSSFlex.isHorizontalFlexDirection(flexDirection)) {
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
        if (flexWrap == FlexWrap.wrapReverse) {
          crossOffset = crossAxisContentSize - (childCrossPosition + crossAxisOffset + _getCrossSize(child));
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
      childMarginTop = childRenderBoxModel.marginTop;
      childMarginBottom = childRenderBoxModel.marginBottom;
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
    bool isVerticalDirection = CSSFlex.isVerticalFlexDirection(_flexDirection);
    if (isVerticalDirection) {
      return Offset(crossAxisOffset, mainAxisOffset);
    } else {
      return Offset(mainAxisOffset, crossAxisOffset);
    }
  }

  /// Get cross size of  content size
  double _getContentCrossSize() {
    if (CSSFlex.isHorizontalFlexDirection(flexDirection)) {
      return contentSize.height;
    }
    return contentSize.width;
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {Offset position}) {
    if (transform != null) {
      return hitTestLayoutChildren(result, lastChild, position);
    }
    return defaultHitTestChildren(result, position: position);
  }

  Offset getChildScrollOffset(RenderObject child, Offset offset) {
    final RenderLayoutParentData childParentData = child.parentData;
    // Fixed elements always paint original offset
    Offset scrollOffset = childParentData.position == CSSPositionType.fixed ?
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
          context.paintChild(child, getChildScrollOffset(child, offset));
        }
      }
    } else {
      RenderObject child = firstChild;
      while (child != null) {
        final RenderFlexParentData childParentData = child.parentData;
        // Don't paint placeholder of positioned element
        if (child is! RenderPositionHolder) {
          context.paintChild(child, getChildScrollOffset(child, offset));
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
    properties.add(DiagnosticsProperty<FlexDirection>('flexDirection', flexDirection));
    properties.add(DiagnosticsProperty<JustifyContent>('justifyContent', justifyContent));
    properties.add(DiagnosticsProperty<AlignItems>('alignItems', alignItems));
    properties.add(DiagnosticsProperty<FlexWrap>('flexWrap', flexWrap));
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
  get isRepaintBoundary => true;

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
