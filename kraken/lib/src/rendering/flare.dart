import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:kraken/style.dart';

class FlareRenderObject extends FlareActorRenderObject with ElementStyleMixin {

  int _nodeId;


  FlareRenderObject(this._nodeId);

  @override
  void performLayout() {
    if (!sizedByParent) {
      double width = getParentWidth(_nodeId);
      double height = getParentHeight(_nodeId);
      size = Size(width, height);
    }
  }

  @override
  void performResize() {
    double width = getParentWidth(_nodeId);
    double height = getParentHeight(_nodeId);
    size = Size(width, height);
  }
}
