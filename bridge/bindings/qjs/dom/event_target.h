/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_EVENT_TARGET_H
#define KRAKENBRIDGE_EVENT_TARGET_H

#include "bindings/qjs/dom/event.h"
#include "bindings/qjs/host_class.h"
#include "bindings/qjs/js_context.h"
#include "bindings/qjs/native_value.h"

namespace kraken::binding::qjs {

class EventTargetInstance;
class NativeEventTarget;
class CSSStyleDeclaration;
class StyleDeclarationInstance;

class EventTarget : public HostClass {
public:
  JSValue constructor(QjsContext *ctx, JSValue func_obj, JSValue this_val, int argc, JSValue *argv) override;
  EventTarget() = delete;
  explicit EventTarget(JSContext *context) : HostClass(context, "EventTarget") {}
  explicit EventTarget(JSContext *context, const char* name): HostClass(context, name) {};

private:
  std::vector<std::string> m_jsOnlyEvents;

  static JSValue addEventListener(QjsContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv);
  static JSValue removeEventListener(QjsContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv);
  static JSValue dispatchEvent(QjsContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv);
#if defined(IS_TEST)
  static JSValue __kraken_clear_event_listener(QjsContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv);
#endif

  ObjectFunction m_addEventListener{m_context, m_prototypeObject, "addEventListener", addEventListener, 3};
  ObjectFunction m_removeEventListener{m_context, m_prototypeObject, "removeEventListener", removeEventListener, 2};
  ObjectFunction m_dispatchEvent{m_context, m_prototypeObject, "dispatchEvent", dispatchEvent, 1};
#if defined(IS_TEST)
  ObjectFunction m_kraken_clear_event_listener_{m_context, m_prototypeObject, "__kraken_clear_event_listeners__",
                                                __kraken_clear_event_listener, 0};
#endif
  friend EventTargetInstance;
};

using NativeDispatchEvent = void (*)(NativeEventTarget *nativeEventTarget, NativeString *eventType, void *nativeEvent,
                                     int32_t isCustomEvent);
using CallNativeMethods = void (*)(NativeEventTarget *nativeEventTarget, NativeValue *returnValue, NativeString *method, int32_t argc,
                                           NativeValue *argv);

struct NativeEventTarget {
  NativeEventTarget() = delete;
  explicit NativeEventTarget(EventTargetInstance *_instance)
    : instance(_instance), dispatchEvent(NativeEventTarget::dispatchEventImpl){};

  static void dispatchEventImpl(NativeEventTarget *nativeEventTarget, NativeString *eventType, void *nativeEvent,
                                int32_t isCustomEvent);

  EventTargetInstance *instance{nullptr};
  NativeDispatchEvent dispatchEvent{nullptr};
  CallNativeMethods callNativeMethods{nullptr};
};

class EventTargetInstance : public Instance {
public:
  EventTargetInstance() = delete;
  explicit EventTargetInstance(EventTarget *eventTarget);

  bool dispatchEvent(EventInstance *event);

  JSValue callNativeMethods(const char* method, int32_t argc,
                                NativeValue *argv);

protected:
  NativeEventTarget nativeEventTarget{this};
  int32_t eventTargetId;
private:
  bool internalDispatchEvent(EventInstance *eventInstance);
  std::unordered_map<std::string, std::forward_list<JSValue>> _eventHandlers;
  std::unordered_map<std::string, JSValue> _propertyEventHandler;
  friend EventTarget;
  friend StyleDeclarationInstance;
};

void bindEventTarget(std::unique_ptr<JSContext> &context);

} // namespace kraken::binding::qjs

#endif // KRAKENBRIDGE_EVENT_TARGET_H
