import 'package:kraken/css.dart';

final RegExp _spaceRegExp = RegExp(r'\s+(?![^(]*\))');
final RegExp _commaRegExp = RegExp(r',(?![^\(]*\))');
final RegExp _slashRegExp = RegExp(r'\/(?![^(]*\))');
final RegExp _replaceCommaRegExp = RegExp(r'\s*,\s*');
const String _comma = ', ';
const String _0s = '0s';
const String _0 = '0';
const String _1 = '1';

// Origin version: https://github.com/jedmao/css-list-helpers/blob/master/src/index.ts
List<String> _splitBySpace(String value) {
  List<String> array = List();
  String current = '';
  int func = 0;
  String quote;
  bool splitMe = false;
  bool escape = false;

  for (int i = 0; i < value.length; i++) {
    String char = value[i];

    if (quote != null) {
      if (escape) {
        escape = false;
      } else if (char == '\\') {
        escape = true;
      } else if (char == quote) {
        quote = null;
      }
    } else if (char == '"' || char == '\'') {
      quote = char;
    } else if (char == '(') {
      func += 1;
    } else if (char == ')') {
      if (func > 0) {
        func -= 1;
      }
    } else if (func == 0) {
      if (char == ' ') {
        splitMe = true;
      }
    }

    if (splitMe) {
      if (current != '') {
        array.add(current.trim());
      }
      current = '';
      splitMe = false;
    } else {
      current += char;
    }
  }

  if (current != '') {
    array.add(current.trim());
  }
  return array;
}

class CSSStyleProperty {
  static void setShorthandPadding(Map<String, String> style, String shorthandValue) {
    List<String> values = _getEdgeValues(shorthandValue);
    if (values == null) return;

    style[PADDING_TOP] = values[0];
    style[PADDING_RIGHT] = values[1];
    style[PADDING_BOTTOM] = values[2];
    style[PADDING_LEFT] = values[3];
  }

  static void removeShorthandPadding(Map<String, String> style) {
    if (style.containsKey(PADDING_LEFT)) style.remove(PADDING_LEFT);
    if (style.containsKey(PADDING_TOP)) style.remove(PADDING_LEFT);
    if (style.containsKey(PADDING_RIGHT)) style.remove(PADDING_RIGHT);
    if (style.containsKey(PADDING_BOTTOM)) style.remove(PADDING_BOTTOM);
  }

  static void setShorthandMargin(Map<String, String> style, String shorthandValue) {
    List<String> values = _getEdgeValues(shorthandValue, isLength: false);
    if (values == null) return;

    style[MARGIN_TOP] = values[0];
    style[MARGIN_RIGHT] = values[1];
    style[MARGIN_BOTTOM] = values[2];
    style[MARGIN_LEFT] = values[3];
  }

  static void removeShorthandMargin(Map<String, String> style) {
    if (style.containsKey(MARGIN_LEFT)) style.remove(MARGIN_LEFT);
    if (style.containsKey(MARGIN_TOP)) style.remove(MARGIN_LEFT);
    if (style.containsKey(MARGIN_RIGHT)) style.remove(MARGIN_RIGHT);
    if (style.containsKey(MARGIN_BOTTOM)) style.remove(MARGIN_BOTTOM);
  }

  static void setShorthandBackground(Map<String, String> style, String shorthandValue) {
    List<String> values = _getBackgroundValues(shorthandValue);
    if (values == null) return;

    style[BACKGROUND_COLOR] = values[0];
    style[BACKGROUND_IMAGE] = values[1];
    style[BACKGROUND_REPEAT] = values[2];
    style[BACKGROUND_ATTACHMENT] = values[3];
    style[BACKGROUND_POSITION] = values[4];
    style[BACKGROUND_SIZE] = values[5];
  }

  static void removeShorthandBackground(Map<String, String> style) {
    if (style.containsKey(BACKGROUND_ATTACHMENT)) style.remove(BACKGROUND_ATTACHMENT);
    if (style.containsKey(BACKGROUND_COLOR)) style.remove(BACKGROUND_COLOR);
    if (style.containsKey(BACKGROUND_IMAGE)) style.remove(BACKGROUND_IMAGE);
    if (style.containsKey(BACKGROUND_POSITION)) style.remove(BACKGROUND_POSITION);
    if (style.containsKey(BACKGROUND_SIZE)) style.remove(BACKGROUND_SIZE);
    if (style.containsKey(BACKGROUND_REPEAT)) style.remove(BACKGROUND_REPEAT);
  }

