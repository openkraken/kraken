// CSS Values and Units: https://drafts.csswg.org/css-values-3/#functional-notations

import 'value.dart';

/// https://drafts.csswg.org/css-values-3/#functional-notations
class CSSFunctionalNotation {
  final String name;
  final List<String> args;

  CSSFunctionalNotation(this.name, this.args);
}

// ignore: public_member_api_docs
class CSSFunction implements CSSValue<List<CSSFunctionalNotation>> {
  final String _rawInput;
  List<CSSFunctionalNotation> _value;

  /// Returns a CSSFunction.
  CSSFunction(this._rawInput) {
    parse();
  }

  @override
  void parse() {
    var start = 0;
    var left = _rawInput.indexOf('(', start);
    var right = _rawInput.indexOf(')', start);
    _value = [];

    while (left != -1 && right != -1 && right > left + 1) {
      var args = _rawInput.substring(left + 1, right).trim();
      var argList = args.split(',');
      var fn = _rawInput.substring(start, left);
      _value.add(CSSFunctionalNotation(fn.trim(), argList));
      start = right + 1;
      left = _rawInput.indexOf('(', start);
      right = _rawInput.indexOf(')', start);
    }
  }

  @override
  List<CSSFunctionalNotation> get computedValue => _value;

  @override
  String get serializedValue => _rawInput;
}
