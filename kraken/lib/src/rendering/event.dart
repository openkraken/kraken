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
    if (event is PointerDownEvent && getEventTarget != null) {
      GestureDispatcher.instance.addEventTarget(getEventTarget!());
    }
    super.handleEvent(event, entry);
  }
}
