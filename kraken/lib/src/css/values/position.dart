import 'package:flutter/painting.dart';
import 'package:kraken/css.dart';

/// CSS Values and Units: https://drafts.csswg.org/css-values-3/#position
/// The <position> value specifies the position of a object area
/// (e.g. background image) inside a positioning area (e.g. background
/// positioning area). It is interpreted as specified for background-position.
/// [CSS3-BACKGROUND]
class CSSPosition implements CSSValue<Alignment> {
  static const String LEFT = 'left';
  static const String RIGHT = 'right';
  static const String TOP = 'top';
  static const String BOTTOM = 'bottom';
  static const String CENTER = 'center';

  // [0, 1]
  Alignment _value = Alignment.topLeft; // default value.

  final String _rawInput;
  CSSPosition(this._rawInput);

  bool _parsed = false;
  @override
  void parse() {
    if (!_parsed) _parse();
    _parsed = true;
  }

  void _parse() {
    var normalized = _rawInput.trim();
    List<String> split = normalized.split(spaceRegExp);

    if (split.length == 1) {
      // If one value is set, another value should be center(0).
      var dx = _getValueX(split.first, initial: 0);
      var dy = _getValueY(split.first, initial: 0);
      _value = Alignment(dx, dy);
    } else if (split.length == 2) {
      _value = Alignment(_getValueX(split.first), _getValueY(split.last));
    }
    // Silently failed.
  }

  static double _gatValuePercentage(String input) {
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

  @override
  Alignment get computedValue {
    parse();
    return _value;
  }

  @override
  String get serializedValue {
    parse();
    var x = _value.x;
    var y = _value.y;

    if (x == -1.0 && y == -1.0) return 'top left';
    if (x == 0.0 && y == -1.0) return 'top center';
    if (x == 1.0 && y == -1.0) return 'top right';
    if (x == -1.0 && y == 0.0) return 'center left';
    if (x == 0.0 && y == 0.0) return 'center';
    if (x == 1.0 && y == 0.0) return 'center right';
    if (x == -1.0 && y == 1.0) return 'bottom left';
    if (x == 0.0 && y == 1.0) return 'bottom center';
    if (x == 1.0 && y == 1.0) return 'bottom right';
    return '${x * 100}%, ${y * 100}%';
  }

  @override
  String toString() {
    return 'CSSPosition($serializedValue)';
  }
}
