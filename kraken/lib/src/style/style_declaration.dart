/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'package:kraken/src/style/types/color.dart';
import 'package:kraken/src/style/types/length.dart';
import 'package:kraken/src/style/types/numeric.dart';

const String STYLE = 'style';

typedef StyleChangeListener = void Function(
  String property,
  String original,
  String present,
);

typedef ConsumeProperty = bool Function(String src);

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
      if (style.containsKey('background')) {
        String background = style['background'];
        _consumeBackgroundShorthand(background?.split(' '), false);
      }
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
    if (property == 'background') {
      _consumeBackgroundShorthand(value.toString().split(' '), true);
    } else {
      this.setProperty(property, value: value);
    }
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

  void _consumeBackgroundShorthand(List<String> shorthand, bool update) {
    int longhandCount = shorthand.length;
    Map<String, ConsumeProperty> propertyMap = {
      'backgroundImage': consumeBackgroundImage,
      'backgroundRepeat': consumeBackgroundRepeat,
      'backgroundAttachment': consumeBackgroundAttachment,
      'backgroundPositionAndSize': consumeBackgroundPosition
    };
    // default property
    Map<String, String> background = {
      'backgroundRepeat': 'repeat',
      'backgroundAttachment': 'scroll',
      'backgroundPosition': 'left top',
      'backgroundImage': '',
      'backgroundSize': 'auto',
      'backgroundColor': 'transparent'
    };
    bool broken = false;
    for (int i = 0; i < longhandCount; i++) {
      if (broken) {
        break;
      }
      String property = shorthand[i].trim();
      Iterable<String> keys = propertyMap.keys;
      // record the consumed property
      String consumedKey;
      for (String key in keys) {
        // position may be more than one(at most four), should special handle
        // size is follow position and split by /
        if (key == 'backgroundPositionAndSize') {
          if (property != '/' && property.contains('/')) {
            int index = property.indexOf('/');
            String position = property.substring(0, index);
            if (consumeBackgroundPosition(position)) {
              background['backgroundPosition'] = position;
              String size = property.substring(index + 1);
              if (consumeBackgroundSize(size)) {
                // size at most two value
                if (i + 1 < longhandCount &&
                  consumeBackgroundSize(shorthand[i + 1].trim())) {
                  size = size + ' ' + shorthand[i + 1].trim();
                  i++;
                }
                background['backgroundSize'] = size;
              } else {
                broken = true;
                break;
              }
              consumedKey = key;
            } else {
              broken = true;
              break;
            }
          } else if (consumeBackgroundPosition(property)) {
            String position = property;
            String size;
            bool hasSize = false;
            // position at most four value
            for (int j = 1; j <= 4; j ++) {
              if (i + j < longhandCount) {
                String temp = shorthand[i + j].trim();
                if (temp == '/') {
                  i = i + j;
                  hasSize = true;
                  break;
                } else if (temp.contains('/')) {
                  i = i + j;
                  hasSize = true;
                  int index = temp.indexOf('/');
                  String positionTemp = temp.substring(0, index);
                  if (consumeBackgroundPosition(positionTemp)) {
                    background['backgroundPosition'] = position;
                    size = property.substring(index + 1);
                    if (!consumeBackgroundSize(size)) {
                      broken = true;
                    }
                  } else {
                    broken = true;
                  }
                  break;
                } else if (consumeBackgroundPosition(temp)) {
                  position = position + ' ' + temp;
                } else {
                  i = i + j - 1;
                  break;
                }
              } else {
                break;
              }
            }
            // handle size when / follow, at most two value
            if (hasSize) {
              if (i + 1 < longhandCount) {
                String nextSize = shorthand[i + 1].trim();
                if (size == null) {
                  size = nextSize;
                  if (consumeBackgroundSize(size)) {
                    i++;
                    if (i + 1 < longhandCount) {
                      if (consumeBackgroundSize(shorthand[i + 1].trim())) {
                        size = size + ' ' + shorthand[i + 1].trim();
                        i++;
                      }
                    }
                    background['backgroundSize'] = size;
                  } else {
                    broken = true;
                    break;
                  }
                } else if (consumeBackgroundSize(nextSize)) {
                  size = size + ' ' + nextSize;
                  background['backgroundSize'] = size;
                } else {
                  broken = true;
                  break;
                }
              } else {
                broken = true;
                break;
              }
            }
            consumedKey = key;
            break;
          }
        } else if (propertyMap[key](property)) {
          background[key] = property;
          consumedKey = key;
          break;
        }
      }
      // consumed the property when find
      if (consumedKey != null) {
        propertyMap.remove(consumedKey);
      } else if (i == longhandCount - 1) {
        background['backgroundColor'] = property;
      }
    }
    // shorthand error don not set value
    if (!broken) {
      background.forEach((key, value) {
        setPropertyByShorthand(key, value, update);
      });
    }
  }

  bool consumeBackgroundRepeat(String src) {
    return 'repeat-x' == src || 'repeat-y' == src || 'repeat' == src ||
        'no-repeat' == src;
  }

  bool consumeBackgroundAttachment(String src) {
    return 'fixed' == src || 'scroll' == src || 'local' == src;
  }

  bool consumeBackgroundImage(String src) {
    return src.startsWith('url(') || src.startsWith('linear-gradient(') ||
      src.startsWith('repeating-linear-gradient(') ||
      src.startsWith('radial-gradient(') ||
      src.startsWith('repeating-radial-gradient(') ||
      src.startsWith('conic-gradient(');
  }

  bool consumeBackgroundPosition(String src) {
    return src == 'center' || src == 'left' || src == 'right' ||
      Length.isLength(src) || Percentage.isPercentage(src) || src == 'top' ||
      src == 'bottom';
  }

  bool consumeBackgroundSize(String src) {
    return src == 'auto' || src == 'contain' || src == 'cover' ||
      src == 'fit-width' || src == 'fit-height' || src == 'scale-down' ||
      src == 'fill' || Length.isLength(src) || Percentage.isPercentage(src);
  }

  void setPropertyByShorthand(String key, String value, bool update) {
    if (update) {
      setProperty(key, value: value);
    } else if (!_cssProperties.containsKey(key)) {
      _cssProperties[key] = value;
    }
  }
}

bool isEmptyStyleValue(String value) {
  return value == null || value.isEmpty;
}
