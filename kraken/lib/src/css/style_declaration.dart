

/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'dart:ui';

import 'package:kraken/css.dart';
import 'package:kraken/dom.dart';
import 'package:kraken/rendering.dart';
import 'package:kraken/src/css/animation.dart';

const String SAFE_AREA_INSET = 'safe-area-inset';
const String SAFE_AREA_INSET_TOP = '$SAFE_AREA_INSET-top';
const String SAFE_AREA_INSET_LEFT = '$SAFE_AREA_INSET-left';
const String SAFE_AREA_INSET_RIGHT = '$SAFE_AREA_INSET-right';
const String SAFE_AREA_INSET_BOTTOM = '$SAFE_AREA_INSET-bottom';

typedef StyleChangeListener = void Function(String property,  String? original, String present);

// https://github.com/WebKit/webkit/blob/master/Source/WebCore/css/CSSProperties.json

Map CSSInitialValues = {
  BACKGROUND_COLOR: TRANSPARENT,
  BACKGROUND_POSITION: '0% 0%',
  BORDER_BOTTOM_COLOR: CURRENT_COLOR,
  BORDER_LEFT_COLOR: CURRENT_COLOR,
  BORDER_RIGHT_COLOR: CURRENT_COLOR,
  BORDER_TOP_COLOR: CURRENT_COLOR,
  BORDER_BOTTOM_LEFT_RADIUS: ZERO,
  BORDER_BOTTOM_RIGHT_RADIUS: ZERO,
  BORDER_TOP_LEFT_RADIUS: ZERO,
  BORDER_TOP_RIGHT_RADIUS: ZERO,
  BORDER_BOTTOM_WIDTH: '3px',
  BORDER_RIGHT_WIDTH: '3px',
  BORDER_LEFT_WIDTH: '3px',
  BORDER_TOP_WIDTH: '3px',
  // Depends on user agent.
  COLOR: CSSColor.INITIAL_COLOR,
  FONT_SIZE: '100%',
  FONT_WEIGHT: '400',
  LINE_HEIGHT: '120%',
  LETTER_SPACING: NORMAL,
  PADDING_BOTTOM: ZERO,
  PADDING_LEFT: ZERO,
  PADDING_RIGHT: ZERO,
  PADDING_TOP: ZERO,
  MARGIN_BOTTOM: ZERO,
  MARGIN_LEFT: ZERO,
  MARGIN_RIGHT: ZERO,
  MARGIN_TOP: ZERO,
  HEIGHT: AUTO,
  WIDTH: AUTO,
  MAX_HEIGHT: NONE,
  MAX_WIDTH: NONE,
  MIN_HEIGHT: ZERO,
  MIN_WIDTH: ZERO,
  OPACITY: '1.0',
  LEFT: AUTO,
  BOTTOM: AUTO,
  RIGHT: AUTO,
  TOP: AUTO,
  TEXT_SHADOW: '0px 0px 0px transparent',
  TRANSFORM: 'matrix3d(${CSSTransform.initial.storage.join(',')})',
  VERTICAL_ALIGN: ZERO,
  VISIBILITY: VISIBLE,
  WORD_SPACING: NORMAL,
  Z_INDEX: AUTO
};

