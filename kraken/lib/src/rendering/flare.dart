import 'dart:ui';

import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/scheduler.dart';
import 'package:kraken/css.dart';
import 'package:kraken/rendering.dart';
import 'package:flutter/rendering.dart';

class FlareRenderObject extends FlareActorRenderObject with CSSComputedMixin, RenderPaddingMixin {
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
  void dispose() {
    // Lazy dispose, due to dynamic render-box arrangement.
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      if (!attached) super.dispose();
    });
  }

  @override
  void performResize() {
    double width = getElementComputedWidth(_targetId);
    double height = getElementComputedHeight(_targetId);
    size = Size(width, height);
  }
}
