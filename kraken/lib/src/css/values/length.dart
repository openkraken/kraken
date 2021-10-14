/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:ui';

import 'package:flutter/rendering.dart';
import 'package:kraken/css.dart';

// https://drafts.csswg.org/css-values-3/#absolute-lengths
const _1in = 96; // 1in = 2.54cm = 96px
const _1cm = _1in / 2.54; // 1cm = 96px/2.54
const _1mm = _1cm / 10; // 1mm = 1/10th of 1cm
const _1Q = _1cm / 40; // 1Q = 1/40th of 1cm
const _1pc = _1in / 6; // 1pc = 1/6th of 1in
const _1pt = _1in / 72; // 1pt = 1/72th of 1in

final _lengthRegExp = RegExp(r'^[+-]?(\d+)?(\.\d+)?px|rpx|vw|vh|vmin|vmax|rem|em|in|cm|mm|pc|pt$', caseSensitive: false);

enum CSSLengthType {
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
  INITIAL,
}

class CSSLengthValue {
  final double? value;
  final CSSLengthType unit;
  CSSLengthValue(this.value, this.unit, [this.renderStyle, this.propertyName, this.axisType]);
  static CSSLengthValue zero = CSSLengthValue(0, CSSLengthType.PX);
  static CSSLengthValue auto = CSSLengthValue(null, CSSLengthType.AUTO);
  static CSSLengthValue initial = CSSLengthValue(null, CSSLengthType.INITIAL);
  static CSSLengthValue unknow = CSSLengthValue(null, CSSLengthType.UNKNOWN);

  // Length is applied in horizontal or vertical direction.
  Axis? axisType;

  RenderStyle? renderStyle;
  String? propertyName;
  double? _computedValue;
  double get computedValue {

    switch (unit) {
      case CSSLengthType.PX:
        _computedValue = value;
        break;
      case CSSLengthType.EM:
        // Font size of the parent, in the case of typographical properties like font-size,
        // and font size of the element itself, in the case of other properties like width.
        if (propertyName == FONT_SIZE) {
          _computedValue = value! * renderStyle!.parent!.fontSize.computedValue;
        } else {
          _computedValue = value! * renderStyle!.fontSize.computedValue;
        }
        break;
      case CSSLengthType.REM:
        // Font rem is calculated against the root element's font size.
        _computedValue = value! * renderStyle!.rootFontSize;
        break;
      case CSSLengthType.VH:
        _computedValue = value! * renderStyle!.viewportSize.height;
        break;
      case CSSLengthType.VW:
        _computedValue = value! * renderStyle!.viewportSize.width;
        break;
      // 1% of viewport's smaller (vw or vh) dimension.
      // If the height of the viewport is less than its width, 1vmin will be equivalent to 1vh.
      // If the width of the viewport is less than it’s height, 1vmin is equvialent to 1vw.
      case CSSLengthType.VMIN:
        _computedValue = value! * renderStyle!.viewportSize.shortestSide;
        break;
      case CSSLengthType.VMAX:
        _computedValue = value! * renderStyle!.viewportSize.longestSide;
        break;
      case CSSLengthType.PERCENTAGE:
        CSSPositionType positionType = renderStyle!.position;
        bool isPositioned = positionType == CSSPositionType.absolute ||
          positionType == CSSPositionType.fixed;

        RenderStyle? parentRenderStyle = renderStyle!.parent;

        // Use logical not rendered width as base length for percentage calculation, cause
        // its parent is not renderer yet when child is layouting.
        double? relativeParentWidth = isPositioned ?
          parentRenderStyle?.paddingBoxLogicalWidth :
          parentRenderStyle?.contentBoxLogicalWidth;

        // The percentage of height is calculated with respect to the height of the generated box's containing block.
        // If the height of the containing block is not specified explicitly (i.e., it depends on content height),
        // and this element is not absolutely positioned, the value computes to 'auto'.
        // https://www.w3.org/TR/CSS2/visudet.html#propdef-height
        // Note: If the parent is flex item, percentage resloves againts the resolved height
        // no matter parent's height is set or not.
        bool isParentFlexLayout = parentRenderStyle?.display == CSSDisplay.flex ||
          parentRenderStyle?.display == CSSDisplay.inlineFlex;

        // Use logical not rendered height as base length for percentage calculation, cause
        // its parent is not renderer yet when child is layouting.
        double? relativeParentHeight = isPositioned || isParentFlexLayout ?
          parentRenderStyle?.paddingBoxLogicalHeight :
          parentRenderStyle?.contentBoxLogicalHeight;

        switch (propertyName) {
          case LINE_HEIGHT:
            // Relative to the font size of the element itself.
            _computedValue = value! * renderStyle!.fontSize.computedValue;
            break;
          case WIDTH:
          case MIN_WIDTH:
          case MAX_WIDTH:
            if (relativeParentWidth != null) {
              _computedValue = value! * relativeParentWidth;
            }
            break;
          case HEIGHT:
          case MIN_HEIGHT:
          case MAX_HEIGHT:
            if (relativeParentHeight != null) {
              _computedValue = value! * relativeParentHeight;
            }
            break;
          case PADDING_TOP:
          case PADDING_RIGHT:
          case PADDING_BOTTOM:
          case PADDING_LEFT:
          case MARGIN_LEFT:
          case MARGIN_RIGHT:
          case MARGIN_TOP:
          case MARGIN_BOTTOM:
            // https://www.w3.org/TR/css-box-3/#padding-physical
            // Percentage refer to logical width of containing block
            if (relativeParentWidth != null) {
              _computedValue = value! * relativeParentWidth;
            }
            break;
          case FLEX_BASIS:
            // Refer to the flex container's inner main size.
            break;
          case TOP:
          case BOTTOM:
            // Offset of positioned element starts from the edge of padding box of containing block.
            double? parentPaddingBoxWidth = parentRenderStyle?.paddingBoxWidth ??
              parentRenderStyle?.paddingBoxLogicalWidth;
            if (parentPaddingBoxWidth != null) {
              _computedValue = value! * parentPaddingBoxWidth;
            }
            break;
          case LEFT:
          case RIGHT:
            // Offset of positioned element starts from the edge of padding box of containing block.
            double? parentPaddingBoxHeight = parentRenderStyle?.paddingBoxHeight ??
              parentRenderStyle?.paddingBoxLogicalHeight;
            if (parentPaddingBoxHeight != null) {
              _computedValue = value! * parentPaddingBoxHeight;
            }
          break;
          case BACKGROUND_SIZE:
          case BORDER_TOP_LEFT_RADIUS:
          case BORDER_TOP_RIGHT_RADIUS:
          case BORDER_BOTTOM_LEFT_RADIUS:
          case BORDER_BOTTOM_RIGHT_RADIUS:
            // Percentages for the horizontal axis refer to the width of the box.
            // Percentages for the vertical axis refer to the height of the box.
            double? borderBoxWidth = renderStyle!.borderBoxWidth ?? renderStyle!.borderBoxLogicalWidth;
            double? borderBoxHeight = renderStyle!.borderBoxHeight ?? renderStyle!.borderBoxLogicalHeight;
            if (axisType == Axis.horizontal && borderBoxWidth != null) {
              _computedValue = value! * borderBoxWidth;
            } else if (axisType == Axis.vertical && borderBoxHeight != null) {
              _computedValue = value! * borderBoxHeight;
            }
          break;
        }
        break;
      default:
        return 0;
    }
    return _computedValue!;
  }

