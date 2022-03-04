/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'dart:ui';

import 'package:kraken/dom.dart';
import 'package:kraken/foundation.dart';
import 'package:kraken/launcher.dart';
import 'package:kraken/module.dart';

const String WINDOW = 'WINDOW';

class Window extends EventTarget implements EventDispatchController {
  final Document document;

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
  void bindEventDispatcher(String eventType) {
    if (hasEventListener(eventType)) return; // Only listen once.

    switch (eventType) {
      case EVENT_COLOR_SCHEME_CHANGE:
        return addEventListener(eventType, dispatchEvent);
      case EVENT_LOAD:
        return addEventListener(eventType, dispatchEvent);
      case EVENT_SCROLL:
        // Fired at the Document or element when the viewport or element is scrolled, respectively.
        return document.documentElement!.addEventListener(eventType, dispatchEvent);
      case EVENT_RESIZE:
        // TODO: Fired at the Window when the viewport is resized.
        break;
      default:
        // Events listened on the Window need to be proxy to the Document, because there is a RenderView on the Document, which can handle hitTest.
        // https://github.com/WebKit/WebKit/blob/main/Source/WebCore/page/VisualViewport.cpp#L61
        document.documentElement!.bindEventDispatcher(eventType);
        break;
    }
  }

  @override
  void unbindEventDispatcher(String eventType) {
    switch (eventType) {
      case EVENT_COLOR_SCHEME_CHANGE:
      case EVENT_LOAD:
        return removeEventListener(eventType, dispatchEvent);
    }
  }
}
