/*
 * Copyright (C) 2021-present The Kraken authors. All rights reserved.
 */

#include "window.h"
#include "binding_call_methods.h"
#include "bindings/qjs/cppgc/garbage_collected.h"
#include "core/events/message_event.h"
#include "event_type_names.h"
#include "foundation/native_value_converter.h"

namespace kraken {

Window::Window(ExecutingContext* context) : EventTargetWithInlineData(context) {}

Window* Window::open(ExceptionState& exception_state) {
  return this;
}

Window* Window::open(const AtomicString& url, ExceptionState& exception_state) {
  const NativeValue args[] = {
    NativeValueConverter<NativeTypeString>::ToNativeValue(url.ToNativeString().release()),
  };
  InvokeBindingMethod(binding_call_methods::kopen, 1, args, exception_state);
}

void Window::scroll(ExceptionState& exception_state) {
  return scroll(0, 0, exception_state);
}

void Window::scroll(double x, double y, ExceptionState& exception_state) {
  const NativeValue args[] = {
      NativeValueConverter<NativeTypeDouble>::ToNativeValue(x),
      NativeValueConverter<NativeTypeDouble>::ToNativeValue(y),
  };
  InvokeBindingMethod(binding_call_methods::kscroll, 2, args, exception_state);
}

void Window::scroll(const std::shared_ptr<ScrollToOptions>& options, ExceptionState& exception_state) {
  const NativeValue args[] = {
      NativeValueConverter<NativeTypeDouble>::ToNativeValue(options->left()),
      NativeValueConverter<NativeTypeDouble>::ToNativeValue(options->top()),
  };
  InvokeBindingMethod(binding_call_methods::kscroll, 2, args, exception_state);
}

void Window::scrollBy(ExceptionState& exception_state) {
  return scrollBy(0, 0, exception_state);
}

void Window::scrollBy(double x, double y, ExceptionState& exception_state) {
  const NativeValue args[] = {
      NativeValueConverter<NativeTypeDouble>::ToNativeValue(x),
      NativeValueConverter<NativeTypeDouble>::ToNativeValue(y),
  };
  InvokeBindingMethod(binding_call_methods::kscrollBy, 2, args, exception_state);
}

void Window::scrollBy(const std::shared_ptr<ScrollToOptions>& options, ExceptionState& exception_state) {
  const NativeValue args[] = {
      NativeValueConverter<NativeTypeDouble>::ToNativeValue(options->left()),
      NativeValueConverter<NativeTypeDouble>::ToNativeValue(options->top()),
  };
  InvokeBindingMethod(binding_call_methods::kscrollBy, 2, args, exception_state);
}

void Window::scrollTo(ExceptionState& exception_state) {
  return scroll(exception_state);
}

void Window::scrollTo(double x, double y, ExceptionState& exception_state) {
  return scroll(x, y, exception_state);
}

void Window::scrollTo(const std::shared_ptr<ScrollToOptions>& options, ExceptionState& exception_state) {
  return scroll(options, exception_state);
}

void Window::postMessage(const ScriptValue& message, ExceptionState& exception_state) {
  auto event_init = MessageEventInit::Create();
  event_init->setData(message);
  auto* message_event =
      MessageEvent::Create(GetExecutingContext(), event_type_names::kmessage, event_init, exception_state);
  dispatchEvent(message_event, exception_state);
}

void Window::postMessage(const ScriptValue& message,
                         const AtomicString& target_origin,
                         ExceptionState& exception_state) {
  auto event_init = MessageEventInit::Create();
  event_init->setData(message);
  event_init->setOrigin(target_origin);
  auto* message_event =
      MessageEvent::Create(GetExecutingContext(), event_type_names::kmessage, event_init, exception_state);
  dispatchEvent(message_event, exception_state);
}

// IMPL_FUNCTION(Window, requestAnimationFrame)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
//  if (argc <= 0) {
//    return JS_ThrowTypeError(ctx,
//                             "Failed to execute 'requestAnimationFrame': 1 argument required, but only 0 present.");
//  }
//
//  auto* context = static_cast<ExecutionContext*>(JS_GetContextOpaque(ctx));
//  auto window = static_cast<Window*>(JS_GetOpaque(context->global(), JSValueGetClassId(this_val)));
//
//  JSValue callbackValue = argv[0];
//
//  if (!JS_IsObject(callbackValue)) {
//    return JS_ThrowTypeError(ctx,
//                             "Failed to execute 'requestAnimationFrame': parameter 1 (callback) must be a function.");
//  }
//
//  if (!JS_IsFunction(ctx, callbackValue)) {
//    return JS_ThrowTypeError(ctx,
//                             "Failed to execute 'requestAnimationFrame': parameter 1 (callback) must be a function.");
//  }
//
//  // Flutter backend implements check
//#if FLUTTER_BACKEND
//  if (getDartMethod()->flushUICommand == nullptr) {
//    return JS_ThrowTypeError(
//        ctx, "Failed to execute '__kraken_flush_ui_command__': dart method (flushUICommand) is not registered.");
//  }
//  // Flush all pending ui messages.
//  getDartMethod()->flushUICommand();
//
//  if (getDartMethod()->requestAnimationFrame == nullptr) {
//    return JS_ThrowTypeError(
//        ctx, "Failed to execute 'requestAnimationFrame': dart method (requestAnimationFrame) is not registered.");
//  }
//#endif
//
//  auto* frameCallback = makeGarbageCollected<FrameCallback>(JS_DupValue(ctx, callbackValue))
//                            ->initialize<FrameCallback>(ctx, &FrameCallback::classId);
//
//  int32_t requestId = window->document()->requestAnimationFrame(frameCallback);
//
//  // `-1` represents some error occurred.
//  if (requestId == -1) {
//    return JS_ThrowTypeError(ctx,
//                             "Failed to execute 'requestAnimationFrame': dart method (requestAnimationFrame) executed
//                             " "with unexpected error.");
//  }
//
//  return JS_NewUint32(ctx, requestId);
//}
//
// IMPL_FUNCTION(Window, cancelAnimationFrame)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
//  if (argc <= 0) {
//    return JS_ThrowTypeError(ctx, "Failed to execute 'cancelAnimationFrame': 1 argument required, but only 0
//    present.");
//  }
//
//  auto context = static_cast<ExecutionContext*>(JS_GetContextOpaque(ctx));
//  auto window = static_cast<Window*>(JS_GetOpaque(context->global(), JSValueGetClassId(this_val)));
//
//  JSValue requestIdValue = argv[0];
//  if (!JS_IsNumber(requestIdValue)) {
//    return JS_ThrowTypeError(ctx, "Failed to execute 'cancelAnimationFrame': parameter 1 (timer) is not a timer
//    kind.");
//  }
//
//  int32_t id;
//  JS_ToInt32(ctx, &id, requestIdValue);
//
//  if (getDartMethod()->cancelAnimationFrame == nullptr) {
//    return JS_ThrowTypeError(
//        ctx, "Failed to execute 'cancelAnimationFrame': dart method (cancelAnimationFrame) is not registered.");
//  }
//
//  window->document()->cancelAnimationFrame(id);
//
//  return JS_NULL;
//}
//
// Window* Window::create(JSContext* ctx) {
//  auto* context = static_cast<ExecutionContext*>(JS_GetContextOpaque(ctx));
//  JSValue prototype = context->contextData()->prototypeForType(&windowTypeInfo);
//
//  auto* window = makeGarbageCollected<Window>()->initialize<Window>(ctx, &classId, nullptr);
//
//  // Let window inherit Window prototype methods.
//  JS_SetPrototype(ctx, window->toQuickJS(), prototype);
//
//  return window;
//}
//
// Document* Window::document() {
//  return context()->document();
//}
//
// Window::Window() {
//  if (getDartMethod()->initWindow != nullptr) {
//    getDartMethod()->initWindow(context()->getContextId(), nativeEventTarget);
//  }
//
//  m_location = makeGarbageCollected<Location>()->initialize<Location>(m_ctx, &Location::classId);
//}
//
// void Window::trace(JSRuntime* rt, JSValue val, JS_MarkFunc* mark_func) const {
//  EventTarget::trace(rt, val, mark_func);
//  JS_MarkValue(rt, onerror, mark_func);
//}
//
// IMPL_PROPERTY_GETTER(Window, devicePixelRatio)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
//  auto* window = static_cast<WindowInstance*>(JS_GetOpaque(this_val, 1));
//  return window->getBindingProperty("devicePixelRatio");
//}
//
// IMPL_PROPERTY_GETTER(Window, colorScheme)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
//  auto* window = static_cast<WindowInstance*>(JS_GetOpaque(this_val, 1));
//  return window->getBindingProperty("colorScheme");
//}
//
// IMPL_PROPERTY_GETTER(Window, innerWidth)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
//  auto* window = static_cast<WindowInstance*>(JS_GetOpaque(this_val, 1));
//  return window->getBindingProperty("innerWidth");
//}
//
// IMPL_PROPERTY_GETTER(Window, innerHeight)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
//  auto* window = static_cast<WindowInstance*>(JS_GetOpaque(this_val, 1));
//  return window->getBindingProperty("innerHeight");
//}
//
// IMPL_PROPERTY_GETTER(Window, __location__)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
//  auto* window = static_cast<Window*>(JS_GetOpaque(this_val, JSValueGetClassId(this_val)));
//  if (window == nullptr)
//    return JS_UNDEFINED;
//  return JS_DupValue(ctx, window->m_location->toQuickJS());
//}
//
// IMPL_PROPERTY_GETTER(Window, location)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
//  auto* window = static_cast<Window*>(JS_GetOpaque(this_val, 1));
//  return JS_GetPropertyStr(ctx, window->context()->global(), "location");
//}
//
// IMPL_PROPERTY_GETTER(Window, window)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
//  return JS_GetGlobalObject(ctx);
//}
//
// IMPL_PROPERTY_GETTER(Window, parent)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
//  return JS_GetGlobalObject(ctx);
//}
//
// IMPL_PROPERTY_GETTER(Window, scrollX)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
//  auto* window = static_cast<WindowInstance*>(JS_GetOpaque(this_val, 1));
//  return window->getBindingProperty("scrollX");
//}
//
// IMPL_PROPERTY_GETTER(Window, scrollY)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
//  auto* window = static_cast<WindowInstance*>(JS_GetOpaque(this_val, 1));
//  return window->getBindingProperty("scrollY");
//}
//
// IMPL_PROPERTY_GETTER(Window, onerror)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
//  auto* window = static_cast<Window*>(JS_GetOpaque(this_val, 1));
//  return JS_DupValue(ctx, window->onerror);
//}
// IMPL_PROPERTY_SETTER(Window, onerror)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
//  auto* window = static_cast<Window*>(JS_GetOpaque(this_val, 1));
//  JSValue eventString = JS_NewString(ctx, "onerror");
//  JSString* p = JS_VALUE_GET_STRING(eventString);
//  JSValue onerrorHandler = argv[0];
//  window->setAttributesEventHandler(p, onerrorHandler);
//
//  if (!JS_IsNull(window->onerror)) {
//    JS_FreeValue(ctx, window->onerror);
//  }
//
//  window->onerror = JS_DupValue(ctx, onerrorHandler);
//  JS_FreeValue(ctx, eventString);
//  return JS_NULL;
//}
//
// IMPL_PROPERTY_GETTER(Window, self)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
//  return JS_GetGlobalObject(ctx);
//}

}  // namespace kraken
