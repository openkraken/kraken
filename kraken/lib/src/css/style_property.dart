import 'package:kraken/css.dart';

final RegExp _spaceRegExp = RegExp(r'\s+(?![^(]*\))');
final RegExp _commaRegExp = RegExp(r',(?![^\(]*\))');
const String _comma = ', ';
const String _0s = '0s';

class CSSStyleProperty {
  static void setShorthandPadding(Map<String, String> style, String shorthandValue) {
    if (shorthandValue != null) {
      List<String> values = CSSStyleProperty.getEdgeValues(shorthandValue);
      style[PADDING_TOP] = values[0];
      style[PADDING_RIGHT] = values[1];
      style[PADDING_BOTTOM] = values[2];
      style[PADDING_LEFT] = values[3];
    }
  }

  static void removeShorthandPadding(Map<String, String> style) {
    if (style.containsKey(PADDING_LEFT)) style.remove(PADDING_LEFT);
    if (style.containsKey(PADDING_TOP)) style.remove(PADDING_LEFT);
    if (style.containsKey(PADDING_RIGHT)) style.remove(PADDING_RIGHT);
    if (style.containsKey(PADDING_BOTTOM)) style.remove(PADDING_BOTTOM);
  }

  static void setShorthandMargin(Map<String, String> style, String shorthandValue) {
    if (shorthandValue != null) {
      List<String> values = CSSStyleProperty.getEdgeValues(shorthandValue);
      if (values != null) {
        style[MARGIN_TOP] = values[0];
        style[MARGIN_RIGHT] = values[1];
        style[MARGIN_BOTTOM] = values[2];
        style[MARGIN_LEFT] = values[3];
      }
    }
  }

  static void removeShorthandMargin(Map<String, String> style) {
    if (style.containsKey(MARGIN_LEFT)) style.remove(MARGIN_LEFT);
    if (style.containsKey(MARGIN_TOP)) style.remove(MARGIN_LEFT);
    if (style.containsKey(MARGIN_RIGHT)) style.remove(MARGIN_RIGHT);
    if (style.containsKey(MARGIN_BOTTOM)) style.remove(MARGIN_BOTTOM);
  }

  static void setShorthandTransition(Map<String, String> style, String shorthandValue) {
    if (shorthandValue != null) {
      List<String> values = CSSStyleProperty.getTransitionValues(shorthandValue);
      if (values != null) {
        style[TRANSITION_PROPERTY] = values[0];
        style[TRANSITION_DURATION] = values[1];
        style[TRANSITION_TIMING_FUNCTION] = values[2];
        style[TRANSITION_DELAY] = values[3];
      }
    }
  }

  static void removeShorthandTransition(Map<String, String> style) {
    if (style.containsKey(TRANSITION_PROPERTY)) style.remove(TRANSITION_PROPERTY);
    if (style.containsKey(TRANSITION_DURATION)) style.remove(TRANSITION_DURATION);
    if (style.containsKey(TRANSITION_TIMING_FUNCTION)) style.remove(TRANSITION_TIMING_FUNCTION);
    if (style.containsKey(TRANSITION_DELAY)) style.remove(TRANSITION_DELAY);
  }

  static void setShorthandBorder(Map<String, String> style, String property, String shorthandValue) {

    String borderTopColor;
    String borderRightColor;
    String borderBottomColor;
    String borderLeftColor;
    String borderTopStyle;
    String borderRightStyle;
    String borderBottomStyle;
    String borderLeftStyle;
    String borderTopWidth;
    String borderRightWidth;
    String borderBottomWidth;
    String borderLeftWidth;

    if (shorthandValue != null) {
      if (property == BORDER ||
        property == BORDER_TOP ||
        property == BORDER_RIGHT ||
        property == BORDER_BOTTOM ||
        property == BORDER_LEFT) {
        List<String> values = CSSStyleProperty._getBorderValues(shorthandValue);
        if (values == null) return;

        if (property == BORDER || property == BORDER_TOP) {
          borderTopWidth = values[0];
          borderTopStyle = values[1];
          borderTopColor = values[2];
        }
        if (property == BORDER || property == BORDER_RIGHT) {
          borderRightWidth = values[0];
          borderRightStyle = values[1];
          borderRightColor = values[2];
        }
        if (property == BORDER || property == BORDER_BOTTOM) {
          borderBottomWidth = values[0];
          borderBottomStyle = values[1];
          borderBottomColor = values[2];
        }
        if (property == BORDER || property == BORDER_LEFT) {
          borderLeftWidth = values[0];
          borderLeftStyle = values[1];
          borderLeftColor = values[2];
        }
      } else {
        
        List<String> values = CSSStyleProperty.getEdgeValues(shorthandValue);
        if (values == null) return;
        // @TODO validate value
        if (property == BORDER_WIDTH) {
          borderTopWidth = values[0];
          borderRightWidth = values[1];
          borderBottomWidth = values[2];
          borderLeftWidth = values[3];
        } else if (property == BORDER_STYLE) {
          borderTopStyle = values[0];
          borderRightStyle = values[1];
          borderBottomStyle = values[2];
          borderLeftStyle = values[3];
        } else if (property == BORDER_COLOR) {
          borderTopColor = values[0];
          borderRightColor = values[1];
          borderBottomColor = values[2];
          borderLeftColor = values[3];
        }
      }
    }

    if (borderTopColor != null) style[BORDER_TOP_COLOR] = borderTopColor;
    if (borderRightColor != null) style[BORDER_RIGHT_COLOR] = borderRightColor;
    if (borderBottomColor != null) style[BORDER_BOTTOM_COLOR] = borderBottomColor;
    if (borderLeftColor != null) style[BORDER_LEFT_COLOR] = borderLeftColor;
    if (borderTopStyle != null) style[BORDER_TOP_STYLE] = borderTopStyle;
    if (borderRightStyle != null) style[BORDER_RIGHT_STYLE] = borderRightStyle;
    if (borderBottomStyle != null) style[BORDER_BOTTOM_STYLE] = borderBottomStyle;
    if (borderLeftStyle != null) style[BORDER_LEFT_STYLE] = borderLeftStyle;
    if (borderTopWidth != null) style[BORDER_TOP_WIDTH] = borderTopWidth;
    if (borderRightWidth != null) style[BORDER_RIGHT_WIDTH] = borderRightWidth;
    if (borderBottomWidth != null) style[BORDER_BOTTOM_WIDTH] = borderBottomWidth;
    if (borderLeftWidth != null) style[BORDER_LEFT_WIDTH] = borderLeftWidth;
  }

