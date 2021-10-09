

/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'dart:ui';
import 'package:flutter/rendering.dart';
import 'package:kraken/rendering.dart';
import 'package:kraken/css.dart';

mixin CSSMarginMixin on RenderStyleBase {

  /// The amount to margin the child in each dimension.
  ///
  /// If this is set to an [EdgeInsetsDirectional] object, then [textDirection]
  /// must not be null.
  EdgeInsets? _margin;
  EdgeInsets get margin {
    // TODO(yuanyan): cache resolved margin when not changed.
    EdgeInsets insets = EdgeInsets.only(
      left: _marginLeft.computedValue,
      right: _marginRight.computedValue,
      bottom: _marginBottom.computedValue,
      top: _marginTop.computedValue
    ).resolve(TextDirection.ltr);
    assert(insets.isNonNegative);
    return _margin = insets;
  }

  CSSLengthValue _marginLeft = CSSLengthValue.zero;
  set marginLeft(CSSLengthValue? value) {
    if (value == null || _marginLeft == value) return;
    _marginLeft = value;
    _markSelfAndParentNeedsLayout();
  }
  CSSLengthValue get marginLeft => _marginLeft;

  CSSLengthValue _marginRight = CSSLengthValue.zero;
    set marginRight(CSSLengthValue? value) {
    if (value == null || _marginRight == value) return;
    _marginRight = value;
    _markSelfAndParentNeedsLayout();
  }
  CSSLengthValue get marginRight => _marginRight;

  CSSLengthValue _marginBottom = CSSLengthValue.zero;
  set marginBottom(CSSLengthValue? value) {
    if (value == null || _marginBottom == value) return;
    _marginBottom = value;
    _markSelfAndParentNeedsLayout();
  }
  CSSLengthValue get marginBottom => _marginBottom;

  CSSLengthValue _marginTop = CSSLengthValue.zero;
  set marginTop(CSSLengthValue? value) {
    if (value == null || _marginTop == value) return;
    _marginTop = value;
    _markSelfAndParentNeedsLayout();
  }
  CSSLengthValue get marginTop => _marginTop;

  void _markSelfAndParentNeedsLayout() {
    RenderBoxModel boxModel = renderBoxModel!;
    boxModel.markNeedsLayout();
    // Sizing may affect parent size, mark parent as needsLayout in case
    // renderBoxModel has tight constraints which will prevent parent from marking.
    if (boxModel.parent is RenderBoxModel) {
      (boxModel.parent as RenderBoxModel).markNeedsLayout();
    }
  }
  void debugMarginProperties(DiagnosticPropertiesBuilder properties) {
    if (_margin != null) properties.add(DiagnosticsProperty('margin', _margin));
  }
}
