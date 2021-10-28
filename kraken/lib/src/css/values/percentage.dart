/*
 * Copyright (C) 2021-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

// CSS Values and Units: https://drafts.csswg.org/css-values-3/#percentages

final _percentageRegExp = RegExp(r'^[-]*\d+\%$', caseSensitive: false);
final Map<String, double?> _cachedParsedPercentage = {};

class CSSPercentage {
  static String PERCENTAGE = '%';

  static double? parsePercentage(String value) {
    if (_cachedParsedPercentage.containsKey(value)) {
      return _cachedParsedPercentage[value];
    }
    double? parsed;
    if (value.endsWith(PERCENTAGE)) {
      parsed = double.tryParse(value.split(PERCENTAGE)[0])! / 100;
    }
    return _cachedParsedPercentage[value] = parsed;
  }

  static bool isPercentage(String? percentageValue) {
    return percentageValue != null && _percentageRegExp.hasMatch(percentageValue);
  }
}
