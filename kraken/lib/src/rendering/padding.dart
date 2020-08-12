/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'package:flutter/rendering.dart';

mixin RenderPaddingMixin on RenderBox {
  EdgeInsets _resolvedPadding;

  void _resolve() {
    if (_resolvedPadding != null) return;
    if (padding == null) return;
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
    if (value == null) return;
    assert(value.isNonNegative);
    if (_padding == value) return;
    _padding = value;
    _markNeedResolution();
  }

  double get paddingTop {
    _resolve();
    if (_resolvedPadding == null) return 0;
    return _resolvedPadding.top;
  }

  double get paddingRight {
    _resolve();
    if (_resolvedPadding == null) return 0;
    return _resolvedPadding.right;
  }

  double get paddingBottom {
    _resolve();
    if (_resolvedPadding == null) return 0;
    return _resolvedPadding.bottom;
  }

  double get paddingLeft {
    _resolve();
    if (_resolvedPadding == null) return 0;
    return _resolvedPadding.left;
  }

  BoxConstraints deflatePaddingConstraints(BoxConstraints constraints) {
    if (_resolvedPadding == null) return constraints;

    _resolve();
    return constraints.deflate(_resolvedPadding);
  }

  Size wrapPaddingSize(Size innerSize) {
    _resolve();
    return Size(_resolvedPadding.left + innerSize.width + _resolvedPadding.right,
        _resolvedPadding.top + innerSize.height + _resolvedPadding.bottom);
  }
}
