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

  static GestureManager _instance;

  GestureManager._internal();

  factory GestureManager.getInstance() => _getInstance();

  final Map<Type, GestureRecognizer> gestures = <Type, GestureRecognizer>{};

  List<RenderBoxModel> renderBoxModelList = [];

  void clearList() {
    renderBoxModelList = [];
  }

  void addPointer(PointerEvent event) {
    gestures.forEach((key, gesture) {
      gesture.addPointer(event);
    });
  }

  void onClick(String eventType, { PointerDownEvent down, PointerUpEvent up }) {
    if (renderBoxModelList.length != 0) {
      renderBoxModelList[0].onClick(eventType, up: up);
    }
    renderBoxModelList = [];
  }

  void onSwipe(Event event) {
    if (renderBoxModelList.length != 0) {
      renderBoxModelList[0].onSwipe(event);
    }
    renderBoxModelList = [];
  }

  void onPanStart(DragStartDetails details) {
    if (renderBoxModelList.length != 0) {
      renderBoxModelList[0].onPan(GestureEvent(EVENT_PAN, GestureEventInit( state: EVENT_STATE_START, deltaX: details.globalPosition.dx, deltaY: details.globalPosition.dy )));
    }
    renderBoxModelList = [];
  }

  void onPanUpdate(DragUpdateDetails details) {
    if (renderBoxModelList.length != 0) {
      renderBoxModelList[0].onPan(GestureEvent(EVENT_PAN, GestureEventInit( state: EVENT_STATE_UPDATE, deltaX: details.globalPosition.dx, deltaY: details.globalPosition.dy )));
    }
    renderBoxModelList = [];
  }

  void onPanEnd(DragEndDetails details) {
    if (renderBoxModelList.length != 0) {
      renderBoxModelList[0].onPan(GestureEvent(EVENT_PAN, GestureEventInit( state: EVENT_STATE_END, velocityX: details.velocity.pixelsPerSecond.dx, velocityY: details.velocity.pixelsPerSecond.dy )));
    }
    renderBoxModelList = [];
  }

  void onScaleStart(ScaleStartDetails details) {
    if (renderBoxModelList.length != 0) {
      renderBoxModelList[0].onScale(GestureEvent(EVENT_SCALE, GestureEventInit( state: EVENT_STATE_START )));
    }
    renderBoxModelList = [];
  }

  void onScaleUpdate(ScaleUpdateDetails details) {
    if (renderBoxModelList.length != 0) {
      renderBoxModelList[0].onScale(GestureEvent(EVENT_SCALE, GestureEventInit( state: EVENT_STATE_UPDATE, rotation: details.rotation, scale: details.scale )));
    }
    renderBoxModelList = [];
  }

  void onScaleEnd(ScaleEndDetails details) {
    if (renderBoxModelList.length != 0) {
      renderBoxModelList[0].onScale(GestureEvent(EVENT_SCALE, GestureEventInit( state: EVENT_STATE_END )));
    }
    renderBoxModelList = [];
  }

  void onLongPressEnd(LongPressEndDetails details) {
    if (renderBoxModelList.length != 0) {
      renderBoxModelList[0].onLongPress(GestureEvent(EVENT_LONG_PRESS, GestureEventInit(deltaX: details.globalPosition.dx, deltaY: details.globalPosition.dy )));
    }
    renderBoxModelList = [];
  }

  static _getInstance() {
    if (_instance == null) {
      _instance = GestureManager._internal();

      _instance.gestures[ClickGestureRecognizer] = ClickGestureRecognizer();
      (_instance.gestures[ClickGestureRecognizer] as ClickGestureRecognizer).onClick = _instance.onClick;

      _instance.gestures[SwipeGestureRecognizer] = SwipeGestureRecognizer();
      (_instance.gestures[SwipeGestureRecognizer] as SwipeGestureRecognizer).onSwipe = _instance.onSwipe;

      _instance.gestures[PanGestureRecognizer] = PanGestureRecognizer();
      (_instance.gestures[PanGestureRecognizer] as PanGestureRecognizer).onStart = _instance.onPanStart;
      (_instance.gestures[PanGestureRecognizer] as PanGestureRecognizer).onUpdate = _instance.onPanUpdate;
      (_instance.gestures[PanGestureRecognizer] as PanGestureRecognizer).onEnd = _instance.onPanEnd;

      _instance.gestures[LongPressGestureRecognizer] = LongPressGestureRecognizer();
      (_instance.gestures[LongPressGestureRecognizer] as LongPressGestureRecognizer).onLongPressEnd = _instance.onLongPressEnd;

      _instance.gestures[ScaleGestureRecognizer] = ScaleGestureRecognizer();
      (_instance.gestures[ScaleGestureRecognizer] as ScaleGestureRecognizer).onStart = _instance.onScaleStart;
      (_instance.gestures[ScaleGestureRecognizer] as ScaleGestureRecognizer).onUpdate = _instance.onScaleUpdate;
      (_instance.gestures[ScaleGestureRecognizer] as ScaleGestureRecognizer).onEnd = _instance.onScaleEnd;
    }
    return _instance;
  }
}
