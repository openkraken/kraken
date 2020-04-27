/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

// CSS Values and Units: https://drafts.csswg.org/css-values-3/#time

class CSSTime {
  static const String MILLISECONDS = 'ms';
  static const String SECOND = 's';
  static CSSTime zero = CSSTime('0s');

  CSSSeconds _value;

  CSSTime(String value) {
    if (value != null) {
      if (value.endsWith(MILLISECONDS)) {
        _value = CSSMilliseconds(value.split(MILLISECONDS)[0]);
      } else if (value.endsWith(SECOND)) {
        _value = CSSSeconds(value.split(SECOND)[0]);
      }
    }
  }

  int valueOf() => _value?.valueOf();
}

class CSSSeconds {
  double _value = 0;

  CSSSeconds(String secondValue) {
    if (secondValue != null) {
      _value = double.parse(secondValue);
    }
  }

  int valueOf() => _value == null ? 0 : (_value * 1000).toInt();
}

class CSSMilliseconds extends CSSSeconds {
  CSSMilliseconds(String millisecondValue) : super(millisecondValue);

  int valueOf() => _value.toInt();
}
