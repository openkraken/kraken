/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "window.h"
#include "bindings/qjs/dom/document.h"
#include "bindings/qjs/dom/events/.gen/message_event.h"
#include "bindings/qjs/garbage_collected.h"
#include "bindings/qjs/qjs_patch.h"
#include "dart_methods.h"

namespace kraken::binding::qjs {

std::once_flag kWindowInitOnceFlag;

void bindWindow(std::unique_ptr<ExecutionContext>& context) {
  // Set globalThis and Window's prototype to EventTarget's prototype to support EventTarget methods in global.
  auto* windowConstructor = new Window(context.get());
  JS_SetPrototype(context->ctx(), context->global(), windowConstructor->prototype());
  context->defineGlobalProperty("Window", windowConstructor->jsObject);

  auto* window = new WindowInstance(windowConstructor);
  JS_SetOpaque(context->global(), window);
  context->defineGlobalProperty("__window__", window->jsObject);
}

JSClassID Window::kWindowClassId{0};

Window::Window(ExecutionContext* context) : EventTarget(context, "Window") {
  std::call_once(kWindowInitOnceFlag, []() { JS_NewClassID(&kWindowClassId); });
  JS_SetPrototype(m_ctx, m_prototypeObject, EventTarget::instance(m_context)->prototype());
}

JSClassID Window::classId() {
  return 1;
}

JSValue Window::open(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto window = static_cast<WindowInstance*>(JS_GetOpaque(this_val, Window::classId()));
  NativeValue arguments[] = {jsValueToNativeValue(ctx, argv[0])};
  return window->callNativeMethods("open", 1, arguments);
}
JSValue Window::scrollTo(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
#if FLUTTER_BACKEND
  auto window = static_cast<WindowInstance*>(JS_GetOpaque(this_val, Window::classId()));
  NativeValue arguments[] = {jsValueToNativeValue(ctx, argv[0]), jsValueToNativeValue(ctx, argv[1])};
  return window->callNativeMethods("scroll", 2, arguments);
#else
  return JS_UNDEFINED;
#endif
}
JSValue Window::scrollBy(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto window = static_cast<WindowInstance*>(JS_GetOpaque(this_val, Window::classId()));
  NativeValue arguments[] = {jsValueToNativeValue(ctx, argv[0]), jsValueToNativeValue(ctx, argv[1])};
  return window->callNativeMethods("scrollBy", 2, arguments);
}

JSValue Window::postMessage(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
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

JSValue Window::requestAnimationFrame(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  if (argc <= 0) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'requestAnimationFrame': 1 argument required, but only 0 present.");
  }

  auto* context = static_cast<ExecutionContext*>(JS_GetContextOpaque(ctx));
  auto window = static_cast<WindowInstance*>(JS_GetOpaque(context->global(), Window::classId()));

  JSValue callbackValue = argv[0];

  if (!JS_IsObject(callbackValue)) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'requestAnimationFrame': parameter 1 (callback) must be a function.");
  }

  if (!JS_IsFunction(ctx, callbackValue)) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'requestAnimationFrame': parameter 1 (callback) must be a function.");
  }

  // Flutter backend implements check
#if FLUTTER_BACKEND
  if (getDartMethod()->flushUICommand == nullptr) {
    return JS_ThrowTypeError(ctx, "Failed to execute '__kraken_flush_ui_command__': dart method (flushUICommand) is not registered.");
  }
  // Flush all pending ui messages.
  getDartMethod()->flushUICommand();

  if (getDartMethod()->requestAnimationFrame == nullptr) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'requestAnimationFrame': dart method (requestAnimationFrame) is not registered.");
  }
#endif

  auto* frameCallback = makeGarbageCollected<FrameCallback>(JS_DupValue(ctx, callbackValue))->initialize(ctx, &FrameCallback::classId);

  int32_t requestId = window->document()->requestAnimationFrame(frameCallback);

  // `-1` represents some error occurred.
  if (requestId == -1) {
    return JS_ThrowTypeError(ctx,
                             "Failed to execute 'requestAnimationFrame': dart method (requestAnimationFrame) executed "
                             "with unexpected error.");
  }

  return JS_NewUint32(ctx, requestId);
}

