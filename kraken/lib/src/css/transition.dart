import 'dart:ui';

import 'package:flutter/animation.dart';
import 'package:kraken/element.dart';
import 'package:kraken/scheduler.dart';
import 'package:kraken/rendering.dart';
import 'package:kraken/css.dart';

// CSS Transitions: https://drafts.csswg.org/css-transitions/
const String _0s = '0s';
const String _transitionRun = 'transitionrun';
const String _transitionStart = 'transitionstart';
const String _transitionEnd = 'transitionend';
const String _transitionCancel = 'transitioncancel';

String _toCamelCase(String s) {
  var sb = StringBuffer();
  var shouldUpperCase = false;
  s.runes.forEach((int rune) {
    // '-' char code is 45
    if (rune == 45) {
      shouldUpperCase = true;
    } else {
      var char = String.fromCharCode(rune);
      if (shouldUpperCase) {
        sb.write(char.toUpperCase());
      } else {
        sb.write(char);
      }
    }
  });
  return sb.toString();
}

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

const ShorthandPropertyTransitionSupport = {
  MARGIN: [MARGIN_BOTTOM, MARGIN_LEFT, MARGIN_RIGHT, MARGIN_TOP],
  PADDING: [PADDING_BOTTOM, PADDING_LEFT, PADDING_RIGHT, PADDING_TOP],
  BACKGROUND: [BACKGROUND_COLOR],
  BORDER_RADIUS: [BORDER_BOTTOM_LEFT_RADIUS, BORDER_BOTTOM_RIGHT_RADIUS, BORDER_TOP_LEFT_RADIUS, BORDER_TOP_RIGHT_RADIUS],
  BORDER: [
    BORDER_BOTTOM_COLOR, BORDER_LEFT_COLOR, BORDER_RIGHT_COLOR, BORDER_TOP_COLOR,
    BORDER_BOTTOM_WIDTH, BORDER_LEFT_WIDTH, BORDER_RIGHT_WIDTH, BORDER_TOP_WIDTH
  ],
  BORDER_COLOR: [BORDER_BOTTOM_COLOR, BORDER_LEFT_COLOR, BORDER_RIGHT_COLOR, BORDER_TOP_COLOR],
  BORDER_WIDTH: [BORDER_BOTTOM_WIDTH, BORDER_LEFT_WIDTH, BORDER_RIGHT_WIDTH, BORDER_TOP_WIDTH],
  FONT: [FONT_SIZE, FONT_WEIGHT],
};

mixin CSSTransitionMixin on Node {
  Throttling throttler = Throttling();
  Map<String, CSSTransition> transitionMap;

  void updateTransition(CSSStyleDeclaration style) {
    Map<String, CSSTransition> map = {};

    List<String> transitionProperty = CSSStyleProperty.getMultipleValues(style[TRANSITION_PROPERTY]) ?? [ALL];
    List<String> transitionDuration = CSSStyleProperty.getMultipleValues(style[TRANSITION_DURATION]) ?? [_0s];
    List<String> transitionTimingFunction = CSSStyleProperty.getMultipleValues(style[TRANSITION_TIMING_FUNCTION]) ?? [EASE];
    List<String> transitionDelay = CSSStyleProperty.getMultipleValues(style[TRANSITION_DELAY]) ?? [_0s];

    for (int i = 0; i < transitionProperty.length; i++) {
      String property = _toCamelCase(transitionProperty[i]);
      String function = transitionTimingFunction.length == 1 ? transitionTimingFunction[0] : transitionTimingFunction[i];
      String duration = transitionDuration.length == 1 ? transitionDuration[0] : transitionDuration[i];
      String delay = transitionDelay.length == 1 ? transitionDelay[0] : transitionDelay[i];

      Curve curve = CSSTransition._parseFunction(function);
      if (curve != null) {
        // @TODO: lazy init css transition
        CSSTransition transition = CSSTransition();
        AnimationController controller =
            AnimationController(duration: Duration(milliseconds: CSSTime.parseTime(duration)), vsync: transition);
        transition.curvedAnimation = CurvedAnimation(curve: curve, parent: controller);
        transition.controller = controller;
        transition.delay = Duration(milliseconds: CSSTime.parseTime(delay));

        map[property] = transition;

        if (ShorthandPropertyTransitionSupport.containsKey(property)) {
          ShorthandPropertyTransitionSupport[property].forEach((property) {
            map[property] = transition;
          });
        }
      }
    }

    transitionMap = map;
  }

  void updateTransitionEvent(CSSTransition transition) {
    transition?._setTransitionListener(_dispatchTransitionEvent);
    transition?._listen();
  }

  // Update background color
  Color getProgressColor(double progress, Color newColor, Color oldColor) {
    if (newColor.value != oldColor.value) {
      int alphaDiff = newColor.alpha - oldColor.alpha;
      int redDiff = newColor.red - oldColor.red;
      int greenDiff = newColor.green - oldColor.green;
      int blueDiff = newColor.blue - oldColor.blue;

      return Color.fromARGB(
        (alphaDiff * progress).toInt() + oldColor.alpha,
        (redDiff * progress).toInt() + oldColor.red,
        (blueDiff * progress).toInt() + oldColor.blue,
        (greenDiff * progress).toInt() + oldColor.green
      );
    }
    return newColor;
  }

  Radius getProgressRaduis(double progress, Radius newRadius, Radius oldRadius) {
    double radiusDiffX = newRadius.x - oldRadius.x;
    double radiusDiffY = newRadius.y - oldRadius.y;
    return Radius.elliptical(radiusDiffX * progress + oldRadius.x, radiusDiffY * progress + oldRadius.y);
  }

  double getProgressLength(double progress, double newLength, double oldLength) {
    double lenghtDiff = newLength - oldLength;
    return lenghtDiff * progress + oldLength;
  }

  void _dispatchTransitionEvent(CSSTransitionEvent status) {
    if (status == CSSTransitionEvent.run) {
      dispatchEvent(Event(_transitionRun));
    } else if (status == CSSTransitionEvent.cancel) {
      // An Event fired when a CSS transition has been cancelled.
      dispatchEvent(Event(_transitionCancel));
    } else if (status == CSSTransitionEvent.start) {
      // An Event fired when a CSS transition is created,
      // when it is added to a set of running transitions,
      // though not nessarilty started.
      dispatchEvent(Event(_transitionStart));
    } else if (status == CSSTransitionEvent.end) {
      // An Event fired when a CSS transition has finished playing.
      dispatchEvent(Event(_transitionEnd));
    }
  }
}

