import 'package:kraken/dom.dart';
import 'package:kraken/bridge.dart';
import 'dart:ffi';

final Pointer<NativeFunction<Native_GetViewModuleProperty>> nativeGetViewModuleProperty = Pointer.fromFunction(ElementNativeMethods._getViewModuleProperty, 0.0);
final Pointer<NativeFunction<Native_GetBoundingClientRect>> nativeGetBoundingClientRect =
    Pointer.fromFunction(ElementNativeMethods._getBoundingClientRect);
final Pointer<NativeFunction<Native_GetStringValueProperty>> nativeGetStringValueProperty =
Pointer.fromFunction(ElementNativeMethods._getStringValueProperty);
final Pointer<NativeFunction<Native_Click>> nativeClick = Pointer.fromFunction(ElementNativeMethods._click);
final Pointer<NativeFunction<Native_Scroll>> nativeScroll = Pointer.fromFunction(ElementNativeMethods._scroll);
final Pointer<NativeFunction<Native_ScrollBy>> nativeScrollBy = Pointer.fromFunction(ElementNativeMethods._scrollBy);

final Pointer<NativeFunction<Native_SetScrollLeft>> nativeSetScrollLeft = Pointer.fromFunction(ElementNativeMethods._setScrollLeft);
final Pointer<NativeFunction<Native_SetScrollTop>> nativeSetScrollTop = Pointer.fromFunction(ElementNativeMethods._setScrollTop);

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
    Element element = Element.getElementOfNativePtr(nativeElement);
    element.flushLayout();
    ViewModuleProperty kind = ViewModuleProperty.values[property];
    switch(kind) {
      case ViewModuleProperty.offsetTop:
        return element.getOffsetY();
      case ViewModuleProperty.offsetLeft:
        return element.getOffsetX();
      case ViewModuleProperty.offsetWidth:
        return element.renderBoxModel.hasSize ? element.renderBoxModel.size.width : 0;
      case ViewModuleProperty.offsetHeight:
        return element.renderBoxModel.hasSize ? element.renderBoxModel.size.height : 0;
      case ViewModuleProperty.clientWidth:
        return element.renderBoxModel.clientWidth;
      case ViewModuleProperty.clientHeight:
        return element.renderBoxModel.clientHeight;
      case ViewModuleProperty.clientTop:
        return element.renderBoxModel.borderTop;
      case ViewModuleProperty.clientLeft:
        return element.renderBoxModel.borderLeft;
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

  static void _setScrollTop(Pointer<NativeElement> nativeElement, double top) {
    Element element = Element.getElementOfNativePtr(nativeElement);
    element.flushLayout();
    element.scrollTop = top;
  }

  static void _setScrollLeft(Pointer<NativeElement> nativeElement, double left) {
    Element element = Element.getElementOfNativePtr(nativeElement);
    element.flushLayout();
    element.scrollLeft = left;
  }

  static double _getScrollWidth(Pointer<NativeElement> nativeElement) {
    Element element = Element.getElementOfNativePtr(nativeElement);
    element.flushLayout();
    return element.scrollWidth;
  }

  static double _getScrollHeight(Pointer<NativeElement> nativeElement) {
    Element element = Element.getElementOfNativePtr(nativeElement);
    element.renderBoxModel.owner.flushLayout();
    return element.scrollHeight;
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
    element.handleMethodScroll(x, y);
  }

  static void _scrollBy(Pointer<NativeElement> nativeElement, int x, int y) {
    Element element = Element.getElementOfNativePtr(nativeElement);
    element.flushLayout();
    element.handleMethodScroll(x, y, diff: true);
  }

  void bindNativeMethods(Pointer<NativeElement> nativeElement) {
    if (nativeElement == nullptr) return;
    nativeElement.ref.getViewModuleProperty = nativeGetViewModuleProperty;
    nativeElement.ref.getBoundingClientRect = nativeGetBoundingClientRect;
    nativeElement.ref.getStringValueProperty = nativeGetStringValueProperty;
    nativeElement.ref.click = nativeClick;
    nativeElement.ref.scroll = nativeScroll;
    nativeElement.ref.scrollBy = nativeScrollBy;
    nativeElement.ref.setScrollTop = nativeSetScrollTop;
    nativeElement.ref.setScrollLeft = nativeSetScrollLeft;
  }
}
