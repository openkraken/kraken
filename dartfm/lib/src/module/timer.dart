/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:async';

import 'package:kraken/element.dart';

class KrakenTimer {
  int timerId = 1;
  Map<int, Timer> timerMap = {};
  Map<int, bool> animationFrameCallbackValidateMap = {};

  KrakenTimer();

  int setTimeout(int timeout, Function callback) {
    Duration timeoutDurationMS = Duration(milliseconds: timeout);
    int id = timerId++;
    timerMap[id] = Timer(timeoutDurationMS, () {
      callback();
      timerMap.remove(id);
    });
    return id;
  }

  void clearTimeout(int timerId) {
    // If timer already executed, which will be removed.
    if (timerMap[timerId] != null) {
      timerMap[timerId].cancel();
      timerMap.remove(timerId);
    }
  }

  int setInterval(int timeout, Function callback) {
    Duration timeoutDurationMS = Duration(milliseconds: timeout);
    int id = timerId++;
    timerMap[id] = Timer.periodic(timeoutDurationMS, (Timer timer) {
      callback();
    });
    return id;
  }

  int requestAnimationFrame(Function callback) {
    int id = timerId++;
    animationFrameCallbackValidateMap[id] = true;
    ElementsBinding.instance.addPostFrameCallback((Duration timeStamp) {
      if (animationFrameCallbackValidateMap[id] == true) {
        callback();
      }
    });
    // Call for paint to trigger painting frame manually.
    ElementManager().getRootRenderObject().markNeedsPaint();
    return id;
  }

  void cancelAnimationFrame(int timerId) {
    if (animationFrameCallbackValidateMap.containsKey(timerId)) {
      animationFrameCallbackValidateMap[timerId] = false;
    }
  }

  void reloadTimer() {
    timerId = 1;
    timerMap = {};
    animationFrameCallbackValidateMap = {};
  }
}

KrakenTimer timer = KrakenTimer();
