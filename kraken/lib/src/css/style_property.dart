/*
 * Copyright (C) 2021-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

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
  List<String> array = List.empty(growable: true);
  String current = '';
  int func = 0;
  String? quote;
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
  static void setShorthandPadding(Map<String, String?> properties, String shorthandValue) {
    List<String?>? values = _getEdgeValues(shorthandValue, isNonNegativeLengthOrPercentage: true);
    if (values == null) return;

    properties[PADDING_TOP] = values[0];
    properties[PADDING_RIGHT] = values[1];
    properties[PADDING_BOTTOM] = values[2];
    properties[PADDING_LEFT] = values[3];
  }

  static void removeShorthandPadding(CSSStyleDeclaration style, [bool? isImportant]) {
    if (style.contains(PADDING_LEFT)) style.removeProperty(PADDING_LEFT, isImportant);
    if (style.contains(PADDING_TOP)) style.removeProperty(PADDING_TOP, isImportant);
    if (style.contains(PADDING_RIGHT)) style.removeProperty(PADDING_RIGHT, isImportant);
    if (style.contains(PADDING_BOTTOM)) style.removeProperty(PADDING_BOTTOM, isImportant);
  }

  static void setShorthandMargin(Map<String, String?> properties, String shorthandValue) {
    List<String?>? values = _getEdgeValues(shorthandValue);
    if (values == null) return;

    properties[MARGIN_TOP] = values[0];
    properties[MARGIN_RIGHT] = values[1];
    properties[MARGIN_BOTTOM] = values[2];
    properties[MARGIN_LEFT] = values[3];
  }

  static void removeShorthandMargin(CSSStyleDeclaration style, [bool? isImportant]) {
    if (style.contains(MARGIN_LEFT)) style.removeProperty(MARGIN_LEFT, isImportant);
    if (style.contains(MARGIN_TOP)) style.removeProperty(MARGIN_TOP, isImportant);
    if (style.contains(MARGIN_RIGHT)) style.removeProperty(MARGIN_RIGHT, isImportant);
    if (style.contains(MARGIN_BOTTOM)) style.removeProperty(MARGIN_BOTTOM, isImportant);
  }

  static void setShorthandBackground(Map<String, String?> properties, String shorthandValue) {
    List<String?>? values = _getBackgroundValues(shorthandValue);
    if (values == null) return;

    properties[BACKGROUND_COLOR] = values[0];
    properties[BACKGROUND_IMAGE] = values[1];
    properties[BACKGROUND_REPEAT] = values[2];
    properties[BACKGROUND_ATTACHMENT] = values[3];
    String? backgroundPosition = values[4];
    if (backgroundPosition != null) {
      List<String> positions = CSSPosition.parsePositionShorthand(backgroundPosition);
      properties[BACKGROUND_POSITION_X] = positions[0];
      properties[BACKGROUND_POSITION_Y] = positions[1];
    }
    properties[BACKGROUND_SIZE] = values[5];
  }

  static void removeShorthandBackground(CSSStyleDeclaration style, [bool? isImportant]) {
    if (style.contains(BACKGROUND_ATTACHMENT)) style.removeProperty(BACKGROUND_ATTACHMENT, isImportant);
    if (style.contains(BACKGROUND_COLOR)) style.removeProperty(BACKGROUND_COLOR, isImportant);
    if (style.contains(BACKGROUND_IMAGE)) style.removeProperty(BACKGROUND_IMAGE, isImportant);
    if (style.contains(BACKGROUND_POSITION)) style.removeProperty(BACKGROUND_POSITION, isImportant);
    if (style.contains(BACKGROUND_SIZE)) style.removeProperty(BACKGROUND_SIZE, isImportant);
    if (style.contains(BACKGROUND_REPEAT)) style.removeProperty(BACKGROUND_REPEAT, isImportant);
  }

  static void setShorthandBackgroundPosition(Map<String, String?> properties, String shorthandValue) {
    List<String> positions = CSSPosition.parsePositionShorthand(shorthandValue);
    properties[BACKGROUND_POSITION_X] = positions[0];
    properties[BACKGROUND_POSITION_Y] = positions[1];
  }

  static void removeShorthandBackgroundPosition(CSSStyleDeclaration style, [bool? isImportant]) {
    if (style.contains(BACKGROUND_POSITION_X)) style.removeProperty(BACKGROUND_POSITION_X, isImportant);
    if (style.contains(BACKGROUND_POSITION_Y)) style.removeProperty(BACKGROUND_POSITION_Y, isImportant);
  }

  static void setShorthandBorderRadius(Map<String, String?> properties, String shorthandValue) {
    List<String?>? values = _getBorderRaidusValues(shorthandValue);

    if (values == null) return;

    properties[BORDER_TOP_LEFT_RADIUS] = values[0];
    properties[BORDER_TOP_RIGHT_RADIUS] = values[1];
    properties[BORDER_BOTTOM_RIGHT_RADIUS] = values[2];
    properties[BORDER_BOTTOM_LEFT_RADIUS] = values[3];
  }

  static void removeShorthandBorderRadius(CSSStyleDeclaration style, [bool? isImportant]) {
    if (style.contains(BORDER_TOP_LEFT_RADIUS)) style.removeProperty(BORDER_TOP_LEFT_RADIUS, isImportant);
    if (style.contains(BORDER_TOP_RIGHT_RADIUS)) style.removeProperty(BORDER_TOP_RIGHT_RADIUS, isImportant);
    if (style.contains(BORDER_BOTTOM_RIGHT_RADIUS)) style.removeProperty(BORDER_BOTTOM_RIGHT_RADIUS, isImportant);
    if (style.contains(BORDER_BOTTOM_LEFT_RADIUS)) style.removeProperty(BORDER_BOTTOM_LEFT_RADIUS, isImportant);
  }

  static void setShorthandOverflow(Map<String, String?> properties, String shorthandValue) {
    List<String> values = shorthandValue.split(_spaceRegExp);
    if (values.length == 1) {
      properties[OVERFLOW_Y] = properties[OVERFLOW_X] = values[0];
    } else if (values.length == 2) {
      properties[OVERFLOW_X] = values[0];
      properties[OVERFLOW_Y] = values[1];
    }
  }

  static void removeShorthandOverflow(CSSStyleDeclaration style, [bool? isImportant]) {
    if (style.contains(OVERFLOW_X)) style.removeProperty(OVERFLOW_X, isImportant);
    if (style.contains(OVERFLOW_Y)) style.removeProperty(OVERFLOW_Y, isImportant);
  }

  static void setShorthandFont(Map<String, String?> properties, String shorthandValue) {
    List<String?>? values = _getFontValues(shorthandValue);
    if (values == null) return;
    properties[FONT_STYLE] = values[0];
    properties[FONT_WEIGHT] = values[1];
    properties[FONT_SIZE] = values[2];
    properties[LINE_HEIGHT] = values[3];
    properties[FONT_FAMILY] = values[4];
  }

  static void removeShorthandFont(CSSStyleDeclaration style, [bool? isImportant]) {
    if (style.contains(FONT_STYLE)) style.removeProperty(FONT_STYLE, isImportant);
    if (style.contains(FONT_WEIGHT)) style.removeProperty(FONT_WEIGHT, isImportant);
    if (style.contains(FONT_SIZE)) style.removeProperty(FONT_SIZE, isImportant);
    if (style.contains(LINE_HEIGHT)) style.removeProperty(LINE_HEIGHT, isImportant);
    if (style.contains(FONT_FAMILY)) style.removeProperty(FONT_FAMILY, isImportant);
  }

  static void setShorthandFlex(Map<String, String?> properties, String shorthandValue) {
    List<String>? values = _getFlexValues(shorthandValue);
    if (values == null) return;
    properties[FLEX_GROW] = values[0];
    properties[FLEX_SHRINK] = values[1];
    properties[FLEX_BASIS] = values[2];
  }

  static void removeShorthandFlex(CSSStyleDeclaration style, [bool? isImportant]) {
    if (style.contains(FLEX_GROW)) style.removeProperty(FLEX_GROW, isImportant);
    if (style.contains(FLEX_SHRINK)) style.removeProperty(FLEX_SHRINK, isImportant);
    if (style.contains(FLEX_BASIS)) style.removeProperty(FLEX_BASIS, isImportant);
  }

  static void setShorthandFlexFlow(Map<String, String?> properties, String shorthandValue) {
    List<String?>? values = _getFlexFlowValues(shorthandValue);
    if (values == null) return;
    properties[FLEX_DIRECTION] = values[0];
    properties[FLEX_WRAP] = values[1];
  }

  static void removeShorthandFlexFlow(CSSStyleDeclaration style, [bool? isImportant]) {
    if (style.contains(FLEX_DIRECTION)) style.removeProperty(FLEX_DIRECTION, isImportant);
    if (style.contains(FLEX_WRAP)) style.removeProperty(FLEX_WRAP, isImportant);
  }

  static void setShorthandTransition(Map<String, String?> properties, String shorthandValue) {
    List<String?>? values = _getTransitionValues(shorthandValue);
    if (values == null) return;

    properties[TRANSITION_PROPERTY] = values[0];
    properties[TRANSITION_DURATION] = values[1];
    properties[TRANSITION_TIMING_FUNCTION] = values[2];
    properties[TRANSITION_DELAY] = values[3];
  }

  static void removeShorthandTransition(CSSStyleDeclaration style, [bool? isImportant]) {
    if (style.contains(TRANSITION_PROPERTY)) style.removeProperty(TRANSITION_PROPERTY, isImportant);
    if (style.contains(TRANSITION_DURATION)) style.removeProperty(TRANSITION_DURATION, isImportant);
    if (style.contains(TRANSITION_TIMING_FUNCTION)) style.removeProperty(TRANSITION_TIMING_FUNCTION, isImportant);
    if (style.contains(TRANSITION_DELAY)) style.removeProperty(TRANSITION_DELAY, isImportant);
  }

  static void setShorthandTextDecoration(Map<String, String?> properties, String shorthandValue) {
    List<String?>? values = _getTextDecorationValues(shorthandValue);
    if (values == null) return;

    properties[TEXT_DECORATION_LINE] = values[0];
    properties[TEXT_DECORATION_COLOR] = values[1];
    properties[TEXT_DECORATION_STYLE] = values[2];
  }

  static void removeShorthandTextDecoration(CSSStyleDeclaration style, [bool? isImportant]) {
    if (style.contains(TEXT_DECORATION_LINE)) style.removeProperty(TEXT_DECORATION_LINE, isImportant);
    if (style.contains(TEXT_DECORATION_COLOR)) style.removeProperty(TEXT_DECORATION_COLOR, isImportant);
    if (style.contains(TEXT_DECORATION_STYLE)) style.removeProperty(TEXT_DECORATION_STYLE, isImportant);
  }

  static void setShorthandBorder(Map<String, String?> properties, String property, String shorthandValue) {
    String? borderTopColor;
    String? borderRightColor;
    String? borderBottomColor;
    String? borderLeftColor;
    String? borderTopStyle;
    String? borderRightStyle;
    String? borderBottomStyle;
    String? borderLeftStyle;
    String? borderTopWidth;
    String? borderRightWidth;
    String? borderBottomWidth;
    String? borderLeftWidth;

    if (property == BORDER ||
        property == BORDER_TOP ||
        property == BORDER_RIGHT ||
        property == BORDER_BOTTOM ||
        property == BORDER_LEFT) {
      List<String?>? values = CSSStyleProperty._getBorderValues(shorthandValue);
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
      List<String?>? values = _getEdgeValues(shorthandValue, isNonNegativeLength: true);
      if (values == null) return;

      borderTopWidth = values[0];
      borderRightWidth = values[1];
      borderBottomWidth = values[2];
      borderLeftWidth = values[3];
    } else if (property == BORDER_STYLE) {
      // @TODO: validate value
      List<String?>? values = _getEdgeValues(shorthandValue);
      if (values == null) return;

      borderTopStyle = values[0];
      borderRightStyle = values[1];
      borderBottomStyle = values[2];
      borderLeftStyle = values[3];
    } else if (property == BORDER_COLOR) {
      // @TODO: validate value
      List<String?>? values = _getEdgeValues(shorthandValue);
      if (values == null) return;

      borderTopColor = values[0];
      borderRightColor = values[1];
      borderBottomColor = values[2];
      borderLeftColor = values[3];
    }

    if (borderTopColor != null) properties[BORDER_TOP_COLOR] = borderTopColor;
    if (borderRightColor != null) properties[BORDER_RIGHT_COLOR] = borderRightColor;
    if (borderBottomColor != null) properties[BORDER_BOTTOM_COLOR] = borderBottomColor;
    if (borderLeftColor != null) properties[BORDER_LEFT_COLOR] = borderLeftColor;
    if (borderTopStyle != null) properties[BORDER_TOP_STYLE] = borderTopStyle;
    if (borderRightStyle != null) properties[BORDER_RIGHT_STYLE] = borderRightStyle;
    if (borderBottomStyle != null) properties[BORDER_BOTTOM_STYLE] = borderBottomStyle;
    if (borderLeftStyle != null) properties[BORDER_LEFT_STYLE] = borderLeftStyle;
    if (borderTopWidth != null) properties[BORDER_TOP_WIDTH] = borderTopWidth;
    if (borderRightWidth != null) properties[BORDER_RIGHT_WIDTH] = borderRightWidth;
    if (borderBottomWidth != null) properties[BORDER_BOTTOM_WIDTH] = borderBottomWidth;
    if (borderLeftWidth != null) properties[BORDER_LEFT_WIDTH] = borderLeftWidth;
  }

  static void removeShorthandBorder(CSSStyleDeclaration style, String property, [bool? isImportant]) {
    if (property == BORDER ||
        property == BORDER_TOP ||
        property == BORDER_RIGHT ||
        property == BORDER_BOTTOM ||
        property == BORDER_LEFT) {
      if (property == BORDER || property == BORDER_TOP) {
        if (style.contains(BORDER_TOP_COLOR)) style.removeProperty(BORDER_TOP_COLOR, isImportant);
        if (style.contains(BORDER_TOP_STYLE)) style.removeProperty(BORDER_TOP_STYLE, isImportant);
        if (style.contains(BORDER_TOP_WIDTH)) style.removeProperty(BORDER_TOP_WIDTH, isImportant);
      }
      if (property == BORDER || property == BORDER_RIGHT) {
        if (style.contains(BORDER_RIGHT_COLOR)) style.removeProperty(BORDER_RIGHT_COLOR, isImportant);
        if (style.contains(BORDER_RIGHT_STYLE)) style.removeProperty(BORDER_RIGHT_STYLE, isImportant);
        if (style.contains(BORDER_RIGHT_WIDTH)) style.removeProperty(BORDER_RIGHT_WIDTH, isImportant);
      }
      if (property == BORDER || property == BORDER_BOTTOM) {
        if (style.contains(BORDER_BOTTOM_COLOR)) style.removeProperty(BORDER_BOTTOM_COLOR, isImportant);
        if (style.contains(BORDER_BOTTOM_STYLE)) style.removeProperty(BORDER_BOTTOM_STYLE, isImportant);
        if (style.contains(BORDER_BOTTOM_WIDTH)) style.removeProperty(BORDER_BOTTOM_WIDTH, isImportant);
      }
      if (property == BORDER || property == BORDER_LEFT) {
        if (style.contains(BORDER_LEFT_COLOR)) style.removeProperty(BORDER_LEFT_COLOR, isImportant);
        if (style.contains(BORDER_LEFT_STYLE)) style.removeProperty(BORDER_LEFT_STYLE, isImportant);
        if (style.contains(BORDER_LEFT_WIDTH)) style.removeProperty(BORDER_LEFT_WIDTH, isImportant);
      }
    } else {
      if (property == BORDER_WIDTH) {
        if (style.contains(BORDER_TOP_WIDTH)) style.removeProperty(BORDER_TOP_WIDTH, isImportant);
        if (style.contains(BORDER_RIGHT_WIDTH)) style.removeProperty(BORDER_RIGHT_WIDTH, isImportant);
        if (style.contains(BORDER_BOTTOM_WIDTH)) style.removeProperty(BORDER_BOTTOM_WIDTH, isImportant);
        if (style.contains(BORDER_LEFT_WIDTH)) style.removeProperty(BORDER_LEFT_WIDTH, isImportant);
      } else if (property == BORDER_STYLE) {
        if (style.contains(BORDER_TOP_STYLE)) style.removeProperty(BORDER_TOP_STYLE, isImportant);
        if (style.contains(BORDER_RIGHT_STYLE)) style.removeProperty(BORDER_RIGHT_STYLE, isImportant);
        if (style.contains(BORDER_BOTTOM_STYLE)) style.removeProperty(BORDER_BOTTOM_STYLE, isImportant);
        if (style.contains(BORDER_LEFT_STYLE)) style.removeProperty(BORDER_LEFT_STYLE, isImportant);
      } else if (property == BORDER_COLOR) {
        if (style.contains(BORDER_TOP_COLOR)) style.removeProperty(BORDER_TOP_COLOR, isImportant);
        if (style.contains(BORDER_RIGHT_COLOR)) style.removeProperty(BORDER_RIGHT_COLOR, isImportant);
        if (style.contains(BORDER_BOTTOM_COLOR)) style.removeProperty(BORDER_BOTTOM_COLOR, isImportant);
        if (style.contains(BORDER_LEFT_COLOR)) style.removeProperty(BORDER_LEFT_COLOR, isImportant);
      }
    }
  }

  // all, -moz-specific, sliding; => ['all', '-moz-specific', 'sliding']
  static List<String>? getMultipleValues(String property) {
    if (property.isEmpty) return null;
    return property.split(_commaRegExp);
  }

  static List<List<String?>>? getShadowValues(String property) {
    List shadows = property.split(_commaRegExp);
    // The shadow effects are applied front-to-back: the first shadow is on top and
    // the others are layered behind.
    // https://drafts.csswg.org/css-backgrounds-3/#shadow-layers
    Iterable reversedShadows = shadows.reversed;
    List reversedShadowList = reversedShadows.toList();
    List<List<String?>> values = List.empty(growable: true);

    for (String shadow in reversedShadowList as Iterable<String>) {
      if (shadow == NONE) {
        continue;
      }
      List<String> parts = shadow.trim().split(_spaceRegExp);

      String? inset;
      String? color;

      List<String?> lengthValues = List.filled(4, null);
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

  static List<String?>? _getBorderRaidusValues(String shorthandProperty) {
    if (!shorthandProperty.contains('/')) {
      return _getEdgeValues(shorthandProperty, isNonNegativeLengthOrPercentage: true);
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

    List<String?> firstValues = _getEdgeValues(firstRadius, isNonNegativeLengthOrPercentage: true)!;
    List<String?> secondValues = _getEdgeValues(secondRadius, isNonNegativeLengthOrPercentage: true)!;

    return [
      '${firstValues[0]} ${secondValues[0]}',
      '${firstValues[1]} ${secondValues[1]}',
      '${firstValues[2]} ${secondValues[2]}',
      '${firstValues[3]} ${secondValues[3]}'
    ];
  }

  // Current not support multiple background layer.
  static List<String?>? _getBackgroundValues(String shorthandProperty) {
    // Convert 40%/10em -> 40% / 10em
    shorthandProperty = shorthandProperty.replaceAll(_slashRegExp, ' / ');
    List values = shorthandProperty.split(_spaceRegExp);

    String? color;
    String? image;
    String? repeat;
    String? attachment;
    String? positionX;
    String? positionY;
    String? sizeWidth;
    String? sizeHeight;

    String? position;
    String? size;
    bool isPositionEndAndSizeStart = false;

    for (String value in values as Iterable<String>) {
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
      position = position! + (' ' + positionY);
    }

    if (sizeWidth != null) {
      size = sizeWidth;
    }

    if (sizeHeight != null) {
      size = size! + (' ' + sizeHeight);
    }

    return [color, image, repeat, attachment, position, size];
  }

  static List<String?>? _getFontValues(String shorthandProperty) {
    // Convert 40%/10em => 40% / 10em
    shorthandProperty = shorthandProperty.replaceAll(_slashRegExp, ' / ');
    // Convert "Goudy Bookletter 1911", sans-serif => "Goudy Bookletter 1911",sans-serif
    shorthandProperty = shorthandProperty.replaceAll(_replaceCommaRegExp, ',');
    List values = _splitBySpace(shorthandProperty);

    String? style;
    String? weight;
    String? size;
    String? lineHeight;
    String? family;

    bool isSizeEndAndLineHeightStart = false;

    for (String value in values as Iterable<String>) {
      if (style == null && CSSText.isValidFontStyleValue(value)) {
        style = value;
      } else if (weight == null && CSSText.isValidFontWeightValue(value)) {
        weight = value;
      } else if (size == null && CSSLength.isNonNegativeLength(value)) {
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

  static List<String?>? _getTextDecorationValues(String shorthandProperty) {
    List<String> values = shorthandProperty.split(_spaceRegExp);
    String? line;
    String? color;
    String? style;

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

  static List<String?>? _getTransitionValues(String shorthandProperty) {
    List transitions = shorthandProperty.split(_commaRegExp);
    List<String?> values = List.filled(4, null);

    for (String transition in transitions as Iterable<String>) {
      List<String> parts = transition.trim().split(_spaceRegExp);

      String? property;
      String? duration;
      String? timingFuction;
      String? delay;

      for (String part in parts) {
        if (property == null && CSSTransitionMixin.isValidTransitionPropertyValue(part)) {
          property = part;
        } else if (duration == null && CSSTime.isTime(part)) {
          duration = part;
        } else if (timingFuction == null && CSSTransitionMixin.isValidTransitionTimingFunctionValue(part)) {
          timingFuction = part;
        } else if (delay == null && CSSTime.isTime(part)) {
          delay = part;
        } else {
          return null;
        }
      }

      property = property ?? ALL;
      duration = duration ?? _0s;
      timingFuction = timingFuction ?? EASE;
      delay = delay ?? _0s;

      values[0] == null ? values[0] = property : values[0] = values[0]! + (_comma + property);
      values[1] == null ? values[1] = duration : values[1] = values[1]! + (_comma + duration);
      values[2] == null ? values[2] = timingFuction : values[2] = values[2]! + (_comma + timingFuction);
      values[3] == null ? values[3] = delay : values[3] = values[3]! + (_comma + delay);
    }

    return values;
  }

  static List<String?>? _getFlexFlowValues(String shorthandProperty) {
    List<String> values = shorthandProperty.split(_spaceRegExp);

    String? direction;
    String? wrap;

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

  static List<String>? _getFlexValues(String shorthandProperty) {
    List<String> values = shorthandProperty.split(_spaceRegExp);

    // In flex shorthand case it is interpreted as flex: <number> 1 0;
    String? grow;
    String? shrink;
    String? basis;

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
      } else if (basis == null && ((CSSLength.isNonNegativeLength(value) || value == AUTO))) {
        basis = value;
      } else {
        return null;
      }
    }

    return [grow ?? _1, shrink ?? _1, basis ?? _0];
  }

  static List<String?>? _getBorderValues(String shorthandProperty) {
    List<String> values = shorthandProperty.split(_spaceRegExp);

    String? width;
    String? style;
    String? color;

    // NOTE: if one of token is wrong like `1pxxx solid red` that all should not work
    for (String value in values) {
      if (width == null && CSSBorderSide.isValidBorderWidthValue(value)) {
        width = value;
      } else if (style == null && CSSBorderSide.isValidBorderStyleValue(value)) {
        style = value;
      } else if (color == null && CSSColor.isColor(value)) {
        color = value;
      } else {
        return null;
      }
    }

    return [width, style, color];
  }

  static List<String?>? _getEdgeValues(String shorthandProperty, {
    bool isLengthOrPercentage = false,
    bool isNonNegativeLengthOrPercentage = false,
    bool isNonNegativeLength = false,
  }) {
    var properties = shorthandProperty.split(_spaceRegExp);

    String? topValue;
    String? rightValue;
    String? bottomValue;
    String? leftValue;

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

    if (isLengthOrPercentage) {
      if ((!CSSLength.isLength(topValue) && !CSSPercentage.isPercentage(topValue)) ||
          (!CSSLength.isLength(rightValue) && !CSSPercentage.isPercentage(rightValue)) ||
          (!CSSLength.isLength(bottomValue) && !CSSPercentage.isPercentage(bottomValue))||
          (!CSSLength.isLength(leftValue) && !CSSPercentage.isPercentage(leftValue))) {
        return null;
      }
    } else if (isNonNegativeLengthOrPercentage) {
      if ((!CSSLength.isNonNegativeLength(topValue) && !CSSPercentage.isNonNegativePercentage(topValue)) ||
        (!CSSLength.isNonNegativeLength(rightValue) && !CSSPercentage.isNonNegativePercentage(rightValue)) ||
        (!CSSLength.isNonNegativeLength(bottomValue) && !CSSPercentage.isNonNegativePercentage(bottomValue))||
        (!CSSLength.isNonNegativeLength(leftValue) && !CSSPercentage.isNonNegativePercentage(leftValue))) {
        return null;
      }
    } else if (isNonNegativeLength) {
      if ((!CSSLength.isNonNegativeLength(topValue)) ||
        (!CSSLength.isNonNegativeLength(rightValue)) ||
        (!CSSLength.isNonNegativeLength(bottomValue))||
        (!CSSLength.isNonNegativeLength(leftValue))) {
        return null;
      }
    }

    // Assume the properties are in the usual order top, right, bottom, left.
    return [topValue, rightValue, bottomValue, leftValue];
  }

  // https://drafts.csswg.org/css-values-4/#typedef-position
  static List<String?> getPositionValues(String shorthandProperty) {
    var properties = shorthandProperty.trim().split(_spaceRegExp);

    String? x;
    String? y;
    if (properties.length == 1) {
      x = y = properties[0];
    } else if (properties.length == 2) {
      x = properties[0];
      y = properties[1];
    }

    return [x, y];
  }
}
