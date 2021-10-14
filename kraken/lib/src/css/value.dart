
import 'dart:ui';

import 'package:kraken/css.dart';

// https://drafts.css-houdini.org/css-properties-values-api/#dependency-cycles
class CSSValue {
  String propertyName;
  RenderStyle renderStyle;
  CSSValue(this.propertyName, this.renderStyle);

  static bool isFontRelativeLength(CSSLengthValue value) {
    return value.unit == CSSLengthType.EM;
  }

  static bool isRootFontRelativeLength(CSSLengthValue value) {
    return value.unit == CSSLengthType.REM;
  }

  static void updateNumber(RenderStyle renderStyle, String property, double number) {
    switch (property) {
      case OPACITY:
        renderStyle.opacity = number;
        break;
      case Z_INDEX:
        renderStyle.zIndex = int.parse(number.toString());
        break;
      case FLEX_GROW:
        renderStyle.flexGrow = number;
        break;
      case FLEX_SHRINK:
        renderStyle.flexShrink = number;
        break;
    }
  }

  static void updateColor(RenderStyle renderStyle, String property, Color color) {
    switch (property) {
      case COLOR:
        renderStyle.color = color;
        break;
      case TEXT_DECORATION_COLOR:
        renderStyle.textDecorationColor = color;
        break;
      case BACKGROUND_COLOR:
        // renderStyle.updateBackgroundColor(color);
        break;
      case BORDER_BOTTOM_COLOR:
      case BORDER_LEFT_COLOR:
      case BORDER_RIGHT_COLOR:
      case BORDER_TOP_COLOR:
      case BORDER_COLOR:
        // renderStyle.updateBorder(property, borderColor: color);
        break;
    }
  }

  static void updateLength(RenderStyle renderStyle, String property, double value) {
    
    
  }

}