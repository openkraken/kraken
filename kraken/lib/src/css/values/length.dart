/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:ui';

import 'package:flutter/rendering.dart';
import 'package:kraken/css.dart';
import 'package:kraken/rendering.dart';
import 'package:quiver/collection.dart';

// https://drafts.csswg.org/css-values-3/#absolute-lengths
const _1in = 96; // 1in = 2.54cm = 96px
const _1cm = _1in / 2.54; // 1cm = 96px/2.54
const _1mm = _1cm / 10; // 1mm = 1/10th of 1cm
const _1Q = _1cm / 40; // 1Q = 1/40th of 1cm
const _1pc = _1in / 6; // 1pc = 1/6th of 1in
const _1pt = _1in / 72; // 1pt = 1/72th of 1in

final String _unitRegStr = '(px|rpx|vw|vh|vmin|vmax|rem|em|in|cm|mm|pc|pt)';
final _lengthRegExp = RegExp(r'^[+-]?(\d+)?(\.\d+)?' + _unitRegStr + r'$', caseSensitive: false);
final _negativeZeroRegExp = RegExp(r'^-(0+)?(\.0+)?' + _unitRegStr + r'$', caseSensitive: false);
final _nonNegativeLengthRegExp = RegExp(r'^[+]?(\d+)?(\.\d+)?' + _unitRegStr + r'$', caseSensitive: false);

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
  // none
  NONE,
  // normal
  NORMAL,
  INITIAL,
}

class CSSLengthValue {
  final double? value;
  final CSSLengthType type;
  CSSLengthValue(this.value, this.type, [this.renderStyle, this.propertyName, this.axisType]) {
    if (propertyName != null) {
      if (type == CSSLengthType.EM) {
        renderStyle!.addFontRelativeProperty(propertyName!);
      } else if (type == CSSLengthType.REM) {
        renderStyle!.addRootFontRelativeProperty(propertyName!);
      }
    }
  }
  static CSSLengthValue zero = CSSLengthValue(0, CSSLengthType.PX);
  static CSSLengthValue auto = CSSLengthValue(null, CSSLengthType.AUTO);
  static CSSLengthValue initial = CSSLengthValue(null, CSSLengthType.INITIAL);
  static CSSLengthValue unknow = CSSLengthValue(null, CSSLengthType.UNKNOWN);
  // Used in https://www.w3.org/TR/css-inline-3/#valdef-line-height-normal
  static CSSLengthValue normal = CSSLengthValue(null, CSSLengthType.NORMAL);
  static CSSLengthValue none = CSSLengthValue(null, CSSLengthType.NONE);

  // Length is applied in horizontal or vertical direction.
  Axis? axisType;

  RenderStyle? renderStyle;
  String? propertyName;
  double? _computedValue;

