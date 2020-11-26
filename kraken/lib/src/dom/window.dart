/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:ffi';
import 'dart:ui';
import 'package:kraken/bridge.dart';
import 'package:kraken/dom.dart';

const String WINDOW = 'WINDOW';

class Window extends EventTarget {
  final Pointer<NativeWindow> nativeWindowPtr;

  Window(int targetId, this.nativeWindowPtr, ElementManager elementManager) : super(targetId, nativeWindowPtr.ref.nativeEventTarget, elementManager) {
    window.onPlatformBrightnessChanged = () {
      ColorSchemeChangeEvent event = ColorSchemeChangeEvent();
      event.platformBrightness = (window.platformBrightness == Brightness.light) ? 'light' : 'dart';
      dispatchEvent(event);
    };
  }

  void _handleColorSchemeChange(Event event) {
    emitUIEvent(elementManager.controller.view.contextId, nativeWindowPtr.ref.nativeEventTarget, event);
  }

  void _handleLoad(Event event) {
    emitUIEvent(elementManager.controller.view.contextId, nativeWindowPtr.ref.nativeEventTarget, event);
  }

  @override
  void addEvent(EventType eventName) {
    super.addEvent(eventName);
    if (eventHandlers.containsKey(eventName)) return; // Only listen once.

    switch (eventName) {
      case EventType.colorschemechange:
        return addEventListener(EventType.colorschemechange, _handleColorSchemeChange);
      case EventType.load:
        return addEventListener(EventType.load, _handleLoad);
      default:
        break;
    }
  }
}
