/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'dart:ui';
import 'package:flutter/rendering.dart';
import 'package:kraken/css.dart';

mixin CSSPaddingMixin on RenderStyleBase {
  EdgeInsets _resolvedPadding;

  void _resolve() {
    if (_resolvedPadding != null) return;
    if (padding == null) return;
    _resolvedPadding = padding.resolve(TextDirection.ltr);
    assert(_resolvedPadding.isNonNegative);
  }

  void _markNeedResolution() {
    _resolvedPadding = null;
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

  void updatePadding(String property, double value, {bool shouldMarkNeedsLayout = true}) {
    RenderStyle renderStyle = this;
    EdgeInsets prevPadding = renderStyle.padding ?? EdgeInsets.only(
      top: 0.0,
      right: 0.0,
      bottom: 0.0,
      left: 0.0
    );

    double left = prevPadding.left;
    double top = prevPadding.top;
    double right = prevPadding.right;
    double bottom = prevPadding.bottom;

    // Can not use [EdgeInsets.copyWith], for zero cannot be replaced to value.
    switch (property) {
      case PADDING_LEFT:
        left = value;
        break;
      case PADDING_TOP:
        top = value;
        break;
      case PADDING_BOTTOM:
        bottom = value;
        break;
      case PADDING_RIGHT:
        right = value;
        break;
    }

    renderStyle.padding = EdgeInsets.only(
      left: left,
      right: right,
      bottom: bottom,
      top: top
    );

    if (shouldMarkNeedsLayout) {
      renderBoxModel.markNeedsLayout();
    }
  }

  BoxConstraints deflatePaddingConstraints(BoxConstraints constraints) {
    if (padding != null) {
      return constraints.deflate(padding);
    }
    return constraints;
  }

  Size wrapPaddingSize(Size innerSize) {
    _resolve();
    return Size(_resolvedPadding.left + innerSize.width + _resolvedPadding.right,
      _resolvedPadding.top + innerSize.height + _resolvedPadding.bottom);
  }

  void debugPaddingProperties(DiagnosticPropertiesBuilder properties) {
    if (_padding != null) properties.add(DiagnosticsProperty('padding', _padding));
  }
}
