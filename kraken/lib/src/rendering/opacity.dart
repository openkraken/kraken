/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'package:flutter/rendering.dart';
import 'package:meta/meta.dart';

// Makes its child partially transparent.
///
/// This class paints its child into an intermediate buffer and then blends the
/// child back into the scene partially transparent.
///
/// For values of opacity other than 0.0 and 1.0, this class is relatively
/// expensive because it requires painting the child into an intermediate
/// buffer. For the value 0.0, the child is simply not painted at all. For the
/// value 1.0, the child is painted immediately without an intermediate buffer.
class KrakenRenderOpacity extends RenderOpacity {
  /// Creates a partially transparent render object.
  ///
  /// The [opacity] argument must be between 0.0 and 1.0, inclusive.
  KrakenRenderOpacity({
    double opacity = 1.0,
    bool alwaysIncludeSemantics = false,
    RenderBox child,
  }) : super(opacity: opacity, alwaysIncludeSemantics: alwaysIncludeSemantics,child: child);

  @override
  bool hitTest(BoxHitTestResult result, { @required Offset position }) {
    if (hitTestChildren(result, position: position) || hitTestSelf(position)) {
      result.add(BoxHitTestEntry(this, position));
      return true;
    }
    return false;
  }
}

