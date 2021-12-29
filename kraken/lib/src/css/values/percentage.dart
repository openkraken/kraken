/*
 * Copyright (C) 2021-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

// CSS Values and Units: https://drafts.csswg.org/css-values-3/#percentages

import 'package:quiver/collection.dart';

final _percentageRegExp = RegExp(r'^[+-]?\d+[\.]?\d*\%$', caseSensitive: false);
final _nonNegativePercentageRegExp = RegExp(r'^[+]?\d+[\.]?\d*\%$', caseSensitive: false);
final LinkedLruHashMap<String, double?> _cachedParsedPercentage = LinkedLruHashMap(maximumSize: 100);

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

  static bool isNonNegativePercentage(String? percentageValue) {
    return percentageValue != null && _nonNegativePercentageRegExp.hasMatch(percentageValue);
  }
}
