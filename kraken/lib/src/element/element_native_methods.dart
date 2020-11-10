import 'package:kraken/element.dart';
import 'package:kraken/launcher.dart';
import 'package:kraken/bridge.dart';
import 'dart:ffi';

final Pointer<NativeFunction<Native_GetOffsetLeft>> nativeGetOffsetLeft = Pointer.fromFunction(ElementNativeMethods.getOffsetLeft, 0.0);
final Pointer<NativeFunction<Native_GetOffsetTop>> nativeGetOffsetTop = Pointer.fromFunction(ElementNativeMethods.getOffsetTop, 0.0);
final Pointer<NativeFunction<Native_GetOffsetWidth>> nativeGetOffsetWidth = Pointer.fromFunction(ElementNativeMethods.getOffsetWidth, 0.0);
final Pointer<NativeFunction<Native_GetOffsetHeight>> nativeGetOffsetHeight = Pointer.fromFunction(ElementNativeMethods.getOffsetHeight, 0.0);
final Pointer<NativeFunction<Native_GetClientWidth>> nativeGetClientWidth = Pointer.fromFunction(ElementNativeMethods.getClientWidth, 0.0);
final Pointer<NativeFunction<Native_GetClientHeight>> nativeGetClientHeight = Pointer.fromFunction(ElementNativeMethods.getClientHeight, 0.0);
final Pointer<NativeFunction<Native_GetClientTop>> nativeGetClientTop = Pointer.fromFunction(ElementNativeMethods.getClientTop, 0.0);
final Pointer<NativeFunction<Native_GetClientLeft>> nativeGetClientLeft = Pointer.fromFunction(ElementNativeMethods.getOffsetLeft, 0.0);
final Pointer<NativeFunction<Native_GetScrollTop>> nativeGetScrollTop = Pointer.fromFunction(ElementNativeMethods.getScrollTop, 0.0);
final Pointer<NativeFunction<Native_GetScrollLeft>> nativeGetScrollLeft = Pointer.fromFunction(ElementNativeMethods.getScrollLeft, 0.0);
final Pointer<NativeFunction<Native_GetScrollWidth>> nativeGetScrollWidth = Pointer.fromFunction(ElementNativeMethods.getScrollWidth, 0.0);
final Pointer<NativeFunction<Native_GetScrollHeight>> nativeGetScrollHeight = Pointer.fromFunction(ElementNativeMethods.getScrollHeight, 0.0);
final Pointer<NativeFunction<Native_GetBoundingClientRect>> nativeGetBoundingClientRect = Pointer.fromFunction(ElementNativeMethods.getBoundingClientRect);

mixin ElementNativeMethods on Node {
  static double getOffsetLeft(int contextId, int targetId) {
    KrakenController controller = KrakenController.getControllerOfJSContextId(contextId);
    EventTarget target = controller.view.getEventTargetById(targetId);
    if (target is Element) {
      controller.view.getRootRenderObject().owner.flushLayout();
      return target.getOffsetX();
    }
    return 0.0;
  }

  static double getOffsetTop(int contextId, int targetId) {
    KrakenController controller = KrakenController.getControllerOfJSContextId(contextId);
    EventTarget target = controller.view.getEventTargetById(targetId);
    if (target is Element) {
      controller.view.getRootRenderObject().owner.flushLayout();
      return target.getOffsetY();
    }
    return 0.0;
  }

  static double getOffsetWidth(int contextId, int targetId) {
    KrakenController controller = KrakenController.getControllerOfJSContextId(contextId);
    EventTarget target = controller.view.getEventTargetById(targetId);
    if (target is Element) {
      controller.view.getRootRenderObject().owner.flushLayout();
      return target.renderBoxModel.hasSize ? target.renderBoxModel.size.width : 0;
    }
    return 0.0;
  }

  static double getOffsetHeight(int contextId, int targetId) {
    KrakenController controller = KrakenController.getControllerOfJSContextId(contextId);
    EventTarget target = controller.view.getEventTargetById(targetId);
    if (target is Element) {
      controller.view.getRootRenderObject().owner.flushLayout();
      return target.renderBoxModel.hasSize ? target.renderBoxModel.size.height : 0;
    }
    return 0.0;
  }

  static double getClientWidth(int contextId, int targetId) {
    KrakenController controller = KrakenController.getControllerOfJSContextId(contextId);
    EventTarget target = controller.view.getEventTargetById(targetId);
    if (target is Element) {
      controller.view.getRootRenderObject().owner.flushLayout();
      return target.renderLayoutBox.clientWidth;
    }
    return 0.0;
  }

  static double getClientHeight(int contextId, int targetId) {
    KrakenController controller = KrakenController.getControllerOfJSContextId(contextId);
    EventTarget target = controller.view.getEventTargetById(targetId);
    if (target is Element) {
      controller.view.getRootRenderObject().owner.flushLayout();
      return target.renderLayoutBox.clientHeight;
    }
    return 0.0;
  }

  static double getClientLeft(int contextId, int targetId) {
    KrakenController controller = KrakenController.getControllerOfJSContextId(contextId);
    EventTarget target = controller.view.getEventTargetById(targetId);
    if (target is Element) {
      controller.view.getRootRenderObject().owner.flushLayout();
      return target.renderLayoutBox.borderLeft;
    }
    return 0.0;
  }

  static double getClientTop(int contextId, int targetId) {
    KrakenController controller = KrakenController.getControllerOfJSContextId(contextId);
    EventTarget target = controller.view.getEventTargetById(targetId);
    if (target is Element) {
      controller.view.getRootRenderObject().owner.flushLayout();
      return target.renderLayoutBox.borderTop;
    }
    return 0.0;
  }

  static double getScrollTop(int contextId, int targetId) {
    KrakenController controller = KrakenController.getControllerOfJSContextId(contextId);
    EventTarget target = controller.view.getEventTargetById(targetId);
    if (target is Element) {
      return target.scrollTop;
    }
    return 0.0;
  }

  static double getScrollLeft(int contextId, int targetId) {
    KrakenController controller = KrakenController.getControllerOfJSContextId(contextId);
    EventTarget target = controller.view.getEventTargetById(targetId);
    if (target is Element) {
      return target.scrollLeft;
    }
    return 0.0;
  }

  static double getScrollWidth(int contextId, int targetId) {
    KrakenController controller = KrakenController.getControllerOfJSContextId(contextId);
    EventTarget target = controller.view.getEventTargetById(targetId);
    if (target is Element) {
      return target.scrollWidth;
    }
    return 0.0;
  }

  static double getScrollHeight(int contextId, int targetId) {
    KrakenController controller = KrakenController.getControllerOfJSContextId(contextId);
    EventTarget target = controller.view.getEventTargetById(targetId);
    if (target is Element) {
      return target.scrollHeight;
    }
    return 0.0;
  }

  static Pointer<NativeBoundingClientRect> getBoundingClientRect(int contextId, int targetId) {
    KrakenController controller = KrakenController.getControllerOfJSContextId(contextId);
    EventTarget target = controller.view.getEventTargetById(targetId);
    if (target is Element) {
      return target.boundingClientRect;
    }
    return nullptr;
  }

  void bindNativeMethods() {
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
  }
}
