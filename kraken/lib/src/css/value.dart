
import 'dart:ui';

import 'package:kraken/css.dart';

// https://drafts.css-houdini.org/css-properties-values-api/#dependency-cycles
class CSSValue {
  String propertyName;
  RenderStyle renderStyle;
  CSSValue(this.propertyName, this.renderStyle);

  // updateFontRelativeLength() {
  //   updateLength(renderStyle, propertyName, value);
  // }

  static bool isFontRelativeLength(CSSLengthValue value) {
    return value.unit == CSSLengthUnit.EM;
  }

  static bool isRootFontRelativeLength(CSSLengthValue value) {
    return value.unit == CSSLengthUnit.REM;
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
        renderStyle.updateBackgroundColor(color);
        break;
      case BORDER_BOTTOM_COLOR:
      case BORDER_LEFT_COLOR:
      case BORDER_RIGHT_COLOR:
      case BORDER_TOP_COLOR:
      case BORDER_COLOR:
        renderStyle.updateBorder(property, borderColor: color);
        break;
    }
  }

  static void updateLength(RenderStyle renderStyle, String property, double value) {
    switch (property) {
      case RIGHT:
      case TOP:
      case BOTTOM:
      case LEFT:
        renderStyle.updateOffset(property, value);
        break;
      case MARGIN_BOTTOM:
      case MARGIN_LEFT:
      case MARGIN_RIGHT:
      case MARGIN_TOP:
        renderStyle.updateMargin(property, value);
        break;
      case PADDING_BOTTOM:
      case PADDING_LEFT:
      case PADDING_RIGHT:
      case PADDING_TOP:
        renderStyle.updatePadding(property, value);
        break;
      case BORDER_BOTTOM_WIDTH:
      case BORDER_LEFT_WIDTH:
      case BORDER_RIGHT_WIDTH:
      case BORDER_TOP_WIDTH:
        renderStyle.updateBorder(property, borderWidth: value);
        break;
      case BORDER_BOTTOM_LEFT_RADIUS:
      case BORDER_BOTTOM_RIGHT_RADIUS:
      case BORDER_TOP_LEFT_RADIUS:
      case BORDER_TOP_RIGHT_RADIUS:
        renderStyle.updateBorderRadius(property, value.toString() + 'px');
        break;
      case FLEX_BASIS:
        renderStyle.flexBasis = value;
        break;
      case FONT_SIZE:
        renderStyle.fontSize = value;
        break;
      case LETTER_SPACING:
        renderStyle.letterSpacing = value;
        break;
      case WORD_SPACING:
        renderStyle.wordSpacing = value;
        break;
      case HEIGHT:
      case WIDTH:
      case MAX_HEIGHT:
      case MAX_WIDTH:
      case MIN_HEIGHT:
      case MIN_WIDTH:
        renderStyle.updateSizing(property, value);
        break;
      case LINE_HEIGHT:
        renderStyle.lineHeight = value;
        break;
    }
  }

}