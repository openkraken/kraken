// @dart=2.9

import 'package:flutter/animation.dart';
import 'package:kraken/dom.dart';
import 'package:kraken/css.dart';

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

mixin CSSTransitionMixin on Node {
  void updateTransition(CSSStyleDeclaration style) {
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
}

class CSSTransition {

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
