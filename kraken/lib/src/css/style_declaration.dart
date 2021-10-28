/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'package:kraken/css.dart';
import 'package:kraken/dom.dart';
import 'package:kraken/rendering.dart';

typedef StyleChangeListener = void Function(String property,  String? original, String present);

const Map<String, bool> _CSSShorthandProperty = {
  MARGIN: true,
  PADDING: true,
  BACKGROUND: true,
  BACKGROUND_POSITION: true,
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

// Reorder the properties for control render style init order, the last is the largest.
List<String> _propertyOrders = [
  LINE_CLAMP,
  WHITE_SPACE,
  FONT_SIZE,
  COLOR,
  TRANSITION_DURATION,
  TRANSITION_PROPERTY,
  OVERFLOW_X,
  OVERFLOW_Y,
  DISPLAY
];

RegExp _kebabCaseReg = RegExp(r'[A-Z]');

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
  Element? target;
  // TODO(yuanyan): defualtStyle should be longhand properties.
  Map<String, dynamic>? defaultStyle;
  StyleChangeListener? onStyleChanged;

  CSSStyleDeclaration();
  // ignore: prefer_initializing_formals
  CSSStyleDeclaration.computedStyle(this.target, this.defaultStyle, this.onStyleChanged);

  /// An empty style declaration.
  static CSSStyleDeclaration empty = CSSStyleDeclaration();

  /// When some property changed, corresponding [StyleChangeListener] will be
  /// invoked in synchronous.
  final List<StyleChangeListener> _styleChangeListeners = [];

  final Map<String, String> _properties = {};
  Map<String, String> _pendingProperties = {};
  final Map<String, bool> _importants = {};

  /// Textual representation of the declaration block.
  /// Setting this attribute changes the style.
  String get cssText {
    String css = EMPTY_STRING;
    _properties.forEach((property, value) {
      if (css.isNotEmpty) css += ' ';
      css += '${_kebabize(property)}: $value;';
    });
    return css;
  }

  // @TODO: Impl the cssText setter.

  /// The number of properties.
  int get length => _properties.length;

  /// Returns a property name.
  String item(int index) {
    return _properties.keys.elementAt(index);
  }

  /// Returns the property value given a property name.
  /// value is a String containing the value of the property.
  /// If not set, returns the empty string.
  String getPropertyValue(String propertyName) {
    // Get the latest pending value first.
    return _pendingProperties[propertyName] ?? _properties[propertyName] ?? EMPTY_STRING;
  }

  /// Removes a property from the CSS declaration.
  String? removeProperty(String propertyName, [bool? isImportant]) {
    if (isImportant == true) {
      _importants.remove(propertyName);
    }

    String? prevValue = getPropertyValue(propertyName);
    String present = EMPTY_STRING;

    switch (propertyName) {
      case PADDING:
        CSSStyleProperty.removeShorthandPadding(this, isImportant);
        break;
      case MARGIN:
        CSSStyleProperty.removeShorthandMargin(this, isImportant);
        break;
      case BACKGROUND:
        CSSStyleProperty.removeShorthandBackground(this, isImportant);
        break;
      case BACKGROUND_POSITION:
        CSSStyleProperty.removeShorthandBackgroundPosition(this, isImportant);
        break;
      case BORDER_RADIUS:
        CSSStyleProperty.removeShorthandBorderRadius(this, isImportant);
        break;
      case OVERFLOW:
        CSSStyleProperty.removeShorthandOverflow(this, isImportant);
        break;
      case FONT:
        CSSStyleProperty.removeShorthandFont(this, isImportant);
        break;
      case FLEX:
        CSSStyleProperty.removeShorthandFlex(this, isImportant);
        break;
      case FLEX_FLOW:
        CSSStyleProperty.removeShorthandFlexFlow(this, isImportant);
        break;
      case BORDER:
      case BORDER_TOP:
      case BORDER_RIGHT:
      case BORDER_BOTTOM:
      case BORDER_LEFT:
      case BORDER_COLOR:
      case BORDER_STYLE:
      case BORDER_WIDTH:
        CSSStyleProperty.removeShorthandBorder(this, propertyName, isImportant);
        break;
      case TRANSITION:
        CSSStyleProperty.removeShorthandTransition(this, isImportant);
        break;
      case TEXT_DECORATION:
        CSSStyleProperty.removeShorthandTextDecoration(this, isImportant);
        break;
    }

    // Fallback to default style.
    if (defaultStyle != null && defaultStyle!.containsKey(propertyName)) {
      present = defaultStyle![propertyName];
    }

    // Update removed value by flush pending properties.
    _pendingProperties[propertyName] = present;
    return prevValue;
  }

  void _expandShorthand(String propertyName, String normalizedValue, bool? isImportant) {
    Map<String, String?> longhandProperties = {};
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
      case BACKGROUND_POSITION:
        CSSStyleProperty.setShorthandBackgroundPosition(longhandProperties, normalizedValue);
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
      longhandProperties.forEach((String propertyName, String? value) {
        setProperty(propertyName, value, isImportant);
      });
    }
  }

  String _replacePattern(String string, String lowerCase, String startString, String endString, [int start = 0]) {
    int startIndex = lowerCase.indexOf(startString, start);
    if (startIndex >= 0) {
      int? endIndex;
      int startStringLength = startString.length;
      startIndex  = startIndex + startStringLength;
      for (int i = startIndex; i < string.length; i++) {
        if (string[i] == endString) endIndex = i;
      }
      if (endIndex != null) {
        var replacement = string.substring(startIndex, endIndex);
        lowerCase = lowerCase.replaceRange(startIndex, endIndex, replacement);
        if (endIndex < string.length - 1) {
          lowerCase = _replacePattern(string, lowerCase, startString, endString, endIndex);
        }
      }
    }
    return lowerCase;
  }

  String _toLowerCase(String string) {
    // Like url("http://path") declared with quotation marks and
    // custom property names are case sensitive.
    String lowerCase = string.toLowerCase();
    lowerCase = _replacePattern(string, lowerCase, 'url(', ')');
     // var(--my-color) will be treated as a separate custom property to var(--My-color).
    lowerCase = _replacePattern(string, lowerCase, 'var(', ')');
    return lowerCase;
  }

  /// Modifies an existing CSS property or creates a new CSS property in
  /// the declaration block.
  void setProperty(String propertyName, value, [bool? isImportant]) {
    // Null or empty value means should be removed.
    if (isNullOrEmptyValue(value)) {
      removeProperty(propertyName, isImportant);
      return;
    }

    String normalizedValue = _toLowerCase(value.toString().trim());

    // Illegal value like '   ' after trim is '' should do nothing.
    if (normalizedValue.isEmpty) return;

    String? prevValue = getPropertyValue(propertyName);
    if (normalizedValue == prevValue) return;

    // If the important property is already set, we should ignore it.
    if (isImportant != true && _importants[propertyName] == true) {
      return;
    }

    if (_CSSShorthandProperty[propertyName] != null) {
      return _expandShorthand(propertyName, normalizedValue, isImportant);
    }

    // Validate value.
    switch (propertyName) {
      case WIDTH:
      case HEIGHT:
      case TOP:
      case LEFT:
      case RIGHT:
      case BOTTOM:
      case MARGIN_TOP:
      case MARGIN_LEFT:
      case MARGIN_RIGHT:
      case MARGIN_BOTTOM:
        // Validation length type
        if (!CSSLength.isLength(normalizedValue) &&
          !CSSLength.isAuto(normalizedValue) &&
          !CSSPercentage.isPercentage(normalizedValue)
        ) {
          return;
        }
        break;
      case MAX_WIDTH:
      case MAX_HEIGHT:
        if (normalizedValue != NONE &&
          !CSSLength.isLength(normalizedValue) &&
          !CSSPercentage.isPercentage(normalizedValue)
        ) {
          return;
        }
        break;
      case MIN_WIDTH:
      case MIN_HEIGHT:
      case PADDING_TOP:
      case PADDING_LEFT:
      case PADDING_BOTTOM:
      case PADDING_RIGHT:
        if (!CSSLength.isLength(normalizedValue) &&
          !CSSPercentage.isPercentage(normalizedValue)
        ) {
          return;
        }
        break;
      case BORDER_BOTTOM_WIDTH:
      case BORDER_TOP_WIDTH:
      case BORDER_LEFT_WIDTH:
      case BORDER_RIGHT_WIDTH:
        if (!CSSLength.isLength(normalizedValue)) {
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
        if (!CSSColor.isColor(normalizedValue)) return;
        break;
      case BACKGROUND_IMAGE:
        if (!CSSBackground.isValidBackgroundImageValue(normalizedValue)) return;
        break;
      case BACKGROUND_REPEAT:
        if (!CSSBackground.isValidBackgroundRepeatValue(normalizedValue)) return;
        break;
    }

    // Current only from inline style will mark the property as important.
    if (isImportant == true) {
      _importants[propertyName] = true;
    }

    _pendingProperties[propertyName] = normalizedValue;
  }

  void flushPendingProperties() {
    RenderBoxModel? renderBoxModel = target?.renderBoxModel;
    if (renderBoxModel == null) {
      return;
    }

    Map<String, String> pendingProperties = _pendingProperties;
    // Reset first avoid set property in flush stage.
    _pendingProperties = {};

    List<String> propertyNames = pendingProperties.keys.toList();
    for (String propertyName in _propertyOrders) {
      int index = propertyNames.indexOf(propertyName);
      if (index > -1) {
        propertyNames.removeAt(index);
        propertyNames.insert(0, propertyName);
      }
    }

    Map<String, String?> prevValues = {};
    for (String propertyName in propertyNames) {
      // Update the prevValue to currentValue.
      prevValues[propertyName] = _properties[propertyName];
      _properties[propertyName] = pendingProperties[propertyName]!;
    }

    for (String propertyName in propertyNames) {
      String? prevValue = prevValues[propertyName];
      String currentValue = pendingProperties[propertyName]!;
      _emitPropertyChanged(propertyName, prevValue, currentValue);
    }
  }

  Map<String, String?> diff(CSSStyleDeclaration other) {
    Map<String, String?> diffs = {};

    Map<String, String> properties = {}
      ..addAll(_properties)
      ..addAll(_pendingProperties);

    for (String propertyName in properties.keys) {
      String? prevValue = properties[propertyName];
      String? currentValue = other._pendingProperties[propertyName];

      if (isNullOrEmptyValue(prevValue) && isNullOrEmptyValue(currentValue)) {
        continue;
      } else if (!isNullOrEmptyValue(prevValue) && isNullOrEmptyValue(currentValue)) {
        // Remove property.
        diffs[propertyName] = null;
      } else if (prevValue != currentValue) {
        // Update property.
        diffs[propertyName] = currentValue;
      }
    }

    for (String propertyName in other._pendingProperties.keys) {
      String? prevValue = properties[propertyName];
      String? currentValue = other._pendingProperties[propertyName];
      if (isNullOrEmptyValue(prevValue) && !isNullOrEmptyValue(currentValue)) {
         // Add property.
        diffs[propertyName] = currentValue;
      }
    }
    return diffs;
  }

  /// Override [] and []= operator to get/set style properties.
  operator [](String property) => getPropertyValue(property);
  operator []=(String property, value) {
    setProperty(property, value);
  }

  /// Check a css property is valid.
  bool contains(String property) {
    return getPropertyValue(property).isNotEmpty;
  }

  void addStyleChangeListener(StyleChangeListener listener) {
    _styleChangeListeners.add(listener);
  }

  void removeStyleChangeListener(StyleChangeListener listener) {
    _styleChangeListeners.remove(listener);
  }

  void _emitPropertyChanged(String property, String? original, String present) {
    if (onStyleChanged != null) {
      onStyleChanged!(property, original, present);
    }

    for (int i = 0; i < _styleChangeListeners.length; i++) {
      StyleChangeListener listener = _styleChangeListeners[i];
      listener(property, original, present);
    }
  }

  void reset() {
    _properties.clear();
    _pendingProperties.clear();
    _importants.clear();
  }

  void dispose() {
    target = null;
    _styleChangeListeners.clear();
    reset();
  }

  static bool isNullOrEmptyValue(value) {
    return value == null || value == EMPTY_STRING;
  }

  @override
  String toString() => 'CSSStyleDeclaration($cssText)';
}

// aB to a-b
String _kebabize(String str) {
  return str.replaceAllMapped(_kebabCaseReg, (match) => '-${match[0]!.toLowerCase()}');
}
