import 'package:flutter/scheduler.dart';

class Performance {
  static now() {
    Duration timeStamp = SchedulerBinding.instance.currentFrameTimeStamp;
    return timeStamp.inMicroseconds / 1000;
  }
}
