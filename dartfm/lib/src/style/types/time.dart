/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

class Time {
  static const String MILLISECONDS = 'ms';
  static const String SECOND = 's';
  static Time zero = Time("0s");

  Seconds _value;

  Time(String value) {
    if (value != null) {
      if (value.endsWith(MILLISECONDS)) {
        _value = Milliseconds(value.split(MILLISECONDS)[0]);
      } else if (value.endsWith(SECOND)) {
        _value = Seconds(value.split(SECOND)[0]);
      }
    }
  }

  int valueOf() => _value?.valueOf();
}

class Seconds {
  double _value = 0;

  Seconds(String secondValue) {
    if (secondValue != null) {
      _value = double.parse(secondValue);
    }
  }

  int valueOf() => _value == null ? 0 : (_value * 1000).toInt();
}

class Milliseconds extends Seconds {
  Milliseconds(String millisecondValue) : super(millisecondValue);

  int ValueOf() => _value.toInt();
}
