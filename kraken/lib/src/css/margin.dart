// @dart=2.9

/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'dart:ui';
import 'package:flutter/rendering.dart';
import 'package:kraken/rendering.dart';
import 'package:kraken/css.dart';

class CSSMargin {
  CSSMargin({
    this.length,
    this.isAuto,
  });
  /// length if margin value is length type
  double length;
  /// Whether value is auto
  bool isAuto;
}

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

  CSSMargin get marginTop {
    _resolve();
    double length = _resolvedMargin != null ? _resolvedMargin.top : 0;
    bool isAuto = style[MARGIN_TOP] == AUTO;
    return CSSMargin(length: length, isAuto: isAuto);
  }

  CSSMargin get marginRight {
    _resolve();
    double length = _resolvedMargin != null ? _resolvedMargin.right : 0;
    bool isAuto = style[MARGIN_RIGHT] == AUTO;
    return CSSMargin(length: length, isAuto: isAuto);
  }

  CSSMargin get marginBottom {
    _resolve();
    double length = _resolvedMargin != null ? _resolvedMargin.bottom : 0;
    bool isAuto = style[MARGIN_BOTTOM] == AUTO;
    return CSSMargin(length: length, isAuto: isAuto);
  }

  CSSMargin get marginLeft {
    _resolve();
    double length = _resolvedMargin != null ? _resolvedMargin.left : 0;
    bool isAuto = style[MARGIN_LEFT] == AUTO;
    return CSSMargin(length: length, isAuto: isAuto);
  }

  void updateMargin(String property, double value, {bool shouldMarkNeedsLayout = true}) {
    RenderStyle renderStyle = this;

    EdgeInsets prevMargin = renderStyle.margin ?? EdgeInsets.only(
      top: 0.0,
      right: 0.0,
      bottom: 0.0,
      left: 0.0
    );

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

    if (shouldMarkNeedsLayout) {
      renderBoxModel.markNeedsLayout();
      // Sizing may affect parent size, mark parent as needsLayout in case
      // renderBoxModel has tight constraints which will prevent parent from marking.
      if (renderBoxModel.parent is RenderBoxModel) {
        (renderBoxModel.parent as RenderBoxModel).markNeedsLayout();
      }
    }
  }
  void debugMarginProperties(DiagnosticPropertiesBuilder properties) {
    if (_margin != null) properties.add(DiagnosticsProperty('margin', _margin));
  }
}
