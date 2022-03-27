/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_EVENT_TARGET_H
#define KRAKENBRIDGE_EVENT_TARGET_H

#include "bindings/qjs/qjs_function.h"
#include "bindings/qjs/script_wrappable.h"
#include "event_listener_map.h"
#include "foundation/native_string.h"

#if UNIT_TEST
void TEST_invokeBindingMethod(void* nativePtr, void* returnValue, void* method, int32_t argc, void* argv);
#endif

#define GetPropertyMagic "%g"
#define SetPropertyMagic "%s"

namespace kraken {

class EventTargetData final {
  KRAKEN_DISALLOW_NEW();
 public:
  EventTargetData();
  EventTargetData(const EventTargetData&) = delete;
  EventTargetData& operator=(const EventTargetData&) = delete;
  ~EventTargetData();

  void Trace(GCVisitor* visitor) const;

 private:
  EventListenerMap event_listener_map_;
};

// All DOM event targets extend EventTarget. The spec is defined here:
// https://dom.spec.whatwg.org/#interface-eventtarget
// EventTarget objects allow us to add and remove an event
// listeners of a specific event type. Each EventTarget object also represents
// the target to which an event is dispatched when something has occurred.
class EventTarget : public ScriptWrappable {
  DEFINE_WRAPPERTYPEINFO();

 public:
  using ImplType = EventTarget*;

  static EventTarget* Create(ExecutingContext* context);

  EventTarget() = delete;
  explicit EventTarget(ExecutingContext* context);

  bool addEventListener(std::unique_ptr<NativeString>& event_type, const std::shared_ptr<QJSFunction>& callback, ExceptionState& exception_state);

  void Trace(GCVisitor* visitor) const override;
  void Dispose() const override;

//  virtual bool AddEventListenerInternal(const AtomicString& event_type,
//                                        EventListener*,
//                                        const AddEventListenerOptionsResolved*);
//  bool RemoveEventListenerInternal(const AtomicString& event_type,
//                                   const EventListener*,
//                                   const EventListenerOptions*);
//
//  // Called when an event listener has been successfully added.
//  virtual void AddedEventListener(const AtomicString& event_type,
//                                  RegisteredEventListener&);
//
//  // Called when an event listener is removed. The original registration
//  // parameters of this event listener are available to be queried.
//  virtual void RemovedEventListener(const AtomicString& event_type,
//                                    const RegisteredEventListener&);
//
//  virtual DispatchEventResult DispatchEventInternal(Event&);

  // Subclasses should likely not override these themselves; instead, they
  // should subclass EventTargetWithInlineData.
  virtual EventTargetData* GetEventTargetData() = 0;
  virtual EventTargetData& EnsureEventTargetData() = 0;

  const char* GetHumanReadableName() const override;

 private:
};

// Provide EventTarget with inlined EventTargetData for improved performance.
class EventTargetWithInlineData : public EventTarget {
 public:
  void Trace(GCVisitor* visitor) const override;

 protected:
  EventTargetData* GetEventTargetData() final { return &data_; }
  EventTargetData& EnsureEventTargetData() final { return data_; }

 private:
  EventTargetData data_;
};


// Macros to define an attribute event listener.
//  |lower_name| - Lower-cased event type name.  e.g. |focus|
//  |symbol_name| - C++ symbol name in event_type_names namespace. e.g. |kFocus|
#define DEFINE_ATTRIBUTE_EVENT_LISTENER(lower_name, symbol_name)                                       \
  EventListener* on##lower_name() { return GetAttributeEventListener(event_type_names::symbol_name); } \
  void setOn##lower_name(EventListener* listener) { SetAttributeEventListener(event_type_names::symbol_name, listener); }

#define DEFINE_STATIC_ATTRIBUTE_EVENT_LISTENER(lower_name, symbol_name)                                                                           \
  static EventListener* on##lower_name(EventTarget& eventTarget) { return eventTarget.GetAttributeEventListener(event_type_names::symbol_name); } \
  static void setOn##lower_name(EventTarget& eventTarget, EventListener* listener) { eventTarget.SetAttributeEventListener(event_type_names::symbol_name, listener); }

#define DEFINE_WINDOW_ATTRIBUTE_EVENT_LISTENER(lower_name, symbol_name)                                                    \
  EventListener* on##lower_name() { return GetDocument().GetWindowAttributeEventListener(event_type_names::symbol_name); } \
  void setOn##lower_name(EventListener* listener) { GetDocument().SetWindowAttributeEventListener(event_type_names::symbol_name, listener); }

#define DEFINE_STATIC_WINDOW_ATTRIBUTE_EVENT_LISTENER(lower_name, symbol_name)                      \
  static EventListener* on##lower_name(EventTarget& eventTarget) {                                  \
    if (Node* node = eventTarget.ToNode()) {                                                        \
      return node->GetDocument().GetWindowAttributeEventListener(event_type_names::symbol_name);    \
    }                                                                                               \
    DCHECK(eventTarget.ToLocalDOMWindow());                                                         \
    return eventTarget.GetAttributeEventListener(event_type_names::symbol_name);                    \
  }                                                                                                 \
  static void setOn##lower_name(EventTarget& eventTarget, EventListener* listener) {                \
    if (Node* node = eventTarget.ToNode()) {                                                        \
      node->GetDocument().SetWindowAttributeEventListener(event_type_names::symbol_name, listener); \
    } else {                                                                                        \
      DCHECK(eventTarget.ToLocalDOMWindow());                                                       \
      eventTarget.SetAttributeEventListener(event_type_names::symbol_name, listener);               \
    }                                                                                               \
  }

//
// using NativeDispatchEvent = int32_t (*)(int32_t contextId, NativeEventTarget* nativeEventTarget, NativeString* eventType, void* nativeEvent, int32_t isCustomEvent);
// using InvokeBindingMethod = void (*)(void* nativePtr, NativeValue* returnValue, NativeString* method, int32_t argc, NativeValue* argv);
//
// struct NativeEventTarget {
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
// class EventTargetProperties : public HeapHashMap<JSAtom> {
// public:
//  EventTargetProperties(JSContext* ctx) : HeapHashMap<JSAtom>(ctx){};
//};
//
// class EventHandlerMap : public HeapHashMap<JSAtom> {
// public:
//  EventHandlerMap(JSContext* ctx) : HeapHashMap<JSAtom>(ctx){};
//};
//
// class EventTargetInstance : public Instance {
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

}  // namespace kraken

#endif  // KRAKENBRIDGE_EVENT_TARGET_H
