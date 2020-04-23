import 'dart:ui';

import 'package:flare_flutter/flare_actor.dart';
import 'package:kraken/style.dart';

class FlareRenderObject extends FlareActorRenderObject with ElementStyleMixin {
  int _targetId;

  FlareRenderObject(this._targetId);

  @override
  void performLayout() {
    if (!sizedByParent) {
      double width = getElementWidth(_targetId);
      double height = getElementHeight(_targetId);
      size = Size(width, height);
    }
  }

  @override
  void performResize() {
    double width = getElementWidth(_targetId);
    double height = getElementHeight(_targetId);
    size = Size(width, height);
  }
}