JSValue Window::cancelAnimationFrame(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  if (argc <= 0) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'cancelAnimationFrame': 1 argument required, but only 0 present.");
  }

  auto context = static_cast<ExecutionContext*>(JS_GetContextOpaque(ctx));
  auto window = static_cast<WindowInstance*>(JS_GetOpaque(context->global(), Window::classId()));

  JSValue requestIdValue = argv[0];
  if (!JS_IsNumber(requestIdValue)) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'cancelAnimationFrame': parameter 1 (timer) is not a timer kind.");
  }

  int32_t id;
  JS_ToInt32(ctx, &id, requestIdValue);

  if (getDartMethod()->cancelAnimationFrame == nullptr) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'cancelAnimationFrame': dart method (cancelAnimationFrame) is not registered.");
  }

  window->document()->cancelAnimationFrame(id);

  return JS_NULL;
}

IMPL_PROPERTY_GETTER(Window, devicePixelRatio)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  if (getDartMethod()->devicePixelRatio == nullptr) {
    return JS_ThrowTypeError(ctx, "Failed to read devicePixelRatio: dart method (devicePixelRatio) is not register.");
  }
  auto* context = static_cast<ExecutionContext*>(JS_GetContextOpaque(ctx));

  double devicePixelRatio = getDartMethod()->devicePixelRatio(context->getContextId());
  return JS_NewFloat64(ctx, devicePixelRatio);
}

IMPL_PROPERTY_GETTER(Window, colorScheme)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  if (getDartMethod()->platformBrightness == nullptr) {
    return JS_ThrowTypeError(ctx, "Failed to read colorScheme: dart method (platformBrightness) not register.");
  }
  auto* context = static_cast<ExecutionContext*>(JS_GetContextOpaque(ctx));

  const NativeString* code = getDartMethod()->platformBrightness(context->getContextId());
  return JS_NewUnicodeString(context->runtime(), ctx, code->string, code->length);
}

IMPL_PROPERTY_GETTER(Window, __location__)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* window = static_cast<WindowInstance*>(JS_GetOpaque(this_val, 1));
  if (window == nullptr)
    return JS_UNDEFINED;
  return JS_DupValue(ctx, window->m_location.value());
}

IMPL_PROPERTY_GETTER(Window, location)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* window = static_cast<WindowInstance*>(JS_GetOpaque(this_val, 1));
  return JS_GetPropertyStr(ctx, window->m_context->global(), "location");
}

IMPL_PROPERTY_GETTER(Window, window)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  return JS_GetGlobalObject(ctx);
}

IMPL_PROPERTY_GETTER(Window, parent)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  return JS_GetGlobalObject(ctx);
}

IMPL_PROPERTY_GETTER(Window, scrollX)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* window = static_cast<WindowInstance*>(JS_GetOpaque(this_val, 1));
  return window->callNativeMethods("scrollX", 0, nullptr);
}

IMPL_PROPERTY_GETTER(Window, scrollY)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* window = static_cast<WindowInstance*>(JS_GetOpaque(this_val, 1));
  return window->callNativeMethods("scrollY", 0, nullptr);
}

IMPL_PROPERTY_GETTER(Window, onerror)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* window = static_cast<WindowInstance*>(JS_GetOpaque(this_val, 1));
  return JS_DupValue(ctx, window->onerror);
}
IMPL_PROPERTY_SETTER(Window, onerror)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* window = static_cast<WindowInstance*>(JS_GetOpaque(this_val, 1));
  JSValue eventString = JS_NewString(ctx, "onerror");
  JSString* p = JS_VALUE_GET_STRING(eventString);
  JSValue onerrorHandler = argv[0];
  window->setAttributesEventHandler(p, onerrorHandler);

  if (!JS_IsNull(window->onerror)) {
    JS_FreeValue(ctx, window->onerror);
  }

  window->onerror = onerrorHandler;
  JS_FreeValue(ctx, eventString);
  return JS_NULL;
}

IMPL_PROPERTY_GETTER(Window, self)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  return JS_GetGlobalObject(ctx);
}

WindowInstance::WindowInstance(Window* window) : EventTargetInstance(window, Window::kWindowClassId, "window", WINDOW_TARGET_ID) {
  if (getDartMethod()->initWindow != nullptr) {
    getDartMethod()->initWindow(context()->getContextId(), nativeEventTarget);
  }
  m_context->m_window = this;
}

void WindowInstance::trace(JSRuntime* rt, JSValue val, JS_MarkFunc* mark_func) {
  EventTargetInstance::trace(rt, val, mark_func);
}

DocumentInstance* WindowInstance::document() {
  return m_context->m_document;
}

}  // namespace kraken::binding::qjs
