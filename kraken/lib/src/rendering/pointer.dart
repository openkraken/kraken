/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:kraken/dom.dart';
import 'package:kraken/gesture.dart';

typedef GestureCallback = void Function(Event);

typedef GetEventTarget = EventTarget Function();

typedef DispatchEvent = void Function(Event event);

typedef HandleMouseEvent = void Function(String type, {
  Offset localPosition,
  Offset globalPosition,
  bool bubbles,
  bool cancelable
});

typedef HandleGestureEvent = void Function(String type, {
  String state,
  String direction,
  double rotation,
  double deltaX,
  double deltaY,
  double velocityX,
  double velocityY,
  double scale
});

class EventManager {
  EventManager({ List<String>? events }) : _events = events ?? [];

  final List<String> _events;

  List<String> get events => _events;

  void add(String eventType) {
    _events.add(eventType);
  }

  void remove(String eventType) {
    _events.remove(eventType);
  }

  void clear() {
    _events.clear();
  }

  EventManager copyWith() {
    return EventManager(events: _events);
  }
}

mixin RenderPointerListenerMixin on RenderBox {
  /// Called when a pointer signal occurs over this object.
  PointerSignalEventListener? onPointerSignal;

  HandleMouseEvent? handleMouseEvent;

  HandleGestureEvent? handleGestureEvent;

  GetEventTarget? getEventTarget;

  DispatchEvent? dispatchEvent;

  EventManager eventManager = EventManager();

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
