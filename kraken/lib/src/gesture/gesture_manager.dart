/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'package:kraken/rendering.dart';
import 'package:kraken/gesture.dart';
import 'package:kraken/dom.dart';
import 'package:kraken/scheduler.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/gestures.dart';

class GestureManager {

  static GestureManager? _instance;
  GestureManager._();

  static const int MAX_STEP_MS = 16;
  final Throttling _throttler = Throttling(duration: Duration(milliseconds: MAX_STEP_MS));

  factory GestureManager.instance() {
    if (_instance == null) {
      _instance = GestureManager._();

      _instance!.gestures[EVENT_CLICK] = TapGestureRecognizer();
      (_instance!.gestures[EVENT_CLICK] as TapGestureRecognizer).onTapUp = _instance!.onTapUp;

      _instance!.gestures[EVENT_DOUBLE_CLICK] = DoubleTapGestureRecognizer();
      (_instance!.gestures[EVENT_DOUBLE_CLICK] as DoubleTapGestureRecognizer).onDoubleTap = _instance!.onDoubleClick;

      _instance!.gestures[EVENT_SWIPE] = SwipeGestureRecognizer();
      (_instance!.gestures[EVENT_SWIPE] as SwipeGestureRecognizer).onSwipe = _instance!.onSwipe;

      _instance!.gestures[EVENT_PAN] = PanGestureRecognizer();
      (_instance!.gestures[EVENT_PAN] as PanGestureRecognizer).onStart = _instance!.onPanStart;
      (_instance!.gestures[EVENT_PAN] as PanGestureRecognizer).onUpdate = _instance!.onPanUpdate;
      (_instance!.gestures[EVENT_PAN] as PanGestureRecognizer).onEnd = _instance!.onPanEnd;

      _instance!.gestures[EVENT_LONG_PRESS] = LongPressGestureRecognizer();
      (_instance!.gestures[EVENT_LONG_PRESS] as LongPressGestureRecognizer).onLongPressEnd = _instance!.onLongPressEnd;

      _instance!.gestures[EVENT_SCALE] = ScaleGestureRecognizer();
      (_instance!.gestures[EVENT_SCALE] as ScaleGestureRecognizer).onStart = _instance!.onScaleStart;
      (_instance!.gestures[EVENT_SCALE] as ScaleGestureRecognizer).onUpdate = _instance!.onScaleUpdate;
      (_instance!.gestures[EVENT_SCALE] as ScaleGestureRecognizer).onEnd = _instance!.onScaleEnd;
    }
    return _instance!;
  }

  final Map<String, GestureRecognizer> gestures = <String, GestureRecognizer>{};

  List<RenderBox> _hitTestList = [];

  RenderPointerListenerMixin? _target;

  final Map<int, PointerEvent> _pointerToEvent = {};

  final Map<int, RenderPointerListenerMixin> _pointerToTarget = {};

  final List<int> _points = [];

  void addTargetToList(RenderBox target) {
    _hitTestList.add(target);
  }

  void clearTargetList() {
    _hitTestList = [];
  }

  void addPointer(PointerEvent event) {
    // Collect the events in the hitTest.
    List<String> events = [];
    for (int i = 0; i < _hitTestList.length; i++) {
      RenderBox renderBox = _hitTestList[i];
      Map<String, List<EventHandler>> eventHandlers = {};
      if (renderBox is RenderPointerListenerMixin && renderBox.getEventHandlers != null) {
        eventHandlers = renderBox.getEventHandlers!();
      }

      if (eventHandlers.keys.isNotEmpty) {
        if (!events.contains(EVENT_CLICK) && eventHandlers.containsKey(EVENT_CLICK)) {
          events.add(EVENT_CLICK);
        }
        if (!events.contains(EVENT_DOUBLE_CLICK) && eventHandlers.containsKey(EVENT_DOUBLE_CLICK)) {
          events.add(EVENT_DOUBLE_CLICK);
        }
        if (!events.contains(EVENT_SWIPE) && eventHandlers.containsKey(EVENT_SWIPE)) {
          events.add(EVENT_SWIPE);
        }
        if (!events.contains(EVENT_PAN) && eventHandlers.containsKey(EVENT_PAN)) {
          events.add(EVENT_PAN);
        }
        if (!events.contains(EVENT_LONG_PRESS) && eventHandlers.containsKey(EVENT_LONG_PRESS)) {
          events.add(EVENT_LONG_PRESS);
        }
        if (!events.contains(EVENT_SCALE) && eventHandlers.containsKey(EVENT_SCALE)) {
          events.add(EVENT_SCALE);
        }
      }
    }

    String touchType = EVENT_TOUCH_CANCEL;

    if (event is PointerDownEvent) {
      touchType = EVENT_TOUCH_START;
      _pointerToEvent[event.pointer] = event;
      _points.add(event.pointer);

      // Add pointer to gestures then register the gesture recognizer to the arena.
      gestures.forEach((key, gesture) {
        // Register the recognizer that needs to be monitored.
        if (events.contains(key)) {
          gesture.addPointer(event as PointerDownEvent);
        }
      });

      // The target node triggered by the gesture is the bottom node of hitTest.
      // The scroll element needs to be judged by isScrollingContentBox to find the real element upwards.
      if (_hitTestList.isNotEmpty) {
        for (int i = 0; i < _hitTestList.length; i++) {
          RenderBox renderBox = _hitTestList[i];
          if ((renderBox is RenderBoxModel && !renderBox.isScrollingContentBox) || renderBox is RenderViewportBox) {
            _pointerToTarget[event.pointer] = renderBox as RenderPointerListenerMixin;
            break;
          }
        }
      }

      clearTargetList();
    } else if (event is PointerMoveEvent) {
      touchType = EVENT_TOUCH_MOVE;
      _pointerToEvent[event.pointer] = event;
    } else if (event is PointerUpEvent) {
      touchType = EVENT_TOUCH_END;
    } else if (event is PointerCancelEvent) {
      touchType = EVENT_TOUCH_CANCEL;
    }

    if (_pointerToTarget[event.pointer] != null) {
      RenderPointerListenerMixin currentTarget = _pointerToTarget[event.pointer] as RenderPointerListenerMixin;

      TouchEvent e = TouchEvent(touchType);
      var pointerEventOriginal = event.original;
      // Use original event, prevent to be relative coordinate
      if (pointerEventOriginal != null) event = pointerEventOriginal;

      for (int i = 0; i < _points.length; i++) {
        int pointer = _points[i];
        PointerEvent point = _pointerToEvent[pointer] as PointerEvent;
        RenderPointerListenerMixin target = _pointerToTarget[pointer] as RenderPointerListenerMixin;

        EventTarget node = target.getEventTarget!();

        Touch touch = Touch(
          identifier: point.pointer,
          target: node,
          screenX: point.position.dx,
          screenY: point.position.dy,
          clientX: point.localPosition.dx,
          clientY: point.localPosition.dy,
          pageX: point.localPosition.dx,
          pageY: point.localPosition.dy,
          radiusX: point.radiusMajor,
          radiusY: point.radiusMinor,
          rotationAngle: point.orientation,
          force: point.pressure,
        );

        if (pointer == event.pointer) {
          e.changedTouches.append(touch);
        }

        if (currentTarget == target) {
          e.targetTouches.append(touch);
        }

        e.touches.append(touch);
      }

      if (currentTarget.dispatchEvent != null) {
        if (touchType == EVENT_TOUCH_MOVE) {
          _throttler.throttle(() {
            currentTarget.dispatchEvent!(e);
          });
        } else {
          currentTarget.dispatchEvent!(e);
        }
      }

      if (event is PointerUpEvent || event is PointerCancelEvent) {
        // Multi pointer operations in the web will organize click and other gesture triggers.
        if (_pointerToTarget.length == 1 && _pointerToTarget[event.pointer] != null) {
          _target = _pointerToTarget[event.pointer];
        } else {
          _target = null;
        }

        _points.remove(event.pointer);
        _pointerToEvent.remove(event.pointer);
        _pointerToTarget.remove(event.pointer);
      }
    }
  }

