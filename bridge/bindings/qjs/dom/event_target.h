/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_EVENT_TARGET_H
#define KRAKENBRIDGE_EVENT_TARGET_H

#include "bindings/qjs/dom/event.h"
#include "bindings/qjs/executing_context.h"
#include "bindings/qjs/garbage_collected.h"
#include "bindings/qjs/heap_hashmap.h"
#include "bindings/qjs/native_value.h"
#include "bindings/qjs/qjs_patch.h"
#include "event_listener_map.h"

#if UNIT_TEST
void TEST_callNativeMethod(void* nativePtr, void* returnValue, void* method, int32_t argc, void* argv);
#endif

namespace kraken::binding::qjs {

class EventTarget;
class NativeEventTarget;
class CSSStyleDeclaration;
class StyleDeclarationInstance;

void bindEventTarget(std::unique_ptr<ExecutionContext>& context);

using NativeDispatchEvent = void (*)(NativeEventTarget* nativeEventTarget, NativeString* eventType, void* nativeEvent, int32_t isCustomEvent);
using CallNativeMethods = void (*)(void* nativePtr, NativeValue* returnValue, NativeString* method, int32_t argc, NativeValue* argv);

struct NativeEventTarget {
  NativeEventTarget() = delete;
  explicit NativeEventTarget(EventTarget* _instance) : instance(_instance), dispatchEvent(NativeEventTarget::dispatchEventImpl){};

  static void dispatchEventImpl(NativeEventTarget* nativeEventTarget, NativeString* eventType, void* nativeEvent, int32_t isCustomEvent);
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
  static JSValue addEventListener(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);
  static JSValue removeEventListener(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);
  static JSValue dispatchEvent(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);

  void trace(JSRuntime* rt, JSValue val, JS_MarkFunc* mark_func) const override;
  void dispose() const override;

  virtual bool dispatchEvent(EventInstance* event);
  inline int32_t eventTargetId() const { return m_eventTargetId; }

 protected:
  JSValue callNativeMethods(const char* method, int32_t argc, NativeValue* argv);
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

  bool internalDispatchEvent(EventInstance* eventInstance);

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
  auto* type = static_cast<const WrapperTypeInfo*>(JS_GetOpaque(func_obj, JSValueGetClassId(func_obj)));
  auto* eventTarget = EventTarget::create(ctx);
  auto* context = static_cast<ExecutionContext*>(JS_GetContextOpaque(ctx));
  JSValue prototype = context->contextData()->prototypeForType(type);

  // Let eventTarget instance inherit EventTarget prototype methods.
  JS_SetPrototype(ctx, eventTarget->toQuickJS(), prototype);

  return eventTarget->toQuickJS();
};

const WrapperTypeInfo eventTargetTypeInfo = {"EventTarget", nullptr, eventTargetCreator};

}  // namespace kraken::binding::qjs

#endif  // KRAKENBRIDGE_EVENT_TARGET_H
