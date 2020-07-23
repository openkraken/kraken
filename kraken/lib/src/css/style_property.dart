
import 'package:kraken/css.dart';

final RegExp _spaceRegExp = RegExp(r'\s+(?![^(]*\))');
final RegExp _commaRegExp = RegExp(r',(?![^\(]*\))');

class CSSStyleProperty {

  static double getDisplayPortValue(input) {
    if (CSSStyleDeclaration.isNullOrEmptyValue(input)) {
      // Null is not equal with 0.0
      return null;
    }
    if (input is! String) {
      input = input.toString();
    }
    return CSSLength.toDisplayPortValue(input as String);
  }


  static void setShorthandPadding(Map<String, String> style, String shorthandValue) {
    if (shorthandValue != null) {
      List<String> properties = CSSStyleProperty.getInsetValues(shorthandValue);
      style[PADDING_TOP] = properties[0];
      style[PADDING_RIGHT] = properties[1];
      style[PADDING_BOTTOM] = properties[2];
      style[PADDING_LEFT] = properties[3];
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
      List<String> properties = CSSStyleProperty.getInsetValues(shorthandValue);
      style[MARGIN_TOP] = properties[0];
      style[MARGIN_RIGHT] = properties[1];
      style[MARGIN_BOTTOM] = properties[2];
      style[MARGIN_LEFT] = properties[3];
    }
  }

  static void removeShorthandMargin(Map<String, String> style) {
    if (style.containsKey(MARGIN_LEFT)) style.remove(MARGIN_LEFT);
    if (style.containsKey(MARGIN_TOP)) style.remove(MARGIN_LEFT);
    if (style.containsKey(MARGIN_RIGHT)) style.remove(MARGIN_RIGHT);
    if (style.containsKey(MARGIN_BOTTOM)) style.remove(MARGIN_BOTTOM);
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
        if (part == 'inset') {
          inset = part;
        } else if (CSSLength.isLength(part)) {
          lengthValues[i++] = part;
        } else {
          color = part;
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

  static List<String> getBorderValues(String shorthandProperty) {
    assert(shorthandProperty != null);
    var properties = shorthandProperty.trim().split(_spaceRegExp);

    String width;
    String style;
    String color;

    // NOTE: if one of token is wrong like `1pxxx solid red` that all should not work 
    for (String property in properties) {
      if (width == null && (CSSLength.isLength(property) || property == THIN || property == MEDIUM || property == THICK)) {
        width = property;
      } else if (style == null && (property == SOLID || property == NONE)) {
        style = property;
      } else if (color == null && CSSColor.isColor(property)) {
        color = property;
      } else {
        return null;
      }
    }

    return [width, style, color];
  }

  static List<String> getInsetValues(String shorthandProperty) {
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

  static bool isShorthandProperty(String property) {
    return property == PADDING || 
      property == MARGIN ||
      property == BORDER ||
      property == BACKGROUND ||
      property == FONT ||
      property == ANIMATION;
  }
}