  // Note return value of double.infinity means the value is resolved as the initial value
  // which can not be computed to a specific value, eg. percentage height is sometimes parsed
  // to be auto due to parent height not defined.
  double get computedValue {

    switch (type) {
      case CSSLengthType.PX:
        _computedValue = value;
        break;
      case CSSLengthType.EM:
        // Font size of the parent, in the case of typographical properties like font-size,
        // and font size of the element itself, in the case of other properties like width.
        if (propertyName == FONT_SIZE) {
          // If root element set fontSize as em unit.
          if (renderStyle!.parent == null) {
            _computedValue = value! * 16;
          } else {
            _computedValue = value! * renderStyle!.parent!.fontSize.computedValue;
          }
        } else {
          _computedValue = value! * renderStyle!.fontSize.computedValue;
        }
        break;
      case CSSLengthType.REM:
        // If root element set fontSize as rem unit.
        if (renderStyle!.parent == null) {
          _computedValue = value! * 16;
        } else {
          // Font rem is calculated against the root element's font size.
          _computedValue = value! * renderStyle!.rootFontSize;
        }
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
        RenderBoxModel? renderBoxModel = renderStyle!.renderBoxModel;

        // Constraints is calculated before layout, the layouted size is identical to the tight constraints
        // if constraints is tight, so it's safe to use the tight constraints as the parent size to resolve
        // the child percentage length to save one extra layout to wait for parent layout complete.

        // Percentage relative width priority: tight constraints width > renderer width > logical width
        double? parentPaddingBoxWidth = parentRenderStyle?.paddingBoxConstraintsWidth
          ?? parentRenderStyle?.paddingBoxWidth
          ?? parentRenderStyle?.paddingBoxLogicalWidth;
        double? parentContentBoxWidth = parentRenderStyle?.contentBoxConstraintsWidth
          ?? parentRenderStyle?.contentBoxWidth
          ?? parentRenderStyle?.contentBoxLogicalWidth;
        // Percentage relative height priority: tight constraints height > renderer height > logical height
        double? parentPaddingBoxHeight = parentRenderStyle?.paddingBoxConstraintsHeight
          ?? parentRenderStyle?.paddingBoxHeight
          ?? parentRenderStyle?.paddingBoxLogicalHeight;
        double? parentContentBoxHeight = parentRenderStyle?.contentBoxConstraintsHeight
          ?? parentRenderStyle?.contentBoxHeight
          ?? parentRenderStyle?.contentBoxLogicalHeight;

        // Positioned element is positioned relative to the padding box of its containing block
        // while the others relative to the content box.
        double? relativeParentWidth = isPositioned
          ? parentPaddingBoxWidth
          : parentContentBoxWidth;
        double? relativeParentHeight = isPositioned
          ? parentPaddingBoxHeight
          : parentContentBoxHeight;

        switch (propertyName) {
          case FONT_SIZE:
            // Relative to the parent font size.
            if (renderStyle!.parent == null) {
              _computedValue = value! * 16;
            } else {
              _computedValue = value! * renderStyle!.parent!.fontSize.computedValue;
            }
            break;
          case LINE_HEIGHT:
            // Relative to the font size of the element itself.
            _computedValue = value! * renderStyle!.fontSize.computedValue;
            break;
          case WIDTH:
          case MIN_WIDTH:
          case MAX_WIDTH:
            if (relativeParentWidth != null) {
              _computedValue = value! * relativeParentWidth;
            } else {
              // Mark parent to relayout to get renderer width of parent.
              if (renderBoxModel != null) {
                renderBoxModel.markParentNeedsRelayout();
              }
              _computedValue = double.infinity;
            }
            break;
          case HEIGHT:
          case MIN_HEIGHT:
          case MAX_HEIGHT:
            // The percentage of height is calculated with respect to the height of the generated box's containing block.
            // If the height of the containing block is not specified explicitly (i.e., it depends on content height),
            // and this element is not absolutely positioned, the value computes to 'auto'.
            // https://www.w3.org/TR/CSS2/visudet.html#propdef-height
            // There are two exceptions when percentage height is resolved against actual render height of parent:
            // 1. positioned element
            // 2. parent is flex item
            RenderStyle? grandParentRenderStyle = parentRenderStyle?.parent;
            bool isGrandParentFlexLayout = grandParentRenderStyle?.display == CSSDisplay.flex ||
              grandParentRenderStyle?.display == CSSDisplay.inlineFlex;

            // The percentage height of positioned element and flex item resolves against the rendered height
            // of parent, mark parent as needs relayout if rendered height is not ready yet.
            if (isPositioned || isGrandParentFlexLayout) {
              if (relativeParentHeight  != null) {
                _computedValue = value! * relativeParentHeight;
              } else {
                // Mark parent to relayout to get renderer height of parent.
                if (renderBoxModel != null) {
                  renderBoxModel.markParentNeedsRelayout();
                }
                _computedValue = double.infinity;
              }
            } else {
              double? relativeParentHeight = parentRenderStyle?.contentBoxLogicalHeight;
              if (relativeParentHeight != null) {
                _computedValue = value! * relativeParentHeight;
              } else {
                // Resolves height as auto if parent has no height specified.
                _computedValue = double.infinity;
              }
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
            } else {
              // Mark parent to relayout to get renderer height of parent.
              if (renderBoxModel != null) {
                renderBoxModel.markParentNeedsRelayout();
              }
              _computedValue = 0;
            }
            break;
          case FLEX_BASIS:
            // Flex-basis computation is called in RenderFlexLayout which
            // will ensure parent exists.
            RenderStyle parentRenderStyle = renderStyle!.parent!;
            double? mainContentSize = parentRenderStyle.flexDirection == FlexDirection.row ?
              parentRenderStyle.contentBoxLogicalWidth :
              parentRenderStyle.contentBoxLogicalHeight;
            if (mainContentSize != null) {
              _computedValue = mainContentSize * value!;
            } else {
              // @TODO: Not supported when parent has no logical main size.
              _computedValue = 0;
            }
            // Refer to the flex container's inner main size.
            break;

          // https://www.w3.org/TR/css-position-3/#valdef-top-percentage
          // The inset is a percentage relative to the containing block’s size in the corresponding
          // axis (e.g. width for left or right, height for top and bottom). For sticky positioned boxes,
          // the inset is instead relative to the relevant scrollport’s size. Negative values are allowed.
          case TOP:
          case BOTTOM:
            // Offset of positioned element starts from the edge of padding box of containing block.
            if (parentPaddingBoxHeight != null) {
              _computedValue = value! * parentPaddingBoxHeight;
            } else {
              // Mark parent to relayout to get renderer height of parent.
              if (renderBoxModel != null) {
                renderBoxModel.markParentNeedsRelayout();
              }
              _computedValue = double.infinity;
            }
            break;
          case LEFT:
          case RIGHT:
            // Offset of positioned element starts from the edge of padding box of containing block.
            if (parentPaddingBoxWidth != null) {
              _computedValue = value! * parentPaddingBoxWidth;
            } else {
              // Mark parent to relayout to get renderer height of parent.
              if (renderBoxModel != null) {
                renderBoxModel.markParentNeedsRelayout();
              }
              _computedValue = double.infinity;
            }
          break;
          case TRANSLATE:
          case BACKGROUND_SIZE:
          case BORDER_TOP_LEFT_RADIUS:
          case BORDER_TOP_RIGHT_RADIUS:
          case BORDER_BOTTOM_LEFT_RADIUS:
          case BORDER_BOTTOM_RIGHT_RADIUS:
            // Percentages for the horizontal axis refer to the width of the box.
            // Percentages for the vertical axis refer to the height of the box.
            double? borderBoxWidth = renderStyle!.borderBoxWidth ?? renderStyle!.borderBoxLogicalWidth;
            double? borderBoxHeight = renderStyle!.borderBoxHeight ?? renderStyle!.borderBoxLogicalHeight;
            if (axisType == Axis.horizontal) {
              if (borderBoxWidth != null) {
                _computedValue = value! * borderBoxWidth;
              } else {
                // Mark parent to relayout to get renderer height of parent.
                if (renderBoxModel != null) {
                  renderBoxModel.markParentNeedsRelayout();
                }
                _computedValue = 0;
              }
            } else if (axisType == Axis.vertical) {
              if (borderBoxHeight != null) {
                _computedValue = value! * borderBoxHeight;
              } else {
                // Mark parent to relayout to get renderer height of parent.
                if (renderBoxModel != null) {
                  renderBoxModel.markParentNeedsRelayout();
                }
                _computedValue = 0;
              }
            }
          break;
        }
        break;
      default:
        // @FIXME: Type AUTO not always resolves to 0, in cases such as `margin: auto`, `width: auto`.
        return 0;
    }
    return _computedValue!;
  }

