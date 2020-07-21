/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'package:flutter/rendering.dart';
import 'package:meta/meta.dart';

/// Insets its child by the given padding.
///
/// When passing layout constraints to its child, padding shrinks the
/// constraints by the given padding, causing the child to layout at a smaller
/// size. Padding then sizes itself to its child's size, inflated by the
/// padding, effectively creating empty space around the child.
class KrakenRenderPadding extends RenderPadding {
  /// Creates a render object that insets its child.
  ///
  /// The [padding] argument must not be null and must have non-negative insets.
  KrakenRenderPadding({
    @required EdgeInsetsGeometry padding,
    TextDirection textDirection,
    RenderBox child,
  }) : super(padding: padding, textDirection: textDirection, child: child);

  @override
  bool hitTest(BoxHitTestResult result, { @required Offset position }) {
    if (hitTestChildren(result, position: position) || hitTestSelf(position)) {
      result.add(BoxHitTestEntry(this, position));
      return true;
    }
    return false;
  }
}
