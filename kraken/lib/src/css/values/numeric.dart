/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'value.dart';

const String PERCENTAGE = '%';
final RegExp _numberRegExp = RegExp(r'^[+-]?(\d+)?(\.\d+)?$');

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
class CSSNumber {
  static double parseNumber(String input) {
    return double.tryParse(input);
  }

  static bool isNumber(String input) {
    return input != null && _numberRegExp.hasMatch(input);
  }
}

// CSS Values and Units: https://drafts.csswg.org/css-values-3/#percentages
class CSSPercentage implements CSSValue<double> {
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

  static bool isPercentage(String percentageValue) {
    return percentageValue != null && percentageValue.endsWith(PERCENTAGE);
  }
}
