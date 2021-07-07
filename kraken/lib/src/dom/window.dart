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

// final Pointer<NativeFunction<NativeWindowOpen>> nativeOpen = Pointer.fromFunction(Window._open);
// final Pointer<NativeFunction<NativeWindowScrollX>> nativeScrollX = Pointer.fromFunction(Window._scrollX, 0.0);
// final Pointer<NativeFunction<NativeWindowScrollY>> nativeScrollY = Pointer.fromFunction(Window._scrollY, 0.0);
// final Pointer<NativeFunction<NativeWindowScrollTo>> nativeScrollTo = Pointer.fromFunction(Window._scrollTo);
// final Pointer<NativeFunction<NativeWindowScrollBy>> nativeScrollBy = Pointer.fromFunction(Window._scrollBy);

class Window extends EventTarget {
  // final Element viewportElement;

  Window(int targetId, Pointer<NativeEventTarget> nativeEventTarget, ElementManager elementManager) : super(targetId, nativeEventTarget, elementManager) {
    window.onPlatformBrightnessChanged = () {
      ColorSchemeChangeEvent event = ColorSchemeChangeEvent((window.platformBrightness == Brightness.light) ? 'light' : 'dart');
      dispatchEvent(event);
    };

    // Bind window methods in dart to cpp
    // NativeEventTarget.ref.open = nativeOpen;
    // NativeEventTarget.ref.scrollX = nativeScrollX;
    // NativeEventTarget.ref.scrollY = nativeScrollY;
    // NativeEventTarget.ref.scrollTo = nativeScrollTo;
    // NativeEventTarget.ref.scrollBy = nativeScrollBy;
  }

  void _handleColorSchemeChange(Event event) {
    emitUIEvent(elementManager.controller.view.contextId, nativeEventTargetPtr, event);
  }

  void _handleLoad(Event event) {
    emitUIEvent(elementManager.controller.view.contextId, nativeEventTargetPtr, event);
  }

  void _handleScroll(Event event) {
    emitUIEvent(elementManager.controller.view.contextId, nativeEventTargetPtr, event);
  }

  static void _open(Pointer<NativeEventTarget> nativeEventTarget, Pointer<NativeString> urlPtr) {
    // String url = nativeStringToString(urlPtr);

    // ElementManager elementManager = _nativeMap[NativeEventTarget.address]!.elementManager;
    // String? sourceUrl = elementManager.controller.view.rootController.bundleURL;

    // if (sourceUrl == null) return;

    // elementManager.controller.view.handleNavigationAction(sourceUrl, url, KrakenNavigationType.navigate);
  }

  // static double _scrollX(Pointer<NativeEventTarget> NativeEventTarget) {
    // Window window = _nativeMap[NativeEventTarget.address]!;
    // return window.scrollX();
  // }

  // static double _scrollY(Pointer<NativeEventTarget> NativeEventTarget) {
    // Window window = _nativeMap[NativeEventTarget.address]!;
    // return window.scrollY();
  // }

  static void _scrollTo(Pointer<NativeEventTarget> NativeEventTarget, int x, int y) {
    // Window window = _nativeMap[NativeEventTarget.address]!;
    // window.viewportElement.flushLayout();
    // window.scrollTo(x, y);
  }

  static void _scrollBy(Pointer<NativeEventTarget> NativeEventTarget, int x, int y) {
    // Window window = _nativeMap[NativeEventTarget.address]!;
    // window.viewportElement.flushLayout();
    // window.scrollBy(x, y);
  }

  double scrollX() {
    return 1.0;
    // return viewportElement.scrollLeft;
  }

  double scrollY() {
    return 2.0;
    // return viewportElement.scrollTop;
  }

  void scrollTo(num x, num y) {
    // viewportElement.scrollTo(x: x, y: y, withAnimation: false);
  }

  void scrollBy(num x, num y) {
    // viewportElement.scrollBy(dx: x, dy: y, withAnimation: false);
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
        // return viewportElement.addEventListener(eventName, _handleScroll);
      default:
        // Events listened on the Window need to be proxied to the Document, because there is a RenderView on the Document, which can handle hitTest.
        // https://github.com/WebKit/WebKit/blob/main/Source/WebCore/page/VisualViewport.cpp#L61
        // viewportElement.addEvent(eventName);
        break;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
