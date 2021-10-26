/*
 * Copyright (C) 2021-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'package:flutter/rendering.dart';
import 'package:kraken/css.dart';
import 'package:vector_math/vector_math_64.dart';

// CSS Transforms: https://drafts.csswg.org/css-transforms/
Color? _parseColor(String color, RenderStyle renderStyle, String propertyName) {
  return CSSColor.resolveColor(color, renderStyle, propertyName);
}

void _updateColor(Color oldColor, Color newColor, double progress, String property, RenderStyle renderStyle) {
  int alphaDiff = newColor.alpha - oldColor.alpha;
  int redDiff = newColor.red - oldColor.red;
  int greenDiff = newColor.green - oldColor.green;
  int blueDiff = newColor.blue - oldColor.blue;

  int alpha = (alphaDiff * progress).toInt() + oldColor.alpha;
  int red = (redDiff * progress).toInt() + oldColor.red;
  int blue = (blueDiff * progress).toInt() + oldColor.blue;
  int green = (greenDiff * progress).toInt() + oldColor.green;
  Color color = Color.fromARGB(alpha, red, green, blue);

  renderStyle.style.target!.setRenderStyleProperty(property, color);
}

double? _parseLength(String length, RenderStyle renderStyle, String property) {
  return CSSLength.parseLength(length, renderStyle, property).computedValue;
}

void _updateLength(double oldLengthValue, double newLengthValue, double progress, String property, RenderStyle renderStyle) {
  double value = oldLengthValue * (1 - progress) + newLengthValue * progress;
  renderStyle.style.target!.setRenderStyleProperty(property, CSSLengthValue(value, CSSLengthType.PX));
}

FontWeight _parseFontWeight(String fontWeight, RenderStyle renderStyle, String property) {
  return CSSText.resolveFontWeight(fontWeight);
}

void _updateFontWeight(FontWeight oldValue, FontWeight newValue, double progress, String property, RenderStyle renderStyle) {
  FontWeight? fontWeight = FontWeight.lerp(oldValue, newValue, progress);
  switch (property) {
    case FONT_WEIGHT:
      renderStyle.fontWeight = fontWeight;
      break;
  }
}

double? _parseNumber(String number, RenderStyle renderStyle, String property) {
  return CSSNumber.parseNumber(number);
}

double _getNumber(double oldValue, double newValue, double progress) {
  return oldValue * (1 - progress) + newValue * progress;
}

void _updateNumber(double oldValue, double newValue, double progress, String property, RenderStyle renderStyle) {
  double number = _getNumber(oldValue, newValue, progress);
  renderStyle.style.target!.setRenderStyleProperty(property, number);
}

double _parseLineHeight(String lineHeight, RenderStyle renderStyle, String property) {
  if (CSSNumber.isNumber(lineHeight)) {
    return CSSLengthValue(CSSNumber.parseNumber(lineHeight), CSSLengthType.EM, renderStyle, LINE_HEIGHT).computedValue;
  }
  return CSSLength.parseLength(lineHeight, renderStyle, LINE_HEIGHT).computedValue;
}

void _updateLineHeight(double oldValue, double newValue, double progress, String property, RenderStyle renderStyle) {
  renderStyle.lineHeight = CSSLengthValue(_getNumber(oldValue, newValue, progress), CSSLengthType.PX);
}

Matrix4? _parseTransform(String value, RenderStyle renderStyle, String property) {
  return CSSMatrix.computeTransformMatrix(CSSFunction.parseFunction(value), renderStyle);
}

void _updateTransform(Matrix4 begin, Matrix4 end, double t, String property, RenderStyle renderStyle) {
  Matrix4 newMatrix4 = CSSMatrix.lerpMatrix(begin, end, t);
  renderStyle.transformMatrix = newMatrix4;
}

const List<Function> _colorHandler = [_parseColor, _updateColor];
const List<Function> _lengthHandler = [_parseLength, _updateLength];
const List<Function> _fontWeightHandler = [_parseFontWeight, _updateFontWeight];
const List<Function> _numberHandler = [_parseNumber, _updateNumber];
const List<Function> _lineHeightHandler = [_parseLineHeight, _updateLineHeight];
const List<Function> _transformHandler = [_parseTransform, _updateTransform];

Map<String, List<Function>> CSSTransformHandlers = {
  COLOR: _colorHandler,
  BACKGROUND_COLOR: _colorHandler,
  BORDER_BOTTOM_COLOR: _colorHandler,
  BORDER_LEFT_COLOR: _colorHandler,
  BORDER_RIGHT_COLOR: _colorHandler,
  BORDER_TOP_COLOR: _colorHandler,
  BORDER_COLOR: _colorHandler,
  TEXT_DECORATION_COLOR: _colorHandler,
  OPACITY: _numberHandler,
  Z_INDEX: _numberHandler,
  FLEX_GROW: _numberHandler,
  FLEX_SHRINK: _numberHandler,
  FONT_WEIGHT: _fontWeightHandler,
  LINE_HEIGHT: _lineHeightHandler,
  TRANSFORM: _transformHandler,
  BORDER_BOTTOM_LEFT_RADIUS: _lengthHandler,
  BORDER_BOTTOM_RIGHT_RADIUS: _lengthHandler,
  BORDER_TOP_LEFT_RADIUS: _lengthHandler,
  BORDER_TOP_RIGHT_RADIUS: _lengthHandler,
  RIGHT: _lengthHandler,
  TOP: _lengthHandler,
  BOTTOM: _lengthHandler,
  LEFT: _lengthHandler,
  LETTER_SPACING: _lengthHandler,
  MARGIN_BOTTOM: _lengthHandler,
  MARGIN_LEFT: _lengthHandler,
  MARGIN_RIGHT: _lengthHandler,
  MARGIN_TOP: _lengthHandler,
  MIN_HEIGHT: _lengthHandler,
  MIN_WIDTH: _lengthHandler,
  PADDING_BOTTOM: _lengthHandler,
  PADDING_LEFT: _lengthHandler,
  PADDING_RIGHT: _lengthHandler,
  PADDING_TOP: _lengthHandler,
  // should non negative value
  BORDER_BOTTOM_WIDTH: _lengthHandler,
  BORDER_LEFT_WIDTH: _lengthHandler,
  BORDER_RIGHT_WIDTH: _lengthHandler,
  BORDER_TOP_WIDTH: _lengthHandler,
  FLEX_BASIS: _lengthHandler,
  FONT_SIZE: _lengthHandler,
  HEIGHT: _lengthHandler,
  WIDTH: _lengthHandler,
  MAX_HEIGHT: _lengthHandler,
  MAX_WIDTH: _lengthHandler,
};

mixin CSSTransformMixin on RenderStyleBase {

  static Offset DEFAULT_TRANSFORM_OFFSET = Offset(0, 0);
  static Alignment DEFAULT_TRANSFORM_ALIGNMENT = Alignment.center;

  // https://drafts.csswg.org/css-transforms-1/#propdef-transform
  // Name: transform
  // Value: none | <transform-list>
  // Initial: none
  // Applies to: transformable elements
  // Inherited: no
  // Percentages: refer to the size of reference box
  // Computed value: as specified, but with lengths made absolute
  // Canonical order: per grammar
  // Animation type: transform list, see interpolation rules
  List<CSSFunctionalNotation>? _transform;
  List<CSSFunctionalNotation>? get transform => _transform;
  set transform(List<CSSFunctionalNotation>? value) {
    // Transform should converted to matrix4 value to compare cause case such as
    // `translate3d(750rpx, 0rpx, 0rpx)` and `translate3d(100vw, 0vw, 0vw)` should considered to be equal.
    // Note this comparison cannot be done in style listener cause prevValue cannot be get in animation case.
    if (_transform == value) return;
    _transform = value;
    _transformMatrix = null;
    renderBoxModel!.markNeedsLayout();
  }

  static List<CSSFunctionalNotation>? resolveTransform(String present) {
    if (present == 'none') return null;
    return CSSFunction.parseFunction(present);
  }

  Matrix4? _transformMatrix;
  Matrix4? get transformMatrix {
    if (_transformMatrix == null && _transform != null) {
      // Illegal transform syntax will return null.
      _transformMatrix = CSSMatrix.computeTransformMatrix(_transform!, this as RenderStyle);
    }
    return _transformMatrix;
  }
  set transformMatrix(Matrix4? value) {
    if (value == null || _transformMatrix == value) return;
    _transformMatrix = value;
    renderBoxModel!.markNeedsLayout();
  }

  Offset get transformOffset => _transformOffset;
  Offset _transformOffset = DEFAULT_TRANSFORM_OFFSET;
  set transformOffset(Offset value) {
    if (_transformOffset == value) return;
    _transformOffset = value;
    renderBoxModel!.markNeedsPaint();
  }

  Alignment get transformAlignment => _transformAlignment;
  Alignment _transformAlignment = DEFAULT_TRANSFORM_ALIGNMENT;
  set transformAlignment(Alignment value) {
    if (_transformAlignment == value) return;
    _transformAlignment = value;
    renderBoxModel!.markNeedsPaint();
  }

  CSSOrigin? _transformOrigin;
  CSSOrigin? get transformOrigin => _transformOrigin;
  set transformOrigin(CSSOrigin? value) {

    if (_transformOrigin == value) return;
    _transformOrigin = value;

    if (value == null) return;
    Offset oldOffset = transformOffset;
    Offset offset = value.offset;
    // Transform origin transition by offset
    if (offset.dx != oldOffset.dx || offset.dy != oldOffset.dy) {
      transformOffset = offset;
    }

    Alignment alignment = value.alignment;
    Alignment oldAlignment = transformAlignment;
    // Transform origin transition by alignment
    if (alignment.x != oldAlignment.x || alignment.y != oldAlignment.y) {
      transformAlignment = alignment;
    }
  }
}

