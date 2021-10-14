/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'package:kraken/gesture.dart';
import 'package:kraken/dom.dart';

import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';

typedef GestureCallback = void Function(Event);

typedef MouseEventListener = void Function(String, TapUpDetails);

typedef GetEventHandlers = Map<String, List<EventHandler>> Function();

typedef GetEventTarget = EventTarget Function();

typedef DispatchEvent = void Function(Event event);

mixin RenderPointerListenerMixin on RenderBox {
  /// Called when a pointer signal occurs over this object.
  PointerSignalEventListener? onPointerSignal;

  MouseEventListener? onClick;

  GestureCallback? onSwipe;

  GestureCallback? onDoubleClick;

  GestureCallback? onPan;

  GestureCallback? onScale;

  GestureCallback? onLongPress;

  GetEventHandlers? getEventHandlers;

  GetEventTarget? getEventTarget;

  DispatchEvent? dispatchEvent;

  @override
  void handleEvent(PointerEvent event, HitTestEntry entry) {
    assert(debugHandleEvent(event, entry));

    /// AddPointer when a pointer comes into contact with the screen (for touch
    /// pointers), or has its button pressed (for mouse pointers) at this widget's
    /// location.
    if (event is PointerDownEvent) {
      GestureManager.instance().addTargetToList(this);
    }
  }
}
