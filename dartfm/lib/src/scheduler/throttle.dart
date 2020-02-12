import 'dart:async';

///  Throttling
///  Have method [throttle]
class Throttling {
  Duration _duration;
  Duration get duration => this._duration;
  set duration(Duration value) {
    assert(duration is Duration && !duration.isNegative);
    this._duration = value;
  }

  bool _isReady = true;
  bool get isReady => isReady;
  Future<void> get _waiter => Future.delayed(this._duration);
  // ignore: close_sinks
  final StreamController<bool> _stateSC = StreamController<bool>.broadcast();

  Throttling({Duration duration = const Duration(seconds: 1)})
      : assert(duration is Duration && !duration.isNegative),
        this._duration = duration ?? Duration(seconds: 1) {
    this._stateSC.sink.add(true);
  }

  dynamic throttle(Function func) {
    if (!this._isReady) return null;
    this._stateSC.sink.add(false);
    this._isReady = false;
    _waiter
      ..then((_) {
        this._isReady = true;
        this._stateSC.sink.add(true);
      });
    return Function.apply(func, []);
  }

  StreamSubscription<bool> listen(Function(bool) onData) =>
      this._stateSC.stream.listen(onData);

  dispose() {
    this._stateSC.close();
  }
}
