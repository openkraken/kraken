

import 'package:flutter/painting.dart';

final RegExp _splitRegExp = RegExp(r'\s+');

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

  static Alignment? parsePosition(String input) {
    String normalized = input.trim();
    if (normalized.isEmpty) return initial;

    Alignment? parsed;
    List<String> split = normalized.split(_splitRegExp);

    if (split.length == 1) {
      // If one value is set, another value should be center(0).
      double dx = _getValueX(split.first, initial: 0);
      double dy = _getValueY(split.first, initial: 0);
      parsed = Alignment(dx, dy);
    } else if (split.length == 2) {
      parsed = Alignment(_getValueX(split.first), _getValueY(split.last));
    }
    return parsed;
  }

  static double? _gatValuePercentage(String input) {
    if (input.endsWith('%')) {
      var percentageValue = input.substring(0, input.length - 1);
      return (double.tryParse(percentageValue) ?? 0) / 50 - 1;
    } else {
      return null;
    }
  }

  static double _getValueX(String input, {double initial = -1}) {
    switch (input) {
      case LEFT:
        return -1;
      case RIGHT:
        return 1;
      case CENTER:
        return 0;
    }
    return _gatValuePercentage(input) ?? initial;
  }

  static double _getValueY(String input, {double initial = 1}) {
    switch (input) {
      case TOP:
        return -1;
      case BOTTOM:
        return 1;
      case CENTER:
        return 0;
    }
    return _gatValuePercentage(input) ?? initial;
  }
}
