import 'package:kraken/module.dart';
import 'dart:async';

///  Debouncing
///  Have method [debounce]
class Debouncing {
  Duration _duration;
  int _animationFrameId;
  Timer _waiter;
  bool _isReady = true;
  bool get isReady => _isReady;
  bool _scheduleRunned = false;
  // ignore: close_sinks
  StreamController<dynamic> _resultSC = new StreamController<dynamic>.broadcast();
  // ignore: close_sinks
  final StreamController<bool> _stateSC = new StreamController<bool>.broadcast();

  /// If duration is null, use frame callback;
  Debouncing({Duration duration}) {
    _stateSC.sink.add(true);
  }

  Future<dynamic> debounce(Function func) async {
    if (_duration == null && !_scheduleRunned) {
      cancelAnimationFrame(_animationFrameId);
      _resultSC.sink.add(null);
    } else if (_waiter?.isActive ?? false) {
      _waiter?.cancel();
      _resultSC.sink.add(null);
    }

    _isReady = false;
    _stateSC.sink.add(false);
    VoidCallback _whenFinish = () {
      _isReady = true;
      _stateSC.sink.add(true);
      _resultSC.sink.add(Function.apply(func, List<dynamic>()));
    };
    if (_duration == null) {
      _scheduleRunned = false;
      _animationFrameId = requestAnimationFrame((_) {
        _scheduleRunned = true;
        _whenFinish();
      });
    } else {
      _waiter = Timer(_duration, _whenFinish);
    }
    return _resultSC.stream.first;
  }

  StreamSubscription<bool> listen(Function(bool) onData) => _stateSC.stream.listen(onData);

  void dispose() {
    _resultSC.close();
    _stateSC.close();
    if (_duration == null)
      cancelAnimationFrame(_animationFrameId);
    else
      _waiter?.cancel();
  }
}
