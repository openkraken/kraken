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
      dispatchEvent(event);
    };
  }

  static void _open(ElementManager elementManager, String url) {
    KrakenController rootController = elementManager.controller.view.rootController;
    String? sourceUrl = rootController.href;

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

  void addEvent(String eventType) {
    if (eventHandlers.containsKey(eventType)) return; // Only listen once.

    switch (eventType) {
      case EVENT_COLOR_SCHEME_CHANGE:
        return addEventListener(eventType, dispatchEvent);
      case EVENT_LOAD:
        return addEventListener(eventType, dispatchEvent);
      case EVENT_SCROLL:
        // Fired at the Document or element when the viewport or element is scrolled, respectively.
        return viewportElement.addEventListener(eventType, dispatchEvent);
      case EVENT_RESIZE:
        // TODO: Fired at the Window when the viewport is resized.
        break;
      default:
        // Events listened on the Window need to be proxied to the Document, because there is a RenderView on the Document, which can handle hitTest.
        // https://github.com/WebKit/WebKit/blob/main/Source/WebCore/page/VisualViewport.cpp#L61
        viewportElement.addEvent(eventType);
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
      default:
        super.handleJSCall(method, argv);
    }
  }
}
