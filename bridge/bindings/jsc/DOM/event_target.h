/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_EVENT_TARGET_H
#define KRAKENBRIDGE_EVENT_TARGET_H

#include "bindings/jsc/DOM/event.h"
#include "bindings/jsc/host_class.h"
#include "bindings/jsc/js_context.h"
#include "dart_methods.h"
#include "foundation/logging.h"
#include "foundation/ui_command_queue.h"
#include "foundation/ui_task_queue.h"
#include "include/kraken_bridge.h"
#include <array>
#include <atomic>
#include <condition_variable>
#include <unordered_map>

namespace kraken::binding::jsc {

void bindEventTarget(std::unique_ptr<JSContext> &context);

struct DisposeCallbackData {
  DisposeCallbackData(int32_t contextId, int64_t id) : contextId(contextId), id(id){};
  int64_t id;
  int32_t contextId;
};

struct NativeEvent;
struct NativeEventTarget;

class JSEventTarget : public HostClass {
public:
  static std::unordered_map<JSContext *, JSEventTarget *> instanceMap;
  static JSEventTarget *instance(JSContext *context);
  enum class EventTargetProperty {
    kAddEventListener,
    kRemoveEventListener,
    kDispatchEvent,
    kClearListeners,
    kEventTargetId
  };
  static std::vector<JSStringRef> &getEventTargetPropertyNames();
  static const std::unordered_map<std::string, EventTargetProperty> &getEventTargetPropertyMap();

  JSObjectRef instanceConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argumentCount,
                                  const JSValueRef *arguments, JSValueRef *exception) override;

  JSValueRef prototypeGetProperty(std::string &name, JSValueRef *exception) override;

  static JSValueRef addEventListener(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
                                     size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception);

  static JSValueRef removeEventListener(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
                                        size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception);

  static JSValueRef dispatchEvent(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                                  const JSValueRef arguments[], JSValueRef *exception);
  static JSValueRef clearListeners(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                                   const JSValueRef arguments[], JSValueRef *exception);

  class EventTargetInstance : public Instance {
  public:
    EventTargetInstance() = delete;
    explicit EventTargetInstance(JSEventTarget *eventTarget);
    explicit EventTargetInstance(JSEventTarget *eventTarget, int64_t targetId);
    JSValueRef getProperty(std::string &name, JSValueRef *exception) override;
    void setProperty(std::string &name, JSValueRef value, JSValueRef *exception) override;
    void getPropertyNames(JSPropertyNameAccumulatorRef accumulator) override;
    JSValueRef getPropertyHandler(std::string &name, JSValueRef *exception);
    void setPropertyHandler(std::string &name, JSValueRef value, JSValueRef *exception);

    bool dispatchEvent(EventInstance *event);

    ~EventTargetInstance() override;
    int32_t eventTargetId;
    NativeEventTarget *nativeEventTarget {nullptr};

  private:
    friend JSEventTarget;
    // TODO: use std::u16string for better performance.
    std::unordered_map<std::string, std::deque<JSObjectRef>> _eventHandlers;
    bool internalDispatchEvent(EventInstance *eventInstance);
  };

protected:
  JSEventTarget() = delete;
  friend EventTargetInstance;
  explicit JSEventTarget(JSContext *context, const char *name);
  explicit JSEventTarget(JSContext *context, const JSStaticFunction *staticFunction, const JSStaticValue *staticValue);
  ~JSEventTarget();

private:
  JSFunctionHolder m_removeEventListener{context, this, "removeEventListener", removeEventListener};
  JSFunctionHolder m_dispatchEvent{context, this, "dispatchEvent", dispatchEvent};
  JSFunctionHolder m_clearListeners{context, this, "clearListeners", clearListeners};
  JSFunctionHolder m_addEventListener{context, this, "addEventListener", addEventListener};
  std::vector<std::string> m_jsOnlyEvents;
};

using NativeDispatchEvent = void (*)(NativeEventTarget *nativeEventTarget, NativeString *eventType, void *nativeEvent);

struct NativeEventTarget {
  NativeEventTarget() = delete;
  NativeEventTarget(JSEventTarget::EventTargetInstance *_instance)
    : instance(_instance), dispatchEvent(NativeEventTarget::dispatchEventImpl){};

  static void dispatchEventImpl(NativeEventTarget *nativeEventTarget, NativeString *eventType, void *nativeEvent);

  JSEventTarget::EventTargetInstance *instance;
  NativeDispatchEvent dispatchEvent;
};

} // namespace kraken::binding::jsc

#endif // KRAKENBRIDGE_EVENT_TARGET_H
