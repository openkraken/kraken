/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/rendering.dart';
import 'package:flutter/foundation.dart';

import 'package:kraken/css.dart';
import 'package:kraken/dom.dart';
import 'package:kraken/kraken.dart';
import 'package:kraken/module.dart';
import 'package:kraken/rendering.dart';
import 'package:kraken/gesture.dart';
import 'debug_overlay.dart';

// Constraints of element whose display style is none
final _displayNoneConstraints = BoxConstraints(
  minWidth: 0,
  maxWidth: 0,
  minHeight: 0,
  maxHeight: 0
);

class RenderLayoutParentData extends ContainerBoxParentData<RenderBox> {
  bool isPositioned = false;

  // Row index of child when wrapping
  int runIndex = 0;

  @override
  String toString() {
    return 'isPositioned=$isPositioned; ${super.toString()}; runIndex: $runIndex;';
  }
}

/// Modified from Flutter rendering/box.dart.
/// A mixin that provides useful default behaviors for boxes with children
/// managed by the [ContainerRenderObjectMixin] mixin.
///
/// By convention, this class doesn't override any members of the superclass.
/// Instead, it provides helpful functions that subclasses can call as
/// appropriate.
mixin RenderBoxContainerDefaultsMixin<ChildType extends RenderBox, ParentDataType extends ContainerBoxParentData<ChildType>> implements ContainerRenderObjectMixin<ChildType, ParentDataType> {
  /// Returns the baseline of the first child with a baseline.
  ///
  /// Useful when the children are displayed vertically in the same order they
  /// appear in the child list.
  double? defaultComputeDistanceToFirstActualBaseline(TextBaseline baseline) {
    assert(!debugNeedsLayout);
    ChildType? child = firstChild;
    while (child != null) {
      final ParentDataType childParentData = child.parentData as ParentDataType;
      // ignore: INVALID_USE_OF_PROTECTED_MEMBER
      final double? result = child.getDistanceToActualBaseline(baseline);
      if (result != null)
        return result + childParentData.offset.dy;
      child = childParentData.nextSibling;
    }
    return null;
  }

  /// Returns the minimum baseline value among every child.
  ///
  /// Useful when the vertical position of the children isn't determined by the
  /// order in the child list.
  double? defaultComputeDistanceToHighestActualBaseline(TextBaseline baseline) {
    assert(!debugNeedsLayout);
    double? result;
    ChildType? child = firstChild;
    while (child != null) {
      final ParentDataType childParentData = child.parentData as ParentDataType;
      // ignore: INVALID_USE_OF_PROTECTED_MEMBER
      double? candidate = child.getDistanceToActualBaseline(baseline);
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

  /// Performs a hit test on each child by walking the child list backwards.
  ///
  /// Stops walking once after the first child reports that it contains the
  /// given point. Returns whether any children contain the given point.
  ///
  /// See also:
  ///
  ///  * [defaultPaint], which paints the children appropriate for this
  ///    hit-testing strategy.
  bool defaultHitTestChildren(BoxHitTestResult result, { required Offset position }) {
    // The x, y parameters have the top left of the node's box as the origin.
    ChildType? child = lastChild;
    while (child != null) {
      final ParentDataType childParentData = child.parentData as ParentDataType;
      final bool isHit = result.addWithPaintOffset(
        offset: childParentData.offset == Offset.zero ? null : childParentData.offset,
        position: position,
        hitTest: (BoxHitTestResult result, Offset transformed) {
          assert(transformed == position - childParentData.offset);
          return child!.hitTest(result, position: transformed);
        },
      );
      if (isHit)
        return true;
      child = childParentData.previousSibling;
    }
    return false;
  }

  /// Paints each child by walking the child list forwards.
  ///
  /// See also:
  ///
  ///  * [defaultHitTestChildren], which implements hit-testing of the children
  ///    in a manner appropriate for this painting strategy.
  void defaultPaint(PaintingContext context, Offset offset) {
    ChildType? child = firstChild;
    while (child != null) {
      final ParentDataType childParentData = child.parentData as ParentDataType;
      context.paintChild(child, childParentData.offset + offset);
      child = childParentData.nextSibling;
    }
  }

  /// Returns a list containing the children of this render object.
  ///
  /// This function is useful when you need random-access to the children of
  /// this render object. If you're accessing the children in order, consider
  /// walking the child list directly.
  List<ChildType> getChildrenAsList() {
    final List<ChildType> result = <ChildType>[];
    RenderBox? child = firstChild;
    while (child != null) {
      final ParentDataType childParentData = child.parentData as ParentDataType;
      result.add(child as ChildType);
      child = childParentData.nextSibling;
    }
    return result;
  }
}

class RenderLayoutBox extends RenderBoxModel
    with
        ContainerRenderObjectMixin<RenderBox, ContainerBoxParentData<RenderBox>>,
        RenderBoxContainerDefaultsMixin<RenderBox, ContainerBoxParentData<RenderBox>> {
  RenderLayoutBox({required int targetId, required RenderStyle renderStyle, required ElementManager elementManager})
      : super(targetId: targetId, renderStyle: renderStyle, elementManager: elementManager);

  @override
  void markNeedsLayout() {
    super.markNeedsLayout();

    // FlexItem layout must trigger flex container to layout.
    if (parent != null && parent is RenderFlexLayout) {
      markParentNeedsLayout();
    }
  }

  // Mark this container to sort children by zIndex properties.
  // When children have positioned elements, which needs to reorder and paint earlier than flow layout renderObjects.
  void markNeedsSortChildren() {
    _isChildrenSorted = false;
  }

  bool _isChildrenSorted = false;
  bool get isChildrenSorted => _isChildrenSorted;

  List<RenderObject>? _sortedChildren;
  List<RenderObject> get sortedChildren {
    if (_sortedChildren == null) return [];
    return _sortedChildren!;
  }
  set sortedChildren(List<RenderObject> value) {
    _isChildrenSorted = true;
    _sortedChildren = value;
  }

  @override
  void insert(RenderBox child, { RenderBox? after }) {
    super.insert(child, after: after);
    _isChildrenSorted = false;
  }

  @override
  void add(RenderBox child) {
    super.add(child);
    _isChildrenSorted = false;
  }

  @override
  void addAll(List<RenderBox>? children) {
    super.addAll(children);
    _isChildrenSorted = false;
  }

  @override
  void remove(RenderBox child) {
    if (child is RenderBoxModel) {
      var childPositionHolder = child.renderPositionHolder;
      if (childPositionHolder != null) {
        (childPositionHolder.parent as ContainerRenderObjectMixin).remove(childPositionHolder);
      }
    }
    super.remove(child);
    _isChildrenSorted = false;
  }

  @override
  void removeAll() {
    super.removeAll();
    _isChildrenSorted = false;
  }

  void move(RenderBox child, { RenderBox? after }) {
    super.move(child, after: after);
    _isChildrenSorted = false;
  }

  // Get all children as a list and detach them all.
  List<RenderBox> getDetachedChildrenAsList() {
    List<RenderBox> children = getChildrenAsList();
    removeAll();
    return children;
  }

  // Cache sticky children to calculate the base offset of sticky children
  List<RenderBoxModel> stickyChildren = [];

  /// Find all the children whose position is sticky to this element
  List<RenderBoxModel> findStickyChildren() {
    List<RenderBoxModel> stickyChildren = [];

    RenderBox? child = firstChild;

    // Layout positioned element
    while (child != null) {
      final RenderLayoutParentData childParentData = (child.parentData as RenderLayoutParentData?)!;
      if (child is! RenderBoxModel) {
        child = childParentData.nextSibling;
        continue;
      }

      RenderBoxModel childRenderBoxModel = child;
      RenderStyle childRenderStyle = childRenderBoxModel.renderStyle;
      CSSOverflowType overflowX = childRenderStyle.overflowX;
      CSSOverflowType overflowY = childRenderStyle.overflowY;
      // No need to loop scrollable container children
      if (overflowX != CSSOverflowType.visible || overflowY != CSSOverflowType.visible) {
        child = childParentData.nextSibling;
        continue;
      }
      if (CSSPositionedLayout.isSticky(childRenderBoxModel)) {
        stickyChildren.add(child);
      }

      if (child is RenderLayoutBox) {
        List<RenderBoxModel> mergedChildren = child.findStickyChildren();
        for (RenderBoxModel child in mergedChildren) {
          stickyChildren.add(child);
        }
      }
      child = childParentData.nextSibling;
    }

    return stickyChildren;
  }

  @override
  double? computeDistanceToActualBaseline(TextBaseline baseline) {
    return computeDistanceToBaseline();
  }

  /// Baseline rule is as follows:
  /// 1. Loop children to find baseline, if child is block-level find the nearest non block-level children's height
  /// as baseline
  /// 2. If child is text-box, use text's baseline
  double? computeDistanceToHighestActualBaseline(TextBaseline baseline) {
    double? result;
    RenderBox? child = firstChild;
    while (child != null) {
      final RenderLayoutParentData childParentData = (child.parentData as RenderLayoutParentData?)!;

      // Whether child is inline-level including text box
      bool isChildInline = true;
      if (child is RenderBoxModel) {
        CSSDisplay? childTransformedDisplay = child.renderStyle.transformedDisplay;
        if (childTransformedDisplay == CSSDisplay.block || childTransformedDisplay == CSSDisplay.flex) {
          isChildInline = false;
        }
      }

      // Block level and positioned element doesn't involve in baseline alignment
      if (childParentData.isPositioned) {
        child = childParentData.nextSibling;
        continue;
      }

      double? childDistance = child.getDistanceToActualBaseline(baseline);
      // Use child's height if child has no baseline and not block-level
      // Text box always has baseline
      if (childDistance == null &&
        isChildInline &&
        child is RenderBoxModel
      ) {
        // Flutter only allow access size of direct children, so cannot use child.size
        Size childSize = child.getBoxSize(child.contentSize);
        childDistance = childSize.height;
      }


      if (childDistance != null) {
        childDistance += childParentData.offset.dy;
        if (result != null)
          result = math.min(result, childDistance);
        else
          result = childDistance;
      }
      child = childParentData.nextSibling;
    }
    return result;
  }

  /// Common layout size (including flow and flexbox layout) calculation logic
  Size getLayoutSize({
    double? logicalContentWidth,
    double? logicalContentHeight,
    required double contentWidth,
    required double contentHeight,
  }) {
    double layoutWidth = contentWidth;
    double layoutHeight = contentHeight;

    // Size which is specified by sizing styles
    double? specifiedWidth = logicalContentWidth;
    double? specifiedHeight = logicalContentHeight;
    // Flex basis takes priority over main size in flex item.
    if (parent is RenderFlexLayout) {
      RenderBoxModel parentRenderBoxModel = (parent as RenderBoxModel?)!;
      double? flexBasis = renderStyle.flexBasis;
      if (flexBasis != null) {
        if (CSSFlex.isHorizontalFlexDirection(parentRenderBoxModel.renderStyle.flexDirection)) {
          specifiedWidth = flexBasis;
        } else {
          specifiedHeight = flexBasis;
        }
      }
    }

    layoutWidth = math.max(specifiedWidth ?? 0, contentWidth);
    layoutHeight = math.max(specifiedHeight ?? 0, contentHeight);

    CSSDisplay? transformedDisplay = renderStyle.transformedDisplay;
    bool isInlineBlock = transformedDisplay == CSSDisplay.inlineBlock;
    bool isNotInline = transformedDisplay != CSSDisplay.inline;
    double? width = renderStyle.width;
    double? height = renderStyle.height;
    double? minWidth = renderStyle.minWidth;
    double? minHeight = renderStyle.minHeight;
    double? maxWidth = renderStyle.maxWidth;
    double? maxHeight = renderStyle.maxHeight;

    // Constrain to min-width or max-width if width not exists.
    if (isInlineBlock && maxWidth != null && width == null) {
      layoutWidth = layoutWidth > maxWidth ? maxWidth : layoutWidth;
    } else if (isInlineBlock && minWidth != null && width == null) {
      layoutWidth = layoutWidth < minWidth ? minWidth : layoutWidth;
    }

    // Constrain to min-height or max-height if height not exists.
    if (isNotInline && maxHeight != null && height == null) {
      layoutHeight = layoutHeight > maxHeight ? maxHeight : layoutHeight;
    } else if (isNotInline && minHeight != null && height == null) {
      layoutHeight = layoutHeight < minHeight ? minHeight : layoutHeight;
    }

    Size layoutSize = Size(layoutWidth, layoutHeight);
    return layoutSize;
  }

  /// Extend max scrollable size of renderBoxModel by offset of positioned child,
  /// get the max scrollable size of children of normal flow and single positioned child.
  void extendMaxScrollableSize(RenderBoxModel child) {
    Size childScrollableSize;
    RenderStyle childRenderStyle = child.renderStyle;
    CSSOverflowType overflowX = childRenderStyle.overflowX;
    CSSOverflowType overflowY = childRenderStyle.overflowY;
    // Only non scroll container need to use scrollable size, otherwise use its own size
    if (overflowX == CSSOverflowType.visible && overflowY == CSSOverflowType.visible) {
      childScrollableSize = child.scrollableSize;
    } else {
      childScrollableSize = child.boxSize;
    }
    double maxScrollableX = scrollableSize.width;
    double maxScrollableY = scrollableSize.height;
    CSSOffset? childLeft = childRenderStyle.left;
    CSSOffset? childRight = childRenderStyle.right;
    CSSOffset? childTop = childRenderStyle.top;
    CSSOffset? childBottom = childRenderStyle.bottom;

    if (childLeft != null && !childLeft.isAuto) {
      maxScrollableX = math.max(maxScrollableX, childLeft.length + childScrollableSize.width);
    }

    if (childRight != null && !childRight.isAuto) {
      if (isScrollingContentBox && (parent as RenderBoxModel).widthSizeType == BoxSizeType.specified) {
        RenderBoxModel overflowContainerBox = (parent as RenderBoxModel?)!;
        maxScrollableX = math.max(maxScrollableX, -childRight.length + overflowContainerBox.renderStyle.width!
          - overflowContainerBox.renderStyle.borderLeft - overflowContainerBox.renderStyle.borderRight);
      } else {
        maxScrollableX = math.max(maxScrollableX, -childRight.length + contentSize.width);
      }
    }

    if (childTop != null && !childTop.isAuto) {
      maxScrollableY = math.max(maxScrollableY, childTop.length + childScrollableSize.height);
    }
    if (childBottom != null && !childBottom.isAuto) {
      if (isScrollingContentBox && (parent as RenderBoxModel).heightSizeType == BoxSizeType.specified) {
        RenderBoxModel overflowContainerBox = (parent as RenderBoxModel?)!;
        maxScrollableY = math.max(maxScrollableY, -childBottom.length + overflowContainerBox.renderStyle.height!
          - overflowContainerBox.renderStyle.borderTop - overflowContainerBox.renderStyle.borderBottom);
      } else {
        maxScrollableY = math.max(maxScrollableY, -childBottom.length + contentSize.height);
      }

    }
    scrollableSize = Size(maxScrollableX, maxScrollableY);
  }
}

mixin RenderBoxModelBase on RenderBox {
  late RenderStyle renderStyle;
  late Size boxSize;
}

class RenderBoxModel extends RenderBox with
  RenderBoxModelBase,
  RenderBoxDecorationMixin,
    RenderTransformMixin,
    RenderOverflowMixin,
    RenderOpacityMixin,
    RenderIntersectionObserverMixin,
    RenderContentVisibilityMixin,
    RenderVisibilityMixin,
    RenderPointerListenerMixin,
    RenderColorFilter,
    RenderImageFilter,
    RenderObjectWithControllerMixin {
  RenderBoxModel({
    required this.targetId,
    required this.renderStyle,
    required this.elementManager,
  }) : super() {
    renderStyle.renderBoxModel = this;
  }

  RenderStyle renderStyle;

  @override
  bool get alwaysNeedsCompositing => opacityAlwaysNeedsCompositing();

  RenderPositionHolder? renderPositionHolder;

  bool _debugShouldPaintOverlay = false;
  bool get debugShouldPaintOverlay => _debugShouldPaintOverlay;
  set debugShouldPaintOverlay(bool? value) {
    if (value != null && _debugShouldPaintOverlay != value) {
      _debugShouldPaintOverlay = value;
      markNeedsPaint();
    }
  }

  bool _debugHasBoxLayout = false;

  int childPaintDuration = 0;
  int childLayoutDuration = 0;

  BoxConstraints? _contentConstraints;
  BoxConstraints? get contentConstraints {
    assert(_debugHasBoxLayout, 'can not access contentConstraints, RenderBoxModel has not layout: ${toString()}');
    return _contentConstraints;
  }

  /// Whether need to recalculate gradient when setting style used in cases
  /// when linear-gradient has length specified and layout has no size in gradient direction
  /// such as 'linear-gradient(to right, red 0px, red 50px, orange 50px, orange 80px)' and style has no width set
  bool _shouldRecalGradient = false;
  bool get shouldRecalGradient => _shouldRecalGradient;
  set shouldRecalGradient(bool value) {
    if (_shouldRecalGradient != value) {
      _shouldRecalGradient = value;
    }
  }

  /// Used when setting percentage font-size style, it needs to be calculated when node attached
  /// where it needs to know the font-size of its parent element
  bool _shouldLazyCalFontSize = false;
  bool get shouldLazyCalFontSize => _shouldLazyCalFontSize;
  set shouldLazyCalFontSize(bool? value) {
    if (value == null) return;
    if (_shouldLazyCalFontSize != value) {
      _shouldLazyCalFontSize = value;
    }
  }

  /// Used when setting percentage line-height style, it needs to be calculated when node attached
  /// where it needs to know the font-size of its own element
  bool _shouldLazyCalLineHeight = false;
  bool get shouldLazyCalLineHeight => _shouldLazyCalLineHeight;
  set shouldLazyCalLineHeight(bool? value) {
    if (value == null) return;
    if (_shouldLazyCalLineHeight != value) {
      _shouldLazyCalLineHeight = value;
    }
  }

  // id of current element
  int targetId;

  ElementManager elementManager;

  // When RenderBoxModel is scrolling box, contentConstraints are always equal to BoxConstraints();
  bool isScrollingContentBox = false;

  BoxSizeType get widthSizeType {
    bool widthDefined = renderStyle.width != null;
    return widthDefined ? BoxSizeType.specified : BoxSizeType.automatic;
  }
  BoxSizeType get heightSizeType {
    bool heightDefined = renderStyle.height != null;
    return heightDefined ? BoxSizeType.specified : BoxSizeType.automatic;
  }

  // Cache scroll offset of scrolling box in horizontal direction
  // to be used in paint of fixed children
  double? _scrollingOffsetX;
  double? get scrollingOffsetX => _scrollingOffsetX;
  set scrollingOffsetX(double? value) {
    if (value == null) return;
    if (_scrollingOffsetX != value) {
      _scrollingOffsetX = value;
      markNeedsPaint();
    }
  }

  // Cache scroll offset of scrolling box in vertical direction
  // to be used in paint of fixed children
  double? _scrollingOffsetY;
  double? get scrollingOffsetY => _scrollingOffsetY;
  set scrollingOffsetY(double? value) {
    if (value == null) return;
    if (_scrollingOffsetY != value) {
      _scrollingOffsetY = value;
      markNeedsPaint();
    }
  }

  // Cache all the fixed children of renderBoxModel of root element
  List<RenderBoxModel> fixedChildren = [];

  // Position of sticky element changes between relative and fixed of scroll container
  StickyPositionType stickyStatus = StickyPositionType.relative;

  // Positioned holder box ref.
  RenderPositionHolder? positionedHolder;

  T copyWith<T extends RenderBoxModel>(T copiedRenderBoxModel) {
    if (renderPositionHolder != null) {
      renderPositionHolder!.realDisplayedBox = copiedRenderBoxModel;
    }

    return copiedRenderBoxModel
      // Copy render style
      ..renderStyle = renderStyle

      // Copy box decoration
      ..boxPainter = boxPainter

      // Copy overflow
      ..scrollListener = scrollListener
      ..clipX = clipX
      ..clipY = clipY
      ..enableScrollX = enableScrollX
      ..enableScrollY = enableScrollY
      ..scrollOffsetX = scrollOffsetX
      ..scrollOffsetY = scrollOffsetY

      // Copy pointer listener
      ..onPointerDown = onPointerDown
      ..onPointerCancel = onPointerCancel
      ..onPointerUp = onPointerUp
      ..onPointerMove = onPointerMove
      ..onPointerSignal = onPointerSignal

      // Copy renderPositionHolder
      ..renderPositionHolder = renderPositionHolder

      // Copy parentData
      ..parentData = parentData;
  }

  // Boxes which have intrinsic ratio
  double? _intrinsicWidth;
  double? get intrinsicWidth {
    return _intrinsicWidth;
  }
  set intrinsicWidth(double? value) {
    if (_intrinsicWidth == value) return;
    _intrinsicWidth = value;
    markNeedsLayout();
  }

  // Boxes which have intrinsic ratio
  double? _intrinsicHeight;
  double? get intrinsicHeight {
    return _intrinsicHeight;
  }
  set intrinsicHeight(double? value) {
    if (_intrinsicHeight == value) return;
    _intrinsicHeight = value;
    markNeedsLayout();
  }

  double? _intrinsicRatio;
  double? get intrinsicRatio {
    return _intrinsicRatio;
  }
  set intrinsicRatio(double? value) {
    if (_intrinsicRatio == value) return;
    _intrinsicRatio = value;
    markNeedsLayout();
  }

  // Auto value for min-width
  double autoMinWidth = 0;
  // Auto value for min-height
  double autoMinHeight = 0;

  // Mirror debugNeedsLayout flag in Flutter to use in layout performance optimization
  bool needsLayout = false;

  @override
  void markNeedsLayout() {
    super.markNeedsLayout();
    needsLayout = true;
  }

  /// Mark children needs layout when drop child as Flutter did
  @override
  void dropChild(RenderBox child) {
    super.dropChild(child);
    // Loop to mark all the children to needsLayout as flutter did
    if (child is RenderBoxModel) {
      child.markOwnNeedsLayout();
    } else if (child is RenderTextBox) {
      child.markOwnNeedsLayout();
    }
  }

  /// Mark own and its children (if exist) needs layout
  void markOwnNeedsLayout() {
    needsLayout = true;
    visitChildren(markChildNeedsLayout);
  }

  /// Mark specified renderBoxModel needs layout
  void markChildNeedsLayout(RenderObject child) {
    if (child is RenderBoxModel) {
      child.markOwnNeedsLayout();
    } else if (child is RenderTextBox) {
      child.markOwnNeedsLayout();
    }
  }

  @override
  void layout(Constraints newConstraints, { bool parentUsesSize = false }) {
    if (hasSize) {
      // Constraints changes between tight and no tight will cause reLayoutBoundary change
      // which will then cause its children to be marked as needsLayout in Flutter
      if ((newConstraints.isTight && !constraints.isTight) ||
        (!newConstraints.isTight && constraints.isTight)
      ) {
        visitChildren((RenderObject child) {
          if (child is RenderBoxModel) {
            child.markOwnNeedsLayout();
          } else if (child is RenderTextBox) {
            child.markOwnNeedsLayout();
          }
        });
      }
    }
    super.layout(newConstraints, parentUsesSize: parentUsesSize);
  }


  /// Calculate renderBoxModel constraints
  BoxConstraints getConstraints() {
    // Inner scrolling content box of overflow element inherits constraints from parent
    // but has indefinite max constraints to allow children overflow
    if (isScrollingContentBox) {
      BoxConstraints parentConstraints = (parent as RenderBoxModel).constraints;
      BoxConstraints constraints = BoxConstraints(
        minWidth: parentConstraints.maxWidth != double.infinity ? parentConstraints.maxWidth : 0,
        maxWidth: double.infinity,
        minHeight: parentConstraints.maxHeight != double.infinity ? parentConstraints.maxHeight : 0,
        maxHeight: double.infinity,
      );
      return constraints;
    }

    CSSDisplay? transformedDisplay = renderStyle.transformedDisplay;
    bool isDisplayInline = transformedDisplay == CSSDisplay.inline;
    bool isDisplayNone = transformedDisplay == CSSDisplay.none;

    if (isDisplayNone) {
      return _displayNoneConstraints;
    }

    EdgeInsets? borderEdge = renderStyle.borderEdge;
    EdgeInsetsGeometry? padding = renderStyle.padding;
    double? minWidth = renderStyle.minWidth;
    double? maxWidth = renderStyle.maxWidth;
    double? minHeight = renderStyle.minHeight;
    double? maxHeight = renderStyle.maxHeight;

    double horizontalBorderLength = borderEdge != null ? borderEdge.horizontal : 0;
    double verticalBorderLength = borderEdge != null ? borderEdge.vertical : 0;
    double horizontalPaddingLength = padding != null ? padding.horizontal : 0;
    double verticalPaddingLength = padding != null ? padding.vertical : 0;

    // Content size calculated from style
    double? logicalContentWidth = getLogicalContentWidth(this);
    double? logicalContentHeight = getLogicalContentHeight(this);

    // Box size calculated from style
    double? logicalWidth = logicalContentWidth != null ?
    logicalContentWidth + horizontalPaddingLength + horizontalBorderLength : null;
    double? logicalHeight = logicalContentHeight != null ?
    logicalContentHeight + verticalPaddingLength + verticalBorderLength : null;

    // Constraints
    double minConstraintWidth = 0;
    double maxConstraintWidth = logicalWidth ?? double.infinity;
    double minConstraintHeight = 0;
    double maxConstraintHeight = logicalHeight ?? double.infinity;

    if (parent is RenderFlexLayout) {
      double? flexBasis = renderStyle.flexBasis;
      RenderFlexLayout parentRenderBoxModel = parent as RenderFlexLayout;
      // In flex layout, flex basis takes priority over width/height if set.
      // Flex-basis cannot be smaller than its content size which happens can not be known
      // in constraints apply stage, so flex-basis acts as min-width in constraints apply stage.
      if (flexBasis != null) {
        if (CSSFlex.isHorizontalFlexDirection(parentRenderBoxModel.renderStyle.flexDirection)) {
          minConstraintWidth = flexBasis;
          // Clamp flex-basis by minWidth and maxWidth
          if (minWidth != null && flexBasis < minWidth) {
            maxConstraintWidth = minWidth;
          }
          if (maxWidth != null && flexBasis > maxWidth) {
            minConstraintWidth = maxWidth;
          }
        } else {
          minConstraintHeight = flexBasis;
          // Clamp flex-basis by minHeight and maxHeight
          if (minHeight != null && flexBasis < minHeight) {
            maxConstraintHeight = minHeight;
          }
          if (maxHeight != null && flexBasis > maxHeight) {
            minConstraintHeight = maxHeight;
          }
        }
      }
    }

    // min/max size does not apply for inline element
    if (!isDisplayInline) {
      if (minWidth != null) {
        minConstraintWidth = minConstraintWidth < minWidth ? minWidth : minConstraintWidth;
      }
      if (maxWidth != null) {
        maxConstraintWidth = maxConstraintWidth > maxWidth ? maxWidth : maxConstraintWidth;
      }
      if (minHeight != null) {
        minConstraintHeight = minConstraintHeight < minHeight ? minHeight : minConstraintHeight;
      }
      if (maxHeight != null) {
        maxConstraintHeight = maxConstraintHeight > maxHeight ? maxHeight : maxConstraintHeight;
      }
    }

    BoxConstraints constraints = BoxConstraints(
      minWidth: minConstraintWidth,
      maxWidth: maxConstraintWidth,
      minHeight: minConstraintHeight,
      maxHeight: maxConstraintHeight,
    );

    return constraints;
  }

  /// Content width of render box model calcaluted from style
  static double? getLogicalContentWidth(RenderBoxModel renderBoxModel) {
    RenderBoxModel originalRenderBoxModel = renderBoxModel;
    double cropWidth = 0;
    CSSDisplay? display = renderBoxModel.renderStyle.transformedDisplay;
    RenderStyle renderStyle = renderBoxModel.renderStyle;
    double? width = renderStyle.width;
    double? minWidth = renderStyle.minWidth;
    double? maxWidth = renderStyle.maxWidth;
    double? intrinsicRatio = renderBoxModel.intrinsicRatio;

    void cropMargin(RenderBoxModel renderBoxModel) {
      if (renderBoxModel.renderStyle.margin != null) {
        cropWidth += renderBoxModel.renderStyle.margin!.horizontal;
      }
    }

    void cropPaddingBorder(RenderBoxModel renderBoxModel) {
      if (renderBoxModel.renderStyle.borderEdge != null) {
        cropWidth += renderBoxModel.renderStyle.borderEdge!.horizontal;
      }

      if (renderBoxModel.renderStyle.padding != null) {
        cropWidth += renderBoxModel.renderStyle.padding!.horizontal;
      }
    }

    switch (display) {
      case CSSDisplay.block:
      case CSSDisplay.flex:
      case CSSDisplay.sliver:
        // Get own width if exists else get the width of nearest ancestor width width
        if (renderStyle.width != null) {
          cropPaddingBorder(renderBoxModel);
        } else {
          // @TODO: flexbox stretch alignment will stretch replaced element in the cross axis
          // Block level element will spread to its parent's width except for replaced element
          if (renderBoxModel is! RenderIntrinsic) {
            while (true) {
              if (renderBoxModel.parent != null && renderBoxModel.parent is RenderBoxModel) {
                cropMargin(renderBoxModel);
                cropPaddingBorder(renderBoxModel);
                renderBoxModel = renderBoxModel.parent as RenderBoxModel;
              } else {
                break;
              }

              CSSDisplay? display = renderBoxModel.renderStyle.transformedDisplay;

              RenderStyle renderStyle = renderBoxModel.renderStyle;
              // Set width of element according to parent display
              if (display != CSSDisplay.inline) {
                // Skip to find upper parent
                if (renderStyle.width != null) {
                  // Use style width
                  width = renderStyle.width;
                  cropPaddingBorder(renderBoxModel);
                  break;
                } else if (display == CSSDisplay.inlineBlock || display == CSSDisplay.inlineFlex || display == CSSDisplay.sliver) {
                  // Collapse width to children
                  width = null;
                  break;
                }
              }
            }
          }
        }
        break;
      case CSSDisplay.inlineBlock:
      case CSSDisplay.inlineFlex:
        if (renderStyle.width != null) {
          width = renderStyle.width;
          cropPaddingBorder(renderBoxModel);
        } else {
          width = null;
        }
        break;
      case CSSDisplay.inline:
        width = null;
        break;
      default:
        break;
    }
    // Get height by intrinsic ratio for replaced elemnent if height is not defined
    if (width == null && intrinsicRatio != null) {
      width = originalRenderBoxModel.renderStyle.getWidthByIntrinsicRatio() + cropWidth;
    }

    if (minWidth != null) {
      if (width != null && width < minWidth) {
        width = minWidth;
      }
    }
    if (maxWidth != null) {
      if (width != null && width > maxWidth)  {
        width = maxWidth;
      }
    }

    if (width != null) {
      return math.max(0, width - cropWidth);
    } else {
      return null;
    }
  }

  /// Content height of render box model calcaluted from style
  static double? getLogicalContentHeight(RenderBoxModel renderBoxModel) {
    RenderBoxModel originalRenderBoxModel = renderBoxModel;
    CSSDisplay? display = renderBoxModel.renderStyle.transformedDisplay;
    RenderStyle renderStyle = renderBoxModel.renderStyle;
    double? height = renderStyle.height;
    double cropHeight = 0;

    double? maxHeight = renderStyle.maxHeight;
    double? minHeight = renderStyle.minHeight;
    double? intrinsicRatio = renderBoxModel.intrinsicRatio;

    void cropMargin(RenderBoxModel renderBoxModel) {
      if (renderBoxModel.renderStyle.margin != null) {
        cropHeight += renderBoxModel.renderStyle.margin!.vertical;
      }
    }

    void cropPaddingBorder(RenderBoxModel renderBoxModel) {
      if (renderBoxModel.renderStyle.borderEdge != null) {
        cropHeight += renderBoxModel.renderStyle.borderEdge!.vertical;
      }
      if (renderBoxModel.renderStyle.padding != null) {
        cropHeight += renderBoxModel.renderStyle.padding!.vertical;
      }
    }

    // Inline element has no height
    if (display == CSSDisplay.inline) {
      return null;
    } else if (height != null) {
      cropPaddingBorder(renderBoxModel);
    } else {
      while (true) {
        RenderBoxModel current;
        if (renderBoxModel.parent != null && renderBoxModel.parent is RenderBoxModel) {
          cropMargin(renderBoxModel);
          cropPaddingBorder(renderBoxModel);
          current = renderBoxModel;
          renderBoxModel = renderBoxModel.parent as RenderBoxModel;
        } else {
          break;
        }

        RenderStyle renderStyle = renderBoxModel.renderStyle;
        if (CSSSizingMixin.isStretchChildHeight(renderBoxModel, current)) {
          if (renderStyle.height != null) {
            height = renderStyle.height;
            cropPaddingBorder(renderBoxModel);
            break;
          }
        } else {
          break;
        }
      }
    }

    // Get height by intrinsic ratio for replaced elemnent if height is not defined
    if (height == null && intrinsicRatio != null) {
      height = originalRenderBoxModel.renderStyle.getHeightByIntrinsicRatio() + cropHeight;
    }

    if (minHeight != null) {
      if (height != null && height < minHeight)  {
        height = minHeight;
      }
    }
    if (maxHeight != null) {
      if (height != null && height > maxHeight)  {
        height = maxHeight;
      }
    }

    if (height != null) {
      return math.max(0, height - cropHeight);
    } else {
      return null;
    }
  }

  /// Get max constraint width from style, use width or max-width exists if exists,
  /// otherwise calculated from its ancestors
  static double getMaxConstraintWidth(RenderBoxModel renderBoxModel) {
    double maxConstraintWidth = double.infinity;
    double cropWidth = 0;

    void cropMargin(RenderBoxModel renderBoxModel) {
      if (renderBoxModel.renderStyle.margin != null) {
        cropWidth += renderBoxModel.renderStyle.margin!.horizontal;
      }
    }

    void cropPaddingBorder(RenderBoxModel renderBoxModel) {
      RenderStyle renderStyle = renderBoxModel.renderStyle;
      if (renderBoxModel.renderStyle.borderEdge != null) {
        cropWidth += renderBoxModel.renderStyle.borderEdge!.horizontal;
      }
      if (renderStyle.padding != null) {
        cropWidth += renderStyle.padding!.horizontal;
      }
    }

    // Get the nearest width of ancestor with width
    while (true) {
      if (renderBoxModel is RenderBoxModel) {
        CSSDisplay? display = renderBoxModel.renderStyle.transformedDisplay;
        RenderStyle renderStyle = renderBoxModel.renderStyle;

        // Flex item with flex-shrink 0 and no width/max-width will have infinity constraints
        // even if parents have width
        if (renderBoxModel.parent is RenderFlexLayout) {
          if (renderStyle.flexShrink == 0 && renderStyle.width == null && renderStyle.maxWidth == null) {
            break;
          }
        }

        // Get width if width exists and element is not inline
        if (display != CSSDisplay.inline && (renderStyle.width != null || renderStyle.maxWidth != null)) {
          // Get the min width between width and max-width
          maxConstraintWidth = math.min(
            renderStyle.width ?? double.infinity,
            renderStyle.maxWidth ?? double.infinity
          ) ;
          cropPaddingBorder(renderBoxModel);
          break;
        }
      }

      if (renderBoxModel.parent != null && renderBoxModel.parent is RenderBoxModel) {
        cropMargin(renderBoxModel);
        cropPaddingBorder(renderBoxModel);
        renderBoxModel = renderBoxModel.parent as RenderBoxModel;
      } else {
        break;
      }
    }

    if (maxConstraintWidth != double.infinity) {
      maxConstraintWidth = maxConstraintWidth - cropWidth;
    }

    return maxConstraintWidth;
  }

  /// Set the size of scrollable overflow area of renderBoxModel
  void setMaxScrollableSize(double width, double height) {
    // Scrollable area includes right and bottom padding
    scrollableSize = Size(
      width + renderStyle.paddingLeft,
      height + renderStyle.paddingTop
    );
  }

  // Box size equals to RenderBox.size to avoid flutter complain when read size property.
  late Size _boxSize;
  Size get boxSize {
    return _boxSize;
  }

  set size(Size value) {
    _boxSize = value;
    super.size = value;
  }

  Size getBoxSize(Size contentSize) {
    Size boxSize = _contentSize = contentConstraints!.constrain(contentSize);

    scrollableViewportSize = Size(
      contentSize.width + renderStyle.paddingLeft + renderStyle.paddingRight,
      contentSize.height + renderStyle.paddingTop + renderStyle.paddingBottom
    );

    if (renderStyle.padding != null) {
      boxSize = renderStyle.wrapPaddingSize(boxSize);
    }
    if (renderStyle.borderEdge != null) {
      boxSize = renderStyle.wrapBorderSize(boxSize);
    }
    return constraints.constrain(boxSize);
  }

  // The contentSize of layout box
  Size? _contentSize;
  Size get contentSize {
    if (_contentSize == null) {
      return Size(0, 0);
    }
    return _contentSize!;
  }

  /// Logical content width calculated from style
  double? logicalContentWidth;
  /// Logical content height calculated from style
  double? logicalContentHeight;

  double get clientWidth {
    double width = contentSize.width;
    if (renderStyle.padding != null) {
      width += renderStyle.padding!.horizontal;
    }
    return width;
  }

  double get clientHeight {
    double height = contentSize.height;
    if (renderStyle.padding != null) {
      height += renderStyle.padding!.vertical;
    }
    return height;
  }

  // Base layout methods to compute content constraints before content box layout.
  // Call this method before content box layout.
  BoxConstraints beforeLayout() {
    _debugHasBoxLayout = true;
    BoxConstraints boxConstraints = constraints;
    // Deflate border constraints.
    boxConstraints = renderStyle.deflateBorderConstraints(boxConstraints);

    // Deflate padding constraints.
    boxConstraints = renderStyle.deflatePaddingConstraints(boxConstraints);

    logicalContentWidth = getLogicalContentWidth(this);
    logicalContentHeight = getLogicalContentHeight(this);

    if (!isScrollingContentBox && (logicalContentWidth != null || logicalContentHeight != null)) {
      double? minWidth;
      double? maxWidth;
      double? minHeight;
      double? maxHeight;

      if (boxConstraints.hasTightWidth) {
        minWidth = maxWidth = boxConstraints.maxWidth;
      } else if (logicalContentWidth != null) {
        minWidth = 0.0;
        maxWidth = logicalContentWidth;
      } else {
        minWidth = boxConstraints.minWidth;
        maxWidth = boxConstraints.maxWidth;
      }

      if (boxConstraints.hasTightHeight) {
        minHeight = maxHeight = boxConstraints.maxHeight;
      } else if (logicalContentHeight != null) {
        minHeight = 0.0;
        maxHeight = logicalContentHeight;
      } else {
        minHeight = boxConstraints.minHeight;
        maxHeight = boxConstraints.maxHeight;
      }

      // max and min size of intrinsc element should respect intrinsc ratio of each other
      if (intrinsicRatio != null) {
        if (renderStyle.minWidth != null && renderStyle.minHeight == null) {
          minHeight = minWidth * intrinsicRatio!;
        }
        if (renderStyle.maxWidth != null && renderStyle.maxHeight == null) {
          maxHeight = maxWidth! * intrinsicRatio!;
        }
        if (renderStyle.minWidth == null && renderStyle.minHeight != null) {
          minWidth = minHeight / intrinsicRatio!;
        }
        if (renderStyle.maxWidth == null && renderStyle.maxHeight != null) {
          maxWidth = maxHeight! / intrinsicRatio!;
        }
      }

      _contentConstraints = BoxConstraints(
          minWidth: minWidth,
          maxWidth: maxWidth!,
          minHeight: minHeight,
          maxHeight: maxHeight!
      );
    } else {
      _contentConstraints = boxConstraints;
    }

    return _contentConstraints!;
  }

  /// Find scroll container
  RenderBoxModel? findScrollContainer() {
    RenderLayoutBox? scrollContainer;
    RenderLayoutBox? parent = this.parent as RenderLayoutBox?;

    while (parent != null) {
      if (parent.isScrollingContentBox) {
        // Scroll container should has definite constraints
        scrollContainer = parent.parent as RenderLayoutBox?;
        break;
      }
      parent = parent.parent as RenderLayoutBox?;
    }
    return scrollContainer;
  }

  @override
  void applyPaintTransform(RenderBox child, Matrix4 transform) {
    super.applyPaintTransform(child, transform);
    applyOverflowPaintTransform(child, transform);
    applyEffectiveTransform(child, transform);
  }

  // The max scrollable size.
  late Size _maxScrollableSize = Size.zero;
  Size get scrollableSize => _maxScrollableSize;
  set scrollableSize(Size value) {
    _maxScrollableSize = value;
  }

  late Size _scrollableViewportSize;
  Size get scrollableViewportSize => _scrollableViewportSize;
  set scrollableViewportSize(Size value) {
    _scrollableViewportSize = value;
  }

  // hooks when content box had layout.
  void didLayout() {
    if (clipX || clipY) {
      setUpOverflowScroller(scrollableSize, scrollableViewportSize);
    }

    if (positionedHolder != null && renderStyle.position != CSSPositionType.sticky) {
      // Make position holder preferred size equal to current element boundary size except sticky element.
      positionedHolder!.preferredSize = Size.copy(size);
    }

    // Positioned renderBoxModel will not trigger parent to relayout. Needs to update it's offset for itself.
    if (parentData is RenderLayoutParentData) {
      RenderLayoutParentData selfParentData = (parentData as RenderLayoutParentData?)!;
      RenderBoxModel parentBox = parent as RenderBoxModel;
      if (selfParentData.isPositioned && parentBox.hasSize) {
        CSSPositionedLayout.applyPositionedChildOffset(parentBox, this);
      }
    }

    needsLayout = false;
  }

  bool get isCSSDisplayNone {
    CSSDisplay? display = renderStyle.display;
    return display != null && display == CSSDisplay.none;
  }

  /// [RenderLayoutBox] real paint things after basiclly paint box model.
  /// Override which to paint layout or intrinsic things.
  /// Used by [RenderIntrinsic], [RenderFlowLayout], [RenderFlexLayout].
  void performPaint(PaintingContext context, Offset offset) {
    throw FlutterError('Please impl performPaint of $runtimeType.');
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (kProfileMode) {
      childPaintDuration = 0;
      PerformanceTiming.instance().mark(PERF_PAINT_START, uniqueId: targetId);
    }
    if (isCSSDisplayNone || isCSSVisibilityHidden) {
      if (kProfileMode) {
        PerformanceTiming.instance().mark(PERF_PAINT_END, uniqueId: targetId);
      }
      return;
    }

    paintBoxModel(context, offset);
    if (kProfileMode) {
      int amendEndTime = DateTime.now().microsecondsSinceEpoch - childPaintDuration;
      PerformanceTiming.instance().mark(PERF_PAINT_END, uniqueId: targetId, startTime: amendEndTime);
    }
  }

  void debugPaintOverlay(PaintingContext context, Offset offset) {
    Rect overlayRect = Rect.fromLTWH(offset.dx, offset.dy, size.width, size.height);
    context.addLayer(InspectorOverlayLayer(
      overlayRect: overlayRect,
    ));
  }

  void paintBoxModel(PaintingContext context, Offset offset) {
    // Paint fixed element to fixed position by compensating scroll offset
    double offsetY = scrollingOffsetY != null ? offset.dy + scrollingOffsetY! : offset.dy;
    double offsetX = scrollingOffsetX != null ? offset.dx + scrollingOffsetX! : offset.dx;
    offset = Offset(
      offsetX,
      offsetY
    );
    paintColorFilter(context, offset, _chainPaintImageFilter);
  }

  void _chainPaintImageFilter(PaintingContext context, Offset offset) {
    paintImageFilter(context, offset, _chainPaintIntersectionObserver);
  }

  void _chainPaintIntersectionObserver(PaintingContext context, Offset offset) {
    paintIntersectionObserver(context, offset, _chainPaintTransform);
  }

  void _chainPaintTransform(PaintingContext context, Offset offset) {
    paintTransform(context, offset, _chainPaintOpacity);
  }

  void _chainPaintOpacity(PaintingContext context, Offset offset) {
    paintOpacity(context, offset, _chainPaintDecoration);
  }

  void _chainPaintDecoration(PaintingContext context, Offset offset) {
    EdgeInsets? resolvedPadding = renderStyle.padding != null ? renderStyle.padding!.resolve(TextDirection.ltr) : null;
    paintDecoration(context, offset, resolvedPadding);
    _chainPaintOverflow(context, offset);
  }

  void ensureBoxSizeLargerThanScrollableSize() {
    double newBoxWidth = size.width;
    double newBoxHeight = size.height;

    if (scrollableSize.width > newBoxWidth) {
      newBoxWidth = scrollableSize.width;
    }
    if (scrollableSize.height > newBoxHeight) {
      newBoxHeight = scrollableSize.height;
    }

    size = Size(newBoxWidth, newBoxHeight);
  }

  void _chainPaintOverflow(PaintingContext context, Offset offset) {
    EdgeInsets borderEdge = EdgeInsets.fromLTRB(renderStyle.borderLeft, renderStyle.borderTop, renderStyle.borderRight, renderStyle.borderLeft);
    BoxDecoration? decoration = renderStyle.decoration;

    bool hasLocalAttachment = _hasLocalBackgroundImage(renderStyle);
    if (hasLocalAttachment) {
      paintOverflow(context, offset, borderEdge, decoration, _chainPaintBackground);
    } else {
      paintOverflow(context, offset, borderEdge, decoration, _chainPaintContentVisibility);
    }
  }

  void _chainPaintBackground(PaintingContext context, Offset offset) {
    EdgeInsets? resolvedPadding = renderStyle.padding != null ? renderStyle.padding!.resolve(TextDirection.ltr) : null;
    paintBackground(context, offset, resolvedPadding);
    _chainPaintContentVisibility(context, offset);
  }

  void _chainPaintContentVisibility(PaintingContext context, Offset offset) {
    paintContentVisibility(context, offset, _chainPaintOverlay);
  }

  void _chainPaintOverlay(PaintingContext context, Offset offset) {
    performPaint(context, offset);

    if (_debugShouldPaintOverlay) {
      debugPaintOverlay(context, offset);
    }
  }

  /// Compute distance to baseline
  double? computeDistanceToBaseline() {
    return null;
  }

  bool _hasLocalBackgroundImage(RenderStyle renderStyle) {
    return renderStyle.backgroundImage != null &&
      renderStyle.backgroundAttachment == LOCAL;
  }

  @override
  void detach() {
    disposePainter();
    super.detach();
  }

  /// Called when its corresponding element disposed
  void dispose() {
    // Clear renderObjects in list when disposed to avoid memory leak
    if (fixedChildren.length != 0) {
      fixedChildren.clear();
    }
  }

  Offset getTotalScrollOffset() {
    double top = scrollTop;
    double left = scrollLeft;
    AbstractNode? parentNode = parent;
    while (parentNode is RenderBoxModel) {
      top += (parentNode).scrollTop;
      left += (parentNode).scrollLeft;

      parentNode = parentNode.parent;
    }
    return Offset(left, top);
  }

  @override
  bool hitTest(BoxHitTestResult result, { required Offset position }) {
    if (!hasSize || !contentVisibilityHitTest(result, position: position) || !visibilityHitTest(result, position: position)) {
      return false;
    }

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

    bool isHit = result.addWithPaintTransform(
      transform: renderStyle.transform != null ? getEffectiveTransform() : null,
      position: position,
      hitTest: (BoxHitTestResult result, Offset trasformPosition) {
        return result.addWithPaintOffset(
          offset: (scrollLeft != 0.0 || scrollTop != 0.0) ? Offset(-scrollLeft, -scrollTop) : null,
          position: trasformPosition,
          hitTest: (BoxHitTestResult result, Offset position) {
            CSSPositionType positionType = renderStyle.position;
            if (positionType == CSSPositionType.fixed) {
              position -= getTotalScrollOffset();
            }

            // Determine whether the hittest position is within the visible area of the node in scroll.
            if ((clipX || clipY) && !size.contains(trasformPosition)) {
              return false;
            }

            // addWithPaintOffset is to add an offset to the child node, the calculation itself does not need to bring an offset.
            if (hitTestChildren(result, position: position) || hitTestSelf(trasformPosition)) {
              result.add(BoxHitTestEntry(this, position));
              return true;
            }
            return false;
          }
        );
      },
    );

    return isHit;
  }

  @override
  bool hitTestSelf(Offset position) {
    return size.contains(position);
  }

  Future<Image> toImage({ double pixelRatio = 1.0 }) {
    assert(layer != null);
    assert(isRepaintBoundary);
    final OffsetLayer offsetLayer = layer as OffsetLayer;
    return offsetLayer.toImage(Offset.zero & size, pixelRatio: pixelRatio);
  }

  @override
  void handleEvent(PointerEvent event, HitTestEntry entry) {
    super.handleEvent(event, entry);
    if (pointerListener != null) {
      pointerListener!(event);
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty('targetId', targetId, missingIfNull: true));
    properties.add(DiagnosticsProperty('contentSize', _contentSize));
    properties.add(DiagnosticsProperty('contentConstraints', _contentConstraints, missingIfNull: true));
    properties.add(DiagnosticsProperty('widthSizeType', widthSizeType, missingIfNull: true));
    properties.add(DiagnosticsProperty('heightSizeType', heightSizeType, missingIfNull: true));
    properties.add(DiagnosticsProperty('maxScrollableSize', scrollableSize, missingIfNull: true));

    if (renderPositionHolder != null) properties.add(DiagnosticsProperty('renderPositionHolder', renderPositionHolder));
    if (intrinsicWidth != null) properties.add(DiagnosticsProperty('intrinsicWidth', intrinsicWidth));
    if (intrinsicHeight != null) properties.add(DiagnosticsProperty('intrinsicHeight', intrinsicHeight));
    if (intrinsicRatio != null) properties.add(DiagnosticsProperty('intrinsicRatio', intrinsicRatio));

    debugBoxDecorationProperties(properties);
    debugVisibilityProperties(properties);
    debugOverflowProperties(properties);
    debugTransformProperties(properties);
    debugOpacityProperties(properties);
  }
}
