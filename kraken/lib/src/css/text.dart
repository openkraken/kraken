

/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'package:flutter/rendering.dart';
import 'package:kraken/css.dart';
import 'package:kraken/rendering.dart';
import 'package:kraken/dom.dart';

final RegExp _commaRegExp = RegExp(r'\s*,\s*');

const double DEFAULT_LETTER_SPACING = 0.0;
const double DEFAULT_WORD_SPACING = 0.0;

// CSS Text: https://drafts.csswg.org/css-text-3/
// CSS Text Decoration: https://drafts.csswg.org/css-text-decor-3/
mixin CSSTextMixin on RenderStyleBase {

  Color? _color = CSSColor.initial;
  Color? get color {
    return _color;
  }
  set color(Color? value) {
    if (_color == value) return;
    _color = value;
  }

  TextDecoration? _textDecorationLine;
  TextDecoration? get textDecorationLine {
    return _textDecorationLine;
  }
  set textDecorationLine(TextDecoration? value) {
    if (_textDecorationLine == value) return;
    _textDecorationLine = value;
  }

  Color? _textDecorationColor;
  Color? get textDecorationColor {
    return _textDecorationColor;
  }
  set textDecorationColor(Color? value) {
    if (_textDecorationColor == value) return;
    _textDecorationColor = value;
  }

  TextDecorationStyle? _textDecorationStyle;
  TextDecorationStyle? get textDecorationStyle {
    return _textDecorationStyle;
  }
  set textDecorationStyle(TextDecorationStyle? value) {
    if (_textDecorationStyle == value) return;
    _textDecorationStyle = value;
  }

  FontWeight? _fontWeight;
  FontWeight? get fontWeight {
    return _fontWeight;
  }
  set fontWeight(FontWeight? value) {
    if (_fontWeight == value) return;
    _fontWeight = value;
  }

  FontStyle? _fontStyle;
  FontStyle? get fontStyle {
    return _fontStyle;
  }
  set fontStyle(FontStyle? value) {
    if (_fontStyle == value) return;
    _fontStyle = value;
  }

  List<String>? _fontFamily;
  List<String>? get fontFamily {
    return _fontFamily;
  }
  set fontFamily(List<String>? value) {
    if (_fontFamily == value) return;
    _fontFamily = value;
  }

  double _fontSize = CSSText.DEFAULT_FONT_SIZE;
  double get fontSize {
    return _fontSize;
  }
  set fontSize(double value) {
    if (_fontSize == value) return;
    _fontSize = value;
  }

  double? _lineHeight;
  double? get lineHeight {
    return _lineHeight;
  }
  set lineHeight(double? value) {
    if (_lineHeight == value) return;
    _lineHeight = value;
    renderBoxModel!.markNeedsLayout();
  }

  double? _letterSpacing;
  double? get letterSpacing {
    return _letterSpacing;
  }
  set letterSpacing(double? value) {
    if (_letterSpacing == value) return;
    _letterSpacing = value;
  }

  double? _wordSpacing;
  double? get wordSpacing {
    return _wordSpacing;
  }
  set wordSpacing(double? value) {
    if (_wordSpacing == value) return;
    _wordSpacing = value;
  }

  List<Shadow>? _textShadow;
  List<Shadow>? get textShadow {
    return _textShadow;
  }
  set textShadow(List<Shadow>? value) {
    if (_textShadow == value) return;
    _textShadow = value;
  }

  WhiteSpace? _whiteSpace;
  WhiteSpace? get whiteSpace {
    return _whiteSpace;
  }
  set whiteSpace(WhiteSpace? value) {
    if (_whiteSpace == value) return;
    _whiteSpace = value;
  }

  static TextSpan createTextSpan(String text, Element? parent) {
    TextStyle? textStyle = parent != null ? getTextStyle(parent) : null;
    return TextSpan(
      text: text,
      style: textStyle,
    );
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
  static TextStyle getTextStyle(Element parent) {
    CSSStyleDeclaration? parentStyle = parent.style;
    RenderBoxModel? parentRenderBoxModel = parent.renderBoxModel;
    ElementManager elementManager = parent.elementManager!;
    double viewportWidth = elementManager.viewportWidth;
    double viewportHeight = elementManager.viewportHeight;
    Size viewportSize = Size(viewportWidth, viewportHeight);

    // Text may be created when parent renderObject not created, get it from style instead
    Color? color = parentRenderBoxModel != null ?
      parentRenderBoxModel.renderStyle!.color : CSSText.getTextColor(parent.style!);
    TextDecoration? textDecorationLine = parentRenderBoxModel != null ?
      parentRenderBoxModel.renderStyle!.textDecorationLine : CSSText.getTextDecorationLine(parent.style!);
    Color? textDecorationColor = parentRenderBoxModel != null ?
      parentRenderBoxModel.renderStyle!.textDecorationColor : CSSText.getTextDecorationColor(parent.style!);
    TextDecorationStyle? textDecorationStyle = parentRenderBoxModel != null ?
      parentRenderBoxModel.renderStyle!.textDecorationStyle : CSSText.getTextDecorationStyle(parent.style!);
    FontWeight? fontWeight = parentRenderBoxModel != null ?
      parentRenderBoxModel.renderStyle!.fontWeight : CSSText.getFontWeight(parent.style!);
    FontStyle? fontStyle = parentRenderBoxModel != null ?
      parentRenderBoxModel.renderStyle!.fontStyle : CSSText.getFontStyle(parent.style!);
    double fontSize = parentRenderBoxModel != null ?
      parentRenderBoxModel.renderStyle!.fontSize : CSSText.getFontSize(parent.style!, viewportSize);
    double? letterSpacing = parentRenderBoxModel != null ?
      parentRenderBoxModel.renderStyle!.letterSpacing : CSSText.getLetterSpacing(parent.style!, viewportSize);
    double? wordSpacing = parentRenderBoxModel != null ?
      parentRenderBoxModel.renderStyle!.wordSpacing : CSSText.getWordSpacing(parent.style!, viewportSize);
    List<Shadow>? textShadow = parentRenderBoxModel != null ?
      parentRenderBoxModel.renderStyle!.textShadow : CSSText.getTextShadow(parent.style!, viewportSize);

    return TextStyle(
      color: color,
      decoration: textDecorationLine,
      decorationColor: textDecorationColor,
      decorationStyle: textDecorationStyle,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      // To keep compatibility with font-family custimazition in test,
      // get style from constants if style not defined
      fontFamilyFallback: CSSText.getFontFamilyFallback(parent.style!),
      fontSize: fontSize,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      shadows: textShadow,
      textBaseline: CSSText.getTextBaseLine(parentStyle),
      package: CSSText.getFontPackage(parentStyle),
      locale: CSSText.getLocale(parentStyle),
      background: CSSText.getBackground(parentStyle),
      foreground: CSSText.getForeground(parentStyle),
    );
  }

  void updateTextStyle() {
    color = CSSText.getTextColor(style!);
    textDecorationLine = CSSText.getTextDecorationLine(style!);
    textDecorationColor = CSSText.getTextDecorationColor(style!);
    textDecorationStyle = CSSText.getTextDecorationStyle(style!);
    fontWeight = CSSText.getFontWeight(style!);
    fontStyle = CSSText.getFontStyle(style!);
    fontFamily = CSSText.getFontFamilyFallback(style!);
    fontSize = CSSText.getFontSize(style!, viewportSize);
    lineHeight = CSSText.getLineHeight(style!, viewportSize);
    letterSpacing = CSSText.getLetterSpacing(style!, viewportSize);
    wordSpacing = CSSText.getWordSpacing(style!, viewportSize);
    textShadow = CSSText.getTextShadow(style!, viewportSize);
    whiteSpace = CSSText.getWhiteSpace(style!);
  }
}

class CSSText {

  static bool isValidFontStyleValue(String value) {
    return value == 'normal' || value == 'italic' || value == 'oblique';
  }

  static bool isValidFontWeightValue(String value) {
    double? weight = CSSNumber.parseNumber(value);
    if (weight != null) {
      return weight >= 1 && weight <= 1000;
    } else {
      return value == 'normal' || value == 'bold' || value == 'lighter' || value == 'bolder';
    }
  }

  static bool isValidLineHeightValue(String value) {
    return CSSLength.isLength(value) || value == 'normal' || double.tryParse(value) != null;
  }

  static bool isValidTextTextDecorationLineValue(String value) {
    return value == 'underline' || value == 'overline' || value == 'line-through' || value == 'none';
  }

  static bool isValidTextTextDecorationStyleValue(String value) {
    return value == 'solid' || value == 'double' || value == 'dotted' || value == 'dashed' || value == 'wavy';
  }

  static double? getLineHeight(CSSStyleDeclaration style, Size viewportSize) {
    return parseLineHeight(style[LINE_HEIGHT], getFontSize(style, viewportSize), viewportSize);
  }

  static double? parseLineHeight(String value, double fontSize, Size viewportSize) {
    double? lineHeight;
    if (value.isNotEmpty) {
      if (CSSLength.isLength(value)) {
        double lineHeightValue = CSSLength.toDisplayPortValue(value, viewportSize)!;
        if (lineHeightValue > 0) {
          lineHeight = lineHeightValue;
        }
      } else {
        double? multipliedNumber = double.tryParse(value);
        if (multipliedNumber != null && multipliedNumber > 0) {
          lineHeight = fontSize * multipliedNumber;
        }
      }
    }
    return lineHeight;
  }

  static TextAlign getTextAlign(CSSStyleDeclaration style) {
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

  /// In CSS2.1, text-decoration determin the type of text decoration,
  /// but in CSS3, which is text-decoration-line.
  static TextDecoration getTextDecorationLine(CSSStyleDeclaration style) {
    switch (style[TEXT_DECORATION_LINE]) {
      case 'line-through':
        return TextDecoration.lineThrough;
      case 'overline':
        return TextDecoration.overline;
      case 'underline':
        return TextDecoration.underline;
      case 'none':
      default:
        return TextDecoration.none;
    }
  }

  static WhiteSpace getWhiteSpace(CSSStyleDeclaration style) {
    switch(style[WHITE_SPACE]) {
      case 'nowrap':
        return WhiteSpace.nowrap;
      case 'pre':
        return WhiteSpace.pre;
      case 'pre-wrap':
        return WhiteSpace.preWrap;
      case 'pre-line':
        return WhiteSpace.preLine;
      case 'break-spaces':
        return WhiteSpace.breakSpaces;
      case 'normal':
      default:
        return WhiteSpace.normal;
    }
  }

  static int? getLineClamp(CSSStyleDeclaration style) {
    return CSSLength.toInt(style[LINE_CLAMP]);
  }

  static TextOverflow getTextOverflow(CSSStyleDeclaration style) {
    List<CSSOverflowType> overflows = getOverflowTypes(style);
    WhiteSpace whiteSpace = getWhiteSpace(style);
    int? lineClamp = getLineClamp(style);

    // Set line-clamp to number makes text-overflow ellipsis which takes priority over text-overflow
    if (lineClamp != null && lineClamp > 0) {
      return TextOverflow.ellipsis;
    }

    //  To make text overflow its container you have to set overflowX hidden and white-space: nowrap.
    if (overflows[0] != CSSOverflowType.hidden || whiteSpace != WhiteSpace.nowrap) {
      return TextOverflow.visible;
    }

    TextOverflow textOverflow = TextOverflow.clip;
    if (style == null) {
      return textOverflow;
    }

    switch(style[TEXT_OVERFLOW]) {
      case 'ellipsis':
        return TextOverflow.ellipsis;
      case 'fade':
        return TextOverflow.fade;
      case 'clip':
      default:
        return TextOverflow.clip;
    }
  }


  static Color? getTextColor(CSSStyleDeclaration style) {
    if (style.contains(COLOR)) {
      return CSSColor.parseColor(style[COLOR]);
    } else {
      return CSSColor.initial;
    }
  }

  static Color? getTextDecorationColor(CSSStyleDeclaration style) {
    if (style.contains(TEXT_DECORATION_COLOR)) {
      return CSSColor.parseColor(style[TEXT_DECORATION_COLOR]);
    } else {
      return getTextColor(style); // Default is currentColor (style.color)
    }
  }

  static TextDecorationStyle getTextDecorationStyle(CSSStyleDeclaration style) {
    switch (style[TEXT_DECORATION_STYLE]) {
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

  static FontWeight parseFontWeight(String? fontWeight) {
    switch (fontWeight) {
      case 'lighter':
        return FontWeight.w200;
      case 'normal':
        return FontWeight.w400;
      case 'bold':
        return FontWeight.w700;
      case 'bolder':
        return FontWeight.w900;
      default:
        int? fontWeightValue;
        if (fontWeight != null) {
          fontWeightValue = int.tryParse(fontWeight);
        }
        // See: https://drafts.csswg.org/css-fonts-4/#font-weight-numeric-values
        // Only values greater than or equal to 1, and less than or equal to 1000, are valid,
        // and all other values are invalid.
        if (fontWeightValue == null || fontWeightValue > 1000 || fontWeightValue <= 0) {
          return FontWeight.w400;
        } else if (fontWeightValue >= 900) {
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
  }

  static FontWeight getFontWeight(CSSStyleDeclaration style) {
    return parseFontWeight(style[FONT_WEIGHT]);
  }

  static FontStyle getFontStyle(CSSStyleDeclaration style) {
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

  static TextBaseline getTextBaseLine(CSSStyleDeclaration? style) {
    return TextBaseline.alphabetic; // @TODO: impl vertical-align
  }

  static String? BUILTIN_FONT_PACKAGE;
  static String? getFontPackage(CSSStyleDeclaration? style) {
    return BUILTIN_FONT_PACKAGE;
  }

  static List<String>? DEFAULT_FONT_FAMILY_FALLBACK;
  static List<String>? getFontFamilyFallback(CSSStyleDeclaration style) {
    return parseFontFamilyFallback(style[FONT_FAMILY]);
  }

  static List<String>? parseFontFamilyFallback(String fontFamily) {
    if (fontFamily.isNotEmpty) {
      List<String> values = fontFamily.split(_commaRegExp);
      List<String> resolvedFamily = List.empty(growable: true);

      for (int i = 0; i < values.length; i++) {
        String familyName = values[i];
        // Remove wrapping quotes: "Gill Sans" -> Gill Sans
        if (familyName[0] == '"' || familyName[0] == '\'') {
          familyName = familyName.substring(1, familyName.length - 1);
        }

        switch (familyName) {
          case 'sans-serif':
          // Default sans-serif font in iOS (9 and newer)and iPadOS: Helvetica
          // Default sans-serif font in Android (4.0+): Roboto
            resolvedFamily.addAll(['Helvetica', 'Roboto', 'PingFang SC', 'PingFang TC']);
            break;
          case 'serif':
          // Default serif font in iOS and iPadOS: Times
          // Default serif font in Android (4.0+): Noto Serif
            resolvedFamily.addAll([
              'Times',
              'Times New Roman',
              'Noto Serif',
              'Songti SC',
              'Songti TC',
              'Hiragino Mincho ProN',
              'AppleMyungjo',
              'Apple SD Gothic Neo'
            ]);
            break;
          case 'monospace':
          // Default monospace font in iOS and iPadOS: Courier
            resolvedFamily.addAll(['Courier', 'Courier New', 'DroidSansMono', 'Monaco', 'Heiti SC', 'Heiti TC']);
            break;
          case 'cursive':
          // Default cursive font in iOS and iPadOS: Snell Roundhand
            resolvedFamily.addAll(['Snell Roundhand', 'Apple Chancery', 'DancingScript', 'Comic Sans MS']);
            break;
          case 'fantasy':
          // Default fantasy font in iOS and iPadOS:
          // Default fantasy font in MacOS: Papyrus
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

  static double DEFAULT_FONT_SIZE = 16.0;
  static double getFontSize(CSSStyleDeclaration style, Size viewportSize) {
    if (style.contains(FONT_SIZE)) {
      return CSSLength.toDisplayPortValue(style[FONT_SIZE], viewportSize) ?? DEFAULT_FONT_SIZE;
    } else {
      return DEFAULT_FONT_SIZE;
    }
  }

  static double getLetterSpacing(CSSStyleDeclaration style, Size viewportSize) {
    if (style.contains(LETTER_SPACING)) {
      String _letterSpacing = style[LETTER_SPACING];
      if (_letterSpacing == NORMAL) return DEFAULT_LETTER_SPACING;

      return CSSLength.toDisplayPortValue(_letterSpacing, viewportSize) ?? DEFAULT_LETTER_SPACING;
    } else {
      return DEFAULT_LETTER_SPACING;
    }
  }

  static double getWordSpacing(CSSStyleDeclaration style, Size viewportSize) {
    if (style.contains(WORD_SPACING)) {
      String _wordSpacing = style[WORD_SPACING];
      if (_wordSpacing == NORMAL) return DEFAULT_WORD_SPACING;

      return CSSLength.toDisplayPortValue(_wordSpacing, viewportSize) ?? DEFAULT_WORD_SPACING;
    } else {
      return DEFAULT_WORD_SPACING;
    }
  }

  static Locale? getLocale(CSSStyleDeclaration? style) {
    // TODO: impl locale for text decoration.
    return null;
  }

  static Paint? getBackground(CSSStyleDeclaration? style) {
    // TODO: Reserved port for customize text decoration background.
    return null;
  }

  static Paint? getForeground(CSSStyleDeclaration? style) {
    // TODO: Reserved port for customize text decoration foreground.
    return null;
  }

  static List<Shadow> getTextShadow(CSSStyleDeclaration style, Size viewportSize) {
    List<Shadow> textShadows = [];
    if (style.contains(TEXT_SHADOW)) {
      var shadows = CSSStyleProperty.getShadowValues(style[TEXT_SHADOW]);
      if (shadows != null) {
        for (var shadowDefinitions in shadows) {
          // Specifies the color of the shadow. If the color is absent, it defaults to currentColor.
          Color? color = CSSColor.parseColor(shadowDefinitions[0] ?? style.getCurrentColor());
          double offsetX = CSSLength.toDisplayPortValue(shadowDefinitions[1], viewportSize) ?? 0;
          double offsetY = CSSLength.toDisplayPortValue(shadowDefinitions[2], viewportSize) ?? 0;
          double blurRadius = CSSLength.toDisplayPortValue(shadowDefinitions[3], viewportSize) ?? 0;

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
