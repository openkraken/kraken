/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_EVENTTARGET_H
#define KRAKENBRIDGE_EVENTTARGET_H

#include "bindings/jsc/host_class.h"
#include "bindings/jsc/js_context.h"
#include "dart_methods.h"
#include "foundation/logging.h"
#include "foundation/ui_command_queue.h"
#include "foundation/ui_task_queue.h"
#include "include/kraken_bridge.h"
#include <atomic>
#include <condition_variable>

namespace kraken::binding::jsc {

struct DisposeCallbackData {
  DisposeCallbackData(int32_t contextId, int64_t id) : contextId(contextId), id(id){};
  int64_t id;
  int32_t contextId;
};

class JSEventTarget : public HostClass {
public:
  JSEventTarget() = delete;
  explicit JSEventTarget(JSContext *context, const char *name);
  explicit JSEventTarget(JSContext *context);

  static JSValueRef addEventListener(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
                                     size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception);
  static JSValueRef removeEventListener(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
                                        size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception);
  static JSValueRef dispatchEvent(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                                  const JSValueRef arguments[], JSValueRef *exception);

  class EventTargetInstance : public Instance {
  public:
    EventTargetInstance() = delete;
    explicit EventTargetInstance(JSEventTarget *eventTarget);
    ~EventTargetInstance() override;
    int64_t eventTargetId;
    std::map<std::string, std::deque<JSObjectRef>> _eventHandlers;
  };

  JSValueRef prototypeGetProperty(Instance *instance, JSStringRef name, JSValueRef *exception) override;
};

} // namespace kraken::binding::jsc

#endif // KRAKENBRIDGE_EVENTTARGET_H
