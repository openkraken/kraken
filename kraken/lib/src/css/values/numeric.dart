/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'value.dart';

const String PERCENTAGE = '%';

// CSS Values and Units: https://drafts.csswg.org/css-values-3/#integers
class CSSInteger implements CSSValue<int> {

  int _value = 0;

  final String _rawInput;
  CSSInteger(this._rawInput) {
    parse();
  }

  int valueOf() => _value;

  @override
  int get computedValue => _value;

  @override
  void parse() {
    _value = int.tryParse(_rawInput);
  }

  @override
  String get serializedValue => _value.toString();
}

// CSS Values and Units: https://drafts.csswg.org/css-values-3/#numbers
class CSSNumber implements CSSValue<double>  {
  double _value = 0.0;

  final String _rawInput;
  CSSNumber(this._rawInput) {
    parse();
  }

  double toDouble() => computedValue;

  int toInt() => _value.toInt();

  @override
  double get computedValue => _value;

  @override
  void parse() {
    _value = double.tryParse(_rawInput);
  }

  @override
  String get serializedValue => _value.toString();
}

// CSS Values and Units: https://drafts.csswg.org/css-values-3/#percentages
class CSSPercentage implements CSSValue<double> {
  static bool isPercentage(String percentageValue) {
    return percentageValue != null && percentageValue.endsWith(PERCENTAGE);
  }

  final String _rawInput;
  double _value = 0.0;
  double toDouble() => _value;

  CSSPercentage(this._rawInput) {
    parse();
  }

  @override
  double get computedValue => _value;

  @override
  void parse() {
    if (_rawInput.endsWith(PERCENTAGE)) {
      _value = double.tryParse(_rawInput.split(PERCENTAGE)[0]) / 100;
    }
  }

  @override
  String get serializedValue => _value.toString();
}
