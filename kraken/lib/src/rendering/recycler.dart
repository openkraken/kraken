/*
 * Copyright (C) 2020-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:kraken/css.dart';
import 'package:kraken/dom.dart';
import 'package:kraken/module.dart';
import 'package:kraken/rendering.dart';
import 'package:kraken/gesture.dart';
import 'package:meta/meta.dart';

class RenderRecyclerLayout extends RenderLayoutBox {
  // Expose viewport for sliver mixin.
  RenderViewport get viewport => _renderViewport;
  // The viewport for sliver.
  late RenderViewport _renderViewport;

  // The sliver list render object reference.
  late RenderSliverList _renderSliverList;

  // The scrollable context to handle gestures.
  late KrakenScrollable scrollable;

  // The main axis for recycler layout.
  Axis axis = Axis.vertical;

  // The sliver box child manager
  late RenderSliverBoxChildManager _renderSliverBoxChildManager;

  RenderRecyclerLayout({
    required RenderStyle renderStyle,
    required ElementDelegate elementDelegate
  }) : super(renderStyle: renderStyle, elementDelegate: elementDelegate) {
    pointerListener = _pointerListener;
    scrollable = KrakenScrollable(axisDirection: getAxisDirection(axis));
    axis = renderStyle.sliverDirection;
    _renderSliverBoxChildManager = ElementSliverBoxChildManager(elementDelegate, this);

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
      axisDirection: scrollable.axisDirection!,
      crossAxisDirection: getCrossAxisDirection(axis),
      children: [_renderSliverList],
    );
    super.insert(_renderViewport);
  }

  @override
  ScrollListener? get scrollListener => elementDelegate.handleScroll;

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

  void _pointerListener(PointerEvent event) {
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

    double? width = renderStyle.width;
    double? height = renderStyle.height;
    Axis sliverAxis = renderStyle.sliverDirection;
    AxisDirection axisDirection = getAxisDirection(sliverAxis);

    // TODO(yuanyan): Update scrollable only when axisDirection changed.
    scrollable = KrakenScrollable(axisDirection: axisDirection);
    viewport
      ..axisDirection = axisDirection
      ..crossAxisDirection = getCrossAxisDirection(sliverAxis)
      ..offset = scrollable.position!;

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

/// [RenderSliverBoxChildManager] for sliver element.
class ElementSliverBoxChildManager implements RenderSliverBoxChildManager {
  final ElementDelegate _elementDelegate;
  final RenderRecyclerLayout _recyclerLayout;

  // Flag to determine whether newly added children could
  // affect the visible contents of the [RenderSliverMultiBoxAdaptor].
  bool _didUnderflow = false;

  // The current rendering object index.
  int _currentIndex = -1;

  ElementSliverBoxChildManager(this._elementDelegate, this._recyclerLayout);

  Iterable<Node> get _renderNodes => _elementDelegate.getChildNodes().where((child) => child is Element || child is TextNode);

  // Only count renderable child.
  @override
  int get childCount => _renderNodes.length;

  @override
  void createChild(int index, {required RenderBox? after}) {
    if (_didUnderflow) return;
    if (index < 0) return;

    Iterable<Node> renderNodes = _renderNodes;
    if (index >= renderNodes.length) return;
    _currentIndex = index;

    Node childNode = renderNodes.elementAt(index);
    childNode.willAttachRenderer();

    RenderBox? child;

    if (childNode is Element) {
      childNode.style.flushPendingProperties();
    }

    if (childNode is Node) {
      child = childNode.renderer as RenderBox?;
    } else {
      if (!kReleaseMode)
        throw FlutterError('Sliver unsupported type ${childNode.runtimeType} $childNode');
    }

    assert(child != null, 'Sliver render node should own RenderBox.');

    _recyclerLayout
      ..setupParentData(child!)
      ..insertSliverChild(child, after: after);

    childNode.didAttachRenderer();
    childNode.ensureChildAttached();
  }

  @override
  bool debugAssertChildListLocked() => true;

  @override
  void didAdoptChild(RenderBox child) {
    final parentData = child.parentData as SliverMultiBoxAdaptorParentData;
    parentData.index = _currentIndex;
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
  void setDidUnderflow(bool value) {
    _didUnderflow = value;
  }

  @override
  void didFinishLayout() {}

  @override
  void didStartLayout() {}

  @override
  double estimateMaxScrollOffset(SliverConstraints constraints, {int? firstIndex, int? lastIndex, double? leadingScrollOffset, double? trailingScrollOffset}) {
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
}
