import 'package:flutter/foundation.dart';
import 'package:kraken/dom.dart';
import 'package:kraken/bridge.dart';
import 'package:kraken/rendering.dart';
import 'package:kraken/module.dart';
import 'dart:ffi';

final Pointer<NativeFunction<NativeGetViewModuleProperty>> nativeGetViewModuleProperty = Pointer.fromFunction(ElementNativeMethods._getViewModuleProperty, 0.0);
final Pointer<NativeFunction<NativeSetViewModuleProperty>> nativeSetViewModuleProperty = Pointer.fromFunction(ElementNativeMethods._setViewModuleProperty);
final Pointer<NativeFunction<NativeGetBoundingClientRect>> nativeGetBoundingClientRect =
    Pointer.fromFunction(ElementNativeMethods._getBoundingClientRect);
final Pointer<NativeFunction<NativeGetStringValueProperty>> nativeGetStringValueProperty =
Pointer.fromFunction(ElementNativeMethods._getStringValueProperty);
final Pointer<NativeFunction<NativeClick>> nativeClick = Pointer.fromFunction(ElementNativeMethods._click);
final Pointer<NativeFunction<NativeScroll>> nativeScroll = Pointer.fromFunction(ElementNativeMethods._scroll);
final Pointer<NativeFunction<NativeScrollBy>> nativeScrollBy = Pointer.fromFunction(ElementNativeMethods._scrollBy);

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

mixin ElementNativeMethods on Node {

  static double _getViewModuleProperty(Pointer<NativeElement> nativeElement, int property) {
    if (kProfileMode) {
      PerformanceTiming.instance().mark(PERF_DOM_FORCE_LAYOUT_START);
    }
    Element element = Element.getElementOfNativePtr(nativeElement);
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

  static void _setViewModuleProperty(Pointer<NativeElement> nativeElement, int property, double value) {
    Element element = Element.getElementOfNativePtr(nativeElement);
    element.flushLayout();

    ViewModuleProperty kind = ViewModuleProperty.values[property];

    switch(kind) {
      case ViewModuleProperty.scrollTop:
        element.scrollTop = value;
        break;
      case ViewModuleProperty.scrollLeft:
        element.scrollLeft = value;
        break;
      default:
        break;
    }
  }

  static Pointer<NativeBoundingClientRect> _getBoundingClientRect(Pointer<NativeElement> nativeElement) {
    Element element = Element.getElementOfNativePtr(nativeElement);
    element.flushLayout();
    return element.boundingClientRect.toNative();
  }

  static Pointer<NativeString> _getStringValueProperty(Pointer<NativeElement> nativeElement, Pointer<NativeString> property) {
    Element element = Element.getElementOfNativePtr(nativeElement);
    element.flushLayout();
    String key = nativeStringToString(property);
    var value = element.getProperty(key);
    String valueInString = value == null ? '' : value.toString();
    return stringToNativeString(valueInString);
  }

  static void _click(Pointer<NativeElement> nativeElement) {
    Element element = Element.getElementOfNativePtr(nativeElement);
    element.flushLayout();
    element.handleMethodClick();
  }

  static void _scroll(Pointer<NativeElement> nativeElement, int x, int y) {
    Element element = Element.getElementOfNativePtr(nativeElement);
    element.flushLayout();
    element.scrollTo(x: x, y: y, withAnimation: false);
  }

  static void _scrollBy(Pointer<NativeElement> nativeElement, int x, int y) {
    Element element = Element.getElementOfNativePtr(nativeElement);
    element.flushLayout();
    element.scrollBy(dx: x, dy: y, withAnimation: false);
  }

  void bindNativeMethods(Pointer<NativeElement> nativeElement) {
    if (nativeElement == nullptr) return;
    nativeElement.ref.getViewModuleProperty = nativeGetViewModuleProperty;
    nativeElement.ref.setViewModuleProperty = nativeSetViewModuleProperty;
    nativeElement.ref.getBoundingClientRect = nativeGetBoundingClientRect;
    nativeElement.ref.getStringValueProperty = nativeGetStringValueProperty;
    nativeElement.ref.click = nativeClick;
    nativeElement.ref.scroll = nativeScroll;
    nativeElement.ref.scrollBy = nativeScrollBy;
  }
}
