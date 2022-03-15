/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:kraken/dom.dart';
import 'package:kraken/src/gesture/gesture_dispatcher.dart';

typedef HandleGetEventTarget = EventTarget Function();

mixin RenderEventListenerMixin on RenderBox {

  HandleGetEventTarget? getEventTarget;

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    assert(debugHandleEvent(event, entry));
    // Set event path at begin stage and reset it at end stage on viewport render box.
    // And if event path existed, it means current render box is not the first in path.
    if (event is PointerDownEvent && getEventTarget != null && GestureDispatcher.instance.getEventPath().isEmpty) {
      // Store the first handleEvent the event path list.
      GestureDispatcher.instance.setEventPath(getEventTarget!());
    }
    super.handleEvent(event, entry);
  }
}
