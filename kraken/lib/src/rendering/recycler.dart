/*
 * Copyright (C) 2020-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

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

    _element = elementManager.getEventTargetByTargetId<Element>(targetId);

    _buildRenderViewport();
    super.insert(_renderViewport);
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

  final KrakenScrollable _scrollableY = KrakenScrollable(axisDirection: AxisDirection.down);

  @protected
  RenderViewport _buildRenderViewport() {
    pointerListener = (PointerEvent event) {
      if (event is PointerDownEvent) {
        _scrollableY.handlePointerDown(event);
      }
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
      node.initializeRenderObject();
    }

    if (node is Element) {
      return node.renderBoxModel;
    } else if (node is TextNode) {
      return node.renderTextBox;
    } else {
      return null;
    }
  }

  @override
  void createChild(int index, { RenderBox after }) {
    if (_didUnderflow) return;
    if (index >= childCount) return;
    _currentIndex = index;
    if (index < 0) return;
    if (childCount <= index) return;

    RenderBox child = _createRenderBox(index);
    if (child != null) {
      child.parentData = SliverMultiBoxAdaptorParentData();
      _renderSliverList.insert(child, after: after);
    }
  }

  @override
  void removeChild(RenderBox child) {
    final parentData = child.parentData as SliverMultiBoxAdaptorParentData;
    if (parentData != null) {
      int index = parentData.index;
      if (index != null && _element.childNodes.length > index) {
        Node node = _element.childNodes[index];
        if (node != null) {
          node.dispose();
        }
      }
    }

    _renderSliverList.remove(child);
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
