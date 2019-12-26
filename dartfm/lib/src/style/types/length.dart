/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:ui';

double devicePixelRatio = window.devicePixelRatio;
Size physicalSize = window.physicalSize;

double toDouble(value) {
  if (value is double) {
    return value;
  } else if (value is int) {
    return value.toDouble();
  } else if (value is String) {
    return double.parse(value);
  } else {
    return 0.0;
  }
}

class Length {
  static const String RPX = 'rpx';
  static const String PX = 'px';
  static const String VW = 'vw';
  static const String VH = 'vh';

  static RegExp NUMBERIC_REGEXP = RegExp(r"^[+-]?(\d+)?(\.\d+)?$");

  String currentUnit = '';
  double currentValue = 0.0;
  double displayPortValue = 0.0;

  Length(String unitedValue) {
    if (unitedValue == null) {
      return;
    }

    unitedValue = unitedValue.trim();

    if (unitedValue.endsWith(RPX)) {
      currentUnit = RPX;
      currentValue = double.parse(unitedValue.split(RPX)[0]);
      displayPortValue =
          currentValue / 750.0 * physicalSize.width / devicePixelRatio;
    } else if (unitedValue.endsWith(PX)) {
      currentUnit = PX;
      currentValue = double.parse(unitedValue.split(PX)[0]);
      displayPortValue = currentValue / devicePixelRatio;
    } else if (unitedValue.endsWith(VW)) {
      currentUnit = VW;
      currentValue = double.parse(unitedValue.split(VW)[0]);
      displayPortValue =
          currentValue / 100.0 * physicalSize.width / devicePixelRatio;
    } else if (unitedValue.endsWith(VH)) {
      currentUnit = VH;
      currentValue = double.parse(unitedValue.split(VH)[0]);
      displayPortValue =
          currentValue / 100.0 * physicalSize.height / devicePixelRatio;
    }
  }
}
