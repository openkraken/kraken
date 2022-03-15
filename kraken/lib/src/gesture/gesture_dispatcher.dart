/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:kraken/dom.dart';
import 'package:kraken/gesture.dart';
import 'package:kraken/src/scheduler/throttle.dart';

import 'pointer.dart';

const int _MAX_STEP_MS = 16;

class _DragEventInfo extends Drag {
  static _DragEventInfo? _instance;
  static _DragEventInfo get instance {
    return _instance ??= _DragEventInfo._();
  }

  _DragEventInfo._();

  /// The pointer has moved.
  @override
  void update(DragUpdateDetails details) {
    GestureDispatcher.instance._handleGestureEvent(EVENT_DRAG, state: EVENT_STATE_UPDATE, deltaX: details.globalPosition.dx, deltaY: details.globalPosition.dy);
  }

  /// The pointer is no longer in contact with the screen.
  ///
  /// The velocity at which the pointer was moving when it stopped contacting
  /// the screen is available in the `details`.
  @override
  void end(DragEndDetails details) {
    GestureDispatcher.instance._handleGestureEvent(EVENT_DRAG, state: EVENT_STATE_END, velocityX: details.velocity.pixelsPerSecond.dx, velocityY: details.velocity.pixelsPerSecond.dy);
  }

  /// The input from the pointer is no longer directed towards this receiver.
  ///
  /// For example, the user might have been interrupted by a system-modal dialog
  /// in the middle of the drag.
  @override
  void cancel() {
    GestureDispatcher.instance._handleGestureEvent(EVENT_DRAG, state: EVENT_STATE_CANCEL);
  }
}

class GestureDispatcher {

  static GestureDispatcher? _instance;
  static GestureDispatcher get instance {
    if (_instance == null) {
      GestureDispatcher instance = _instance = GestureDispatcher._();
      _addAllGestureRecognizer(instance);
    }
    return _instance!;
  }

  static void _addAllGestureRecognizer(GestureDispatcher instance) {
    Map<String, GestureRecognizer> gestureRecognizers = instance._gestureRecognizers;
    // Tap Recognizer
    gestureRecognizers[EVENT_CLICK] = TapGestureRecognizer()..onTapUp = instance._onClick;
    // DoubleTap Recognizer
    gestureRecognizers[EVENT_DOUBLE_CLICK] = DoubleTapGestureRecognizer()..onDoubleTapDown = instance._onDoubleClick;
    // Swipe Recognizer
    gestureRecognizers[EVENT_SWIPE] = SwipeGestureRecognizer()..onSwipe = instance._onSwipe;
    // Pan Recognizer
    gestureRecognizers[EVENT_PAN] = PanGestureRecognizer()
      ..onStart = instance._onPanStart
      ..onUpdate = instance._onPanUpdate
      ..onEnd = instance._onPanEnd;
    // LongPress Recognizer
    gestureRecognizers[EVENT_LONG_PRESS] = LongPressGestureRecognizer()..onLongPressEnd = instance._onLongPressEnd;
    // Scale Recognizer
    gestureRecognizers[EVENT_SCALE] = ScaleGestureRecognizer()
      ..onStart = instance._onScaleStart
      ..onUpdate = instance._onScaleUpdate
      ..onEnd = instance._onScaleEnd;
    // Drag Recognizer
    gestureRecognizers[EVENT_DRAG] = ImmediateMultiDragGestureRecognizer()
      ..onStart = instance._onDragStart;
  }

  GestureDispatcher._();

  final Map<String, GestureRecognizer> _gestureRecognizers = <String, GestureRecognizer>{};

  List<EventTarget> _eventPath = const [];
  // Collect the events in the event path list.
  final Map<String, bool> _eventsInPath = const {};

  final Map<int, Pointer> _pointerIdToPointer = {};

  EventTarget? _target;

  final Throttling _throttler = Throttling(duration: Duration(milliseconds: _MAX_STEP_MS));

