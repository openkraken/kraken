/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'dart:math' as math;
import 'value.dart';

// CSS Values and Units: https://drafts.csswg.org/css-values-3/#angles
class CSSAngle implements CSSValue<double> {
  static const String DEG = 'deg';
  static const String GRAD = 'grad';
  static const String RAD = 'rad';
  static const String TURN = 'turn';

  /// Judge a string is an angle.
  static bool isAngle(String angle) {
    return angle != null &&
        (angle.endsWith(DEG) || angle.endsWith(GRAD) || angle.endsWith(RAD) || angle.endsWith(TURN));
  }

  String angleType = DEG;
  double angleValue = 0.0;
  final String rawAngleValue;

  CSSAngle(this.rawAngleValue) {
    parse();
  }

  bool _parsed = false;
  @override
  void parse() {
    if (_parsed) return;
    if (rawAngleValue != null) {
      if (rawAngleValue.endsWith(DEG)) {
        angleType = DEG;
        angleValue = double.parse(rawAngleValue.split(angleType)[0]) * 2 * math.pi / 360;
      } else if (rawAngleValue.endsWith(GRAD)) {
        angleType = GRAD;
        angleValue = double.parse(rawAngleValue.split(angleType)[0]) * 2 * math.pi / 400;
      } else if (rawAngleValue.endsWith(RAD)) {
        angleType = RAD;
        angleValue = double.parse(rawAngleValue.split(angleType)[0]);
      } else if (rawAngleValue.endsWith(TURN)) {
        angleType = TURN;
        angleValue = double.parse(rawAngleValue.split(angleType)[0]) * 2 * math.pi;
      }
    }
    _parsed = true;
  }

  @override
  double get computedValue {
    parse();
    switch (angleType) {
      case DEG:
        return angleValue;
      case GRAD:
        return angleValue * 0.9;
      case RAD:
        return angleValue * 45 / math.pi;
      case TURN:
        return angleValue * 360;
      default:
        return null;
    }
  }

  /// The <number> component serialized as per <number> followed by the
  /// unit in canonical form as defined in its respective specification.
  @override
  String get serializedValue {
    parse();
    return '$angleValue$angleType';
  }
}
