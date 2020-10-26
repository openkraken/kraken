/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:ui';

import 'package:kraken/css.dart';

// https://drafts.csswg.org/css-values-3/#absolute-lengths
const _1in = 96; // 1in = 2.54cm = 96px
const _1cm = _1in / 2.54; // 1cm = 96px/2.54
const _1mm = _1cm / 10; // 1mm = 1/10th of 1cm
const _1Q = _1cm / 40; // 1Q = 1/40th of 1cm
const _1pc = _1in / 6; // 1pc = 1/6th of 1in
const _1pt = _1in / 72; // 1pt = 1/72th of 1in

final _lengthRegExp = RegExp(r'^[+-]?(\d+)?(\.\d+)?px|rpx|vw|vh|in|cm|mm|pc|pt$', caseSensitive: false);

// CSS Values and Units: https://drafts.csswg.org/css-values-3/#lengths
class CSSLength {
  static const String RPX = 'rpx';
  static const String PX = 'px';
  static const String VW = 'vw';
  static const String VH = 'vh';
  static const String MM = 'mm';
  static const String CM = 'cm';
  static const String IN = 'in';
  static const String PC = 'pc';
  static const String PT = 'pt';
  static const String Q = 'q';

  static double toDouble(value) {
    if (value is double) {
      return value;
    } else if (value is int) {
      return value.toDouble();
    } else if (value is String) {
      return double.tryParse(value);
    } else {
      return null;
    }
  }

  static int toInt(value) {
    if (value is double) {
      return value.toInt();
    } else if (value is int) {
      return value;
    } else if (value is String) {
      return int.tryParse(value);
    } else {
      return null;
    }
  }

  static bool isAuto(String value) {
    return value == AUTO;
  }

  static double parseLength(String unitedValue) {
    return toDisplayPortValue(unitedValue);
  }

  static double toDisplayPortValue(String unitedValue) {
    if (unitedValue == null || unitedValue.isEmpty) return null;

    unitedValue = unitedValue.trim();
    if (unitedValue == INITIAL) return null;

    double displayPortValue;
    // Only '0' is accepted with no unit.
    if (unitedValue == ZERO) {
      return 0;
    } else if (unitedValue.endsWith(RPX)) {
      double currentValue = double.parse(unitedValue.split(RPX)[0]);
      displayPortValue = currentValue / 750.0 * window.physicalSize.width / window.devicePixelRatio;
    } else if (unitedValue.endsWith(Q)) {
      displayPortValue = double.tryParse(unitedValue.split(Q)[0]) * _1Q;
    } else if (unitedValue.length > 2) {
      switch (unitedValue.substring(unitedValue.length - 2)) {
        case PX:
          displayPortValue = double.tryParse(unitedValue.split(PX)[0]);
          break;
        case VW:
          double currentValue = double.parse(unitedValue.split(VW)[0]);
          displayPortValue = currentValue / 100.0 * window.physicalSize.width / window.devicePixelRatio;
          break;
        case VH:
          double currentValue = double.parse(unitedValue.split(VH)[0]);
          displayPortValue = currentValue / 100.0 * window.physicalSize.height / window.devicePixelRatio;
          break;
        case IN:
          displayPortValue = double.tryParse(unitedValue.split(IN)[0]) * _1in;
          break;
        case CM:
          displayPortValue = double.tryParse(unitedValue.split(CM)[0]) * _1cm;
          break;
        case MM:
          displayPortValue = double.tryParse(unitedValue.split(MM)[0]) * _1mm;
          break;
        case PC:
          displayPortValue = double.tryParse(unitedValue.split(PC)[0]) * _1pc;
          break;
        case PT:
          displayPortValue = double.tryParse(unitedValue.split(PT)[0]) * _1pt;
          break;
      }
    }

    return displayPortValue;
  }

  static bool isLength(String value) {
    return value != null && (value == ZERO || _lengthRegExp.hasMatch(value));
  }

}
