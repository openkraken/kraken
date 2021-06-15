/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'package:kraken/rendering.dart';
import 'package:kraken/gesture.dart';
import 'package:kraken/dom.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/gestures.dart';

class GestureManager {

  static GestureManager? _instance;
  GestureManager._();

  factory GestureManager.instance() {
    if (_instance == null) {
      _instance = GestureManager._();

      _instance!.gestures[EVENT_CLICK] = ClickGestureRecognizer();
      (_instance!.gestures[EVENT_CLICK] as ClickGestureRecognizer).onClick = _instance!.onClick;

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

  void addTargetToList(RenderBox target) {
    _hitTestList.add(target);
  }

  void clearTargetList() {
    if (_hitTestList.isNotEmpty && _hitTestList[0] is RenderPointerListenerMixin) {
      // The target node triggered by the gesture is the bottom node of hitTest.
      _target = _hitTestList[0] as RenderPointerListenerMixin;
    }
    _hitTestList = [];
  }

  void addPointer(PointerEvent event) {
    // Collect the events in the hitTest.
    List<String> events = [];
    for (int i = 0; i < _hitTestList.length; i++) {
      RenderBox renderBox = _hitTestList[i];
      Map<String, List<EventHandler>> eventHandlers = {};
      if (renderBox is RenderBoxModel && renderBox.getEventHandlers != null) {
        eventHandlers = renderBox.getEventHandlers!();
      } else if (renderBox is RenderViewportBox && renderBox.getEventHandlers != null) {
        eventHandlers = renderBox.getEventHandlers!();
      }

      if (!eventHandlers.keys.isEmpty) {
        if (!events.contains(EVENT_CLICK) && eventHandlers.containsKey(EVENT_CLICK)) {
          events.add(EVENT_CLICK);
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

    gestures.forEach((key, gesture) {
      // Register the recognizer that needs to be monitored.
      if (events.contains(key)) {
        gesture.addPointer(event as PointerDownEvent);
      }
    });
  }

  void onClick(String eventType, { PointerDownEvent? down, PointerUpEvent? up }) {
    _target!.onClick!(eventType, up: up);
  }

  void onSwipe(Event event) {
    _target!.onSwipe!(event);
  }

  void onPanStart(DragStartDetails details) {
    _target!.onPan!(GestureEvent(EVENT_PAN, GestureEventInit( state: EVENT_STATE_START, deltaX: details.globalPosition.dx, deltaY: details.globalPosition.dy )));
  }

  void onPanUpdate(DragUpdateDetails details) {
    _target!.onPan!(GestureEvent(EVENT_PAN, GestureEventInit( state: EVENT_STATE_UPDATE, deltaX: details.globalPosition.dx, deltaY: details.globalPosition.dy )));
  }

  void onPanEnd(DragEndDetails details) {
    _target!.onPan!(GestureEvent(EVENT_PAN, GestureEventInit( state: EVENT_STATE_END, velocityX: details.velocity.pixelsPerSecond.dx, velocityY: details.velocity.pixelsPerSecond.dy )));
  }

  void onScaleStart(ScaleStartDetails details) {
    _target!.onScale!(GestureEvent(EVENT_SCALE, GestureEventInit( state: EVENT_STATE_START )));
  }

  void onScaleUpdate(ScaleUpdateDetails details) {
    _target!.onScale!(GestureEvent(EVENT_SCALE, GestureEventInit( state: EVENT_STATE_UPDATE, rotation: details.rotation, scale: details.scale )));
  }

  void onScaleEnd(ScaleEndDetails details) {
    _target!.onScale!(GestureEvent(EVENT_SCALE, GestureEventInit( state: EVENT_STATE_END )));
  }

  void onLongPressEnd(LongPressEndDetails details) {
    _target!.onLongPress!(GestureEvent(EVENT_LONG_PRESS, GestureEventInit(deltaX: details.globalPosition.dx, deltaY: details.globalPosition.dy )));
  }
}
