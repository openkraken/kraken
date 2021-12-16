/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'package:flutter/rendering.dart';
import 'package:kraken/css.dart';
import 'package:kraken/rendering.dart';

final RegExp _commaRegExp = RegExp(r'\s*,\s*');

// CSS Text: https://drafts.csswg.org/css-text-3/
// CSS Text Decoration: https://drafts.csswg.org/css-text-decor-3/
// CSS Box Alignment: https://drafts.csswg.org/css-align/
mixin CSSTextMixin on RenderStyle {
  bool get hasColor => _color != null;

  @override
  Color get currentColor => color;

  Color? _color;

  @override
  Color get color {
    // Get style from self or closest parent if specified style property is not set
    // due to style inheritance.
    if (_color == null && parent != null) {
      return parent!.color;
    }

    // The root element has no color, and the color is initial.
    return _color ?? CSSColor.initial;
  }

  set color(Color? value) {
    if (_color == value) return;
    _color = value;
    // Update all the children text with specified style property not set due to style inheritance.
    _markChildrenNeedsLayout(renderBoxModel!, COLOR);
  }

  // Current not update the dependent property relative to the color.
  final Map<String, bool> _colorRelativeProperties = {};

  @override
  void addColorRelativeProperty(String propertyName) {
    _colorRelativeProperties[propertyName] = true;
  }

  void updateColorRelativeProperty() {
    if (_colorRelativeProperties.isEmpty) return;
    _colorRelativeProperties.forEach((String propertyName, _) {
      // TODO: use css color abstraction avoid re-parse the property string.
      target.setRenderStyle(propertyName, target.style.getPropertyValue(propertyName));
    });
  }

  TextDecoration? _textDecorationLine;
  TextDecoration get textDecorationLine => _textDecorationLine ?? TextDecoration.none;
  set textDecorationLine(TextDecoration? value) {
    if (_textDecorationLine == value) return;
    _textDecorationLine = value;
    // Non inheritable style change should only update text node in direct children.
    renderBoxModel?.markNeedsLayout();
  }

  Color? _textDecorationColor;
  Color? get textDecorationColor {
    return _textDecorationColor;
  }
  set textDecorationColor(Color? value) {
    if (_textDecorationColor == value) return;
    _textDecorationColor = value;
    // Non inheritable style change should only update text node in direct children.
    _markTextNeedsLayout();
  }

  TextDecorationStyle? _textDecorationStyle;
  TextDecorationStyle? get textDecorationStyle {
    return _textDecorationStyle;
  }
  set textDecorationStyle(TextDecorationStyle? value) {
    if (_textDecorationStyle == value) return;
    _textDecorationStyle = value;
    // Non inheritable style change should only update text node in direct children.
    _markTextNeedsLayout();
  }

  FontWeight? _fontWeight;
  @override
  FontWeight get fontWeight {
    // Get style from self or closest parent if specified style property is not set
    // due to style inheritance.
    if (_fontWeight == null && parent != null) {
      return parent!.fontWeight;
    }

    // The root element has no fontWeight, and the fontWeight is initial.
    return _fontWeight ?? FontWeight.w400;
  }
  set fontWeight(FontWeight? value) {
    if (_fontWeight == value) return;
    _fontWeight = value;
    // Update all the children text with specified style property not set due to style inheritance.
    _markChildrenNeedsLayout(renderBoxModel!, FONT_WEIGHT);
  }

  FontStyle? _fontStyle;

  @override
  FontStyle get fontStyle {
    // Get style from self or closest parent if specified style property is not set
    // due to style inheritance.
    if (_fontStyle == null && parent != null) {
      return parent!.fontStyle;
    }

    // The root element has no fontWeight, and the fontWeight is initial.
    return _fontStyle ?? FontStyle.normal;
  }
  set fontStyle(FontStyle? value) {
    if (_fontStyle == value) return;
    _fontStyle = value;
    // Update all the children text with specified style property not set due to style inheritance.
    _markChildrenNeedsLayout(renderBoxModel!, FONT_STYLE);
  }

  List<String>? _fontFamily;

  @override
  List<String>? get fontFamily {
    // Get style from self or closest parent if specified style property is not set
    // due to style inheritance.
    if (_fontFamily == null && parent != null) {
      return parent!.fontFamily;
    }
    return _fontFamily ?? CSSText.DEFAULT_FONT_FAMILY_FALLBACK;
  }
  set fontFamily(List<String>? value) {
    if (_fontFamily == value) return;
    _fontFamily = value;
    // Update all the children text with specified style property not set due to style inheritance.
    _markChildrenNeedsLayout(renderBoxModel!, FONT_FAMILY);
  }

  bool get hasFontSize => _fontSize != null;

  CSSLengthValue? _fontSize;

  @override
  CSSLengthValue get fontSize {
    // Get style from self or closest parent if specified style property is not set
    // due to style inheritance.
    if (_fontSize == null && parent != null) {
      return parent!.fontSize;
    }
    return _fontSize ?? CSSText.DEFAULT_FONT_SIZE;
  }
  // Update font-size may affect following style:
  // 1. Nested children text size due to style inheritance.
  // 2. Em unit: style of own element with em unit and nested children with no font-size set due to style inheritance.
  // 3. Rem unit: nested children with rem set.
  set fontSize(CSSLengthValue? value) {
    if (_fontSize == value) return;
    _fontSize = value;
   // Update all the children text with specified style property not set due to style inheritance.
    _markChildrenNeedsLayout(renderBoxModel!, FONT_SIZE);
  }

  // Current not update the dependent property relative to the font-size.
  final Map<String, bool> _fontRelativeProperties = {};
  final Map<String, bool> _rootFontRelativeProperties = {};

  @override
  void addFontRelativeProperty(String propertyName) {
    _fontRelativeProperties[propertyName] = true;
  }

  void updateFontRelativeLength() {
    if (_fontRelativeProperties.isEmpty) return;
    renderBoxModel?.markNeedsLayout();
  }

  @override
  void addRootFontRelativeProperty(String propertyName) {
    _rootFontRelativeProperties[propertyName] = true;
  }

  void updateRootFontRelativeLength() {
    if (_rootFontRelativeProperties.isEmpty) return;
    renderBoxModel?.markNeedsLayout();
  }

  CSSLengthValue? _lineHeight;

  @override
  CSSLengthValue get lineHeight {
    if (_lineHeight == null && parent != null) {
      return parent!.lineHeight;
    }

    return _lineHeight ?? CSSText.DEFAULT_LINE_HEIGHT;
  }

  set lineHeight(CSSLengthValue? value) {
    if (_lineHeight == value) return;
    _lineHeight = value;
    // Update all the children layout and text with specified style property not set due to style inheritance.
    _markNestChildrenTextAndLayoutNeedsLayout(renderBoxModel!, LINE_HEIGHT);
  }

  CSSLengthValue? _letterSpacing;

  @override
  CSSLengthValue? get letterSpacing {
    // Get style from self or closest parent if specified style property is not set
    // due to style inheritance.
    if (_letterSpacing == null && parent != null) {
      return parent!.letterSpacing;
    }
    return _letterSpacing;
  }
  set letterSpacing(CSSLengthValue? value) {
    if (_letterSpacing == value) return;
    _letterSpacing = value;
    // Update all the children text with specified style property not set due to style inheritance.
    _markChildrenNeedsLayout(renderBoxModel!, LETTER_SPACING);
  }

  CSSLengthValue? _wordSpacing;

  @override
  CSSLengthValue? get wordSpacing {
    // Get style from self or closest parent if specified style property is not set
    // due to style inheritance.
    if (_wordSpacing == null && parent != null) {
      return parent!.wordSpacing;
    }
    return _wordSpacing;
  }
  set wordSpacing(CSSLengthValue? value) {
    if (_wordSpacing == value) return;
    _wordSpacing = value;
    // Update all the children text with specified style property not set due to style inheritance.
    _markChildrenNeedsLayout(renderBoxModel!, WORD_SPACING);
  }

  List<Shadow>? _textShadow;

  @override
  List<Shadow>? get textShadow {
    // Get style from self or closest parent if specified style property is not set
    // due to style inheritance.
    if (_textShadow == null && parent != null) {
      return parent!.textShadow;
    }
    return _textShadow;
  }
  set textShadow(List<Shadow>? value) {
    if (_textShadow == value) return;
    _textShadow = value;
    // Update all the children text with specified style property not set due to style inheritance.
     _markChildrenNeedsLayout(renderBoxModel!, TEXT_SHADOW);
  }

  WhiteSpace? _whiteSpace;

  @override
  WhiteSpace get whiteSpace {
    // Get style from self or closest parent if specified style property is not set
    // due to style inheritance.
    if (_whiteSpace == null && parent != null) {
      return parent!.whiteSpace;
    }
    return _whiteSpace ?? WhiteSpace.normal;
  }
  set whiteSpace(WhiteSpace? value) {
    if (_whiteSpace == value) return;
    _whiteSpace = value;
    // Update all the children layout and text with specified style property not set due to style inheritance.
     _markNestChildrenTextAndLayoutNeedsLayout(renderBoxModel!, WHITE_SPACE);
  }

  TextOverflow _textOverflow = TextOverflow.clip;

  @override
  TextOverflow get textOverflow {
    return _textOverflow;
  }
  set textOverflow(TextOverflow value) {
    if (_textOverflow == value) return;
    _textOverflow = value;
    // Non inheritable style change should only update text node in direct children.
    _markTextNeedsLayout();
  }

  int? _lineClamp;

  @override
  int? get lineClamp {
    return _lineClamp;
  }
  set lineClamp(int? value) {
    if (_lineClamp == value) return;
    _lineClamp = value;
    // Non inheritable style change should only update text node in direct children.
    _markTextNeedsLayout();
  }

  TextAlign? _textAlign;

  @override
  TextAlign get textAlign {
    // Get style from self or closest parent if specified style property is not set
    // due to style inheritance.
    if (_textAlign == null && parent != null) {
      return parent!.textAlign;
    }
    return _textAlign ?? TextAlign.start;
  }
  set textAlign(TextAlign? value) {
    if (_textAlign == value) return;
    _textAlign = value;
    // Update all the children flow layout with specified style property not set due to style inheritance.
    _markNestFlowLayoutNeedsLayout(renderBoxModel, TEXT_ALIGN);
  }

  // Mark flow layout and all the children flow layout with specified style property not set needs layout.
  void _markNestFlowLayoutNeedsLayout(RenderBoxModel? renderBoxModel, String styleProperty) {
    if (renderBoxModel is RenderFlowLayout) {
      renderBoxModel.markNeedsLayout();
      renderBoxModel.visitChildren((RenderObject child) {
        if (child is RenderFlowLayout) {
          // Only need to layout when the specified style property is not set.
          if (child.renderStyle.target.style[styleProperty].isEmpty) {
            _markNestFlowLayoutNeedsLayout(child, styleProperty);
          }
        }
      });
    }
  }

  // Mark all nested layout and text children as needs layout when properties that will affect both
  // text and layout (line-height, white-space) changes.
  void _markNestChildrenTextAndLayoutNeedsLayout(RenderBoxModel renderBoxModel, String styleProperty) {
    if (renderBoxModel is RenderLayoutBox) {
      renderBoxModel.markNeedsLayout();
      renderBoxModel.visitChildren((RenderObject child) {
        if (child is RenderLayoutBox) {
          // Only need to layout when the specified style property is not set.
          if (child.renderStyle.target.style[styleProperty].isEmpty) {
            _markNestChildrenTextAndLayoutNeedsLayout(child, styleProperty);
          }
        } else if (child is RenderTextBox) {
          KrakenRenderParagraph renderParagraph = child.child as KrakenRenderParagraph;
          renderParagraph.markNeedsLayout();
        }
      });
    }
  }

  // Mark direct children text as needs layout.
  // None inheritable style change should only loop direct children to update text node with specified
  // style property not set in its parent.
  void _markTextNeedsLayout() {
    renderBoxModel!.visitChildren((RenderObject child) {
      if (child is RenderTextBox) {
        KrakenRenderParagraph renderParagraph = child.child as KrakenRenderParagraph;
        renderParagraph.markNeedsLayout();
      }
    });
  }

  // Mark nested children text as needs layout.
  // Inheritable style change should loop nest children to update text node with specified style property
  // not set in its parent.
  void _markChildrenNeedsLayout(RenderBoxModel renderBoxModel, String styleProperty) {
    renderBoxModel.visitChildren((RenderObject child) {
      if (child is RenderBoxModel) {
        // Only need to update child text when style property is not set.
        if (child.renderStyle.target.style[styleProperty].isEmpty) {
          _markChildrenNeedsLayout(child, styleProperty);
        }
      } else if (child is RenderTextBox) {
        KrakenRenderParagraph renderParagraph = child.child as KrakenRenderParagraph;
        renderParagraph.markNeedsLayout();
      }
    });
  }

  static TextAlign? resolveTextAlign(String value) {
    TextAlign? alignment;

    switch (value) {
      case 'end':
      case 'right':
        alignment = TextAlign.end;
        break;
      case 'center':
        alignment = TextAlign.center;
        break;
      case 'justify':
        alignment = TextAlign.justify;
        break;
      case 'start':
      case 'left':
        alignment = TextAlign.start;
      // Like inherit, which is the same with parent element.
      // Not impl it due to performance consideration.
      // case 'match-parent':
    }

    return alignment;
  }

  static TextSpan createTextSpan(String? text, CSSRenderStyle renderStyle) {
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
    TextStyle textStyle = TextStyle(
      color: renderStyle.color,
      decoration: renderStyle.textDecorationLine,
      decorationColor: renderStyle.textDecorationColor,
      decorationStyle: renderStyle.textDecorationStyle,
      fontWeight: renderStyle.fontWeight,
      fontStyle: renderStyle.fontStyle,
      fontFamilyFallback: renderStyle.fontFamily,
      fontSize: renderStyle.fontSize.computedValue,
      letterSpacing: renderStyle.letterSpacing?.computedValue,
      wordSpacing: renderStyle.wordSpacing?.computedValue,
      shadows: renderStyle.textShadow,
      textBaseline: CSSText.getTextBaseLine(),
      package: CSSText.getFontPackage(),
      locale: CSSText.getLocale(),
      background: CSSText.getBackground(),
      foreground: CSSText.getForeground(),
    );
    return TextSpan(
      text: text,
      style: textStyle,
    );
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
    return CSSLength.isNonNegativeLength(value) || CSSPercentage.isNonNegativePercentage(value) ||
      value == 'normal' || double.tryParse(value) != null;
  }

  static bool isValidTextTextDecorationLineValue(String value) {
    return value == 'underline' || value == 'overline' || value == 'line-through' || value == 'none';
  }

  static bool isValidTextTextDecorationStyleValue(String value) {
    return value == 'solid' || value == 'double' || value == 'dotted' || value == 'dashed' || value == 'wavy';
  }

  static CSSLengthValue DEFAULT_LINE_HEIGHT = CSSLengthValue.normal;
  static CSSLengthValue? resolveLineHeight(String value, RenderStyle renderStyle, String propertyName) {
    if (value.isNotEmpty) {
      if (CSSLength.isNonNegativeLength(value) || CSSPercentage.isNonNegativePercentage(value)) {
        CSSLengthValue lineHeight = CSSLength.parseLength(value, renderStyle, propertyName);
        // Line-height 0 and negative value is considered invalid.
        if (lineHeight.computedValue != double.infinity && lineHeight.computedValue > 0) {
          return lineHeight;
        }
      } else if (value == NORMAL) {
        return CSSLengthValue.normal;
      } else if (CSSNumber.isNumber(value)){
        double? multipliedNumber = double.tryParse(value);
        if (multipliedNumber != null) {
          return CSSLengthValue(multipliedNumber, CSSLengthType.EM, renderStyle, propertyName);
        }
      }
    }
  }

  /// In CSS2.1, text-decoration determin the type of text decoration,
  /// but in CSS3, which is text-decoration-line.
  static TextDecoration resolveTextDecorationLine(String present) {
    switch (present) {
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

  static WhiteSpace resolveWhiteSpace(String value) {
    switch(value) {
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

  static int? parseLineClamp(String value) {
    return CSSLength.toInt(value);
  }

  static TextOverflow resolveTextOverflow(String value) {
    // Always get text overflow from style cause it is affected by white-space and overflow.
    switch(value) {
      case 'ellipsis':
        return TextOverflow.ellipsis;
      case 'fade':
        return TextOverflow.fade;
      case 'clip':
      default:
        return TextOverflow.clip;
    }
  }

  static TextDecorationStyle resolveTextDecorationStyle(String present) {
    switch (present) {
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

  static FontWeight resolveFontWeight(String? fontWeight) {
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

  static FontStyle resolveFontStyle(String? fontStyle) {
    switch (fontStyle) {
      case 'oblique':
      case 'italic':
        return FontStyle.italic;
      case 'normal':
      default:
        return FontStyle.normal;
    }
  }

  static TextBaseline getTextBaseLine() {
    return TextBaseline.alphabetic; // @TODO: impl vertical-align
  }

  static String? BUILTIN_FONT_PACKAGE;
  static String? getFontPackage() {
    return BUILTIN_FONT_PACKAGE;
  }

  static List<String>? DEFAULT_FONT_FAMILY_FALLBACK;

  static List<String> resolveFontFamilyFallback(String? fontFamily) {
    fontFamily = fontFamily ?? 'sans-serif';
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

    // Only for internal use.
    if (resolvedFamily.isEmpty && CSSText.DEFAULT_FONT_FAMILY_FALLBACK != null) {
      return CSSText.DEFAULT_FONT_FAMILY_FALLBACK!;
    }
    return resolvedFamily;
  }

  static CSSLengthValue DEFAULT_FONT_SIZE = CSSLengthValue(16.0, CSSLengthType.PX);

  static CSSLengthValue resolveSpacing(String spacing, RenderStyle renderStyle, String property) {
    if (spacing == NORMAL) return CSSLengthValue.zero;

    return CSSLength.parseLength(spacing, renderStyle, property);
  }

  static Locale? getLocale() {
    // TODO: impl locale for text decoration.
    return null;
  }

  static Paint? getBackground() {
    // TODO: Reserved port for customize text decoration background.
    return null;
  }

  static Paint? getForeground() {
    // TODO: Reserved port for customize text decoration foreground.
    return null;
  }

  static List<Shadow> resolveTextShadow(String value, RenderStyle renderStyle, String propertyName) {
    List<Shadow> textShadows = [];

    var shadows = CSSStyleProperty.getShadowValues(value);
    if (shadows != null) {
      for (var shadowDefinitions in shadows) {
        String shadowColor = shadowDefinitions[0] ?? CURRENT_COLOR;
        // Specifies the color of the shadow. If the color is absent, it defaults to currentColor.
        Color? color = CSSColor.resolveColor(shadowColor, renderStyle, propertyName);
        double offsetX = CSSLength.parseLength(shadowDefinitions[1]!, renderStyle, propertyName).computedValue;
        double offsetY = CSSLength.parseLength(shadowDefinitions[2]!, renderStyle, propertyName).computedValue;
        String? blurRadiusStr = shadowDefinitions[3];
        // Blur-radius defaults to 0 if not specified.
        double blurRadius = blurRadiusStr != null ?
          CSSLength.parseLength(blurRadiusStr, renderStyle, propertyName).computedValue : 0;
        if (color != null) {
          textShadows.add(Shadow(
            offset: Offset(offsetX, offsetY),
            blurRadius: blurRadius,
            color: color,
          ));
        }
      }
    }

    return textShadows;
  }

}
