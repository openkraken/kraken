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
  Throttling throttler = Throttling();
  Map<String, CSSTransition> transitionMap;

  void updateTransition(CSSStyleDeclaration style) {
    Map<String, CSSTransition> map = {};

    List<String> transitionProperty = CSSStyleProperty.getMultipleValues(style[TRANSITION_PROPERTY]) ?? [ALL];
    List<String> transitionDuration = CSSStyleProperty.getMultipleValues(style[TRANSITION_DURATION]) ?? [_0s];
    List<String> transitionTimingFunction = CSSStyleProperty.getMultipleValues(style[TRANSITION_TIMING_FUNCTION]) ?? [EASE];
    List<String> transitionDelay = CSSStyleProperty.getMultipleValues(style[TRANSITION_DELAY]) ?? [_0s];

    for (int i = 0; i < transitionProperty.length; i++) {
      String property = transitionProperty[i];
      String function = transitionTimingFunction.length == 1 ? transitionTimingFunction[0] : transitionTimingFunction[i];
      String duration = transitionDuration.length == 1 ? transitionDuration[0] : transitionDuration[i];
      String delay = transitionDelay.length == 1 ? transitionDelay[0] : transitionDelay[i];

      Curve curve = CSSTransition._parseFunction(function);
      if (curve != null) {
        CSSTransition transition = CSSTransition();
        _dispatchTransitionRun();

        AnimationController controller =
            AnimationController(duration: Duration(milliseconds: CSSTime.parseTime(duration)), vsync: transition);
        transition.curvedAnimation = CurvedAnimation(curve: curve, parent: controller);
        transition.controller = controller;
        transition.delay = Duration(milliseconds: CSSTime.parseTime(delay));
        map[property] = transition;
      }
    }

    transitionMap = map;
  }

  void updateTransitionEvent(CSSTransition transition) {
    transition?._setTransitionListener(_dispatchTransitionEvent);
    transition?._listen();
  }

  void _dispatchTransitionEvent(CSSTransitionEvent status) {
    if (status == CSSTransitionEvent.cancel) {
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

  void _dispatchTransitionRun() {
    dispatchEvent(Event(_transitionRun));
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

  void _listen() {
    if (progressListeners != null && progressListeners.length > 0) {
      curvedAnimation.addListener(_progressListener);
      curvedAnimation.addStatusListener(_statusListener);
      Future.delayed(delay, _forward);
    }
  }

  void _forward() {
    controller.reset();
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

  void _progressListener() {
    if (progressListeners != null) {
      for (CSSTransitionProgressListener progressListener in progressListeners) {
        progressListener(curvedAnimation.value);
      }
    }
  }

  bool _isTransitionStart = false;
  void _statusListener(AnimationStatus status) {
    if (status == AnimationStatus.forward) {
      // Forward status trigger many times
      if (!_isTransitionStart) {
        _isTransitionStart = true;
        _transitionListener(CSSTransitionEvent.start);
      }
    } else if (status == AnimationStatus.completed) {
      _dispose();
      _transitionListener(CSSTransitionEvent.end);
    } else if (status == AnimationStatus.dismissed) {
      _transitionListener(CSSTransitionEvent.cancel);
    }
  }

  void _dispose() {
    curvedAnimation.removeListener(_progressListener);
    curvedAnimation.removeStatusListener(_statusListener);
    controller.reset();
    if (progressListeners != null) {
      progressListeners.clear();
      progressListeners = null;
    }
    _isTransitionStart = false;
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
