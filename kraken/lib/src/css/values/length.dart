/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:ui';

import 'package:kraken/css.dart';

// https://drafts.csswg.org/css-values-3/#absolute-lengths
const _1in = 96; // 1in = 2.54cm = 96px
const _1cm = _1in / 2.54; // 1cm = 96px/2.54
const _1mm = _1cm / 10; // 1mm = 1/10th of 1cm
const _1Q = _1cm / 40; // 1Q = 1/40th of 1cm
const _1pc = _1in / 6; // 1pc = 1/6th of 1in
const _1pt = _1in / 72; // 1pt = 1/72th of 1in

final _lengthRegExp = RegExp(r'^[+-]?(\d+)?(\.\d+)?px|rpx|vw|vh|vmin|vmax|rem|em|in|cm|mm|pc|pt$', caseSensitive: false);
final _percentageRegExp = RegExp(r'^\d+\%$', caseSensitive: false);

enum CSSLengthUnit {
  // absolute units
  PX, // px
  // relative units
  EM, // em,
  REM, // rem
  VH, // vh
  VW, // vw
  VMIN, // vmin
  VMAX, // vmax
  PERCENTAGE, // %
  // unknown
  UNKNOWN,
  // auto
  AUTO,
}

class CSSLengthValue {
  final double? value;
  final CSSLengthUnit unit;
  CSSLengthValue(this.value, this.unit, [this.renderStyle, this.propertyName]);
  static CSSLengthValue zero = CSSLengthValue(0, CSSLengthUnit.PX);
  static CSSLengthValue auto = CSSLengthValue(null, CSSLengthUnit.AUTO);
  static CSSLengthValue unknow = CSSLengthValue(null, CSSLengthUnit.UNKNOWN);

  RenderStyle? renderStyle;
  String? propertyName; 
  double? _computedValue;
  double get computedValue {

    RenderStyle renderStyle = this.renderStyle!;
    switch (unit) {
      case CSSLengthUnit.PX:
        _computedValue = value;
        break;
      case CSSLengthUnit.EM:
        // Font size of the parent, in the case of typographical properties like font-size,
        // and font size of the element itself, in the case of other properties like width.
        if (propertyName == FONT_SIZE) {
          _computedValue = value! * renderStyle.parent!.fontSize.computedValue;
        } else {
          _computedValue = value! * renderStyle.fontSize.computedValue;
        }
        break;
      case CSSLengthUnit.REM:
        // Font rem is calculated against the root element's font size. 
        _computedValue = value! * renderStyle.rootFontSize;
        break;
      case CSSLengthUnit.VH:
        _computedValue = value! * renderStyle.viewportSize.height;
        break;
      case CSSLengthUnit.VW:
        _computedValue = value! * renderStyle.viewportSize.width;
        break;
      // 1% of viewport's smaller (vw or vh) dimension.
      // If the height of the viewport is less than its width, 1vmin will be equivalent to 1vh.
      // If the width of the viewport is less than it’s height, 1vmin is equvialent to 1vw.
      case CSSLengthUnit.VMIN:
        _computedValue = value! * renderStyle.viewportSize.shortestSide;
        break;
      case CSSLengthUnit.VMAX:
        _computedValue = value! * renderStyle.viewportSize.longestSide;
        break;
      case CSSLengthUnit.PERCENTAGE:
        if (propertyName!.contains(WIDTH)) {
          _computedValue = value! * renderStyle.logicalWidth;
        } else if (propertyName!.contains(HEIGHT)) {
          _computedValue = value! * renderStyle.logicalHeight;
        } else if (propertyName == TOP || propertyName == BOTTOM) {

        } else if (propertyName == LEFT || propertyName == RIGHT) {

        } else if (propertyName!.contains(PADDING) || propertyName!.contains(MARGIN)) {
          // https://www.w3.org/TR/css-box-3/#padding-physical
          // Percentage refer to logical width of containing block
          _computedValue = value! * renderStyle.logicalWidth;
        } else if (propertyName == LINE_HEIGHT) {
          // Relative to the font size of the element itself.
          _computedValue = value! * renderStyle.fontSize.computedValue;
        } else if (propertyName == FLEX_BASIS) {
          // Refer to the flex container's inner main size

        } else {
          // Refer to the size of bounding box

        }
        break;
      default:
        return 0;
    }
    return _computedValue!;
  }

  bool get isAuto {
    return unit == CSSLengthUnit.AUTO;
  }

  void markNeedsCompute() {
    _computedValue = null;
  }

