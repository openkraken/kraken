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

mixin EventHandlerMixin on EventTarget {
  static const int MAX_STEP_MS = 10;
  final Throttling _throttler = Throttling(duration: Duration(milliseconds: MAX_STEP_MS));

  AppearEventState appearEventState = AppearEventState.none;

  void addEventResponder(RenderPointerListenerMixin renderBox) {
    renderBox.onClick = handleMouseEvent;
    renderBox.onSwipe = dispatchEvent;
    renderBox.onPan = dispatchEvent;
    renderBox.onScale = dispatchEvent;
    renderBox.onLongPress = dispatchEvent;
    renderBox.getEventHandlers = getEventHandlers;
    renderBox.getEventTarget = getEventTarget;
    renderBox.dispatchEvent = dispatchEvent;
  }

  void removeEventResponder(RenderPointerListenerMixin renderBox) {
    renderBox.onClick = null;
    renderBox.onSwipe = null;
    renderBox.onPan = null;
    renderBox.onScale = null;
    renderBox.onLongPress = null;
    renderBox.getEventTarget = null;
    renderBox.dispatchEvent = null;
  }

  EventTarget getEventTarget() {
    return this;
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
    event.changedTouches.append(touch);
    event.targetTouches.append(touch);
    event.touches.append(touch);
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
