/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'package:flutter/rendering.dart';
import 'package:kraken/css.dart';

mixin CSSObjectPositionMixin on RenderStyle {
  @override
  Alignment get objectPosition => _objectPosition;
  Alignment _objectPosition = Alignment.center;
  set objectPosition(Alignment value) {
    if (_objectPosition == value) return;
    _objectPosition = value;
    renderBoxModel?.markNeedsLayout();
  }

  static Alignment resolveObjectPosition(String? position) {
    // Syntax: object-position: <position>
    // position: From one to four values that define the 2D position of the element. Relative or absolute offsets can be used.
    // <position> = [ [ left | center | right ] || [ top | center | bottom ] | [ left | center | right | <length-percentage> ] [ top | center | bottom | <length-percentage> ]? | [ [ left | right ] <length-percentage> ] && [ [ top | bottom ] <length-percentage> ] ]

    if (position != null) {
      List<String?> values = CSSStyleProperty.getPositionValues(position);
      return Alignment(_getAlignmentValueFromString(values[0]!), _getAlignmentValueFromString(values[1]!));
    }

    // The default value for object-position is 50% 50%
    return Alignment.center;
  }

  static double _getAlignmentValueFromString(String value) {

    // Support percentage
    if (value.endsWith('%')) {
      // 0% equal to -1.0
      // 50% equal to 0.0
      // 100% equal to 1.0
      return double.tryParse(value.substring(0, value.length - 1))! / 50 - 1;
    }

    switch (value) {
      case 'top':
      case 'left':
        return -1;

      case 'bottom':
      case 'right':
        return 1;

      case 'center':
      default:
        return 0;
    }
  }
}