  /// Compares two length for equality.
  @override
  bool operator ==(Object? other) {
    return (other == null && unit == CSSLengthUnit.UNKNOWN) || 
        (other is CSSLengthValue
        && other.value == value
        && other.unit == unit);
  }

  @override
  int get hashCode => hashValues(value, unit);

  @override
  String toString() => 'CSSLengthValue(value: $value, unit: $unit, computedValue: $computedValue)';
}

// CSS Values and Units: https://drafts.csswg.org/css-values-3/#lengths
class CSSLength {
  static const String PX = 'px';
  static const String MM = 'mm';
  static const String CM = 'cm';
  static const String IN = 'in';
  static const String PC = 'pc';
  static const String PT = 'pt';
  static const String Q = 'q';
  static const String RPX = 'rpx';
  static const String VW = 'vw';
  static const String VH = 'vh';
  static const String VMIN = 'vmin';
  static const String VMAX = 'vmax';
  static const String EM = 'em';
  static const String REM = 'rem';
  static const String CH = 'ch';
  static const String PERCENTAGE = '%';
  static const String AUTO = 'auto';

  static double? toDouble(value) {
    if (value is double) {
      return value;
    } else if (value is int) {
      return value.toDouble();
    } else if (value is String) {
      return double.tryParse(value);
    } else {
      return null;
    }
  }

  static int? toInt(value) {
    if (value is double) {
      return value.toInt();
    } else if (value is int) {
      return value;
    } else if (value is String) {
      return int.tryParse(value);
    } else {
      return null;
    }
  }

  static bool isAuto(String? value) {
    return value == AUTO;
  }

  static bool isPercentage(String? value) {
    return value != null && _percentageRegExp.hasMatch(value);
  }

  static bool isLength(String? value) {
    return value != null && (value == ZERO || _lengthRegExp.hasMatch(value));
  }

  static double parsePercentage(String percentage) {
    return double.tryParse(percentage.split('%')[0])! / 100;
  }

  static CSSLengthValue parseLength(String text, RenderStyle? renderStyle, String? propertyName) {
    // Only '0' is accepted with no unit.
    double? value;
    CSSLengthUnit unit = CSSLengthUnit.PX;
    if (text == ZERO) {
      return CSSLengthValue.zero;
    } if (text == AUTO) {
      return CSSLengthValue.auto;
    } else if (text.endsWith(REM)) {
      value = double.tryParse(text.split(REM)[0]);
      unit = CSSLengthUnit.REM;
    } else if (text.endsWith(EM)) {
      value = double.tryParse(text.split(EM)[0]);
      unit = CSSLengthUnit.EM;
    } else if (text.endsWith(RPX)) {
      value = double.tryParse(text.split(RPX)[0]);
      if (value != null) value = value / 750.0 * window.physicalSize.width / window.devicePixelRatio;
    } else if (text.endsWith(VMIN)) {
      value = double.tryParse(text.split(VMIN)[0]);
      if (value != null) value = value / 100;
      unit = CSSLengthUnit.VMIN;
    }  else if (text.endsWith(VMAX)) {
      value = double.tryParse(text.split(VMAX)[0]);
      if (value != null) value = value / 100;
      unit = CSSLengthUnit.VMAX;
    } else if (text.endsWith(Q)) {
      value = double.tryParse(text.split(Q)[0]);
    } else if (text.endsWith(PERCENTAGE)) {
      value = double.tryParse(text.split(PERCENTAGE)[0]);
      if (value != null) value = value / 100;
      unit = CSSLengthUnit.PERCENTAGE;
    } else if (text.length > 2) {
      switch (text.substring(text.length - 2)) {
        case PX:
          value = double.tryParse(text.split(PX)[0]);
          break;
        case VW:
          value = double.tryParse(text.split(VW)[0]);
          if (value != null) value = value / 100;
          unit = CSSLengthUnit.VW;
          break;
        case VH:
          value = double.tryParse(text.split(VH)[0]);
          if (value != null) value = value / 100;
          unit = CSSLengthUnit.VH;
          break;
        case IN:
          value = double.tryParse(text.split(IN)[0]);
          if (value != null) value = value * _1in;
          break;
        case CM:
          value = double.tryParse(text.split(CM)[0]);
          if (value != null) value = value * _1cm;
          break;
        case MM:
          value = double.tryParse(text.split(MM)[0]);
          if (value != null) value = value * _1mm;
          break;
        case PC:
          value = double.tryParse(text.split(PC)[0]);
          if (value != null) value = value * _1pc;
          break;
        case PT:
          value = double.tryParse(text.split(PT)[0]);
          if (value != null) value = value * _1pt;
          break;
      }
    }

    if (value == 0) {
      return CSSLengthValue.zero;
    }

    return value == null ? CSSLengthValue.unknow : CSSLengthValue(value, unit, renderStyle, propertyName);
  }

