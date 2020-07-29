import 'package:flutter/animation.dart';
import 'package:kraken/element.dart';
import 'package:kraken/scheduler.dart';
import 'package:kraken/rendering.dart';
import 'package:kraken/css.dart';

// CSS Transitions: https://drafts.csswg.org/css-transitions/

mixin CSSTransitionMixin on Node {
  Throttling throttler = Throttling();
  Map<String, CSSTransition> transitionMap;

  void updateTransition(CSSStyleDeclaration style) {
    transitionMap = CSSTransition.parseTransitions(style, this);
  }

  void initTransitionEvent(CSSTransition transition) {
    transition?.setStatusListener((AnimationStatus status) {
      if (status == AnimationStatus.dismissed) {
        // An Event fired when a CSS transition has been cancelled.
        dispatchTransitionCancel();
      } else if (status == AnimationStatus.forward) {
        // An Event fired when a CSS transition is created,
        // when it is added to a set of running transitions,
        // though not nessarilty started.
        dispatchTransitionStart();
      } else if (status == AnimationStatus.completed) {
        // An Event fired when a CSS transition has finished playing.
        dispatchTransitionEnd();
      }
    });
  }

  void dispatchTransitionRun() {
    dispatchEvent(Event('transitionrun'));
  }

  void dispatchTransitionStart() {
    dispatchEvent(Event('transitionstart'));
  }

  void dispatchTransitionCancel() {
    dispatchEvent(Event('transitioncancel'));
  }

  void dispatchTransitionEnd() {
    dispatchEvent(Event('transitionend'));
  }
}

typedef CSSTransitionProgressListener = void Function(double progress);
typedef CSSTransitionStatusListener = void Function(AnimationStatus status);

class CSSTransition with CustomTickerProviderStateMixin {
  Duration delay = Duration(milliseconds: 0);
  CurvedAnimation curvedAnimation;
  AnimationController controller;
  List<CSSTransitionProgressListener> progressListeners;
  CSSTransitionStatusListener _statusListener;

  void setStatusListener(CSSTransitionStatusListener statusListener) {
    _statusListener = statusListener;
  }

  void apply() {
    if (progressListeners != null && progressListeners.length > 0) {
      curvedAnimation.addListener(listener);
      curvedAnimation.addStatusListener(statusListener);
      Future.delayed(delay, () {
        controller.reset();
        controller.forward();
      });
    }
  }

  void setProgressListener(CSSTransitionProgressListener progressListener) {
    progressListeners = [progressListener];
  }

  void addProgressListener(CSSTransitionProgressListener progressListener) {
    if (progressListeners == null) {
      progressListeners = [];
    }
    if (progressListener != null) {
      progressListeners.add(progressListener);
    }
  }

  void listener() {
    if (progressListeners != null) {
      if (curvedAnimation.value == 0.0) {
        statusListener(AnimationStatus.forward);
      }
      for (CSSTransitionProgressListener progressListener in progressListeners) {
        progressListener(curvedAnimation.value);
      }
    }
  }

  void statusListener(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      dispose();
    }
    if (_statusListener != null) {
      _statusListener(status);
    }
  }

  void dispose() {
    curvedAnimation.removeListener(listener);
    curvedAnimation.removeStatusListener(statusListener);
    controller.reset();
    if (progressListeners != null) {
      progressListeners.clear();
      progressListeners = null;
    }
  }

  static Map<String, CSSTransition> parseTransitions(CSSStyleDeclaration style, Element el) {

    Map<String, CSSTransition> map = {};

    List<String> transitionProperty = CSSStyleProperty.getMultipleValues(style[TRANSITION_PROPERTY].isEmpty ? ALL : style[TRANSITION_PROPERTY]);
    List<String> transitionDuration = CSSStyleProperty.getMultipleValues(style[TRANSITION_DURATION].isEmpty ? '0s' : style[TRANSITION_DURATION]);
    List<String> transitionTimingFunction = CSSStyleProperty.getMultipleValues(style[TRANSITION_TIMING_FUNCTION].isEmpty ? EASE : style[TRANSITION_TIMING_FUNCTION]);
    List<String> transitionDelay = CSSStyleProperty.getMultipleValues(style[TRANSITION_DELAY].isEmpty ? '0s' : style[TRANSITION_DELAY]);

    for (int i = 0; i < transitionProperty.length; i++) {
      String property = transitionProperty[i];
      String function = transitionTimingFunction.length == 1 ? transitionTimingFunction[0] : transitionTimingFunction[i];
      String duration = transitionDuration.length == 1 ? transitionDuration[0] : transitionDuration[i];
      String delay = transitionDelay.length == 1 ? transitionDelay[0] : transitionDelay[i];
  
      Curve curve = _parseFunction(function);
      if (curve != null) {
        CSSTransition transition = CSSTransition();
        el?.dispatchTransitionRun();

        AnimationController controller = AnimationController(duration: Duration(milliseconds: CSSTime.parseTime(duration)), vsync: transition);
        transition.curvedAnimation = CurvedAnimation(curve: curve, parent: controller);
        transition.controller = controller;
        transition.delay = Duration(milliseconds: CSSTime.parseTime(delay));
        map[property] = transition;
      }
    }

    return map;
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
    List<CSSFunctionalNotation> methods = CSSFunction(function).computedValue;
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
