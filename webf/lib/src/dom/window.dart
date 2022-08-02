/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
import 'dart:ui';

import 'package:webf/bridge.dart';
import 'package:webf/dom.dart';
import 'package:webf/foundation.dart';
import 'package:webf/rendering.dart';
import 'package:webf/module.dart';

const String WINDOW = 'WINDOW';

class Window extends EventTarget {
  final Document document;
  final Screen screen;

  Window(BindingContext? context, this.document)
      : screen = Screen(context),
        super(context);

  @override
  EventTarget? get parentEventTarget => null;

  // https://www.w3.org/TR/cssom-view-1/#extensions-to-the-window-interface
  @override
  getBindingProperty(String key) {
    switch (key) {
      case 'innerWidth':
        return innerWidth;
      case 'innerHeight':
        return innerHeight;
      case 'scrollX':
        return scrollX;
      case 'scrollY':
        return scrollY;
      case 'screen':
        return screen;
      case 'colorScheme':
        return colorScheme;
      case 'devicePixelRatio':
        return devicePixelRatio;
      default:
        return super.getBindingProperty(key);
    }
  }

  @override
  invokeBindingMethod(String method, List args) {
    switch (method) {
      case 'scroll':
      case 'scrollTo':
        return scrollTo(castToType<double>(args[0]), castToType<double>(args[1]));
      case 'scrollBy':
        return scrollBy(castToType<double>(args[0]), castToType<double>(args[1]));
      case 'open':
        return open(castToType<String>(args[0]));
      default:
        return super.invokeBindingMethod(method, args);
    }
  }

  void open(String url) {
    String? sourceUrl = document.controller.view.rootController.url;
    document.controller.view.handleNavigationAction(sourceUrl, url, WebFNavigationType.navigate);
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

  String get colorScheme => window.platformBrightness == Brightness.light ? 'light' : 'dark';

  double get devicePixelRatio => window.devicePixelRatio;

  // The innerWidth/innerHeight attribute must return the viewport width/height
  // including the size of a rendered scroll bar (if any), or zero if there is no viewport.
  // https://drafts.csswg.org/cssom-view/#dom-window-innerwidth
  // This is a read only idl attribute.
  int get innerWidth => _viewportSize.width.toInt();
  int get innerHeight => _viewportSize.height.toInt();

  Size get _viewportSize {
    RenderViewportBox? viewport = document.viewport;
    if (viewport != null && viewport.hasSize) {
      return viewport.size;
    } else {
      return Size.zero;
    }
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
