/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'package:kraken/css.dart';

typedef StyleChangeListener = void Function(
  String property,
  String original,
  String present,
);

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
  CSSStyleDeclaration({Map<String, dynamic> style}) {
    if (style != null) {
      style.forEach((property, dynamic value) {
        if (value != null) setProperty(property, value: value.toString());
      });
    }
  }

  /// When some property changed, corresponding [StyleChangeListener] will be
  /// invoked in synchronous.
  List<StyleChangeListener> _styleChangeListeners = [];

  Map<String, String> _cssProperties = {};

  /// Textual representation of the declaration block.
  /// Setting this attribute changes the style.
  String get cssText {
    String css = '';
    _cssProperties.forEach((property, value) {
      if (css.isNotEmpty) css += ' ';
      css += '$property: $value;';
    });
    return css;
  }

  // @TODO: Impl the cssText setter.

  /// The number of properties.
  int get length => _cssProperties.length;

  /// Returns the property value given a property name.
  /// value is a String containing the value of the property.
  /// If not set, returns the empty string.
  String getPropertyValue(String propertyName) {
    return _cssProperties[propertyName] ?? '';
  }

  CSSValue _getCSSValue(String propertyName) {
    var stringValue = getPropertyValue(propertyName);

    switch (propertyName) {
      case WIDTH:
      case HEIGHT:
        return CSSLength(stringValue);

      // TODO: Add more css properties.
    }

    return null;
  }

  /// Returns a computed value.
  T getComputedValue<T>(String propertyName) {
    CSSValue cssValue = getComputedValue(propertyName);
    T computedValue = cssValue.computedValue;
    return computedValue;
  }

  /// Returns a property name.
  String item(int index) {
    return _cssProperties.keys.elementAt(index);
  }

  /// Removes a property from the CSS declaration block.
  String removeProperty(String propertyName) {
    String prevValue = getPropertyValue(propertyName);

    if (!isNullOrEmptyValue(prevValue)) {
      switch (propertyName) {
        case PADDING:
          CSSStyleProperty.removeShorthandPadding(_cssProperties);
          break;
        case MARGIN:
          CSSStyleProperty.removeShorthandMargin(_cssProperties);
          break;
        case BACKGROUND:
          CSSStyleProperty.removeShorthandBackground(_cssProperties);
          break;
        case BORDER_RADIUS:
          CSSStyleProperty.removeShorthandBorderRadius(_cssProperties);
          break;
        case OVERFLOW:
          CSSStyleProperty.removeShorthandOverflow(_cssProperties);
          break;
        case FONT:
          CSSStyleProperty.removeShorthandFont(_cssProperties);
          break;
        case FLEX:
          CSSStyleProperty.removeShorthandFlex(_cssProperties);
          break;
        case FLEX_FLOW:
          CSSStyleProperty.removeShorthandFlexFlow(_cssProperties);
          break;
        case BORDER:
        case BORDER_TOP:
        case BORDER_RIGHT:
        case BORDER_BOTTOM:
        case BORDER_LEFT:
        case BORDER_COLOR:
        case BORDER_STYLE:
        case BORDER_WIDTH:
          CSSStyleProperty.removeShorthandBorder(_cssProperties, propertyName);
          break;
        case TRANSITION:
          CSSStyleProperty.removeShorthandTransition(_cssProperties);
          break;
        case TEXT_DECORATION:
          CSSStyleProperty.removeShorthandTextDecoration(_cssProperties);
          break;
      }
      _cssProperties.remove(propertyName);
      _invokePropertyChangedListener(propertyName, prevValue, '');
    }

    return prevValue;
  }

  /// Modifies an existing CSS property or creates a new CSS property in
  /// the declaration block.
  void setProperty(String propertyName, {value = ''}) {
    // Null or empty value means should be removed.
    if (isNullOrEmptyValue(value)) {
      removeProperty(propertyName);
      return;
    }

    String normalizedValue = value.toString().trim();

    // Illegal value like '   ' after trim is '' shoud do nothing.
    if (normalizedValue.isEmpty) {
      return;
    }

    String prevValue = _cssProperties[propertyName];

    if (normalizedValue != prevValue) {
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
        case PADDING:
          CSSStyleProperty.setShorthandPadding(_cssProperties, normalizedValue);
          break;
        case MARGIN:
          CSSStyleProperty.setShorthandMargin(_cssProperties, normalizedValue);
          break;
        case BACKGROUND:
          CSSStyleProperty.setShorthandBackground(_cssProperties, normalizedValue);
          break;
        case BORDER_RADIUS:
          CSSStyleProperty.setShorthandBorderRadius(_cssProperties, normalizedValue);
          break;
        case OVERFLOW:
          CSSStyleProperty.setShorthandOverflow(_cssProperties, normalizedValue);
          break;
        case FONT:
          CSSStyleProperty.setShorthandFont(_cssProperties, normalizedValue);
          break;
        case FLEX:
          CSSStyleProperty.setShorthandFlex(_cssProperties, normalizedValue);
          break;
        case FLEX_FLOW:
          CSSStyleProperty.setShorthandFlexFlow(_cssProperties, normalizedValue);
          break;
        case BORDER:
        case BORDER_TOP:
        case BORDER_RIGHT:
        case BORDER_BOTTOM:
        case BORDER_LEFT:
        case BORDER_COLOR:
        case BORDER_STYLE:
        case BORDER_WIDTH:
          CSSStyleProperty.setShorthandBorder(_cssProperties, propertyName, normalizedValue);
          break;
        case TRANSITION:
          CSSStyleProperty.setShorthandTransition(_cssProperties, normalizedValue);
          break;
        case TEXT_DECORATION:
          CSSStyleProperty.setShorthandTextDecoration(_cssProperties, normalizedValue);
          break;
      }

      _cssProperties[propertyName] = normalizedValue;
      _invokePropertyChangedListener(propertyName, prevValue, normalizedValue);
    }
  }

  /// Override [] and []= operator to get/set style properties.
  operator [](String property) => getPropertyValue(property);
  operator []=(String property, value) {
    setProperty(property, value: value);
  }

  /// Check a css property is valid.
  bool contains(String property) {
    return _cssProperties.containsKey(property) && _cssProperties[property] != null;
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

  void _invokePropertyChangedListener(String property, String original, String present) {
    assert(property != null);
    _styleChangeListeners.forEach((StyleChangeListener listener) {
      listener(property, original, present);
    });
  }

  double getLengthByPropertyName(properyName) {
    return CSSLength.toDisplayPortValue(getPropertyValue(properyName));
  }

  CSSStyleDeclaration copyWith(Map<String, String> override) {
    Map<String, dynamic> mergedProperties = {};
    var copy = (property, value) {
      mergedProperties[property] = value;
    };
    _cssProperties.forEach(copy);
    override?.forEach(copy);
    return CSSStyleDeclaration(style: mergedProperties);
  }

  static bool isNullOrEmptyValue(value) {
    return value == null || value == '';
  }

  @override
  String toString() => 'CSSStyleDeclaration($cssText)';
}

// Returns the computed property value.
T getComputedStyle<T>(CSSStyleDeclaration style, String propertyName) {
  assert(style != null);
  CSSValue cssValue = style._getCSSValue(propertyName);
  return cssValue?.computedValue;
}