const Map<String, bool> CSSShorthandProperty = {
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
List<String> _propertyOrders = [FONT_SIZE, OVERFLOW_X, OVERFLOW_Y, DISPLAY];

RegExp _kebabCaseReg = RegExp(r'[A-Z]');
RegExp _camelCaseReg = RegExp(r'-(\w)');

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
  final Map<String, String> _animationProperties = {};

  final Map<String, bool> _importants = {};
  Map<String, List> _transitions = {};

  String getCurrentColor() {
    String? currentColor = _properties[COLOR];
    return currentColor ?? CSSColor.INITIAL_COLOR;
  }

  set transitions(Map<String, List> value) {
    _transitions = value;
  }

  bool _shouldTransition(String property, String? prevValue, String nextValue, RenderBoxModel? renderBoxModel) {
    // When begin propertyValue is AUTO, skip animation and trigger style update directly.
    if (CSSLength.isAuto(prevValue) || CSSLength.isAuto(nextValue)) {
      return false;
    }

    // Transition does not work when renderBoxModel has not been layout yet.
    if (renderBoxModel != null && renderBoxModel.attached && CSSTransformHandlers[property] != null &&
      (_transitions.containsKey(property) || _transitions.containsKey(ALL))) {
      bool shouldTransition = false;
      // Transition will be disabled when all transition has transitionDuration as 0.
      _transitions.forEach((String transitionKey, List transitionOptions) {
        double duration = CSSTime.parseTime(transitionOptions[0]).toDouble();
        if (duration != 0) {
          shouldTransition = true;
        }
      });
      return shouldTransition;
    }
    return false;
  }

  EffectTiming? _getTransitionEffectTiming(String property) {

    List? transitionOptions = _transitions[property] ?? _transitions[ALL];
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

  final Map<String, Animation> _propertyRunningTransition = {};

  bool _hasRunningTransition(String property) {
    return _propertyRunningTransition.containsKey(property);
  }

  void _transition(String propertyName, begin, end, Size? viewportSize, RenderStyle? renderStyle) {
    if (_hasRunningTransition(propertyName)) {
      Animation animation = _propertyRunningTransition[propertyName]!;
      animation.cancel();
      CSSTransition.dispatchTransitionEvent(target, CSSTransitionEvent.cancel);
      // Maybe set transition twice in a same frame. should check animationProperties has contains propertyName.
      if (_animationProperties.containsKey(propertyName)) {
        begin = _animationProperties[propertyName];
      }
    }

    if (begin == null) {
      begin = CSSInitialValues[propertyName];

      if (begin == CURRENT_COLOR) {
        begin = getCurrentColor();
      }

      // When begin propertyValue is AUTO, skip animation and trigger style update directly.
      if (begin == AUTO) {
        _properties[propertyName] = end;
        _emitPropertyChanged(propertyName, begin, end);
        return;
      }
    }

    EffectTiming? options = _getTransitionEffectTiming(propertyName);

    List<Keyframe> keyframes = [
      Keyframe(propertyName, begin, 0, LINEAR),
      Keyframe(propertyName, end, 1, LINEAR),
    ];
    KeyframeEffect effect = KeyframeEffect(this, target, keyframes, options, viewportSize, renderStyle);
    Animation animation = Animation(effect);
    _propertyRunningTransition[propertyName] = animation;

    animation.onstart = () {
      CSSTransition.dispatchTransitionEvent(target, CSSTransitionEvent.start);
    };

    animation.onfinish = (AnimationPlaybackEvent event) {
      _setTransitionEndProperty(propertyName, begin, end);
      _propertyRunningTransition.remove(propertyName);
      CSSTransition.dispatchTransitionEvent(target, CSSTransitionEvent.end);
    };

    CSSTransition.dispatchTransitionEvent(target, CSSTransitionEvent.run);
    animation.play();
  }

  _setTransitionEndProperty(String propertyName, String? prevValue, String value) {
    if (value == prevValue) return;
    _properties[propertyName] = value;
    _emitPropertyChanged(propertyName, prevValue, value);
  }

  /// Textual representation of the declaration block.
  /// Setting this attribute changes the style.
  String get cssText {
    String css = EMPTY_STRING;
    _properties.forEach((property, value) {
      if (css.isNotEmpty) css += ' ';
      css += '${kebabize(property)}: $value;';
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
    String value = _pendingProperties[propertyName] ?? _properties[propertyName] ??  EMPTY_STRING;
    return value == CURRENT_COLOR ? getCurrentColor() : value;
  }

  String? removeAnimationProperty(String propertyName) {
    String? prevValue = EMPTY_STRING;

    if (_animationProperties.containsKey(propertyName)) {
       prevValue = _animationProperties[propertyName];
      _animationProperties.remove(propertyName);
    }

    return prevValue;
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

    // But if display change, need emit change event.
    if (propertyName == DISPLAY) {
      present = present == EMPTY_STRING ? INLINE : present;
    }

    // Update removed value by flush pending properties.
    _pendingProperties[propertyName] = present;
    return prevValue;
  }

  void _expandShorthand(String propertyName, String normalizedValue, bool? isImportant, Size? viewportSize) {
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
        setProperty(propertyName, value, isImportant, viewportSize);
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

  String _normalizeValue(value) {
    String result = _toLowerCase(value.toString().trim());

    if (CSSFunction.isFunction(result)) {
      String normalizedFunctionValue = '';
      List<CSSFunctionalNotation> funcs = CSSFunction.parseFunction(result);
      for (CSSFunctionalNotation func in funcs) {
        String loweredFuncName = func.name.toLowerCase();
        if (loweredFuncName == 'env' && func.args.isNotEmpty) {
          String? defaultValue = func.args.length > 1 ? func.args[1] : null;
          switch (func.args.first) {
            case SAFE_AREA_INSET_TOP:
              normalizedFunctionValue += '${window.viewPadding.top / window.devicePixelRatio}${CSSLength.PX}$FUNCTION_SPLIT';
              break;
            case SAFE_AREA_INSET_RIGHT:
              normalizedFunctionValue += '${window.viewPadding.right / window.devicePixelRatio}${CSSLength.PX}$FUNCTION_SPLIT';
              break;
            case SAFE_AREA_INSET_BOTTOM:
              normalizedFunctionValue += '${window.viewPadding.bottom / window.devicePixelRatio}${CSSLength.PX}$FUNCTION_SPLIT';
              break;
            case SAFE_AREA_INSET_LEFT:
              normalizedFunctionValue += '${window.viewPadding.left / window.devicePixelRatio}${CSSLength.PX}$FUNCTION_SPLIT';
              break;
            default:
              normalizedFunctionValue += '$defaultValue$FUNCTION_SPLIT';
              break;
          }
        } else if (loweredFuncName == 'var') {
          // TODO: impl CSS Variables.
        } else {
          normalizedFunctionValue += '${func.name}(${func.args.join(FUNCTION_ARGS_SPLIT)})$FUNCTION_SPLIT';
        }
      }
      result = normalizedFunctionValue.substring(0, normalizedFunctionValue.length - 1);
    }

    return result;
  }

  /// Modifies an existing CSS property or creates a new CSS property in
  /// the declaration block.
  void setProperty(String propertyName, value, [bool? isImportant, Size? viewportSize]) {
    // Null or empty value means should be removed.
    if (isNullOrEmptyValue(value)) {
      removeProperty(propertyName, isImportant);
      return;
    }

    String normalizedValue = _normalizeValue(value);

    // Illegal value like '   ' after trim is '' should do nothing.
    if (normalizedValue.isEmpty) return;

    String? prevValue = getPropertyValue(propertyName);
    if (normalizedValue == prevValue) return;

    // If the important property is already set, we should ignore it.
    if (isImportant != true && _importants[propertyName] == true) {
      return;
    }

    if (CSSShorthandProperty[propertyName] != null) {
      return _expandShorthand(propertyName, normalizedValue, isImportant, viewportSize);
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
          !CSSLength.isPercentage(normalizedValue)
        ) {
          return;
        }
        break;
      case MAX_WIDTH:
      case MAX_HEIGHT:
        if (normalizedValue != NONE &&
          !CSSLength.isLength(normalizedValue) &&
          !CSSLength.isPercentage(normalizedValue)
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
          !CSSLength.isPercentage(normalizedValue)
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
      case TRANSFORM:
        if (!CSSTransform.isValidTransformValue(normalizedValue, viewportSize)) return;
        break;
    }

    // Current only from inline style will mark the property as important.
    if (isImportant == true) {
      _importants[propertyName] = true;
    }

    // Should direct update render style if display is 'none' and changed to other value.
    if (propertyName == DISPLAY && prevValue == NONE) {
      _emitPropertyChanged(propertyName, prevValue, normalizedValue);
      _pendingProperties.remove(propertyName);
      _properties[propertyName] = normalizedValue;
      return;
    }

    _pendingProperties[propertyName] = normalizedValue;

    switch (propertyName) {
      case TRANSITION_DELAY:
      case TRANSITION_DURATION:
      case TRANSITION_TIMING_FUNCTION:
      case TRANSITION_PROPERTY:
        CSSTransition.updateTransition(this);
        break;
    }

    // https://github.com/WebKit/webkit/blob/master/Source/WebCore/animation/AnimationTimeline.cpp#L257
    // Any animation found in previousAnimations but not found in newAnimations is not longer current and should be canceled.
    // @HACK: There are no way to get animationList from styles(Webkit will create an new Style object when style changes, but Kraken not).
    // Therefore we should cancel all running transition to get thing works.
    if (propertyName == TRANSITION_PROPERTY && _propertyRunningTransition.isNotEmpty) {
      for (String property in _propertyRunningTransition.keys) {
        _propertyRunningTransition[property]!.finish();
      }
      _propertyRunningTransition.clear();
    }

  }

  void flushPendingProperties() {
    RenderBoxModel? renderBoxModel = target?.renderBoxModel;
    if (renderBoxModel == null) {
      return;
    }

    List<String> propertyNames = _pendingProperties.keys.toList();
    Map<String, String> pendingProperties = _pendingProperties;
    // Reset first avoid set property in flush stage.
    _pendingProperties = {};

    for (String propertyName in _propertyOrders) {
      int index = propertyNames.indexOf(propertyName);
      if (index > -1) {
        propertyNames.removeAt(index);
        propertyNames.insert(0, propertyName);
      }
    }

    for (String propertyName in propertyNames) {
      // Update the prevValue to currentValue.
      _properties[propertyName] = pendingProperties[propertyName]!;
    }

    for (String propertyName in propertyNames) {
      String? prevValue = _properties[propertyName];
      String? currentValue = pendingProperties[propertyName];
      if (currentValue == null) {
        break;
      }
      RenderStyle? renderStyle = target?.renderStyle;
      if (_shouldTransition(propertyName, prevValue, currentValue, renderBoxModel)) {
        _transition(propertyName, prevValue, currentValue, target?.viewportSize, renderStyle);
      } else {
        _emitPropertyChanged(propertyName, prevValue, currentValue);
      }
    }

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

  /// Set all style properties with em unit.
  void applyEmProperties() {
    _properties.forEach((key, value) {
      if (key != FONT_SIZE && value.endsWith(CSSLength.EM)) {
        String normalizedValue = _normalizeValue(value);
        _emitPropertyChanged(key, null, normalizedValue);
      }
    });
  }

  /// Set all style properties with rem unit.
  void applyRemProperties() {
    _properties.forEach((key, value) {
      if (key != FONT_SIZE && value.endsWith(CSSLength.REM)) {
        String normalizedValue = _normalizeValue(value);
        _emitPropertyChanged(key, null, normalizedValue);
      }
    });
  }

  void reset() {
    _properties.clear();
    _pendingProperties.clear();
    _animationProperties.clear();
    _transitions.clear();
    _propertyRunningTransition.clear();
    _importants.clear();
  }

  void dispose() {
    target = null;
    _styleChangeListeners.clear();
    reset();
  }

  static bool isNullOrEmptyValue(value) {
    return value == null || value == '';
  }

  @override
  String toString() => 'CSSStyleDeclaration($cssText)';
}

// aB to a-b
String kebabize(String str) {
  return str.replaceAllMapped(_kebabCaseReg, (match) => '-${match[0]!.toLowerCase()}');
}

// a-b to aB
String camelize(String str) {
  return str.replaceAllMapped(_camelCaseReg, (match) {
    String subStr = match[0]!.substring(1);
    return subStr.isNotEmpty ? subStr.toUpperCase() : '';
  });
}
