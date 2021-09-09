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

class RenderRecyclerLayout extends RenderLayoutBox {
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
  Axis axis = Axis.vertical;

  @override
  void add(RenderBox child) {}

  @override
  void insert(RenderBox child, {RenderBox? after}) {}

  @override
  void addAll(List<RenderBox>? children) {}

  void insertIntoSliver(RenderBox child, { RenderBox? after }) {
    setupParentData(child);
    _renderSliverList!.insert(child, after: after);
  }

  @override
  void remove(RenderBox child) {
    if (child == renderViewport) {
      super.remove(child);
    } else if (child.parent == _renderSliverList) {
      assert(_renderSliverList != null);
      _renderSliverList!.remove(child);
    }
  }

  @override
  void removeAll() {
    _renderSliverList!.removeAll();
  }

  @override
  void move(RenderBox child, {RenderBox? after}) {
    assert(_renderSliverList != null);
    if (child.parent == _renderSliverList) {
      remove(child);
      insertIntoSliver(child, after: after);
    }
  }

  @override
  void setupParentData(RenderBox child) {
    if (child == renderViewport && child.parentData is ! RenderLayoutParentData) {
      child.parentData = RenderLayoutParentData();
    } else if (child.parentData is! SliverMultiBoxAdaptorParentData) {
      child.parentData = SliverMultiBoxAdaptorParentData();
    }
  }

  KrakenScrollable? scrollable;

  @protected
  RenderViewport _buildRenderViewport() {
    pointerListener = _pointerListener;
    axis = renderStyle.sliverAxis;

    AxisDirection axisDirection = getAxisDirection(axis);
    scrollable = KrakenScrollable(axisDirection: axisDirection);

    return renderViewport = RenderViewport(
      offset: scrollable!.position!,
      axisDirection: axisDirection,
      crossAxisDirection: getCrossAxisDirection(axis),
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
    return _renderSliverList = RenderSliverList(childManager: elementDelegate.renderSliverBoxChildManager!);
  }

  /// Child count should rely on element's childNodes, the real
  /// child renderObject count is not exactly.
  @override
  int get childCount => elementDelegate.renderSliverBoxChildManager!.childCount;

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
