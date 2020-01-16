/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:async';
import 'package:kraken/element.dart';
import 'message.dart';

class KrakenTimer {
  int timerId = 1;
  Map<int, Timer> timerMap = {};
  Map<int, bool> animationFrameCallbackValidateMap = {};

  KrakenTimer();

  int setTimeout(int callbackId, int timeout) {
    Duration timeoutDurationMS = Duration(milliseconds: timeout);
    int id = timerId++;
    timerMap[id] = Timer(timeoutDurationMS, () {
      CPPMessage(TIMEOUT_MESSAGE, "$callbackId").send();
      timerMap.remove(id);
    });
    return id;
  }

  void clearTimeout(int timerId) {
    timerMap[timerId].cancel();
    timerMap.remove(timerId);
  }

  int setInterval(int callbackId, int timeout) {
    Duration timeoutDurationMS = Duration(milliseconds: timeout);
    int id = timerId++;
    timerMap[id] = Timer.periodic(timeoutDurationMS, (Timer timer) {
      CPPMessage(INTERVAL_MESSAGE, "$callbackId").send();
    });
    return id;
  }

  int requestAnimationFrame(int callbackId) {
    int id = timerId++;
    animationFrameCallbackValidateMap[callbackId] = true;
    ElementsBinding.instance.addPostFrameCallback((Duration timeStamp) {
      if (animationFrameCallbackValidateMap[callbackId] == true) {
        CPPMessage(ANIMATION_FRAME_MESSAGE, "$callbackId").send();
        // $timeStamp
      }
    });
    return id;
  }

  void cancelAnimationFrame(int timerId) {
    if (animationFrameCallbackValidateMap.containsKey(timerId)) {
      animationFrameCallbackValidateMap[timerId] = false;
    }
  }
}
