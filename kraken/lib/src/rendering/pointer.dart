/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:kraken/dom.dart';
import 'package:kraken/src/gesture/pointer.dart' as gesture_pointer;

import '../../gesture.dart';

typedef GestureCallback = void Function(Event);

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

typedef HandleTouchEvent = void Function(String type, gesture_pointer.Pointer targetPoint, List<gesture_pointer.Pointer> pointerEventList);

typedef HandleGetEventTarget = EventTarget Function();

mixin RenderEventListenerMixin on RenderBox {
  /// Called when a pointer signal occurs over this object.
  PointerSignalEventListener? onPointerSignal;

  HandleMouseEvent? handleMouseEvent;

  HandleGestureEvent? handleGestureEvent;

  HandleTouchEvent? handleTouchEvent;

  HandleGetEventTarget? getEventTarget;

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    assert(debugHandleEvent(event, entry));
    GestureDispatcher.instance.handlePointerEvent(event, this);
    super.handleEvent(event, entry);
  }
}
