/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:ui';

abstract class Length {
  static const String RPX = 'rpx';
  static const String PX = 'px';
  static const String VW = 'vw';
  static const String VH = 'vh';

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

  static double toDisplayPortValue(String unitedValue) {
    double displayPortValue = 0.0;

    if (unitedValue == null) return displayPortValue;
    unitedValue = unitedValue.trim();

    if (unitedValue.endsWith(RPX)) {
      double currentValue = double.parse(unitedValue.split(RPX)[0]);
      displayPortValue = currentValue /
          750.0 *
          window.physicalSize.width /
          window.devicePixelRatio;
    } else if (unitedValue.endsWith(PX)) {
      double currentValue = double.parse(unitedValue.split(PX)[0]);
      displayPortValue = currentValue;
    } else if (unitedValue.endsWith(VW)) {
      double currentValue = double.parse(unitedValue.split(VW)[0]);
      displayPortValue = currentValue /
          100.0 *
          window.physicalSize.width /
          window.devicePixelRatio;
    } else if (unitedValue.endsWith(VH)) {
      double currentValue = double.parse(unitedValue.split(VH)[0]);
      displayPortValue = currentValue /
          100.0 *
          window.physicalSize.height /
          window.devicePixelRatio;
    }
    // Failed silently

    return displayPortValue;
  }

  static bool isLength(String value) {
    return value != null &&
        (value.endsWith(RPX) || value.endsWith(PX) || value.endsWith(VH) ||
            value.endsWith(VW));
  }
}
