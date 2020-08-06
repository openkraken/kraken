/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'package:flutter/rendering.dart';
import 'package:kraken/css.dart';

const double DEFAULT_FONT_SIZE = 14.0;
const double DEFAULT_LETTER_SPACING = 0.0;
const double DEFAULT_WORD_SPACING = 0.0;
const double DEFAULT_FONT_WEIGHT = 400.0;

final RegExp _spaceRegExp = RegExp(r'\s+');
final RegExp _commaRegExp = RegExp(r'\s*,\s*');

// CSS Text: https://drafts.csswg.org/css-text-3/
// CSS Text Decoration: https://drafts.csswg.org/css-text-decor-3/
mixin CSSTextMixin {
  TextSpan createTextSpan(String text, CSSStyleDeclaration style) {
    TextStyle textStyle = style != null ? getTextStyle(style) : null;
    return TextSpan(
      text: text,
      style: textStyle,
    );
  }

  TextAlign getTextAlign(CSSStyleDeclaration style) {
    TextAlign textAlign = TextAlign.left;
    if (style == null) {
      return textAlign;
    }
    switch (style[TEXT_ALIGN]) {
      case 'center':
        textAlign = TextAlign.center;
        break;
      case 'right':
        textAlign = TextAlign.right;
        break;
      case 'left':
      default:
        textAlign = TextAlign.left;
        break;
    }
    return textAlign;
  }

  /// Creates a new TextStyle object.
  ///   color: The color to use when painting the text. If this is specified, foreground must be null.
  ///   decoration: The decorations to paint near the text (e.g., an underline).
  ///   decorationColor: The color in which to paint the text decorations.
  ///   decorationStyle: The style in which to paint the text decorations (e.g., dashed).
  ///   fontWeight: The typeface thickness to use when painting the text (e.g., bold).
  ///   fontStyle: The typeface variant to use when drawing the letters (e.g., italics).
  ///   fontSize: The size of glyphs (in logical pixels) to use when painting the text.
  ///   letterSpacing: The amount of space (in logical pixels) to add between each letter.
  ///   wordSpacing: The amount of space (in logical pixels) to add at each sequence of white-space (i.e. between /// each word).
  ///   textBaseline: The common baseline that should be aligned between this text span and its parent text span, /// or, for the root text spans, with the line box.
  ///   height: The height of this text span, as a multiple of the font size.
  ///   locale: The locale used to select region-specific glyphs.
  ///   background: The paint drawn as a background for the text.
  ///   foreground: The paint used to draw the text. If this is specified, color must be null.
  TextStyle getTextStyle(CSSStyleDeclaration style) {
    return TextStyle(
      color: getColor(style),
      decoration: getDecorationLine(style),
      decorationColor: getDecorationColor(style),
      decorationStyle: getTextDecorationStyle(style),
      fontWeight: getFontWeight(style),
      fontStyle: getFontStyle(style),
      textBaseline: getTextBaseLine(style),
      package: getFontPackage(style),
      fontFamilyFallback: getFontFamilyFallback(style),
      fontSize: getFontSize(style),
      letterSpacing: getLetterSpacing(style),
      wordSpacing: getWordSpacing(style),
      locale: getLocale(style),
      background: getBackground(style),
      foreground: getForeground(style),
      shadows: getShadows(style),
    );
  }

  Color getColor(CSSStyleDeclaration style) {
    if (style.contains(COLOR)) {
      return CSSColor.parseColor(style[COLOR]);
    } else {
      return CSSColor.initial; // Default color to black.
    }
  }

  /// In CSS2.1, text-decoration determin the type of text decoration,
  /// but in CSS3, which is text-decoration-line.
  TextDecoration getDecorationLine(CSSStyleDeclaration style) {
    if (style.contains(TEXT_DECORATION_LINE)) {
      return _getTextDecorationLine(style[TEXT_DECORATION_LINE]);
    } else if (style.contains(TEXT_DECORATION)) {
      String textDecoration = style[TEXT_DECORATION];
      List<String> splittedTextDecoration = textDecoration.split(_spaceRegExp);
      // Compatible with CSS 2.1: text-decoration = text-decoration-line.
      if (splittedTextDecoration.length >= 1) {
        return _getTextDecorationLine(splittedTextDecoration[0]);
      }
    }
    return _getTextDecorationLine();
  }

  TextDecoration _getTextDecorationLine([String type]) {
    if (type == 'line-through')
      return TextDecoration.lineThrough;
    else if (type == 'overline')
      return TextDecoration.overline;
    else if (type == 'underline')
      return TextDecoration.underline;
    else
      return TextDecoration.none;
  }

  Color getDecorationColor(CSSStyleDeclaration style) {
    if (style.contains(TEXT_DECORATION_COLOR)) {
      return CSSColor.parseColor(style[TEXT_DECORATION_COLOR]);
    } else if (style.contains(TEXT_DECORATION)) {
      String textDecoration = style[TEXT_DECORATION];
      List<String> splitedDecoration = textDecoration.split(_spaceRegExp);
      if (splitedDecoration.length >= 2) {
        return CSSColor.parseColor(splitedDecoration.last);
      }
    }
    return getColor(style); // Default to currentColor (style.color)
  }

  TextDecorationStyle getTextDecorationStyle(CSSStyleDeclaration style) {
    if (style.contains(TEXT_DECORATION_STYLE)) {
      return _getTextDecorationStyle(style[TEXT_DECORATION_STYLE]);
    } else if (style.contains(TEXT_DECORATION)) {
      String textDecoration = style[TEXT_DECORATION];
      List<String> splitedDecoration = textDecoration.split(_spaceRegExp);
      if (splitedDecoration.length >= 2) {
        return _getTextDecorationStyle(splitedDecoration[1]);
      }
    }
    return _getTextDecorationStyle();
  }

  TextDecorationStyle _getTextDecorationStyle([String value]) {
    switch (value) {
      case 'double':
        return TextDecorationStyle.double;
      case 'dotted':
        return TextDecorationStyle.dotted;
      case 'dashed':
        return TextDecorationStyle.dashed;
      case 'wavy':
        return TextDecorationStyle.wavy;
      case 'solid':
      default:
        return TextDecorationStyle.solid;
    }
  }

  FontWeight getFontWeight(CSSStyleDeclaration style) {
    if (style.contains(FONT_WEIGHT)) {
      var fontWeight = style[FONT_WEIGHT];
      double fontWeightValue = DEFAULT_FONT_WEIGHT; // Default to 400.
      if (fontWeight is String) {
        switch (fontWeight) {
          case 'lighter':
            fontWeightValue = 200;
            break;
          case 'normal':
            fontWeightValue = 400;
            break;
          case 'bold':
            fontWeightValue = 700;
            break;
          case 'bolder':
            fontWeightValue = 900;
            break;
          default:
            fontWeightValue = double.tryParse(fontWeight) ?? DEFAULT_FONT_WEIGHT;
            break;
        }
      }

      if (fontWeightValue >= 900) {
        return FontWeight.w900;
      } else if (fontWeightValue >= 800) {
        return FontWeight.w800;
      } else if (fontWeightValue >= 700) {
        return FontWeight.w700;
      } else if (fontWeightValue >= 600) {
        return FontWeight.w600;
      } else if (fontWeightValue >= 500) {
        return FontWeight.w500;
      } else if (fontWeightValue >= 400) {
        return FontWeight.w400;
      } else if (fontWeightValue >= 300) {
        return FontWeight.w300;
      } else if (fontWeightValue >= 200) {
        return FontWeight.w200;
      } else {
        return FontWeight.w100;
      }
    }
    return FontWeight.normal;
  }

  FontStyle getFontStyle(CSSStyleDeclaration style) {
    if (style.contains(FONT_STYLE)) {
      switch (style[FONT_STYLE]) {
        case 'oblique':
        case 'italic':
          return FontStyle.italic;
        case 'normal':
          return FontStyle.normal;
      }
    }
    return FontStyle.normal;
  }

  TextBaseline getTextBaseLine(CSSStyleDeclaration style) {
    return TextBaseline.alphabetic; // @TODO: impl vertical-align
  }

  static String BUILTIN_FONT_PACKAGE = null;
  String getFontPackage(CSSStyleDeclaration style) {
    return BUILTIN_FONT_PACKAGE;
  }

  static List<String> DEFAULT_FONT_FAMILY_FALLBACK = null;
  List<String> getFontFamilyFallback(CSSStyleDeclaration style) {
    String fontFamily = style[FONT_FAMILY];
    if (fontFamily.isNotEmpty) {
      List<String> values = fontFamily.split(_commaRegExp);
      List<String> resolvedFamily = List();

      for (int i = 0; i < values.length; i++) {
        String familyName = values[i];
        // Remove wrapping quotes: "Gill Sans" -> Gill Sans
        if (familyName[0] == '"' || familyName[0] == '\'') {
          familyName = familyName.substring(1, familyName.length - 1);
        }

        switch (familyName) {
          case 'sans-serif':
            // Default sans-serif font in iOS (9 and newer)and iPadOS: San Francisco
            // Default sans-serif font in Android (4.0+): Roboto
            resolvedFamily.addAll(['Helvetica', 'Roboto', 'PingFang SC', 'PingFang TC']);
            break;
          case 'serif':
            // Default serif font in iOS and iPadOS: Times New Roman (as TimesNewRomanPSMT)
            // Default serif font in Android (4.0+): Noto Serif
            resolvedFamily.addAll(['Times', 'Times New Roman', 'Noto Serif', 'Songti SC', 'Songti TC', 'Hiragino Mincho ProN', 'AppleMyungjo', 'Apple SD Gothic Neo']);
            break;
          case 'monospace':
            resolvedFamily.addAll(['Courier', 'Courier New', 'DroidSansMono', 'Monaco', 'Heiti SC', 'Heiti TC']);
            break;
          case 'cursive':
            resolvedFamily.addAll(['Apple Chancery', 'DancingScript']);
            break;
          case 'fantasy':
            resolvedFamily.addAll(['Papyrus', 'Impact']);
            break;
          default:
            resolvedFamily.add(familyName);
        }
      }
      return resolvedFamily;
    }
    return DEFAULT_FONT_FAMILY_FALLBACK;
  }

  double getFontSize(CSSStyleDeclaration style) {
    if (style.contains(FONT_SIZE)) {
      return CSSLength.toDisplayPortValue(style[FONT_SIZE]) ?? DEFAULT_FONT_SIZE;
    } else {
      return DEFAULT_FONT_SIZE;
    }
  }

  double getLetterSpacing(CSSStyleDeclaration style) {
    if (style.contains(LETTER_SPACING)) {
      String _letterSpacing = style[LETTER_SPACING];
      if (_letterSpacing == NORMAL) return DEFAULT_LETTER_SPACING;

      return CSSLength.toDisplayPortValue(_letterSpacing) ?? DEFAULT_LETTER_SPACING;
    } else {
      return DEFAULT_LETTER_SPACING;
    }
  }

  double getWordSpacing(CSSStyleDeclaration style) {
    if (style.contains(WORD_SPACING)) {
      String _wordSpacing = style[WORD_SPACING];
      if (_wordSpacing == NORMAL) return DEFAULT_WORD_SPACING;

      return CSSLength.toDisplayPortValue(_wordSpacing) ?? DEFAULT_WORD_SPACING;
    } else {
      return DEFAULT_WORD_SPACING;
    }
  }

  Locale getLocale(CSSStyleDeclaration style) {
    // TODO: impl locale for text decoration.
    return null;
  }

  Paint getBackground(CSSStyleDeclaration style) {
    // TODO: Reserved port for customize text decoration background.
    return null;
  }

  Paint getForeground(CSSStyleDeclaration style) {
    // TODO: Reserved port for customize text decoration foreground.
    return null;
  }

  List<Shadow> getShadows(CSSStyleDeclaration style) {
    List<Shadow> textShadows = [];
    if (style.contains(TEXT_SHADOW)) {
      var shadows = CSSStyleProperty.getShadowValues(style[TEXT_SHADOW]);
      if (shadows != null) {
        shadows.forEach((shadowDefinitions) {
          // Specifies the color of the shadow. If the color is absent, it defaults to currentColor.
          Color color = CSSColor.parseColor(shadowDefinitions[0] ?? style[COLOR]);
          double offsetX = CSSLength.toDisplayPortValue(shadowDefinitions[1]) ?? 0;
          double offsetY = CSSLength.toDisplayPortValue(shadowDefinitions[2]) ?? 0;
          double blurRadius = CSSLength.toDisplayPortValue(shadowDefinitions[3]) ?? 0;

          if (color != null) {
            textShadows.add(Shadow(
              offset: Offset(offsetX, offsetY),
              blurRadius: blurRadius,
              color: color,
            ));
          }
        });
      }

    }
    return textShadows;
  }
}


