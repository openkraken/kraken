/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:collection';
import 'dart:ffi';
import 'dart:ui';
import 'package:kraken/bridge.dart';
import 'package:kraken/dom.dart';
import 'package:kraken/module.dart';

const String WINDOW = 'WINDOW';

final Pointer<NativeFunction<Native_Open>> nativeOpen = Pointer.fromFunction(Window._open);

class Window extends EventTarget {
  final Pointer<NativeWindow> nativeWindowPtr;
  static SplayTreeMap<int, Window> _nativeMap = SplayTreeMap();

  Window(int targetId, this.nativeWindowPtr, ElementManager elementManager) : super(targetId, nativeWindowPtr.ref.nativeEventTarget, elementManager) {
    window.onPlatformBrightnessChanged = () {
      ColorSchemeChangeEvent event = ColorSchemeChangeEvent((window.platformBrightness == Brightness.light) ? 'light' : 'dart');
      dispatchEvent(event);
    };
    
    // Bind window methods in dart to cpp
    nativeWindowPtr.ref.open = nativeOpen;
    // Store currunt native window pointer in dart
    _nativeMap[nativeWindowPtr.address] = this;
  }

  void _handleColorSchemeChange(Event event) {
    emitUIEvent(elementManager.controller.view.contextId, nativeWindowPtr.ref.nativeEventTarget, event);
  }

  void _handleLoad(Event event) {
    emitUIEvent(elementManager.controller.view.contextId, nativeWindowPtr.ref.nativeEventTarget, event);
  }

  static void _open(Pointer<NativeWindow> nativeWindowPtr, Pointer<NativeString> urlPtr) {
    String url = nativeStringToString(urlPtr);

    ElementManager elementManager = _nativeMap[nativeWindowPtr.address].elementManager;
    String sourceUrl = elementManager.controller.view.rootController.bundleURL;
    
    elementManager.controller.view.handleNavigationAction(sourceUrl, url, KrakenNavigationType.navigate);
  }

  @override
  void addEvent(String eventName) {
    super.addEvent(eventName);
    if (eventHandlers.containsKey(eventName)) return; // Only listen once.

    switch (eventName) {
      case EVENT_COLOR_SCHEME_CHANGE:
        return addEventListener(eventName, _handleColorSchemeChange);
      case EVENT_LOAD:
        return addEventListener(eventName, _handleLoad);
      default:
        break;
    }
  }

  @override
  void dispose() {
    super.dispose();
    // Remove native reference.
    _nativeMap.remove(nativeWindowPtr.address);
  }
}
