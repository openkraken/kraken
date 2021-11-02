/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:kraken/rendering.dart';
import 'package:kraken/dom.dart';

/// [RenderSliverBoxChildManager] for sliver element.
class ElementSliverBoxChildManager implements RenderSliverBoxChildManager {
  final Element _target;
  late RenderSliverListLayout _sliverListLayout;

  // Flag to determine whether newly added children could
  // affect the visible contents of the [RenderSliverMultiBoxAdaptor].
  bool _didUnderflow = false;

  // The current rendering object index.
  int _currentIndex = -1;

  bool _hasLayout = false;
  void setupSliverLayoutLayout(RenderSliverListLayout layout) {
    _sliverListLayout = layout;
    _hasLayout = true;
  }

  ElementSliverBoxChildManager(this._target);

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

    if (_hasLayout) {
      _sliverListLayout
        ..setupParentData(child!)
        ..insertSliverChild(child, after: after);
    }

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
      child.renderStyle.cancelRunningTransiton();
      child.clearIntersectionChangeListeners();

      child.detach();
      child.dispose();
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
