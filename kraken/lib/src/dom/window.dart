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

final Pointer<NativeFunction<NativeWindowOpen>> nativeOpen = Pointer.fromFunction(Window._open);
final Pointer<NativeFunction<NativeWindowScrollX>> nativeScrollX = Pointer.fromFunction(Window._scrollX, 0.0);
final Pointer<NativeFunction<NativeWindowScrollY>> nativeScrollY = Pointer.fromFunction(Window._scrollY, 0.0);
final Pointer<NativeFunction<NativeWindowScrollTo>> nativeScrollTo = Pointer.fromFunction(Window._scrollTo);
final Pointer<NativeFunction<NativeWindowScrollBy>> nativeScrollBy = Pointer.fromFunction(Window._scrollBy);

class Window extends EventTarget {
  final Pointer<NativeWindow> nativeWindowPtr;
  static SplayTreeMap<int, Window> _nativeMap = SplayTreeMap();
  final Document document;

  Window(int targetId, this.nativeWindowPtr, ElementManager elementManager, this.document) : super(targetId, nativeWindowPtr.ref.nativeEventTarget, elementManager) {
    window.onPlatformBrightnessChanged = () {
      ColorSchemeChangeEvent event = ColorSchemeChangeEvent((window.platformBrightness == Brightness.light) ? 'light' : 'dart');
      dispatchEvent(event);
    };

    // Bind window methods in dart to cpp
    nativeWindowPtr.ref.open = nativeOpen;
    nativeWindowPtr.ref.scrollX = nativeScrollX;
    nativeWindowPtr.ref.scrollY = nativeScrollY;
    nativeWindowPtr.ref.scrollTo = nativeScrollTo;
    nativeWindowPtr.ref.scrollBy = nativeScrollBy;
    // Store current native window pointer in dart
    _nativeMap[nativeWindowPtr.address] = this;
  }

  void _handleColorSchemeChange(Event event) {
    emitUIEvent(elementManager.controller.view.contextId, nativeWindowPtr.ref.nativeEventTarget, event);
  }

  void _handleLoad(Event event) {
    emitUIEvent(elementManager.controller.view.contextId, nativeWindowPtr.ref.nativeEventTarget, event);
  }

  void _handleScroll(Event event) {
    emitUIEvent(elementManager.controller.view.contextId, nativeWindowPtr.ref.nativeEventTarget, event);
  }

  static void _open(Pointer<NativeWindow> nativeWindowPtr, Pointer<NativeString> urlPtr) {
    String url = nativeStringToString(urlPtr);

    ElementManager elementManager = _nativeMap[nativeWindowPtr.address]!.elementManager;
    String? sourceUrl = elementManager.controller.view.rootController.bundleURL;

    if (sourceUrl == null) return;

    elementManager.controller.view.handleNavigationAction(sourceUrl, url, KrakenNavigationType.navigate);
  }

  static double _scrollX(Pointer<NativeWindow> nativeWindowPtr) {
    Window window = _nativeMap[nativeWindowPtr.address]!;
    return window.scrollX();
  }

  static double _scrollY(Pointer<NativeWindow> nativeWindowPtr) {
    Window window = _nativeMap[nativeWindowPtr.address]!;
    return window.scrollY();
  }

  static void _scrollTo(Pointer<NativeWindow> nativeWindowPtr, int x, int y) {
    Window window = _nativeMap[nativeWindowPtr.address]!;
    window.viewportElement.flushLayout();
    window.scrollTo(x, y);
  }

  static void _scrollBy(Pointer<NativeWindow> nativeWindowPtr, int x, int y) {
    Window window = _nativeMap[nativeWindowPtr.address]!;
    window.viewportElement.flushLayout();
    window.scrollBy(x, y);
  }

  double scrollX() {
    return viewportElement.scrollLeft;
  }

  double scrollY() {
    return viewportElement.scrollTop;
  }

  void scrollTo(num x, num y) {
    viewportElement.scrollTo(x: x, y: y, withAnimation: false);
  }

  void scrollBy(num x, num y) {
    viewportElement.scrollBy(dx: x, dy: y, withAnimation: false);
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
      case EVENT_SCROLL:
        return document.documentElement.addEventListener(eventName, _handleScroll);
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
