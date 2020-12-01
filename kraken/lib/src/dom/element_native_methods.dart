import 'package:kraken/dom.dart';
import 'package:kraken/bridge.dart';
import 'dart:ffi';

final Pointer<NativeFunction<Native_GetOffsetLeft>> nativeGetOffsetLeft =
    Pointer.fromFunction(ElementNativeMethods._getOffsetLeft, 0.0);
final Pointer<NativeFunction<Native_GetOffsetTop>> nativeGetOffsetTop =
    Pointer.fromFunction(ElementNativeMethods._getOffsetTop, 0.0);
final Pointer<NativeFunction<Native_GetOffsetWidth>> nativeGetOffsetWidth =
    Pointer.fromFunction(ElementNativeMethods._getOffsetWidth, 0.0);
final Pointer<NativeFunction<Native_GetOffsetHeight>> nativeGetOffsetHeight =
    Pointer.fromFunction(ElementNativeMethods._getOffsetHeight, 0.0);
final Pointer<NativeFunction<Native_GetClientWidth>> nativeGetClientWidth =
    Pointer.fromFunction(ElementNativeMethods._getClientWidth, 0.0);
final Pointer<NativeFunction<Native_GetClientHeight>> nativeGetClientHeight =
    Pointer.fromFunction(ElementNativeMethods._getClientHeight, 0.0);
final Pointer<NativeFunction<Native_GetClientTop>> nativeGetClientTop =
    Pointer.fromFunction(ElementNativeMethods._getClientTop, 0.0);
final Pointer<NativeFunction<Native_GetClientLeft>> nativeGetClientLeft =
    Pointer.fromFunction(ElementNativeMethods._getClientLeft, 0.0);
final Pointer<NativeFunction<Native_GetScrollTop>> nativeGetScrollTop =
    Pointer.fromFunction(ElementNativeMethods._getScrollTop, 0.0);
final Pointer<NativeFunction<Native_GetScrollLeft>> nativeGetScrollLeft =
    Pointer.fromFunction(ElementNativeMethods._getScrollLeft, 0.0);
final Pointer<NativeFunction<Native_GetScrollWidth>> nativeGetScrollWidth =
    Pointer.fromFunction(ElementNativeMethods._getScrollWidth, 0.0);
final Pointer<NativeFunction<Native_GetScrollHeight>> nativeGetScrollHeight =
    Pointer.fromFunction(ElementNativeMethods._getScrollHeight, 0.0);
final Pointer<NativeFunction<Native_GetBoundingClientRect>> nativeGetBoundingClientRect =
    Pointer.fromFunction(ElementNativeMethods._getBoundingClientRect);
final Pointer<NativeFunction<Native_Click>> nativeClick = Pointer.fromFunction(ElementNativeMethods._click);
final Pointer<NativeFunction<Native_Scroll>> nativeScroll = Pointer.fromFunction(ElementNativeMethods._scroll);
final Pointer<NativeFunction<Native_ScrollBy>> nativeScrollBy = Pointer.fromFunction(ElementNativeMethods._scrollBy);

final Pointer<NativeFunction<Native_SetScrollLeft>> nativeSetScrollLeft = Pointer.fromFunction(ElementNativeMethods._setScrollLeft);
final Pointer<NativeFunction<Native_SetScrollTop>> nativeSetScrollTop = Pointer.fromFunction(ElementNativeMethods._setScrollTop);

