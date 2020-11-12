import 'package:kraken/dom.dart';
import 'package:kraken/launcher.dart';
import 'package:kraken/bridge.dart';
import 'dart:ffi';

final Pointer<NativeFunction<Native_GetOffsetLeft>> nativeGetOffsetLeft = Pointer.fromFunction(ElementNativeMethods._getOffsetLeft, 0.0);
final Pointer<NativeFunction<Native_GetOffsetTop>> nativeGetOffsetTop = Pointer.fromFunction(ElementNativeMethods._getOffsetTop, 0.0);
final Pointer<NativeFunction<Native_GetOffsetWidth>> nativeGetOffsetWidth = Pointer.fromFunction(ElementNativeMethods._getOffsetWidth, 0.0);
final Pointer<NativeFunction<Native_GetOffsetHeight>> nativeGetOffsetHeight = Pointer.fromFunction(ElementNativeMethods._getOffsetHeight, 0.0);
final Pointer<NativeFunction<Native_GetClientWidth>> nativeGetClientWidth = Pointer.fromFunction(ElementNativeMethods._getClientWidth, 0.0);
final Pointer<NativeFunction<Native_GetClientHeight>> nativeGetClientHeight = Pointer.fromFunction(ElementNativeMethods._getClientHeight, 0.0);
final Pointer<NativeFunction<Native_GetClientTop>> nativeGetClientTop = Pointer.fromFunction(ElementNativeMethods._getClientTop, 0.0);
final Pointer<NativeFunction<Native_GetClientLeft>> nativeGetClientLeft = Pointer.fromFunction(ElementNativeMethods._getClientLeft, 0.0);
final Pointer<NativeFunction<Native_GetScrollTop>> nativeGetScrollTop = Pointer.fromFunction(ElementNativeMethods._getScrollTop, 0.0);
final Pointer<NativeFunction<Native_GetScrollLeft>> nativeGetScrollLeft = Pointer.fromFunction(ElementNativeMethods._getScrollLeft, 0.0);
final Pointer<NativeFunction<Native_GetScrollWidth>> nativeGetScrollWidth = Pointer.fromFunction(ElementNativeMethods._getScrollWidth, 0.0);
final Pointer<NativeFunction<Native_GetScrollHeight>> nativeGetScrollHeight = Pointer.fromFunction(ElementNativeMethods._getScrollHeight, 0.0);
final Pointer<NativeFunction<Native_GetBoundingClientRect>> nativeGetBoundingClientRect = Pointer.fromFunction(ElementNativeMethods._getBoundingClientRect);
final Pointer<NativeFunction<Native_Click>> nativeClick = Pointer.fromFunction(ElementNativeMethods._click);
final Pointer<NativeFunction<Native_Scroll>> nativeScroll = Pointer.fromFunction(ElementNativeMethods._scroll);
final Pointer<NativeFunction<Native_ScrollBy>> nativeScrollBy = Pointer.fromFunction(ElementNativeMethods._scrollBy);

