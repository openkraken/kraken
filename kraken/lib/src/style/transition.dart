import 'package:flutter/animation.dart';
import 'package:kraken/rendering.dart';
import 'package:kraken/style.dart';

mixin TransitionStyleMixin {
  Map<String, Transition> transitionMap;

  void initTransition(StyleDeclaration style, String property) {
    transitionMap = Transition.parseTransitions(style, property);
  }
}

typedef ProgressListener = void Function(double progress);

class Transition with CustomTickerProviderStateMixin {
  Duration delay = Duration(milliseconds: 0);
  CurvedAnimation curvedAnimation;
  AnimationController controller;
  List<ProgressListener> progressListeners;

  void apply() {
    if (progressListeners != null && progressListeners.length > 0) {
      Future.delayed(delay, () {
        controller?.forward();
      });
      curvedAnimation.addListener(listener);
      curvedAnimation.addStatusListener(statusListener);
    }
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
      for (ProgressListener progressListener in progressListeners) {
        progressListener(curvedAnimation.value);
      }
    }
  }

  void statusListener(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      dispose();
    }
  }

  void dispose() {
    if (controller?.isAnimating != null) {
      controller?.dispose();
      controller = null;
      progressListeners.clear();
      progressListeners = null;
      curvedAnimation = null;
    }
  }

  static Map<String, Transition> parseTransitions(StyleDeclaration style, String property) {
    String transition = style['transition'] ?? 'all 0s ease 0s';
    List<String> list = style['transition'].split(',');
    String transitionProperty = style['transitionProperty'] ?? 'all';
    String transitionDuration = style['transitionDuration'] ?? '0s';
    String transitionTimingFunction = style['transitionTimingFunction'] ?? 'ease';
    String transitionDelay = style['transitionDelay'] ?? '0s';

    if (property == 'transitionProperty' ||
      property == 'transitionDuration' ||
      property == 'transitionTimingFunction' ||
      property == 'transitionDelay'
    ) {
      List<String> properties = transitionProperty.split(',');
      List<String> newList = [];
      for (String prop in properties) {
        newList.add(
          prop + ' ' + transitionDuration + ' ' + transitionTimingFunction + ' ' + transitionDelay
        );
      }
      list = newList;
    }

    Map<String, Transition> map = {};
    for (String transition in list) {
      parseTransition(transition, map);
    }
    return map;
  }

  static void parseTransition(String string, Map<String, Transition> map) {
    if (string != null && string.isNotEmpty) {
      List<String> strs = string.trim().split(" ");
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
        if (duration.valueOf() == null) {
          duration = Time.zero;
        }
        Curve curve = parseFunction(function);
        if (curve != null) {
          Transition transition = Transition();
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
    List<Method> methods = Method.parseMethod(function);
    if (methods != null && methods.length > 0) {
      Method method = methods[0];
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
