/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:async';

/// A [Timer] that can be paused, resumed.
class PausableTimer implements Timer {
  final Zone _zone;
  Timer? _timer;
  void Function()? _callback;
  final Duration _duration;
  int _tick = 0;

  void _startTimer() {
    _timer = _zone.createTimer(_duration, () {
      _tick++;
      _timer = null;
      _zone.run(_callback!);
    });
  }

  /// Creates a new timer.
  PausableTimer(Duration duration, void Function() callback)
      : assert(duration >= Duration.zero),
        _duration = duration,
        _zone = Zone.current {
    _callback = _zone.bindCallback(callback);
    assert(_callback != null);
  }

  @override
  bool get isActive => _timer != null;

  @override
  void cancel() {
    _timer?.cancel();
    _timer = null;
    _callback = null;
  }

  /// Resume the timer.
  void resume() {
    if (isActive) return;
    _startTimer();
  }

  /// Pauses an active timer.
  void pause() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  int get tick => _tick;
}

mixin TimerMixin {
  int _timerId = 1;
  final Map<int, Timer> _timerMap = {};

  int setTimeout(int timeout, void Function() callback) {
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

  int setInterval(int timeout, void Function() callback) {
    Duration timeoutDurationMS = Duration(milliseconds: timeout);
    int id = _timerId++;
    _timerMap[id] = PausableTimer(timeoutDurationMS, callback);
    return id;
  }

  void pauseInterval() {
    _timerMap.forEach((key, timer) {
      if (timer is PausableTimer) {
        timer.pause();
      }
    });
  }

  void resumeInterval() {
    _timerMap.forEach((key, timer) {
      if (timer is PausableTimer) {
        timer.resume();
      }
    });
  }

  void disposeTimer() {
    _timerMap.forEach((key, timer) {
      timer.cancel();
    });
    _timerMap.clear();
  }
}
