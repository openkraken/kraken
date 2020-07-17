/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:ui';
import 'value.dart';

// CSS Values and Units: https://drafts.csswg.org/css-values-3/#lengths
class CSSLength implements CSSValue<double> {
  static const String RPX = 'rpx';
  static const String PX = 'px';
  static const String VW = 'vw';
  static const String VH = 'vh';

  static bool isValidateLength(String value) {
    return value != null && value.endsWith(RPX) || value.endsWith(PX) || value.endsWith(VW) || value.endsWith(VH);
  }

  static RegExp NUMBERIC_REGEXP = RegExp(r"^[+-]?(\d+)?(\.\d+)?$");

  static double toDouble(value) {
    if (value is double) {
      return value;
    } else if (value is int) {
      return value.toDouble();
    } else if (value is String) {
      return double.tryParse(value) ?? 0.0;
    } else {
      return 0.0;
    }
  }

  static int toInt(value) {
    if (value is double) {
      return value.toInt();
    } else if (value is int) {
      return value;
    } else if (value is String) {
      return int.tryParse(value) ?? 0;
    } else {
      return 0;
    }
  }


  //todo maybe relate to ElementManger Index
  static double displayWidth = window.physicalSize.width;
  static double displayHeight = 1850;

  static double toDisplayPortValue(String unitedValue) {
    double displayPortValue = 0.0;

    if (unitedValue == null) return null;
    unitedValue = unitedValue.trim();
    if (unitedValue == INITIAL) return null;

    // Only '0' is accepted with no unit.
    if (unitedValue == '0') {
      return 0;
    } else if (unitedValue.endsWith(RPX)) {
      double currentValue = double.parse(unitedValue.split(RPX)[0]);
      displayPortValue = currentValue / 750.0 * displayWidth / window.devicePixelRatio;
    } else if (unitedValue.endsWith(PX)) {
      double currentValue = double.parse(unitedValue.split(PX)[0]);
      displayPortValue = currentValue;
    } else if (unitedValue.endsWith(VW)) {
      double currentValue = double.parse(unitedValue.split(VW)[0]);
      displayPortValue = currentValue / 100.0 * displayWidth / window.devicePixelRatio;
    } else if (unitedValue.endsWith(VH)) {
      double currentValue = double.parse(unitedValue.split(VH)[0]);
      displayPortValue = currentValue / 100.0 * displayHeight / window.devicePixelRatio;
    } else {
      // Failed silently.
      return null;
    }

    return displayPortValue;
  }

  static bool isLength(String value) {
    return value != null &&
        (value == '0' || value.endsWith(RPX) || value.endsWith(PX) || value.endsWith(VH) || value.endsWith(VW));
  }

  final String _rawInput;
  double _value;
  CSSLength(this._rawInput) {
    parse();
  }

  @override
  double get computedValue => _value;

  @override
  void parse() {
    _value = CSSLength.toDisplayPortValue(_rawInput);
  }

  @override
  String get serializedValue => _rawInput;
}
