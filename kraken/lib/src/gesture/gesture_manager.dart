/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:kraken/dom.dart';
import 'package:kraken/gesture.dart';
import 'package:kraken/rendering.dart';


class GestureManager {

  static GestureManager? _instance;
  GestureManager._();

  factory GestureManager.instance() {
    if (_instance == null) {
      _instance = GestureManager._();

      _instance!._gestures[EVENT_CLICK] = TapGestureRecognizer();
      (_instance!._gestures[EVENT_CLICK] as TapGestureRecognizer).onTapDown = _instance!.onClick;

      _instance!._gestures[EVENT_DOUBLE_CLICK] = DoubleTapGestureRecognizer();
      (_instance!._gestures[EVENT_DOUBLE_CLICK] as DoubleTapGestureRecognizer).onDoubleTapDown = _instance!.onDoubleClick;

      _instance!._gestures[EVENT_SWIPE] = SwipeGestureRecognizer();
      (_instance!._gestures[EVENT_SWIPE] as SwipeGestureRecognizer).onSwipe = _instance!.onSwipe;

      _instance!._gestures[EVENT_PAN] = PanGestureRecognizer();
      (_instance!._gestures[EVENT_PAN] as PanGestureRecognizer).onStart = _instance!.onPanStart;
      (_instance!._gestures[EVENT_PAN] as PanGestureRecognizer).onUpdate = _instance!.onPanUpdate;
      (_instance!._gestures[EVENT_PAN] as PanGestureRecognizer).onEnd = _instance!.onPanEnd;

      _instance!._gestures[EVENT_LONG_PRESS] = LongPressGestureRecognizer();
      (_instance!._gestures[EVENT_LONG_PRESS] as LongPressGestureRecognizer).onLongPressEnd = _instance!.onLongPressEnd;

      _instance!._gestures[EVENT_SCALE] = ScaleGestureRecognizer();
      (_instance!._gestures[EVENT_SCALE] as ScaleGestureRecognizer).onStart = _instance!.onScaleStart;
      (_instance!._gestures[EVENT_SCALE] as ScaleGestureRecognizer).onUpdate = _instance!.onScaleUpdate;
      (_instance!._gestures[EVENT_SCALE] as ScaleGestureRecognizer).onEnd = _instance!.onScaleEnd;
    }
    return _instance!;
  }

  final Map<String, GestureRecognizer> _gestures = <String, GestureRecognizer>{};

  final List<RenderBox> _hitTestTargetList = [];
  // Collect the events in the hitTest list.
  final Map<String, bool> _hitTestEventMap = {};

  final Map<int, Point> _pointerToPoint = {};

  RenderPointerListenerMixin? _target;

  void addTargetToList(RenderBox target) {
    _hitTestTargetList.add(target);
  }

  void addPointer(PointerEvent event) {
    String touchType;

    if (event is PointerDownEvent) {
      // Reset the hitTest event map when start a new gesture.
      _hitTestEventMap.clear();

      _pointerToPoint[event.pointer] = Point(event);

      for (int i = 0; i < _hitTestTargetList.length; i++) {
        RenderBox renderBox = _hitTestTargetList[i];
        if (renderBox is RenderPointerListenerMixin) {
          // Mark event that should propagation in dom tree.
          renderBox.eventManager.events.forEach((eventType) {
            _hitTestEventMap[eventType] = true;
          });
        }
      }

      touchType = EVENT_TOUCH_START;

      // Add pointer to gestures then register the gesture recognizer to the arena.
      _gestures.forEach((key, gesture) {
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
            Point? point = _pointerToPoint[event.pointer];
            if (point != null) {
              point.target = renderBox as RenderPointerListenerMixin;
            }
            break;
          }
        }
      }
      _hitTestTargetList.clear();

      // Multi pointer operations in the web will organize click and other gesture triggers.
      bool isSinglePointer = _pointerToPoint.length == 1;
      Point? point = _pointerToPoint[event.pointer];
      if (isSinglePointer && point != null) {
        _target = point.target;
      } else {
        _target = null;
      }
    } else if (event is PointerMoveEvent) {
      touchType = EVENT_TOUCH_MOVE;
    } else if (event is PointerUpEvent) {
      touchType = EVENT_TOUCH_END;
    } else {
      touchType = EVENT_TOUCH_CANCEL;
    }

