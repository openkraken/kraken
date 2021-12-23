/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "window.h"
#include "bindings/qjs/dom/events/.gen/message_event.h"
#include "bindings/qjs/qjs_patch.h"
#include "dart_methods.h"

namespace kraken::binding::qjs {

std::once_flag kWindowInitOnceFlag;

void bindWindow(std::unique_ptr<JSContext>& context) {
  // Set globalThis and Window's prototype to EventTarget's prototype to support EventTarget methods in global.
  auto* windowConstructor = new Window(context.get());
  JS_SetPrototype(context->ctx(), context->global(), windowConstructor->prototype());
  context->defineGlobalProperty("Window", windowConstructor->jsObject);

  auto* window = new WindowInstance(windowConstructor);
  JS_SetOpaque(context->global(), window);
  context->defineGlobalProperty("__window__", window->jsObject);
}

JSClassID Window::kWindowClassId{0};

Window::Window(JSContext* context) : EventTarget(context, "Window") {
  std::call_once(kWindowInitOnceFlag, []() { JS_NewClassID(&kWindowClassId); });
  JS_SetPrototype(m_ctx, m_prototypeObject, EventTarget::instance(m_context)->prototype());
}

JSClassID Window::classId() {
  return 1;
}

JSValue Window::open(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto window = static_cast<WindowInstance*>(JS_GetOpaque(this_val, Window::classId()));
  NativeValue arguments[] = {jsValueToNativeValue(ctx, argv[0])};
  return window->callNativeMethods("open", 1, arguments);
}
JSValue Window::scrollTo(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto window = static_cast<WindowInstance*>(JS_GetOpaque(this_val, Window::classId()));
  NativeValue arguments[] = {jsValueToNativeValue(ctx, argv[0]), jsValueToNativeValue(ctx, argv[1])};
  return window->callNativeMethods("scroll", 2, arguments);
}
JSValue Window::scrollBy(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto window = static_cast<WindowInstance*>(JS_GetOpaque(this_val, Window::classId()));
  NativeValue arguments[] = {jsValueToNativeValue(ctx, argv[0]), jsValueToNativeValue(ctx, argv[1])};
  return window->callNativeMethods("scrollBy", 2, arguments);
}

JSValue Window::postMessage(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  JSValue messageValue = argv[0];
  JSValue originValue = argv[1];
  JSValue globalObjectValue = JS_GetGlobalObject(ctx);
  auto* window = static_cast<WindowInstance*>(JS_GetOpaque(globalObjectValue, Window::classId()));

  JSValue messageEventInitValue = JS_NewObject(ctx);
  JS_SetPropertyStr(ctx, messageEventInitValue, "data", JS_DupValue(ctx, messageValue));
  JS_SetPropertyStr(ctx, originValue, "origin", JS_DupValue(ctx, originValue));

  JSValue messageEventValue = JS_CallConstructor(ctx, MessageEvent::instance(window->m_context)->jsObject, 1, &messageEventInitValue);
  auto* event = static_cast<MessageEventInstance*>(JS_GetOpaque(messageEventValue, Event::kEventClassID));
  window->dispatchEvent(event);

  JS_FreeValue(ctx, messageEventValue);
  JS_FreeValue(ctx, messageEventInitValue);
  JS_FreeValue(ctx, globalObjectValue);
  return JS_NULL;
}

IMPL_PROPERTY_GETTER(Window, devicePixelRatio)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  if (getDartMethod()->devicePixelRatio == nullptr) {
    return JS_ThrowTypeError(ctx, "Failed to read devicePixelRatio: dart method (devicePixelRatio) is not register.");
  }
  auto* context = static_cast<JSContext*>(JS_GetContextOpaque(ctx));

  double devicePixelRatio = getDartMethod()->devicePixelRatio(context->getContextId());
  return JS_NewFloat64(ctx, devicePixelRatio);
}

IMPL_PROPERTY_GETTER(Window, colorScheme)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  if (getDartMethod()->platformBrightness == nullptr) {
    return JS_ThrowTypeError(ctx, "Failed to read colorScheme: dart method (platformBrightness) not register.");
  }
  auto* context = static_cast<JSContext*>(JS_GetContextOpaque(ctx));

  const NativeString* code = getDartMethod()->platformBrightness(context->getContextId());
  return JS_NewUnicodeString(context->runtime(), ctx, code->string, code->length);
}

IMPL_PROPERTY_GETTER(Window, __location__)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* window = static_cast<WindowInstance*>(JS_GetOpaque(this_val, 1));
  if (window == nullptr)
    return JS_UNDEFINED;
  return JS_DupValue(ctx, window->m_location.value());
}

IMPL_PROPERTY_GETTER(Window, location)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* window = static_cast<WindowInstance*>(JS_GetOpaque(this_val, 1));
  return JS_GetPropertyStr(ctx, window->m_context->global(), "location");
}

IMPL_PROPERTY_GETTER(Window, window)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  return JS_GetGlobalObject(ctx);
}

IMPL_PROPERTY_GETTER(Window, parent)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  return JS_GetGlobalObject(ctx);
}

IMPL_PROPERTY_GETTER(Window, scrollX)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* window = static_cast<WindowInstance*>(JS_GetOpaque(this_val, 1));
  return window->callNativeMethods("scrollX", 0, nullptr);
}

IMPL_PROPERTY_GETTER(Window, scrollY)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* window = static_cast<WindowInstance*>(JS_GetOpaque(this_val, 1));
  return window->callNativeMethods("scrollY", 0, nullptr);
}

IMPL_PROPERTY_GETTER(Window, onerror)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* window = static_cast<WindowInstance*>(JS_GetOpaque(this_val, 1));
  return JS_DupValue(ctx, window->onerror);
}
IMPL_PROPERTY_SETTER(Window, onerror)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* window = static_cast<WindowInstance*>(JS_GetOpaque(this_val, 1));
  JSValue eventString = JS_NewString(ctx, "onerror");
  JSString* p = JS_VALUE_GET_STRING(eventString);
  window->setPropertyHandler(p, argv[0]);

  if (!JS_IsNull(window->onerror)) {
    JS_FreeValue(ctx, window->onerror);
  }

  window->onerror = JS_DupValue(ctx, argv[0]);
  JS_FreeValue(ctx, eventString);
  return JS_NULL;
}

IMPL_PROPERTY_GETTER(Window, self)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  return JS_GetGlobalObject(ctx);
}

WindowInstance::WindowInstance(Window* window) : EventTargetInstance(window, Window::kWindowClassId, "window", WINDOW_TARGET_ID) {
  if (getDartMethod()->initWindow != nullptr) {
    getDartMethod()->initWindow(context()->getContextId(), nativeEventTarget);
  }
  m_context->m_window = this;
}

void WindowInstance::gcMark(JSRuntime* rt, JSValue val, JS_MarkFunc* mark_func) {
  EventTargetInstance::gcMark(rt, val, mark_func);

  // Should check object is already inited before gc mark.
  if (JS_IsObject(onerror))
    JS_MarkValue(rt, onerror, mark_func);
}

}  // namespace kraken::binding::qjs
