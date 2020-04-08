import 'dart:developer';

class Performance {
  static DateTime timeOrigin = DateTime.now();

  // Use the same monotonic clock with dart vm.
  static double now() {
    int nowInMicroseconds = Timeline.now;
    return nowInMicroseconds / 1000;
  }

  static double getTimeOrigin() {
    return timeOrigin.microsecondsSinceEpoch / 1000;
  }
}
