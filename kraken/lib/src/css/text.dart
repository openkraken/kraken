

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
    // Get style from self or closest parent if specified style property is not set
    // due to style inheritance.
    RenderBoxModel? renderBox = renderBoxModel!.getSelfParentWithSpecifiedStyle(COLOR);
    if (renderBox != null) {
      return renderBox.renderStyle._color;
    }
    return _color;
  }

  set color(Color? value) {
    if (_color == value) return;
    _color = value;
    // Update all the children text with specified style property not set due to style inheritance.
    _updateNestChildrenText(renderBoxModel!, COLOR);
  }

  TextDecoration? _textDecorationLine;
  TextDecoration? get textDecorationLine {
    return _textDecorationLine;
  }
  set textDecorationLine(TextDecoration? value) {
    if (_textDecorationLine == value) return;
    _textDecorationLine = value;
    // Non inheritable style change should only update text node in direct children.
    _updateChildrenText(renderBoxModel!, TEXT_DECORATION_LINE);
  }

  Color? _textDecorationColor;
  Color? get textDecorationColor {
    return _textDecorationColor;
  }
  set textDecorationColor(Color? value) {
    if (_textDecorationColor == value) return;
    _textDecorationColor = value;
    // Non inheritable style change should only update text node in direct children.
    _updateChildrenText(renderBoxModel!, TEXT_DECORATION_COLOR);
  }

  TextDecorationStyle? _textDecorationStyle;
  TextDecorationStyle? get textDecorationStyle {
    return _textDecorationStyle;
  }
  set textDecorationStyle(TextDecorationStyle? value) {
    if (_textDecorationStyle == value) return;
    _textDecorationStyle = value;
    // Non inheritable style change should only update text node in direct children.
    _updateChildrenText(renderBoxModel!, TEXT_DECORATION_STYLE);
  }

  FontWeight? _fontWeight;
  FontWeight? get fontWeight {
    // Get style from self or closest parent if specified style property is not set
    // due to style inheritance.
    RenderBoxModel? renderBox = renderBoxModel!.getSelfParentWithSpecifiedStyle(FONT_WEIGHT);
    if (renderBox != null) {
      return renderBox.renderStyle._fontWeight;
    }
    return _fontWeight;
  }
  set fontWeight(FontWeight? value) {
    if (_fontWeight == value) return;
    _fontWeight = value;
    // Update all the children text with specified style property not set due to style inheritance.
    _updateNestChildrenText(renderBoxModel!, FONT_WEIGHT);
  }

  FontStyle? _fontStyle;
  FontStyle? get fontStyle {
    // Get style from self or closest parent if specified style property is not set
    // due to style inheritance.
    RenderBoxModel? renderBox = renderBoxModel!.getSelfParentWithSpecifiedStyle(FONT_STYLE);
    if (renderBox != null) {
      return renderBox.renderStyle._fontStyle;
    }
    return _fontStyle;
  }
  set fontStyle(FontStyle? value) {
    if (_fontStyle == value) return;
    _fontStyle = value;
    // Update all the children text with specified style property not set due to style inheritance.
    _updateNestChildrenText(renderBoxModel!, FONT_STYLE);
  }

  List<String>? _fontFamily;
  List<String>? get fontFamily {
    if (CSSText.DEFAULT_FONT_FAMILY_FALLBACK != null) {
      return CSSText.getFontFamilyFallback(renderBoxModel!.renderStyle.style);
    }
    // Get style from self or closest parent if specified style property is not set
    // due to style inheritance.
    RenderBoxModel? renderBox = renderBoxModel!.getSelfParentWithSpecifiedStyle(FONT_FAMILY);
    if (renderBox != null) {
      return renderBox.renderStyle._fontFamily;
    }
    return _fontFamily;
  }
  set fontFamily(List<String>? value) {
    if (_fontFamily == value) return;
    _fontFamily = value;
    // Update all the children text with specified style property not set due to style inheritance.
    _updateNestChildrenText(renderBoxModel!, FONT_FAMILY);
  }

  double _fontSize = CSSText.DEFAULT_FONT_SIZE;
  double get fontSize {
    // Get style from self or closest parent if specified style property is not set
    // due to style inheritance.
    if (renderBoxModel != null) {
      RenderBoxModel? renderBox = renderBoxModel!.getSelfParentWithSpecifiedStyle(FONT_SIZE);
      if (renderBox != null) {
        return renderBox.renderStyle._fontSize;
      }
    }
    return _fontSize;
  }
  set fontSize(double value) {
    if (_fontSize == value) return;
    _fontSize = value;
    // Need update all em unit style of own element when font size changed.
    style.applyEmProperties();

    // Update all the children text with specified style property not set due to style inheritance.
    _updateChildrenFontSize(renderBoxModel!, renderBoxModel!.isDocumentRootBox);
  }

  double? _lineHeight;
  double? get lineHeight {
    // Get style from self or closest parent if specified style property is not set
    // due to style inheritance.
    RenderBoxModel? renderBox = renderBoxModel!.getSelfParentWithSpecifiedStyle(LINE_HEIGHT);
    if (renderBox != null) {
      return renderBox.renderStyle._lineHeight;
    }
    return _lineHeight;
  }
  set lineHeight(double? value) {
    if (_lineHeight == value) return;
    _lineHeight = value;
    // Update all the children layout and text with specified style property not set due to style inheritance.
    _markChildrenNeedsLayoutByLineHeight(renderBoxModel!, LINE_HEIGHT);
  }

  double? _letterSpacing;
  double? get letterSpacing {
    // Get style from self or closest parent if specified style property is not set
    // due to style inheritance.
    RenderBoxModel? renderBox = renderBoxModel!.getSelfParentWithSpecifiedStyle(LETTER_SPACING);
    if (renderBox != null) {
      return renderBox.renderStyle._letterSpacing;
    }
    return _letterSpacing;
  }
  set letterSpacing(double? value) {
    if (_letterSpacing == value) return;
    _letterSpacing = value;
    // Update all the children text with specified style property not set due to style inheritance.
    _updateNestChildrenText(renderBoxModel!, LETTER_SPACING);
  }

  double? _wordSpacing;
  double? get wordSpacing {
    // Get style from self or closest parent if specified style property is not set
    // due to style inheritance.
    RenderBoxModel? renderBox = renderBoxModel!.getSelfParentWithSpecifiedStyle(WORD_SPACING);
    if (renderBox != null) {
      return renderBox.renderStyle._wordSpacing;
    }
    return _wordSpacing;
  }
  set wordSpacing(double? value) {
    if (_wordSpacing == value) return;
    _wordSpacing = value;
    // Update all the children text with specified style property not set due to style inheritance.
    _updateNestChildrenText(renderBoxModel!, WORD_SPACING);
  }

  List<Shadow>? _textShadow;
  List<Shadow>? get textShadow {
    // Get style from self or closest parent if specified style property is not set
    // due to style inheritance.
    RenderBoxModel? renderBox = renderBoxModel!.getSelfParentWithSpecifiedStyle(TEXT_SHADOW);
    if (renderBox != null) {
      return renderBox.renderStyle._textShadow;
    }
    return _textShadow;
  }
  set textShadow(List<Shadow>? value) {
    if (_textShadow == value) return;
    _textShadow = value;
    // Update all the children text with specified style property not set due to style inheritance.
    _updateNestChildrenText(renderBoxModel!, TEXT_SHADOW);
  }

  WhiteSpace? _whiteSpace = WhiteSpace.normal;
  WhiteSpace? get whiteSpace {
    // Get style from self or closest parent if specified style property is not set
    // due to style inheritance.
    RenderBoxModel? renderBox = renderBoxModel!.getSelfParentWithSpecifiedStyle(WHITE_SPACE);
    if (renderBox != null) {
      return renderBox.renderStyle._whiteSpace;
    }
    return _whiteSpace;
  }
  set whiteSpace(WhiteSpace? value) {
    if (_whiteSpace == value) return;
    _whiteSpace = value;
    // Update all the children layout and text with specified style property not set due to style inheritance.
    _markChildrenNeedsLayoutByWhiteSpace(renderBoxModel!, WHITE_SPACE);
  }

  TextOverflow _textOverflow = TextOverflow.clip;
  TextOverflow get textOverflow {
    return _textOverflow;
  }
  set textOverflow(TextOverflow value) {
    if (_textOverflow == value) return;
    _textOverflow = value;
    // Non inheritable style change should only update text node in direct children.
    _updateChildrenText(renderBoxModel!, TEXT_OVERFLOW);
  }

  int? _lineClamp;
  int? get lineClamp {
    return _lineClamp;
  }
  set lineClamp(int? value) {
    if (_lineClamp == value) return;
    _lineClamp = value;
    // Non inheritable style change should only update text node in direct children.
    _updateChildrenText(renderBoxModel!, LINE_CLAMP);
  }

  /// Mark all layout and text children as needs layout when line-height changed.
  void _markChildrenNeedsLayoutByLineHeight(RenderBoxModel renderBoxModel, String styleProperty) {
    if (renderBoxModel is RenderLayoutBox) {
      // Line-height works both on text and layout.
      renderBoxModel.markNeedsLayout();
      renderBoxModel.visitChildren((RenderObject child) {
        if (child is RenderLayoutBox) {
          // Only need to layout when the specified style property is not set.
          if (child.renderStyle.style[styleProperty].isEmpty) {
            _markChildrenNeedsLayoutByLineHeight(child, styleProperty);
          }
        } else if (child is RenderTextBox) {
          // Update line height of paragraph.
          KrakenRenderParagraph renderParagraph = child.child as KrakenRenderParagraph;
          renderParagraph.lineHeight = renderBoxModel.renderStyle.lineHeight;
          renderParagraph.markNeedsLayout();
        }
      });
    }
  }

  /// Mark all layout and text children as needs layout when white-space changed.
  void _markChildrenNeedsLayoutByWhiteSpace(RenderBoxModel renderBoxModel, String styleProperty) {
    if (renderBoxModel is RenderLayoutBox) {
      // White-space works both on text and layout.
      renderBoxModel.markNeedsLayout();
      renderBoxModel.visitChildren((RenderObject child) {
        if (child is RenderLayoutBox) {
          // Only need to layout when the specified style property is not set.
          if (child.renderStyle.style[styleProperty].isEmpty) {
            _markChildrenNeedsLayoutByWhiteSpace(child, styleProperty);
          }
        } else if (child is RenderTextBox) {
          RenderBoxModel parentRenderBoxModel = child.parent as RenderBoxModel;
          RenderStyle parentRenderStyle = parentRenderBoxModel.renderStyle;
          child.whiteSpace = parentRenderStyle.whiteSpace;
          // White-space change will affect text-overflow.
          child.overflow = CSSText.getTextOverflow(renderStyle: parentRenderStyle);
        }
      });
    }
  }

  /// None inheritable style change should only loop direct children to update text node with specified
  /// style property not set in its parent.
  void _updateChildrenText(RenderBoxModel renderBoxModel, String styleProperty) {
    renderBoxModel.visitChildren((RenderObject child) {
      if (child is RenderTextBox) {
        // Need to recreate text span cause text style can not be set alone.
        RenderBoxModel parentRenderBoxModel = child.parent as RenderBoxModel;
        KrakenRenderParagraph renderParagraph = child.child as KrakenRenderParagraph;
        String? text = renderParagraph.text.text;
        child.text = CSSTextMixin.createTextSpan(text, parentRenderBoxModel.renderStyle);
        // Update text box property which will then update paragraph and mark it needs layout.
        if (styleProperty == TEXT_OVERFLOW) {
          // Always get text overflow from style cause it is affected by white-space and overflow.
          child.overflow = CSSText.getTextOverflow(renderStyle: parentRenderBoxModel.renderStyle);
        } else if (styleProperty == LINE_CLAMP) {
          child.maxLines = parentRenderBoxModel.renderStyle.lineClamp;
          // Text-overflow needs to change when line-clamp has changed.
          child.overflow = CSSText.getTextOverflow(renderStyle: parentRenderBoxModel.renderStyle);
        }
      }
    });
  }

  /// Inheritable style change should loop nest children to update text node with specified style property
  /// not set in its parent.
  void _updateNestChildrenText(RenderBoxModel renderBoxModel, String styleProperty) {
    renderBoxModel.visitChildren((RenderObject child) {
      if (child is RenderBoxModel) {
        // Only need to update child text when style property is not set.
        if (child.renderStyle.style[styleProperty].isEmpty) {
          _updateNestChildrenText(child, styleProperty);
          // Need update all em unit style of child when its font size is inherited.
          if (styleProperty == FONT_SIZE) {
            child.renderStyle.style.applyEmProperties();
          }
        }
      } else if (child is RenderTextBox) {
        // Need to recreate text span cause text style can not be set alone.
        RenderBoxModel parentRenderBoxModel = child.parent as RenderBoxModel;
        KrakenRenderParagraph renderParagraph = child.child as KrakenRenderParagraph;
        String? text = renderParagraph.text.text;
        child.text = CSSTextMixin.createTextSpan(text, parentRenderBoxModel.renderStyle);
      }
    });
  }

  // Update font-size may affect following style:
  // 1. Nested children text size due to style inheritance.
  // 2. Em unit: style of own element with em unit and nested children with no font-size set due to style inheritance.
  // 3. Rem unit: nested children with rem set.
  void _updateChildrenFontSize(RenderBoxModel renderBoxModel, bool isRootFontSizeUpdated, {int depth = 1}) {
    renderBoxModel.visitChildren((RenderObject child) {
      if (child is RenderBoxModel) {
        bool isChildHasFontSize = child.renderStyle.style[FONT_SIZE].isNotEmpty;
        // FIXME: Update `rem` will travers all dom tree may cause performance problem.
        if (isRootFontSizeUpdated) {
          child.renderStyle.style.applyRemProperties();
          // Also need update all em unit style if font-size is not set cause font-size of child
          // may depend on font-size of root due to style inheritance.
          if (!isChildHasFontSize) {
            child.renderStyle.style.applyEmProperties();
          }
          // Update font-size of nested children below root element.
          _updateChildrenFontSize(child, isRootFontSizeUpdated, depth: depth++);
        } else {
          // Need update all em unit style of child when its font size is inherited.
          child.renderStyle.style.applyEmProperties();
          // When child has font-size do not need update font-size:
          // <div style="font-size: 18px">
          //    <div>18px</div>
          //    <div style="font-size: 20px">20px</div>
          // </div>
          if (isChildHasFontSize) return;
          // Only need to update child text when style property is not set.
          _updateChildrenFontSize(child, isRootFontSizeUpdated, depth: depth++);
        }
        // Update direct renderTextBox and the nested text that its parent has no font-size set.
      } else if (child is RenderTextBox) {
        // Need to recreate text span cause text style can not be set alone.
        RenderBoxModel parentRenderBoxModel = child.parent as RenderBoxModel;
        KrakenRenderParagraph renderParagraph = child.child as KrakenRenderParagraph;
        String? text = renderParagraph.text.text;
        child.text = CSSTextMixin.createTextSpan(text, parentRenderBoxModel.renderStyle);
      }
    });
  }

  static TextSpan createTextSpan(String? text, RenderStyle parentRenderStyle) {
    CSSStyleDeclaration parentStyle = parentRenderStyle.style;
    Size viewportSize = parentRenderStyle.viewportSize;

    return TextSpan(
      text: text,
      style: getTextStyle(parentStyle, viewportSize, parentRenderStyle: parentRenderStyle),
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
  static TextStyle getTextStyle(CSSStyleDeclaration parentStyle, Size viewportSize, {RenderStyle? parentRenderStyle}) {
    // Text may be created when parent renderObject not created, get it from style instead
    Color? color = parentRenderStyle != null ?
      parentRenderStyle.color : CSSText.getTextColor(parentStyle);
    TextDecoration? textDecorationLine = parentRenderStyle != null ?
      parentRenderStyle.textDecorationLine : CSSText.getTextDecorationLine(parentStyle);
    Color? textDecorationColor = parentRenderStyle != null ?
      parentRenderStyle.textDecorationColor : CSSText.getTextDecorationColor(parentStyle);
    TextDecorationStyle? textDecorationStyle = parentRenderStyle != null ?
      parentRenderStyle.textDecorationStyle : CSSText.getTextDecorationStyle(parentStyle);
    FontWeight? fontWeight = parentRenderStyle != null ?
      parentRenderStyle.fontWeight : CSSText.getFontWeight(parentStyle);
    FontStyle? fontStyle = parentRenderStyle != null ?
      parentRenderStyle.fontStyle : CSSText.getFontStyle(parentStyle);
    double? fontSize = parentRenderStyle != null ?
      parentRenderStyle.fontSize : CSSText.getFontSize(parentStyle, viewportSize: viewportSize);
    List<String>? fontFamily = parentRenderStyle != null ?
      parentRenderStyle.fontFamily : CSSText.getFontFamilyFallback(parentStyle);
    double? letterSpacing = parentRenderStyle != null ?
      parentRenderStyle.letterSpacing : CSSText.getLetterSpacing(parentStyle, viewportSize: viewportSize);
    double? wordSpacing = parentRenderStyle != null ?
      parentRenderStyle.wordSpacing : CSSText.getWordSpacing(parentStyle, viewportSize: viewportSize);
    List<Shadow>? textShadow = parentRenderStyle != null ?
      parentRenderStyle.textShadow : CSSText.getTextShadow(parentStyle, viewportSize: viewportSize);

    return TextStyle(
      color: color,
      decoration: textDecorationLine,
      decorationColor: textDecorationColor,
      decorationStyle: textDecorationStyle,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      fontFamilyFallback: fontFamily,
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

  /// Percentage font size is set relative to parent's font size.
  void _updatePercentageFontSize(RenderStyle parentRenderStyle, String present) {
    double parentFontSize = parentRenderStyle.fontSize;
    double parsedFontSize = parentFontSize * CSSLength.parsePercentage(present);
    fontSize = parsedFontSize;
  }

  /// Percentage line height is set relative to its own font size.
  void _updatePercentageLineHeight(String present) {
    double parsedLineHeight = fontSize * CSSLength.parsePercentage(present);
    lineHeight = parsedLineHeight;
  }

  void updateTextStyle(String property, String present, RenderStyle? parentRenderStyle) {
    /// Percentage font-size should be resolved when node attached
    /// cause it needs to know its parents style
    if (property == FONT_SIZE && CSSLength.isPercentage(present)) {
      if (parentRenderStyle != null) {
        _updatePercentageFontSize(parentRenderStyle, present);
      } else {
        // Lazy process when element has a parent.
        style.setProperty(property, present);
      }
      return;
    }
    /// Percentage line-height should be resolved when node attached
    /// cause it needs to know other style in its own element
    if (property == LINE_HEIGHT && CSSLength.isPercentage(present)) {
      _updatePercentageLineHeight(present);
      return;
    }

    RenderStyle renderStyle = this as RenderStyle;
    Size viewportSize = renderStyle.viewportSize;
    RenderBoxModel renderBoxModel = renderStyle.renderBoxModel!;
    double rootFontSize = renderBoxModel.elementDelegate.getRootElementFontSize();
    double _fontSize = renderStyle.fontSize;

    switch (property) {
      case COLOR:
        color = CSSText.getTextColor(style);
        break;
      case TEXT_DECORATION_LINE:
        textDecorationLine = CSSText.getTextDecorationLine(style);
        break;
      case TEXT_DECORATION_STYLE:
        textDecorationStyle = CSSText.getTextDecorationStyle(style);
        break;
      case TEXT_DECORATION_COLOR:
        textDecorationColor = CSSText.getTextDecorationColor(style);
        break;
      case FONT_WEIGHT:
        fontWeight = CSSText.getFontWeight(style);
        break;
      case FONT_STYLE:
        fontStyle = CSSText.getFontStyle(style);
        break;
      case FONT_FAMILY:
        fontFamily = CSSText.getFontFamilyFallback(style);
        break;
      case FONT_SIZE:
        fontSize = CSSText.getFontSize(
          style,
          viewportSize: viewportSize,
          rootFontSize: rootFontSize,
          fontSize: _fontSize
        );
        break;
      case LINE_HEIGHT:
        lineHeight = CSSText.getLineHeight(
          style,
          viewportSize: viewportSize,
          rootFontSize: rootFontSize,
          fontSize: fontSize
        );
        break;
      case LETTER_SPACING:
        letterSpacing = CSSText.getLetterSpacing(
          style,
          viewportSize: viewportSize,
          rootFontSize: rootFontSize,
          fontSize: fontSize
        );
        break;
      case WORD_SPACING:
        wordSpacing = CSSText.getWordSpacing(
          style,
          viewportSize: viewportSize,
          rootFontSize: rootFontSize,
          fontSize: fontSize
        );
        break;
      case TEXT_SHADOW:
        textShadow = CSSText.getTextShadow(
          style,
          viewportSize: viewportSize,
          rootFontSize: rootFontSize,
          fontSize: fontSize
        );
        break;
      case WHITE_SPACE:
        whiteSpace = CSSText.getWhiteSpace(style);
        break;
      case TEXT_OVERFLOW:
        textOverflow = CSSText.getTextOverflow(renderStyle: this as RenderStyle);
        break;
      case LINE_CLAMP:
        lineClamp = CSSText.getLineClamp(style);
        break;
    }
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

  static double? getLineHeight(CSSStyleDeclaration style, {
    Size? viewportSize,
    double? rootFontSize,
    double? fontSize
  }) {
    double _fontSize = getFontSize(
      style,
      viewportSize: viewportSize,
      rootFontSize: rootFontSize,
      fontSize: fontSize
    );
    return parseLineHeight(
      style[LINE_HEIGHT],
      viewportSize: viewportSize,
      rootFontSize: rootFontSize,
      fontSize: _fontSize
    );
  }

  static double? parseLineHeight(String value, {
    Size? viewportSize,
    double? rootFontSize,
    required double fontSize
  }) {
    double? lineHeight;
    if (value.isNotEmpty) {
      if (CSSLength.isLength(value)) {
        double lineHeightValue = CSSLength.toDisplayPortValue(
          value, viewportSize:
          viewportSize,
          rootFontSize: rootFontSize,
          fontSize: fontSize
        )!;
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

  static TextOverflow getTextOverflow({CSSStyleDeclaration? style, RenderStyle? renderStyle}) {
    CSSOverflowType overflowX = renderStyle != null ?
      renderStyle.overflowX : getOverflowTypes(style!)[0];
    // Get white space from renderStyle cause it may be inherited from parents.
    WhiteSpace? whiteSpace = renderStyle != null ?
      renderStyle.whiteSpace : getWhiteSpace(style!);
    int? lineClamp = renderStyle != null ?
      renderStyle.lineClamp : getLineClamp(style!);

    // Set line-clamp to number makes text-overflow ellipsis which takes priority over text-overflow
    if (lineClamp != null && lineClamp > 0) {
      return TextOverflow.ellipsis;
    }
    //  To make text overflow its container you have to set overflowX hidden and white-space: nowrap.
    if (overflowX != CSSOverflowType.hidden || whiteSpace != WhiteSpace.nowrap) {
      return TextOverflow.visible;
    }

    // Always get text overflow from style cause it is affected by white-space and overflow.
    CSSStyleDeclaration? _style = renderStyle != null ? renderStyle.style : style;
    switch(_style![TEXT_OVERFLOW]) {
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

  static List<String>? parseFontFamilyFallback(String? fontFamily) {
    if (fontFamily!.isNotEmpty) {
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
  static double getFontSize(CSSStyleDeclaration style, {
    Size? viewportSize,
    double? rootFontSize,
    double? fontSize
  }) {
    if (style.contains(FONT_SIZE)) {
      return CSSLength.toDisplayPortValue(
        style[FONT_SIZE],
        viewportSize: viewportSize,
        rootFontSize: rootFontSize,
        fontSize: fontSize
      ) ?? DEFAULT_FONT_SIZE;
    } else {
      return DEFAULT_FONT_SIZE;
    }
  }

  static double getLetterSpacing(CSSStyleDeclaration style, {
    Size? viewportSize,
    double? rootFontSize,
    double? fontSize
  }) {
    if (style.contains(LETTER_SPACING)) {
      String _letterSpacing = style[LETTER_SPACING];
      if (_letterSpacing == NORMAL) return DEFAULT_LETTER_SPACING;

      return CSSLength.toDisplayPortValue(
        _letterSpacing,
        viewportSize: viewportSize,
        rootFontSize: rootFontSize,
        fontSize: fontSize
      ) ?? DEFAULT_LETTER_SPACING;
    } else {
      return DEFAULT_LETTER_SPACING;
    }
  }

  static double getWordSpacing(CSSStyleDeclaration style, {
    Size? viewportSize,
    double? rootFontSize,
    double? fontSize
  }) {
    if (style.contains(WORD_SPACING)) {
      String _wordSpacing = style[WORD_SPACING];
      if (_wordSpacing == NORMAL) return DEFAULT_WORD_SPACING;

      return CSSLength.toDisplayPortValue(
        _wordSpacing,
        viewportSize: viewportSize,
        rootFontSize: rootFontSize,
        fontSize: fontSize
      ) ?? DEFAULT_WORD_SPACING;
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

  static List<Shadow> getTextShadow(CSSStyleDeclaration style, {
    Size? viewportSize,
    double? rootFontSize,
    double? fontSize
  }) {
    List<Shadow> textShadows = [];
    if (style.contains(TEXT_SHADOW)) {
      var shadows = CSSStyleProperty.getShadowValues(style[TEXT_SHADOW]);
      if (shadows != null) {
        for (var shadowDefinitions in shadows) {
          // Specifies the color of the shadow. If the color is absent, it defaults to currentColor.
          Color? color = CSSColor.parseColor(shadowDefinitions[0] ?? style.getCurrentColor());
          double offsetX = CSSLength.toDisplayPortValue(
            shadowDefinitions[1],
            viewportSize: viewportSize,
            rootFontSize: rootFontSize,
            fontSize: fontSize
          ) ?? 0;
          double offsetY = CSSLength.toDisplayPortValue(
            shadowDefinitions[2],
            viewportSize: viewportSize,
            rootFontSize: rootFontSize,
            fontSize: fontSize
          ) ?? 0;
          double blurRadius = CSSLength.toDisplayPortValue(
            shadowDefinitions[3],
            viewportSize: viewportSize,
            rootFontSize: rootFontSize,
            fontSize: fontSize
          ) ?? 0;

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
