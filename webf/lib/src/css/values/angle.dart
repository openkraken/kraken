/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'dart:math' as math;
import 'package:quiver/collection.dart';

// CSS Values and Units: https://drafts.csswg.org/css-values-3/#angles
const String _DEG = 'deg';
const String _GRAD = 'grad';
const String _RAD = 'rad';
const String _TURN = 'turn';

final LinkedLruHashMap<String, double?> _cachedParsedAngle = LinkedLruHashMap(maximumSize: 100);

class CSSAngle {
  /// Judge a string is an angle.
  static bool isAngle(String angle) {
    return (angle.endsWith(_DEG) || angle.endsWith(_GRAD) || angle.endsWith(_RAD) || angle.endsWith(_TURN));
  }

  static double? parseAngle(String rawAngleValue) {
    if (_cachedParsedAngle.containsKey(rawAngleValue)) {
      return _cachedParsedAngle[rawAngleValue];
    }
    double? angleValue;
    if (rawAngleValue.endsWith(_DEG)) {
      angleValue = double.tryParse(rawAngleValue.split(_DEG)[0])! * 2 * math.pi / 360;
    } else if (rawAngleValue.endsWith(_GRAD)) {
      angleValue = double.tryParse(rawAngleValue.split(_GRAD)[0])! * 2 * math.pi / 400;
    } else if (rawAngleValue.endsWith(_RAD)) {
      angleValue = double.tryParse(rawAngleValue.split(_RAD)[0]);
    } else if (rawAngleValue.endsWith(_TURN)) {
      angleValue = double.tryParse(rawAngleValue.split(_TURN)[0])! * 2 * math.pi;
    }

    return _cachedParsedAngle[rawAngleValue] = angleValue;
  }
}