  void markEventsInPath() {
    // Reset the event map when start a new gesture.
    _eventsInPath.clear();

    for (int i = 0; i < _eventPath.length; i++) {
      EventTarget eventTarget = _eventPath[i];
      eventTarget.getEventHandlers().keys.forEach((eventType) {
        _eventsInPath[eventType] = true;
      });
    }
  }

  void addPointerDownEventToMatchedRecognizers(PointerDownEvent event) {
    // Add pointer to gestures then register the gesture recognizer to the arena.
    _gestureRecognizers.forEach((key, gesture) {
      // Register the recognizer that needs to be monitored.
      if (_eventsInPath.containsKey(key)) {
        gesture.addPointer(event);
      }
    });
  }

  void handlePointerEvent(PointerEvent event) {
    String touchType;

    if (event is PointerDownEvent) {
      touchType = EVENT_TOUCH_START;

      _pointerIdToPointer[event.pointer] = Pointer(event);
      markEventsInPath();
      addPointerDownEventToMatchedRecognizers(event);

      // The target node triggered by the gesture is the bottom node of hitTest.
      // The scroll element needs to be judged by isScrollingContentBox to find the real element upwards.
      for (int i = 0; i < _eventPath.length; i++) {
        EventTarget eventTarget = _eventPath[i];
        Pointer? pointer = _pointerIdToPointer[event.pointer];
        pointer?.updateEventTarget(eventTarget);
        break;
      }

    } else if (event is PointerMoveEvent) {
      touchType = EVENT_TOUCH_MOVE;
    } else if (event is PointerUpEvent) {
      touchType = EVENT_TOUCH_END;
    } else {
      touchType = EVENT_TOUCH_CANCEL;
    }

    Pointer? pointer = _pointerIdToPointer[event.pointer];
    pointer?.updateEvent(event);

    // Only dispatch touch event that added.
    bool needDispatch = _eventsInPath.containsKey(touchType);
    if (needDispatch && pointer != null) {
      _handleTouchEvent(touchType, _pointerIdToPointer[event.pointer]!, _pointerIdToPointer.values.toList());
    }

    // End of the gesture.
    if (event is PointerUpEvent || event is PointerCancelEvent) {
      // Multi pointer operations in the web will organize click and other gesture triggers.
      bool isSinglePointer = _pointerIdToPointer.length == 1;
      Pointer? pointer = _pointerIdToPointer[event.pointer];
      if (isSinglePointer && pointer != null) {
        _target = pointer.eventTarget;
      } else {
        _target = null;
      }

      _pointerIdToPointer.remove(event.pointer);
    }
  }

  void resetEventPath() {
    _eventPath = const [];
  }

  List<EventTarget> getEventPath() {
    return _eventPath;
  }

  void setEventPath(EventTarget target) {
    _eventPath = target.eventPath;
  }

  void _onDoubleClick(TapDownDetails details) {
    _handleMouseEvent(EVENT_DOUBLE_CLICK, localPosition: details.localPosition, globalPosition: details.globalPosition);
  }

  void _onClick(TapUpDetails details) {
    _handleMouseEvent(EVENT_CLICK, localPosition: details.localPosition, globalPosition: details.globalPosition);
  }

  void _onLongPressEnd(LongPressEndDetails details) {
    _handleMouseEvent(EVENT_LONG_PRESS, localPosition: details.localPosition, globalPosition: details.globalPosition);
  }

  void _onSwipe(SwipeDetails details) {
    _handleGestureEvent(EVENT_SWIPE, velocityX: details.velocity.pixelsPerSecond.dx, velocityY: details.velocity.pixelsPerSecond.dy);
  }

  void _onPanStart(DragStartDetails details) {
    _handleGestureEvent(EVENT_PAN, state: EVENT_STATE_START, deltaX: details.globalPosition.dx, deltaY: details.globalPosition.dy);
  }

  void _onPanUpdate(DragUpdateDetails details) {
    _handleGestureEvent(EVENT_PAN, state: EVENT_STATE_UPDATE, deltaX: details.globalPosition.dx, deltaY: details.globalPosition.dy);
  }

