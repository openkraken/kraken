/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'package:flutter/rendering.dart';

mixin RenderMarginMixin on RenderBox {
  EdgeInsets _resolvedMargin;

  void _resolve() {
    if (_resolvedMargin != null) return;
    if (margin == null) return;
    _resolvedMargin = margin.resolve(TextDirection.ltr);
  }

  void _markNeedResolution() {
    _resolvedMargin = null;
    markNeedsLayout();
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

  void debugMarginProperties(DiagnosticPropertiesBuilder properties) {
    if (_margin != null) properties.add(DiagnosticsProperty('margin', _margin));
  }
}
