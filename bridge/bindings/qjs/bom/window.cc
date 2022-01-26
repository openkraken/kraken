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

void bindWindow(std::unique_ptr<ExecutionContext>& context) {
  auto* contextData = context->contextData();
  JSValue classObject = contextData->constructorForType(&windowTypeInfo);
  JSValue prototypeObject = contextData->prototypeForType(&windowTypeInfo);

  // Install methods.
  INSTALL_FUNCTION(Window, prototypeObject, open, 1);
  installFunctionProperty(context.get(), prototypeObject, "scroll", Window::m_scrollTo_, 2);
  INSTALL_FUNCTION(Window, prototypeObject, scrollTo, 2);
  INSTALL_FUNCTION(Window, prototypeObject, scrollBy, 2);
  INSTALL_FUNCTION(Window, prototypeObject, postMessage, 3);
  INSTALL_FUNCTION(Window, prototypeObject, requestAnimationFrame, 1);
  INSTALL_FUNCTION(Window, prototypeObject, cancelAnimationFrame, 1);

  // Install Getter and Setter properties.
  INSTALL_READONLY_PROPERTY(Window, prototypeObject, devicePixelRatio);
  INSTALL_READONLY_PROPERTY(Window, prototypeObject, colorScheme);
  INSTALL_READONLY_PROPERTY(Window, prototypeObject, __location__);
  INSTALL_READONLY_PROPERTY(Window, prototypeObject, location);
  INSTALL_READONLY_PROPERTY(Window, prototypeObject, window);
  INSTALL_READONLY_PROPERTY(Window, prototypeObject, parent);
  INSTALL_READONLY_PROPERTY(Window, prototypeObject, scrollX);
  INSTALL_READONLY_PROPERTY(Window, prototypeObject, scrollY);
  INSTALL_READONLY_PROPERTY(Window, prototypeObject, self);

  INSTALL_PROPERTY(Window, prototypeObject, onerror);

  // Set globalThis and Window's prototype to EventTarget's prototype to support EventTarget methods in global.
  JS_SetPrototype(context->ctx(), context->global(), prototypeObject);
  context->defineGlobalProperty("Window", classObject);

  // Hide window instance to global object, to get access to window when get property on globalObject.
  auto* window = makeGarbageCollected<Window>()->initialize<Window>(context->ctx(), &Window::classId);
  JS_SetOpaque(context->global(), window);
  context->defineGlobalProperty("__window__", window->toQuickJS());
}

IMPL_FUNCTION(Window, open)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto window = static_cast<Window*>(JS_GetOpaque(this_val, JSValueGetClassId(this_val)));
  NativeValue arguments[] = {jsValueToNativeValue(ctx, argv[0])};
  return window->callNativeMethods("open", 1, arguments);
}

IMPL_FUNCTION(Window, scrollTo)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
#if FLUTTER_BACKEND
  auto window = static_cast<WindowInstance*>(JS_GetOpaque(this_val, Window::classId()));
  NativeValue arguments[] = {jsValueToNativeValue(ctx, argv[0]), jsValueToNativeValue(ctx, argv[1])};
  return window->callNativeMethods("scroll", 2, arguments);
#else
  return JS_UNDEFINED;
#endif
}

IMPL_FUNCTION(Window, scrollBy)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto window = static_cast<Window*>(JS_GetOpaque(this_val, JSValueGetClassId(this_val)));
  NativeValue arguments[] = {jsValueToNativeValue(ctx, argv[0]), jsValueToNativeValue(ctx, argv[1])};
  return window->callNativeMethods("scrollBy", 2, arguments);
}

IMPL_FUNCTION(Window, postMessage)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  JSValue messageValue = argv[0];
  JSValue globalObjectValue = JS_GetGlobalObject(ctx);
  auto* window = static_cast<Window*>(JS_GetOpaque(globalObjectValue, JSValueGetClassId(this_val)));

  JSValue messageEventInitValue = JS_NewObject(ctx);

  // TODO: convert originValue to current src.
  JSValue messageOriginValue = JS_NewString(ctx, "");

  JS_SetPropertyStr(ctx, messageEventInitValue, "data", JS_DupValue(ctx, messageValue));
  JS_SetPropertyStr(ctx, messageEventInitValue, "origin", messageOriginValue);

  JSValue messageType = JS_NewString(ctx, "message");
  JSValue arguments[] = {messageType, messageEventInitValue};
  JSValue messageEventValue = JS_CallConstructor(ctx, MessageEvent::instance(window->m_context)->jsObject, 2, arguments);
  auto* event = static_cast<MessageEventInstance*>(JS_GetOpaque(messageEventValue, Event::kEventClassID));
  window->dispatchEvent(event);

  JS_FreeValue(ctx, messageType);
  JS_FreeValue(ctx, messageEventValue);
  JS_FreeValue(ctx, messageEventInitValue);
  JS_FreeValue(ctx, globalObjectValue);
  JS_FreeValue(ctx, messageOriginValue);
  return JS_NULL;
}

