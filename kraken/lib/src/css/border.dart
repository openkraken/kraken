/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'dart:core';
import 'dart:ui';

import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:kraken/css.dart';

final RegExp _splitRegExp = RegExp(r'\s+');

// Initial border value: medium
final CSSLengthValue _mediumWidth = CSSLengthValue(3, CSSLengthType.PX);

enum CSSBorderStyleType {
  none,
  hidden,
  dotted,
  dashed,
  solid,
  double,
  groove,
  ridge,
  inset,
  outset,
}

mixin CSSBorderMixin on RenderStyle {

  // Effective border widths. These are used to calculate the
  // dimensions of the border box.
  @override
  EdgeInsets get border {
    // If has border, render padding should subtracting the edge of the border
    return EdgeInsets.fromLTRB(
      effectiveBorderLeftWidth.computedValue,
      effectiveBorderTopWidth.computedValue,
      effectiveBorderRightWidth.computedValue,
      effectiveBorderBottomWidth.computedValue,
    );
  }

  Size wrapBorderSize(Size innerSize) {
    return Size(border.left + innerSize.width + border.right,
        border.top + innerSize.height + border.bottom);
  }

  BoxConstraints deflateBorderConstraints(BoxConstraints constraints) {
    return constraints.deflate(border);
  }

  @override
  List<BorderSide>? get borderSides {
    BorderSide? leftSide = CSSBorderSide._getBorderSide(this, CSSBorderSide.LEFT);
    BorderSide? topSide = CSSBorderSide._getBorderSide(this, CSSBorderSide.TOP);
    BorderSide? rightSide = CSSBorderSide._getBorderSide(this, CSSBorderSide.RIGHT);
    BorderSide? bottomSide = CSSBorderSide._getBorderSide(this, CSSBorderSide.BOTTOM);

    bool hasBorder = leftSide != null ||
        topSide != null ||
        rightSide != null ||
        bottomSide != null;

    return hasBorder ? [
      leftSide ?? CSSBorderSide.none,
      topSide ?? CSSBorderSide.none,
      rightSide ?? CSSBorderSide.none,
      bottomSide ?? CSSBorderSide.none] : null;
  }

  /// Shorted border property:
  ///   border：<line-width> || <line-style> || <color>
  ///   (<line-width> = <length> | thin | medium | thick), support length now.
  /// Seperated properties:
  ///   borderWidth: <line-width>{1,4}
  ///   borderStyle: none | hidden | dotted | dashed | solid | double | groove | ridge | inset | outset
  ///     (PS. Only support solid now.)
  ///   borderColor: <color>

  /// Border-width = <length> | thin | medium | thick

  CSSLengthValue? _borderTopWidth;
  set borderTopWidth(CSSLengthValue? value) {
    if (value == _borderTopWidth) return;
    _borderTopWidth = value;
    renderBoxModel?.markNeedsLayout();
  }
  @override
  CSSLengthValue? get borderTopWidth => _borderTopWidth;

  @override
  CSSLengthValue get effectiveBorderTopWidth => borderTopStyle == BorderStyle.none ? CSSLengthValue.zero : (_borderTopWidth ?? _mediumWidth);

  CSSLengthValue? _borderRightWidth;
  set borderRightWidth(CSSLengthValue? value) {
    if (value == _borderRightWidth) return;
    _borderRightWidth = value;
    renderBoxModel?.markNeedsLayout();
  }

  @override
  CSSLengthValue? get borderRightWidth => _borderRightWidth;

  @override
  CSSLengthValue get effectiveBorderRightWidth => borderRightStyle == BorderStyle.none ? CSSLengthValue.zero : (_borderRightWidth ?? _mediumWidth);

  CSSLengthValue? _borderBottomWidth;
  set borderBottomWidth(CSSLengthValue? value) {
    if (value == _borderBottomWidth) return;
    _borderBottomWidth = value;
    renderBoxModel?.markNeedsLayout();
  }

  @override
  CSSLengthValue? get borderBottomWidth => _borderBottomWidth;

  @override
  CSSLengthValue get effectiveBorderBottomWidth => borderBottomStyle == BorderStyle.none ? CSSLengthValue.zero : (_borderBottomWidth ?? _mediumWidth);

  CSSLengthValue? _borderLeftWidth;
  set borderLeftWidth(CSSLengthValue? value) {
    if (value == _borderLeftWidth) return;
    _borderLeftWidth = value;
    renderBoxModel?.markNeedsLayout();
  }

  @override
  CSSLengthValue? get borderLeftWidth => _borderLeftWidth;

  @override
  CSSLengthValue get effectiveBorderLeftWidth => borderLeftStyle == BorderStyle.none ? CSSLengthValue.zero : (_borderLeftWidth ?? _mediumWidth);

  /// Border-color
  @override
  Color get borderTopColor => _borderTopColor ?? currentColor;
  Color? _borderTopColor;
  set borderTopColor(Color? value) {
    if (value == _borderTopColor) return;
    _borderTopColor = value;
    renderBoxModel?.markNeedsPaint();
  }

  @override
  Color get borderRightColor => _borderRightColor ?? currentColor;
  Color? _borderRightColor;
  set borderRightColor(Color? value) {
    if (value == _borderRightColor) return;
    _borderRightColor = value;
    renderBoxModel?.markNeedsPaint();
  }

  @override
  Color get borderBottomColor => _borderBottomColor ?? currentColor;
  Color? _borderBottomColor;
  set borderBottomColor(Color? value) {
    if (value == _borderBottomColor) return;
    _borderBottomColor = value;
    renderBoxModel?.markNeedsPaint();
  }

  @override
  Color get borderLeftColor => _borderLeftColor ?? currentColor;
  Color? _borderLeftColor;
  set borderLeftColor(Color? value) {
    if (value == _borderLeftColor) return;
    _borderLeftColor = value;
    renderBoxModel?.markNeedsPaint();
  }

  /// Border-style
  @override
  BorderStyle get borderTopStyle => _borderTopStyle ?? BorderStyle.none;
  BorderStyle? _borderTopStyle;
  set borderTopStyle(BorderStyle? value) {
    if (value == _borderTopStyle) return;
    _borderTopStyle = value;
    renderBoxModel?.markNeedsPaint();
  }

  @override
  BorderStyle get borderRightStyle => _borderRightStyle ?? BorderStyle.none;
  BorderStyle? _borderRightStyle;
  set borderRightStyle(BorderStyle? value) {
    if (value == _borderRightStyle) return;
    _borderRightStyle = value;
    renderBoxModel?.markNeedsPaint();
  }

  @override
  BorderStyle get borderBottomStyle => _borderBottomStyle ?? BorderStyle.none;
  BorderStyle? _borderBottomStyle;
  set borderBottomStyle(BorderStyle? value) {
    if (value == _borderBottomStyle) return;
    _borderBottomStyle = value;
    renderBoxModel?.markNeedsPaint();
  }

  BorderStyle? _borderLeftStyle;

  @override
  BorderStyle get borderLeftStyle => _borderLeftStyle ?? BorderStyle.none;

  set borderLeftStyle(BorderStyle? value) {
    if (value == _borderLeftStyle) return;
    _borderLeftStyle = value;
    renderBoxModel?.markNeedsPaint();
  }
}