  static void setShorthandBorderRadius(Map<String, String> style, String shorthandValue) {
    List<String> values = _getBorderRaidusValues(shorthandValue);
    if (values == null) return;

    style[BORDER_TOP_LEFT_RADIUS] = values[0];
    style[BORDER_TOP_RIGHT_RADIUS] = values[1];
    style[BORDER_BOTTOM_RIGHT_RADIUS] = values[2];
    style[BORDER_BOTTOM_LEFT_RADIUS] = values[3];
  }

  static void removeShorthandBorderRadius(Map<String, String> style) {
    if (style.containsKey(BORDER_TOP_LEFT_RADIUS)) style.remove(BORDER_TOP_LEFT_RADIUS);
    if (style.containsKey(BORDER_TOP_RIGHT_RADIUS)) style.remove(BORDER_TOP_RIGHT_RADIUS);
    if (style.containsKey(BORDER_BOTTOM_RIGHT_RADIUS)) style.remove(BORDER_BOTTOM_RIGHT_RADIUS);
    if (style.containsKey(BORDER_BOTTOM_LEFT_RADIUS)) style.remove(BORDER_BOTTOM_LEFT_RADIUS);
  }

  static void setShorthandOverflow(Map<String, String> style, String shorthandValue) {
    List<String> values = shorthandValue.split(_spaceRegExp);
    if (values.length == 1) {
      style[OVERFLOW_Y] = style[OVERFLOW_X] = values[0];
    } else if (values.length == 2) {
      style[OVERFLOW_X] = values[0];
      style[OVERFLOW_Y] = values[1];
    }
  }

  static void removeShorthandOverflow(Map<String, String> style) {
    if (style.containsKey(OVERFLOW_X)) style.remove(OVERFLOW_X);
    if (style.containsKey(OVERFLOW_Y)) style.remove(OVERFLOW_Y);
  }

  static void setShorthandFont(Map<String, String> style, String shorthandValue) {
    List<String> values = _getFontValues(shorthandValue);
    if (values == null) return;
    style[FONT_STYLE] = values[0];
    style[FONT_WEIGHT] = values[1];
    style[FONT_SIZE] = values[2];
    style[LINE_HEIGHT] = values[3];
    style[FONT_FAMILY] = values[4];
  }

  static void removeShorthandFont(Map<String, String> style) {
    if (style.containsKey(FONT_STYLE)) style.remove(FONT_STYLE);
    if (style.containsKey(FONT_WEIGHT)) style.remove(FONT_WEIGHT);
    if (style.containsKey(FONT_SIZE)) style.remove(FONT_SIZE);
    if (style.containsKey(LINE_HEIGHT)) style.remove(LINE_HEIGHT);
    if (style.containsKey(FONT_FAMILY)) style.remove(FONT_FAMILY);
  }

  static void setShorthandFlex(Map<String, String> style, String shorthandValue) {
    List<String> values = _getFlexValues(shorthandValue);
    if (values == null) return;
    style[FLEX_GROW] = values[0];
    style[FLEX_SHRINK] = values[1];
    style[FLEX_BASIS] = values[2];
  }

  static void removeShorthandFlex(Map<String, String> style) {
    if (style.containsKey(FLEX_GROW)) style.remove(FLEX_GROW);
    if (style.containsKey(FLEX_SHRINK)) style.remove(FLEX_SHRINK);
    if (style.containsKey(FLEX_BASIS)) style.remove(FLEX_BASIS);
  }

  static void setShorthandFlexFlow(Map<String, String> style, String shorthandValue) {
    List<String> values = _getFlexFlowValues(shorthandValue);
    if (values == null) return;
    style[FLEX_DIRECTION] = values[0];
    style[FLEX_WRAP] = values[1];
  }

  static void removeShorthandFlexFlow(Map<String, String> style) {
    if (style.containsKey(FLEX_DIRECTION)) style.remove(FLEX_DIRECTION);
    if (style.containsKey(FLEX_WRAP)) style.remove(FLEX_WRAP);
  }

  static void setShorthandTransition(Map<String, String> style, String shorthandValue) {
    List<String> values = _getTransitionValues(shorthandValue);
    if (values == null) return;

    style[TRANSITION_PROPERTY] = values[0];
    style[TRANSITION_DURATION] = values[1];
    style[TRANSITION_TIMING_FUNCTION] = values[2];
    style[TRANSITION_DELAY] = values[3];
  }

