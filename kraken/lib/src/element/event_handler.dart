import 'package:flutter/rendering.dart';
import 'package:kraken/element.dart';
import 'package:kraken/rendering.dart';
import 'package:kraken/scheduler.dart';

mixin EventHandlerMixin on Node {
  num _touchStartTime = 0;
  num _touchEndTime = 0;

  static const int MAX_STEP_MS = 10;
  final Throttling _throttler =
      Throttling(duration: Duration(milliseconds: MAX_STEP_MS));

  void handlePointDown(PointerDownEvent pointEvent) {
    TouchEvent event = _getTouchEvent('touchstart', pointEvent);
    _touchStartTime = event.timeStamp;
    this.dispatchEvent(event);
  }

  void handlePointMove(PointerMoveEvent pointEvent) {
    _throttler.throttle(() {
      TouchEvent event = _getTouchEvent('touchmove', pointEvent);
      this.dispatchEvent(event);
    });
  }

  void handlePointUp(PointerUpEvent pointEvent) {
    TouchEvent event = _getTouchEvent('touchend', pointEvent);
    _touchEndTime = event.timeStamp;
    this.dispatchEvent(event);

    // <300ms to trigger click
    if (_touchStartTime > 0 &&
        _touchEndTime > 0 &&
        _touchEndTime - _touchStartTime < 300) {
      handleClick(Event('click', EventInit()));
    }
  }

  void handlePointCancel(PointerCancelEvent pointEvent) {
    Event event = Event('touchcancel', EventInit());
    event.detail = {};
    this.dispatchEvent(event);
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
    this.dispatchEvent(event);
  }

  void handleAppear() {
    this.dispatchEvent(AppearEvent());
  }

  void handleDisappear() {
    this.dispatchEvent(DisappearEvent());
  }

  void handleIntersectionChange(IntersectionObserverEntry entry) {
    // Only visible element will trigger intersection change event
    Rect boundingClientRect = entry.boundingClientRect;
    if (boundingClientRect.left == boundingClientRect.right ||
        boundingClientRect.top == boundingClientRect.bottom) return;

    this.dispatchEvent(IntersectionChangeEvent(entry.intersectionRatio));
    if (entry.intersectionRatio > 0) {
      handleAppear();
    } else {
      handleDisappear();
    }
  }
}