  void _onPanEnd(DragEndDetails details) {
    _handleGestureEvent(EVENT_PAN, state: EVENT_STATE_END, velocityX: details.velocity.pixelsPerSecond.dx, velocityY: details.velocity.pixelsPerSecond.dy);
  }

  void _onScaleStart(ScaleStartDetails details) {
    _handleGestureEvent(EVENT_SCALE, state: EVENT_STATE_START);
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    _handleGestureEvent(EVENT_SCALE, state: EVENT_STATE_UPDATE, rotation: details.rotation, scale: details.scale);
  }

  void _onScaleEnd(ScaleEndDetails details) {
    _handleGestureEvent(EVENT_SCALE, state: EVENT_STATE_END);
  }

  Drag? _onDragStart(Offset position) {
    _handleGestureEvent(EVENT_DRAG, state: EVENT_STATE_START, deltaX: position.dx, deltaY: position.dy);
    return _DragEventInfo.instance;
  }

  void _handleMouseEvent(String type, {
    Offset localPosition = Offset.zero,
    Offset globalPosition = Offset.zero,
    bool bubbles = true,
    bool cancelable = true,
  }) {
    if (_target == null) {
      return;
    }
    // @TODO
    RenderBox? root = (_target as Node).ownerDocument.renderer;

    if (root == null) {
      return;
    }

    // When Kraken wraps the Flutter Widget, Kraken need to calculate the global coordinates relative to self.
    Offset globalOffset = root.globalToLocal(Offset(globalPosition.dx, globalPosition.dy));
    double clientX = globalOffset.dx;
    double clientY = globalOffset.dy;

    Event event = MouseEvent(type,
        MouseEventInit(
          bubbles: bubbles,
          cancelable: cancelable,
          clientX: clientX,
          clientY: clientY,
          offsetX: localPosition.dx,
          offsetY: localPosition.dy,
        )
    );
    _target?.dispatchEvent(event);
  }

  void _handleGestureEvent(String type, {
    String state = '',
    String direction = '',
    double rotation = 0.0,
    double deltaX = 0.0,
    double deltaY = 0.0,
    double velocityX = 0.0,
    double velocityY = 0.0,
    double scale = 0.0
  }) {
    Event event = GestureEvent(type, GestureEventInit(
      state: state,
      direction: direction,
      rotation: rotation,
      deltaX: deltaX,
      deltaY: deltaY,
      velocityX: velocityX,
      velocityY: velocityY,
      scale: scale,
    ));
    _target?.dispatchEvent(event);
  }

  void _handleTouchEvent(String eventType, Pointer targetPointer, List<Pointer> points) {
    TouchEvent e = TouchEvent(eventType);
    EventTarget currentTarget = targetPointer.eventTarget!;

    for (int i = 0; i < points.length; i++) {
      Pointer pointer = points[i];
      PointerEvent pointerEvent = pointer.event;
      EventTarget target = pointer.eventTarget!;

      Touch touch = Touch(
        identifier: pointerEvent.pointer,
        target: target,
        screenX: pointerEvent.position.dx,
        screenY: pointerEvent.position.dy,
        clientX: pointerEvent.localPosition.dx,
        clientY: pointerEvent.localPosition.dy,
        pageX: pointerEvent.localPosition.dx,
        pageY: pointerEvent.localPosition.dy,
        radiusX: pointerEvent.radiusMajor,
        radiusY: pointerEvent.radiusMinor,
        rotationAngle: pointerEvent.orientation,
        force: pointerEvent.pressure,
      );

      if (targetPointer == pointer) {
        e.changedTouches.append(touch);
      }

      if (currentTarget == target) {
        e.targetTouches.append(touch);
      }

      e.touches.append(touch);
    }

    if (eventType == EVENT_TOUCH_MOVE) {
      _throttler.throttle(() {
        currentTarget.dispatchEvent(e);
      });
    } else {
      currentTarget.dispatchEvent(e);
    }
  }
}