typedef CSSTransitionProgressListener = void Function(double progress);
typedef CSSTransitionStatusListener = void Function(CSSTransitionEvent status);

class CSSTransition with CustomTickerProviderStateMixin {
  Duration delay = Duration(milliseconds: 0);
  CurvedAnimation curvedAnimation;
  AnimationController controller;
  List<CSSTransitionProgressListener> progressListeners;
  CSSTransitionStatusListener _transitionListener;

  void _setTransitionListener(CSSTransitionStatusListener transitionListener) {
    _transitionListener = transitionListener;
  }

  bool _listened = false;
  void _listen() {
    if (_listened) return;

    if (progressListeners != null && progressListeners.length > 0) {
      _listened = true;
      _transitionListener(CSSTransitionEvent.run);
      curvedAnimation.addListener(_progressListener);
      Future.delayed(delay, _forward);
    }
  }

  void _forward() {
    controller.forward();
  }

  void addProgressListener(CSSTransitionProgressListener progressListener) {
    if (progressListeners == null) {
      progressListeners = [];
    }
    if (progressListener != null) {
      progressListeners.add(progressListener);
    }
  }

  bool _isTransitionStart = false;
  bool _isTransitionCancel = false;
  bool _isTransitionEnd = false;

  void _progressListener() {
    if (progressListeners != null) {
      for (CSSTransitionProgressListener progressListener in progressListeners) {
        progressListener(curvedAnimation.value);
      }
      // Trigger transtion event
      AnimationStatus status = curvedAnimation.status;
      if (status == AnimationStatus.forward) {
        // Forward status trigger many times
        if (!_isTransitionStart) {
          _isTransitionStart = true;
          _transitionListener(CSSTransitionEvent.start);
        }
      } else if (status == AnimationStatus.completed) {
        if (!_isTransitionEnd) {
          _isTransitionEnd = true;
          _dispose();
          _transitionListener(CSSTransitionEvent.end);
        }
      } else if (status == AnimationStatus.dismissed) {
        if (!_isTransitionCancel) {
          _isTransitionCancel = true;
          _dispose();
          _transitionListener(CSSTransitionEvent.cancel);
        }
      }
    }
  }

  void _dispose() {
    curvedAnimation.removeListener(_progressListener);
    controller.reset();
    if (progressListeners != null) {
      progressListeners.clear();
      progressListeners = null;
    }
    _listened = false;
    _isTransitionStart = false;
    _isTransitionCancel = false;
    _isTransitionEnd = false;
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

  static Curve _parseFunction(String function) {
    switch (function) {
      case LINEAR:
        return Curves.linear;
      case EASE:
        return Curves.ease;
      case EASE_IN:
        return Curves.easeIn;
      case EASE_OUT:
        return Curves.easeOut;
      case EASE_IN_OUT:
        return Curves.easeInOut;
      case STEP_START:
        return Threshold(0);
      case STEP_END:
        return Threshold(1);
    }
    List<CSSFunctionalNotation> methods = CSSFunction.parseFunction(function);
    if (methods != null && methods.length > 0) {
      CSSFunctionalNotation method = methods.first;
      if (method != null) {
        if (method.name == 'steps') {
          if (method.args.length >= 1) {
            var step = int.tryParse(method.args[0]);
            var isStart = false;
            if (method.args.length == 2) {
              isStart = method.args[1] == 'start';
            }
            return CSSStepCurve(step, isStart);
          }
        } else if (method.name == 'cubic-bezier') {
          if (method.args.length == 4) {
            var first = double.tryParse(method.args[0]);
            var sec = double.tryParse(method.args[1]);
            var third = double.tryParse(method.args[2]);
            var forth = double.tryParse(method.args[3]);
            return Cubic(first, sec, third, forth);
          }
        }
      }
    }
    return null;
  }
}

class CSSStepCurve extends Curve {
  final int step;
  final bool isStart;

  CSSStepCurve(this.step, this.isStart);

  @override
  double transformInternal(double t) {
    int addition = 0;
    if (!isStart) {
      addition = 1;
    }

    int cur = (t * step).floor();
    cur = cur + addition;

    return cur / step;
  }
}
