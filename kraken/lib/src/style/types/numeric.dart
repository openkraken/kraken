/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
const String PERCENTAGE = '%';

class Integer {
  int _value = 0;
  Integer(String intValue) {
    _value = int.parse(intValue);
  }

  int valueOf() => _value;
}

class Number {
  double _value;

  Number(String numericValue) {
    try {
      _value = double.parse(numericValue);
    } catch (exception) {
      _value = 0.0;
    }
  }

  double toDouble() => _value;

  int toInt() => _value.toInt();
}

class Percentage {
  double _value = 0.0;

  Percentage(String percentageValue) {
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
