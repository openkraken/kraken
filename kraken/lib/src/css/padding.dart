/*
 * Copyright (C) 2019-present The Kraken authors. All rights reserved.
 */

import 'dart:ui';

import 'package:flutter/rendering.dart';
import 'package:kraken/css.dart';
import 'package:kraken/rendering.dart';

mixin CSSPaddingMixin on RenderStyle {
  /// The amount to pad the child in each dimension.
  ///
  /// If this is set to an [EdgeInsetsDirectional] object, then [textDirection]
  /// must not be null.
  @override
  EdgeInsets get padding {
    EdgeInsets insets = EdgeInsets.only(
      left: paddingLeft.compute(this),
      right: paddingRight.compute(this),
      bottom: paddingBottom.compute(this),
      top: paddingTop.compute(this)
    );
    assert(insets.isNonNegative);
    return insets;
  }

  CSSLengthValue? _paddingLeft;
  set paddingLeft(CSSLengthValue? value) {
    if (_paddingLeft == value) return;
    _paddingLeft = value;
    _markSelfAndParentNeedsLayout();
  }

  @override
  CSSLengthValue get paddingLeft => _paddingLeft ?? CSSLengthValue.zero;

  CSSLengthValue? _paddingRight;
    set paddingRight(CSSLengthValue? value) {
    if (_paddingRight == value) return;
    _paddingRight = value;
    _markSelfAndParentNeedsLayout();
  }

  @override
  CSSLengthValue get paddingRight => _paddingRight ?? CSSLengthValue.zero;

  CSSLengthValue? _paddingBottom;
  set paddingBottom(CSSLengthValue? value) {
    if (_paddingBottom == value) return;
    _paddingBottom = value;
    _markSelfAndParentNeedsLayout();
  }

  @override
  CSSLengthValue get paddingBottom => _paddingBottom ?? CSSLengthValue.zero;

  CSSLengthValue? _paddingTop;
  set paddingTop(CSSLengthValue? value) {
    if (_paddingTop == value) return;
    _paddingTop = value;
    _markSelfAndParentNeedsLayout();
  }

  @override
  CSSLengthValue get paddingTop => _paddingTop ?? CSSLengthValue.zero;

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
      paddingLeft.compute(this) + innerSize.width + paddingRight.compute(this),
      paddingTop.compute(this) + innerSize.height + paddingBottom.compute(this)
    );
  }

  void debugPaddingProperties(DiagnosticPropertiesBuilder properties) {
    properties.add(DiagnosticsProperty('padding', padding));
  }
}