class CSSBorderSide {
  // border default width 3.0
  static double defaultBorderWidth = 3.0;
  static Color defaultBorderColor = CSSColor.initial;
  static const String LEFT = 'Left';
  static const String RIGHT = 'Right';
  static const String TOP = 'Top';
  static const String BOTTOM = 'Bottom';

  static BorderStyle resolveBorderStyle(String input) {
    BorderStyle borderStyle;
    switch (input) {
      case SOLID:
        borderStyle = BorderStyle.solid;
        break;
      case NONE:
      default:
        borderStyle = BorderStyle.none;
        break;
    }
    return borderStyle;
  }

  static final CSSLengthValue _thinWidth = CSSLengthValue(1, CSSLengthType.PX);
  static final CSSLengthValue _mediumWidth = CSSLengthValue(3, CSSLengthType.PX);
  static final CSSLengthValue _thickWidth = CSSLengthValue(5, CSSLengthType.PX);

  static CSSLengthValue? resolveBorderWidth(String input, RenderStyle renderStyle, String propertyName) {
    // https://drafts.csswg.org/css2/#border-width-properties
    // The interpretation of the first three values depends on the user agent.
    // The following relationships must hold, however:
    // thin ≤ medium ≤ thick.
    CSSLengthValue? borderWidth;
    switch (input) {
      case THIN:
        borderWidth = _thinWidth;
        break;
      case MEDIUM:
        borderWidth = _mediumWidth;
        break;
      case THICK:
        borderWidth = _thickWidth;
        break;
      default:
        borderWidth = CSSLength.parseLength(input, renderStyle, propertyName);
    }
    return borderWidth;
  }

  static bool isValidBorderStyleValue(String value) {
    return value == SOLID || value == NONE;
  }

  static bool isValidBorderWidthValue(String value) {
    return CSSLength.isNonNegativeLength(value) || value == THIN || value == MEDIUM || value == THICK;
  }

  static BorderSide none = BorderSide(color: defaultBorderColor, width: 0.0, style: BorderStyle.none);

  static BorderSide? _getBorderSide(RenderStyle renderStyle, String side) {
    BorderStyle? borderStyle;
    CSSLengthValue? borderWidth;
    Color? borderColor;
    switch (side) {
      case LEFT:
        borderStyle = renderStyle.borderLeftStyle;
        borderWidth = renderStyle.effectiveBorderLeftWidth;
        borderColor = renderStyle.borderLeftColor;
        break;
      case RIGHT:
        borderStyle = renderStyle.borderRightStyle;
        borderWidth = renderStyle.effectiveBorderRightWidth;
        borderColor = renderStyle.borderRightColor;
        break;
      case TOP:
        borderStyle = renderStyle.borderTopStyle;
        borderWidth = renderStyle.effectiveBorderTopWidth;
        borderColor = renderStyle.borderTopColor;
        break;
      case BOTTOM:
        borderStyle = renderStyle.borderBottomStyle;
        borderWidth = renderStyle.effectiveBorderBottomWidth;
        borderColor = renderStyle.borderBottomColor;
        break;
    }
    // Flutter will print border event if width is 0.0. So we needs to set borderStyle to none to prevent this.
    if (borderStyle == BorderStyle.none || borderWidth!.isZero) {
      return null;
    } else {
      return BorderSide(
        width: borderWidth.computedValue,
        style: borderStyle!,
        color: borderColor!
      );
    }
  }
}

