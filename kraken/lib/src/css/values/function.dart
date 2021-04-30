// CSS Values and Units: https://drafts.csswg.org/css-values-3/#functional-notations

final _functionRegExp = RegExp(r'^[a-zA-Z_]+\(.+\)$', caseSensitive: false);
final _functionStart = '(';
final _functionEnd = ')';
final _functionNotationUrl = 'url';

const String FUNCTION_SPLIT = ',';
const String FUNCTION_ARGS_SPLIT = ',';

// ignore: public_member_api_docs
class CSSFunction {

  static bool isFunction(String value) {
    return value != null && _functionRegExp.hasMatch(value);
  }

  static List<CSSFunctionalNotation> parseFunction(String value) {
    var start = 0;
    var left = value.indexOf(_functionStart, start);
    List<CSSFunctionalNotation> notations = [];

    // function may contain function, should handle this situation
    while (left != -1 && start < left) {
      String fn = value.substring(start, left);
      int argsBeginIndex = left + 1;
      List<String> argList = [];
      int argBeginIndex = argsBeginIndex;
      // contains function count
      int containLeftCount = 0;
      bool match = false;
      // find all args in this function
      while (argsBeginIndex < value.length) {
        // url() function notation should not be splitted cause it only accept one URL.
        // https://drafts.csswg.org/css-values-3/#urls
        if (fn != _functionNotationUrl && value[argsBeginIndex] == FUNCTION_ARGS_SPLIT) {
          if (containLeftCount == 0 && argBeginIndex < argsBeginIndex) {
            argList.add(value.substring(argBeginIndex, argsBeginIndex));
            argBeginIndex = argsBeginIndex + 1;
          }
        } else if (value[argsBeginIndex] == _functionStart) {
          containLeftCount++;
        } else if (value[argsBeginIndex] == _functionEnd) {
          if (containLeftCount > 0) {
            containLeftCount--;
          } else {
            if (argBeginIndex < argsBeginIndex) {
              argList.add(value.substring(argBeginIndex, argsBeginIndex));
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
        fn = fn.trim();
        if (fn.startsWith(FUNCTION_SPLIT)) {
          fn = fn.substring(1, ).trim();
        }
        notations.add(CSSFunctionalNotation(fn, argList));
      }
      start = argsBeginIndex + 1;
      if (start >= value.length) {
        break;
      }
      left = value.indexOf(_functionStart, start);
    }

    return notations;
  }
}

/// https://drafts.csswg.org/css-values-3/#functional-notations
class CSSFunctionalNotation {
  final String name;
  final List<String> args;

  CSSFunctionalNotation(this.name, this.args);

  String toString() => 'CSSFunctionalNotation($name: $args)';
}
