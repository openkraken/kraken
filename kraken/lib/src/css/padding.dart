/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'dart:ui';
import 'package:flutter/rendering.dart';
import 'package:kraken/css.dart';

mixin CSSPaddingMixin on RenderStyleBase {
  EdgeInsets? _resolvedPadding;

  void _resolve() {
    EdgeInsetsGeometry _p = padding!;
    _resolvedPadding = _p.resolve(TextDirection.ltr);
    assert(_resolvedPadding!.isNonNegative);
  }

  void _markNeedResolution() {
    _resolvedPadding = null;
  }

  /// The amount to pad the child in each dimension.
  ///
  /// If this is set to an [EdgeInsetsDirectional] object, then [textDirection]
  /// must not be null.
  EdgeInsets? get padding => _padding;
  EdgeInsets? _padding;
  set padding(EdgeInsets? value) {
    if (value == null) return;
    assert(value.isNonNegative);
    if (_padding == value) return;
    _padding = value;
    _markNeedResolution();
  }

  double get paddingTop {
    _resolve();
    EdgeInsets? resolvedPadding = _resolvedPadding;
    if (resolvedPadding == null) return 0;
    return resolvedPadding.top;
  }

  double get paddingRight {
    _resolve();
    EdgeInsets? resolvedPadding = _resolvedPadding;
    if (resolvedPadding == null) return 0;
    return resolvedPadding.right;
  }

  double get paddingBottom {
    _resolve();
    EdgeInsets? resolvedPadding = _resolvedPadding;
    if (resolvedPadding == null) return 0;
    return resolvedPadding.bottom;
  }

  double get paddingLeft {
    _resolve();
    EdgeInsets? resolvedPadding = _resolvedPadding;
    if (resolvedPadding == null) return 0;
    return resolvedPadding.left;
  }

  void updatePadding(String property, double value, {bool shouldMarkNeedsLayout = true}) {
    RenderStyle renderStyle = this as RenderStyle;
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
    EdgeInsets? _padding = padding;
    if (_padding != null) {
      return constraints.deflate(_padding);
    }
    return constraints;
  }

  Size wrapPaddingSize(Size innerSize) {
    _resolve();
    EdgeInsets? resolvedPadding = _resolvedPadding;
    if (resolvedPadding == null) return Size.zero;

    return Size(resolvedPadding.left + innerSize.width + resolvedPadding.right,
        resolvedPadding.top + innerSize.height + resolvedPadding.bottom);
  }

  void debugPaddingProperties(DiagnosticPropertiesBuilder properties) {
    if (_padding != null) properties.add(DiagnosticsProperty('padding', _padding));
  }
}
