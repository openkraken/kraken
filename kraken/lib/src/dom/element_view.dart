/*
 * Copyright (C) 2021-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:ffi';

import 'package:flutter/foundation.dart';
import 'package:kraken/bridge.dart';
import 'package:kraken/dom.dart';
import 'package:kraken/module.dart';
import 'package:kraken/rendering.dart';

// https://www.w3.org/TR/cssom-view-1/
enum ViewModuleProperty {
  offsetTop,
  offsetLeft,
  offsetWidth,
  offsetHeight,
  clientWidth,
  clientHeight,
  clientTop,
  clientLeft,
  scrollTop,
  scrollLeft,
  scrollHeight,
  scrollWidth
}

mixin ElementViewMixin on ElementBase {
  @override
  dynamic handleJSCall(String method, List<dynamic> argv) {
    Element element = (this as Element);
    switch(method) {
      case 'getViewModuleProperty':
        return _getViewModuleProperty(element, argv[0]);
      case 'setViewModuleProperty':
        return _setViewModuleProperty(element, argv[0], argv[1]);
      case 'getBoundingClientRect':
        return _getBoundingClientRect(element);
      case 'getStringValueProperty':
        return _getStringValueProperty(element, argv[0]);
      case 'click':
        return _click(element);
      case 'scroll':
        return _scroll(element, argv[0], argv[1]);
      case 'scrollBy':
        return _scrollBy(element, argv[0], argv[1]);
    }
    return super.handleJSCall(method, argv);
  }

  static double _getViewModuleProperty(Element element, int property) {
    if (kProfileMode) {
      PerformanceTiming.instance().mark(PERF_DOM_FORCE_LAYOUT_START);
    }
    element.flushLayout();

    if (kProfileMode) {
      PerformanceTiming.instance().mark(PERF_DOM_FORCE_LAYOUT_END);
    }

    RenderBoxModel? elementRenderBoxModel = element.renderBoxModel;

    if (elementRenderBoxModel == null) {
      return 0.0;
    }

    ViewModuleProperty kind = ViewModuleProperty.values[property];
    switch(kind) {
      case ViewModuleProperty.offsetTop:
        return element.getOffsetY();
      case ViewModuleProperty.offsetLeft:
        return element.getOffsetX();
      case ViewModuleProperty.offsetWidth:
        return elementRenderBoxModel.hasSize ? elementRenderBoxModel.size.width : 0;
      case ViewModuleProperty.offsetHeight:
        return elementRenderBoxModel.hasSize ? elementRenderBoxModel.size.height : 0;
      case ViewModuleProperty.clientWidth:
        return elementRenderBoxModel.clientWidth;
      case ViewModuleProperty.clientHeight:
        return elementRenderBoxModel.clientHeight;
      case ViewModuleProperty.clientTop:
        return elementRenderBoxModel.renderStyle.effectiveBorderTopWidth.computedValue;
      case ViewModuleProperty.clientLeft:
        return elementRenderBoxModel.renderStyle.effectiveBorderLeftWidth.computedValue;
      case ViewModuleProperty.scrollTop:
        return element.scrollTop;
      case ViewModuleProperty.scrollLeft:
        return element.scrollLeft;
      case ViewModuleProperty.scrollHeight:
        return element.scrollHeight;
      case ViewModuleProperty.scrollWidth:
        return element.scrollWidth;
    }
  }

  static void _setViewModuleProperty(Element element, num property, num value) {
    element.flushLayout();

    ViewModuleProperty kind = ViewModuleProperty.values[property.toInt()];

    switch(kind) {
      case ViewModuleProperty.scrollTop:
        element.scrollTop = value.toDouble();
        break;
      case ViewModuleProperty.scrollLeft:
        element.scrollLeft = value.toDouble();
        break;
      default:
        break;
    }
  }

  static Pointer<NativeBoundingClientRect> _getBoundingClientRect(Element element) {
    element.flushLayout();
    return element.boundingClientRect.toNative();
  }

  static Pointer<NativeString> _getStringValueProperty(Element element, String key) {
    element.flushLayout();
    var value = element.getProperty(key);
    String valueInString = value == null ? '' : value.toString();
    return stringToNativeString(valueInString);
  }

  static void _click(Element element) {
    element.flushLayout();
    element.click();
  }

  static void _scroll(Element element, int x, int y) {
    element.flushLayout();
    element.scrollTo(x: x, y: y, withAnimation: false);
  }

  static void _scrollBy(Element element, int x, int y) {
    element.flushLayout();
    element.scrollBy(dx: x, dy: y, withAnimation: false);
  }
}