  bool get isAuto {
    switch (propertyName) {
      // Length is considered as auto of following properties
      // if it computes to double.infinity in cases of percentage.
      // The percentage of height is calculated with respect to the height of the generated box's containing block.
      // If the height of the containing block is not specified explicitly (i.e., it depends on content height),
      // and this element is not absolutely positioned, the value computes to 'auto'.
      // https://www.w3.org/TR/CSS2/visudet.html#propdef-height
      case WIDTH:
      case MIN_WIDTH:
      case MAX_WIDTH:
      case HEIGHT:
      case MIN_HEIGHT:
      case MAX_HEIGHT:
      case TOP:
      case BOTTOM:
      case LEFT:
      case RIGHT:
        if (computedValue == double.infinity) {
          return true;
        }
        break;
    }
    return type == CSSLengthType.AUTO;
  }

  bool get isNotAuto {
    return !isAuto;
  }

  bool get isNone {
    return type == CSSLengthType.NONE;
  }

  bool get isNotNone {
    return type != CSSLengthType.NONE;
  }

  bool get isPercentage {
    return type == CSSLengthType.PERCENTAGE;
  }

  bool get isZero {
    return value == 0;
  }

  /// Compares two length for equality.
  @override
  bool operator ==(Object? other) {
    return (other == null && (type == CSSLengthType.UNKNOWN || type == CSSLengthType.INITIAL)) ||
        (other is CSSLengthValue
        && other.value == value
        && other.type == type);
  }

  @override
  int get hashCode => hashValues(value, type);

  @override
  String toString() => 'CSSLengthValue(value: $value, unit: $type, computedValue: $computedValue)';
}

final LinkedLruHashMap<String, CSSLengthValue> _cachedParsedLength = LinkedLruHashMap(maximumSize: 500);

