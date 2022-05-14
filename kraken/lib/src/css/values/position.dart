/*
 * Copyright (C) 2019-present The Kraken authors. All rights reserved.
 */

import 'package:flutter/painting.dart';
import 'package:kraken/css.dart';
import 'package:quiver/collection.dart';

final RegExp _splitRegExp = RegExp(r'\s+');
final LinkedLruHashMap<String, List<String>> _cachedParsedPosition = LinkedLruHashMap(maximumSize: 100);

/// CSS Values and Units: https://drafts.csswg.org/css-values-3/#position
/// The <position> value specifies the position of a object area
/// (e.g. background image) inside a positioning area (e.g. background
/// positioning area). It is interpreted as specified for background-position.
/// [CSS3-BACKGROUND]
class CSSPosition {
  // [0, 1]
  static Alignment initial = Alignment.topLeft; // default value.

  /// Parse background-position shorthand to background-position-x and background-position-y list.
  static List<String> parsePositionShorthand(String input) {
    if (_cachedParsedPosition.containsKey(input)) {
      return _cachedParsedPosition[input]!;
    }
    List<String> positions = [];
    List<String> split = input.split(_splitRegExp);
    if (split.length == 1) {
      switch(split.first) {
        case TOP:
        case BOTTOM:
          positions.add(CENTER);
          positions.add(split.first);
          break;
        case LEFT:
        case RIGHT:
          positions.add(split.first);
          positions.add(CENTER);
          break;
        default:
          positions.add(split.first);
          positions.add(CENTER);
          break;
      }
    } else if (split.length == 2) {
      positions.add(split.first);
      positions.add(split.last);
    }
    return _cachedParsedPosition[input] = positions;
  }

  /// Parse background-position-x/background-position-y from string to CSSBackgroundPosition type.
  static CSSBackgroundPosition resolveBackgroundPosition(String input, RenderStyle renderStyle, String propertyName, bool isHorizontal) {
    if (CSSPercentage.isPercentage(input)) {
      return CSSBackgroundPosition(percentage: _gatValuePercentage(input));
    } else if (CSSLength.isLength(input)) {
      return CSSBackgroundPosition(length: CSSLength.parseLength(input, renderStyle, propertyName));
    } else {
      if (isHorizontal) {
        switch (input) {
          case LEFT:
            return CSSBackgroundPosition(percentage: -1);
          case RIGHT:
            return CSSBackgroundPosition(percentage: 1);
          case CENTER:
            return CSSBackgroundPosition(percentage: 0);
          default:
            return CSSBackgroundPosition(percentage: -1);
        }
      } else {
        switch (input) {
          case TOP:
            return CSSBackgroundPosition(percentage: -1);
          case BOTTOM:
            return CSSBackgroundPosition(percentage: 1);
          case CENTER:
            return CSSBackgroundPosition(percentage: 0);
          default:
            return CSSBackgroundPosition(percentage: -1);
        }
      }
    }
  }

  static double _gatValuePercentage(String input) {
    var percentageValue = input.substring(0, input.length - 1);
    return (double.tryParse(percentageValue) ?? 0) / 50 - 1;
  }
}
