/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

// CSS Values and Units: https://drafts.csswg.org/css-values-3/#common-keywords

final _customIdentRegExp = RegExp(r'^-?[_a-zA-Z]+[_a-zA-Z0-9-]*$', caseSensitive: false);
final _dashedIdentRegExp = RegExp(r'^--[_a-zA-Z]+[_a-zA-Z0-9-]*$', caseSensitive: false);

/// All of these keywords are normatively defined in the Cascade module.
enum CSSWideKeywords {
  /// The initial keyword represents the value specified as the property’s
  /// initial value.
  initial,

  /// The inherit keyword represents the computed value of the property on
  /// the element’s parent.
  inherit,

  /// The unset keyword acts as either inherit or initial, depending on whether
  /// the property is inherited or not.
  unset,
}

class CSSTextual {
  static bool isCustomIdent(String value) {
    return _customIdentRegExp.hasMatch(value);
  }

  static bool isDashedIdent(String value) {
    return _dashedIdentRegExp.hasMatch(value);
  }
}
