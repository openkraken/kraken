/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:kraken/dom.dart';
import 'package:kraken/gesture.dart';
import 'package:kraken/rendering.dart';
import 'package:kraken/src/scheduler/throttle.dart';

import 'pointer.dart';

const int _MAX_STEP_MS = 16;

class GestureDispatcher {

  static GestureDispatcher? _instance;
  static get instance {
    if (_instance == null) {
      GestureDispatcher instance = _instance = GestureDispatcher._();
      _bindAllGestureRecognizer(instance);
    }
    return _instance!;
  }

  static void _bindAllGestureRecognizer(GestureDispatcher instance) {
    instance._gestures[EVENT_CLICK] = TapGestureRecognizer();
    (instance._gestures[EVENT_CLICK] as TapGestureRecognizer).onTapUp = instance.onClick;

    instance._gestures[EVENT_DOUBLE_CLICK] = DoubleTapGestureRecognizer();
    (instance._gestures[EVENT_DOUBLE_CLICK] as DoubleTapGestureRecognizer).onDoubleTapDown = instance.onDoubleClick;

    instance._gestures[EVENT_SWIPE] = SwipeGestureRecognizer();
    (instance._gestures[EVENT_SWIPE] as SwipeGestureRecognizer).onSwipe = instance.onSwipe;

    instance._gestures[EVENT_PAN] = PanGestureRecognizer();
    (instance._gestures[EVENT_PAN] as PanGestureRecognizer).onStart = instance.onPanStart;
    (instance._gestures[EVENT_PAN] as PanGestureRecognizer).onUpdate = instance.onPanUpdate;
    (instance._gestures[EVENT_PAN] as PanGestureRecognizer).onEnd = instance.onPanEnd;

    instance._gestures[EVENT_LONG_PRESS] = LongPressGestureRecognizer();
    (instance._gestures[EVENT_LONG_PRESS] as LongPressGestureRecognizer).onLongPressEnd = instance.onLongPressEnd;

    instance._gestures[EVENT_SCALE] = ScaleGestureRecognizer();
    (instance._gestures[EVENT_SCALE] as ScaleGestureRecognizer).onStart = instance.onScaleStart;
    (instance._gestures[EVENT_SCALE] as ScaleGestureRecognizer).onUpdate = instance.onScaleUpdate;
    (instance._gestures[EVENT_SCALE] as ScaleGestureRecognizer).onEnd = instance.onScaleEnd;
  }

  GestureDispatcher._();

  final Map<String, GestureRecognizer> _gestures = <String, GestureRecognizer>{};

  final List<EventTarget> _hitTestTargets = [];
  // Collect the events in the hitTest list.
  final Map<String, bool> _hitTestEvents = {};

  final Map<int, Pointer> _pointerIdToPointer = {};

  EventTarget? _target;

  final Throttling _throttler = Throttling(duration: Duration(milliseconds: _MAX_STEP_MS));

  void addEventTarget(EventTarget lowestTarget) {
    if (_hitTestTargets.isNotEmpty) {
      return;
    }
    EventTarget? target = lowestTarget;
    while (target != null) {
      _hitTestTargets.add(target);
      target = target.parentEventTarget;
    }
  }