mixin ElementNativeMethods on Node {
  static double _getOffsetLeft(int contextId, int targetId) {
    KrakenController controller = KrakenController.getControllerOfJSContextId(contextId);
    EventTarget target = controller.view.getEventTargetById(targetId);
    if (target is Element) {
      controller.view.getRootRenderObject().owner.flushLayout();
      return target.getOffsetX();
    }
    return 0.0;
  }

  static double _getOffsetTop(int contextId, int targetId) {
    KrakenController controller = KrakenController.getControllerOfJSContextId(contextId);
    EventTarget target = controller.view.getEventTargetById(targetId);
    if (target is Element) {
      controller.view.getRootRenderObject().owner.flushLayout();
      return target.getOffsetY();
    }
    return 0.0;
  }

  static double _getOffsetWidth(int contextId, int targetId) {
    KrakenController controller = KrakenController.getControllerOfJSContextId(contextId);
    EventTarget target = controller.view.getEventTargetById(targetId);
    if (target is Element) {
      controller.view.getRootRenderObject().owner.flushLayout();
      return target.renderBoxModel.hasSize ? target.renderBoxModel.size.width : 0;
    }
    return 0.0;
  }

  static double _getOffsetHeight(int contextId, int targetId) {
    KrakenController controller = KrakenController.getControllerOfJSContextId(contextId);
    EventTarget target = controller.view.getEventTargetById(targetId);
    if (target is Element) {
      controller.view.getRootRenderObject().owner.flushLayout();
      return target.renderBoxModel.hasSize ? target.renderBoxModel.size.height : 0;
    }
    return 0.0;
  }

  static double _getClientWidth(int contextId, int targetId) {
    KrakenController controller = KrakenController.getControllerOfJSContextId(contextId);
    EventTarget target = controller.view.getEventTargetById(targetId);
    if (target is Element) {
      controller.view.getRootRenderObject().owner.flushLayout();
      return target.renderBoxModel.clientWidth;
    }
    return 0.0;
  }

  static double _getClientHeight(int contextId, int targetId) {
    KrakenController controller = KrakenController.getControllerOfJSContextId(contextId);
    EventTarget target = controller.view.getEventTargetById(targetId);
    if (target is Element) {
      controller.view.getRootRenderObject().owner.flushLayout();
      return target.renderBoxModel.clientHeight;
    }
    return 0.0;
  }

  static double _getClientLeft(int contextId, int targetId) {
    KrakenController controller = KrakenController.getControllerOfJSContextId(contextId);
    EventTarget target = controller.view.getEventTargetById(targetId);
    if (target is Element) {
      controller.view.getRootRenderObject().owner.flushLayout();
      return target.renderBoxModel.borderLeft;
    }
    return 0.0;
  }

  static double _getClientTop(int contextId, int targetId) {
    KrakenController controller = KrakenController.getControllerOfJSContextId(contextId);
    EventTarget target = controller.view.getEventTargetById(targetId);
    if (target is Element) {
      controller.view.getRootRenderObject().owner.flushLayout();
      return target.renderBoxModel.borderTop;
    }
    return 0.0;
  }

  static double _getScrollTop(int contextId, int targetId) {
    KrakenController controller = KrakenController.getControllerOfJSContextId(contextId);
    EventTarget target = controller.view.getEventTargetById(targetId);
    if (target is Element) {
      return target.scrollTop;
    }
    return 0.0;
  }

  static double _getScrollLeft(int contextId, int targetId) {
    KrakenController controller = KrakenController.getControllerOfJSContextId(contextId);
    EventTarget target = controller.view.getEventTargetById(targetId);
    if (target is Element) {
      return target.scrollLeft;
    }
    return 0.0;
  }

  static double _getScrollWidth(int contextId, int targetId) {
    KrakenController controller = KrakenController.getControllerOfJSContextId(contextId);
    EventTarget target = controller.view.getEventTargetById(targetId);
    if (target is Element) {
      return target.scrollWidth;
    }
    return 0.0;
  }

  static double _getScrollHeight(int contextId, int targetId) {
    KrakenController controller = KrakenController.getControllerOfJSContextId(contextId);
    EventTarget target = controller.view.getEventTargetById(targetId);
    if (target is Element) {
      return target.scrollHeight;
    }
    return 0.0;
  }

  static Pointer<NativeBoundingClientRect> _getBoundingClientRect(int contextId, int targetId) {
    KrakenController controller = KrakenController.getControllerOfJSContextId(contextId);
    EventTarget target = controller.view.getEventTargetById(targetId);
    if (target is Element) {
      return target.boundingClientRect;
    }
    return nullptr;
  }

  static void _click(int contextId, int targetId) {
    KrakenController controller = KrakenController.getControllerOfJSContextId(contextId);
    EventTarget target = controller.view.getEventTargetById(targetId);
    if (target is Element) {
      target.click();
    }
  }

  static void _scroll(int contextId, int targetId, int x, int y) {
    KrakenController controller = KrakenController.getControllerOfJSContextId(contextId);
    EventTarget target = controller.view.getEventTargetById(targetId);
    if (target is Element) {
      target.scroll(x, y);
    }
  }

  static void _scrollBy(int contextId, int targetId, int x, int y) {
    KrakenController controller = KrakenController.getControllerOfJSContextId(contextId);
    EventTarget target = controller.view.getEventTargetById(targetId);
    if (target is Element) {
      target.scroll(x, y, isScrollBy: true);
    }
  }

  void bindNativeMethods(Pointer<NativeElement> nativePtr) {
    if (nativePtr == nullptr) return;
    Pointer<NativeElement> nativeElement = nativePtr.cast<NativeElement>();
    nativeElement.ref.getOffsetLeft = nativeGetOffsetLeft;
    nativeElement.ref.getOffsetTop = nativeGetOffsetTop;
    nativeElement.ref.getOffsetWidth = nativeGetOffsetWidth;
    nativeElement.ref.getOffsetHeight = nativeGetOffsetHeight;
    nativeElement.ref.getClientWidth = nativeGetClientWidth;
    nativeElement.ref.getClientHeight = nativeGetClientHeight;
    nativeElement.ref.getClientTop = nativeGetClientTop;
    nativeElement.ref.getClientLeft = nativeGetClientLeft;
    nativeElement.ref.getScrollTop = nativeGetScrollTop;
    nativeElement.ref.getScrollLeft = nativeGetScrollLeft;
    nativeElement.ref.getScrollWidth = nativeGetScrollWidth;
    nativeElement.ref.getScrollHeight = nativeGetScrollHeight;
    nativeElement.ref.getBoundingClientRect = nativeGetBoundingClientRect;
    nativeElement.ref.click = nativeClick;
    nativeElement.ref.scroll = nativeScroll;
    nativeElement.ref.scrollBy = nativeScrollBy;
  }
}