  // TODO(yuanyan): fontSize to getFontSize for performance improve
  static double? toDisplayPortValue(
    String? unitedValue,
    {
      Size? viewportSize,
      double? rootFontSize,
      double? fontSize
    }
  ) {
    if (unitedValue == null || unitedValue.isEmpty) return null;

    unitedValue = unitedValue.trim();
    if (unitedValue == INITIAL) return null;

    double? displayPortValue;
    double viewportWidth = viewportSize!.width;
    double viewportHeight = viewportSize.height;

    // Only '0' is accepted with no unit.
    if (unitedValue == ZERO) {
      return 0;
    } else if (unitedValue.endsWith(REM)) {
      double? currentValue = double.tryParse(unitedValue.split(REM)[0]);
      if (currentValue == null || rootFontSize == null) return null;
      // Font rem is calculated against the root element's font size.
      return rootFontSize * currentValue;
    } else if (unitedValue.endsWith(EM)) {
      double? currentValue = double.tryParse(unitedValue.split(EM)[0]);
      if (currentValue == null || fontSize == null) return null;
      // Font em is calculated against the parent element's font size.
      return fontSize * currentValue;
    } else if (unitedValue.endsWith(RPX)) {
      double? currentValue = double.tryParse(unitedValue.split(RPX)[0]);
      if (currentValue == null) return null;
      displayPortValue = currentValue / 750.0 * window.physicalSize.width / window.devicePixelRatio;
    } else if (unitedValue.endsWith(Q)) {
      double? currentValue = double.tryParse(unitedValue.split(Q)[0]);
      if (currentValue == null) return null;
      displayPortValue = currentValue * _1Q;
    }  else if (unitedValue.endsWith(VMIN)) {
      // 1% of viewport's smaller (vw or vh) dimension.
      // If the height of the viewport is less than its width, 1vmin will be equivalent to 1vh.
      // If the width of the viewport is less than it’s height, 1vmin is equvialent to 1vw.
      double? currentValue = double.tryParse(unitedValue.split(VMIN)[0]);
      if (currentValue == null) return null;
      // Viewport min is calculated against the smaller dimension of the viewport.
      double smallest = viewportWidth > viewportHeight ? viewportHeight : viewportWidth;
      displayPortValue = currentValue / 100.0 * smallest;
    }  else if (unitedValue.endsWith(VMAX)) {
      double? currentValue = double.tryParse(unitedValue.split(VMAX)[0]);
      // 1% of viewport's larger (vw or vh) dimension.
      if (currentValue == null) return null;
      // Viewport max is calculated against the larger dimension of the viewport.
      double largest = viewportWidth > viewportHeight ? viewportWidth : viewportHeight;
      displayPortValue = currentValue / 100.0 * largest;
    } else if (unitedValue.length > 2) {
      switch (unitedValue.substring(unitedValue.length - 2)) {
        case PX:
          displayPortValue = double.tryParse(unitedValue.split(PX)[0]);
          break;
        case VW:
          double? currentValue = double.tryParse(unitedValue.split(VW)[0]);
          if (currentValue == null) return null;
          // Viewport width is calculated against the width of the viewport.
          displayPortValue = currentValue / 100.0 * viewportWidth;
          break;
        case VH:
          double? currentValue = double.tryParse(unitedValue.split(VH)[0]);
          if (currentValue == null) return null;
          // Viewport height is calculated against the height of the viewport.
          displayPortValue = currentValue / 100.0 * viewportHeight;
          break;
        case IN:
          double? currentValue = double.tryParse(unitedValue.split(IN)[0]);
          if (currentValue == null) return null;
          displayPortValue = currentValue * _1in;
          break;
        case CM:
          double? currentValue = double.tryParse(unitedValue.split(CM)[0]);
          if (currentValue == null) return null;
          displayPortValue = currentValue * _1cm;
          break;
        case MM:
          double? currentValue = double.tryParse(unitedValue.split(MM)[0]);
          if (currentValue == null) return null;
          displayPortValue = currentValue * _1mm;
          break;
        case PC:
          double? currentValue = double.tryParse(unitedValue.split(PC)[0]);
          if (currentValue == null) return null;
          displayPortValue = currentValue * _1pc;
          break;
        case PT:
          double? currentValue = double.tryParse(unitedValue.split(PT)[0]);
          if (currentValue == null) return null;
          displayPortValue = currentValue * _1pt;
          break;
      }
    }

    return displayPortValue;
  }
}
