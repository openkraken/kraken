/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'dart:math' as math;

class Angle {
  static const String DEG = 'deg';
  static const String GRAD = 'grad';
  static const String RAD = 'rad';
  static const String TURN = 'turn';

  String angleType = DEG;
  double angleValue = 0.0;

  Angle(String angleValue) {
    if (angleValue != null) {
      if (angleValue.endsWith(DEG)) {
        angleType = DEG;
        this.angleValue =
            double.parse(angleValue.split(angleType)[0]) * 2 * math.pi / 360;
      } else if (angleValue.endsWith(GRAD)) {
        angleType = GRAD;
        this.angleValue =
            double.parse(angleValue.split(angleType)[0]) * 2 * math.pi / 400;
      } else if (angleValue.endsWith(RAD)) {
        angleType = RAD;
        this.angleValue = double.parse(angleValue.split(angleType)[0]);
      } else if (angleValue.endsWith(TURN)) {
        angleType = TURN;
        this.angleValue =
            double.parse(angleValue.split(angleType)[0]) * 2 * math.pi;
      }
    }
  }

  static bool isAngle(String angle) {
    return angle != null &&
        (angle.endsWith(DEG) ||
            angle.endsWith(GRAD) ||
            angle.endsWith(RAD) ||
            angle.endsWith(TURN));
  }
}