class CSSFont {
  static bool isValidFontStyleValue(String value) {
    return value ==  'normal' || value == 'italic' || value == 'oblique';
  }

  static bool isValidFontWeightValue(String value) {
    double weight = CSSNumber.parseNumber(value);
    if (weight != null) {
      return weight >= 1 && weight <= 1000;
    } else {
      return value == 'normal' || value == 'bold' || value == 'lighter' || value == 'bolder';
    }
  }

  static bool isValidLineHeightValue(String value) {
    return CSSLength.isLength(value) || value == 'normal' || double.tryParse(value) != null;
  }

  static double getFontSize(CSSStyleDeclaration style) {
    if (style.contains(FONT_SIZE)) {
      return CSSLength.toDisplayPortValue(style[FONT_SIZE]) ?? DEFAULT_FONT_SIZE;
    } else {
      return DEFAULT_FONT_SIZE;
    }
  }

  static double getLineHeight(CSSStyleDeclaration style) {
    String value = style[LINE_HEIGHT];
    double lineHeight;
    if (value.isNotEmpty) {
      if (CSSLength.isLength(value)) {
        lineHeight = CSSLength.toDisplayPortValue(value);
      } else {
        double multipliedNumber = double.tryParse(value);
        if (multipliedNumber != null) {
          lineHeight = getFontSize(style) * multipliedNumber;
        }
        
      }
    }
    return lineHeight;
  }
}