  bool get isAuto {
    return unit == CSSLengthType.AUTO;
  }

  bool get isPercentage {
    return unit == CSSLengthType.PERCENTAGE;
  }

  bool get isZero {
    return value == 0;
  }

  void markNeedsCompute() {
    _computedValue = null;
  }

  /// Compares two length for equality.
  @override
  bool operator ==(Object? other) {
    return (other == null && (unit == CSSLengthType.UNKNOWN || unit == CSSLengthType.INITIAL)) ||
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

  static bool isLength(String? value) {
    return value != null && (value == ZERO || _lengthRegExp.hasMatch(value));
  }

  static CSSLengthValue parseLength(String text, RenderStyle? renderStyle, [String? propertyName, Axis? axisType]) {
    // Only '0' is accepted with no unit.
    double? value;
    CSSLengthType unit = CSSLengthType.PX;

    if (text == ZERO) {
      return CSSLengthValue.zero;
    } else if (text == INITIAL) {
      return CSSLengthValue.initial;
    } else if (text == AUTO) {
      return CSSLengthValue.auto;
    } else if (text.endsWith(REM)) {
      value = double.tryParse(text.split(REM)[0]);
      unit = CSSLengthType.REM;
    } else if (text.endsWith(EM)) {
      value = double.tryParse(text.split(EM)[0]);
      unit = CSSLengthType.EM;
    } else if (text.endsWith(RPX)) {
      value = double.tryParse(text.split(RPX)[0]);
      if (value != null) value = value / 750.0 * window.physicalSize.width / window.devicePixelRatio;
    } else if (text.endsWith(VMIN)) {
      value = double.tryParse(text.split(VMIN)[0]);
      if (value != null) value = value / 100;
      unit = CSSLengthType.VMIN;
    }  else if (text.endsWith(VMAX)) {
      value = double.tryParse(text.split(VMAX)[0]);
      if (value != null) value = value / 100;
      unit = CSSLengthType.VMAX;
    } else if (text.endsWith(Q)) {
      value = double.tryParse(text.split(Q)[0]);
    } else if (text.endsWith(PERCENTAGE)) {
      value = double.tryParse(text.split(PERCENTAGE)[0]);
      if (value != null) value = value / 100;
      unit = CSSLengthType.PERCENTAGE;
    } else if (text.length > 2) {
      switch (text.substring(text.length - 2)) {
        case PX:
          value = double.tryParse(text.split(PX)[0]);
          break;
        case VW:
          value = double.tryParse(text.split(VW)[0]);
          if (value != null) value = value / 100;
          unit = CSSLengthType.VW;
          break;
        case VH:
          value = double.tryParse(text.split(VH)[0]);
          if (value != null) value = value / 100;
          unit = CSSLengthType.VH;
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

    return value == null ? CSSLengthValue.unknow : CSSLengthValue(value, unit, renderStyle, propertyName, axisType);
  }
}
