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

class RenderRecyclerParentData extends RenderLayoutParentData {}

class RenderRecyclerLayout extends RenderLayoutBox implements RenderSliverBoxChildManager {
  static Axis resolveAxis(CSSStyleDeclaration style) {
    String sliverDirection = style[SLIVER_DIRECTION];
    switch (sliverDirection) {
      case ROW:
        return Axis.horizontal;
        break;

      case COLUMN:
      default:
        return Axis.vertical;
    }
  }

  RenderRecyclerLayout({
    Axis axis = Axis.vertical,
    int targetId,
    ElementManager elementManager,
    CSSStyleDeclaration style,
  }) : assert(axis != null),
        super(targetId: targetId, style: style, elementManager: elementManager) {

    _element = elementManager.getEventTargetByTargetId<Element>(targetId);
    _axis = resolveAxis(_element.style);

    _buildRenderViewport();
    super.insert(_renderViewport);
  }

  @override
  bool get isRepaintBoundary => true;

  Axis _axis;
  Axis get axis => _axis;
  set axis(Axis value) {
    if (_axis != value) {
      _axis = value;

      AxisDirection axisDirection = _getAxisDirection();
      _scrollable = KrakenScrollable(axisDirection: axisDirection);
      _renderViewport.axisDirection = axisDirection;
      _renderViewport.crossAxisDirection = _getCrossAxisDirection();
      _renderViewport.offset = _scrollable.position;

      markNeedsLayout();
    }
  }

  Element _element;
  RenderViewport _renderViewport;
  RenderSliverList _renderSliverList;

  // Children targetId list.
  List<int> _children = List<int>();

  @override
  void add(RenderBox child) {
    if (child is RenderBoxModel) {
      _children.add(child.targetId);
    }
  }

  @override
  void insert(RenderBox child, { RenderBox after }) {
    // Append to last.
    if (after == _renderViewport) {
      return add(child);
    }

    if (child is RenderBoxModel) {
      int index;
      if (after == null) {
        index = 0;
      } else if (after is RenderBoxModel) {
        index = _children.indexOf(after.targetId);
      }

      if (index != null) {
        _children.insert(index, child.targetId);
      }
    }
  }

  @override
  void addAll(List<RenderBox> children) {
    assert(children != null);
    children.forEach(add);
  }

  @override
  void remove(RenderBox child) {
    if (child is RenderBoxModel) {
      _children.remove(child.targetId);
    }

    assert(_renderSliverList != null);
    _renderSliverList.remove(child);
  }

  @override
  void removeAll() {
    _renderSliverList.removeAll();
    _children.clear();
  }

