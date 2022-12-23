/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_EVENT_TARGET_H
#define KRAKENBRIDGE_EVENT_TARGET_H

#include "bindings/qjs/dom/event.h"
#include "bindings/qjs/executing_context.h"
#include "bindings/qjs/heap_hashmap.h"
#include "bindings/qjs/host_class.h"
#include "bindings/qjs/host_object.h"
#include "bindings/qjs/native_value.h"
#include "bindings/qjs/qjs_patch.h"
#include "event_listener_map.h"

#if UNIT_TEST
void TEST_invokeBindingMethod(void* nativePtr, void* returnValue, void* method, int32_t argc, void* argv);
#endif

#define GetPropertyMagic "%g"
#define SetPropertyMagic "%s"

namespace kraken::binding::qjs {

class EventTargetInstance;
class NativeEventTarget;
class CSSStyleDeclaration;
class StyleDeclarationInstance;

void bindEventTarget(ExecutionContext* context);

class EventTarget : public HostClass {
 public:
  static JSClassID kEventTargetClassId;
  JSValue instanceConstructor(JSContext* ctx, JSValue func_obj, JSValue this_val, int argc, JSValue* argv) override;
  EventTarget() = delete;
  explicit EventTarget(ExecutionContext* context, const char* name);
  explicit EventTarget(ExecutionContext* context);

  static JSClassID classId();
  static JSClassID classId(JSValue& value);

  OBJECT_INSTANCE(EventTarget);

 private:
  static JSValue addEventListener(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);
  static JSValue removeEventListener(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);
  static JSValue dispatchEvent(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);

  DEFINE_PROTOTYPE_FUNCTION(addEventListener, 3);
  DEFINE_PROTOTYPE_FUNCTION(removeEventListener, 2);
  DEFINE_PROTOTYPE_FUNCTION(dispatchEvent, 1);
  friend EventTargetInstance;
};

using NativeDispatchEvent = int32_t (*)(int32_t contextId, NativeEventTarget* nativeEventTarget, NativeString* eventType, void* nativeEvent, int32_t isCustomEvent);
using InvokeBindingMethod = void (*)(void* nativePtr, NativeValue* returnValue, NativeString* method, int32_t argc, NativeValue* argv);

struct NativeEventTarget {
  NativeEventTarget() = delete;
  explicit NativeEventTarget(EventTargetInstance* _instance) : instance(_instance), dispatchEvent(reinterpret_cast<NativeDispatchEvent>(NativeEventTarget::dispatchEventImpl)){};

  // Add more memory valid check with contextId.
  static int32_t dispatchEventImpl(int32_t contextId, NativeEventTarget* nativeEventTarget, NativeString* eventType, void* nativeEvent, int32_t isCustomEvent);
  EventTargetInstance* instance{nullptr};
  NativeDispatchEvent dispatchEvent{nullptr};
#if UNIT_TEST
  InvokeBindingMethod invokeBindingMethod{reinterpret_cast<InvokeBindingMethod>(TEST_invokeBindingMethod)};
#else
  InvokeBindingMethod invokeBindingMethod{nullptr};
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

class EventTargetInstance : public Instance {
 public:
  EventTargetInstance() = delete;
  explicit EventTargetInstance(EventTarget* eventTarget, JSClassID classId, JSClassExoticMethods& exoticMethods, std::string name);
  explicit EventTargetInstance(EventTarget* eventTarget, JSClassID classId, std::string name);
  explicit EventTargetInstance(EventTarget* eventTarget, JSClassID classId, std::string name, int64_t eventTargetId);
  ~EventTargetInstance();

  virtual bool dispatchEvent(EventInstance* event);
  static inline JSClassID classId();
  inline int32_t eventTargetId() const { return m_eventTargetId; }

  // @TODO: Should move to BindingObject.
  JSValue invokeBindingMethod(const char* method, int32_t argc, NativeValue* argv);
  JSValue getBindingProperty(const char* prop);
  void setBindingProperty(const char* prop, NativeValue value);

  NativeEventTarget* nativeEventTarget{new NativeEventTarget(this)};

 protected:
  int32_t m_eventTargetId;
  // EventListener handlers registered with addEventListener API.
  // https://dom.spec.whatwg.org/#concept-event-listener
  EventListenerMap m_eventListenerMap{m_ctx};

  // EventListener handlers registered with DOM attributes API.
  // https://html.spec.whatwg.org/C/#event-handler-attributes
  EventHandlerMap m_eventHandlerMap{m_ctx};

  // When javascript code set a property on EventTarget instance, EventTarget::setAttribute callback will be called when
  // property are not defined by Object.defineProperty or setAttribute.
  // We store there values in here.
  EventTargetProperties m_properties{m_ctx};

  void trace(JSRuntime* rt, JSValue val, JS_MarkFunc* mark_func) override;
  static void copyNodeProperties(EventTargetInstance* newNode, EventTargetInstance* referenceNode);

  static int hasProperty(JSContext* ctx, JSValueConst obj, JSAtom atom);
  static JSValue getProperty(JSContext* ctx, JSValueConst obj, JSAtom atom, JSValueConst receiver);
  static int setProperty(JSContext* ctx, JSValueConst obj, JSAtom atom, JSValueConst value, JSValueConst receiver, int flags);
  static int deleteProperty(JSContext* ctx, JSValueConst obj, JSAtom prop);

  // Used for legacy "onEvent" attribute APIs.
  void setAttributesEventHandler(JSString* p, JSValue value);
  JSValue getAttributesEventHandler(JSString* p);

 private:
  std::unordered_map<JSAtom, JSValue> m_cached_binding_function;

  bool internalDispatchEvent(EventInstance* eventInstance);
  static void finalize(JSRuntime* rt, JSValue val);
  friend EventTarget;
  friend StyleDeclarationInstance;
};

}  // namespace kraken::binding::qjs

#endif  // KRAKENBRIDGE_EVENT_TARGET_H
