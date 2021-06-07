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

      _instance!.gestures[ClickGestureRecognizer] = ClickGestureRecognizer();
      (_instance!.gestures[ClickGestureRecognizer] as ClickGestureRecognizer).onClick = _instance!.onClick;

      _instance!.gestures[SwipeGestureRecognizer] = SwipeGestureRecognizer();
      (_instance!.gestures[SwipeGestureRecognizer] as SwipeGestureRecognizer).onSwipe = _instance!.onSwipe;

      _instance!.gestures[PanGestureRecognizer] = PanGestureRecognizer();
      (_instance!.gestures[PanGestureRecognizer] as PanGestureRecognizer).onStart = _instance!.onPanStart;
      (_instance!.gestures[PanGestureRecognizer] as PanGestureRecognizer).onUpdate = _instance!.onPanUpdate;
      (_instance!.gestures[PanGestureRecognizer] as PanGestureRecognizer).onEnd = _instance!.onPanEnd;

      _instance!.gestures[LongPressGestureRecognizer] = LongPressGestureRecognizer();
      (_instance!.gestures[LongPressGestureRecognizer] as LongPressGestureRecognizer).onLongPressEnd = _instance!.onLongPressEnd;

      _instance!.gestures[ScaleGestureRecognizer] = ScaleGestureRecognizer();
      (_instance!.gestures[ScaleGestureRecognizer] as ScaleGestureRecognizer).onStart = _instance!.onScaleStart;
      (_instance!.gestures[ScaleGestureRecognizer] as ScaleGestureRecognizer).onUpdate = _instance!.onScaleUpdate;
      (_instance!.gestures[ScaleGestureRecognizer] as ScaleGestureRecognizer).onEnd = _instance!.onScaleEnd;
    }
    return _instance!;
  }

  final Map<Type, GestureRecognizer> gestures = <Type, GestureRecognizer>{};

  List<RenderBoxModel> _renderBoxModelList = [];

  List _eventTypesList = [];

  RenderBoxModel? _target;

  void addTargetToList(RenderBoxModel renderBoxModel) {
    _renderBoxModelList.add(renderBoxModel);
  }

  void addEventTypes(List<String> list) {
    for (int i = 0; i < list.length; i++) {
      String eventType = list[i];
      if (!_eventTypesList.contains(eventType)) {
        _eventTypesList.add(eventType);
      }
    }
  }

  void clearTargetList() {
    if (_renderBoxModelList.length != 0) {
      // The target node triggered by the gesture is the bottom node of hittest.
      _target = _renderBoxModelList[0];
    }
    _renderBoxModelList = [];
  }

  void addPointer(PointerEvent event) {print('_eventTypesList=${_eventTypesList}');
    gestures.forEach((key, gesture) {
      gesture.addPointer(event as PointerDownEvent);
    });
  }

  void onClick(String eventType, { PointerDownEvent? down, PointerUpEvent? up }) {
    if (_target != null && _target!.onClick != null) {
      _target!.onClick!(eventType, up: up);
    }
  }

  void onSwipe(Event event) {
    if (_target != null && _target!.onSwipe != null) {
      _target!.onSwipe!(event);
    }
  }

  void onPanStart(DragStartDetails details) {
    if (_target != null && _target!.onPan != null) {
      _target!.onPan!(GestureEvent(EVENT_PAN, GestureEventInit( state: EVENT_STATE_START, deltaX: details.globalPosition.dx, deltaY: details.globalPosition.dy )));
    }
  }

  void onPanUpdate(DragUpdateDetails details) {
    if (_target != null && _target!.onPan != null) {
      _target!.onPan!(GestureEvent(EVENT_PAN, GestureEventInit( state: EVENT_STATE_UPDATE, deltaX: details.globalPosition.dx, deltaY: details.globalPosition.dy )));
    }
  }

  void onPanEnd(DragEndDetails details) {
    if (_target != null && _target!.onPan != null) {
      _target!.onPan!(GestureEvent(EVENT_PAN, GestureEventInit( state: EVENT_STATE_END, velocityX: details.velocity.pixelsPerSecond.dx, velocityY: details.velocity.pixelsPerSecond.dy )));
    }
  }

  void onScaleStart(ScaleStartDetails details) {
    if (_target != null && _target!.onScale != null) {
      _target!.onScale!(GestureEvent(EVENT_SCALE, GestureEventInit( state: EVENT_STATE_START )));
    }
  }

  void onScaleUpdate(ScaleUpdateDetails details) {
      if (_target != null && _target!.onScale != null) {
        _target!.onScale!(GestureEvent(EVENT_SCALE, GestureEventInit( state: EVENT_STATE_UPDATE, rotation: details.rotation, scale: details.scale )));
    }
  }

  void onScaleEnd(ScaleEndDetails details) {
      if (_target != null && _target!.onScale != null) {
        _target!.onScale!(GestureEvent(EVENT_SCALE, GestureEventInit( state: EVENT_STATE_END )));
    }
  }

  void onLongPressEnd(LongPressEndDetails details) {
      if (_target != null && _target!.onLongPress != null) {
        _target!.onLongPress!(GestureEvent(EVENT_LONG_PRESS, GestureEventInit(deltaX: details.globalPosition.dx, deltaY: details.globalPosition.dy )));
    }
  }
}
