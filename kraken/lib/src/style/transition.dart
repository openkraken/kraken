import 'package:flutter/animation.dart';
import 'package:kraken/element.dart';
import 'package:kraken/scheduler.dart';
import 'package:kraken/rendering.dart';
import 'package:kraken/style.dart';

mixin TransitionStyleMixin on Node {
  Throttling throttler = Throttling();
  Map<String, Transition> transitionMap;

  void initTransition(StyleDeclaration style, String property) {
    transitionMap = Transition.parseTransitions(style, property, this);
  }

  void initTransitionEvent(Transition transition) {
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

  void _dispatchTransitionEnd() {
    dispatchEvent(Event('transitionend'));
  }

  void dispatchTransitionEnd() {
    throttler.throttle(_dispatchTransitionEnd);
  }
}

typedef ProgressListener = void Function(double progress);
typedef StatusListener = void Function(AnimationStatus status);

class Transition with CustomTickerProviderStateMixin {
  Duration delay = Duration(milliseconds: 0);
  CurvedAnimation curvedAnimation;
  AnimationController controller;
  List<ProgressListener> progressListeners;
  StatusListener _statusListener;

  void setStatusListener(StatusListener statusListener) {
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

  void setProgressListener(ProgressListener progressListener) {
    progressListeners = [progressListener];
  }

  void addProgressListener(ProgressListener progressListener) {
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
      for (ProgressListener progressListener in progressListeners) {
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

  static Map<String, Transition> parseTransitions(StyleDeclaration style, String property, Element el) {
    List<String> list = [];

    if (property == 'transitionProperty' ||
      property == 'transitionDuration' ||
      property == 'transitionTimingFunction' ||
      property == 'transitionDelay'
    ) {
      String transitionProperty = style['transitionProperty'] != '' ? style['transitionProperty'] : 'all';
      String transitionDuration = style['transitionDuration'] != '' ? style['transitionDuration'] : '0s';
      String transitionTimingFunction = style['transitionTimingFunction']  != '' ? style['transitionTimingFunction'] : 'ease';
      String transitionDelay = style['transitionDelay'] != '' ? style['transitionDelay'] : '0s';
      List<String> properties = transitionProperty.split(',');
      for (String prop in properties) {
        list.add(
          prop + ' ' + transitionDuration + ' ' + transitionTimingFunction + ' ' + transitionDelay
        );
      }
    } else {
      list = style['transition'].split(',');
    }

    Map<String, Transition> map = {};
    for (String transition in list) {
      parseTransition(transition, map, el);
    }
    return map;
  }

  static void parseTransition(String string, Map<String, Transition> map, Element el) {
    if (string != null && string.isNotEmpty) {
      List<String> strs = string.trim().split(' ');
      if (strs.length > 1) {
        String property = strs[0];
        Time duration = Time(strs[1]);
        Time delay;
        String function;
        if (strs.length == 3) {
          String third = strs[2];
          if (third.endsWith('s')) {
            delay = Time(third);
          } else {
            function = third;
          }
        } else if (strs.length == 4) {
          delay = Time(strs[3]);
          function = strs[2];
        }
        if (delay?.valueOf() == null) {
          delay = Time.zero;
        }
        if (duration.valueOf() == null || duration.valueOf() <= 0) {
          return;
        }
        Curve curve = parseFunction(function);
        if (curve != null) {
          Transition transition = Transition();
          el?.dispatchTransitionRun();

          AnimationController controller = AnimationController(
              duration: Duration(milliseconds: duration.valueOf()),
              vsync: transition);
          transition.curvedAnimation =
              CurvedAnimation(curve: curve, parent: controller);
          transition.controller = controller;
          transition.delay = Duration(milliseconds: delay.valueOf());
          map[property] = transition;
        }
      }
    }
  }

  static Curve parseFunction(String function) {
    switch (function) {
      case "linear":
        return Curves.linear;
      case "ease":
        return Curves.ease;
      case "ease-in":
        return Curves.easeIn;
      case "ease-out":
        return Curves.easeOut;
      case "ease-in-out":
        return Curves.easeInOut;
      case "step-start":
        return Threshold(0);
      case "step-end":
        return Threshold(1);
    }
    Map<String, Method> methods = Method.parseMethod(function);
    if (methods != null && methods.length > 0) {
      Method method = methods?.values?.first;
      if (method != null) {
        if ("steps" == method.name) {
          if (method.args.length >= 1) {
            try {
              int step = int.parse(method.args[0]);
              bool isStart = false;
              if (method.args.length == 2) {
                isStart = method.args[1] == "start";
              }
              return StepCurve(step, isStart);
            } catch (e) {
              return null;
            }
          }
        } else if ("cubic-bezier" == method.name) {
          if (method.args.length == 4) {
            try {
              double first = double.parse(method.args[0]);
              double sec = double.parse(method.args[1]);
              double third = double.parse(method.args[2]);
              double forth = double.parse(method.args[3]);
              return Cubic(first, sec, third, forth);
            } catch (e) {
              return null;
            }
          }
        }
      }
    }
    return null;
  }
}

class StepCurve extends Curve {
  final int step;
  final bool isStart;

  StepCurve(this.step, this.isStart);

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
