import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/scheduler.dart';

class FlareRenderObject extends FlareActorRenderObject {
  FlareRenderObject();

  @override
  void performLayout() {
    if (!sizedByParent) {
      size = constraints.biggest;
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
    size = constraints.biggest;
  }
}
