/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:async';
import 'package:kraken/bridge.dart';

mixin TimerMixin {
  int _timerId = 1;
  final Map<int, Timer> _timerMap = {};

  int setTimeout(int timeout, Function callback) {
    Duration timeoutDurationMS = Duration(milliseconds: timeout);
    int id = _timerId++;
    _timerMap[id] = Timer(timeoutDurationMS, () {
      // https://html.spec.whatwg.org/multipage/webappapis.html#task-queue
      // Make sure promise pending jobs are executed before execute timer callbacks.
      executeJSPendingJob();

      callback();
      _timerMap.remove(id);
    });
    return id;
  }

  void clearTimeout(int timerId) {
    // If timer already executed, which will be removed.
    if (_timerMap[timerId] != null) {
      _timerMap[timerId]!.cancel();
      _timerMap.remove(timerId);
    }
  }

  void clearTimer() {
    _timerMap.forEach((key, timer) {
      timer.cancel();
    });
    _timerMap.clear();
  }

  int setInterval(int timeout, Function callback) {
    Duration timeoutDurationMS = Duration(milliseconds: timeout);
    int id = _timerId++;
    _timerMap[id] = Timer.periodic(timeoutDurationMS, (Timer timer) {
      // https://html.spec.whatwg.org/multipage/webappapis.html#task-queue
      // Make sure promise pending jobs are executed before execute timer callbacks.
      executeJSPendingJob();
      callback();
    });
    return id;
  }
}
