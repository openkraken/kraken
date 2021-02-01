/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'package:flutter/rendering.dart';
import 'package:kraken/dom.dart';
import 'package:kraken/rendering.dart';
import 'package:kraken/scheduler.dart';


mixin EventHandlerMixin on Node {
  static const int MAX_STEP_MS = 10;
  final Throttling _throttler = Throttling(duration: Duration(milliseconds: MAX_STEP_MS));

  void addEventResponder(RenderBoxModel renderBoxModel) {
    renderBoxModel.onPointerDown = handlePointDown;
    renderBoxModel.onPointerMove = handlePointMove;
    renderBoxModel.onPointerUp = handlePointUp;
    renderBoxModel.onPointerCancel = handlePointCancel;
    renderBoxModel.onClick = handleClick;
    renderBoxModel.initGestureRecognizer(eventHandlers);
  }

  void removeEventResponder(RenderBoxModel renderBoxModel) {
    renderBoxModel.onPointerDown = null;
    renderBoxModel.onPointerMove = null;
    renderBoxModel.onPointerUp = null;
    renderBoxModel.onPointerCancel = null;
  }

  bool hasPointerEvent() {
    return eventHandlers.containsKey('click') ||
        eventHandlers.containsKey('touchstart') ||
        eventHandlers.containsKey('touchmove') ||
        eventHandlers.containsKey('touchend') ||
        eventHandlers.containsKey('touchcancel');
  }

  void handlePointDown(PointerDownEvent pointEvent) {
    TouchEvent event = _getTouchEvent(EVENT_TOUCH_START, pointEvent);
    dispatchEvent(event);
  }

  void handlePointMove(PointerMoveEvent pointEvent) {
    _throttler.throttle(() {
      TouchEvent event = _getTouchEvent(EVENT_TOUCH_MOVE, pointEvent);
      dispatchEvent(event);
    });
  }

  void handlePointUp(PointerUpEvent pointEvent) {
    TouchEvent event = _getTouchEvent(EVENT_TOUCH_END, pointEvent);
    dispatchEvent(event);
  }

  void handlePointCancel(PointerCancelEvent pointEvent) {
    Event event = Event(EVENT_TOUCH_CANCEL, EventInit());
    dispatchEvent(event);
  }

  TouchEvent _getTouchEvent(String type, PointerEvent pointEvent) {
    TouchEvent event = TouchEvent(type);
    // Use original event, prevent to be relative coordinate
    if (pointEvent.original != null) pointEvent = pointEvent.original;

    Touch touch = Touch(
      identifier: pointEvent.pointer,
      target: this,
      screenX: pointEvent.position.dx,
      screenY: pointEvent.position.dy,
      clientX: pointEvent.localPosition.dx,
      clientY: pointEvent.localPosition.dy,
      pageX: pointEvent.localPosition.dx,
      pageY: pointEvent.localPosition.dy,
      radiusX: pointEvent.radiusMajor,
      radiusY: pointEvent.radiusMinor,
      rotationAngle: pointEvent.orientation,
      force: pointEvent.pressure,
    );
    event.changedTouches.items.add(touch);
    event.targetTouches.items.add(touch);
    event.touches.items.add(touch);
    return event;
  }

  void handleClick(Event event) {
    dispatchEvent(event);
  }

  void handleAppear() {
    dispatchEvent(AppearEvent());
  }

  void handleDisappear() {
    dispatchEvent(DisappearEvent());
  }

  void handleIntersectionChange(IntersectionObserverEntry entry) {
    // Only visible element will trigger intersection change event
    Rect boundingClientRect = entry.boundingClientRect;
    if (boundingClientRect.left == boundingClientRect.right || boundingClientRect.top == boundingClientRect.bottom)
      return;

    dispatchEvent(IntersectionChangeEvent(entry.intersectionRatio));
    if (entry.intersectionRatio > 0) {
      handleAppear();
    } else {
      handleDisappear();
    }
  }
}