mixin ElementNativeMethods on Node {
  static double _getOffsetLeft(Pointer<NativeElement> nativeElement) {
    Element element = Element.getElementOfNativePtr(nativeElement);
    element.renderBoxModel.owner.flushLayout();
    return element.getOffsetX();
  }

  static double _getOffsetTop(Pointer<NativeElement> nativeElement) {
    Element element = Element.getElementOfNativePtr(nativeElement);
    element.renderBoxModel.owner.flushLayout();
    return element.getOffsetY();
  }

  static double _getOffsetWidth(Pointer<NativeElement> nativeElement) {
    Element element = Element.getElementOfNativePtr(nativeElement);
    element.renderBoxModel.owner.flushLayout();
    return element.renderBoxModel.hasSize ? element.renderBoxModel.size.width : 0;
  }

  static double _getOffsetHeight(Pointer<NativeElement> nativeElement) {
    Element element = Element.getElementOfNativePtr(nativeElement);
    element.renderBoxModel.owner.flushLayout();
    return element.renderBoxModel.hasSize ? element.renderBoxModel.size.height : 0;
  }

  static double _getClientWidth(Pointer<NativeElement> nativeElement) {
    Element element = Element.getElementOfNativePtr(nativeElement);
    element.renderBoxModel.owner.flushLayout();
    return element.renderBoxModel.clientWidth;
  }

  static double _getClientHeight(Pointer<NativeElement> nativeElement) {
    Element element = Element.getElementOfNativePtr(nativeElement);
    element.renderBoxModel.owner.flushLayout();
    return element.renderBoxModel.clientHeight;
  }

  static double _getClientLeft(Pointer<NativeElement> nativeElement) {
    Element element = Element.getElementOfNativePtr(nativeElement);
    element.renderBoxModel.owner.flushLayout();
    return element.renderBoxModel.borderLeft;
  }

  static double _getClientTop(Pointer<NativeElement> nativeElement) {
    Element element = Element.getElementOfNativePtr(nativeElement);
    element.renderBoxModel.owner.flushLayout();
    return element.renderBoxModel.borderTop;
  }

  static double _getScrollTop(Pointer<NativeElement> nativeElement) {
    Element element = Element.getElementOfNativePtr(nativeElement);
    element.renderBoxModel.owner.flushLayout();
    return element.scrollTop;
  }

  static double _getScrollLeft(Pointer<NativeElement> nativeElement) {
    Element element = Element.getElementOfNativePtr(nativeElement);
    element.renderBoxModel.owner.flushLayout();
    return element.scrollLeft;
  }

  static void _setScrollTop(Pointer<NativeElement> nativeElement, double top) {
    Element element = Element.getElementOfNativePtr(nativeElement);
    element.renderBoxModel.owner.flushLayout();
    element.scrollTop = top;
  }

  static void _setScrollLeft(Pointer<NativeElement> nativeElement, double left) {
    Element element = Element.getElementOfNativePtr(nativeElement);
    element.renderBoxModel.owner.flushLayout();
    element.scrollLeft = left;
  }

  static double _getScrollWidth(Pointer<NativeElement> nativeElement) {
    Element element = Element.getElementOfNativePtr(nativeElement);
    element.renderBoxModel.owner.flushLayout();
    return element.scrollWidth;
  }

  static double _getScrollHeight(Pointer<NativeElement> nativeElement) {
    Element element = Element.getElementOfNativePtr(nativeElement);
    element.renderBoxModel.owner.flushLayout();
    return element.scrollHeight;
  }

  static Pointer<NativeBoundingClientRect> _getBoundingClientRect(Pointer<NativeElement> nativeElement) {
    Element element = Element.getElementOfNativePtr(nativeElement);
    element.renderBoxModel.owner.flushLayout();
    return element.boundingClientRect.toNative();
  }

  static void _click(Pointer<NativeElement> nativeElement) {
    Element element = Element.getElementOfNativePtr(nativeElement);
    element.renderBoxModel.owner.flushLayout();
    element.handleMethodClick();
  }

  static void _scroll(Pointer<NativeElement> nativeElement, int x, int y) {
    Element element = Element.getElementOfNativePtr(nativeElement);
    element.renderBoxModel.owner.flushLayout();
    element.handleMethodScroll(x, y);
  }

  static void _scrollBy(Pointer<NativeElement> nativeElement, int x, int y) {
    Element element = Element.getElementOfNativePtr(nativeElement);
    element.renderBoxModel.owner.flushLayout();
    element.handleMethodScroll(x, y, diff: true);
  }

  void bindNativeMethods(Pointer<NativeElement> nativeElement) {
    if (nativeElement == nullptr) return;
    nativeElement.ref.getOffsetLeft = nativeGetOffsetLeft;
    nativeElement.ref.getOffsetTop = nativeGetOffsetTop;
    nativeElement.ref.getOffsetWidth = nativeGetOffsetWidth;
    nativeElement.ref.getOffsetHeight = nativeGetOffsetHeight;
    nativeElement.ref.getClientWidth = nativeGetClientWidth;
    nativeElement.ref.getClientHeight = nativeGetClientHeight;
    nativeElement.ref.getClientTop = nativeGetClientTop;
    nativeElement.ref.getClientLeft = nativeGetClientLeft;
    nativeElement.ref.getScrollTop = nativeGetScrollTop;
    nativeElement.ref.setScrollTop = nativeSetScrollTop;
    nativeElement.ref.getScrollLeft = nativeGetScrollLeft;
    nativeElement.ref.setScrollLeft = nativeSetScrollLeft;
    nativeElement.ref.getScrollWidth = nativeGetScrollWidth;
    nativeElement.ref.getScrollHeight = nativeGetScrollHeight;
    nativeElement.ref.getBoundingClientRect = nativeGetBoundingClientRect;
    nativeElement.ref.click = nativeClick;
    nativeElement.ref.scroll = nativeScroll;
    nativeElement.ref.scrollBy = nativeScrollBy;
  }
}
