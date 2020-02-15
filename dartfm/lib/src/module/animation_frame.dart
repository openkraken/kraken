import 'package:kraken/element.dart';

int _frameId = 1;
Map<int, bool> _animationFrameCallbackValidateMap = {};

int requestAnimationFrame(Function callback) {
  int id = _frameId++;
  _animationFrameCallbackValidateMap[id] = true;
  ElementsBinding.instance.scheduleFrameCallback((Duration timeStamp) {
    if (_animationFrameCallbackValidateMap[id] == true) {
      _animationFrameCallbackValidateMap.remove(id);
      callback();
    }
  });
  ElementsBinding.instance.scheduleFrame();
  return id;
}

void cancelAnimationFrame(int frameId) {
  if (_animationFrameCallbackValidateMap.containsKey(frameId)) {
    _animationFrameCallbackValidateMap[frameId] = false;
  }
}
