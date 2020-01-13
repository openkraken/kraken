/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'package:flutter/rendering.dart';
import 'package:kraken/style.dart';

const String COLOR = 'color';
const String HEIGHT = 'height';
const String LINE_HEIGHT = 'lineHeight';
const String TEXT_DECORATION = 'textDecoration';
const String TEXT_DECORATION_LINE = 'textDecorationLine';
const String TEXT_DECORATION_COLOR = 'textDecorationColor';
const String TEXT_DECORATION_STYLE = 'textDecorationStyle';
const String LETTER_SPACING = 'letterSpacing';
const String WORD_SPACING = 'wordSpacing';
const String FONT_SIZE = 'fontSize';
const String FONT_FAMILY = 'fontFamily';
const String FONT_WEIGHT = 'fontWeight';
const String FONT_STYLE = 'fontStyle';
const String NORMAL = 'normal';
const double DEFAULT_FONT_SIZE = 14.0;
const double DEFAULT_LETTER_SPACING = 0.0;
const double DEFAULT_WORD_SPACING = 0.0;

mixin TextStyleMixin {
  TextSpan createTextSpanWithStyle(String text, Style style) {
    return TextSpan(
      text: text,
      style: getTextStyle(style),
    );
  }

  TextAlign getTextAlignFromStyle(Style style) {
    TextAlign textAlign;
    switch (style['textAlign']) {
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

  /// TextStyle({
  ///   Color color,
  ///   TextDecoration decoration,
  ///   Color decorationColor,
  ///   TextDecorationStyle decorationStyle,
  ///   FontWeight fontWeight,
  ///   FontStyle fontStyle,
  ///   TextBaseline textBaseline,
  ///   String fontFamily,
  ///   double fontSize,
  ///   double letterSpacing,
  ///   double wordSpacing,
  ///   double height,
  ///   Locale locale,
  ///   Paint background,
  ///   Paint foreground,
  ///   List<Shadow> shadows
  /// })
  ///
  /// Creates a new TextStyle object.
  ///   color: The color to use when painting the text. If this is specified, foreground must be null.
  ///   decoration: The decorations to paint near the text (e.g., an underline).
  ///   decorationColor: The color in which to paint the text decorations.
  ///   decorationStyle: The style in which to paint the text decorations (e.g., dashed).
  ///   fontWeight: The typeface thickness to use when painting the text (e.g., bold).
  ///   fontStyle: The typeface variant to use when drawing the letters (e.g., italics).
  ///   fontFamily: The name of the font to use when painting the text (e.g., Roboto).
  ///   fontSize: The size of glyphs (in logical pixels) to use when painting the text.
  ///   letterSpacing: The amount of space (in logical pixels) to add between each letter.
  ///   wordSpacing: The amount of space (in logical pixels) to add at each sequence of white-space (i.e. between /// each word).
  ///   textBaseline: The common baseline that should be aligned between this text span and its parent text span, /// or, for the root text spans, with the line box.
  ///   height: The height of this text span, as a multiple of the font size.
  ///   locale: The locale used to select region-specific glyphs.
  ///   background: The paint drawn as a background for the text.
  ///   foreground: The paint used to draw the text. If this is specified, color must be null.
  TextStyle getTextStyle(Style style) {
    return TextStyle(
      color: getColor(style),
      decoration: getDecorationLine(style),
      decorationColor: getDecorationColor(style),
      decorationStyle: getDecorationStyle(style),
      fontWeight: getFontWeight(style),
      fontStyle: getFontStyle(style),
      textBaseline: getTextBaseLine(style),
      fontFamily: getFontFamily(style),
      fontSize: getFontSize(style),
      letterSpacing: getLetterSpacing(style),
      wordSpacing: getWordSpacing(style),
      height: getHeight(style),
      locale: getLocale(style),
      background: getBackground(style),
      foreground: getForeground(style),
      shadows: getShadows(style),
    );
  }

  Color getColor(Style style) {
    if (style.contains(COLOR)) {
      return WebColor.generate(style[COLOR]);
    } else {
      return WebColor.black; // Default color to black.
    }
  }

  static RegExp spaceRegExp = RegExp(r' ');

  /// In CSS2.1, text-decoration determin the type of text decoration,
  /// but in CSS3, which is text-decoration-line.
  TextDecoration getDecorationLine(Style style) {
    TextDecoration textDecorationLine;
    if (style.contains(TEXT_DECORATION_LINE)) {
      textDecorationLine = _getTextDecorationLine(style[TEXT_DECORATION_LINE]);
    } else if (style.contains(TEXT_DECORATION)) {
      List<String> splittedTextDecoration =
          style[TEXT_DECORATION].split(spaceRegExp);
      for (String value in splittedTextDecoration) {
        textDecorationLine = _getTextDecorationLine(value);
      }
    }
    return textDecorationLine;
  }

  TextDecoration _getTextDecorationLine(String type) {
    if (type == 'line-through')
      return TextDecoration.lineThrough;
    else if (type == 'overline')
      return TextDecoration.overline;
    else if (type == 'underline')
      return TextDecoration.underline;
    else if (type == 'none') return TextDecoration.none;
    return null;
  }

  Color getDecorationColor(Style style) {
    if (style.contains(TEXT_DECORATION_COLOR)) {
      return WebColor.generate(style[TEXT_DECORATION_COLOR]);
    } else {
      return getColor(style); // Default to currentColor (style.color)
    }
  }

  TextDecorationStyle getDecorationStyle(Style style) {
    if (style.contains(TEXT_DECORATION_STYLE)) {
      switch (style[TEXT_DECORATION_STYLE]) {
        case 'solid':
          return TextDecorationStyle.solid;
        case 'double':
          return TextDecorationStyle.double;
        case 'dotted':
          return TextDecorationStyle.dotted;
        case 'dashed':
          return TextDecorationStyle.dashed;
        case 'wavy':
          return TextDecorationStyle.wavy;
      }
    }
    return TextDecorationStyle.solid;
  }

  FontWeight getFontWeight(Style style) {
    if (style.contains(FONT_WEIGHT)) {
      dynamic fontWeight = style[FONT_WEIGHT];
      if (fontWeight is int || fontWeight is double) {
        fontWeight = fontWeight.toString();
      }

      switch (fontWeight) {
        case '100':
          return FontWeight.w100;
        case '200':
        case 'lighter':
          return FontWeight.w200;
        case '300':
          return FontWeight.w300;
        case '400':
        case 'normal':
          return FontWeight.w400;
        case '500':
          return FontWeight.w500;
        case '600':
          return FontWeight.w600;
        case '700':
        case 'bold':
          return FontWeight.w700;
        case '800':
          return FontWeight.w800;
        case '900':
        case 'bolder':
          return FontWeight.w900;
      }
    }
    return FontWeight.normal;
  }

  FontStyle getFontStyle(Style style) {
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

  TextBaseline getTextBaseLine(Style style) {
    return TextBaseline.alphabetic; // TODO: impl vertical-align
  }

  String getFontFamily(Style style) {
    return style.contains(FONT_FAMILY) ? style[FONT_FAMILY] : null;
  }

  double getFontSize(Style style) {
    if (style.contains(FONT_SIZE)) {
      Length fontSize = Length(style[FONT_SIZE]);
      return fontSize.displayPortValue;
    } else {
      return DEFAULT_FONT_SIZE;
    }
  }

  double getLetterSpacing(Style style) {
    if (style.contains(LETTER_SPACING)) {
      String _letterSpacing = style[LETTER_SPACING];
      if (_letterSpacing == NORMAL) return DEFAULT_LETTER_SPACING;

      Length letterSpacing = Length(_letterSpacing);
      return letterSpacing.displayPortValue;
    } else {
      return DEFAULT_LETTER_SPACING;
    }
  }

  double getWordSpacing(Style style) {
    if (style.contains(WORD_SPACING)) {
      String _wordSpacing = style[WORD_SPACING];
      if (_wordSpacing == NORMAL) return DEFAULT_WORD_SPACING;

      Length wordSpacing = Length(_wordSpacing);
      return wordSpacing.displayPortValue;
    } else {
      return DEFAULT_WORD_SPACING;
    }
  }

  double getHeight(Style style) {
    if (style.contains(LINE_HEIGHT)) {
      Length height = Length(style[LINE_HEIGHT]);
      return height.displayPortValue;
    } else {
      return null;
    }
  }

  Locale getLocale(Style style) {
    // TODO: impl locale for text decoration.
    return null;
  }

  Paint getBackground(Style style) {
    // TODO: Reserved port for customize text decoration background.
    return null;
  }

  Paint getForeground(Style style) {
    // TODO: Reserved port for customize text decoration foreground.
    return null;
  }

  static RegExp commaRegExp = RegExp(r',');
  List<Shadow> getShadows(Style style) {
    List<Shadow> textShadows = [];
    if (style.contains('textShadow')) {
      String processedValue =
          WebColor.preprocessCSSPropertyWithRGBAColor(style['textShadow']);
      List<String> rawShadows = processedValue.split(commaRegExp);
      for (String rawShadow in rawShadows) {
        List<String> shadowDefinitions = rawShadow.trim().split(spaceRegExp);
        if (shadowDefinitions.length > 2) {
          double offsetX = Length(shadowDefinitions[0]).displayPortValue;
          double offsetY = Length(shadowDefinitions[1]).displayPortValue;
          double blurRadius = shadowDefinitions.length > 3
              ? Length(shadowDefinitions[2]).displayPortValue
              : 0.0;
          Color color = WebColor.generate(shadowDefinitions.last);
          if (color != null) {
            textShadows.add(Shadow(
              offset: Offset(offsetX, offsetY),
              blurRadius: blurRadius,
              color: color,
            ));
          }
        }
      }
    }
    return textShadows;
  }
}
