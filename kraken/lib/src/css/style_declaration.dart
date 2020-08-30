/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'dart:typed_data';
import 'dart:ui';

import 'package:kraken/css.dart';
import 'package:kraken/element.dart';
import 'package:kraken/src/css/animation.dart';
import 'package:vector_math/vector_math_64.dart';

typedef StyleChangeListener = void Function(
  String property,
  String original,
  String present,
  bool inAnimation
);

const String EMPTY_STRING = '';

Map LonghandPropertyInitialValues = {
  'backgroundColor': 'transparent',
  'backgroundPosition': '0% 0%',
  'borderBottomColor': 'currentColor',
  'borderBottomLeftRadius': '0px',
  'borderBottomRightRadius': '0px',
  'borderBottomWidth': '3px',
  'borderLeftColor': 'currentColor',
  'borderLeftWidth': '3px',
  'borderRightColor': 'currentColor',
  'borderRightWidth': '3px',
  // Spec says this should be 0 but in practise it is 2px.
  'borderTopColor': 'currentColor',
  'borderTopLeftRadius': '0px',
  'borderTopRightRadius': '0px',
  'borderTopWidth': '3px',
  'bottom': 'auto',
  'clip': 'rect(0px, 0px, 0px, 0px)',
  // Depends on user agent.
  'color': 'black',
  'fontSize': '100%',
  'fontWeight': '400',
  'height': 'auto',
  'left': 'auto',
  'letterSpacing': 'normal',
  'lineHeight': '120%',
  'marginBottom': '0px',
  'marginLeft': '0px',
  'marginRight': '0px',
  'marginTop': '0px',
  'maxHeight': 'none',
  'maxWidth': 'none',
  'minHeight': '0px',
  'minWidth': '0px',
  'opacity': '1.0',
  'paddingBottom': '0px',
  'paddingLeft': '0px',
  'paddingRight': '0px',
  'paddingTop': '0px',
  'right': 'auto',
  'textShadow': '0px 0px 0px transparent',
  'top': 'auto',
  'transform': 'matrix3d(${CSSTransform.initial.storage.join(',')})',
  'verticalAlign': '0px',
  'visibility': 'visible',
  'width': 'auto',
  'wordSpacing': 'normal',
  'zIndex': 'auto'
};

Color _parseColor(String color) {
  return CSSColor.parseColor(color);
}

String _stringifyColor(Color oldColor, Color newColor, double progress) {
  int alphaDiff = newColor.alpha - oldColor.alpha;
  int redDiff = newColor.red - oldColor.red;
  int greenDiff = newColor.green - oldColor.green;
  int blueDiff = newColor.blue - oldColor.blue;

  int alpha = (alphaDiff * progress).toInt() + oldColor.alpha;
  int red = (redDiff * progress).toInt() + oldColor.red;
  int blue = (blueDiff * progress).toInt() + oldColor.blue;
  int green = (greenDiff * progress).toInt() + oldColor.green;

  return 'rgba(${red}, ${green}, ${blue}, ${alpha})';
}

double _parseLength(String length) {
  return CSSLength.parseLength(length);
}

String _stringifyLength(double oldLength, double newLength, double progress) {
  return _stringifyNumber(oldLength, newLength, progress) + 'px';
}

FontWeight _parseFontWeight(String fontWeight) {
  return CSSText.parseFontWeight(fontWeight);
}

String _stringifyFontWeight(FontWeight oldValue, FontWeight newValue, double progress) {
  return ((FontWeight.lerp(oldValue, newValue, progress).index + 1) * 100).toString();
}

double _parseNumber(String number) {
  return CSSNumber.parseNumber(number);
}

String _stringifyNumber(double oldValue, double newValue, double progress) {
  return (oldValue * (1 - progress) + newValue * progress).toString();
}

String _parseLineHeight(String lineHeight) {
  return lineHeight;
}

String _stringifyLineHeight(String oldValue, String newValue, double progress) {
  if (CSSLength.isLength(oldValue) && CSSLength.isLength(newValue)) {
    double left = CSSLength.parseLength(oldValue);
    double right = CSSLength.parseLength(newValue);
    return _stringifyNumber(left, right, progress).toString() + 'px';
  } else if (CSSNumber.isNumber(oldValue) && CSSNumber.isNumber(newValue)) {
    double left = CSSNumber.parseNumber(oldValue);
    double right = CSSNumber.parseNumber(newValue);
    return _stringifyNumber(left, right, progress).toString();
  } else {
    return newValue;
  }
}

Matrix4 _parseTransform(String value) {
  return CSSTransform.parseTransform(value);
}

