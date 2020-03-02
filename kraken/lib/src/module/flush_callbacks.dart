import 'dart:async';
import 'package:kraken/bridge.dart';

Timer uiLoop;

/// https://github.com/dart-lang/sdk/issues/37022
/// Dart FFI did not support async callbacks from native execution. So we use this
/// loop to consume some callback which comes from other threads.
/// When this issue is been closed, there is no need to use this loop anymore.
void startFlushCallbacksInUIThread() {
  flushUITask();

  // flush ui task every 16ms
  Duration duration = Duration(milliseconds: 16);
  uiLoop = Timer(duration, () {
    startFlushCallbacksInUIThread();
  });
}

void stopFlushCallbacksInUIThread() {
  if (uiLoop != null) {
    uiLoop.cancel();
  }
}
