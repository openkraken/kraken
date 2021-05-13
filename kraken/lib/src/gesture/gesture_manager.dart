/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'package:kraken/rendering.dart';
import 'package:flutter/gestures.dart';
import 'package:kraken/gesture.dart';

class GestureManager {

  static GestureManager _instance;

  GestureManager._internal();

  factory GestureManager.getInstance() => _getInstance();

  final Map<Type, GestureRecognizer> gestures = <Type, GestureRecognizer>{};

  List<RenderBoxModel> renderBoxModelList = [];

  void clearList() {
    renderBoxModelList = [];
  }

  void triggerGesture() {

  }

  void addPointer(PointerEvent event) {
    gestures.forEach((key, gesture) {
      gesture.addPointer(event);
    });
  }

  void onClick(String eventType, { PointerDownEvent down, PointerUpEvent up }) {
    if (renderBoxModelList.length != 0) {
      (renderBoxModelList[0] as RenderBoxModel).onClick(eventType, up: up);
    }
    renderBoxModelList = [];
  }

  static _getInstance() {
    if (_instance == null) {
      _instance = GestureManager._internal();

      _instance.gestures[ClickGestureRecognizer] = ClickGestureRecognizer();
      (_instance.gestures[ClickGestureRecognizer] as ClickGestureRecognizer).onClick = _instance.onClick;
    }
    return _instance;
  }
}