String _stringifyTransform(Matrix4 begin, Matrix4 end, double t) {
  final Vector3 beginTranslation = Vector3.zero();
  final Vector3 endTranslation = Vector3.zero();
  final Quaternion beginRotation = Quaternion.identity();
  final Quaternion endRotation = Quaternion.identity();
  final Vector3 beginScale = Vector3.zero();
  final Vector3 endScale = Vector3.zero();
  begin.decompose(beginTranslation, beginRotation, beginScale);
  end.decompose(endTranslation, endRotation, endScale);
  final Vector3 lerpTranslation = beginTranslation * (1.0 - t) + endTranslation * t;
  // TODO(alangardner): Implement slerp for constant rotation
  final Quaternion lerpRotation = (beginRotation.scaled(1.0 - t) + endRotation.scaled(t)).normalized();
  final Vector3 lerpScale = beginScale * (1.0 - t) + endScale * t;
  Matrix4 newMatrix4 = Matrix4.compose(lerpTranslation, lerpRotation, lerpScale);
  Float64List m4storage = newMatrix4.storage;
  return 'matrix3d(${m4storage.join(',')})';
}

const List<Function> _colorHandler = [_parseColor, _stringifyColor];
const List<Function> _lengthHandler = [_parseLength, _stringifyLength];
const List<Function> _fontWeightHandler = [_parseFontWeight, _stringifyFontWeight];
const List<Function> _numberHandler = [_parseNumber, _stringifyNumber];
const List<Function> _lineHeightHandler = [_parseLineHeight, _stringifyLineHeight];
const List<Function> _transformHandler = [_parseTransform, _stringifyTransform];

