// @dart=2.9

/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'dart:math' as math;

// CSS Values and Units: https://drafts.csswg.org/css-values-3/#angles
class CSSAngle {
  static const String DEG = 'deg';
  static const String GRAD = 'grad';
  static const String RAD = 'rad';
  static const String TURN = 'turn';

  /// Judge a string is an angle.
  static bool isAngle(String angle) {
    return angle != null &&
        (angle.endsWith(DEG) || angle.endsWith(GRAD) || angle.endsWith(RAD) || angle.endsWith(TURN));
  }

  static double parseAngle(String rawAngleValue) {
    double angleValue;
    if (rawAngleValue != null) {
      if (rawAngleValue.endsWith(DEG)) {
        angleValue = double.tryParse(rawAngleValue.split(DEG)[0]) * 2 * math.pi / 360;
      } else if (rawAngleValue.endsWith(GRAD)) {
        angleValue = double.tryParse(rawAngleValue.split(GRAD)[0]) * 2 * math.pi / 400;
      } else if (rawAngleValue.endsWith(RAD)) {
        angleValue = double.tryParse(rawAngleValue.split(RAD)[0]);
      } else if (rawAngleValue.endsWith(TURN)) {
        angleValue = double.tryParse(rawAngleValue.split(TURN)[0]) * 2 * math.pi;
      }
    }
    return angleValue;
  }
}
