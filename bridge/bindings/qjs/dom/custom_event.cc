/*
 * Copyright (C) 2021-present The Kraken authors. All rights reserved.
 */

#include "custom_event.h"
#include "bindings/qjs/qjs_patch.h"
#include "kraken_bridge.h"

#include <utility>

namespace kraken::binding::qjs {

void bindCustomEvent(ExecutionContext* context) {
  auto* constructor = CustomEvent::instance(context);
  context->defineGlobalProperty("CustomEvent", constructor->jsObject);
}

JSValue CustomEvent::initCustomEvent(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  if (argc < 1) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'initCustomEvent' on 'CustomEvent': 1 argument required, but only 0 present");
  }

  auto* eventInstance = static_cast<CustomEventInstance*>(JS_GetOpaque(this_val, Event::kEventClassID));
  if (eventInstance == nullptr) {
    return JS_ThrowTypeError(ctx, "Failed to addEventListener: this is not an EventTarget object.");
  }

  JSValue typeValue = argv[0];
  eventInstance->setType(jsValueToNativeString(ctx, typeValue).release());

  if (argc <= 2) {
    bool canBubble = JS_ToBool(ctx, argv[1]);
    eventInstance->nativeEvent->bubbles = canBubble ? 1 : 0;
  }

  if (argc <= 3) {
    bool cancelable = JS_ToBool(ctx, argv[2]);
    eventInstance->nativeEvent->cancelable = cancelable ? 1 : 0;
  }

  if (argc <= 4) {
    eventInstance->m_detail.value(argv[3]);
  }
  return JS_NULL;
}

JSValue CustomEvent::instanceConstructor(JSContext* ctx, JSValue func_obj, JSValue this_val, int argc, JSValue* argv) {
  if (argc < 1) {
    return JS_ThrowTypeError(ctx, "Failed to construct 'CustomEvent': 1 argument required, but only 0 present.");
  }

  JSValue typeArgsValue = argv[0];
  JSValue customEventInit = JS_NULL;

  if (argc == 2) {
    customEventInit = argv[1];
  }

  JSAtom typeAtom = JS_ValueToAtom(m_ctx, typeArgsValue);
  auto* customEvent = new CustomEventInstance(CustomEvent::instance(context()), typeAtom, customEventInit);
  JS_FreeAtom(m_ctx, typeAtom);

  return customEvent->jsObject;
}

IMPL_PROPERTY_GETTER(CustomEvent, detail)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* customEventInstance = static_cast<CustomEventInstance*>(JS_GetOpaque(this_val, Event::kEventClassID));
  return customEventInstance->m_detail.value();
}

CustomEventInstance::CustomEventInstance(CustomEvent* jsCustomEvent, JSAtom customEventType, JSValue eventInit) : EventInstance(jsCustomEvent, customEventType, eventInit) {
  if (!JS_IsNull(eventInit)) {
    JSAtom detailKey = JS_NewAtom(m_ctx, "detail");
    if (JS_HasProperty(m_ctx, eventInit, detailKey)) {
      JSValue detailValue = JS_GetProperty(m_ctx, eventInit, detailKey);
      m_detail.value(detailValue);
      JS_FreeValue(m_ctx, detailValue);
    }
    JS_FreeAtom(m_ctx, detailKey);
  }
}

CustomEventInstance::CustomEventInstance(CustomEvent* jsCustomEvent, NativeCustomEvent* nativeCustomEvent)
    : nativeCustomEvent(nativeCustomEvent), EventInstance(jsCustomEvent, reinterpret_cast<NativeEvent*>(nativeCustomEvent)) {
  auto* detail = reinterpret_cast<NativeString*>(nativeCustomEvent->detail);
  JSValue newDetail = JS_NewUnicodeString(jsCustomEvent->context()->runtime(), jsCustomEvent->context()->ctx(), detail->string, detail->length);
  detail->free();
  m_detail.value(newDetail);
  JS_FreeValue(m_ctx, newDetail);
}
}  // namespace kraken::binding::qjs
