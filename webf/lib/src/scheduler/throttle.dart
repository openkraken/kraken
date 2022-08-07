/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'dart:async';

///  Throttling
///  Have method [throttle]
class Throttling {
  Duration _duration;
  Duration get duration => _duration;
  set duration(Duration value) {
    assert(!duration.isNegative);
    _duration = value;
  }

  bool _isReady = true;
  bool get isReady => _isReady;
  Future<void> get _waiter => Future.delayed(_duration);
  // ignore: close_sinks
  final StreamController<bool> _stateSC = StreamController<bool>.broadcast();

  Throttling({Duration duration = const Duration(seconds: 1)})
      : assert(!duration.isNegative),
        _duration = duration {
    _stateSC.sink.add(true);
  }

  dynamic throttle(Function func) {
    if (!_isReady) return null;
    _stateSC.sink.add(false);
    _isReady = false;
    _waiter
      ..then((_) {
        _isReady = true;
        _stateSC.sink.add(true);
      });
    return Function.apply(func, List.empty());
  }

  StreamSubscription<bool> listen(void Function(bool)? onData) => _stateSC.stream.listen(onData);

  void dispose() {
    _stateSC.close();
  }
}
