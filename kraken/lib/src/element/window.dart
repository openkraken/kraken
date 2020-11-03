/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:ui';
import 'dart:convert';
import 'package:kraken/bridge.dart';
import 'package:kraken/element.dart';

const String WINDOW = 'WINDOW';

class Window extends EventTarget {
  Window(ElementManager elementManager) : super(WINDOW_ID, elementManager) {
    window.onPlatformBrightnessChanged = () {
      Event event = Event(EventType.colorschemechange);
      event.detail = (window.platformBrightness == Brightness.light) ? 'light' : 'dart';
      dispatchEvent(event);
    };
  }

  void _handleColorSchemeChange(Event event) {
    String json = jsonEncode([targetId, event]);
    emitUIEvent(elementManager.controller.view.contextId, json);
  }

  void _handleLoad(Event event) {
    String json = jsonEncode([targetId, event]);
    emitUIEvent(elementManager.controller.view.contextId, json);
  }

  @override
  void addEvent(EventType eventName) {
    super.addEvent(eventName);
    if (eventHandlers.containsKey(eventName)) return; // Only listen once.

    switch (eventName) {
      case EventType.colorschemechange:
        return super.addEventListener(EventType.colorschemechange, _handleColorSchemeChange);
      case EventType.load:
        return super.addEventListener(EventType.load, _handleLoad);
      default:
    }
  }
}
