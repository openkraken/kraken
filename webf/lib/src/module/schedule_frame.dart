/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:flutter/scheduler.dart';

typedef DoubleCallback = void Function(double);
typedef VoidCallback = void Function();

mixin ScheduleFrameMixin {
  int _id = 1;
  final Map<int, bool> _animationFrameCallbackMap = {};

  int requestAnimationFrame(DoubleCallback callback) {
    int id = _id++;
    _animationFrameCallbackMap[id] = true;
    SchedulerBinding.instance.addPostFrameCallback((Duration timeStamp) {
      if (_animationFrameCallbackMap.containsKey(id)) {
        _animationFrameCallbackMap.remove(id);
        double highResTimeStamp = timeStamp.inMicroseconds / 1000;
        callback(highResTimeStamp);
      }
    });
    SchedulerBinding.instance.scheduleFrame();
    return id;
  }

  void cancelAnimationFrame(int id) {
    if (_animationFrameCallbackMap.containsKey(id)) {
      _animationFrameCallbackMap.remove(id);
    }
  }

  void requestBatchUpdate() {
    SchedulerBinding.instance.scheduleFrame();
  }

  void disposeScheduleFrame() {
    _animationFrameCallbackMap.clear();
  }
}
