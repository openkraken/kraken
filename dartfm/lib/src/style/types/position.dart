import 'package:flutter/cupertino.dart';
import 'length.dart';

class Position {
  static const String LEFT = 'left';
  static const String RIGHT = 'right';
  static const String CENTER = 'center';
  static const String TOP = 'top';
  static const String BOTTOM = 'bottom';
  Alignment alignment = Alignment.topLeft;
  Size size;

  Position(String position, Size size) {
    if (position == null) {
      return;
    }
    this.size = size;
    List<String> items = position.split(" ");
    if (items.length == 1) {
      alignment = Alignment(getValue(items[0], true), 0.0);
    } else if (items.length == 2) {
      alignment =
          Alignment(getValue(items[0], true), getValue(items[1], false));
    } else if (items.length == 3) {
      String first = items[0];
      String second = items[1];
      String third = items[2];
      double dx;
      double dy;
      if (first == LEFT || first == RIGHT) {
        if (second == TOP) {
          dx = -1.0;
          dy = getLengthValue(third, false);
        } else if (second == BOTTOM) {
          dx = -1.0;
          dy = -getLengthValue(third, false);
        } else if (third == TOP) {
          dx = getLengthValue(second, true);
          dy = -1.0;
        } else if (third == BOTTOM) {
          dx = getLengthValue(second, true);
          dy = 1.0;
        } else if (third == CENTER) {
          dx = getLengthValue(second, true);
          dy = 0.0;
        } else {
          ///error arguments
          return;
        }
        if (first == RIGHT) {
          dx = -dx;
        }
      } else if (first == TOP || first == BOTTOM) {
        if (second == LEFT) {
          dx = getLengthValue(third, true);
          dy = -1.0;
        } else if (second == RIGHT) {
          dx = -getLengthValue(third, true);
          dy = -1.0;
        } else if (third == LEFT) {
          dy = getLengthValue(second, false);
          dx = -1.0;
        } else if (third == RIGHT) {
          dy = getLengthValue(second, false);
          dx = 1.0;
        } else if (third == CENTER) {
          dy = getLengthValue(second, false);
          dx = 0.0;
        } else {
          /// error arguments
          return;
        }
        if (first == BOTTOM) {
          dy = -dy;
        }
      } else if (first == CENTER) {
        if (second == LEFT) {
          dx = getLengthValue(third, true);
          dy = 0.0;
        } else if (second == RIGHT) {
          dx = -getLengthValue(third, true);
          dy = 0.0;
        } else if (second == TOP) {
          dy = getLengthValue(third, false);
          dx = 0.0;
        } else if (second == BOTTOM) {
          dy = -getLengthValue(third, false);
          dx = 0.0;
        } else {
          /// error arguments
          return;
        }
      } else {
        /// error arguments
        return;
      }
      alignment = Alignment(dx, dy);
    } else if (items.length == 4) {
      String first = items[0];
      String second = items[1];
      String third = items[2];
      String fourth = items[3];
      double dx;
      double dy;
      if (first == LEFT || first == RIGHT) {
        dx = getLengthValue(second, true);
        if (third == TOP) {
          dy = getLengthValue(fourth, false);
        } else if (third == BOTTOM) {
          dy = -getLengthValue(fourth, false);
        } else {
          ///error arguments
          return;
        }
        if (first == RIGHT) {
          dx = -dx;
        }
      } else if (first == TOP || first == BOTTOM) {
        dy = getLengthValue(second, false);
        if (third == LEFT) {
          dx = getLengthValue(fourth, true);
        } else if (third == RIGHT) {
          dx = -getLengthValue(fourth, true);
        } else {
          /// error arguments
          return;
        }
        if (first == BOTTOM) {
          dy = -dy;
        }
      } else {
        /// error arguments
        return;
      }
      alignment = Alignment(dx, dy);
    }
  }

  double getValue(String value, bool isHorizontal) {
    if (isHorizontal) {
      switch (value) {
        case RIGHT:
          return 1.0;
        case LEFT:
          return -1.0;
      }
    } else {
      switch (value) {
        case BOTTOM:
          return 1.0;
        case TOP:
          return -1.0;
      }
    }
    if (value == CENTER) {
      return 0.0;
    }
    return getLengthValue(value, isHorizontal);
  }

  double getLengthValue(String value, bool isHorizontal) {
    if (value.endsWith('%')) {
      double currentValue = double.parse(value.split('%')[0]);
      return (currentValue - 50) / 50;
    }
    double dividend = isHorizontal ? size.width : size.height;
    return -Length.toDisplayPortValue(value) / dividend;
  }
}
