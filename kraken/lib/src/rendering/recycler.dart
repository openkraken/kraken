
import 'dart:math' as math;

import 'package:meta/meta.dart';
import 'package:flutter/rendering.dart';

import 'package:kraken/css.dart';
import 'package:kraken/rendering.dart';
import 'package:kraken/element.dart';

class RenderRecyclerParentData extends RenderLayoutParentData {}

class RenderRecyclerLayout extends RenderLayoutBox implements RenderSliverBoxChildManager {

  RenderRecyclerLayout({
    int targetId,
    ElementManager elementManager,
    CSSStyleDeclaration style,
  }) : super(targetId: targetId, style: style, elementManager: elementManager) {

    _buildRenderViewport();
    super.insert(_renderViewport);
  }

  RenderViewport _renderViewport;
  RenderSliverList _renderSliverList;

  List<RenderBox> _children = List<RenderBox>();

  @override
  void add(RenderBox child) {
    assert(_renderSliverList != null);
    _children.add(child);
  }

  @override
  void insert(RenderBox child, { RenderBox after }) {
    assert(_renderSliverList != null);
    if (after == _renderViewport) {
      return add(child);
    }

    if (after == null) {
      // insert at the start
      _children.insert(0, child);
    } else {
      _children.insert(_children.indexOf(after), child);
    }
  }

  @override
  void addAll(List<RenderBox> children) {
    assert(children != null);
    children.forEach(add);
  }

  @override
  void remove(RenderBox child) {
    assert(_renderSliverList != null);
    _children.remove(child);
  }

  @override
  void removeAll() {
    assert(_renderSliverList != null);
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

  final KrakenScrollable _scrollableY = KrakenScrollable(axisDirection: AxisDirection.down);

  @protected
  RenderViewport _buildRenderViewport() {
    PointerDownEventListener originalPointerDown = onPointerDown;
    print('originalPointerDown $originalPointerDown');
    onPointerDown = (PointerDownEvent event) {
      if (originalPointerDown != null) {
        originalPointerDown(event);
      }

      _scrollableY.handlePointerDown(event);
    };

    return _renderViewport = RenderViewport(
      offset: _scrollableY.position,
      crossAxisDirection: AxisDirection.right,
      children: [_buildRenderSliverList()],
    );
  }

  @protected
  RenderSliverList _buildRenderSliverList() {
    return _renderSliverList = RenderSliverList(childManager: this);
  }

  @override
  void performLayout() {
    if (display == CSSDisplay.none) {
      size = constraints.smallest;
      return;
    }

    beforeLayout();

    // If width is given, use exact width; or expand to parent extent width.
    // If height is given, use exact height; or use 0.
    RenderBox child = _renderViewport;

    final double contentWidth = RenderBoxModel.getContentWidth(this);
    final double contentHeight = RenderBoxModel.getContentHeight(this);

    double constraintWidth = contentWidth ?? 0;
    double constraintHeight = contentHeight ?? 0;
    double baseWidth = constraintWidth;

    if (maxWidth != null && width == null) {
      constraintWidth = baseWidth > maxWidth ? maxWidth : baseWidth;
    } else if (minWidth != null && width == null) {
      constraintWidth = baseWidth < minWidth ? minWidth : baseWidth;
    }

    // Base height always equals to 0.
    double baseHeight = 0;
    if (maxHeight != null && height == null) {
      constraintHeight = baseHeight > maxHeight ? maxHeight : baseHeight;
    } else if (minHeight != null && height == null) {
      constraintHeight = baseHeight < minHeight ? minHeight : baseHeight;
    }

    Size constraintSize = Size(constraintWidth, constraintHeight,);
    setMaxScrollableSize(constraintWidth, constraintHeight);

    BoxConstraints childConstraints = BoxConstraints.loose(constraintSize);
    child.layout(childConstraints, parentUsesSize: true);

    size = getBoxSize(child.size);

    didLayout();
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

  bool _didUnderflow = false;

  @override
  int get childCount => _children.length;

  List<RenderBox> _presentChildren = List<RenderBox>();
  int _currentIndex;
  @override
  void createChild(int index, { RenderBox after }) {
    if (index >= childCount) return;
    _currentIndex = index;
    if (index < 0) return;
    if (childCount <= index) return;

    RenderBox child = _children[index];
    if (child != null) {
      child.parentData = SliverMultiBoxAdaptorParentData();
      _renderSliverList.insert(child, after: after);

      _presentChildren.insert(index, child);
    }
  }

  @override
  bool debugAssertChildListLocked() {
    // print('debugAssertChildListLocked');
    // TODO: implement debugAssertChildListLocked
    return true;
  }

  @override
  void didAdoptChild(RenderBox child) {
    final parentData = child.parentData as SliverMultiBoxAdaptorParentData;
    assert(parentData != null);
    parentData.index = _currentIndex;
  }

  @override
  void didFinishLayout() {
    // print('didFinishLayout');
    // throw FlutterError('didFinishLayout');
  }

  @override
  void didStartLayout() {
    // print('didStartLayout');
    assert(debugAssertChildListLocked());
  }

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
    if (lastIndex == childCount - 1)
      return trailingScrollOffset;
    final int reifiedCount = lastIndex - firstIndex + 1;
    final double averageExtent = (trailingScrollOffset - leadingScrollOffset) / reifiedCount;
    final int remainingCount = childCount - lastIndex - 1;
    return trailingScrollOffset + averageExtent * remainingCount;
  }

  @override
  void removeChild(RenderBox child) {
    final parentData = child.parentData as SliverMultiBoxAdaptorParentData;
    int index = parentData.index;

    if (_children.contains(child)) {
      _renderSliverList.remove(child);
      _presentChildren[index] = null;
    }
  }

  @override
  void setDidUnderflow(bool value) {
    _didUnderflow = value;
  }

  RenderFlexLayout toFlexLayout() {

  }
}
