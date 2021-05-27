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
      GestureManager instance = _instance = GestureManager._();

      instance.gestures[ClickGestureRecognizer] = ClickGestureRecognizer();
      (instance.gestures[ClickGestureRecognizer] as ClickGestureRecognizer).onClick = instance.onClick;

      instance.gestures[SwipeGestureRecognizer] = SwipeGestureRecognizer();
      (instance.gestures[SwipeGestureRecognizer] as SwipeGestureRecognizer).onSwipe = instance.onSwipe;

      instance.gestures[PanGestureRecognizer] = PanGestureRecognizer();
      (instance.gestures[PanGestureRecognizer] as PanGestureRecognizer).onStart = instance.onPanStart;
      (instance.gestures[PanGestureRecognizer] as PanGestureRecognizer).onUpdate = instance.onPanUpdate;
      (instance.gestures[PanGestureRecognizer] as PanGestureRecognizer).onEnd = instance.onPanEnd;

      instance.gestures[LongPressGestureRecognizer] = LongPressGestureRecognizer();
      (instance.gestures[LongPressGestureRecognizer] as LongPressGestureRecognizer).onLongPressEnd = instance.onLongPressEnd;

      instance.gestures[ScaleGestureRecognizer] = ScaleGestureRecognizer();
      (instance.gestures[ScaleGestureRecognizer] as ScaleGestureRecognizer).onStart = instance.onScaleStart;
      (instance.gestures[ScaleGestureRecognizer] as ScaleGestureRecognizer).onUpdate = instance.onScaleUpdate;
      (instance.gestures[ScaleGestureRecognizer] as ScaleGestureRecognizer).onEnd = instance.onScaleEnd;
    }
    return _instance!;
  }

  final Map<Type, GestureRecognizer> gestures = <Type, GestureRecognizer>{};

  List<RenderBoxModel> _renderBoxModelList = [];

  RenderBoxModel? _target;

  void addTargetToList(RenderBoxModel renderBoxModel) {
    _renderBoxModelList.add(renderBoxModel);
  }

  void clearTargetList() {
    if (_renderBoxModelList.length != 0) {
      // The target node triggered by the gesture is the bottom node of hittest.
      _target = _renderBoxModelList[0];
    }
    _renderBoxModelList = [];
  }

  void addPointer(PointerEvent event) {
    gestures.forEach((key, gesture) {
      gesture.addPointer(event as PointerDownEvent);
    });
  }

  void onClick(String eventType, { PointerDownEvent? down, PointerUpEvent? up }) {
    RenderBoxModel? target = _target;
    if (target != null && target.onClick != null) {
      target.onClick!(eventType, up: up);
    }
  }

  void onSwipe(Event event) {
    RenderBoxModel? target = _target;
    if (target != null && target.onSwipe != null) {
      target.onSwipe!(event);
    }
  }

  void onPanStart(DragStartDetails details) {
    RenderBoxModel? target = _target;
    if (target != null && target.onPan != null) {
      target.onPan!(GestureEvent(EVENT_PAN, GestureEventInit( state: EVENT_STATE_START, deltaX: details.globalPosition.dx, deltaY: details.globalPosition.dy )));
    }
  }

  void onPanUpdate(DragUpdateDetails details) {
    RenderBoxModel? target = _target;
    if (target != null && target.onPan != null) {
      target.onPan!(GestureEvent(EVENT_PAN, GestureEventInit( state: EVENT_STATE_UPDATE, deltaX: details.globalPosition.dx, deltaY: details.globalPosition.dy )));
    }
  }

  void onPanEnd(DragEndDetails details) {
    RenderBoxModel? target = _target;
    if (target != null && target.onPan != null) {
      target.onPan!(GestureEvent(EVENT_PAN, GestureEventInit( state: EVENT_STATE_END, velocityX: details.velocity.pixelsPerSecond.dx, velocityY: details.velocity.pixelsPerSecond.dy )));
    }
  }

  void onScaleStart(ScaleStartDetails details) {
    RenderBoxModel? target = _target;
    if (target != null && target.onScale != null) {
      target.onScale!(GestureEvent(EVENT_SCALE, GestureEventInit( state: EVENT_STATE_START )));
    }
  }

  void onScaleUpdate(ScaleUpdateDetails details) {
    RenderBoxModel? target = _target;
    if (target != null && target.onScale != null) {
        target.onScale!(GestureEvent(EVENT_SCALE, GestureEventInit( state: EVENT_STATE_UPDATE, rotation: details.rotation, scale: details.scale )));
    }
  }

  void onScaleEnd(ScaleEndDetails details) {
    RenderBoxModel? target = _target;
    if (target != null && target.onScale != null) {
      target.onScale!(GestureEvent(EVENT_SCALE, GestureEventInit( state: EVENT_STATE_END )));
    }
  }

  void onLongPressEnd(LongPressEndDetails details) {
    RenderBoxModel? target = _target;
    if (target != null && target.onLongPress != null) {
      target.onLongPress!(GestureEvent(EVENT_LONG_PRESS, GestureEventInit(deltaX: details.globalPosition.dx, deltaY: details.globalPosition.dy )));
    }
  }
}
