/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'dart:ui';

import 'package:kraken/dom.dart';
import 'package:kraken/foundation.dart';
import 'package:kraken/launcher.dart';
import 'package:kraken/module.dart';
import 'package:kraken/bridge.dart';

const String WINDOW = 'WINDOW';

class Window extends EventTarget {
  final Document document;

  @override
  EventTarget? get parentEventTarget => null;

  Window(BindingContext? context, this.document) : super(context) {
    window.onPlatformBrightnessChanged = () {
      ColorSchemeChangeEvent event = ColorSchemeChangeEvent((window.platformBrightness == Brightness.light) ? 'light' : 'dart');
      dispatchEvent(event);
    };
  }

  // https://www.w3.org/TR/cssom-view-1/#extensions-to-the-window-interface
  @override
  getBindingProperty(String key) {
    switch (key) {
      case 'scrollX': return scrollX;
      case 'scrollY': return scrollY;
      default: return super.getBindingProperty(key);
    }
  }

  @override
  invokeBindingMethod(String method, List args) {
    switch (method) {
      case 'scroll':
      case 'scrollTo':
        return scrollTo(
            castToType<double>(args[0]),
            castToType<double>(args[1])
        );
      case 'scrollBy':
        return scrollBy(
            castToType<double>(args[0]),
            castToType<double>(args[1])
        );
      case 'open':
        return open(castToType<String>(args[0]));
      default: return super.invokeBindingMethod(method, args);
    }
  }

  void open(String url) {
    KrakenController rootController = document.controller.view.rootController;
    String? sourceUrl = rootController.url;

    document.controller.view.handleNavigationAction(sourceUrl, url, KrakenNavigationType.navigate);
  }

  double get scrollX => document.documentElement!.scrollLeft;

  double get scrollY => document.documentElement!.scrollTop;

  void scrollTo(double x, double y) {
    document.documentElement!
      ..flushLayout()
      ..scrollTo(x, y);
  }

  void scrollBy(double x, double y) {
    document.documentElement!
      ..flushLayout()
      ..scrollBy(x, y);
  }

  @override
  void dispatchEvent(Event event) {
    // Events such as EVENT_DOM_CONTENT_LOADED need to ensure that listeners are flushed and registered.
    if (event.type == EVENT_DOM_CONTENT_LOADED || event.type == EVENT_LOAD || event.type == EVENT_ERROR) {
      flushUICommand();
    }
    super.dispatchEvent(event);
  }

  @override
  void addEventListener(String eventType, EventHandler handler) {
    super.addEventListener(eventType, handler);
    switch (eventType) {
      case EVENT_SCROLL:
        // Fired at the Document or element when the viewport or element is scrolled, respectively.
        document.documentElement?.addEventListener(eventType, handler);
        break;
    }
  }

  @override
  void removeEventListener(String eventType, EventHandler handler) {
    super.removeEventListener(eventType, handler);
    switch (eventType) {
      case EVENT_SCROLL:
        document.documentElement?.removeEventListener(eventType, handler);
        break;
    }
  }

  /// Moves the focus to the window's browsing context, if any.
  /// https://html.spec.whatwg.org/multipage/interaction.html#dom-window-focus
  void focus() {
    // TODO
  }
}
