

/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:ui';

import 'package:kraken/css.dart';
import 'package:kraken/rendering.dart';

// https://drafts.csswg.org/css-values-3/#absolute-lengths
const _1in = 96; // 1in = 2.54cm = 96px
const _1cm = _1in / 2.54; // 1cm = 96px/2.54
const _1mm = _1cm / 10; // 1mm = 1/10th of 1cm
const _1Q = _1cm / 40; // 1Q = 1/40th of 1cm
const _1pc = _1in / 6; // 1pc = 1/6th of 1in
const _1pt = _1in / 72; // 1pt = 1/72th of 1in

final _lengthRegExp = RegExp(r'^[+-]?(\d+)?(\.\d+)?px|rpx|vw|vh|vmin|vmax|rem|em|in|cm|mm|pc|pt$', caseSensitive: false);
final _percentageRegExp = RegExp(r'^\d+\%$', caseSensitive: false);

// CSS Values and Units: https://drafts.csswg.org/css-values-3/#lengths
class CSSLength {
  static const String RPX = 'rpx';
  static const String PX = 'px';
  static const String VW = 'vw';
  static const String VH = 'vh';
  static const String VMIN = 'vmin';
  static const String VMAX = 'vmax';
  static const String MM = 'mm';
  static const String CM = 'cm';
  static const String IN = 'in';
  static const String PC = 'pc';
  static const String PT = 'pt';
  static const String Q = 'q';
  static const String EM = 'em';
  static const String REM = 'rem';

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

  static double parsePercentage(String percentage) {
    return double.tryParse(percentage.split('%')[0])! / 100;
  }

  static double? parseLength(String unitedValue, { Size? viewportSize, RenderStyle? renderStyle }) {
    return toDisplayPortValue(unitedValue, viewportSize: viewportSize, renderStyle: renderStyle);
  }

  static double? toDisplayPortValue(String? unitedValue, { Size? viewportSize, RenderStyle? renderStyle }) {
    if (unitedValue == null || unitedValue.isEmpty) return null;

    unitedValue = unitedValue.trim();
    if (unitedValue == INITIAL) return null;

    double? displayPortValue;
    Size _viewportSize = renderStyle != null ? renderStyle.viewportSize : viewportSize!;
    double viewportWidth = _viewportSize.width;
    double viewportHeight = _viewportSize.height;

    // Only '0' is accepted with no unit.
    if (unitedValue == ZERO) {
      return 0;
    } else if (unitedValue.endsWith(REM)) {
      double? currentValue = double.tryParse(unitedValue.split(REM)[0]);
      if (currentValue == null || renderStyle == null) return null;
      RenderBoxModel renderBoxModel = renderStyle.renderBoxModel!;
      RenderBoxModel? documentRoot = renderBoxModel.getDocumentRoot();
      if (documentRoot != null) {
        double rootFontSize = documentRoot.renderStyle.fontSize;
        return rootFontSize * currentValue;
      }
      return null;
    } else if (unitedValue.endsWith(EM)) {
      double? currentValue = double.tryParse(unitedValue.split(EM)[0]);
      if (currentValue == null || renderStyle == null) return null;
      double fontSize = renderStyle.fontSize;
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
      double smallest = viewportWidth > viewportHeight ? viewportHeight : viewportWidth;
      displayPortValue = currentValue / 100.0 * smallest;
    }  else if (unitedValue.endsWith(VMAX)) {
      double? currentValue = double.tryParse(unitedValue.split(VMAX)[0]);
      // 1% of viewport's larger (vw or vh) dimension.
      if (currentValue == null) return null;
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
          displayPortValue = currentValue / 100.0 * viewportWidth;
          break;
        case VH:
          double? currentValue = double.tryParse(unitedValue.split(VH)[0]);
          if (currentValue == null) return null;
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

  static bool isLength(String? value) {
    return value != null && (value == ZERO || _lengthRegExp.hasMatch(value));
  }

}
