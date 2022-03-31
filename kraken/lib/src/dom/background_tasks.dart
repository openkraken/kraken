/*
 * Copyright (C) 2022-present The Kraken authors. All rights reserved.
 */

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

typedef IdleRequestCallback = void Function(IdleDeadline deadline);

class IdleDeadline {
  IdleDeadline._(double time) : _time = time;

  // Each IdleDeadline has an associated time which holds a DOMHighResTimeStamp representing the absolute time in
  // milliseconds of the deadline. This must be populated when the IdleDeadline is created.
  final double _time;

  // Each IdleDeadline has an associated timeout, which is initially false.
  bool _timeout = false;

  // The didTimeout getter must return timeout.
  bool get didTimeout => _timeout;

  // When the timeRemaining() method is invoked on an IdleDeadline object it must return the duration,
  // as a DOMHighResTimeStamp, between the current time and the time associated with the IdleDeadline object.
  // The value should be accurate to 5 microseconds - see "Privacy and Security" section of [HR-TIME].
  // This value is calculated by performing the following steps:
  //
  // 1. Let now be a DOMHighResTimeStamp representing current high resolution time in milliseconds.
  // 2. Let deadline be the time associated with the IdleDeadline object.
  // 3. Let timeRemaining be deadline - now.
  // 4. If timeRemaining is negative, set it to 0.
  // 5. Return timeRemaining.
  double timeRemaining() {
    double currentTime = _currentTime();
    return _time - currentTime;
  }
}

class IdleRequestOptions {
  IdleRequestOptions(this.timeout);
  int? timeout;
}

// https://www.w3.org/TR/requestidlecallback
mixin ScheduleBackgroundTasks {
  // The list must be initially empty and each entry in this list is identified by a number, which must
  // be unique within the list for the lifetime of the Window object.
  final Map<int, IdleRequestCallback> _idleRequestCallbacks = {};
  // A list of runnable idle callbacks. The list must be initially empty and each entry in this list is
  // identified by a number, which must be unique within the list of the lifetime of the Window object.
  final Map<int, IdleRequestCallback> _runnableIdleCallback = {};
  // An idle callback identifier, which is a number which must initially be zero.
  int _idleCallbackIdentifier = 0;
  // A last idle period deadline, which is a [DOMHighResTimeStamp] which must initially be zero.
  double _lastIdlePeriodDeadline = 0;

  // https://www.w3.org/TR/requestidlecallback/#dom-window-requestidlecallback
  int requestIdleCallback(IdleRequestCallback callback, [IdleRequestOptions? options]) {
    final int id = ++_idleCallbackIdentifier;

    final startIdlePeriod = _idleRequestCallbacks.isEmpty && _runnableIdleCallback.isEmpty;
    _idleRequestCallbacks[id] = callback;
    if (startIdlePeriod) {
      _queueIdleTask(_startIdlePeriod);
    }

    final int? timeout = options?.timeout;
    if (timeout != null && timeout > 0) {
      Timer(Duration(milliseconds: timeout), () {
        _queueIdleTask(() {
          _invokeIdleCallbackTimeout(id);
        });
      });
    }

    return id;
  }

  // https://www.w3.org/TR/requestidlecallback/#dom-window-cancelidlecallback
  // 1. Let window be this Window object.
  // 2. Find the entry in either the window's list of idle request callbacks or list of runnable
  //    idle callbacks that is associated with the value handle.
  // 3. If there is such an entry, remove it from both window's list of idle request
  //    callbacks and the list of runnable idle callbacks.
  void cancelIdleCallback(int handle) {
    IdleRequestCallback? entry = _idleRequestCallbacks.remove(handle);
    if (entry == null) {
      _runnableIdleCallback.remove(handle);
    }
  }

  // https://www.w3.org/TR/requestidlecallback/#dfn-start-an-idle-period-algorithm
  void _startIdlePeriod() async {
    double lastDeadline = _lastIdlePeriodDeadline;
    double now = _currentTime();
    if (lastDeadline > now) {
      await _wait((lastDeadline - now).floor());
    }
    await _waitUntilNextMicrotask();
    now = _currentTime();
    double deadline = _expectedNextDeadline;
    if (deadline - now > 50) {
      deadline = now + 50;
    }
    Map<int, IdleRequestCallback> pendingList = _idleRequestCallbacks;
    Map<int, IdleRequestCallback> runList = _runnableIdleCallback;
    runList.addAll(pendingList);
    pendingList.clear();
    _queueIdleTask(() {
      _invokeIdleCallback(deadline);
    });
    _lastIdlePeriodDeadline = deadline;
  }

  // The user agent should choose deadline to ensure that no time-critical tasks will be delayed
  // even if a callback runs for the whole time period from now to deadline. As such, it should
  // be set to the minimum of: the closest timeout in the list of active timers as set via setTimeout
  // and setInterval; the scheduled runtime for pending animation callbacks posted via requestAnimationFrame;
  // pending internal timeouts such as deadlines to start rendering the next frame, process audio
  // or any other internal task the user agent deems important.
  double get _expectedNextDeadline {
    // @TODO: Only supported 60fps.
    return SchedulerBinding.instance!.currentFrameTimeStamp.inMicroseconds + 1000 / 60;
  }

  void _queueIdleTask(VoidCallback task) {
    SchedulerBinding.instance!.scheduleTask(task, Priority.idle);
  }

  // https://www.w3.org/TR/requestidlecallback/#dfn-invoke-idle-callbacks-algorithm
  void _invokeIdleCallback(double deadline) {
    double now = _currentTime();
    if (now < deadline && _runnableIdleCallback.isNotEmpty) {
      int first = _runnableIdleCallback.keys.first;
      IdleRequestCallback callback = _runnableIdleCallback.remove(first)!;
      IdleDeadline idleDeadline = IdleDeadline._(deadline)
        .._timeout = false;
      _invokeCallback(callback, idleDeadline);
      if (_runnableIdleCallback.isNotEmpty) {
        Timer.run(() {
          _invokeIdleCallback(deadline);
        });
      }
    } else {
      if (_idleRequestCallbacks.isNotEmpty || _runnableIdleCallback.isNotEmpty) {
        Timer.run(_startIdlePeriod);
      }
    }
  }

  // https://www.w3.org/TR/requestidlecallback/#dfn-invoke-idle-callback-timeout-algorithm
  void _invokeIdleCallbackTimeout(int id) {
    IdleRequestCallback? callback = _idleRequestCallbacks[id] ?? _runnableIdleCallback[id];
    if (callback != null) {
      _idleRequestCallbacks.remove(id);
      _runnableIdleCallback.remove(id);
      double now = _currentTime();
      IdleDeadline deadline = IdleDeadline._(now)
        .._timeout = true;
      _invokeCallback(callback, deadline);
    }
  }

  void _invokeCallback(IdleRequestCallback callback, IdleDeadline idleDeadline) {
    try {
      callback(idleDeadline);
    } catch (exception, exceptionStack) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: exception,
        stack: exceptionStack,
        library: 'scheduler library',
        context: ErrorDescription('during a task callback'),
      ));
    }
  }
}

Future<void> _wait(int millisecond) {
  return Future.delayed(Duration(milliseconds: millisecond));
}

FutureOr<void> _waitUntilNextMicrotask() {
  return Future.microtask(() => null);
}

double _currentTime() {
  return DateTime.now().microsecond / 1000;
}