  static void removeShorthandTransition(Map<String, String> style) {
    if (style.containsKey(TRANSITION_PROPERTY)) style.remove(TRANSITION_PROPERTY);
    if (style.containsKey(TRANSITION_DURATION)) style.remove(TRANSITION_DURATION);
    if (style.containsKey(TRANSITION_TIMING_FUNCTION)) style.remove(TRANSITION_TIMING_FUNCTION);
    if (style.containsKey(TRANSITION_DELAY)) style.remove(TRANSITION_DELAY);
  }

  static void setShorthandTextDecoration(Map<String, String> style, String shorthandValue) {
    List<String> values = _getTextDecorationValues(shorthandValue);
    if (values == null) return;

    style[TEXT_DECORATION_LINE] = values[0];
    style[TEXT_DECORATION_COLOR] = values[1];
    style[TEXT_DECORATION_STYLE] = values[2];
  }

  static void removeShorthandTextDecoration(Map<String, String> style) {
    if (style.containsKey(TEXT_DECORATION_LINE)) style.remove(TEXT_DECORATION_LINE);
    if (style.containsKey(TEXT_DECORATION_COLOR)) style.remove(TEXT_DECORATION_COLOR);
    if (style.containsKey(TEXT_DECORATION_STYLE)) style.remove(TEXT_DECORATION_STYLE);
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
    } else if (property == BORDER_WIDTH) {
      List<String> values = _getEdgeValues(shorthandValue);
      if (values == null) return;

      borderTopWidth = values[0];
      borderRightWidth = values[1];
      borderBottomWidth = values[2];
      borderLeftWidth = values[3];
    } else if (property == BORDER_STYLE) {
      // @TODO: validate value
      List<String> values = _getEdgeValues(shorthandValue, isLength: false);
      if (values == null) return;

      borderTopStyle = values[0];
      borderRightStyle = values[1];
      borderBottomStyle = values[2];
      borderLeftStyle = values[3];
    } else if (property == BORDER_COLOR) {
      // @TODO: validate value
      List<String> values = _getEdgeValues(shorthandValue, isLength: false);
      if (values == null) return;

      borderTopColor = values[0];
      borderRightColor = values[1];
      borderBottomColor = values[2];
      borderLeftColor = values[3];
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
    if (property == BORDER ||
        property == BORDER_TOP ||
        property == BORDER_RIGHT ||
        property == BORDER_BOTTOM ||
        property == BORDER_LEFT) {
      if (property == BORDER || property == BORDER_TOP) {
        if (style.containsKey(BORDER_TOP_COLOR)) style.remove(BORDER_TOP_COLOR);
        if (style.containsKey(BORDER_TOP_STYLE)) style.remove(BORDER_TOP_STYLE);
        if (style.containsKey(BORDER_TOP_WIDTH)) style.remove(BORDER_TOP_WIDTH);
      }
      if (property == BORDER || property == BORDER_RIGHT) {
        if (style.containsKey(BORDER_RIGHT_COLOR)) style.remove(BORDER_RIGHT_COLOR);
        if (style.containsKey(BORDER_RIGHT_STYLE)) style.remove(BORDER_RIGHT_STYLE);
        if (style.containsKey(BORDER_RIGHT_WIDTH)) style.remove(BORDER_RIGHT_WIDTH);
      }
      if (property == BORDER || property == BORDER_BOTTOM) {
        if (style.containsKey(BORDER_BOTTOM_COLOR)) style.remove(BORDER_BOTTOM_COLOR);
        if (style.containsKey(BORDER_BOTTOM_STYLE)) style.remove(BORDER_BOTTOM_STYLE);
        if (style.containsKey(BORDER_BOTTOM_WIDTH)) style.remove(BORDER_BOTTOM_WIDTH);
      }
      if (property == BORDER || property == BORDER_LEFT) {
        if (style.containsKey(BORDER_LEFT_COLOR)) style.remove(BORDER_LEFT_COLOR);
        if (style.containsKey(BORDER_LEFT_STYLE)) style.remove(BORDER_LEFT_STYLE);
        if (style.containsKey(BORDER_LEFT_WIDTH)) style.remove(BORDER_LEFT_WIDTH);
      }
    } else {
      if (property == BORDER_WIDTH) {
        if (style.containsKey(BORDER_TOP_WIDTH)) style.remove(BORDER_TOP_WIDTH);
        if (style.containsKey(BORDER_RIGHT_WIDTH)) style.remove(BORDER_RIGHT_WIDTH);
        if (style.containsKey(BORDER_BOTTOM_WIDTH)) style.remove(BORDER_BOTTOM_WIDTH);
        if (style.containsKey(BORDER_LEFT_WIDTH)) style.remove(BORDER_LEFT_WIDTH);
      } else if (property == BORDER_STYLE) {
        if (style.containsKey(BORDER_TOP_STYLE)) style.remove(BORDER_TOP_STYLE);
        if (style.containsKey(BORDER_RIGHT_STYLE)) style.remove(BORDER_RIGHT_STYLE);
        if (style.containsKey(BORDER_BOTTOM_STYLE)) style.remove(BORDER_BOTTOM_STYLE);
        if (style.containsKey(BORDER_LEFT_STYLE)) style.remove(BORDER_LEFT_STYLE);
      } else if (property == BORDER_COLOR) {
        if (style.containsKey(BORDER_TOP_COLOR)) style.remove(BORDER_TOP_COLOR);
        if (style.containsKey(BORDER_RIGHT_COLOR)) style.remove(BORDER_RIGHT_COLOR);
        if (style.containsKey(BORDER_BOTTOM_COLOR)) style.remove(BORDER_BOTTOM_COLOR);
        if (style.containsKey(BORDER_LEFT_COLOR)) style.remove(BORDER_LEFT_COLOR);
      }
    }
  }