IMPL_FUNCTION(Window, requestAnimationFrame)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  if (argc <= 0) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'requestAnimationFrame': 1 argument required, but only 0 present.");
  }

  auto* context = static_cast<ExecutionContext*>(JS_GetContextOpaque(ctx));
  auto window = static_cast<Window*>(JS_GetOpaque(context->global(), JSValueGetClassId(this_val)));

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

  auto* frameCallback = makeGarbageCollected<FrameCallback>(JS_DupValue(ctx, callbackValue))->initialize<FrameCallback>(ctx, &FrameCallback::classId);

  int32_t requestId = window->document()->requestAnimationFrame(frameCallback);

  // `-1` represents some error occurred.
  if (requestId == -1) {
    return JS_ThrowTypeError(ctx,
                             "Failed to execute 'requestAnimationFrame': dart method (requestAnimationFrame) executed "
                             "with unexpected error.");
  }

  return JS_NewUint32(ctx, requestId);
}

IMPL_FUNCTION(Window, cancelAnimationFrame)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  if (argc <= 0) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'cancelAnimationFrame': 1 argument required, but only 0 present.");
  }

  auto context = static_cast<ExecutionContext*>(JS_GetContextOpaque(ctx));
  auto window = static_cast<Window*>(JS_GetOpaque(context->global(), JSValueGetClassId(this_val)));

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

Window* Window::create(JSContext* ctx) {
  auto* context = static_cast<ExecutionContext*>(JS_GetContextOpaque(ctx));
  JSValue prototype = context->contextData()->prototypeForType(&windowTypeInfo);

  auto* window = makeGarbageCollected<Window>()->initialize<Window>(ctx, &classId, nullptr);

  // Let window inherit Window prototype methods.
  JS_SetPrototype(ctx, window->toQuickJS(), prototype);

  return window;
}

Document* Window::document() {
  return context()->document();
}

Window::Window() {
  if (getDartMethod()->initWindow != nullptr) {
    getDartMethod()->initWindow(context()->getContextId(), nativeEventTarget);
  }

  m_location = makeGarbageCollected<Location>()->initialize<Location>(m_ctx, &Location::classId);
}

void Window::trace(JSRuntime* rt, JSValue val, JS_MarkFunc* mark_func) const {
  EventTarget::trace(rt, val, mark_func);
  JS_MarkValue(rt, onerror, mark_func);
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
  auto* window = static_cast<Window*>(JS_GetOpaque(this_val, JSValueGetClassId(this_val)));
  if (window == nullptr)
    return JS_UNDEFINED;
  return JS_DupValue(ctx, window->m_location->toQuickJS());
}

IMPL_PROPERTY_GETTER(Window, location)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* window = static_cast<Window*>(JS_GetOpaque(this_val, 1));
  return JS_GetPropertyStr(ctx, window->context()->global(), "location");
}

IMPL_PROPERTY_GETTER(Window, window)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  return JS_GetGlobalObject(ctx);
}

IMPL_PROPERTY_GETTER(Window, parent)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  return JS_GetGlobalObject(ctx);
}

IMPL_PROPERTY_GETTER(Window, scrollX)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* window = static_cast<Window*>(JS_GetOpaque(this_val, 1));
  return window->callNativeMethods("scrollX", 0, nullptr);
}

IMPL_PROPERTY_GETTER(Window, scrollY)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* window = static_cast<Window*>(JS_GetOpaque(this_val, 1));
  return window->callNativeMethods("scrollY", 0, nullptr);
}

IMPL_PROPERTY_GETTER(Window, onerror)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* window = static_cast<Window*>(JS_GetOpaque(this_val, 1));
  return JS_DupValue(ctx, window->onerror);
}
IMPL_PROPERTY_SETTER(Window, onerror)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* window = static_cast<Window*>(JS_GetOpaque(this_val, 1));
  JSValue eventString = JS_NewString(ctx, "onerror");
  JSString* p = JS_VALUE_GET_STRING(eventString);
  JSValue onerrorHandler = argv[0];
  window->setAttributesEventHandler(p, onerrorHandler);

  if (!JS_IsNull(window->onerror)) {
    JS_FreeValue(ctx, window->onerror);
  }

  window->onerror = JS_DupValue(ctx, onerrorHandler);
  JS_FreeValue(ctx, eventString);
  return JS_NULL;
}

IMPL_PROPERTY_GETTER(Window, self)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  return JS_GetGlobalObject(ctx);
}

}  // namespace kraken::binding::qjs
