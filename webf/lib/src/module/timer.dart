/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'dart:async';

/// A [Timer] that can be paused, resumed.
class PausablePeriodicTimer implements Timer {
  Timer? _timer;
  final void Function(Timer) _callback;
  final Duration _duration;
  int _tick = 0;

  void _startTimer() {
    var boundCallback = _callback;
    if (Zone.current != Zone.root) {
      boundCallback = Zone.current.bindUnaryCallbackGuarded(_callback);
    }
    _timer = Zone.current.createPeriodicTimer(_duration, (Timer timer) {
      _tick++;
      boundCallback(timer);
    });
  }

  /// Creates a new timer.
  PausablePeriodicTimer(Duration duration, void Function(Timer) callback)
      : assert(duration >= Duration.zero),
        _duration = duration,
        _callback = callback {
    _startTimer();
  }

  @override
  bool get isActive => _timer != null;

  @override
  void cancel() {
    _timer?.cancel();
    _timer = null;
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
    _timerMap[id] = PausablePeriodicTimer(timeoutDurationMS, (_) {
      callback();
    });
    return id;
  }

  void pauseInterval() {
    _timerMap.forEach((key, timer) {
      if (timer is PausablePeriodicTimer) {
        timer.pause();
      }
    });
  }

  void resumeInterval() {
    _timerMap.forEach((key, timer) {
      if (timer is PausablePeriodicTimer) {
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
