/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "window.h"
#include "dart_methods.h"
#include "bindings/qjs/qjs_patch.h"

namespace kraken::binding::qjs {

std::once_flag kWindowInitOnceFlag;

OBJECT_INSTANCE_IMPL(Window);

void bindWindow(std::unique_ptr<JSContext> &context) {
  // Set globalThis and Window's prototype to EventTarget's prototype to support EventTarget methods in global.
  auto *windowConstructor = new Window(context.get());
  JS_SetPrototype(context->ctx(), context->global(), windowConstructor->prototype());
  context->defineGlobalProperty("Window", windowConstructor->classObject);

  auto *window = new WindowInstance(windowConstructor);
  JS_SetOpaque(context->global(), window);
}

JSClassID Window::kWindowClassId{0};

Window::Window(JSContext *context) : EventTarget(context, "Window") {
  std::call_once(kWindowInitOnceFlag, []() {
    JS_NewClassID(&kWindowClassId);
  });
}

JSClassID Window::classId() {
  return kWindowClassId;
}

JSValue Window::open(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  JSValue &url = argv[0];
  auto window = static_cast<WindowInstance *>(JS_GetOpaque(this_val, Window::classId()));
  NativeValue arguments[] = {
    jsValueToNativeValue(ctx, argv[0])
  };
  return window->callNativeMethods("open", 1, arguments);
}
JSValue Window::scrollTo(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  JSValue &x = argv[0];
  JSValue &y = argv[1];
  auto window = static_cast<WindowInstance *>(JS_GetOpaque(this_val, Window::classId()));
  NativeValue arguments[] = {
    jsValueToNativeValue(ctx, argv[0]),
    jsValueToNativeValue(ctx, argv[1])
  };
  return window->callNativeMethods("scroll", 2, arguments);
}
JSValue Window::scrollBy(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  JSValue &x = argv[0];
  JSValue &y = argv[1];
  auto window = static_cast<WindowInstance *>(JS_GetOpaque(this_val, Window::classId()));
  NativeValue arguments[] = {
    jsValueToNativeValue(ctx, argv[0]),
    jsValueToNativeValue(ctx, argv[1])
  };
  return window->callNativeMethods("scrollBy", 2, arguments);
}

PROP_GETTER(Window, devicePixelRatio)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  if (getDartMethod()->devicePixelRatio == nullptr) {
    return JS_ThrowTypeError(ctx, "Failed to read devicePixelRatio: dart method (devicePixelRatio) is not register.");
  }
  auto *context = static_cast<JSContext *>(JS_GetContextOpaque(ctx));

  double devicePixelRatio = getDartMethod()->devicePixelRatio(context->getContextId());
  return JS_NewFloat64(ctx, devicePixelRatio);
}
PROP_SETTER(Window, devicePixelRatio)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  return JS_NULL;
}

PROP_GETTER(Window, colorScheme)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  if (getDartMethod()->platformBrightness == nullptr) {
    return JS_ThrowTypeError(ctx, "Failed to read colorScheme: dart method (platformBrightness) not register.");
  }
  auto *context = static_cast<JSContext *>(JS_GetContextOpaque(ctx));

  const NativeString *code = getDartMethod()->platformBrightness(context->getContextId());
  return JS_NewUnicodeString(context->runtime(), ctx, code->string, code->length);
}
PROP_SETTER(Window, colorScheme)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  return JS_NULL;
}

PROP_GETTER(Window, __location__)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  auto *window = static_cast<WindowInstance *>(JS_GetOpaque(this_val, 1));
  if (window == nullptr) return JS_UNDEFINED;
  return window->m_location->jsObject;
}
PROP_SETTER(Window, __location__)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  return JS_NULL;
}

PROP_GETTER(Window, window)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  auto *window = static_cast<WindowInstance *>(JS_GetOpaque(this_val, Window::classId()));
  if (window == nullptr) return JS_UNDEFINED;
  return window->instanceObject;
}
PROP_SETTER(Window, window)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  return JS_NULL;
}
PROP_GETTER(Window, parent)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  auto *window = static_cast<WindowInstance *>(JS_GetOpaque(this_val, Window::classId()));
  if (window == nullptr) return JS_UNDEFINED;
  return window->instanceObject;
}
PROP_SETTER(Window, parent)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  return JS_NULL;
}

PROP_GETTER(Window, history)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  auto *context = static_cast<JSContext *>(JS_GetContextOpaque(ctx));
  return JS_GetPropertyStr(ctx, context->global(), "__history__");
}
PROP_SETTER(Window, history)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  return JS_NULL;
}

PROP_GETTER(Window, scrollX)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  auto *window = static_cast<WindowInstance *>(JS_GetOpaque(this_val, 1));
  return window->callNativeMethods("scrollX", 0, nullptr);
}
PROP_SETTER(Window, scrollX)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  return JS_NULL;
}

PROP_GETTER(Window, scrollY)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  auto *window = static_cast<WindowInstance *>(JS_GetOpaque(this_val, 1));
  return window->callNativeMethods("scrollY", 0, nullptr);
}
PROP_SETTER(Window, scrollY)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  return JS_NULL;
}

WindowInstance::WindowInstance(Window *window) : EventTargetInstance(window, Window::classId(), "window") {
  if (getDartMethod()->initWindow != nullptr) {
    getDartMethod()->initWindow(context()->getContextId(), &nativeEventTarget);
  }
  m_context->m_window = this;
  m_location = new Location(m_context);
}

}
