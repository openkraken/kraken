/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_EVENTTARGET_H
#define KRAKENBRIDGE_EVENTTARGET_H

#include "bindings/jsc/host_class.h"
#include "bindings/jsc/js_context.h"
#include "bindings/jsc/DOM/event.h"
#include "dart_methods.h"
#include "foundation/logging.h"
#include "foundation/ui_command_queue.h"
#include "foundation/ui_task_queue.h"
#include "include/kraken_bridge.h"
#include <array>
#include <atomic>
#include <condition_variable>

namespace kraken::binding::jsc {

void bindEventTarget(std::unique_ptr<JSContext> &context);

struct DisposeCallbackData {
  DisposeCallbackData(int32_t contextId, int64_t id) : contextId(contextId), id(id){};
  int64_t id;
  int32_t contextId;
};

class JSEventTarget : public HostClass {
public:
  static JSEventTarget *instance(JSContext *context);

  JSEventTarget() = delete;
  explicit JSEventTarget(JSContext *context, const char *name);
  explicit JSEventTarget(JSContext *context);

  JSObjectRef instanceConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argumentCount,
                                const JSValueRef *arguments, JSValueRef *exception) override;

  class EventTargetInstance : public Instance {
  public:
    static JSValueRef addEventListener(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
                                       size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception);
    static JSValueRef removeEventListener(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
                                          size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception);
    static JSValueRef dispatchEvent(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
                                    size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception);
    EventTargetInstance() = delete;
    explicit EventTargetInstance(JSEventTarget *eventTarget);
    explicit EventTargetInstance(JSEventTarget *eventTarget, int64_t targetId);
    JSValueRef getProperty(JSStringRef name, JSValueRef *exception) override;
    void setProperty(JSStringRef name, JSValueRef value, JSValueRef *exception) override;
    void getPropertyNames(JSPropertyNameAccumulatorRef accumulator) override;
    JSValueRef getPropertyHandler(std::string &name, JSValueRef *exception);
    void setPropertyHandler(std::string &name, JSValueRef value, JSValueRef *exception);

    ~EventTargetInstance() override;
    int64_t eventTargetId;
  private:
    std::map<EventType, std::deque<JSObjectRef>> _eventHandlers;
    bool _dispatchEvent(JSEvent::EventInstance *eventInstance);

  private:
    std::array<JSStringRef, 3> propertyNames{
      JSStringCreateWithUTF8CString("addEventListener"),
      JSStringCreateWithUTF8CString("removeEventListener"),
      JSStringCreateWithUTF8CString("dispatchEvent"),
    };
  };
};

struct NativeEvent;
struct NativeEventTarget;
using NativeDispatchEvent = void (*)(NativeEventTarget *nativeEventTarget, NativeEvent *nativeEvent);

struct NativeEventTarget {
  NativeEventTarget() = delete;
  NativeEventTarget(JSEventTarget::EventTargetInstance *_instance, NativeDispatchEvent dispatchEvent)
    : instance(_instance), dispatchEvent(dispatchEvent){};

  static void dispatchEventImpl(NativeEventTarget *nativeEventTarget, NativeEvent *nativeEvent);

  JSEventTarget::EventTargetInstance *instance;
  NativeDispatchEvent dispatchEvent;
};

} // namespace kraken::binding::jsc

#endif // KRAKENBRIDGE_EVENTTARGET_H
