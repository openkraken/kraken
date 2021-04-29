/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'package:kraken/gesture.dart';
import 'package:kraken/dom.dart';

import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';

typedef GestureCallback = void Function(Event);

typedef ClickEventListener = void Function(String, PointerDownEvent);

mixin RenderPointerListenerMixin on RenderBox {
  /// Called when a pointer comes into contact with the screen (for touch
  /// pointers), or has its button pressed (for mouse pointers) at this widget's
  /// location.
  PointerDownEventListener onPointerDown;

  /// Called when a pointer that triggered an [onPointerDown] changes position.
  PointerMoveEventListener onPointerMove;

  /// Called when a pointer that triggered an [onPointerDown] is no longer in
  /// contact with the screen.
  PointerUpEventListener onPointerUp;

  /// Called when the input from a pointer that triggered an [onPointerDown] is
  /// no longer directed towards this receiver.
  PointerCancelEventListener onPointerCancel;

  /// Called when a pointer signal occurs over this object.
  PointerSignalEventListener onPointerSignal;

  ClickEventListener onClick;

  GestureCallback onSwipe;

  GestureCallback onPan;

  GestureCallback onScale;

  GestureCallback onLongPress;

  void onPanStart(DragStartDetails details) {
    onPan(GestureEvent(EVENT_PAN, GestureEventInit( state: EVENT_STATE_START, deltaX: details.globalPosition.dx, deltaY: details.globalPosition.dy )));
  }

  void onPanUpdate(DragUpdateDetails details) {
    onPan(GestureEvent(EVENT_PAN, GestureEventInit( state: EVENT_STATE_UPDATE, deltaX: details.globalPosition.dx, deltaY: details.globalPosition.dy )));
  }

  void onPanEnd(DragEndDetails details) {
    onPan(GestureEvent(EVENT_PAN, GestureEventInit( state: EVENT_STATE_END, velocityX: details.velocity.pixelsPerSecond.dx, velocityY: details.velocity.pixelsPerSecond.dy )));
  }

  void onScaleStart(ScaleStartDetails details) {
    onScale(GestureEvent(EVENT_SCALE, GestureEventInit( state: EVENT_STATE_START )));
  }

  void onScaleUpdate(ScaleUpdateDetails details) {
    onScale(GestureEvent(EVENT_SCALE, GestureEventInit( state: EVENT_STATE_UPDATE, rotation: details.rotation, scale: details.scale )));
  }

  void onScaleEnd(ScaleEndDetails details) {
    onScale(GestureEvent(EVENT_SCALE, GestureEventInit( state: EVENT_STATE_END )));
  }

  void onLongPressEnd(LongPressEndDetails details) {
    onLongPress(GestureEvent(EVENT_Long_PRESS, GestureEventInit(deltaX: details.globalPosition.dx, deltaY: details.globalPosition.dy )));
  }

  /// Called when a pointer signal this object.
  void initGestureRecognizer(Map<String, List<EventHandler>> eventHandlers) {
    if (eventHandlers.containsKey('click')) {
      gestures[ClickGestureRecognizer] = ClickGestureRecognizer();
      (gestures[ClickGestureRecognizer] as ClickGestureRecognizer).onClick = onClick;
    }
    if (eventHandlers.containsKey('swipe')) {
      gestures[SwipeGestureRecognizer] = SwipeGestureRecognizer();
      (gestures[SwipeGestureRecognizer] as SwipeGestureRecognizer).onSwipe = onSwipe;
    }
    if (eventHandlers.containsKey('pan')) {
      gestures[PanGestureRecognizer] = PanGestureRecognizer();
      (gestures[PanGestureRecognizer] as PanGestureRecognizer).onStart = onPanStart;
      (gestures[PanGestureRecognizer] as PanGestureRecognizer).onUpdate = onPanUpdate;
      (gestures[PanGestureRecognizer] as PanGestureRecognizer).onEnd = onPanEnd;
    }
    if (eventHandlers.containsKey('longpress')) {
      gestures[LongPressGestureRecognizer] = LongPressGestureRecognizer();
      (gestures[LongPressGestureRecognizer] as LongPressGestureRecognizer).onLongPressEnd = onLongPressEnd;
    }
    if (eventHandlers.containsKey('scale')) {
      gestures[ScaleGestureRecognizer] = ScaleGestureRecognizer();
      (gestures[ScaleGestureRecognizer] as ScaleGestureRecognizer).onStart = onScaleStart;
      (gestures[ScaleGestureRecognizer] as ScaleGestureRecognizer).onUpdate = onScaleUpdate;
      (gestures[ScaleGestureRecognizer] as ScaleGestureRecognizer).onEnd = onScaleEnd;
    }
  }

  final Map<Type, GestureRecognizer> gestures = <Type, GestureRecognizer>{};

  @override
  void handleEvent(PointerEvent event, HitTestEntry entry) {
    assert(debugHandleEvent(event, entry));

    /// AddPointer when a pointer comes into contact with the screen (for touch
    /// pointers), or has its button pressed (for mouse pointers) at this widget's
    /// location.
    if (event is PointerDownEvent) {
      gestures.forEach((key, gesture) {
        gesture.addPointer(event);
      });
    }

    if (onPointerDown != null && event is PointerDownEvent)
      return onPointerDown(event);
    if (onPointerMove != null && event is PointerMoveEvent)
      return onPointerMove(event);
    if (onPointerUp != null && event is PointerUpEvent)
      return onPointerUp(event);
    if (onPointerCancel != null && event is PointerCancelEvent)
      return onPointerCancel(event);
    if (onPointerSignal != null && event is PointerSignalEvent)
      return onPointerSignal(event);
  }
}
