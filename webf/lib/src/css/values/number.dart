/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

// CSS Values and Units: https://drafts.csswg.org/css-values-3/#numbers
final RegExp _numberRegExp = RegExp(r'^[+-]?(\d+)?(\.\d+)?$');

class CSSNumber {
  static double? parseNumber(String input) {
    return double.tryParse(input);
  }

  static bool isNumber(String input) {
    return _numberRegExp.hasMatch(input);
  }
}
