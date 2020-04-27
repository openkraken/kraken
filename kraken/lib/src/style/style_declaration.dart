/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
const String STYLE = 'style';

typedef StyleChangeListener = void Function(
  String property,
  String original,
  String present,
);

/// The [StyleDeclaration] interface represents an object that is a CSS
/// declaration block, and exposes style information and various style-related
/// methods and properties.
///
/// A [StyleDeclaration] object can be exposed using three different APIs:
/// 1. Via [HTMLElement.style], which deals with the inline styles of a single
///    element (e.g., <div style="...">).
/// 2. Via the [CSSStyleSheet] API. For example,
///    document.styleSheets[0].cssRules[0].style returns a [StyleDeclaration]
///    object on the first CSS rule in the document's first stylesheet.
/// 3. Via [Window.getComputedStyle()], which exposes the [StyleDeclaration]
///    object as a read-only interface.
class StyleDeclaration {
  StyleDeclaration({ Map<String, dynamic> style }) {
    if (style != null ) {
      style.forEach((property, value) {
        if (value != null) this.setProperty(property, value: value.toString());
      });
    }
  }

  /// When some property changed, corresponding [StyleChangeListener] will be
  /// invoked in synchronous.
  Map<String, List<StyleChangeListener>> _styleChangeListeners = {};

  Map<String, String> _cssProperties = {};

  /// Textual representation of the declaration block.
  /// Setting this attribute changes the style.
  String get cssText {
    String _cssText = '';
    _cssProperties.forEach((property, value) {
      if (_cssText.isNotEmpty) _cssText += ' ';
      _cssText += '$property: $value;';
    });
    return _cssText;
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

  /// Returns a property name.
  String item(int index) {
    return _cssProperties.keys.elementAt(index);
  }

  /// Removes a property from the CSS declaration block.
  String removeProperty(String property) {
    return _cssProperties.remove(property);
  }

  /// Modifies an existing CSS property or creates a new CSS property in
  /// the declaration block.
  void setProperty(String propertyName, { value = '' }) {
    // Null means with should be removed.
    String prevValue = _cssProperties[propertyName];
    String stringifyValue;
    if (value == null) {
      _cssProperties.remove(propertyName);
    } else {
      stringifyValue = value.toString();
      _cssProperties[propertyName] = stringifyValue;
    }

    if (value != prevValue) {
      _invokePropertyChangedListener(propertyName, prevValue, stringifyValue);
    }
  }

  /// Override [] and []= operator to get/set style properties.
  operator [](String property) => this.getPropertyValue(property);
  operator []=(String property, value) {
    this.setProperty(property, value: value);
  }

  /// Check a css property is valid.
  bool contains(String property) {
    String value = getPropertyValue(property);
    return !isEmptyStyleValue(value);
  }

  void addStyleChangeListener(String property, StyleChangeListener listener) {
    if (!_styleChangeListeners.containsKey(property)) _styleChangeListeners[property] = [];
    _styleChangeListeners[property].add(listener);
  }

  void removeStyleChangeListener({ String property }) {
    if (property != null) {
      _styleChangeListeners[property] = [];
    } else {
      // Remove all if no property specified.
      _styleChangeListeners = {};
    }
  }

  void _invokePropertyChangedListener(String property, String original, String present) {
    assert(property != null);
    _styleChangeListeners[property]?.forEach((StyleChangeListener listener) {
      listener(property, original, present);
    });
  }

  StyleDeclaration copyWith(Map<String, String> override) {
    Map<String, dynamic> mergedProperties = {};
    var copy = (property, value) {
      mergedProperties[property] = value;
    };
    this._cssProperties.forEach(copy);
    override?.forEach(copy);
    return StyleDeclaration(style: mergedProperties);
  }

  @override
  String toString() => 'StyleDeclaration($cssText)';
}

bool isEmptyStyleValue(String value) {
  return value == null || value.isEmpty;
}
