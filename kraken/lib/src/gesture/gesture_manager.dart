/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:kraken/dom.dart';
import 'package:kraken/gesture.dart';
import 'package:kraken/rendering.dart';
import 'package:kraken/scheduler.dart';

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

  final List<RenderBox> _hitTestTargetList = [];
  // Collect the events in the hitTest list.
  final Map<String, bool> _hitTestEventMap = {};

  final Map<int, PointerEvent> _pointerToEvent = {};

  final Map<int, RenderPointerListenerMixin> _pointerToTarget = {};

  final List<int> _pointers = [];

  RenderPointerListenerMixin? _target;

  void addTargetToList(RenderBox target) {
    _hitTestTargetList.add(target);
  }

  void addPointer(PointerEvent event) {
    String touchType;
    if (event is PointerDownEvent) {
      // Reset the hitTest event map when start a new gesture.
      _hitTestEventMap.clear();

      for (int i = 0; i < _hitTestTargetList.length; i++) {
        RenderBox renderBox = _hitTestTargetList[i];
        Map<String, List<EventHandler>>? eventHandlers;
        if (renderBox is RenderPointerListenerMixin && renderBox.getEventHandlers != null) {
          eventHandlers = renderBox.getEventHandlers!();
        }

        // Mark event that should propagation in dom tree.
        if (eventHandlers != null && eventHandlers.isNotEmpty) {
          for (String eventType in eventHandlers.keys) {
            _hitTestEventMap[eventType] = true;
          }
        }
      }

      touchType = EVENT_TOUCH_START;
      _pointerToEvent[event.pointer] = event;
      _pointers.add(event.pointer);

      // Add pointer to gestures then register the gesture recognizer to the arena.
      gestures.forEach((key, gesture) {
        // Register the recognizer that needs to be monitored.
        if (_hitTestEventMap.containsKey(key)) {
          gesture.addPointer(event);
        }
      });

      // The target node triggered by the gesture is the bottom node of hitTest.
      // The scroll element needs to be judged by isScrollingContentBox to find the real element upwards.
      if (_hitTestTargetList.isNotEmpty) {
        for (int i = 0; i < _hitTestTargetList.length; i++) {
          RenderBox renderBox = _hitTestTargetList[i];
          if ((renderBox is RenderBoxModel && !renderBox.isScrollingContentBox) || renderBox is RenderViewportBox) {
            _pointerToTarget[event.pointer] = renderBox as RenderPointerListenerMixin;
            break;
          }
        }
      }
      _hitTestTargetList.clear();
    } else if (event is PointerMoveEvent) {
      touchType = EVENT_TOUCH_MOVE;
      _pointerToEvent[event.pointer] = event;
    } else if (event is PointerUpEvent) {
      touchType = EVENT_TOUCH_END;
    } else {
      touchType = EVENT_TOUCH_CANCEL;
    }

    // If the target node is not attached, the event will be ignored.
    if (_pointerToTarget[event.pointer] == null) return;

    // Only dispatch event that added.
    bool needDispatch = _hitTestEventMap.containsKey(touchType);
    if (needDispatch) {
      TouchEvent e = TouchEvent(touchType);
      RenderPointerListenerMixin currentTarget = _pointerToTarget[event.pointer] as RenderPointerListenerMixin;

      for (int i = 0; i < _pointers.length; i++) {
        int pointer = _pointers[i];
        PointerEvent pointerEvent = _pointerToEvent[pointer] as PointerEvent;
        RenderPointerListenerMixin target = _pointerToTarget[pointer] as RenderPointerListenerMixin;

        Touch touch = Touch(
          identifier: pointerEvent.pointer,
          target: target.getEventTarget!(),
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

        if (pointer == event.pointer) {
          e.changedTouches.append(touch);
        }

        if (currentTarget == target) {
          e.targetTouches.append(touch);
        }

        e.touches.append(touch);
      }

      if (touchType == EVENT_TOUCH_MOVE) {
        _throttler.throttle(() {
          currentTarget.dispatchEvent!(e);
        });
      } else {
        currentTarget.dispatchEvent!(e);
      }
    }

    // End of the gesture.
    if (event is PointerUpEvent || event is PointerCancelEvent) {
      // Multi pointer operations in the web will organize click and other gesture triggers.
      bool isSinglePointer = _pointerToTarget.length == 1;
      if (isSinglePointer) {
        _target = _pointerToTarget[event.pointer];
      } else {
        _target = null;
      }

      _pointers.remove(event.pointer);
      _pointerToEvent.remove(event.pointer);
      _pointerToTarget.remove(event.pointer);
    }

  }

  void onDoubleClick() {
    if (_target != null && _target?.onDoubleClick != null) {
      _target?.onDoubleClick!(Event(EVENT_DOUBLE_CLICK));
    }
  }

  void onTapUp(TapUpDetails details) {
    if (_target != null && _target?.onClick != null) {
      _target?.onClick!(EVENT_CLICK, details);
    }
  }

  void onSwipe(Event event) {
    if (_target != null && _target?.onSwipe != null) {
      _target?.onSwipe!(event);
    }
  }

  void onPanStart(DragStartDetails details) {
    if (_target != null && _target?.onPan != null) {
      _target?.onPan!(
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
    if (_target != null && _target?.onPan != null) {
      _target?.onPan!(
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
    if (_target != null && _target?.onPan != null) {
      _target?.onPan!(
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
    if (_target != null && _target?.onScale != null) {
      _target?.onScale!(
        GestureEvent(
          EVENT_SCALE,
          GestureEventInit( state: EVENT_STATE_START )
        )
      );
    }
  }

  void onScaleUpdate(ScaleUpdateDetails details) {
    if (_target != null && _target?.onScale != null) {
      _target?.onScale!(
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
    if (_target != null && _target?.onScale != null) {
      _target?.onScale!(
        GestureEvent(
          EVENT_SCALE,
          GestureEventInit( state: EVENT_STATE_END )
        )
      );
    }
  }

  void onLongPressEnd(LongPressEndDetails details) {
    if (_target != null && _target?.onLongPress != null) {
      _target?.onLongPress!(
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
