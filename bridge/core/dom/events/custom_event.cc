/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "custom_event.h"
#include "bindings/qjs/native_value.h"
#include "bindings/qjs/qjs_engine_patch.h"

#include <utility>

namespace kraken {

void bindCustomEvent(std::unique_ptr<ExecutionContext>& context) {
  JSValue constructor = context->contextData()->constructorForType(&customEventTypeInfo);
  JSValue prototype = context->contextData()->prototypeForType(&customEventTypeInfo);

  // Install methods on prototype.
  INSTALL_FUNCTION(CustomEvent, prototype, initCustomEvent, 4);

  // Install readonly properties on prototype.
  INSTALL_READONLY_PROPERTY(CustomEvent, prototype, detail);

  context->defineGlobalProperty("CustomEvent", constructor);
}

JSClassID CustomEvent::classId{0};

CustomEvent* CustomEvent::create(JSContext* ctx, JSValue eventType, JSValue init) {
  auto* context = static_cast<ExecutionContext*>(JS_GetContextOpaque(ctx));
  JSValue prototype = context->contextData()->prototypeForType(&eventTypeInfo);

  auto* event = makeGarbageCollected<CustomEvent>(eventType, init)->initialize<CustomEvent>(ctx, &classId);

  if (!JS_IsNull(init)) {
    JSAtom detailKey = JS_NewAtom(ctx, "detail");
    if (JS_HasProperty(ctx, init, detailKey)) {
      JSValue detailValue = JS_GetProperty(ctx, init, detailKey);
      event->m_detail = JS_DupValue(ctx, detailValue);
      JS_FreeValue(ctx, detailValue);
    }
    JS_FreeAtom(ctx, detailKey);
  }

  // Let instance inherit prototype methods.
  JS_SetPrototype(ctx, event->toQuickJS(), prototype);

  return event;
}

CustomEvent* CustomEvent::create(JSContext* ctx, NativeCustomEvent* nativeCustomEvent) {
  auto* context = static_cast<ExecutionContext*>(JS_GetContextOpaque(ctx));
  JSValue prototype = context->contextData()->prototypeForType(&eventTypeInfo);

  auto* event = makeGarbageCollected<CustomEvent>(nativeCustomEvent)->initialize<CustomEvent>(ctx, &classId);

  // Let instance inherit prototype methods.
  JS_SetPrototype(ctx, event->toQuickJS(), prototype);

  return event;
}

JSValue CustomEvent::constructor(ExecutionContext* context) {
  return context->contextData()->constructorForType(&customEventTypeInfo);
}

JSValue CustomEvent::prototype(ExecutionContext* context) {
  return context->contextData()->prototypeForType(&customEventTypeInfo);
}

CustomEvent::CustomEvent(JSValue eventType, JSValue eventInit) : Event(eventType, eventInit) {
  if (!JS_IsNull(eventInit)) {
    JSAtom detailKey = JS_NewAtom(m_ctx, "detail");
    if (JS_HasProperty(m_ctx, eventInit, detailKey)) {
      JSValue detailValue = JS_GetProperty(m_ctx, eventInit, detailKey);
      m_detail = JS_DupValue(m_ctx, detailValue);
      JS_FreeValue(m_ctx, detailValue);
    }
    JS_FreeAtom(m_ctx, detailKey);
  }
}

CustomEvent::CustomEvent(NativeCustomEvent* nativeEvent)
    : m_nativeCustomEvent(nativeEvent), Event(reinterpret_cast<NativeEvent*>(nativeEvent)) {
  m_detail = JS_NewUnicodeString(m_runtime, m_ctx, nativeEvent->detail->string, nativeEvent->detail->length);
}

void CustomEvent::trace(JSRuntime* rt, JSValue val, JS_MarkFunc* mark_func) const {
  Event::trace(rt, val, mark_func);
  JS_MarkValue(rt, m_detail, mark_func);
}

void CustomEvent::dispose() const {
  // No needs to free m_nativeCustomEvent, Event::dispose() will handle this.
  Event::dispose();
  JS_FreeValueRT(m_runtime, m_detail);
}

IMPL_FUNCTION(CustomEvent, initCustomEvent)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  if (argc < 1) {
    return JS_ThrowTypeError(
        ctx, "Failed to execute 'initCustomEvent' on 'CustomEvent': 1 argument required, but only 0 present");
  }

  auto* eventInstance = static_cast<CustomEvent*>(JS_GetOpaque(this_val, CustomEvent::classId));
  if (eventInstance == nullptr) {
    return JS_ThrowTypeError(ctx, "Failed to addEventListener: this is not an EventTarget object.");
  }

  JSValue typeValue = argv[0];
  eventInstance->nativeEvent->type = jsValueToNativeString(ctx, typeValue).release();

  if (argc <= 2) {
    bool canBubble = JS_ToBool(ctx, argv[1]);
    eventInstance->nativeEvent->bubbles = canBubble ? 1 : 0;
  }

  if (argc <= 3) {
    bool cancelable = JS_ToBool(ctx, argv[2]);
    eventInstance->nativeEvent->cancelable = cancelable ? 1 : 0;
  }

  if (argc <= 4) {
    eventInstance->m_detail = JS_DupValue(ctx, argv[3]);
  }
  return JS_NULL;
}

IMPL_PROPERTY_GETTER(CustomEvent, detail)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* customEventInstance = static_cast<CustomEvent*>(JS_GetOpaque(this_val, CustomEvent::classId));
  return JS_DupValue(ctx, customEventInstance->m_detail);
}

}  // namespace kraken
