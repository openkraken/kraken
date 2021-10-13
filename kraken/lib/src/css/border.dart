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

  static final CSSLengthValue _thinWidth = CSSLengthValue(1, CSSLengthUnit.PX);
  static final CSSLengthValue _mediumWidth = CSSLengthValue(3, CSSLengthUnit.PX);
  static final CSSLengthValue _thickWidth = CSSLengthValue(5, CSSLengthUnit.PX);

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
    return CSSLength.isLength(value) || value == THIN || value == MEDIUM || value == THICK;
  }

  static BorderSide none = BorderSide(color: defaultBorderColor, width: 0.0, style: BorderStyle.none);

  static BorderSide? getBorderSide(RenderStyle renderStyle, String side) {
    BorderStyle? borderStyle;
    CSSLengthValue? borderWidth;
    Color? borderColor;
    switch (side) {
      case LEFT:
        borderStyle = renderStyle.borderLeftStyle;
        borderWidth = renderStyle.borderLeftWidth;
        borderColor = renderStyle.borderLeftColor;
        break;
      case RIGHT:
        borderStyle = renderStyle.borderRightStyle;
        borderWidth = renderStyle.borderRightWidth;
        borderColor = renderStyle.borderRightColor;
        break;
      case TOP:
        borderStyle = renderStyle.borderTopStyle;
        borderWidth = renderStyle.borderTopWidth;
        borderColor = renderStyle.borderTopColor;
        break;
      case BOTTOM:
        borderStyle = renderStyle.borderBottomStyle;
        borderWidth = renderStyle.borderBottomWidth;
        borderColor = renderStyle.borderBottomColor;
        break;
    }
    // Flutter will print border event if width is 0.0. So we needs to set borderStyle to none to prevent this.
    if (borderStyle == BorderStyle.none || borderWidth!.isZero) {
      return null;
    } else if (borderColor == null) {
      return BorderSide(
        width: borderWidth.computedValue,
        style: borderStyle!
      );
    } else {
      return BorderSide(
        width: borderWidth.computedValue,
        style: borderStyle!,
        color: borderColor
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
        CSSLengthValue circular = CSSLength.parseLength(values[0], renderStyle, propertyName);
        return CSSBorderRadius(circular, circular);
      } else if (values.length == 2) {
        CSSLengthValue x = CSSLength.parseLength(values[0], renderStyle, propertyName);
        CSSLengthValue y = CSSLength.parseLength(values[1], renderStyle, propertyName);
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
  }) : super(color: color, offset: offset, blurRadius: blurRadius);

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

  KrakenBoxShadow get computedBoxShdow {
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
        String? colorDefinition = shadowDefinitions[0];
        Color? color;
        if (colorDefinition == CURRENT_COLOR || colorDefinition == null) {
          color = renderStyle.currentColor;
        } else {
          color = CSSColor.parseColor(colorDefinition);
        }
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
