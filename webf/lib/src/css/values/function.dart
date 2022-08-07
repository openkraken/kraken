/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

// CSS Values and Units: https://drafts.csswg.org/css-values-3/#functional-notations

import 'package:quiver/collection.dart';

// DotAll means accept line terminators like `\n`.
final _functionRegExp = RegExp(r'^[a-zA-Z-_]+\(.+\)$', dotAll: true);
final _functionStart = '(';
final _functionEnd = ')';
final _functionNotationUrl = 'url';

const String FUNCTION_SPLIT = ',';
const String FUNCTION_ARGS_SPLIT = ',';

final LinkedLruHashMap<String, List<CSSFunctionalNotation>> _cachedParsedFunction = LinkedLruHashMap(maximumSize: 100);

// ignore: public_member_api_docs
class CSSFunction {
  static bool isFunction(String value, {String? functionName}) {
    if (functionName != null) {
      bool isMatch;
      final int functionNameLength = functionName.length;

      if (value.length < functionNameLength) {
        return false;
      }

      for (int i = 0; i < functionNameLength; i++) {
        isMatch = functionName.codeUnitAt(i) == value.codeUnitAt(i);
        if (!isMatch) {
          return false;
        }
      }
    }

    return _functionRegExp.hasMatch(value);
  }

  static List<CSSFunctionalNotation> parseFunction(final String value) {
    if (_cachedParsedFunction.containsKey(value)) {
      return _cachedParsedFunction[value]!;
    }

    final int valueLength = value.length;
    final List<CSSFunctionalNotation> notations = [];

    int start = 0;
    int left = value.indexOf(_functionStart, start);

    // Function may contain function, should handle this situation.
    while (left != -1 && start < left) {
      String fn = value.substring(start, left);
      int argsBeginIndex = left + 1;
      List<String> argList = [];
      int argBeginIndex = argsBeginIndex;
      // Contain function count.
      int containLeftCount = 0;
      bool match = false;
      // Find all args in this function.
      while (argsBeginIndex < valueLength) {
        // url() function notation should not be split causing it only accept one URL.
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
            // Function parse success when find the matched right parenthesis.
            match = true;
            break;
          }
        }
        argsBeginIndex++;
      }
      if (match) {
        // Only add the right function.
        fn = fn.trim();
        if (fn.startsWith(FUNCTION_SPLIT)) {
          fn = fn
              .substring(
                1,
              )
              .trim();
        }
        notations.add(CSSFunctionalNotation(fn, argList));
      }
      start = argsBeginIndex + 1;
      if (start >= value.length) {
        break;
      }
      left = value.indexOf(_functionStart, start);
    }

    return _cachedParsedFunction[value] = notations;
  }
}

/// https://drafts.csswg.org/css-values-3/#functional-notations
class CSSFunctionalNotation {
  final String name;
  final List<String> args;

  CSSFunctionalNotation(this.name, this.args);

  @override
  String toString() => 'CSSFunctionalNotation($name: $args)';
}
