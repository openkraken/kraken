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

  Touch _toTouch(PointerEvent event) {
    return Touch(
        identifier: event.pointer,
        target: getEventTarget!(),
        screenX: event.position.dx,
        screenY: event.position.dy,
        clientX: event.localPosition.dx,
        clientY: event.localPosition.dy,
        pageX: event.localPosition.dx,
        pageY: event.localPosition.dy,
        radiusX: event.radiusMajor,
        radiusY: event.radiusMinor,
        rotationAngle: event.orientation,
        force: event.pressure,
      );
  }

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
        GestureDispatcher.instance.addTouch(_toTouch(event));
      } else if (event is PointerUpEvent || event is PointerCancelEvent) {
        GestureDispatcher.instance.removeTouch(_toTouch(event));
      }
    }

    super.handleEvent(event, entry);
  }
}
