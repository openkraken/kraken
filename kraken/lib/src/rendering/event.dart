/*
 * Copyright (C) 2019-present The Kraken authors. All rights reserved.
 */

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
    if (getEventTarget != null) {
      if (event is PointerDownEvent) {
        // Store the first handleEvent the event path list.
        if (GestureDispatcher.instance.getEventPath().isEmpty) {
          GestureDispatcher.instance.setEventPath(getEventTarget!());
        }
      }
    }

    super.handleEvent(event, entry);
  }
}
