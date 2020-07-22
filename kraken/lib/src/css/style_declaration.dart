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
      if (propertyName == PADDING) {
        CSSStyleProperty.removeShorthandPadding(_cssProperties);
      } else if (propertyName == MARGIN) {
        CSSStyleProperty.removeShorthandMargin(_cssProperties);
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
    if (normalizedValue == '') {
      return;
    }

    String prevValue = _cssProperties[propertyName];

    if (normalizedValue != prevValue) {
      if (propertyName == PADDING) {
        CSSStyleProperty.setShorthandPadding(_cssProperties, normalizedValue);
      } else if (propertyName == MARGIN) {
        CSSStyleProperty.setShorthandMargin(_cssProperties, normalizedValue);
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
    String value = getPropertyValue(property);
    return !CSSStyleDeclaration.isNullOrEmptyValue(value);
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