  void onDoubleClick() {
    if (_target != null && _target!.onClick != null) {
      if (_target!.onDoubleClick != null) {
        _target!.onDoubleClick!(Event(EVENT_DOUBLE_CLICK));
      }
    }
  }

  void onTapUp(TapUpDetails details) {
    if (_target != null && _target!.onClick != null) {
      if (_target!.onClick != null) {
        _target!.onClick!(EVENT_CLICK, details);
      }
    }
  }

  void onSwipe(Event event) {
    if (_target != null && _target!.onSwipe != null) {
      if (_target!.onSwipe != null) {
        _target!.onSwipe!(event);
      }
    }
  }

  void onPanStart(DragStartDetails details) {
    if (_target != null && _target!.onPan != null) {
      _target!.onPan!(
        GestureEvent(
          EVENT_PAN,
          GestureEventInit(
            state: EVENT_STATE_START,
            deltaX: details.globalPosition.dx,
            deltaY: details.globalPosition.dy
          )
        )
      );
    }
  }

  void onPanUpdate(DragUpdateDetails details) {
    if (_target != null && _target!.onPan != null) {
      _target!.onPan!(
          GestureEvent(
              EVENT_PAN,
              GestureEventInit(
                  state: EVENT_STATE_UPDATE,
                  deltaX: details.globalPosition.dx,
                  deltaY: details.globalPosition.dy
              )
          )
      );
    }
  }

  void onPanEnd(DragEndDetails details) {
    if (_target != null && _target!.onPan != null) {
      _target!.onPan!(
        GestureEvent(
          EVENT_PAN,
          GestureEventInit(
            state: EVENT_STATE_END,
            velocityX: details.velocity.pixelsPerSecond.dx,
            velocityY: details.velocity.pixelsPerSecond.dy
          )
        )
      );
    }
  }

  void onScaleStart(ScaleStartDetails details) {
    if (_target != null && _target!.onScale != null) {
      _target!.onScale!(
        GestureEvent(
          EVENT_SCALE,
          GestureEventInit( state: EVENT_STATE_START )
        )
      );
    }
  }

  void onScaleUpdate(ScaleUpdateDetails details) {
    if (_target != null && _target!.onScale != null) {
      _target!.onScale!(
        GestureEvent(
          EVENT_SCALE,
          GestureEventInit(
            state: EVENT_STATE_UPDATE,
            rotation: details.rotation,
            scale: details.scale
          )
        )
      );
    }
  }

  void onScaleEnd(ScaleEndDetails details) {
    if (_target != null && _target!.onScale != null) {
      _target!.onScale!(
        GestureEvent(
          EVENT_SCALE,
          GestureEventInit( state: EVENT_STATE_END )
        )
      );
    }
  }

  void onLongPressEnd(LongPressEndDetails details) {
    if (_target != null && _target!.onLongPress != null) {
      _target!.onLongPress!(
        GestureEvent(
          EVENT_LONG_PRESS,
          GestureEventInit(
            deltaX: details.globalPosition.dx,
            deltaY: details.globalPosition.dy
          )
        )
      );
    }
  }
}