    Point? point = _pointerToPoint[event.pointer];
    if (point != null) {
      point.event = event;
    }

    // If the target node is not attached, the event will be ignored.
    if (_pointerToPoint[event.pointer] == null) return;

    // Only dispatch event that added.
    bool needDispatch = _hitTestEventMap.containsKey(touchType);
    if (needDispatch) {
      Function? handleTouchEvent = _target?.handleTouchEvent;
      if (handleTouchEvent != null) {
        handleTouchEvent(touchType, _pointerToPoint[event.pointer], _pointerToPoint.values.toList());
      }
    }

    // End of the gesture.
    if (event is PointerUpEvent || event is PointerCancelEvent) {
      _pointerToPoint.remove(event.pointer);
    }

  }

  void onDoubleClick(TapDownDetails details) {
    Function? handleMouseEvent = _target?.handleMouseEvent;
    if (handleMouseEvent != null) {
      handleMouseEvent(EVENT_DOUBLE_CLICK, localPosition: details.localPosition, globalPosition: details.globalPosition);
    }
  }

  void onClick(TapDownDetails details) {
    Function? handleMouseEvent = _target?.handleMouseEvent;
    if (handleMouseEvent != null) {
      handleMouseEvent(EVENT_CLICK, localPosition: details.localPosition, globalPosition: details.globalPosition);
    }
  }

  void onLongPressEnd(LongPressEndDetails details) {
    Function? handleMouseEvent = _target?.handleMouseEvent;
    if (handleMouseEvent != null) {
      handleMouseEvent(EVENT_LONG_PRESS, localPosition: details.localPosition, globalPosition: details.globalPosition);
    }
  }

  void onSwipe(SwipeDetails details) {
    Function? handleGestureEvent = _target?.handleGestureEvent;
    if (handleGestureEvent != null) {
      handleGestureEvent(EVENT_SWIPE, velocityX: details.velocity.pixelsPerSecond.dx, velocityY: details.velocity.pixelsPerSecond.dy);
    }
  }

  void onPanStart(DragStartDetails details) {
    Function? handleGestureEvent = _target?.handleGestureEvent;
    if (handleGestureEvent != null) {
      handleGestureEvent(EVENT_PAN, state: EVENT_STATE_START, deltaX: details.globalPosition.dx, deltaY: details.globalPosition.dy);
    }
  }

  void onPanUpdate(DragUpdateDetails details) {
    Function? handleGestureEvent = _target?.handleGestureEvent;
    if (handleGestureEvent != null) {
      handleGestureEvent(EVENT_PAN, state: EVENT_STATE_UPDATE, deltaX: details.globalPosition.dx, deltaY: details.globalPosition.dy);
    }
  }

  void onPanEnd(DragEndDetails details) {
    Function? handleGestureEvent = _target?.handleGestureEvent;
    if (handleGestureEvent != null) {
      handleGestureEvent(EVENT_PAN, state: EVENT_STATE_END, velocityX: details.velocity.pixelsPerSecond.dx, velocityY: details.velocity.pixelsPerSecond.dy);
    }
  }

  void onScaleStart(ScaleStartDetails details) {
    Function? handleGestureEvent = _target?.handleGestureEvent;
    if (handleGestureEvent != null) {
      handleGestureEvent(EVENT_SCALE, state: EVENT_STATE_START);
    }
  }

  void onScaleUpdate(ScaleUpdateDetails details) {
    Function? handleGestureEvent = _target?.handleGestureEvent;
    if (handleGestureEvent != null) {
      handleGestureEvent(EVENT_SCALE, state: EVENT_STATE_UPDATE, rotation: details.rotation, scale: details.scale);
    }
  }

  void onScaleEnd(ScaleEndDetails details) {
    Function? handleGestureEvent = _target?.handleGestureEvent;
    if (handleGestureEvent != null) {
      handleGestureEvent(GestureEvent, state: EVENT_STATE_END);
    }
  }
}