Map<String, List<Function>> AnimationPropertyHandlers = {
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

const Map<String, bool> ShorthandProperty = {
  MARGIN: true,
  PADDING: true,
  BACKGROUND: true,
  BORDER_RADIUS: true,
  BORDER: true,
  BORDER_COLOR: true,
  BORDER_WIDTH: true,
  BORDER_STYLE: true,
  BORDER_LEFT: true,
  BORDER_RIGHT: true,
  BORDER_TOP: true,
  BORDER_BOTTOM: true,
  FONT: true,
  FLEX: true,
  FLEX_FLOW: true,
  OVERFLOW: true,
  TRANSITION: true,
  TEXT_DECORATION: true,
};

// CSS Object Model: https://drafts.csswg.org/cssom/#the-cssstyledeclaration-interface

/// The [CSSStyleDeclaration] interface represents an object that is a CSS
/// declaration block, and exposes style information and various style-related
/// methods and properties.
///
/// A [CSSStyleDeclaration] object can be exposed using three different APIs:
/// 1. Via [HTMLElement.style], which deals with the inline styles of a single
///    element (e.g., <div style="...">).
/// 2. Via the [CSSStyleSheet] API. For example,
///    document.styleSheets[0].cssRules[0].style returns a [CSSStyleDeclaration]
///    object on the first CSS rule in the document's first stylesheet.
/// 3. Via [Window.getComputedStyle()], which exposes the [CSSStyleDeclaration]
///    object as a read-only interface.
class CSSStyleDeclaration {
  Element target;

  CSSStyleDeclaration(Element this.target);
  /// When some property changed, corresponding [StyleChangeListener] will be
  /// invoked in synchronous.
  List<StyleChangeListener> _styleChangeListeners = [];

  Map<String, String> _properties = {};

  Map<String, List> _transitions = {};

  set transitions (Map<String, List> value) {
    _transitions = value;
  }

  bool _shouldTransition(String property) {
    return AnimationPropertyHandlers[property] != null &&
      (_transitions.containsKey(property) || _transitions.containsKey(ALL));
  }

  EffectTiming _getTransitionEffectTiming(String property) {

    List transitionOptions = _transitions[property] ?? _transitions[ALL];
    // [duration, function, delay]
    if (transitionOptions != null) {

      return EffectTiming(
        duration: CSSTime.parseTime(transitionOptions[0]).toDouble(),
        easing: transitionOptions[1],
        delay: CSSTime.parseTime(transitionOptions[2]).toDouble(),
        // In order for CSS Transitions to be seeked backwards, they need to have their fill mode set to backwards
        // such that the original CSS value applied prior to the transition is used for a negative current time.
        fill: FillMode.backwards,
      );
    }

    return null;
  }

  Map<String, Animation> _propertyRunningTransition = {};

  bool _hasRunningTransition(String property) {
    return _propertyRunningTransition[property] != null;
  }

  void _transition(String propertyName, begin, end){
    if (_hasRunningTransition(propertyName)) {
      Animation animation = _propertyRunningTransition[propertyName];
      animation.cancel();
      CSSTransition.dispatchTransitionEvent(target, CSSTransitionEvent.cancel);
    }

    if (begin == null) {
      begin = LonghandPropertyInitialValues[propertyName];
    }

    EffectTiming options = _getTransitionEffectTiming(propertyName);
    List<Keyframe> keyframes = [
      Keyframe(propertyName, begin, 0, options.easing),
      Keyframe(propertyName, end, 1, options.easing),
    ];
    KeyframeEffect effect = KeyframeEffect(this, keyframes, options);
    Animation animation = Animation(effect);
    _propertyRunningTransition[propertyName] = animation;

    animation.onstart = () {
      CSSTransition.dispatchTransitionEvent(target, CSSTransitionEvent.start);
    };

    animation.onfinish = (AnimationPlaybackEvent event) {
      _propertyRunningTransition[propertyName] = null;
      CSSTransition.dispatchTransitionEvent(target, CSSTransitionEvent.end);
    };

    CSSTransition.dispatchTransitionEvent(target, CSSTransitionEvent.run);
    animation.play();
  }


  /// Textual representation of the declaration block.
  /// Setting this attribute changes the style.
  String get cssText {
    String css = EMPTY_STRING;
    _properties.forEach((property, value) {
      if (css.isNotEmpty) css += ' ';
      css += '$property: $value;';
    });
    return css;
  }

  // @TODO: Impl the cssText setter.

  /// The number of properties.
  int get length => _properties.length;

  /// Returns the property value given a property name.
  /// value is a String containing the value of the property.
  /// If not set, returns the empty string.
  String getPropertyValue(String propertyName) {
    return _properties[propertyName] ?? EMPTY_STRING;
  }

  /// Returns a property name.
  String item(int index) {
    return _properties.keys.elementAt(index);
  }

  /// Removes a property from the CSS declaration block.
  String removeProperty(String propertyName) {

    switch (propertyName) {
      case PADDING:
        CSSStyleProperty.removeShorthandPadding(_properties);
        break;
      case MARGIN:
        CSSStyleProperty.removeShorthandMargin(_properties);
        break;
      case BACKGROUND:
        CSSStyleProperty.removeShorthandBackground(_properties);
        break;
      case BORDER_RADIUS:
        CSSStyleProperty.removeShorthandBorderRadius(_properties);
        break;
      case OVERFLOW:
        CSSStyleProperty.removeShorthandOverflow(_properties);
        break;
      case FONT:
        CSSStyleProperty.removeShorthandFont(_properties);
        break;
      case FLEX:
        CSSStyleProperty.removeShorthandFlex(_properties);
        break;
      case FLEX_FLOW:
        CSSStyleProperty.removeShorthandFlexFlow(_properties);
        break;
      case BORDER:
      case BORDER_TOP:
      case BORDER_RIGHT:
      case BORDER_BOTTOM:
      case BORDER_LEFT:
      case BORDER_COLOR:
      case BORDER_STYLE:
      case BORDER_WIDTH:
        CSSStyleProperty.removeShorthandBorder(_properties, propertyName);
        break;
      case TRANSITION:
        CSSStyleProperty.removeShorthandTransition(_properties);
        break;
      case TEXT_DECORATION:
        CSSStyleProperty.removeShorthandTextDecoration(_properties);
        break;
    }

    String prevValue = EMPTY_STRING;

    if (_properties.containsKey(propertyName)) {
       prevValue = _properties[propertyName];
      _properties.remove(propertyName);
    }

    _invokePropertyChangedListener(propertyName, prevValue, EMPTY_STRING);

    return prevValue;
  }

  void _expandShorthand(String propertyName, String normalizedValue) {
    Map<String, String> longhandProperties = {};
    switch(propertyName) {
      case PADDING:
        CSSStyleProperty.setShorthandPadding(longhandProperties, normalizedValue);
        break;
      case MARGIN:
        CSSStyleProperty.setShorthandMargin(longhandProperties, normalizedValue);
        break;
      case BACKGROUND:
        CSSStyleProperty.setShorthandBackground(longhandProperties, normalizedValue);
        break;
      case BORDER_RADIUS:
        CSSStyleProperty.setShorthandBorderRadius(longhandProperties, normalizedValue);
        break;
      case OVERFLOW:
        CSSStyleProperty.setShorthandOverflow(longhandProperties, normalizedValue);
        break;
      case FONT:
        CSSStyleProperty.setShorthandFont(longhandProperties, normalizedValue);
        break;
      case FLEX:
        CSSStyleProperty.setShorthandFlex(longhandProperties, normalizedValue);
        break;
      case FLEX_FLOW:
        CSSStyleProperty.setShorthandFlexFlow(longhandProperties, normalizedValue);
        break;
      case BORDER:
      case BORDER_TOP:
      case BORDER_RIGHT:
      case BORDER_BOTTOM:
      case BORDER_LEFT:
      case BORDER_COLOR:
      case BORDER_STYLE:
      case BORDER_WIDTH:
        CSSStyleProperty.setShorthandBorder(longhandProperties, propertyName, normalizedValue);
        break;
      case TRANSITION:
        CSSStyleProperty.setShorthandTransition(longhandProperties, normalizedValue);
        break;
      case TEXT_DECORATION:
        CSSStyleProperty.setShorthandTextDecoration(longhandProperties, normalizedValue);
        break;
    }

    if (longhandProperties.isNotEmpty) {
      longhandProperties.forEach(setProperty);
    }
  }

  /// Modifies an existing CSS property or creates a new CSS property in
  /// the declaration block.
  void setProperty(String propertyName, value, [bool fromAnimation = false]) {
    // Null or empty value means should be removed.
    if (isNullOrEmptyValue(value)) {
      removeProperty(propertyName);
      return;
    }

    String normalizedValue = value.toString().trim();

    // Illegal value like '   ' after trim is '' shoud do nothing.
    if (normalizedValue.isEmpty) return;

    String prevValue = _properties[propertyName];
    if (normalizedValue == prevValue) return;

    if (ShorthandProperty[propertyName] != null) {
      return _expandShorthand(propertyName, normalizedValue);
    }

    if (!fromAnimation && _shouldTransition(propertyName)) {
      return _transition(propertyName, prevValue, normalizedValue);
    }

    switch (propertyName) {
      case WIDTH:
      case HEIGHT:
      case MIN_WIDTH:
      case MIN_HEIGHT:
      case MAX_WIDTH:
      case MAX_HEIGHT:
      case BORDER_BOTTOM_WIDTH:
      case BORDER_TOP_WIDTH:
      case BORDER_LEFT_WIDTH:
      case BORDER_RIGHT_WIDTH:
      case PADDING_TOP:
      case PADDING_LEFT:
      case PADDING_BOTTOM:
      case PADDING_RIGHT:
        // Validation length type
        if (!CSSLength.isLength(normalizedValue)) {
          return;
        }
        break;
      case MARGIN_TOP:
      case MARGIN_LEFT:
      case MARGIN_RIGHT:
      case MARGIN_BOTTOM:
        // Validation length type and keyword type
        if (!CSSLength.isLength(normalizedValue) && !CSSLength.isKeyword(normalizedValue)) {
          return;
        }
        break;
      case COLOR:
      case BACKGROUND_COLOR:
      case BORDER_BOTTOM_COLOR:
      case BORDER_TOP_COLOR:
      case BORDER_LEFT_COLOR:
      case BORDER_RIGHT_COLOR:
      case TEXT_DECORATION_COLOR:
        // Validation color type
        if (!CSSColor.isColor(normalizedValue)) {
          return;
        }
        break;
    }

    _properties[propertyName] = normalizedValue;
    _invokePropertyChangedListener(propertyName, prevValue, normalizedValue);
  }

  /// Override [] and []= operator to get/set style properties.
  operator [](String property) => getPropertyValue(property);
  operator []=(String property, value) {
    setProperty(property, value);
  }

  /// Check a css property is valid.
  bool contains(String property) {
    return _properties.containsKey(property) && _properties[property] != null;
  }

  void addStyleChangeListener(StyleChangeListener listener) {
    _styleChangeListeners.add(listener);
  }

  void removeStyleChangeListener(StyleChangeListener listener) {
    if (listener != null) {
      _styleChangeListeners.remove(listener);
    } else {
      _styleChangeListeners.clear();
    }
  }

  void _invokePropertyChangedListener(String property, String original, String present, [bool inAnimation]) {
    assert(property != null);

    _styleChangeListeners.forEach((StyleChangeListener listener) {
      listener(property, original, present, inAnimation);
    });
  }

  double getLengthByPropertyName(properyName) {
    return CSSLength.toDisplayPortValue(getPropertyValue(properyName));
  }

  static bool isNullOrEmptyValue(value) {
    return value == null || value == '';
  }

  @override
  String toString() => 'CSSStyleDeclaration($cssText)';
}
