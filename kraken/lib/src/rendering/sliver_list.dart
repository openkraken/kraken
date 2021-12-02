/*
 * Copyright (C) 2020-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:kraken/css.dart';
import 'package:kraken/gesture.dart';
import 'package:kraken/module.dart';
import 'package:kraken/rendering.dart';
import 'package:kraken/src/dom/sliver_manager.dart';
import 'package:meta/meta.dart';

class RenderSliverListLayout extends RenderLayoutBox {
  // Expose viewport for sliver mixin.
  RenderViewport get viewport => _renderViewport;
  // The viewport for sliver.
  late RenderViewport _renderViewport;

  // The sliver list render object reference.
  late RenderSliverList _renderSliverList;

  // The scrollable context to handle gestures.
  late KrakenScrollable scrollable;

  // Called if scrolling pixel has moved.
  final ScrollListener? _scrollListener;

  // The main axis for sliver list layout.
  Axis axis = Axis.vertical;

  // The sliver box child manager
  final RenderSliverBoxChildManager _renderSliverBoxChildManager;

  RenderSliverListLayout({
    required CSSRenderStyle renderStyle,
    required RenderSliverElementChildManager manager,
    ScrollListener? onScroll,
  }) : _renderSliverBoxChildManager = manager,
       _scrollListener = onScroll,
        super(renderStyle: renderStyle) {
    scrollablePointerListener = _scrollablePointerListener;
    scrollable = KrakenScrollable(axisDirection: getAxisDirection(axis));
    axis = renderStyle.sliverDirection;

    switch (axis) {
      case Axis.horizontal:
        scrollOffsetX = scrollable.position;
        scrollOffsetY = null;
        break;
      case Axis.vertical:
        scrollOffsetX = null;
        scrollOffsetY = scrollable.position;
        break;
    }

    _renderSliverList = _buildRenderSliverList();
    _renderViewport = RenderViewport(
      offset: scrollable.position!,
      axisDirection: scrollable.axisDirection,
      crossAxisDirection: getCrossAxisDirection(axis),
      children: [_renderSliverList],
    );
    manager.setupSliverListLayout(this);
    super.insert(_renderViewport);
  }

  @override
  ScrollListener? get scrollListener => _scrollListener;

  @override
  bool get isRepaintBoundary => true;

  // Override box model methods, give the control right to sliver list.
  @override
  void add(RenderBox child) {}

  @override
  void insert(RenderBox child, {RenderBox? after}) {}

  @override
  void addAll(List<RenderBox>? children) {}

  // Insert render box child as sliver child.
  void insertSliverChild(RenderBox child, { RenderBox? after }) {
    setupParentData(child);
    _renderSliverList.insert(child, after: after);
  }

  @override
  void remove(RenderBox child) {
    if (child == _renderViewport) {
      super.remove(child);
    } else if (child.parent == _renderSliverList) {
      _renderSliverList.remove(child);
    }
  }

  @override
  void removeAll() {
    _renderSliverList.removeAll();
  }

  @override
  void move(RenderBox child, {RenderBox? after}) {
    if (child.parent == _renderSliverList) {
      remove(child);
      insertSliverChild(child, after: after);
    }
  }

  @override
  void setupParentData(RenderBox child) {
    if (child == _renderViewport && child.parentData is ! RenderLayoutParentData) {
      child.parentData = RenderLayoutParentData();
    } else if (child.parentData is! SliverMultiBoxAdaptorParentData) {
      child.parentData = SliverMultiBoxAdaptorParentData();
    }
  }

  void _scrollablePointerListener(PointerEvent event) {
    if (event is PointerDownEvent) {
      scrollable.handlePointerDown(event);
    }
  }

  @protected
  RenderSliverList _buildRenderSliverList() {
    return _renderSliverList = RenderSliverList(childManager: _renderSliverBoxChildManager);
  }

  /// Child count should rely on element's childNodes, the real
  /// child renderObject count is not exactly.
  @override
  int get childCount => _renderSliverBoxChildManager.childCount;

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
    RenderBox? child = _renderViewport;
    late BoxConstraints childConstraints;

    double? width = renderStyle.width.isAuto ? null : renderStyle.width.computedValue;
    double? height = renderStyle.height.isAuto ? null : renderStyle.height.computedValue;
    Axis sliverAxis = renderStyle.sliverDirection;

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

    child.layout(childConstraints, parentUsesSize: true);

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

    offset += Offset(renderStyle.paddingLeft.computedValue, renderStyle.paddingTop.computedValue);

    offset += Offset(renderStyle.effectiveBorderLeftWidth.computedValue, renderStyle.effectiveBorderTopWidth.computedValue);

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

  @override
  bool hitTestChildren(BoxHitTestResult result, { required Offset position }) {
    // The x, y parameters have the top left of the node's box as the origin.
    // Get the sliver content scrolling offset.
    final Offset currentOffset = Offset(scrollLeft, scrollTop);

    // The z-index needs to be sorted, and higher-level nodes are processed first.
    for (int i = paintingOrder.length - 1; i >= 0; i--) {
      RenderBox child = paintingOrder[i];
      // Ignore detached render object.
      if (!child.attached) continue;

      final ContainerBoxParentData childParentData = child.parentData as ContainerBoxParentData;
      final bool isHit = result.addWithPaintOffset(
        offset: childParentData.offset + currentOffset,
        position: position,
        hitTest: (BoxHitTestResult result, Offset transformed) {
          return child.hitTest(result, position: transformed);
        },
      );
      if (isHit) return true;
    }

    return false;
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
}
