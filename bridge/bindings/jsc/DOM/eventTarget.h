/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_EVENTTARGET_H
#define KRAKENBRIDGE_EVENTTARGET_H

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
  explicit JSEventTarget(JSContext *context, const char* name);
  explicit JSEventTarget(JSContext *context);

  void instanceFinalized(JSObjectRef object) override;

  NativeEventTarget *getEventTarget() {
    return nativeEventTarget;
  }

  int64_t getEventTargetId();

private:
  NativeEventTarget *nativeEventTarget{nullptr};
  int64_t eventTargetId;
};

} // namespace kraken::binding::jsc

#endif // KRAKENBRIDGE_EVENTTARGET_H