// CSS Values and Units: https://drafts.csswg.org/css-values-3/#lengths
class CSSLength {

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
    return value != null && (
      value == ZERO
      || _lengthRegExp.hasMatch(value)
    );
  }

  static bool isNonNegativeLength(String? value) {
    return value != null && (
      value == ZERO
      || _negativeZeroRegExp.hasMatch(value) // Negative zero is considered to be equal to zero.
      || _nonNegativeLengthRegExp.hasMatch(value)
    );
  }

  static CSSLengthValue? resolveLength(String text, RenderStyle? renderStyle, String propertyName) {
    if (text.isEmpty) {
      // Empty string means delete value.
      return null;
    } else {
      return parseLength(text, renderStyle, propertyName);
    }
  }

  static CSSLengthValue parseLength(String text, RenderStyle? renderStyle, [String? propertyName, Axis? axisType]) {
    if (_cachedParsedLength.containsKey(text)) {
      return _cachedParsedLength[text]!;
    }

    double? value;
    CSSLengthType unit = CSSLengthType.PX;
    if (text == ZERO) {
      // Only '0' is accepted with no unit.
      return CSSLengthValue.zero;
    } else if (text == INITIAL) {
      return CSSLengthValue.initial;
    } else if (text == AUTO) {
      return CSSLengthValue.auto;
    } else if (text == NONE) {
      return CSSLengthValue.none;
    } else if (text.endsWith(REM)) {
      value = double.tryParse(text.split(REM)[0]);
      unit = CSSLengthType.REM;
    } else if (text.endsWith(EM)) {
      value = double.tryParse(text.split(EM)[0]);
      unit = CSSLengthType.EM;
    } else if (text.endsWith(RPX)) {
      value = double.tryParse(text.split(RPX)[0]);
      if (value != null) value = value / 750.0 * window.physicalSize.width / window.devicePixelRatio;
    } else if (text.endsWith(PX)) {
      value = double.tryParse(text.split(PX)[0]);
    } else if (text.endsWith(VW)) {
      value = double.tryParse(text.split(VW)[0]);
      if (value != null) value = value / 100;
      unit = CSSLengthType.VW;
    } else if (text.endsWith(VH)) {
      value = double.tryParse(text.split(VH)[0]);
      if (value != null) value = value / 100;
      unit = CSSLengthType.VH;
    } else if (text.endsWith(CM)) {
      value = double.tryParse(text.split(CM)[0]);
      if (value != null) value = value * _1cm;
    } else if (text.endsWith(MM)) {
      value = double.tryParse(text.split(MM)[0]);
      if (value != null) value = value * _1mm;
    } else if (text.endsWith(PC)) {
      value = double.tryParse(text.split(PC)[0]);
      if (value != null) value = value * _1pc;
    } else if (text.endsWith(PT)) {
      value = double.tryParse(text.split(PT)[0]);
      if (value != null) value = value * _1pt;
    } else if (text.endsWith(VMIN)) {
      value = double.tryParse(text.split(VMIN)[0]);
      if (value != null) value = value / 100;
      unit = CSSLengthType.VMIN;
    }  else if (text.endsWith(VMAX)) {
      value = double.tryParse(text.split(VMAX)[0]);
      if (value != null) value = value / 100;
      unit = CSSLengthType.VMAX;
    } else if (text.endsWith(IN)) {
      value = double.tryParse(text.split(IN)[0]);
      if (value != null) value = value * _1in;
    } else if (text.endsWith(Q)) {
      value = double.tryParse(text.split(Q)[0]);
      if (value != null) value = value * _1Q;
    } else if (text.endsWith(PERCENTAGE)) {
      value = double.tryParse(text.split(PERCENTAGE)[0]);
      if (value != null) value = value / 100;
      unit = CSSLengthType.PERCENTAGE;
    } else if (CSSFunction.isFunction(text)) {
      List<CSSFunctionalNotation> notations = CSSFunction.parseFunction(text);
      // https://drafts.csswg.org/css-env/#env-function
      // Using Environment Variables: the env() notation
      if (notations.length == 1 && notations[0].name == ENV && notations[0].args.length == 1) {
        switch (notations[0].args.first) {
          case SAFE_AREA_INSET_TOP:
            value = window.viewPadding.top / window.devicePixelRatio;
            break;
          case SAFE_AREA_INSET_RIGHT:
            value = window.viewPadding.right / window.devicePixelRatio;
            break;
          case SAFE_AREA_INSET_BOTTOM:
            value = window.viewPadding.bottom / window.devicePixelRatio;
            break;
          case SAFE_AREA_INSET_LEFT:
            value = window.viewPadding.left / window.devicePixelRatio;
            break;
          default:
            // Using fallback value if not match user agent-defined environment variable: env(xxx, 50px).
            return parseLength(notations[0].args[1], renderStyle, propertyName, axisType);
        }

      }
      // TODO: impl CSS Variables.
    }

    if (value == 0) {
      return _cachedParsedLength[text] = CSSLengthValue.zero;
    } else if (value == null) {
      return _cachedParsedLength[text] = CSSLengthValue.unknow;
    } else if (unit == CSSLengthType.PX){
      return _cachedParsedLength[text] = CSSLengthValue(value, unit);
    } else {
      return CSSLengthValue(value, unit, renderStyle, propertyName, axisType);
    }
  }
}
