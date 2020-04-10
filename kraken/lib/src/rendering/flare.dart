import 'dart:ui';

import 'package:flare_flutter/flare_actor.dart';
import 'package:kraken/style.dart';

class FlareRenderObject extends FlareActorRenderObject with ElementStyleMixin {
  int _nodeId;

  FlareRenderObject(this._nodeId);

  @override
  void performLayout() {
    if (!sizedByParent) {
      double width = getElementWidth(_nodeId);
      double height = getElementHeight(_nodeId);
      size = Size(width, height);
    }
  }

  @override
  void performResize() {
    double width = getElementWidth(_nodeId);
    double height = getElementHeight(_nodeId);
    size = Size(width, height);
  }
}
