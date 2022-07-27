/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
import 'package:flutter/rendering.dart';
import 'package:webf/rendering.dart';
import 'package:webf/dom.dart';

/// An implementation of [RenderSliverBoxChildManager] for sliver,
/// manage element to implement lifecycles for sliver list, generate
/// renderer from existing element tree.
class RenderSliverElementChildManager implements RenderSliverBoxChildManager {
  // @NOTE: For hummer support, no real function here.
  void restorePreparedChild(int index) {}
  void stashPreparedChild(int index) {}

  final Element _target;
  late RenderSliverListLayout _sliverListLayout;

  // Flag to determine whether newly added children could
  // affect the visible contents of the [RenderSliverMultiBoxAdaptor].
  bool _didUnderflow = false;

  // The current rendering object index.
  int _currentIndex = -1;

  bool _hasLayout = false;
  void setupSliverListLayout(RenderSliverListLayout layout) {
    _sliverListLayout = layout;
    _hasLayout = true;
  }

  RenderSliverElementChildManager(this._target);

  Iterable<Node> get _renderNodes => _target.childNodes.where((child) => child is Element || child is TextNode);

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

    // If renderer is not created, use an empty RenderBox to occupy the position, but not do layout or paint.
    RenderBox child = childNode.renderer ?? _createEmptyRenderObject();

    if (_hasLayout) {
      _sliverListLayout.insertSliverChild(child, after: after);
    }

    if (childNode is Element) {
      childNode.style.flushPendingProperties();
    }

    childNode.didAttachRenderer();
  }

  RenderBox _createEmptyRenderObject() {
    return _RenderSliverItemProxy();
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
      SliverMultiBoxAdaptorParentData parentData = child.parentData as SliverMultiBoxAdaptorParentData;
      // The index of sliver list.
      int index = parentData.index!;

      Iterable<Node> renderNodes = _renderNodes;
      if (index < renderNodes.length) {
        renderNodes.elementAt(index).unmountRenderObject(deep: true, keepFixedAlive: true);
        return;
      }
    }

    // Fallback operation, remove child from sliver list.
    _sliverListLayout.remove(child);
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
  double estimateMaxScrollOffset(SliverConstraints constraints,
      {int? firstIndex, int? lastIndex, double? leadingScrollOffset, double? trailingScrollOffset}) {
    return _extrapolateMaxScrollOffset(firstIndex, lastIndex, leadingScrollOffset, trailingScrollOffset, childCount)!;
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
    final double averageExtent = (trailingScrollOffset! - leadingScrollOffset!) / reifiedCount;
    final int remainingCount = childCount - lastIndex - 1;
    return trailingScrollOffset + averageExtent * remainingCount;
  }
}

/// Used for the placeholder for empty sliver item.
class _RenderSliverItemProxy extends RenderProxyBox {}