  void addPointer(PointerEvent event) {
    String touchType;

    if (event is PointerDownEvent) {
      // Reset the hitTest event map when start a new gesture.
      _hitTestEvents.clear();

      _pointerIdToPointer[event.pointer] = Pointer(event);

      for (int i = 0; i < _hitTestTargets.length; i++) {
        EventTarget eventTarget = _hitTestTargets[i];
        eventTarget.getEventHandlers().keys.forEach((eventType) {
          _hitTestEvents[eventType] = true;
        });
      }

      touchType = EVENT_TOUCH_START;

      // Add pointer to gestures then register the gesture recognizer to the arena.
      _gestures.forEach((key, gesture) {
        // Register the recognizer that needs to be monitored.
        if (_hitTestEvents.containsKey(key)) {
          gesture.addPointer(event);
        }
      });

      // The target node triggered by the gesture is the bottom node of hitTest.
      // The scroll element needs to be judged by isScrollingContentBox to find the real element upwards.
      for (int i = 0; i < _hitTestTargets.length; i++) {
        EventTarget eventTarget = _hitTestTargets[i];
        Pointer? pointer = _pointerIdToPointer[event.pointer];
        pointer?.target = eventTarget;
        break;
      }

      _hitTestTargets.clear();
    } else if (event is PointerMoveEvent) {
      touchType = EVENT_TOUCH_MOVE;
    } else if (event is PointerUpEvent) {
      touchType = EVENT_TOUCH_END;
    } else {
      touchType = EVENT_TOUCH_CANCEL;
    }

    Pointer? pointer = _pointerIdToPointer[event.pointer];
    pointer?.updateEvent(event);

    // If the target node is not attached, the event will be ignored.
    if (_pointerIdToPointer[event.pointer] == null) return;

    // Only dispatch touch event that added.
    bool needDispatch = _hitTestEvents.containsKey(touchType);
    if (needDispatch && pointer != null) {
      handleTouchEvent(touchType, _pointerIdToPointer[event.pointer]!, _pointerIdToPointer.values.toList());
    }

    // End of the gesture.
    if (event is PointerUpEvent || event is PointerCancelEvent) {
      // Multi pointer operations in the web will organize click and other gesture triggers.
      bool isSinglePointer = _pointerIdToPointer.length == 1;
      Pointer? pointer = _pointerIdToPointer[event.pointer];
      if (isSinglePointer && pointer != null) {
        _target = pointer.target;
      } else {
        _target = null;
      }

      _pointerIdToPointer.remove(event.pointer);
    }
  }

  void handlePointerEvent(PointerEvent event, RenderEventListenerMixin target) {
    /// AddPointer when a pointer comes into contact with the screen (for touch
    /// pointers), or has its button pressed (for mouse pointers) at this widget's
    /// location.
    if (event is PointerDownEvent && target.getEventTarget != null) {
      GestureDispatcher.instance.addEventTarget(target.getEventTarget!());
    }
  }

  void onDoubleClick(TapDownDetails details) {
    handleMouseEvent(EVENT_DOUBLE_CLICK, localPosition: details.localPosition, globalPosition: details.globalPosition);
  }

  void handleMouseEvent(String type, {
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

  void onClick(TapUpDetails details) {
    handleMouseEvent(EVENT_CLICK, localPosition: details.localPosition, globalPosition: details.globalPosition);
  }

  void onLongPressEnd(LongPressEndDetails details) {
    handleMouseEvent(EVENT_LONG_PRESS, localPosition: details.localPosition, globalPosition: details.globalPosition);
  }

  void handleGestureEvent(String type, {
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

  void onSwipe(SwipeDetails details) {
    handleGestureEvent(EVENT_SWIPE, velocityX: details.velocity.pixelsPerSecond.dx, velocityY: details.velocity.pixelsPerSecond.dy);
  }

  void onPanStart(DragStartDetails details) {
    handleGestureEvent(EVENT_PAN, state: EVENT_STATE_START, deltaX: details.globalPosition.dx, deltaY: details.globalPosition.dy);
  }

  void onPanUpdate(DragUpdateDetails details) {
    handleGestureEvent(EVENT_PAN, state: EVENT_STATE_UPDATE, deltaX: details.globalPosition.dx, deltaY: details.globalPosition.dy);
  }

  void onPanEnd(DragEndDetails details) {
    handleGestureEvent(EVENT_PAN, state: EVENT_STATE_END, velocityX: details.velocity.pixelsPerSecond.dx, velocityY: details.velocity.pixelsPerSecond.dy);
  }

  void onScaleStart(ScaleStartDetails details) {
    handleGestureEvent(EVENT_SCALE, state: EVENT_STATE_START);
  }

  void onScaleUpdate(ScaleUpdateDetails details) {
    handleGestureEvent(EVENT_SCALE, state: EVENT_STATE_UPDATE, rotation: details.rotation, scale: details.scale);
  }

  void onScaleEnd(ScaleEndDetails details) {
    handleGestureEvent(EVENT_SCALE, state: EVENT_STATE_END);
  }

  void handleTouchEvent(String eventType, Pointer targetPointer, List<Pointer> points) {
    TouchEvent e = TouchEvent(eventType);
    EventTarget currentTarget = targetPointer.target!;

    for (int i = 0; i < points.length; i++) {
      Pointer pointer = points[i];
      PointerEvent pointerEvent = pointer.event;
      EventTarget target = pointer.target!;

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
