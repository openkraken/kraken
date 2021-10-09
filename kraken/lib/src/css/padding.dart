

/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'dart:ui';
import 'package:flutter/rendering.dart';
import 'package:kraken/css.dart';
import 'package:kraken/rendering.dart';

mixin CSSPaddingMixin on RenderStyleBase {
  /// The amount to pad the child in each dimension.
  ///
  /// If this is set to an [EdgeInsetsDirectional] object, then [textDirection]
  /// must not be null.
  EdgeInsets? _padding;
  EdgeInsets get padding {
    // TODO(yuanyan): cache resolved padding when not changed.
    EdgeInsets insets = EdgeInsets.only(
      left: _paddingLeft.computedValue,
      right: _paddingRight.computedValue,
      bottom: _paddingBottom.computedValue,
      top: _paddingTop.computedValue
    );
    assert(insets.isNonNegative);
    return _padding = insets;
  }

  CSSLengthValue _paddingLeft = CSSLengthValue.zero;
  set paddingLeft(CSSLengthValue? value) {
    if (value == null || _paddingLeft == value) return;
    _paddingLeft = value;
    _markSelfAndParentNeedsLayout();
  }
  CSSLengthValue get paddingLeft => _paddingLeft;

  CSSLengthValue _paddingRight = CSSLengthValue.zero;
    set paddingRight(CSSLengthValue? value) {
    if (value == null || _paddingRight == value) return;
    _paddingRight = value;
    _markSelfAndParentNeedsLayout();
  }
  CSSLengthValue get paddingRight => _paddingRight;

  CSSLengthValue _paddingBottom = CSSLengthValue.zero;
  set paddingBottom(CSSLengthValue? value) {
    if (value == null || _paddingBottom == value) return;
    _paddingBottom = value;
    _markSelfAndParentNeedsLayout();
  }
  CSSLengthValue get paddingBottom => _paddingBottom;

  CSSLengthValue _paddingTop = CSSLengthValue.zero;
  set paddingTop(CSSLengthValue? value) {
    if (value == null || _paddingTop == value) return;
    _paddingTop = value;
    _markSelfAndParentNeedsLayout();
  }
  CSSLengthValue get paddingTop => _paddingTop;

  void _markSelfAndParentNeedsLayout() {
    RenderBoxModel boxModel = renderBoxModel!;
    boxModel.markNeedsLayout();
    // Sizing may affect parent size, mark parent as needsLayout in case
    // renderBoxModel has tight constraints which will prevent parent from marking.
    if (boxModel.parent is RenderBoxModel) {
      (boxModel.parent as RenderBoxModel).markNeedsLayout();
    }
  }

  BoxConstraints deflatePaddingConstraints(BoxConstraints constraints) {
    return constraints.deflate(padding);
  }

  Size wrapPaddingSize(Size innerSize) {
    return Size(
      _paddingLeft.computedValue + innerSize.width + _paddingRight.computedValue,
      _paddingTop.computedValue + innerSize.height + _paddingBottom.computedValue
    );
  }

  void debugPaddingProperties(DiagnosticPropertiesBuilder properties) {
    if (_padding != null) properties.add(DiagnosticsProperty('padding', _padding));
  }
}
