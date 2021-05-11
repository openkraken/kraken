/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'package:flutter/rendering.dart';
import 'package:kraken/css.dart';

mixin CSSObjectFitMixin on RenderStyleBase {
  BoxFit _objectFit = BoxFit.fill;
  BoxFit get objectFit {
    return _objectFit;
  }
  set objectFit(BoxFit value) {
    if (_objectFit == value) return;
    _objectFit = value;
  }

  void updateObjectFit(String property, String value, {bool shouldMarkNeedsLayout = true}) {
    RenderStyle renderStyle = this;
    renderStyle.objectFit = _getBoxFit(value);
    if (shouldMarkNeedsLayout) {
      renderBoxModel.markNeedsLayout();
    }
  }

  BoxFit _getBoxFit(String fit) {
    switch (fit) {
      case 'contain':
        return BoxFit.contain;

      case 'cover':
        return BoxFit.cover;

      case 'none':
        return BoxFit.none;

      case 'scaleDown':
      case 'scale-down':
        return BoxFit.scaleDown;

      case 'fitWidth':
      case 'fit-width':
        return BoxFit.fitWidth;

      case 'fitHeight':
      case 'fit-height':
        return BoxFit.fitHeight;

      case 'fill':
      default:
        return BoxFit.fill;
    }
  }
}
