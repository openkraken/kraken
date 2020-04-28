// https://drafts.csswg.org/css-values-3/#functional-notations
import 'value.dart';

// ignore: public_member_api_docs
class CSSFunctionValue implements CSSValue<Map<String, List<String>>> {

  final String _rawInput;
  Map<String, List<String>> _value;

  /// Returns a CSSFunctionValue.
  CSSFunctionValue(this._rawInput) {
    parse();
  }

  @override
  void parse() {
    var start = 0;
    var left = _rawInput.indexOf('(', start);
    var right = _rawInput.indexOf(')', start);
    _value = {};

    while (left != -1 && right != -1 && right > left + 1) {
      var args = _rawInput.substring(left + 1, right).trim();
      var argList = args.split(',');
      var fn = _rawInput.substring(start, left);
      _value[fn.trim()] = argList;
      start = right + 1;
      left = _rawInput.indexOf('(', start);
      right = _rawInput.indexOf(')', start);
    }
  }

  @override
  Map<String, List<String>> get computedValue => _value;

  @override
  String get serializedValue => _rawInput;
}
