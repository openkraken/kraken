/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'package:flutter/rendering.dart';
import 'package:meta/meta.dart';

/// Calls callbacks in response to common pointer events.
///
/// It responds to events that can construct gestures, such as when the
/// pointer is pressed, moved, then released or canceled.
///
/// It does not respond to events that are exclusive to mouse, such as when the
/// mouse enters, exits or hovers a region without pressing any buttons. For
/// these events, use [RenderMouseRegion].
///
/// If it has a child, defers to the child for sizing behavior.
///
/// If it does not have a child, grows to fit the parent-provided constraints.
class KrakenRenderPointerListener extends RenderPointerListener {
  /// Creates a render object that forwards pointer events to callbacks.
  ///
  /// The [behavior] must be [HitTestBehavior.deferToChild].
  KrakenRenderPointerListener({
    onPointerDown,
    onPointerMove,
    onPointerUp,
    onPointerCancel,
    onPointerSignal,
    RenderBox child,
  }) : super(onPointerDown: onPointerDown, onPointerMove: onPointerMove, onPointerUp: onPointerUp, onPointerCancel: onPointerCancel, onPointerSignal: onPointerSignal, behavior: HitTestBehavior.deferToChild, child: child);

  @override
  bool hitTest(BoxHitTestResult result, { @required Offset position }) {
    if (hitTestChildren(result, position: position) || hitTestSelf(position)) {
      result.add(BoxHitTestEntry(this, position));
      return true;
    }
    return false;
  }

  @override
  bool hitTestSelf(Offset position) {
    return size.contains(position);
  }
}

