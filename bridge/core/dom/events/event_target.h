/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_EVENT_TARGET_H
#define KRAKENBRIDGE_EVENT_TARGET_H

#include "foundation/macros.h"
#include "bindings/qjs/macros.h"
#include "bindings/qjs/heap_hashmap.h"
#include "core/executing_context.h"
#include "event_listener_map.h"

#if UNIT_TEST
void TEST_callNativeMethod(void* nativePtr, void* returnValue, void* method, int32_t argc, void* argv);
#endif

namespace kraken {

class EventTarget;
class NativeEventTarget;
class CSSStyleDeclaration;
class Event;

void bindEventTarget(ExecutionContext* context);

using NativeDispatchEvent = void (*)(int32_t contextId, NativeEventTarget* nativeEventTarget, NativeString* eventType, void* nativeEvent, int32_t isCustomEvent);
using CallNativeMethods = void (*)(void* nativePtr, NativeValue* returnValue, NativeString* method, int32_t argc, NativeValue* argv);

struct NativeEventTarget {
  NativeEventTarget() = delete;
  explicit NativeEventTarget(EventTarget* _instance) : instance(_instance), dispatchEvent(NativeEventTarget::dispatchEventImpl){};

  // Add more memory valid check with contextId.
  static void dispatchEventImpl(int32_t contextId, NativeEventTarget* nativeEventTarget, NativeString* eventType, void* nativeEvent, int32_t isCustomEvent);
  EventTarget* instance{nullptr};
  NativeDispatchEvent dispatchEvent{nullptr};
#if UNIT_TEST
  CallNativeMethods callNativeMethods{reinterpret_cast<CallNativeMethods>(TEST_callNativeMethod)};
#else
  CallNativeMethods callNativeMethods{nullptr};
#endif
};

class EventTargetProperties : public HeapHashMap<JSAtom> {
 public:
  EventTargetProperties(JSContext* ctx) : HeapHashMap<JSAtom>(ctx){};
};

class EventHandlerMap : public HeapHashMap<JSAtom> {
 public:
  EventHandlerMap(JSContext* ctx) : HeapHashMap<JSAtom>(ctx){};
};

class EventTarget : public GarbageCollected<EventTarget> {
 public:
  EventTarget();
  static JSClassID classId;
  static EventTarget* create(JSContext* ctx);
  static JSValue constructor(ExecutionContext* context);
  static JSValue prototype(ExecutionContext* context);

  DEFINE_FUNCTION(addEventListener);
  DEFINE_FUNCTION(removeEventListener);
  DEFINE_FUNCTION(dispatchEvent);

  void trace(JSRuntime* rt, JSValue val, JS_MarkFunc* mark_func) const override;
  void dispose() const override;

  virtual bool dispatchEvent(Event* event);
  FORCE_INLINE int32_t eventTargetId() const { return m_eventTargetId; }

  JSValue callNativeMethods(const char* method, int32_t argc, NativeValue* argv);

 protected:
  JSValue getNativeProperty(const char* prop);

  // Used for legacy "onEvent" attribute APIs.
  void setAttributesEventHandler(JSString* p, JSValue value);
  JSValue getAttributesEventHandler(JSString* p);
  static void copyNodeProperties(EventTarget* newNode, EventTarget* referenceNode);

  NativeEventTarget* nativeEventTarget{new NativeEventTarget(this)};

 private:
  static int hasProperty(JSContext* ctx, JSValueConst obj, JSAtom atom);
  static JSValue getProperty(JSContext* ctx, JSValueConst obj, JSAtom atom, JSValueConst receiver);
  static int setProperty(JSContext* ctx, JSValueConst obj, JSAtom atom, JSValueConst value, JSValueConst receiver, int flags);
  static int deleteProperty(JSContext* ctx, JSValueConst obj, JSAtom prop);

  bool internalDispatchEvent(Event* event);

  int32_t m_eventTargetId;
  // EventListener handlers registered with addEventListener API.
  // https://dom.spec.whatwg.org/#concept-event-listener
  EventListenerMap m_eventListenerMap{this->m_ctx};

  // EventListener handlers registered with DOM attributes API.
  // https://html.spec.whatwg.org/C/#event-handler-attributes
  EventHandlerMap m_eventHandlerMap{this->m_ctx};

  // When javascript code set a property on EventTarget instance, EventTarget::setProperty callback will be called when
  // property are not defined by Object.defineProperty or setProperty.
  // We store there values in here.
  EventTargetProperties m_properties{this->m_ctx};
};

auto eventTargetCreator = [](JSContext* ctx, JSValueConst func_obj, JSValueConst this_val, int argc, JSValueConst* argv, int flags) -> JSValue {
  auto* eventTarget = EventTarget::create(ctx);
  return eventTarget->toQuickJS();
};

const WrapperTypeInfo eventTargetTypeInfo = {"EventTarget", nullptr, eventTargetCreator};

}  // namespace kraken

#endif  // KRAKENBRIDGE_EVENT_TARGET_H
