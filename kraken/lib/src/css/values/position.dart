import 'value.dart';

enum CSSPositionValue {
  left,
  right,
  center,
  top,
  bottom,
}

// https://drafts.csswg.org/css-values-3/#position
class CSSPosition implements CSSValue<CSSPositionValue> {
  static const String LEFT = 'left';
  static const String RIGHT = 'right';
  static const String TOP = 'top';
  static const String BOTTOM = 'bottom';
  static const String CENTER = 'center';

  CSSPositionValue value;

  final String _rawInput;
  CSSPosition(this._rawInput);

  bool _parsed = false;
  @override
  void parse() {
    if (!_parsed) _parse();
    _parsed = true;
  }

  void _parse() {
    switch (_rawInput) {
      case LEFT: value = CSSPositionValue.left; break;
      case TOP: value = CSSPositionValue.top; break;
      case BOTTOM: value = CSSPositionValue.bottom; break;
      case CENTER: value = CSSPositionValue.center; break;
      case RIGHT: value = CSSPositionValue.right; break;
    }
  }

  @override
  CSSPositionValue get computedValue {
    parse();
    return value;
  }

  @override
  String get serializedValue {
    parse();
    return value.toString();
  }

  @override
  String toString() {
    return 'CSSPosition($value)';
  }
}
