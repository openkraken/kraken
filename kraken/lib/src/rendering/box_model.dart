/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:kraken/css.dart';
import 'package:kraken/dom.dart';
import 'package:kraken/gesture.dart';
import 'package:kraken/kraken.dart';
import 'package:kraken/module.dart';
import 'package:kraken/rendering.dart';
import 'package:kraken/src/dom/sliver_manager.dart';

import 'debug_overlay.dart';

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
mixin RenderBoxContainerDefaultsMixin<ChildType extends RenderBox,
        ParentDataType extends ContainerBoxParentData<ChildType>>
    implements ContainerRenderObjectMixin<ChildType, ParentDataType> {
  /// Returns the baseline of the first child with a baseline.
  ///
  /// Useful when the children are displayed vertically in the same order they
  /// appear in the child list.
  double? defaultComputeDistanceToFirstActualBaseline(TextBaseline baseline) {
    assert(!debugNeedsLayout);
    ChildType? child = firstChild;
    while (child != null) {
      final ParentDataType? childParentData =
          child.parentData as ParentDataType?;
      // ignore: INVALID_USE_OF_PROTECTED_MEMBER
      final double? result = child.getDistanceToActualBaseline(baseline);
      if (result != null) return result + childParentData!.offset.dy;
      child = childParentData!.nextSibling;
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
  bool defaultHitTestChildren(BoxHitTestResult result, {Offset? position}) {
    // The x, y parameters have the top left of the node's box as the origin.

    // The z-index needs to be sorted, and higher-level nodes are processed first.
    List<RenderObject?> paintingOrder = (this as RenderLayoutBox).paintingOrder;
    for (int i = paintingOrder.length - 1; i >= 0; i--) {
      ChildType child = paintingOrder[i] as ChildType;
      // Ignore detached render object.
      if (!child.attached) {
        continue;
      }
      final ParentDataType childParentData = child.parentData as ParentDataType;
      final bool isHit = result.addWithPaintOffset(
        offset: childParentData.offset == Offset.zero
            ? null
            : childParentData.offset,
        position: position!,
        hitTest: (BoxHitTestResult result, Offset transformed) {
          assert(transformed == position - childParentData.offset);
          return child.hitTest(result, position: transformed);
        },
      );
      if (isHit) return true;
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
  List<ChildType> getChildren() {
    final List<ChildType> result = <ChildType>[];
    visitChildren((child) {
      if (child is! RenderPositionPlaceholder) {
        result.add(child as ChildType);
      }
    });
    return result;
  }
}

class RenderLayoutBox extends RenderBoxModel
  with
    ContainerRenderObjectMixin<RenderBox,
    ContainerBoxParentData<RenderBox>>,
    RenderBoxContainerDefaultsMixin<RenderBox,
    ContainerBoxParentData<RenderBox>> {
  RenderLayoutBox({required CSSRenderStyle renderStyle}) : super(renderStyle: renderStyle);

  // Host content which can be scrolled.
  RenderLayoutBox? get renderScrollingContent {
    if (firstChild is RenderLayoutBox) {
      RenderLayoutBox _firstChild = firstChild as RenderLayoutBox;
      if (_firstChild.isScrollingContentBox) {
        return _firstChild;
      }
    }
  }

  // No need to override [all] and [addAll] method cause they invoke [insert] method eventually.
  @override
  void insert(RenderBox child, {RenderBox? after}) {
    super.insert(child, after: after);
    _paintingOrder = null;
  }

  @override
  void remove(RenderBox child) {
    super.remove(child);
    _paintingOrder = null;
  }

  @override
  void removeAll() {
    super.removeAll();
    _paintingOrder = null;
  }

  @override
  void move(RenderBox child, {RenderBox? after}) {
    super.move(child, after: after);
    _paintingOrder = null;
  }

  @override
  void markNeedsLayout() {
    super.markNeedsLayout();

    // FlexItem layout must trigger flex container to layout.
    if (parent is RenderFlexLayout) {
      markParentNeedsLayout();
    }
  }

  // Sort children by zIndex, used for paint and hitTest.
  List<RenderBox>? _paintingOrder;
  List<RenderBox> get paintingOrder {
    if (_paintingOrder != null) {
      return _paintingOrder!;
    }

    if (childCount == 0) {
      // No child.
      return _paintingOrder = const [];
    } else if (childCount == 1) {
      // Only one child.
      final List<RenderBox> order = <RenderBox>[];
      order.add(firstChild!);
      return _paintingOrder = order;
    } else {
      // Sort by zIndex.
      List<RenderBox> children = getChildren();
      if (_childrenNeedsSort) {
        children.sort((RenderBox left, RenderBox right) {
          bool isLeftNeedsStacking = left is RenderBoxModel && left.needsStacking;
          bool isRightNeedsStacking = right is RenderBoxModel && right.needsStacking;
          if (!isLeftNeedsStacking && isRightNeedsStacking) {
            return 0 <= (right.renderStyle.zIndex ?? 0) ? -1 : 1;
          } else if (isLeftNeedsStacking && !isRightNeedsStacking) {
            return (left.renderStyle.zIndex ?? 0) < 0 ? -1 : 1;
          } else if (isLeftNeedsStacking && isRightNeedsStacking) {
            return (left.renderStyle.zIndex ?? 0) <= (right.renderStyle.zIndex ?? 0) ? -1 : 1;
          } else {
            return -1;
          }
        });
      }
      return _paintingOrder = children;
    }
  }

  bool _childrenNeedsSort = false;
  void markChildrenNeedsSort() {
    _childrenNeedsSort = true;
    _paintingOrder = null;
  }

  // Get all children as a list and detach them all.
  List<RenderBox> detachChildren() {
    List<RenderBox> children = getChildren();
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
      final ContainerParentDataMixin<RenderBox>? childParentData =
          child.parentData as ContainerParentDataMixin<RenderBox>?;
      if (child is! RenderBoxModel) {
        child = childParentData!.nextSibling;
        continue;
      }

      RenderBoxModel childRenderBoxModel = child;
      RenderStyle childRenderStyle = childRenderBoxModel.renderStyle;
      CSSOverflowType overflowX = childRenderStyle.effectiveOverflowX;
      CSSOverflowType overflowY = childRenderStyle.effectiveOverflowY;

      if (CSSPositionedLayout.isSticky(childRenderBoxModel)) {
        stickyChildren.add(child);
      }

      // No need to loop scrollable container children
      if (overflowX != CSSOverflowType.visible ||
          overflowY != CSSOverflowType.visible) {
        child = childParentData!.nextSibling;
        continue;
      }
      if (child is RenderLayoutBox) {
        List<RenderBoxModel> mergedChildren = child.findStickyChildren();
        for (RenderBoxModel child in mergedChildren) {
          stickyChildren.add(child);
        }
      }
      child = childParentData!.nextSibling;
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
      final RenderLayoutParentData childParentData =
          child.parentData as RenderLayoutParentData;

      // Whether child is inline-level including text box
      bool isChildInline = true;
      if (child is RenderBoxModel) {
        CSSDisplay? childTransformedDisplay =
            child.renderStyle.effectiveDisplay;
        if (childTransformedDisplay == CSSDisplay.block ||
            childTransformedDisplay == CSSDisplay.flex) {
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
          child is RenderBoxModel) {
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

  /// Common layout content size (including flow and flexbox layout) calculation logic
  Size getContentSize({
    double? logicalContentWidth,
    double? logicalContentHeight,
    required double contentWidth,
    required double contentHeight,
  }) {
    double finalContentWidth = contentWidth;
    double finalContentHeight = contentHeight;

    // Size which is specified by sizing styles
    double? specifiedContentWidth = logicalContentWidth;
    double? specifiedContentHeight = logicalContentHeight;
    // Flex basis takes priority over main size in flex item.
    if (parent is RenderFlexLayout) {
      RenderBoxModel? parentRenderBoxModel = parent as RenderBoxModel?;
      double? flexBasis = renderStyle.flexBasis == CSSLengthValue.auto ? null : renderStyle.flexBasis?.computedValue;
      if (flexBasis != null) {
        if (CSSFlex.isHorizontalFlexDirection(
            parentRenderBoxModel!.renderStyle.flexDirection)) {
          specifiedContentWidth = _getContentWidth(flexBasis);
        } else {
          specifiedContentHeight = _getContentHeight(flexBasis);
        }
      }
    }

    if (specifiedContentWidth != null) {
      finalContentWidth = math.max(specifiedContentWidth, contentWidth);
    }
    if (specifiedContentHeight != null) {
      finalContentHeight = math.max(specifiedContentHeight, contentHeight);
    }

    CSSDisplay? effectiveDisplay = renderStyle.effectiveDisplay;
    bool isInlineBlock = effectiveDisplay == CSSDisplay.inlineBlock;
    bool isNotInline = effectiveDisplay != CSSDisplay.inline;
    double? width = renderStyle.width.isAuto ? null : renderStyle.width.computedValue;
    double? height = renderStyle.height.isAuto ? null : renderStyle.height.computedValue;
    double? minWidth = renderStyle.minWidth.isAuto ? null : renderStyle.minWidth.computedValue;
    double? maxWidth = renderStyle.maxWidth.isNone ? null : renderStyle.maxWidth.computedValue;
    double? minHeight = renderStyle.minHeight.isAuto ? null : renderStyle.minHeight.computedValue;
    double? maxHeight = renderStyle.maxHeight.isNone ? null : renderStyle.maxHeight.computedValue;

    // Constrain to min-width or max-width if width not exists.
    if (isInlineBlock && maxWidth != null && width == null) {
      double maxContentWidth = _getContentWidth(maxWidth);
      finalContentWidth = finalContentWidth > maxContentWidth ? maxContentWidth : finalContentWidth;
    } else if (isInlineBlock && minWidth != null && width == null) {
      double minContentWidth = _getContentWidth(minWidth);
      finalContentWidth = finalContentWidth < minContentWidth ? minContentWidth : finalContentWidth;
    }

    // Constrain to min-height or max-height if height not exists.
    if (isNotInline && maxHeight != null && height == null) {
      double maxContentHeight = _getContentHeight(maxHeight);
      finalContentHeight = finalContentHeight > maxContentHeight ? maxContentHeight : finalContentHeight;
    } else if (isNotInline && minHeight != null && height == null) {
      double minContentHeight = _getContentWidth(minHeight);
      finalContentHeight = finalContentHeight < minContentHeight ? minContentHeight : finalContentHeight;
    }

    Size finalContentSize = Size(finalContentWidth, finalContentHeight);
    return finalContentSize;
  }

  /// Extend max scrollable size of renderBoxModel by offset of positioned child,
  /// get the max scrollable size of children of normal flow and single positioned child.
  void extendMaxScrollableSize(RenderBoxModel child) {
    Size? childScrollableSize;
    RenderStyle childRenderStyle = child.renderStyle;
    CSSOverflowType overflowX = childRenderStyle.effectiveOverflowX;
    CSSOverflowType overflowY = childRenderStyle.effectiveOverflowY;
    // Only non scroll container need to use scrollable size, otherwise use its own size
    if (overflowX == CSSOverflowType.visible &&
        overflowY == CSSOverflowType.visible) {
      childScrollableSize = child.scrollableSize;
    } else {
      childScrollableSize = child.boxSize;
    }
    double maxScrollableX = scrollableSize.width;
    double maxScrollableY = scrollableSize.height;
    if (childRenderStyle.left.isNotAuto) {
      maxScrollableX = math.max(maxScrollableX,
          childRenderStyle.left.computedValue + childScrollableSize!.width);
    }

    if (childRenderStyle.right.isNotAuto) {
      if (isScrollingContentBox &&
          (parent as RenderBoxModel).widthSizeType == BoxSizeType.specified) {
        RenderBoxModel overflowContainerBox = parent as RenderBoxModel;
        maxScrollableX = math.max(
            maxScrollableX,
            -childRenderStyle.right.computedValue +
                overflowContainerBox.renderStyle.width.computedValue -
                overflowContainerBox.renderStyle.effectiveBorderLeftWidth.computedValue -
                overflowContainerBox.renderStyle.effectiveBorderRightWidth.computedValue);
      } else {
        maxScrollableX = math.max(maxScrollableX,
            -childRenderStyle.right.computedValue + _contentSize!.width);
      }
    }

    if (childRenderStyle.top.isNotAuto) {
      maxScrollableY = math.max(maxScrollableY,
          childRenderStyle.top.computedValue + childScrollableSize!.height);
    }
    if (childRenderStyle.bottom.isNotAuto) {
      if (isScrollingContentBox &&
          (parent as RenderBoxModel).heightSizeType == BoxSizeType.specified) {
        RenderBoxModel overflowContainerBox = parent as RenderBoxModel;
        maxScrollableY = math.max(
            maxScrollableY,
            -childRenderStyle.bottom.computedValue +
                overflowContainerBox.renderStyle.height.computedValue -
                overflowContainerBox.renderStyle.effectiveBorderTopWidth.computedValue -
                overflowContainerBox.renderStyle.effectiveBorderBottomWidth.computedValue);
      } else {
        maxScrollableY = math.max(maxScrollableY,
            -childRenderStyle.bottom.computedValue + _contentSize!.height);
      }
    }
    scrollableSize = Size(maxScrollableX, maxScrollableY);
  }

  double _getContentWidth(double width) {
    return width - (renderStyle.borderLeftWidth?.computedValue ?? 0) -
      (renderStyle.borderRightWidth?.computedValue ?? 0) -
      renderStyle.paddingLeft.computedValue -
      renderStyle.paddingRight.computedValue;
  }

  double _getContentHeight(double height) {
    return height - (renderStyle.borderTopWidth?.computedValue ?? 0) -
      (renderStyle.borderBottomWidth?.computedValue ?? 0) -
      renderStyle.paddingTop.computedValue -
      renderStyle.paddingBottom.computedValue;
  }

  /// Convert to [RenderFlexLayout]
  RenderFlexLayout toFlexLayout() {
    RenderFlexLayout flexLayout = RenderFlexLayout(
      renderStyle: renderStyle,
    );
    copyWith(flexLayout);
    flexLayout.addAll(detachChildren());
    return flexLayout;
  }

  /// Convert to [RenderRepaintBoundaryFlexLayout]
  RenderRepaintBoundaryFlexLayout toRepaintBoundaryFlexLayout() {
    RenderRepaintBoundaryFlexLayout repaintBoundaryFlexLayout = RenderRepaintBoundaryFlexLayout(
      renderStyle: renderStyle,
    );
    copyWith(repaintBoundaryFlexLayout);
    repaintBoundaryFlexLayout.addAll(detachChildren());
    return repaintBoundaryFlexLayout;
  }

  /// Convert to [RenderFlowLayout]
  RenderFlowLayout toFlowLayout() {
    RenderFlowLayout flowLayout = RenderFlowLayout(
      renderStyle: renderStyle,
    );
    copyWith(flowLayout);
    flowLayout.addAll(detachChildren());
    return flowLayout;
  }

  /// Convert to [RenderRepaintBoundaryFlowLayout]
  RenderRepaintBoundaryFlowLayout toRepaintBoundaryFlowLayout() {
    RenderRepaintBoundaryFlowLayout repaintBoundaryFlowLayout = RenderRepaintBoundaryFlowLayout(
      renderStyle: renderStyle,
    );
    copyWith(repaintBoundaryFlowLayout);
    repaintBoundaryFlowLayout.addAll(detachChildren());
    return repaintBoundaryFlowLayout;
  }

  RenderSliverListLayout toSliverLayout(RenderSliverElementChildManager manager, ScrollListener? onScroll) {
    RenderSliverListLayout sliverListLayout = RenderSliverListLayout(
      renderStyle: renderStyle,
      manager: manager,
      onScroll: onScroll,
    );
    manager.setupSliverListLayout(sliverListLayout);
    copyWith(sliverListLayout);
    sliverListLayout.addAll(detachChildren());
    return sliverListLayout;
  }

  @override
  void dispose() {
    super.dispose();

    stickyChildren.clear();
    _paintingOrder = null;
  }

}

mixin RenderBoxModelBase on RenderBox {
  late CSSRenderStyle renderStyle;
  Size? boxSize;
}

class RenderBoxModel extends RenderBox
  with
    RenderBoxModelBase,
    RenderBoxDecorationMixin,
    RenderTransformMixin,
    RenderOverflowMixin,
    RenderOpacityMixin,
    RenderIntersectionObserverMixin,
    RenderContentVisibilityMixin,
    RenderPointerListenerMixin,
    RenderObjectWithControllerMixin {
  RenderBoxModel({
    required this.renderStyle,
  }) : super();

  @override
  bool get alwaysNeedsCompositing => opacityAlwaysNeedsCompositing();

  RenderPositionPlaceholder? renderPositionPlaceholder;

  bool _debugShouldPaintOverlay = false;

  @override
  late CSSRenderStyle renderStyle;

  bool get debugShouldPaintOverlay => _debugShouldPaintOverlay;

  set debugShouldPaintOverlay(bool value) {
    if (_debugShouldPaintOverlay != value) {
      _debugShouldPaintOverlay = value;
      markNeedsPaint();
    }
  }

  int childPaintDuration = 0;
  int childLayoutDuration = 0;

  BoxConstraints? _contentConstraints;

  BoxConstraints? get contentConstraints {
    assert(_contentConstraints != null);
    return _contentConstraints;
  }

  /// Used when setting percentage line-height style, it needs to be calculated when node attached
  /// where it needs to know the font-size of its own element
  bool _shouldLazyCalLineHeight = false;

  bool get shouldLazyCalLineHeight => _shouldLazyCalLineHeight;

  set shouldLazyCalLineHeight(bool value) {
    if (_shouldLazyCalLineHeight != value) {
      _shouldLazyCalLineHeight = value;
    }
  }

  // When RenderBoxModel is scrolling box, contentConstraints are always equal to BoxConstraints();
  bool isScrollingContentBox = false;

  bool _needsRecalculateStyle = false;
  void markNeedsRecalculateRenderStyle() {
    if (_needsRecalculateStyle)
      return;
    _needsRecalculateStyle = true;
  }

  BoxSizeType get widthSizeType {
    return renderStyle.width.isAuto ? BoxSizeType.automatic : BoxSizeType.specified;
  }

  BoxSizeType get heightSizeType {
    return renderStyle.height.isAuto ? BoxSizeType.automatic: BoxSizeType.specified;
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
  RenderPositionPlaceholder? positionedHolder;

  // https://developer.mozilla.org/en-US/docs/Web/CSS/CSS_Positioning/Understanding_z_index/The_stacking_context#the_stacking_context
  bool get needsStacking {
    return
      // Element with a position value absolute, relative, fixed or sticky.
      renderStyle.position != CSSPositionType.static ||
      // Element that is a child of a flex container with z-index value other than auto.
      (
        (renderStyle.parent!.display == CSSDisplay.flex ||
        renderStyle.parent!.display == CSSDisplay.inlineFlex) &&
        renderStyle.zIndex != null
      ) ||
      // Element with a opacity value less than 1.
      renderStyle.opacity < 1.0 ||
      // Element with a transform value.
      renderStyle.transform != null ||
      // Element with a filter value.
      renderStyle.filter != null;
  }

  T copyWith<T extends RenderBoxModel>(T copiedRenderBoxModel) {
    if (renderPositionPlaceholder != null) {
      renderPositionPlaceholder!.positioned = copiedRenderBoxModel;
    }

    return copiedRenderBoxModel
      // Copy render style
      ..renderStyle = renderStyle

      // Copy box decoration
      ..boxPainter = boxPainter

      // Copy overflow
      ..scrollListener = scrollListener
      ..scrollablePointerListener = scrollablePointerListener
      ..clipX = clipX
      ..clipY = clipY
      ..enableScrollX = enableScrollX
      ..enableScrollY = enableScrollY
      ..scrollOffsetX = scrollOffsetX
      ..scrollOffsetY = scrollOffsetY

      // Copy pointer listener
      ..getEventTarget = getEventTarget
      ..dispatchEvent = dispatchEvent
      ..getEventHandlers = getEventHandlers
      ..onClick = onClick
      ..onSwipe = onSwipe
      ..onPan = onPan
      ..onScale = onScale
      ..onLongPress = onLongPress
      ..onPointerSignal = onPointerSignal

      // Copy renderPositionHolder
      ..renderPositionPlaceholder = renderPositionPlaceholder

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
    _markSelfAndParentNeedsLayout();
  }

  // Boxes which have intrinsic ratio
  double? _intrinsicHeight;

  double? get intrinsicHeight {
    return _intrinsicHeight;
  }

  set intrinsicHeight(double? value) {
    if (_intrinsicHeight == value) return;
    _intrinsicHeight = value;
    _markSelfAndParentNeedsLayout();
  }

  double? _intrinsicRatio;

  double? get intrinsicRatio {
    return _intrinsicRatio;
  }

  set intrinsicRatio(double? value) {
    if (_intrinsicRatio == value) return;
    _intrinsicRatio = value;
    _markSelfAndParentNeedsLayout();
  }

  // Sizing may affect parent size, mark parent as needsLayout in case
  // renderBoxModel has tight constraints which will prevent parent from marking.
  void _markSelfAndParentNeedsLayout() {
    markNeedsLayout();
    if (parent is RenderBoxModel) {
      (parent as RenderBoxModel).markNeedsLayout();
    }
  }

  /// Whether current box is the root of the document which corresponds to HTML element in dom tree.
  bool get isDocumentRootBox {
    // Get the outer box of overflow scroll box
    RenderBoxModel currentBox = isScrollingContentBox ? parent as RenderBoxModel : this;
    // Root element of document is the child of viewport.
    return currentBox.parent is RenderViewportBox;
  }

  // Auto value for min-width
  double autoMinWidth = 0;

  // Auto value for min-height
  double autoMinHeight = 0;

  // Whether it needs relayout due to percentage calculation.
  bool needsRelayout = false;

  // Mark parent as needs relayout used in cases such as
  // child has percentage length and parent's size can not be calculated by style
  // thus parent needs relayout for its child calculate percentage length.
  void markParentNeedsRelayout() {
    RenderBoxModel? parent = this.parent as RenderBoxModel?;
    if (parent != null) {
      parent.needsRelayout = true;
    }
  }

  // Mirror debugNeedsLayout flag in Flutter to use in layout performance optimization
  bool needsLayout = false;

  @override
  void markNeedsLayout() {
    super.markNeedsLayout();
    needsLayout = true;
  }

  /// Mark children needs layout when drop child as Flutter did
  ///
  @override
  void dropChild(RenderBox child) {
    super.dropChild(child);
    // Loop to mark all the children to needsLayout as flutter did
    _syncChildNeedsLayoutFlag(child);
  }

  // @HACK: sync _needsLayout flag in Flutter to do performance opt.
  void syncNeedsLayoutFlag() {
    needsLayout = true;
    visitChildren(_syncChildNeedsLayoutFlag);
  }

  /// Mark specified renderBoxModel needs layout
  void _syncChildNeedsLayoutFlag(RenderObject child) {
    if (child is RenderBoxModel) {
      child.syncNeedsLayoutFlag();
    } else if (child is RenderTextBox) {
      child.syncNeedsLayoutFlag();
    }
  }

  @override
  void layout(Constraints newConstraints, {bool parentUsesSize = false}) {
    if (hasSize) {
      // Constraints changes between tight and no tight will cause reLayoutBoundary change
      // which will then cause its children to be marked as needsLayout in Flutter
      if ((newConstraints.isTight && !constraints.isTight) ||
          (!newConstraints.isTight && constraints.isTight)) {
        syncNeedsLayoutFlag();
      }
    }
    super.layout(newConstraints, parentUsesSize: parentUsesSize);
  }

  /// Calculate renderBoxModel constraints
  BoxConstraints getConstraints() {
    // Inner scrolling content box of overflow element inherits constraints from parent
    // but has indefinite max constraints to allow children overflow
    if (isScrollingContentBox) {
      RenderStyle parentRenderStyle = (parent as RenderBoxModel).renderStyle;
      EdgeInsets borderEdge = parentRenderStyle.border;
      EdgeInsetsGeometry? padding = parentRenderStyle.padding;
      double horizontalBorderLength = borderEdge.horizontal;
      double verticalBorderLength = borderEdge.vertical;
      double horizontalPaddingLength = padding.horizontal;
      double verticalPaddingLength = padding.vertical;

      BoxConstraints parentConstraints = (parent as RenderBoxModel).constraints;
      BoxConstraints constraints = BoxConstraints(
        minWidth: parentConstraints.maxWidth != double.infinity ?
          parentConstraints.maxWidth - horizontalBorderLength - horizontalPaddingLength : 0,
        maxWidth: double.infinity,
        minHeight: parentConstraints.maxHeight != double.infinity ?
          parentConstraints.maxHeight - verticalBorderLength - verticalPaddingLength : 0,
        maxHeight: double.infinity,
      );
      return constraints;
    }

    CSSDisplay? effectiveDisplay = renderStyle.effectiveDisplay;
    bool isDisplayInline = effectiveDisplay == CSSDisplay.inline;

    EdgeInsets borderEdge = renderStyle.border;
    EdgeInsetsGeometry? padding = renderStyle.padding;

    double horizontalBorderLength = borderEdge.horizontal;
    double verticalBorderLength = borderEdge.vertical;
    double horizontalPaddingLength = padding.horizontal;
    double verticalPaddingLength = padding.vertical;

    double? minWidth = renderStyle.minWidth.isAuto ? null : renderStyle.minWidth.computedValue;
    double? maxWidth = renderStyle.maxWidth.isNone ? null : renderStyle.maxWidth.computedValue;
    double? minHeight = renderStyle.minHeight.isAuto ? null : renderStyle.minHeight.computedValue;
    double? maxHeight = renderStyle.maxHeight.isNone ? null : renderStyle.maxHeight.computedValue;

    // Content size calculated from style
    logicalContentWidth = renderStyle.logicalContentWidth;
    logicalContentHeight = renderStyle.logicalContentHeight;

    // Box size calculated from style
    double? logicalWidth = logicalContentWidth != null
        ? logicalContentWidth! + horizontalPaddingLength + horizontalBorderLength
        : null;
    double? logicalHeight = logicalContentHeight != null
        ? logicalContentHeight! + verticalPaddingLength + verticalBorderLength
        : null;

    // Constraints
    // Width should be not smaller than border and padding in horizontal direction
    // when box-sizing is border-box which is only supported.
    double minConstraintWidth = renderStyle.effectiveBorderLeftWidth.computedValue + renderStyle.effectiveBorderRightWidth.computedValue +
      renderStyle.paddingLeft.computedValue + renderStyle.paddingRight.computedValue;
    double maxConstraintWidth = logicalWidth ?? double.infinity;
    // Height should be not smaller than border and padding in vertical direction
    // when box-sizing is border-box which is only supported.
    double minConstraintHeight = renderStyle.effectiveBorderTopWidth.computedValue + renderStyle.effectiveBorderBottomWidth.computedValue +
      renderStyle.paddingTop.computedValue + renderStyle.paddingBottom.computedValue;
    double maxConstraintHeight = logicalHeight ?? double.infinity;

    if (parent is RenderFlexLayout) {
      double? flexBasis = renderStyle.flexBasis == CSSLengthValue.auto ? null : renderStyle.flexBasis?.computedValue;
      RenderBoxModel? parentRenderBoxModel = parent as RenderBoxModel?;
      // In flex layout, flex basis takes priority over width/height if set.
      // Flex-basis cannot be smaller than its content size which happens can not be known
      // in constraints apply stage, so flex-basis acts as min-width in constraints apply stage.
      if (flexBasis != null) {
        if (CSSFlex.isHorizontalFlexDirection(
            parentRenderBoxModel!.renderStyle.flexDirection)) {
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
        minConstraintWidth =
            minConstraintWidth < minWidth ? minWidth : minConstraintWidth;
      }
      if (maxWidth != null) {
        maxConstraintWidth =
            maxConstraintWidth > maxWidth ? maxWidth : maxConstraintWidth;
      }
      if (minHeight != null) {
        minConstraintHeight =
            minConstraintHeight < minHeight ? minHeight : minConstraintHeight;
      }
      if (maxHeight != null) {
        maxConstraintHeight =
            maxConstraintHeight > maxHeight ? maxHeight : maxConstraintHeight;
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

  /// Set the size of scrollable overflow area of renderBoxModel
  void setMaxScrollableSize(Size contentSize) {
    // Scrollable area includes right and bottom padding
    scrollableSize = Size(
      contentSize.width + renderStyle.paddingLeft.computedValue,
      contentSize.height + renderStyle.paddingTop.computedValue
    );
  }

  // Box size equals to RenderBox.size to avoid flutter complain when read size property.
  Size? _boxSize;

  @override
  Size? get boxSize {
    assert(_boxSize != null, 'box does not have laid out.');
    return _boxSize;
  }

  @override
  set size(Size value) {
    _boxSize = value;
    super.size = value;
  }

  Size getBoxSize(Size contentSize) {
    _contentSize = contentConstraints!.constrain(contentSize);
    Size paddingBoxSize = renderStyle.wrapPaddingSize(_contentSize!);
    Size borderBoxSize = renderStyle.wrapBorderSize(paddingBoxSize);
    return constraints.constrain(borderBoxSize);
  }

  // The contentSize of layout box
  Size? _contentSize;
  Size get contentSize => _contentSize ?? Size.zero;

  /// Logical content width calculated from style
  double? logicalContentWidth;

  /// Logical content height calculated from style
  double? logicalContentHeight;

  double get clientWidth {
    double width = contentSize.width;
    width += renderStyle.padding.horizontal;
    return width;
  }

  double get clientHeight {
    double height = contentSize.height;
    height += renderStyle.padding.vertical;

    return height;
  }

  // Base layout methods to compute content constraints before content box layout.
  // Call this method before content box layout.
  void beforeLayout() {
    BoxConstraints boxConstraints = constraints;
    // Deflate border constraints.
    boxConstraints = renderStyle.deflateBorderConstraints(boxConstraints);

    // Deflate padding constraints.
    boxConstraints = renderStyle.deflatePaddingConstraints(boxConstraints);

    logicalContentWidth = renderStyle.logicalContentWidth;
    logicalContentHeight = renderStyle.logicalContentHeight;

    if (!isScrollingContentBox && (logicalContentWidth != null || logicalContentHeight != null)) {
      double minWidth;
      double? maxWidth;
      double minHeight;
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
        if (!renderStyle.minWidth.isAuto && renderStyle.minHeight.isAuto) {
          minHeight = minWidth * intrinsicRatio!;
        }
        if (!renderStyle.maxWidth.isNone && renderStyle.maxHeight.isNone) {
          maxHeight = maxWidth! * intrinsicRatio!;
        }
        if (renderStyle.minWidth.isAuto && !renderStyle.minHeight.isAuto) {
          minWidth = minHeight / intrinsicRatio!;
        }
        if (renderStyle.maxWidth.isNone && !renderStyle.maxHeight.isNone) {
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
  Size _maxScrollableSize = Size.zero;

  Size get scrollableSize => _maxScrollableSize;

  set scrollableSize(Size value) {
    _maxScrollableSize = value;
  }

  late Size _scrollableViewportSize;

  Size get scrollableViewportSize => _scrollableViewportSize;

  set scrollableViewportSize(Size value) {
    _scrollableViewportSize = value;
  }

  // Hooks when content box had layout.
  void didLayout() {
    if (clipX || clipY) {
      scrollableViewportSize = Size(
        _contentSize!.width +
          renderStyle.paddingLeft.computedValue +
          renderStyle.paddingRight.computedValue,
        _contentSize!.height +
          renderStyle.paddingTop.computedValue +
          renderStyle.paddingBottom.computedValue);

      setUpOverflowScroller(scrollableSize, scrollableViewportSize);
    }

    if (positionedHolder != null &&
        renderStyle.position != CSSPositionType.sticky) {
      // Make position holder preferred size equal to current element boundary size except sticky element.
      positionedHolder!.preferredSize = Size.copy(size);
    }

    // Positioned renderBoxModel will not trigger parent to relayout. Needs to update it's offset for itself.
    if (parentData is RenderLayoutParentData) {
      RenderLayoutParentData selfParentData =
          parentData as RenderLayoutParentData;
      RenderBoxModel? parentBox = parent as RenderBoxModel?;
      if (selfParentData.isPositioned && parentBox!.hasSize) {
        CSSPositionedLayout.applyPositionedChildOffset(parentBox, this);
      }
    }

    needsLayout = false;
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
      PerformanceTiming.instance().mark(PERF_PAINT_START, uniqueId: hashCode);
    }
    if (renderStyle.isVisibilityHidden) {
      if (kProfileMode) {
        PerformanceTiming.instance().mark(PERF_PAINT_END, uniqueId: hashCode);
      }
      return;
    }

    paintBoxModel(context, offset);
    if (kProfileMode) {
      int amendEndTime =
          DateTime.now().microsecondsSinceEpoch - childPaintDuration;
      PerformanceTiming.instance()
          .mark(PERF_PAINT_END, uniqueId: hashCode, startTime: amendEndTime);
    }
  }

  void debugPaintOverlay(PaintingContext context, Offset offset) {
    Rect overlayRect =
        Rect.fromLTWH(offset.dx, offset.dy, size.width, size.height);
    context.addLayer(InspectorOverlayLayer(
      overlayRect: overlayRect,
    ));
  }

  void paintColorFilter(PaintingContext context, Offset offset, PaintingContextCallback callback) {
    ColorFilter? colorFilter = renderStyle.colorFilter;
    if (colorFilter != null) {
      context.pushColorFilter(offset, colorFilter, callback);
    } else {
      callback(context, offset);
    }
  }

  void paintBoxModel(PaintingContext context, Offset offset) {

    if (isScrollingContentBox) {
      // Scrolling content box should only size painted.
      performPaint(context, offset);
    } else {
      // Paint fixed element to fixed position by compensating scroll offset
      double offsetY =
          scrollingOffsetY != null ? offset.dy + scrollingOffsetY! : offset.dy;
      double offsetX =
          scrollingOffsetX != null ? offset.dx + scrollingOffsetX! : offset.dx;
      offset = Offset(offsetX, offsetY);
      paintColorFilter(context, offset, _chainPaintImageFilter);
    }
  }

  ImageFilterLayer? _imageFilterLayer;
  void paintImageFilter(PaintingContext context, Offset offset,
      PaintingContextCallback callback) {
    if (renderStyle.imageFilter != null) {
      _imageFilterLayer ??= ImageFilterLayer();
      _imageFilterLayer!.imageFilter = renderStyle.imageFilter;
      context.pushLayer(_imageFilterLayer!, callback, offset);
    } else {
      callback(context, offset);
    }
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
    EdgeInsets? resolvedPadding = renderStyle.padding.resolve(TextDirection.ltr);
    paintDecoration(context, offset, resolvedPadding);
    _chainPaintOverflow(context, offset);
  }

  // For scrolling box, the minimum width and height should not less than scrollableSize
  void ensureBoxSizeLargerThanScrollableSize() {
    if (isScrollingContentBox) {
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
  }

  void _chainPaintOverflow(PaintingContext context, Offset offset) {
    EdgeInsets borderEdge = EdgeInsets.fromLTRB(
        renderStyle.effectiveBorderLeftWidth.computedValue,
        renderStyle.effectiveBorderTopWidth.computedValue,
        renderStyle.effectiveBorderRightWidth.computedValue,
        renderStyle.effectiveBorderLeftWidth.computedValue);
    BoxDecoration? decoration = renderStyle.decoration;

    bool hasLocalAttachment = _hasLocalBackgroundImage(renderStyle);
    if (hasLocalAttachment) {
      paintOverflow(
          context, offset, borderEdge, decoration, _chainPaintBackground);
    } else {
      paintOverflow(context, offset, borderEdge, decoration,
          _chainPaintContentVisibility);
    }
  }

  void _chainPaintBackground(PaintingContext context, Offset offset) {
    EdgeInsets resolvedPadding = renderStyle.padding.resolve(TextDirection.ltr);
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

  bool _hasLocalBackgroundImage(CSSRenderStyle renderStyle) {
    return renderStyle.backgroundImage != null &&
        renderStyle.backgroundAttachment == CSSBackgroundAttachmentType.local;
  }

  void _detachAllChildren() {
    if (this is RenderObjectWithChildMixin) {
      (this as RenderObjectWithChildMixin).child = null;
    } else if (this is ContainerRenderObjectMixin) {
      (this as ContainerRenderObjectMixin).removeAll();
    }
  }

  /// Called when its corresponding element disposed
  @mustCallSuper
  void dispose() {
    // Clear renderObjects in list when disposed to avoid memory leak
    if (fixedChildren.isNotEmpty) {
      fixedChildren.clear();
    }

    // Dispose scroll behavior
    disposeScrollable();

    // Dispose box decoration painter.
    disposePainter();
    // Evict render decoration image cache.
    renderStyle.decoration?.image?.image.evict();

    // Remove reference from childs
    _detachAllChildren();
  }

  Offset getTotalScrollOffset() {
    double top = scrollTop;
    double left = scrollLeft;
    AbstractNode? parentNode = parent;
    while (parentNode is RenderBoxModel) {
      top += parentNode.scrollTop;
      left += parentNode.scrollLeft;

      parentNode = parentNode.parent;
    }
    return Offset(left, top);
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    if (!hasSize ||
        !contentVisibilityHitTest(result, position: position) ||
        renderStyle.isVisibilityHidden) {
      return false;
    }

    assert(() {
      if (!hasSize) {
        if (debugNeedsLayout) {
          throw FlutterError.fromParts(<DiagnosticsNode>[
            ErrorSummary(
                'Cannot hit test a render box that has never been laid out.'),
            describeForError(
                'The hitTest() method was called on this RenderBox'),
            ErrorDescription(
                "Unfortunately, this object's geometry is not known at this time, "
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
          ErrorDescription(
              'Although this node is not marked as needing layout, '
              'its size is not set.'),
          ErrorHint('A RenderBox object must have an '
              'explicit size before it can be hit-tested. Make sure '
              'that the RenderBox in question sets its size during layout.'),
        ]);
      }
      return true;
    }());

    bool isHit = result.addWithPaintTransform(
      transform: renderStyle.transformMatrix != null ? getEffectiveTransform() : null,
      position: position,
      hitTest: (BoxHitTestResult result, Offset trasformPosition) {
        return result.addWithPaintOffset(
            offset: (scrollLeft != 0.0 || scrollTop != 0.0)
                ? Offset(-scrollLeft, -scrollTop)
                : null,
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
              if (hitTestChildren(result, position: position) ||
                  hitTestSelf(trasformPosition)) {
                result.add(BoxHitTestEntry(this, position));
                return true;
              }
              return false;
            });
      },
    );

    return isHit;
  }

  /// Get the root box model of document which corresponds to html element.
  RenderBoxModel? getRootBoxModel() {
    RenderBoxModel _self = this;
    while (_self.parent != null && _self.parent is! RenderViewportBox) {
      _self = _self.parent as RenderBoxModel;
    }
    return _self.parent is RenderViewportBox ? _self : null;
  }

  @override
  bool hitTestSelf(Offset position) {
    return size.contains(position);
  }

  Future<Image> toImage({double pixelRatio = 1.0}) {
    assert(layer != null);
    assert(isRepaintBoundary);
    final OffsetLayer offsetLayer = layer as OffsetLayer;
    return offsetLayer.toImage(Offset.zero & size, pixelRatio: pixelRatio);
  }

  @override
  void handleEvent(PointerEvent event, HitTestEntry entry) {
    super.handleEvent(event, entry);
    if (scrollablePointerListener != null) {
      scrollablePointerListener!(event);
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty('contentSize', _contentSize));
    properties.add(DiagnosticsProperty(
        'contentConstraints', _contentConstraints,
        missingIfNull: true));
    properties.add(DiagnosticsProperty('widthSizeType', widthSizeType,
        missingIfNull: true));
    properties.add(DiagnosticsProperty('heightSizeType', heightSizeType,
        missingIfNull: true));
    properties.add(DiagnosticsProperty('maxScrollableSize', scrollableSize,
        missingIfNull: true));

    if (renderPositionPlaceholder != null)
      properties.add(
          DiagnosticsProperty('renderPositionHolder', renderPositionPlaceholder));
    if (intrinsicWidth != null)
      properties.add(DiagnosticsProperty('intrinsicWidth', intrinsicWidth));
    if (intrinsicHeight != null)
      properties.add(DiagnosticsProperty('intrinsicHeight', intrinsicHeight));
    if (intrinsicRatio != null)
      properties.add(DiagnosticsProperty('intrinsicRatio', intrinsicRatio));

    debugBoxDecorationProperties(properties);
    debugVisibilityProperties(properties);
    debugOverflowProperties(properties);
    debugTransformProperties(properties);
    debugOpacityProperties(properties);
  }
}
