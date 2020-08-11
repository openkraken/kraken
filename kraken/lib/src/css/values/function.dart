// CSS Values and Units: https://drafts.csswg.org/css-values-3/#functional-notations

import 'value.dart';

/// https://drafts.csswg.org/css-values-3/#functional-notations
class CSSFunctionalNotation {
  final String name;
  final List<String> args;

  CSSFunctionalNotation(this.name, this.args);
}

final _functionRegExp = RegExp(r'^[a-zA-Z_]+\(.+\)$', caseSensitive: false);

// ignore: public_member_api_docs
class CSSFunction implements CSSValue<List<CSSFunctionalNotation>> {
  final String _rawInput;
  List<CSSFunctionalNotation> _value;

  /// Returns a CSSFunction.
  CSSFunction(this._rawInput) {
    parse();
  }

  static bool isFunction(String value) {
    return value != null && _functionRegExp.hasMatch(value);
  }

  @override
  void parse() {
    var start = 0;
    var left = _rawInput.indexOf('(', start);
    _value = [];

    // function may contain function, should handle this situation
    while (left != -1 && start < left) {
      String fn = _rawInput.substring(start, left);
      int argsBeginIndex = left + 1;
      List<String> argList = [];
      int argBeginIndex = argsBeginIndex;
      // contains function count
      int containLeftCount = 0;
      bool match = false;
      // find all args in this function
      while (argsBeginIndex < _rawInput.length) {
        if (_rawInput[argsBeginIndex] == ',') {
          if (containLeftCount == 0 && argBeginIndex < argsBeginIndex) {
            argList.add(_rawInput.substring(argBeginIndex, argsBeginIndex));
            argBeginIndex = argsBeginIndex + 1;
          }
        } else if (_rawInput[argsBeginIndex] == '(') {
          containLeftCount++;
        } else if (_rawInput[argsBeginIndex] == ')') {
          if (containLeftCount > 0) {
            containLeftCount--;
          } else {
            if (argBeginIndex < argsBeginIndex) {
              argList.add(_rawInput.substring(argBeginIndex, argsBeginIndex));
              argBeginIndex = argsBeginIndex + 1;
            }
            // function parse success when find the matched right parenthesis
            match = true;
            break;
          }
        }
        argsBeginIndex++;
      }
      if (match) {
        // only add the right function
        _value.add(CSSFunctionalNotation(fn.trim(), argList));
      }
      start = argsBeginIndex + 1;
      if (start >= _rawInput.length) {
        break;
      }
      left = _rawInput.indexOf('(', start);
    }
  }

  @override
  List<CSSFunctionalNotation> get computedValue => _value;

  @override
  String get serializedValue => _rawInput;
}
