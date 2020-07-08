/*
 * Copyright (C) 2020-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'package:flutter/rendering.dart';

/// Insets its child by the given padding.
///
/// When passing layout constraints to its child, padding shrinks the
/// constraints by the given padding, causing the child to layout at a smaller
/// size. Padding then sizes itself to its child's size, inflated by the
/// padding, effectively creating empty space around the child.
mixin RenderPaddingMixin on RenderBox {
  EdgeInsets _resolvedPadding;

  void _resolve() {
    if (_resolvedPadding != null)
      return;
    _resolvedPadding = padding.resolve(TextDirection.ltr);
    assert(_resolvedPadding.isNonNegative);
  }

  void _markNeedResolution() {
    _resolvedPadding = null;
    markNeedsLayout();
  }

  /// The amount to pad the child in each dimension.
  ///
  /// If this is set to an [EdgeInsetsDirectional] object, then [textDirection]
  /// must not be null.
  EdgeInsetsGeometry get padding => _padding;
  EdgeInsetsGeometry _padding;
  set padding(EdgeInsetsGeometry value) {
    assert(value != null);
    assert(value.isNonNegative);
    if (_padding == value)
      return;
    _padding = value;
    _markNeedResolution();
  }

  BoxConstraints deflatePaddingConstraints(BoxConstraints constraints) {
    _resolve();
    return constraints.deflate(_resolvedPadding);
  }

  Offset getPaddingOffset() {
    _resolve();
    return Offset(_resolvedPadding.left, _resolvedPadding.top);
  }

  Size wrapPaddingSize(Size innerSize) {
    _resolve();
    return Size(
      _resolvedPadding.left + innerSize.width + _resolvedPadding.right,
      _resolvedPadding.top + innerSize.height + _resolvedPadding.bottom
    );
  }
}
