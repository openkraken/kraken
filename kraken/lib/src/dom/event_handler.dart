/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'package:flutter/rendering.dart';
import 'package:kraken/dom.dart';
import 'package:kraken/rendering.dart';
import 'package:kraken/scheduler.dart';

enum AppearEventState {
  none,
  appear,
  disappear
}

mixin EventHandlerMixin on Node {
  static const int MAX_STEP_MS = 10;
  final Throttling _throttler = Throttling(duration: Duration(milliseconds: MAX_STEP_MS));

  AppearEventState appearEventState = AppearEventState.none;

  void addEventResponder(RenderBoxModel renderBoxModel) {
    renderBoxModel.onPointerDown = handlePointDown;
    renderBoxModel.onPointerMove = handlePointMove;
    renderBoxModel.onPointerUp = handlePointUp;
    renderBoxModel.onPointerCancel = handlePointCancel;
    renderBoxModel.onClick = handleMouseEvent;
    renderBoxModel.onSwipe = dispatchEvent;
    renderBoxModel.onPan = dispatchEvent;
    renderBoxModel.onScale = dispatchEvent;
    renderBoxModel.onLongPress = dispatchEvent;
  }

  void removeEventResponder(RenderBoxModel renderBoxModel) {
    renderBoxModel.onPointerDown = null;
    renderBoxModel.onPointerMove = null;
    renderBoxModel.onPointerUp = null;
    renderBoxModel.onPointerCancel = null;
    renderBoxModel.onClick = null;
    renderBoxModel.onSwipe = null;
    renderBoxModel.onPan = null;
    renderBoxModel.onScale = null;
    renderBoxModel.onLongPress = null;
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
    var pointerEventOriginal = pointEvent.original;
    // Use original event, prevent to be relative coordinate
    if (pointerEventOriginal != null) pointEvent = pointerEventOriginal;

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

  void handleMouseEvent(String eventType, { PointerDownEvent? down, PointerUpEvent? up }) {
    RenderBoxModel? root = elementManager.viewportElement.renderBoxModel;
    if (root == null || up == null) {
      return;
    }
    Offset globalOffset = root.globalToLocal(Offset(up.position.dx, up.position.dy));
    dispatchEvent(MouseEvent(eventType,
      MouseEventInit(
        bubbles: true,
        cancelable: true,
        clientX: globalOffset.dx,
        clientY: globalOffset.dy,
        offsetX: up.localPosition.dx,
        offsetY: up.localPosition.dy,
      )
    ));
  }

  void handleAppear() {
    if (appearEventState == AppearEventState.appear) return;
    appearEventState = AppearEventState.appear;

    dispatchEvent(AppearEvent());
  }

  void handleDisappear() {
    if (appearEventState == AppearEventState.disappear) return;
    appearEventState = AppearEventState.disappear;
    dispatchEvent(DisappearEvent());
  }

  void handleIntersectionChange(IntersectionObserverEntry entry) {
    dispatchEvent(IntersectionChangeEvent(entry.intersectionRatio));
    if (entry.intersectionRatio > 0) {
      handleAppear();
    } else {
      handleDisappear();
    }
  }
}
