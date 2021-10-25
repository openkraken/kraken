/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:ffi';
import 'dart:ui';

import 'package:kraken/bridge.dart';
import 'package:kraken/dom.dart';
import 'package:kraken/launcher.dart';
import 'package:kraken/module.dart';

const String WINDOW = 'WINDOW';

class Window extends EventTarget {
  final Element viewportElement;

  Window(int targetId, Pointer<NativeEventTarget> nativeEventTarget, ElementManager elementManager, this.viewportElement) : super(targetId, nativeEventTarget, elementManager) {
    window.onPlatformBrightnessChanged = () {
      ColorSchemeChangeEvent event = ColorSchemeChangeEvent((window.platformBrightness == Brightness.light) ? 'light' : 'dart');
      emitUIEvent(elementManager.controller.view.contextId, nativeEventTargetPtr, event);
    };
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

  static void _open(ElementManager elementManager, String url) {
    KrakenController rootController = elementManager.controller.view.rootController;
    String? sourceUrl = rootController.bundleURL ?? rootController.bundlePath;

    elementManager.controller.view.handleNavigationAction(sourceUrl, url, KrakenNavigationType.navigate);
  }

  double scrollX() {
    return viewportElement.scrollLeft;
  }

  double scrollY() {
    return viewportElement.scrollTop;
  }

  void scrollTo(num x, num y) {
    viewportElement.flushLayout();
    viewportElement.scrollTo(x: x, y: y, withAnimation: false);
  }

  void scrollBy(num x, num y) {
    viewportElement.flushLayout();
    viewportElement.scrollBy(dx: x, dy: y, withAnimation: false);
  }

  void addEvent(String eventName) {
    if (eventHandlers.containsKey(eventName)) return; // Only listen once.

    switch (eventName) {
      case EVENT_COLOR_SCHEME_CHANGE:
        return addEventListener(eventName, _handleColorSchemeChange);
      case EVENT_LOAD:
        return addEventListener(eventName, _handleLoad);
      case EVENT_SCROLL:
        return viewportElement.addEventListener(eventName, _handleScroll);
      default:
        // Events listened on the Window need to be proxied to the Document, because there is a RenderView on the Document, which can handle hitTest.
        // https://github.com/WebKit/WebKit/blob/main/Source/WebCore/page/VisualViewport.cpp#L61
        viewportElement.addEvent(eventName);
        break;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  dynamic handleJSCall(String method, List<dynamic> argv) {
    switch(method) {
      case 'scroll':
      case 'scrollTo':
        return scrollTo(argv[0], argv[1]);
      case 'scrollBy':
        return scrollBy(argv[0], argv[1]);
      case 'scrollX':
        return scrollX();
      case 'scrollY':
        return scrollY();
      case 'open':
        return _open(elementManager, argv[0]);
    }
  }
}
