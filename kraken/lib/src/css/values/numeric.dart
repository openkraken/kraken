/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
const String PERCENTAGE = '%';

// https://drafts.csswg.org/css-values-3/#integers
class CSSInteger {
  int _value = 0;
  CSSInteger(String intValue) {
    _value = int.parse(intValue);
  }

  int valueOf() => _value;
}

// https://drafts.csswg.org/css-values-3/#numbers
class CSSNumber {
  double _value;

  CSSNumber(String numericValue) {
    try {
      _value = double.parse(numericValue);
    } catch (exception) {
      _value = 0.0;
    }
  }

  double toDouble() => _value;

  int toInt() => _value.toInt();
}

// https://drafts.csswg.org/css-values-3/#percentages
class CSSPercentage {
  double _value = 0.0;

  CSSPercentage(String percentageValue) {
    if (percentageValue.endsWith(PERCENTAGE)) {
      try {
        _value = double.parse(percentageValue.split(PERCENTAGE)[0]) / 100;
      } catch (exception) {}
    }
  }

  static bool isPercentage(String percentageValue) {
    return percentageValue != null && percentageValue.endsWith(PERCENTAGE);
  }

  double toDouble() => _value;
}
