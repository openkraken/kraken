/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
final _timeRegExp = RegExp(r'^[+-]?(\d+)?(\.\d+)?ms|s$', caseSensitive: false);
final _0s = '0s';
final _0ms = '0ms';

// CSS Values and Units: https://drafts.csswg.org/css-values-3/#time
class CSSTime {
  static const String MILLISECONDS = 'ms';
  static const String SECOND = 's';

  static bool isTime(String value) {
    return value != null && (value == _0s || value == _0ms || _timeRegExp.firstMatch(value) != null);
  }

  static int? parseTime(String input) {
    double? milliseconds;
    if (input.endsWith(MILLISECONDS)) {
      double? v = double.tryParse(input.split(MILLISECONDS)[0]);
      if (v == null) return null;
      milliseconds = v;
    } else if (input.endsWith(SECOND)) {
      double? v = double.tryParse(input.split(SECOND)[0]);
      if (v == null) return null;
      milliseconds = v * 1000;
    }
    return milliseconds!.toInt();
  }
}
