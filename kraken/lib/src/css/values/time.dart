/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

// https://drafts.csswg.org/css-values-3/#time
import 'value.dart';

class CSSTime implements CSSValue<double> {
  static const String MILLISECONDS = 'ms';
  static const String SECOND = 's';
  static CSSTime zero = CSSTime('0s');

  CSSSeconds _value;

  final String _rawInput;
  CSSTime(this._rawInput) {
    parse();
  }

  @override
  double get computedValue => _value?.computedValue;

  @override
  void parse() {
    if (_rawInput.endsWith(MILLISECONDS)) {
      _value = CSSMilliseconds(_rawInput.split(MILLISECONDS)[0]);
    } else if (_rawInput.endsWith(SECOND)) {
      _value = CSSSeconds(_rawInput.split(SECOND)[0]);
    }
  }

  @override
  String get serializedValue => computedValue?.toString();
}

class CSSSeconds implements CSSValue<double> {
  double _value = 0;

  final String _rawInput;
  CSSSeconds(this._rawInput) {
    parse();
  }

  @override
  double get computedValue => _value == null ? 0 : _value * 1000;

  @override
  void parse() {
    _value = double.tryParse(_rawInput);
  }

  @override
  String get serializedValue => computedValue.toString();
}

class CSSMilliseconds extends CSSSeconds {
  CSSMilliseconds(String millisecondValue) : super(millisecondValue);

  @override
  double get computedValue => _value ?? 0;
}