  // all, -moz-specific, sliding; => ['all', '-moz-specific', 'sliding']
  static List<String> getMultipleValues(String property) {
    if (property.isEmpty) return null;
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
        } else if (color == null && CSSColor.isColor(part)) {
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

  static List<String> _getBorderRaidusValues(String shorthandProperty) {
    if (!shorthandProperty.contains('/')) {
      return _getEdgeValues(shorthandProperty);
    }

    List radius = shorthandProperty.split(_slashRegExp);
    if (radius.length != 2) {
      return null;
    }

    // border-radius: 10px 20px / 20px 25px 30px 35px;
    // =>
    // order-top-left-radius: 10px 20px;
    // border-top-right-radius: 20px 25px;
    // border-bottom-right-radius: 10px 30px;
    // border-bottom-left-radius: 20px 35px;
    String firstRadius = radius[0];
    String secondRadius = radius[1];

    List<String> firstValues = _getEdgeValues(firstRadius);
    List<String> secondValues = _getEdgeValues(secondRadius);

    return [
      '${firstValues[0]} ${secondValues[0]}',
      '${firstValues[1]} ${secondValues[1]}',
      '${firstValues[2]} ${secondValues[2]}',
      '${firstValues[3]} ${secondValues[3]}'
    ];
  }

  // Current not support multiple background layer:
  static List<String> _getBackgroundValues(String shorthandProperty) {
    // Convert 40%/10em -> 40% / 10em
    shorthandProperty = shorthandProperty.replaceAll(_slashRegExp, ' / ');
    List values = shorthandProperty.split(_spaceRegExp);

    String color;
    String image;
    String repeat;
    String attachment;
    String positionX;
    String positionY;
    String sizeWidth;
    String sizeHeight;

    String position;
    String size;
    bool isPositionEndAndSizeStart = false;

    for (String value in values) {
      if (color == null && CSSColor.isColor(value)) {
        color = value;
      } else if (image == null && CSSBackground.isValidBackgroundImageValue(value)) {
        image = value;
      } else if (repeat == null && CSSBackground.isValidBackgroundRepeatValue(value)) {
        repeat = value;
      } else if (attachment == null && CSSBackground.isValidBackgroundAttachmentValue(value)) {
        attachment = value;
      } else if (positionX == null &&
          !isPositionEndAndSizeStart &&
          CSSBackground.isValidBackgroundPositionValue(value)) {
        positionX = value;
      } else if (positionY == null &&
          !isPositionEndAndSizeStart &&
          CSSBackground.isValidBackgroundPositionValue(value)) {
        positionY = value;
      } else if (value == '/') {
        isPositionEndAndSizeStart = true;
        continue;
      } else if (sizeWidth == null && CSSBackground.isValidBackgroundSizeValue(value)) {
        sizeWidth = value;
      } else if (sizeHeight == null && CSSBackground.isValidBackgroundSizeValue(value)) {
        sizeHeight = value;
      } else {
        return null;
      }
    }

    // Before `/` must have one position value, after `/` must have on size value
    if (isPositionEndAndSizeStart &&
        ((positionX == null && positionY == null) || (sizeWidth == null && sizeHeight == null))) {
      return null;
    }

    if (positionX != null) {
      position = positionX;
    }

    if (positionY != null) {
      position += (' ' + positionY);
    }

    if (sizeWidth != null) {
      size = sizeWidth;
    }

    if (sizeHeight != null) {
      size += (' ' + sizeHeight);
    }

    return [color, image, repeat, attachment, position, size];
  }

  static List<String> _getFontValues(String shorthandProperty) {
    // Convert 40%/10em => 40% / 10em
    shorthandProperty = shorthandProperty.replaceAll(_slashRegExp, ' / ');
    // Convert "Goudy Bookletter 1911", sans-serif => "Goudy Bookletter 1911",sans-serif
    shorthandProperty = shorthandProperty.replaceAll(_replaceCommaRegExp, ',');
    List values = _splitBySpace(shorthandProperty);

    String style;
    String weight;
    String size;
    String lineHeight;
    String family;

    bool isSizeEndAndLineHeightStart = false;

    for (String value in values) {
      if (style == null && CSSText.isValidFontStyleValue(value)) {
        style = value;
      } else if (weight == null && CSSText.isValidFontWeightValue(value)) {
        weight = value;
      } else if (size == null && CSSLength.isLength(value)) {
        size = value;
      } else if (value == '/') {
        isSizeEndAndLineHeightStart = true;
        continue;
      } else if (lineHeight == null && CSSText.isValidLineHeightValue(value)) {
        lineHeight = value;
      } else if (family == null) {
        // The font-family must be the last value specified.
        // Like `font: 12px` is invalid property value.
        family = value;
      } else {
        return null;
      }
    }

    if ((isSizeEndAndLineHeightStart && (size == null || lineHeight == null)) || family == null) {
      return null;
    }

    return [style, weight, size, lineHeight, family];
  }

  static List<String> _getTextDecorationValues(String shorthandProperty) {
    List<String> values = shorthandProperty.split(_spaceRegExp);
    String line;
    String color;
    String style;

    for (String value in values) {
      if (line == null && CSSText.isValidTextTextDecorationLineValue(value)) {
        line = value;
      } else if (color == null && CSSColor.isColor(value)) {
        color = value;
      } else if (style == null && CSSText.isValidTextTextDecorationStyleValue(value)) {
        style = value;
      } else {
        return null;
      }
    }

    return [line, color, style];
  }

  static List<String> _getTransitionValues(String shorthandProperty) {
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

  static List<String> _getFlexFlowValues(String shorthandProperty) {
    List<String> values = shorthandProperty.split(_spaceRegExp);

    String direction;
    String wrap;

    for (String value in values) {
      if (direction == null && CSSFlex.isValidFlexDirectionValue(value)) {
        direction = value;
      } else if (wrap == null && CSSFlex.isValidFlexWrapValue(value)) {
        wrap = value;
      } else {
        return null;
      }
    }

    return [direction, wrap];
  }

  static List<String> _getFlexValues(String shorthandProperty) {
    List<String> values = shorthandProperty.split(_spaceRegExp);

    // In flex shorthand case it is interpreted as flex: <number> 1 0;
    String grow;
    String shrink;
    String basis;

    for (String value in values) {
      if (values.length == 1) {
        if (value == INITIAL) {
          grow = _0;
          shrink = _1;
          basis = AUTO;
          break;
        } else if (value == AUTO) {
          grow = _1;
          shrink = _1;
          basis = AUTO;
          break;
        } else if (value == NONE) {
          grow = _0;
          shrink = _0;
          basis = AUTO;
          break;
        }
      }

      if (grow == null && CSSNumber.isNumber(value)) {
        grow = value;
      } else if (shrink == null && CSSNumber.isNumber(value)) {
        shrink = value;
      } else if (basis == null && ((CSSLength.isLength(value) || value == AUTO))) {
        basis = value;
      } else {
        return null;
      }
    }

    return [grow ?? _1, shrink ?? _1, basis ?? _0];
  }

  static List<String> _getBorderValues(String shorthandProperty) {
    List<String> values = shorthandProperty.split(_spaceRegExp);

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

  static List<String> _getEdgeValues(String shorthandProperty, {bool isLength = true}) {
    var properties = shorthandProperty.split(_spaceRegExp);

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

    if (isLength) {
      if (!CSSLength.isLength(topValue) ||
          !CSSLength.isLength(rightValue) ||
          !CSSLength.isLength(bottomValue) ||
          !CSSLength.isLength(leftValue)) {
        return null;
      }
    }

    // Assume the properties are in the usual order top, right, bottom, left.
    return [topValue, rightValue, bottomValue, leftValue];
  }

  // https://drafts.csswg.org/css-values-4/#typedef-position
  static List<String> getPositionValues(String shorthandProperty) {
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
