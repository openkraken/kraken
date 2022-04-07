/*
 * Copyright (C) 2019-present The Kraken authors. All rights reserved.
 */

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:kraken/dom.dart';
import 'package:kraken/gesture.dart';
import 'package:kraken/src/scheduler/throttle.dart';

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

enum PointState {
  Down,
  Move,
  Up,
  Cancel
}

// The coordinate point at which a pointer (e.g finger or stylus) intersects the target surface of an interface.
// This may apply to a finger touching a touch-screen, or an digital pen writing on a piece of paper.
// https://www.w3.org/TR/touch-events/#dfn-touch-point
// https://github.com/WebKit/WebKit/blob/main/Source/WebCore/platform/PlatformTouchPoint.h#L31
class TouchPoint {
  final int id;
  final PointState state;
  final Offset pos;
  final Offset screenPos;
  final double radiusX;
  final double radiusY;
  final double rotationAngle;
  final double force;

  const TouchPoint(this.id, this.state, this.pos, this.screenPos, this.radiusX, this.radiusY, this.rotationAngle, this.force);
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
    gestureRecognizers[EVENT_LONG_PRESS] = LongPressGestureRecognizer()..onLongPress = instance._onLongPress;
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
  final Map<String, bool> _eventsInPath = {};

  final Throttling _throttler = Throttling(duration: Duration(milliseconds: _MAX_STEP_MS));

  final Map<int, EventTarget> _pointTargets = {};
  void _bindEventTargetWithTouchPoint(TouchPoint touchPoint, EventTarget eventTarget) {
    _pointTargets[touchPoint.id] = eventTarget;
  }
  void _unbindEventTargetWithTouchPoint(TouchPoint touchPoint) {
    _pointTargets.remove(touchPoint.id);
  }

  TouchPoint _toTouchPoint(PointerEvent pointerEvent) {
    PointState pointState = PointState.Cancel;
    if (pointerEvent is PointerDownEvent) {
      pointState = PointState.Down;
    } else if (pointerEvent is PointerMoveEvent) {
      pointState = PointState.Move;
    } else if (pointerEvent is PointerUpEvent) {
      pointState = PointState.Up;
    } else {
      pointState = PointState.Cancel;
    }

    return TouchPoint(
      pointerEvent.pointer,
      pointState,
      pointerEvent.localPosition,
      pointerEvent.position,
      pointerEvent.radiusMajor,
      pointerEvent.radiusMinor,
      pointerEvent.orientation,
      pointerEvent.pressure
    );
  }

  final Map<int, TouchPoint> _touchPoints = {};
  void _addPoint(TouchPoint touchPoint) {
    _touchPoints[touchPoint.id] = touchPoint;
  }
  void _removePoint(TouchPoint touchPoint) {
    _touchPoints.remove(touchPoint.id);
  }

  EventTarget? _target;

  Touch _toTouch(TouchPoint touchPoint) {
    return Touch(
      identifier: touchPoint.id,
      target: _pointTargets[touchPoint.id]!,
      screenX: touchPoint.screenPos.dx,
      screenY: touchPoint.screenPos.dy,
      clientX: touchPoint.pos.dx,
      clientY: touchPoint.pos.dy,
      pageX: touchPoint.pos.dx,
      pageY: touchPoint.pos.dy,
      radiusX: touchPoint.radiusX,
      radiusY: touchPoint.radiusY,
      rotationAngle: touchPoint.rotationAngle,
      force: touchPoint.force,
    );
  }

  void _gatherEventsInPath() {
    // Reset the event map when start a new gesture.
    _eventsInPath.clear();

    for (int i = 0; i < _eventPath.length; i++) {
      EventTarget eventTarget = _eventPath[i];
      eventTarget.getEventHandlers().keys.forEach((eventType) {
        _eventsInPath[eventType] = true;
      });
    }
  }

  void _addPointerDownEventToMatchedRecognizers(PointerDownEvent event) {
    // Add pointer to gestures then register the gesture recognizer to the arena.
    _gestureRecognizers.forEach((key, gesture) {
      // Register the recognizer that needs to be monitored.
      if (_eventsInPath.containsKey(key)) {
        gesture.addPointer(event);
      }
    });
  }


  void handlePointerEvent(PointerEvent event) {
    if (event is PointerHoverEvent) {
      // Hover does nothing and returns directly.
      return;
    }

    // Stores the current TouchPoint to trigger the corresponding event.
    TouchPoint touchPoint = _toTouchPoint(event);

    _addPoint(touchPoint);

    if (event is PointerDownEvent) {
      _gatherEventsInPath();

      // The current eventTarget state needs to be stored for use in the callback of GestureRecognizer.
      _target = _eventPath.isNotEmpty ? _eventPath.first : null;
      if (_target != null) {
        _bindEventTargetWithTouchPoint(touchPoint, _target!);
      }
    }

    _handleTouchPoint(touchPoint);

    // Make sure gesture event is dispatched after touchstart event.
    if (event is PointerDownEvent) {
      _addPointerDownEventToMatchedRecognizers(event);
    }

    if (event is PointerUpEvent || event is PointerCancelEvent) {
      _removePoint(touchPoint);
      _unbindEventTargetWithTouchPoint(touchPoint);
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

  void _onLongPress() {
    _handleMouseEvent(EVENT_LONG_PRESS);
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

  void _handleTouchPoint(TouchPoint currentTouchPoint) {
    String eventType;
    if (currentTouchPoint.state == PointState.Down) {
      eventType = EVENT_TOUCH_START;
    } else if (currentTouchPoint.state == PointState.Move) {
      eventType = EVENT_TOUCH_MOVE;
    } else if (currentTouchPoint.state == PointState.Up) {
      eventType = EVENT_TOUCH_END;
    } else {
      eventType = EVENT_TOUCH_CANCEL;
    }

    if (_eventsInPath.containsKey(eventType)) {
      TouchEvent e = TouchEvent(eventType);
      List<TouchPoint> touchPoints = _touchPoints.values.toList();

      for (int i = 0; i < touchPoints.length; i++) {
        TouchPoint touchPoint = touchPoints[i];
        Touch touch = _toTouch(touchPoint);

        if (currentTouchPoint.id == touchPoint.id) {
          // TODO: add pointEvent list for handle pointEvent at the current frame and support changedTouches.
          e.changedTouches.append(touch);
        }
        if (_pointTargets[touchPoint.id] == _pointTargets[currentTouchPoint.id]) {
          // A list of Touch objects for every point of contact that is touching the surface
          // and started on the element that is the target of the current event.
          e.targetTouches.append(touch);
        }
        e.touches.append(touch);
      }


      if (eventType == EVENT_TOUCH_MOVE) {
        _throttler.throttle(() {
          _pointTargets[currentTouchPoint.id]?.dispatchEvent(e);
        });
      } else {
        _pointTargets[currentTouchPoint.id]?.dispatchEvent(e);
      }
    }
  }
}
