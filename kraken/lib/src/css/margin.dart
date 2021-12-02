/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:ui';

import 'package:flutter/rendering.dart';
import 'package:kraken/css.dart';
import 'package:kraken/rendering.dart';

mixin CSSMarginMixin on RenderStyle {

  /// The amount to margin the child in each dimension.
  ///
  /// If this is set to an [EdgeInsetsDirectional] object, then [textDirection]
  /// must not be null.
  @override
  EdgeInsets get margin {
    EdgeInsets insets = EdgeInsets.only(
      left: marginLeft.computedValue,
      right: marginRight.computedValue,
      bottom: marginBottom.computedValue,
      top: marginTop.computedValue
    ).resolve(TextDirection.ltr);
    return insets;
  }

  CSSLengthValue? _marginLeft;
  set marginLeft(CSSLengthValue? value) {
    if (_marginLeft == value) return;
    _marginLeft = value;
    _markSelfAndParentNeedsLayout();
  }

  @override
  CSSLengthValue get marginLeft => _marginLeft ?? CSSLengthValue.zero;

  CSSLengthValue? _marginRight;
    set marginRight(CSSLengthValue? value) {
    if (_marginRight == value) return;
    _marginRight = value;
    _markSelfAndParentNeedsLayout();
  }

  @override
  CSSLengthValue get marginRight => _marginRight ?? CSSLengthValue.zero;

  CSSLengthValue? _marginBottom;
  set marginBottom(CSSLengthValue? value) {
    if (_marginBottom == value) return;
    _marginBottom = value;
    _markSelfAndParentNeedsLayout();
  }

  @override
  CSSLengthValue get marginBottom => _marginBottom ?? CSSLengthValue.zero;

  CSSLengthValue? _marginTop;
  set marginTop(CSSLengthValue? value) {
    if (_marginTop == value) return;
    _marginTop = value;
    _markSelfAndParentNeedsLayout();
  }

  @override
  CSSLengthValue get marginTop => _marginTop ?? CSSLengthValue.zero;

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
    properties.add(DiagnosticsProperty('margin', margin));
  }
}