  static void removeShorthandBorder(Map<String, String> style, String property) {
    if (style.containsKey(BORDER_WIDTH)) style.remove(BORDER_WIDTH);
    if (style.containsKey(BORDER_STYLE)) style.remove(BORDER_STYLE);
    if (style.containsKey(BORDER_COLOR)) style.remove(BORDER_COLOR);
  }

  // all, -moz-specific, sliding; => ['all', '-moz-specific', 'sliding']
  static List<String> getMultipleValues(String property) {
    assert(property != null);
    return property.split(_commaRegExp);
  }

  static List<List<String>> getShadowValues(String property) {
    assert(property != null);

    List shadows = property.split(_commaRegExp);
    List<List<String>> values = List();
    for (String shadow in shadows) {
      List<String> parts = shadow.trim().split(_spaceRegExp);

      String inset;
      String color;

      List<String> lengthValues = List(4);
      int i = 0;
      for (String part in parts) {
        if (part == INSET) {
          inset = part;
        } else if (CSSLength.isLength(part)) {
          lengthValues[i++] = part;
        } else if (color == null && CSSColor.isColor(part)){
          color = part;
        } else {
          return null;
        }
      }

      values.add([
        color,
        lengthValues[0], // offsetX
        lengthValues[1], // offsetY
        lengthValues[2], // blurRadius
        lengthValues[3], // spreadRadius
        inset
      ]);
    }

    return values;
  }

  static List<String> getTransitionValues(String shorthandProperty) {
    List transitions = shorthandProperty.split(_commaRegExp);
    List<String> values = List(4);

    for (String transition in transitions) {
      List<String> parts = transition.trim().split(_spaceRegExp);

      String property;
      String duration;
      String timingFuction;
      String delay;

      for (String part in parts) {
        if (property == null && CSSTransition.isValidTransitionPropertyValue(part)) {
          property = part;
        } else if (duration == null && CSSTime.isTime(part)) {
          duration = part;
        } else if (timingFuction == null && CSSTransition.isValidTransitionTimingFunctionValue(part)) {
          timingFuction = part;
        } else if (delay == null && CSSTime.isTime(delay)) {
          delay = part;
        } else {
          return null;
        }
      }

      property = property ?? ALL;
      duration = duration ?? _0s;
      timingFuction = timingFuction ?? EASE;
      delay = delay ?? _0s;

      values[0] == null ? values[0] = property : values[0] += (_comma + property);
      values[1] == null ? values[1] = duration : values[1] += (_comma + duration);
      values[2] == null ? values[2] = timingFuction : values[2] += (_comma + timingFuction);  
      values[3] == null ? values[3] = delay : values[3] += (_comma + delay);
    }
    
    return values;
  }

  static List<String> _getBorderValues(String shorthandProperty) {
    assert(shorthandProperty != null);
    var values = shorthandProperty.trim().split(_spaceRegExp);

    String width;
    String style;
    String color;

    // NOTE: if one of token is wrong like `1pxxx solid red` that all should not work
    for (String value in values) {
      if (width == null && CSSBorder.isValidBorderWidthValue(value)) {
        width = value;
      } else if (style == null && CSSBorder.isValidBorderStyleValue(value)) {
        style = value;
      } else if (color == null && CSSColor.isColor(value)) {
        color = value;
      } else {
        return null;
      }
    }

    return [width, style, color];
  }

  static List<String> getEdgeValues(String shorthandProperty) {
    assert(shorthandProperty != null);
    var properties = shorthandProperty.trim().split(_spaceRegExp);

    String topValue;
    String rightValue;
    String bottomValue;
    String leftValue;

    if (properties.length == 1) {
      topValue = rightValue = bottomValue = leftValue = properties[0];
    } else if (properties.length == 2) {
      topValue = bottomValue = properties[0];
      leftValue = rightValue = properties[1];
    } else if (properties.length == 3) {
      topValue = properties[0];
      rightValue = leftValue = properties[1];
      bottomValue = properties[2];
    } else if (properties.length == 4) {
      topValue = properties[0];
      rightValue = properties[1];
      bottomValue = properties[2];
      leftValue = properties[3];
    }

    // Assume the properties are in the usual order top, right, bottom, left.
    return [topValue, rightValue, bottomValue, leftValue];
  }

  // https://drafts.csswg.org/css-values-4/#typedef-position
  static List<String> getPositionValues(String shorthandProperty) {
    assert(shorthandProperty != null);
    var properties = shorthandProperty.trim().split(_spaceRegExp);

    String x;
    String y;
    if (properties.length == 1) {
      x = y = properties[0];
    } else if (properties.length == 2) {
      x = properties[0];
      y = properties[1];
    }

    return [x, y];
  }
}
