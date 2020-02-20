import 'package:kraken/element.dart';

int _id = 1;
Map<int, bool> _animationFrameCallbackMap = {};

typedef DoubleCallback = void Function(double);

int requestAnimationFrame(DoubleCallback callback) {
  int id = _id++;
  _animationFrameCallbackMap[id] = true;
  ElementsBinding.instance.scheduleFrameCallback((Duration timeStamp) {
    if (_animationFrameCallbackMap.containsKey(id)) {
      _animationFrameCallbackMap.remove(id);
      double highResTimeStamp = timeStamp.inMicroseconds / 1000;
      callback(highResTimeStamp);
    }
  });
  ElementsBinding.instance.scheduleFrame();
  return id;
}

void cancelAnimationFrame(int id) {
  if (_animationFrameCallbackMap.containsKey(id)) {
    _animationFrameCallbackMap.remove(id);
  }
}
