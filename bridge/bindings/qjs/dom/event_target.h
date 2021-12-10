/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_EVENT_TARGET_H
#define KRAKENBRIDGE_EVENT_TARGET_H

#include "bindings/qjs/dom/event.h"
#include "bindings/qjs/host_class.h"
#include "bindings/qjs/host_object.h"
#include "bindings/qjs/js_context.h"
#include "bindings/qjs/native_value.h"
#include "bindings/qjs/qjs_patch.h"

namespace kraken::binding::qjs {

class EventTargetInstance;
class NativeEventTarget;
class CSSStyleDeclaration;
class StyleDeclarationInstance;

void bindEventTarget(std::unique_ptr<JSContext>& context);

class EventTarget : public HostClass {
 public:
  static JSClassID kEventTargetClassId;
  JSValue instanceConstructor(QjsContext* ctx, JSValue func_obj, JSValue this_val, int argc, JSValue* argv) override;
  EventTarget() = delete;
  explicit EventTarget(JSContext* context, const char* name);
  explicit EventTarget(JSContext* context);

  static JSClassID classId();
  static JSClassID classId(JSValue& value);

  OBJECT_INSTANCE(EventTarget);

 private:
  static JSValue addEventListener(QjsContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);
  static JSValue removeEventListener(QjsContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);
  static JSValue dispatchEvent(QjsContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);

  DEFINE_PROTOTYPE_FUNCTION(addEventListener, 3);
  DEFINE_PROTOTYPE_FUNCTION(removeEventListener, 2);
  DEFINE_PROTOTYPE_FUNCTION(dispatchEvent, 1);
  friend EventTargetInstance;
};

using NativeDispatchEvent = void (*)(NativeEventTarget* nativeEventTarget, NativeString* eventType, void* nativeEvent, int32_t isCustomEvent);
using CallNativeMethods = void (*)(void* nativePtr, NativeValue* returnValue, NativeString* method, int32_t argc, NativeValue* argv);

struct NativeEventTarget {
  NativeEventTarget() = delete;
  explicit NativeEventTarget(EventTargetInstance* _instance) : instance(_instance), dispatchEvent(NativeEventTarget::dispatchEventImpl){};

  static void dispatchEventImpl(NativeEventTarget* nativeEventTarget, NativeString* eventType, void* nativeEvent, int32_t isCustomEvent);
  EventTargetInstance* instance{nullptr};
  NativeDispatchEvent dispatchEvent{nullptr};
  CallNativeMethods callNativeMethods{nullptr};
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

  JSValue callNativeMethods(const char* method, int32_t argc, NativeValue* argv);
  JSValue getNativeProperty(const char* prop);

  NativeEventTarget* nativeEventTarget{new NativeEventTarget(this)};

 protected:
  int32_t m_eventTargetId;
  ObjectProperty m_eventHandlers{m_context, jsObject, "__eventHandlers", JS_NewObject(m_ctx)};
  ObjectProperty m_propertyEventHandler{m_context, jsObject, "__propertyEventHandler", JS_NewObject(m_ctx)};
  ObjectProperty m_properties{m_context, jsObject, "__properties", JS_NewObject(m_ctx)};

  void gcMark(JSRuntime* rt, JSValue val, JS_MarkFunc* mark_func) override;
  static void copyNodeProperties(EventTargetInstance* newNode, EventTargetInstance* referenceNode);

  static int hasProperty(QjsContext* ctx, JSValueConst obj, JSAtom atom);
  static JSValue getProperty(QjsContext* ctx, JSValueConst obj, JSAtom atom, JSValueConst receiver);
  static int setProperty(QjsContext* ctx, JSValueConst obj, JSAtom atom, JSValueConst value, JSValueConst receiver, int flags);
  static int deleteProperty(QjsContext* ctx, JSValueConst obj, JSAtom prop);

  void setPropertyHandler(JSString* p, JSValue value);
  JSValue getPropertyHandler(JSString* p);

 private:
  bool internalDispatchEvent(EventInstance* eventInstance);
  static void finalize(JSRuntime* rt, JSValue val);
  friend EventTarget;
  friend StyleDeclarationInstance;
};

}  // namespace kraken::binding::qjs

#endif  // KRAKENBRIDGE_EVENT_TARGET_H
