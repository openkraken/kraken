/*
 * Copyright (C) 2020-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:ui';
import 'package:kraken/module.dart';
import 'package:meta/meta.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

import 'package:kraken/css.dart';
import 'package:kraken/rendering.dart';
import 'package:kraken/dom.dart';
import 'package:kraken/gesture.dart';

class RenderRecyclerParentData extends RenderLayoutParentData {}

class RenderRecyclerLayout extends RenderLayoutBox
    implements RenderSliverBoxChildManager {
  static Axis resolveAxis(CSSStyleDeclaration style) {
    String? sliverDirection = style[SLIVER_DIRECTION];
    switch (sliverDirection) {
      case ROW:
        return Axis.horizontal;

      case COLUMN:
      default:
        return Axis.vertical;
    }
  }

  RenderRecyclerLayout({
    required RenderStyle renderStyle,
    required ElementDelegate elementDelegate
  }) : super(
    renderStyle: renderStyle,
    elementDelegate: elementDelegate
  ) {
    _buildRenderViewport();
    super.insert(renderViewport!);
  }

  @override
  bool get isRepaintBoundary => true;

  RenderViewport? renderViewport;
  RenderSliverList? _renderSliverList;

  // Children renderBox list of element when element is created,
  // not correspond to the real renderObject.
  final List<RenderBox> _children = List.empty(growable: true);

  @override
  void add(RenderBox? child) {
    if (child is RenderBoxModel) {
      _children.add(child);
    }
  }

  @override
  void insert(RenderBox child, {RenderBox? after}) {
    // Append to last.
    if (after == renderViewport) {
      return add(child);
    }

    if (child is RenderBoxModel) {
      int? index;
      if (after == null) {
        index = 0;
      } else if (after is RenderBoxModel) {
        index = _children.indexOf(after);
      }

      if (index != null) {
        _children.insert(index, child);
      }
    }
  }

  @override
  void addAll(List<RenderBox?>? children) {
    assert(children != null);
    children!.forEach(add);
  }

  @override
  void remove(RenderBox child) {
    if (child is RenderBoxModel) {
      _children.remove(child);
    }

    assert(_renderSliverList != null);
    _renderSliverList!.remove(child);
  }

  @override
  void removeAll() {
    _renderSliverList!.removeAll();
    _children.clear();
  }

  @override
  void move(RenderBox child, {RenderBox? after}) {
    assert(_renderSliverList != null);
    remove(child);
    insert(child, after: after);
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! RenderRecyclerParentData) {
      child.parentData = RenderRecyclerParentData();
    }
  }

  KrakenScrollable? scrollable;

  @protected
  RenderViewport _buildRenderViewport() {
    pointerListener = _pointerListener;
    Axis sliverAxis = renderStyle.sliverAxis;

    AxisDirection axisDirection = getAxisDirection(sliverAxis);
    scrollable = KrakenScrollable(axisDirection: axisDirection);

    return renderViewport = RenderViewport(
      offset: scrollable!.position!,
      axisDirection: axisDirection,
      crossAxisDirection: getCrossAxisDirection(sliverAxis),
      children: [_buildRenderSliverList()],
      cacheExtent: kReleaseMode ? null : 0.0,
    );
  }

  void _pointerListener(PointerEvent event) {
    if (event is PointerDownEvent) {
      scrollable?.handlePointerDown(event);
    }
  }

  static AxisDirection getAxisDirection(Axis sliverAxis) {
    switch (sliverAxis) {
      case Axis.horizontal:
        return AxisDirection.right;
      case Axis.vertical:
      default:
        return AxisDirection.down;
    }
  }

  static AxisDirection getCrossAxisDirection(Axis sliverAxis) {
    switch (sliverAxis) {
      case Axis.horizontal:
        return AxisDirection.down;
      case Axis.vertical:
      default:
        return AxisDirection.right;
    }
  }

  @protected
  RenderSliverList _buildRenderSliverList() {
    return _renderSliverList = RenderSliverList(childManager: this);
  }

  Size get _screenSize => window.physicalSize / window.devicePixelRatio;

  @override
  void performLayout() {
    if (kProfileMode) {
      childLayoutDuration = 0;
      PerformanceTiming.instance()
          .mark(PERF_SILVER_LAYOUT_START, uniqueId: hashCode);
    }

    beforeLayout();

    // If width is given, use exact width; or expand to parent extent width.
    // If height is given, use exact height; or use 0.
    // Only layout [renderViewport] as only-child.
    RenderBox? child = renderViewport;
    late BoxConstraints childConstraints;

    double? width = renderStyle.width;
    double? height = renderStyle.height;
    Axis sliverAxis = renderStyle.sliverAxis;

    switch (sliverAxis) {
      case Axis.horizontal:
        childConstraints = BoxConstraints(
          maxWidth: width ?? 0.0,
          maxHeight: height ?? _screenSize.height,
        );
        break;
      case Axis.vertical:
        childConstraints = BoxConstraints(
          maxWidth: width ?? _screenSize.width,
          maxHeight: height ?? 0.0,
        );
        break;
    }

    late DateTime childLayoutStart;
    if (kProfileMode) {
      childLayoutStart = DateTime.now();
    }

    child!.layout(childConstraints, parentUsesSize: true);

    if (kProfileMode) {
      DateTime childLayoutEnd = DateTime.now();
      childLayoutDuration += (childLayoutEnd.microsecondsSinceEpoch -
          childLayoutStart.microsecondsSinceEpoch);
    }

    size = getBoxSize(child.size);

    didLayout();

    if (kProfileMode) {
      PerformanceTiming.instance().mark(PERF_SILVER_LAYOUT_END,
          uniqueId: hashCode,
          startTime:
              DateTime.now().microsecondsSinceEpoch - childLayoutDuration);
    }
  }

  @override
  void performPaint(PaintingContext context, Offset offset) {
    if (renderStyle.padding != null) {
      offset += Offset(renderStyle.paddingLeft, renderStyle.paddingTop);
    }

    if (renderStyle.borderEdge != null) {
      offset += Offset(renderStyle.borderLeft, renderStyle.borderTop);
    }

    if (firstChild != null) {
      late DateTime childPaintStart;
      if (kProfileMode) {
        childPaintStart = DateTime.now();
      }
      context.paintChild(firstChild!, offset);
      if (kProfileMode) {
        DateTime childPaintEnd = DateTime.now();
        childPaintDuration += (childPaintEnd.microsecondsSinceEpoch -
            childPaintStart.microsecondsSinceEpoch);
      }
    }
  }

  Offset getChildScrollOffset(RenderObject child, Offset offset) {
    final RenderLayoutParentData? childParentData =
        child.parentData as RenderLayoutParentData?;
    bool isChildFixed = child is RenderBoxModel
        ? child.renderStyle.position == CSSPositionType.fixed
        : false;
    // Fixed elements always paint original offset
    Offset scrollOffset = isChildFixed
        ? childParentData!.offset
        : childParentData!.offset + offset;
    return scrollOffset;
  }

  // RenderSliverBoxChildManager protocol.

  /// Useful to determine whether newly added children could
  /// affect the visible contents of this class.
  bool _didUnderflow = false;

  /// Child count should rely on element's childNodes, the real
  /// child renderObject count is not exactly.
  @override
  int get childCount => _children.length;

  int? _currentIndex;

  @override
  void createChild(int index, {RenderBox? after}) {
    if (_didUnderflow) return;
    if (index >= childCount) return;
    _currentIndex = index;

    if (index < 0) return;
    if (childCount <= index) return;

    RenderBox refChild = _children[index];
    RenderBoxModel child;
    if (refChild is RenderBoxModel) {
      child = refChild.elementDelegate.beforeRendererAttach() as RenderBoxModel;
      child.parentData = SliverMultiBoxAdaptorParentData();
      _renderSliverList!.insert(child, after: after);
      child.elementDelegate.afterRendererAttach();
    }
  }

  @override
  void removeChild(RenderBox child) {
    if (child is RenderBoxModel) {
      child.elementDelegate.detachRenderer();
    } else {
      child.detach();
    }
  }

  @override
  void didAdoptChild(RenderBox child) {
    final parentData = child.parentData as SliverMultiBoxAdaptorParentData;
    parentData.index = _currentIndex;
  }

  @override
  void setDidUnderflow(bool value) {
    _didUnderflow = value;
  }

  @override
  bool debugAssertChildListLocked() => true;

  /// Called at the beginning of layout to indicate that layout is about to
  /// occur.
  @override
  void didStartLayout() {}

  /// Called at the end of layout to indicate that layout is now complete.
  @override
  void didFinishLayout() {}

  @override
  double estimateMaxScrollOffset(
    SliverConstraints constraints, {
    int? firstIndex,
    int? lastIndex,
    double? leadingScrollOffset,
    double? trailingScrollOffset,
  }) {
    return _extrapolateMaxScrollOffset(firstIndex, lastIndex,
        leadingScrollOffset, trailingScrollOffset, childCount)!;
  }

  static double? _extrapolateMaxScrollOffset(
    int? firstIndex,
    int? lastIndex,
    double? leadingScrollOffset,
    double? trailingScrollOffset,
    int childCount,
  ) {
    if (lastIndex == childCount - 1) {
      return trailingScrollOffset;
    }

    final int reifiedCount = lastIndex! - firstIndex! + 1;
    final double averageExtent =
        (trailingScrollOffset! - leadingScrollOffset!) / reifiedCount;
    final int remainingCount = childCount - lastIndex - 1;
    return trailingScrollOffset + averageExtent * remainingCount;
  }

  RenderFlexLayout toFlexLayout() {
    List<RenderObject?> children = getDetachedChildrenAsList();
    RenderFlexLayout renderFlexLayout = RenderFlexLayout(
      children: children as List<RenderBox>?,
      renderStyle: renderStyle,
      elementDelegate: elementDelegate,
    );
    return copyWith(renderFlexLayout);
  }

  RenderFlowLayout toFlowLayout() {
    List<RenderObject?> children = getDetachedChildrenAsList();
    RenderFlowLayout renderFlowLayout = RenderFlowLayout(
      renderStyle: renderStyle,
      elementDelegate: elementDelegate,
    );
    renderFlowLayout.addAll(children as List<RenderBox>?);
    return copyWith(renderFlowLayout);
  }
}
