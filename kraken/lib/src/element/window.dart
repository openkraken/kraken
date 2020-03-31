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
  Window(): super(WINDOW_ID) {
    window.onPlatformBrightnessChanged = () {
      Event event = Event('colorschemechange');
      event.detail = (window.platformBrightness == Brightness.light) ? 'light' : 'dart';
      this.dispatchEvent(event);
    };
  }

  void _handleColorSchemeChange(Event event) {
    String json = jsonEncode([WINDOW_ID, event]);
    emitUIEvent(json);
  }

  @override
  void addEvent(String eventName) {
    super.addEvent(eventName);
    if (this.eventHandlers.containsKey(eventName)) return; // Only listen once.

    switch (eventName) {
      case 'colorschemechange':
        return super.addEventListener(eventName, this._handleColorSchemeChange);
    }
  }
}
