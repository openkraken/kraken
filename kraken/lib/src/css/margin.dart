/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'dart:ui';
import 'package:flutter/rendering.dart';
import 'package:kraken/css.dart';

mixin CSSMarginMixin on RenderStyleBase {

  EdgeInsets _resolvedMargin;

  void _resolve() {
    if (_resolvedMargin != null) return;
    if (margin == null) return;
    _resolvedMargin = margin.resolve(TextDirection.ltr);
  }

  void _markNeedResolution() {
    _resolvedMargin = null;
  }

  /// The amount to pad the child in each dimension.
  ///
  /// If this is set to an [EdgeInsetsDirectional] object, then [textDirection]
  /// must not be null.
  EdgeInsets get margin => _margin;
  EdgeInsets _margin;
  set margin(EdgeInsets value) {
    if (value == null) return;
    if (_margin == value) return;
    _margin = value;
    _markNeedResolution();
  }

  double get marginTop {
    _resolve();
    if (_resolvedMargin == null) return 0;
    return _resolvedMargin.top;
  }

  double get marginRight {
    _resolve();
    if (_resolvedMargin == null) return 0;
    return _resolvedMargin.right;
  }

  double get marginBottom {
    _resolve();
    if (_resolvedMargin == null) return 0;
    return _resolvedMargin.bottom;
  }

  double get marginLeft {
    _resolve();
    if (_resolvedMargin == null) return 0;
    return _resolvedMargin.left;
  }

  EdgeInsets _getMargin() {
    Size viewportSize = this.viewportSize;
    CSSStyleDeclaration style = this.style;
    double marginLeft;
    double marginTop;
    double marginRight;
    double marginBottom;

    if (style.contains(MARGIN_LEFT)) marginLeft = CSSLength.toDisplayPortValue(style[MARGIN_LEFT], viewportSize);
    if (style.contains(MARGIN_TOP)) marginTop = CSSLength.toDisplayPortValue(style[MARGIN_TOP], viewportSize);
    if (style.contains(MARGIN_RIGHT)) marginRight = CSSLength.toDisplayPortValue(style[MARGIN_RIGHT], viewportSize);
    if (style.contains(MARGIN_BOTTOM)) marginBottom = CSSLength.toDisplayPortValue(style[MARGIN_BOTTOM], viewportSize);

    return EdgeInsets.only(top: marginTop ?? 0.0, right: marginRight ?? 0.0, bottom: marginBottom ?? 0.0, left: marginLeft ?? 0.0);
  }

  void updateMargin(String property, double value, {bool markNeedsLayout = true}) {
    RenderStyle renderStyle = this;
    EdgeInsets prevMargin = renderStyle.margin;

    if (prevMargin != null) {
      double left = prevMargin.left;
      double top = prevMargin.top;
      double right = prevMargin.right;
      double bottom = prevMargin.bottom;

      // Can not use [EdgeInsets.copyWith], for zero cannot be replaced to value.
      switch (property) {
        case MARGIN_LEFT:
          left = value;
          break;
        case MARGIN_TOP:
          top = value;
          break;
        case MARGIN_BOTTOM:
          bottom = value;
          break;
        case MARGIN_RIGHT:
          right = value;
          break;
      }

      renderStyle.margin = EdgeInsets.only(
        left: left,
        top: top,
        right: right,
        bottom: bottom,
      );
    } else {
      renderStyle.margin = _getMargin();
    }

    if (markNeedsLayout) {
      renderBoxModel.markNeedsLayout();
    }
  }
  void debugMarginProperties(DiagnosticPropertiesBuilder properties) {
    if (_margin != null) properties.add(DiagnosticsProperty('margin', _margin));
  }
}