  void move(RenderBox child, { RenderBox after }) {
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

  KrakenScrollable _scrollable;
  KrakenScrollable get scrollable => _scrollable;

  @protected
  RenderViewport _buildRenderViewport() {
    pointerListener = _pointerListener;

    AxisDirection axisDirection = _getAxisDirection();
    _scrollable = KrakenScrollable(axisDirection: axisDirection);

    return _renderViewport = RenderViewport(
      offset: _scrollable.position,
      axisDirection: axisDirection,
      crossAxisDirection: _getCrossAxisDirection(),
      children: [_buildRenderSliverList()],
      cacheExtent: kReleaseMode ? null : 0.0,
    );
  }

  void _pointerListener(PointerEvent event) {
    if (event is PointerDownEvent) {
      _scrollable?.handlePointerDown(event);
    }
  }

  AxisDirection _getAxisDirection() {
    switch (_axis) {
      case Axis.horizontal:
        return AxisDirection.right;
      case Axis.vertical:
      default:
        return AxisDirection.down;
    }
  }

  AxisDirection _getCrossAxisDirection() {
    switch (_axis) {
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
      PerformanceTiming.instance(elementManager.contextId).mark(PERF_SILVER_LAYOUT_START);
    }

    if (display == CSSDisplay.none) {
      size = constraints.smallest;
      return;
    }

    beforeLayout();

    // If width is given, use exact width; or expand to parent extent width.
    // If height is given, use exact height; or use 0.
    // Only layout [_renderViewport] as only-child.
    RenderBox child = _renderViewport;
    BoxConstraints childConstraints;

    switch (_axis) {
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

    child.layout(childConstraints, parentUsesSize: true);
    size = getBoxSize(child.size);

    didLayout();

    if (kProfileMode) {
      PerformanceTiming.instance(elementManager.contextId).mark(PERF_SILVER_LAYOUT_END);
    }
  }

  @override
  void performPaint(PaintingContext context, Offset offset) {
    if (padding != null) {
      offset += Offset(paddingLeft, paddingTop);
    }

    if (borderEdge != null) {
      offset += Offset(borderLeft, borderTop);
    }

    if (firstChild != null) {
      context.paintChild(firstChild, offset);
    }
  }

  Offset getChildScrollOffset(RenderObject child, Offset offset) {
    final RenderLayoutParentData childParentData = child.parentData;
    // Fixed elements always paint original offset
    Offset scrollOffset = childParentData.position == CSSPositionType.fixed
        ? childParentData.offset
        : childParentData.offset + offset;
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

  int _currentIndex;

  RenderBox _createRenderBox(int index) {
    if (childCount <= index) {
      return null;
    }

    int targetId = _children[index];
    Node node = elementManager.getEventTargetByTargetId<Node>(targetId);

    if (node != null) {
      node.createRenderer();
    }

    return node.renderer;
  }

  @override
  void createChild(int index, { RenderBox after }) {
    if (_didUnderflow) return;
    if (index >= childCount) return;
    _currentIndex = index;

    if (index < 0) return;
    if (childCount <= index) return;

    RenderBox child;
    int targetId = _children[index];
    Node node = elementManager.getEventTargetByTargetId<Node>(targetId);
    assert(node != null);
    node.willAttachRenderer();

    if (node is Element) {
      node.style.applyTargetProperties();
    }
    if (node is Node) {
      child = node.renderer;
    } else {
      if (!kReleaseMode)
        throw FlutterError('Unsupported type ${node.runtimeType} $node');
    }

    assert(child != null, 'Child should not be null');
    child.parentData = SliverMultiBoxAdaptorParentData();
    _renderSliverList.insert(child, after: after);

    node.didAttachRenderer();
    node.ensureChildAttached();
  }

  @override
  void removeChild(RenderBox child) {
    if (child is RenderBoxModel) {
      Node node = elementManager.getEventTargetByTargetId(child.targetId);
      if (node != null) {
        node.detach();
      }
    } else {
      child.detach();
    }
  }

  @override
  void didAdoptChild(RenderBox child) {
    final parentData = child.parentData as SliverMultiBoxAdaptorParentData;
    assert(parentData != null);
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
  void didStartLayout() { }

  /// Called at the end of layout to indicate that layout is now complete.
  void didFinishLayout() { }

  @override
  double estimateMaxScrollOffset(SliverConstraints constraints, {
    int firstIndex,
    int lastIndex,
    double leadingScrollOffset,
    double trailingScrollOffset,
  }) {
    return _extrapolateMaxScrollOffset(
      firstIndex,
      lastIndex,
      leadingScrollOffset,
      trailingScrollOffset,
      childCount
    );
  }

  static double _extrapolateMaxScrollOffset(
    int firstIndex,
    int lastIndex,
    double leadingScrollOffset,
    double trailingScrollOffset,
    int childCount,
  ) {
    if (lastIndex == childCount - 1) {
      return trailingScrollOffset;
    }

    final int reifiedCount = lastIndex - firstIndex + 1;
    final double averageExtent = (trailingScrollOffset - leadingScrollOffset) / reifiedCount;
    final int remainingCount = childCount - lastIndex - 1;
    return trailingScrollOffset + averageExtent * remainingCount;
  }

  @override
  List<RenderBox> getChildrenAsList() {
    assert(_element != null);
    final List<RenderBox> result = <RenderBox>[];
    for (int index = 0; index < childCount; index++) {
      result.add(_createRenderBox(index));
    }
    return result;
  }

  RenderFlexLayout toFlexLayout() {
    List<RenderObject> children = getDetachedChildrenAsList();
    RenderFlexLayout renderFlexLayout = RenderFlexLayout(
        children: children,
        targetId: targetId,
        style: style,
        elementManager: elementManager
    );
    return copyWith(renderFlexLayout);
  }

  RenderFlowLayout toFlowLayout() {
    List<RenderObject> children = getDetachedChildrenAsList();
    RenderFlowLayout renderFlowLayout = RenderFlowLayout(
        targetId: targetId,
        style: style,
        elementManager: elementManager
    );
    renderFlowLayout.addAll(children);
    return copyWith(renderFlowLayout);
  }
}
