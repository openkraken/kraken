/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:flutter/rendering.dart';
import 'package:webf/dom.dart';
import 'package:webf/src/gesture/gesture_dispatcher.dart';

typedef HandleGetEventTarget = EventTarget Function();

typedef HandleGetGestureDispather = GestureDispatcher Function();

mixin RenderEventListenerMixin on RenderBox {
  HandleGetEventTarget? getEventTarget;

  HandleGetGestureDispather? getGestureDispather;

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    assert(debugHandleEvent(event, entry));
    // Set event path at begin stage and reset it at end stage on viewport render box.
    // And if event path existed, it means current render box is not the first in path.
    if (getEventTarget != null && getGestureDispather != null) {
      if (event is PointerDownEvent) {
        // Store the first handleEvent the event path list.
        GestureDispatcher gestureDispatcher = getGestureDispather!();
        if (gestureDispatcher.getEventPath().isEmpty) {
          gestureDispatcher.setEventPath(getEventTarget!());
        }
      }
    }

    super.handleEvent(event, entry);
  }
}
