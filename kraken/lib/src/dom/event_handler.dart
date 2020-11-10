/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'package:flutter/rendering.dart';
import 'package:kraken/dom.dart';
import 'package:kraken/rendering.dart';
import 'package:kraken/scheduler.dart';
import 'package:flutter/gestures.dart';


mixin EventHandlerMixin on Node {
  num _touchStartTime = 0;
  num _touchEndTime = 0;
  OffsetPair _initialPosition;

  static const int MAX_STEP_MS = 10;
  final Throttling _throttler = Throttling(duration: Duration(milliseconds: MAX_STEP_MS));

  void addEventResponder(RenderBoxModel renderBoxModel) {
    renderBoxModel.onPointerDown = handlePointDown;
    renderBoxModel.onPointerMove = handlePointMove;
    renderBoxModel.onPointerUp = handlePointUp;
    renderBoxModel.onPointerCancel = handlePointCancel;
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

  double _getGlobalDistance(PointerEvent event) {
    final Offset offset = event.position - _initialPosition.global;
    return offset.distance;
  }

  void handlePointDown(PointerDownEvent pointEvent) {
    TouchEvent event = _getTouchEvent('touchstart', pointEvent);
    _touchStartTime = event.timeStamp;
    _initialPosition = OffsetPair(local: pointEvent.localPosition, global: pointEvent.position);
    dispatchEvent(event);
  }

  void handlePointMove(PointerMoveEvent pointEvent) {
    _throttler.throttle(() {
      TouchEvent event = _getTouchEvent('touchmove', pointEvent);
      dispatchEvent(event);
    });
  }

  void handlePointUp(PointerUpEvent pointEvent) {
    TouchEvent event = _getTouchEvent('touchend', pointEvent);
    _touchEndTime = event.timeStamp;
    dispatchEvent(event);

    if (_getGlobalDistance(pointEvent) < kTouchSlop) {
      handleClick(Event('click', EventInit()));
    }
  }

  void handlePointCancel(PointerCancelEvent pointEvent) {
    Event event = Event('touchcancel', EventInit());
    event.detail = {};
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
    event.detail = {};
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
