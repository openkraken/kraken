/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:async';

mixin TimerMixin {
  int _timerId = 1;
  Map<int, Timer> _timerMap = {};

  int setTimeout(int timeout, Function callback) {
    Duration timeoutDurationMS = Duration(milliseconds: timeout);
    int id = _timerId++;
    _timerMap[id] = Timer(timeoutDurationMS, () {
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
      callback();
    });
    return id;
  }
}
