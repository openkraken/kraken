

/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'package:flutter/painting.dart';
import 'package:kraken/css.dart';

final RegExp _splitRegExp = RegExp(r'\s+');

class CSSStylePosition {
  CSSStylePosition({
    this.length,
    this.percentage,
  });
  /// Absolute position to image container when length type is set.
  double? length;
  /// Relative position to image container when keyword or percentage type is set.
  double? percentage;
}

/// CSS Values and Units: https://drafts.csswg.org/css-values-3/#position
/// The <position> value specifies the position of a object area
/// (e.g. background image) inside a positioning area (e.g. background
/// positioning area). It is interpreted as specified for background-position.
/// [CSS3-BACKGROUND]
class CSSPosition {
  static const String LEFT = 'left';
  static const String RIGHT = 'right';
  static const String TOP = 'top';
  static const String BOTTOM = 'bottom';
  static const String CENTER = 'center';

  // [0, 1]
  static Alignment initial = Alignment.topLeft; // default value.

  static CSSStylePosition parsePosition(String input, Size viewportSize, bool isHorizontal) {
    if (CSSLength.isPercentage(input)) {
      return CSSStylePosition(percentage: _gatValuePercentage(input));
    } else if (CSSLength.isLength(input)) {
      return CSSStylePosition(length: CSSLength.toDisplayPortValue(input, viewportSize));
    } else {
      if (isHorizontal) {
        switch (input) {
          case LEFT:
            return CSSStylePosition(percentage: -1);
          case RIGHT:
            return CSSStylePosition(percentage: 1);
          case CENTER:
            return CSSStylePosition(percentage: 0);
          default:
            return CSSStylePosition(percentage: -1);
        }
      } else {
        switch (input) {
          case TOP:
            return CSSStylePosition(percentage: -1);
          case BOTTOM:
            return CSSStylePosition(percentage: 1);
          case CENTER:
            return CSSStylePosition(percentage: 0);
          default:
            return CSSStylePosition(percentage: -1);
        }
      }
    }
  }

  static double? _gatValuePercentage(String input) {
    var percentageValue = input.substring(0, input.length - 1);
    return (double.tryParse(percentageValue) ?? 0) / 50 - 1;
  }
}
