/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_EVENT_TARGET_H
#define KRAKENBRIDGE_EVENT_TARGET_H

#include "bindings/qjs/script_wrappable.h"
#include "event_listener_map.h"

#if UNIT_TEST
void TEST_invokeBindingMethod(void* nativePtr, void* returnValue, void* method, int32_t argc, void* argv);
#endif

#define GetPropertyMagic "%g"
#define SetPropertyMagic "%s"

namespace kraken {

// All DOM event targets extend EventTarget. The spec is defined here:
// https://dom.spec.whatwg.org/#interface-eventtarget
// EventTarget objects allow us to add and remove an event
// listeners of a specific event type. Each EventTarget object also represents
// the target to which an event is dispatched when something has occurred.
// All nodes are EventTargets, some other event targets include: XMLHttpRequest,
// AudioNode and AudioContext.

// To make your class an EventTarget, follow these steps:
// - Make your IDL interface inherit from EventTarget.
// - Inherit from EventTargetWithInlineData (only in rare cases should you
//   use EventTarget directly).
// - In your class declaration, EventTargetWithInlineData must come first in
//   the base class list. If your class is non-final, classes inheriting from
//   your class need to come first, too.
// - If you added an onfoo attribute, use DEFINE_ATTRIBUTE_EVENT_LISTENER(foo)
//   in your class declaration. Add "attribute EventHandler onfoo;" to the IDL
//   file.
// - Override EventTarget::interfaceName() and getExecutionContext(). The former
//   will typically return EventTargetNames::YourClassName. The latter will
//   return ExecutionContextLifecycleObserver::executionContext (if you are an
//   ExecutionContextLifecycleObserver)
//   or the document you're in.
// - Your trace() method will need to call EventTargetWithInlineData::trace
//   depending on the base class of your class.
class EventTarget : public ScriptWrappable {
  DEFINE_WRAPPERTYPEINFO();
 public:
  static EventTarget* Create(ExecutingContext* context);

  EventTarget() = delete;
  explicit EventTarget(ExecutingContext* context);

  void Trace(GCVisitor* visitor) const override;
  void Dispose() const override;

  const char* GetHumanReadableName() const override;
 private:
};
//
//using NativeDispatchEvent = int32_t (*)(int32_t contextId, NativeEventTarget* nativeEventTarget, NativeString* eventType, void* nativeEvent, int32_t isCustomEvent);
//using InvokeBindingMethod = void (*)(void* nativePtr, NativeValue* returnValue, NativeString* method, int32_t argc, NativeValue* argv);
//
//struct NativeEventTarget {
//  NativeEventTarget() = delete;
//  explicit NativeEventTarget(EventTargetInstance* _instance) : instance(_instance), dispatchEvent(reinterpret_cast<NativeDispatchEvent>(NativeEventTarget::dispatchEventImpl)){};
//
//  // Add more memory valid check with contextId.
//  static int32_t dispatchEventImpl(int32_t contextId, NativeEventTarget* nativeEventTarget, NativeString* eventType, void* nativeEvent, int32_t isCustomEvent);
//  EventTargetInstance* instance{nullptr};
//  NativeDispatchEvent dispatchEvent{nullptr};
//#if UNIT_TEST
//  InvokeBindingMethod invokeBindingMethod{reinterpret_cast<InvokeBindingMethod>(TEST_invokeBindingMethod)};
//#else
//  InvokeBindingMethod invokeBindingMethod{nullptr};
//#endif
//};
//
//class EventTargetProperties : public HeapHashMap<JSAtom> {
// public:
//  EventTargetProperties(JSContext* ctx) : HeapHashMap<JSAtom>(ctx){};
//};
//
//class EventHandlerMap : public HeapHashMap<JSAtom> {
// public:
//  EventHandlerMap(JSContext* ctx) : HeapHashMap<JSAtom>(ctx){};
//};
//
//class EventTargetInstance : public Instance {
// public:
//  EventTargetInstance() = delete;
//  explicit EventTargetInstance(EventTarget* eventTarget, JSClassID classId, JSClassExoticMethods& exoticMethods, std::string name);
//  explicit EventTargetInstance(EventTarget* eventTarget, JSClassID classId, std::string name);
//  explicit EventTargetInstance(EventTarget* eventTarget, JSClassID classId, std::string name, int64_t eventTargetId);
//  ~EventTargetInstance();
//
//  virtual bool dispatchEvent(EventInstance* event);
//  static inline JSClassID classId();
//  inline int32_t eventTargetId() const { return m_eventTargetId; }
//
//  // @TODO: Should move to BindingObject.
//  JSValue invokeBindingMethod(const char* method, int32_t argc, NativeValue* argv);
//  JSValue getBindingProperty(const char* prop);
//  void setBindingProperty(const char* prop, NativeValue value);
//
//  NativeEventTarget* nativeEventTarget{new NativeEventTarget(this)};
//
// protected:
//  int32_t m_eventTargetId;
//  // EventListener handlers registered with addEventListener API.
//  // https://dom.spec.whatwg.org/#concept-event-listener
//  EventListenerMap m_eventListenerMap{m_ctx};
//
//  // EventListener handlers registered with DOM attributes API.
//  // https://html.spec.whatwg.org/C/#event-handler-attributes
//  EventHandlerMap m_eventHandlerMap{m_ctx};
//
//  // When javascript code set a property on EventTarget instance, EventTarget::setAttribute callback will be called when
//  // property are not defined by Object.defineProperty or setAttribute.
//  // We store there values in here.
//  EventTargetProperties m_properties{m_ctx};
//
//  void trace(JSRuntime* rt, JSValue val, JS_MarkFunc* mark_func) override;
//  static void copyNodeProperties(EventTargetInstance* newNode, EventTargetInstance* referenceNode);
//
//  static int hasProperty(JSContext* ctx, JSValueConst obj, JSAtom atom);
//  static JSValue getProperty(JSContext* ctx, JSValueConst obj, JSAtom atom, JSValueConst receiver);
//  static int setProperty(JSContext* ctx, JSValueConst obj, JSAtom atom, JSValueConst value, JSValueConst receiver, int flags);
//  static int deleteProperty(JSContext* ctx, JSValueConst obj, JSAtom prop);
//
//  // Used for legacy "onEvent" attribute APIs.
//  void setAttributesEventHandler(JSString* p, JSValue value);
//  JSValue getAttributesEventHandler(JSString* p);
//
// private:
//  bool internalDispatchEvent(EventInstance* eventInstance);
//  static void finalize(JSRuntime* rt, JSValue val);
//  friend EventTarget;
//  friend StyleDeclarationInstance;
//};

}  // namespace kraken::binding::qjs

#endif  // KRAKENBRIDGE_EVENT_TARGET_H
