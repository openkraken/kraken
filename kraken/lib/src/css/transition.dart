/*
 * Copyright (C) 2021-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:ui';

import 'package:flutter/animation.dart';
import 'package:kraken/css.dart';
import 'package:kraken/dom.dart';
import 'package:vector_math/vector_math_64.dart';

// CSS Transitions: https://drafts.csswg.org/css-transitions/
const String _0s = '0s';

String _toCamelCase(String s) {
  var sb = StringBuffer();
  var shouldUpperCase = false;
  for (int rune in s.runes) {
    // '-' char code is 45
    if (rune == 45) {
      shouldUpperCase = true;
    } else {
      var char = String.fromCharCode(rune);
      if (shouldUpperCase) {
        sb.write(char.toUpperCase());
        shouldUpperCase = false;
      } else {
        sb.write(char);
      }
    }
  }

  return sb.toString();
}

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

Map<String, List<Function>> CSSTranstionHandlers = {
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

/// The types of TransitionEvent
enum CSSTransitionEvent {
  /// The transitionrun event occurs when a transition is created
  run,

  /// The transitionstart event occurs when a transition’s delay phase ends.
  start,

  /// The transitionend event occurs at the completion of the transition.
  end,

  /// The transitioncancel event occurs when a transition is canceled.
  cancel,
}

class CSSTransition {
  static void updateTransition(CSSStyleDeclaration style) {
    Map<String, List> transitions = {};

    List<String> transitionProperty = CSSStyleProperty.getMultipleValues(style[TRANSITION_PROPERTY]) ?? [ALL];
    List<String> transitionDuration = CSSStyleProperty.getMultipleValues(style[TRANSITION_DURATION]) ?? [_0s];
    List<String> transitionTimingFunction = CSSStyleProperty.getMultipleValues(style[TRANSITION_TIMING_FUNCTION]) ?? [EASE];
    List<String> transitionDelay = CSSStyleProperty.getMultipleValues(style[TRANSITION_DELAY]) ?? [_0s];

    for (int i = 0; i < transitionProperty.length; i++) {
      String property = _toCamelCase(transitionProperty[i]);
      String duration = transitionDuration.length == 1 ? transitionDuration[0] : transitionDuration[i];
      String function = transitionTimingFunction.length == 1 ? transitionTimingFunction[0] : transitionTimingFunction[i];
      String delay = transitionDelay.length == 1 ? transitionDelay[0] : transitionDelay[i];
      transitions[property] = [duration, function, delay];
    }
    style.transitions = transitions;
  }

  static bool isValidTransitionPropertyValue(String value) {
    return value == ALL || value == NONE || CSSTextual.isCustomIdent(value);
  }

  static bool isValidTransitionTimingFunctionValue(String value) {
    return value == LINEAR ||
        value == EASE ||
        value == EASE_IN ||
        value == EASE_OUT ||
        value == EASE_IN_OUT ||
        value == STEP_END ||
        value == STEP_START ||
        CSSFunction.isFunction(value);
  }

  static void dispatchTransitionEvent(Element target, CSSTransitionEvent status) {
    if (status == CSSTransitionEvent.run) {
      target.dispatchEvent(Event(EVENT_TRANSITION_RUN));
    } else if (status == CSSTransitionEvent.cancel) {
      // An Event fired when a CSS transition has been cancelled.
      target.dispatchEvent(Event(EVENT_TRANSITION_CANCEL));
    } else if (status == CSSTransitionEvent.start) {
      // An Event fired when a CSS transition is created,
      // when it is added to a set of running transitions,
      // though not necessarily started.
      target.dispatchEvent(Event(EVENT_TRANSITION_START));
    } else if (status == CSSTransitionEvent.end) {
      // An Event fired when a CSS transition has finished playing.
      target.dispatchEvent(Event(EVENT_TRANSITION_END));
    }
  }
}

class CSSStepCurve extends Curve {
  final int? step;
  final bool isStart;

  CSSStepCurve(this.step, this.isStart);

  @override
  double transformInternal(double t) {
    int addition = 0;
    if (!isStart) {
      addition = 1;
    }

    int cur = (t * step!).floor();
    cur = cur + addition;

    return cur / step!;
  }
}
