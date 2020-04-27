import 'dart:ui';

import 'package:flare_flutter/flare_actor.dart';
import 'package:kraken/css.dart';

class FlareRenderObject extends FlareActorRenderObject with CSSComputedMixin {
  int _targetId;

  FlareRenderObject(this._targetId);

  @override
  void performLayout() {
    if (!sizedByParent) {
      double width = getElementComputedWidth(_targetId);
      double height = getElementComputedHeight(_targetId);
      size = Size(width, height);
    }
  }

  @override
  void performResize() {
    double width = getElementComputedWidth(_targetId);
    double height = getElementComputedHeight(_targetId);
    size = Size(width, height);
  }
}
