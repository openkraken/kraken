import 'dart:ui' show VoidCallback;
import 'package:kraken/element.dart';

int _id = 1;
Map<int, bool> _animationFrameCallbackMap = {};

int requestAnimationFrame(VoidCallback callback) {
  int id = _id++;
  _animationFrameCallbackMap[id] = true;
  ElementsBinding.instance.scheduleFrameCallback((Duration timeStamp) {
    if (_animationFrameCallbackMap.containsKey(id)) {
      _animationFrameCallbackMap.remove(id);
      callback();
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