class CSSBorderRadius {
  final CSSLengthValue x;
  final CSSLengthValue y;
  const CSSBorderRadius(this.x, this.y);
  static CSSBorderRadius zero = CSSBorderRadius(CSSLengthValue.zero, CSSLengthValue.zero);
  static CSSBorderRadius? parseBorderRadius(String radius, RenderStyle renderStyle, String propertyName) {
    if (radius.isNotEmpty) {
      // border-top-left-radius: horizontal vertical
      List<String> values = radius.split(_splitRegExp);
      if (values.length == 1) {
        CSSLengthValue circular = CSSLength.parseLength(values[0], renderStyle, propertyName, Axis.horizontal);
        return CSSBorderRadius(circular, circular);
      } else if (values.length == 2) {
        CSSLengthValue x = CSSLength.parseLength(values[0], renderStyle, propertyName, Axis.horizontal);
        CSSLengthValue y = CSSLength.parseLength(values[1], renderStyle, propertyName, Axis.vertical);
        return CSSBorderRadius(x, y);
      }
    }
    return null;
  }

  Radius get computedRadius {
    return Radius.elliptical(x.computedValue, y.computedValue);
  }
}

class KrakenBoxShadow extends BoxShadow {
  /// Creates a box shadow.
  ///
  /// By default, the shadow is solid black with zero [offset], [blurRadius],
  /// and [spreadRadius].
  const KrakenBoxShadow({
    Color color = const Color(0xFF000000),
    Offset offset = Offset.zero,
    double blurRadius = 0.0,
    double spreadRadius = 0.0,
    this.inset = false,
  }) : super(color: color, offset: offset, blurRadius: blurRadius, spreadRadius: spreadRadius);

  final bool inset;
}

// ignore: must_be_immutable
class CSSBoxShadow {
  CSSBoxShadow({
    this.color,
    this.offsetX,
    this.offsetY,
    this.blurRadius,
    this.spreadRadius,
    this.inset = false,
  });

  bool inset = false;
  Color? color;
  CSSLengthValue? offsetX;
  CSSLengthValue? offsetY;
  CSSLengthValue? blurRadius;
  CSSLengthValue? spreadRadius;

  KrakenBoxShadow get computedBoxShadow {
    color ??= const Color(0xFF000000);
    offsetX ??= CSSLengthValue.zero;
    offsetY ??= CSSLengthValue.zero;
    blurRadius ??= CSSLengthValue.zero;
    spreadRadius ??= CSSLengthValue.zero;
    return KrakenBoxShadow(
      color: color!,
      offset: Offset(offsetX!.computedValue, offsetY!.computedValue),
      blurRadius: blurRadius!.computedValue,
      spreadRadius: spreadRadius!.computedValue,
      inset: inset,
    );
  }

  static List<CSSBoxShadow>? parseBoxShadow(String present, RenderStyle renderStyle, String propertyName) {

    var shadows = CSSStyleProperty.getShadowValues(present);
    if (shadows != null) {
      List<CSSBoxShadow>? boxShadow = [];
      for (var shadowDefinitions in shadows) {
        // Specifies the color of the shadow. If the color is absent, it defaults to currentColor.
        String colorDefinition = shadowDefinitions[0] ?? CURRENT_COLOR;
        Color? color = CSSColor.resolveColor(colorDefinition, renderStyle, propertyName);
        CSSLengthValue? offsetX;
        if (shadowDefinitions[1] != null) {
          offsetX = CSSLength.parseLength(shadowDefinitions[1]!, renderStyle, propertyName);
        }

        CSSLengthValue? offsetY;
        if (shadowDefinitions[2] != null) {
          offsetY = CSSLength.parseLength(shadowDefinitions[2]!, renderStyle, propertyName);
        }

        CSSLengthValue? blurRadius;
        if (shadowDefinitions[3] != null) {
          blurRadius = CSSLength.parseLength(shadowDefinitions[3]!, renderStyle, propertyName);
        }

        CSSLengthValue? spreadRadius;
        if (shadowDefinitions[4] != null) {
          spreadRadius = CSSLength.parseLength(shadowDefinitions[4]!, renderStyle, propertyName);
        }

        bool inset = shadowDefinitions[5] == INSET;

        if (color != null) {
          boxShadow.add(CSSBoxShadow(
            offsetX: offsetX,
            offsetY: offsetY,
            blurRadius: blurRadius,
            spreadRadius: spreadRadius,
            color: color,
            inset: inset,
          ));
        }
      }
      return boxShadow;
    }

    return null;
  }
}
